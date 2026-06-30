# Module Annuaire, Notifications, Reseau et Carte

## Portee

Recherche alumni, fiche utilisateur, notifications utilisateur, graphe reseau professionnel, carte de localisation alumni.

## Annuaire

Pages:

- `opus-war/web/pages/annuaire/annuaire.jsp`
- `opus-war/web/pages/annuaire/fiche-utilisateur.jsp`

Endpoint:

- `opus-war/web/pages/annuaire/ajax/recherche-annuaire.jsp` -> `AnnuaireService.rechercher`

Service:

- `opus-ejb/src/java/alumni/AnnuaireService.java`

Fonction cle:

- `AnnuaireService.rechercher(...)`
  - Filtres supportes: nom, promotion, parcours, specialite, entreprise, poste, annee.
  - Exclut profils inactifs (`estactif = 1`).
  - **Filtre nom bidirectionnel** : cherche `LOWER(nom || ' ' || prenom) LIKE '%query%'` ET `LOWER(prenom || ' ' || nom) LIKE '%query%'` — ordre prenom/nom ne bloque pas la recherche.
  - **Filtres entreprise/poste** : post-filtrage en Java (pas en SQL). Charge toutes les `ExperienceLib` per profil puis filtre en Java sur la DERNIERE experience (`debut DESC`). Si la base est large et ces filtres actifs, c'est couteux (N requetes).
  - **Filtre specialite** : second post-filtrage en Java via `CGenUtil.rechercher(Specialiteprofil)`.
  - **Pagination Java** : le `total` retourne est le nombre de resultats APRES filtrage complet, pas la taille brute en DB. La pagination est calculee sur cette liste.
  - **Specialites dans resultats** : affiche max 3 specialites par profil.
  - Retour JSON avec `total`, `page`, `totalPages`, `resultats`.

## Notifications

Pages:

- `opus-war/web/pages/alumni/notifications.jsp`

Endpoints:

- `opus-war/web/pages/alumni/ajax/charger-notifications.jsp` -> `NotificationAlumniService.chargerNotifications`
- `opus-war/web/pages/alumni/ajax/marquer-notification-lu.jsp` -> `NotificationAlumniService.marquerLu`

Service:

- `opus-ejb/src/java/alumni/NotificationAlumniService.java`

Fonctions cles:

- `NotificationAlumniService.chargerNotifications(int refuser, String limitParam)`
	- Charge notifications triees date/heure desc.
	- Calcule `nbNonLu`, `ecart` temps humain (`j`, `h`, `min`, `A l'instant`).
	- Mappe `typenotif` vers icone UI (`bi-*`).

- `NotificationAlumniService.marquerLu(int refuser, String idnotification, String action)`
	- `action=all`: mark all unread via SQL prepare.
	- Sinon mark one by id avec verification d'appartenance utilisateur.

## WebSocket temps reel (`NotificationSocket`)

Fichier: `opus-ejb/src/java/web/socket/NotificationSocket.java`

Endpoint: `@ServerEndpoint("/ws/notifications")`

### Protocole client

Le client JS se connecte a `ws://<host>/opus/ws/notifications` et envoie immediatement:

```
register:<userId>
```

Cela lie la session WebSocket a l'utilisateur. Un meme utilisateur peut avoir plusieurs sessions (plusieurs onglets ouverts).

### Envoi de notifications

`Notification.creerEtEnvoyer()` est la methode centrale pour persister une notification ET envoyer le push WebSocket. Elle utilise `NotificationSocket.broadcast()` — ce qui signifie que **tous** les clients connectes recoivent le message. C'est le front-end JS qui filtre par `refUser` pour n'afficher que les notifications qui lui sont destinees.

Format du message WebSocket envoye:

```json
{"refUser":"<idutilisateur>","message":"<objet>","type":"<typenotif>"}
```

Types de notification (`Notification.TYPE_*`): `COMMENT`, `REPLY`, `PUB_REACTION`, `COMM_REACTION`, `MENTION`, `IDENTIFICATION`, `EVENEMENT`, `HASHTAG`.

### Point de vigilance relais

- `NotificationSocket.broadcastToUser(userId, message)` existe mais n'est pas utilise actuellement. Si les volumes augmentent, remplacer `broadcast()` par `broadcastToUser()` dans `Notification.creerEtEnvoyer()` pour eviter que chaque client recoive toutes les notifications du systeme.
- Ne jamais appeler `NotificationSocket` depuis les JSP. Le push doit transiter par la methode `Notification.creerEtEnvoyer()` dans l'EJB.
- Si le WebSocket n'est pas declenche, verifier que le client a bien envoye `register:<userId>` apres connexion.

## Reseau professionnel

Page:

- `opus-war/web/pages/alumni/reseau-professionnel.jsp`

Endpoint:

- `opus-war/web/pages/alumni/ajax/calculer-reseau.jsp` -> `ReseauService.calculerReseau`

Service:

- `opus-ejb/src/java/alumni/ReseauService.java`

Fonction cle:

- `ReseauService.calculerReseau(int refuser, String nomuser)`
  - **LIMITE HARDCODEE : 20 autres profils maximum** (`LIMIT 20` en SQL). Le graphe ne montre jamais plus de 20 membres.
  - Calcule un score de compatibilite /100 :
    - **Specialites (max 50)** : similarite Jaccard = `|intersection| / |union| * 50`. Si aucune specialite commune = 0.
    - **Parcours (20)** : 20 si `idparcours` identique, sinon 0.
    - **Poste (15)** : compare le `idposte` (pas le libelle) de la DERNIERE experience active (`fin DESC LIMIT 1`). 15 si identique, sinon 0.
    - **Annee promo (max 15)** : graduation par ecart d'annees — ecart=0 → 15, ecart≤1 → 12, ecart≤3 → 8, ecart≤5 → 3, ecart>5 → 0.
  - **Aretes (edges)** : une arete n'est creee que si `score >= 20` OU au moins une specialite en commun. Un profil avec score < 20 et 0 specialite commune apparait comme nœud isole sans lien.
  - Retourne graphe JSON `nodes` + `edges` pour rendu reseau.
  - Charge specialites et postes de tous les 20 profils en 2 requetes batch (IN) — ne pas modifier en boucle N+1.

## Carte alumni

Page:

- `opus-war/web/pages/map/cart.jsp`

Endpoint:

- `opus-war/web/pages/map/ajax/get-alumni.jsp` -> `MapService.getAlumni`

Service:

- `opus-ejb/src/java/alumni/MapService.java`

Fonction cle:

- `MapService.getAlumni(String contextPath)`
  - **Retourne un JSON array brut** (`[...]`) sans enveloppe `{success:true, data:[...]}` — comportement different de TOUS les autres services. Le JSP consommateur ne doit pas chercher un champ `success`.
  - N'affiche que les utilisateurs avec une entree dans `profilemplacement` via la vue `v_profil_localisation`. Les utilisateurs sans coordonnees sont invisibles sur la carte.
  - Photo : si `photo.startsWith("http")`, utilisee telle quelle (URL absolue) ; sinon `contextPath + "/" + photo` est prepende.

## Entites/tables frequentes

- `Profil` / `ProfilLib`
- `Notification`
- `VProfilLocalisation`
- `Promotion`, `Parcours`, `Specialite` (filtres annuaire)

## Points de vigilance relais

- Annuaire : le filtre specialite utilise un pattern N+1 (une requete APJ par profil). Tres couteux si beaucoup de profils passent les filtres precedents. Ne pas ajouter de filtres supplementaires en Java sans evaluer l'impact.
- Notifications : `getIconeType` ne gere pas `TYPE_EVENEMENT` et `TYPE_HASHTAG` — ces deux types affichent l'icone generique `bi-bell`. Ajouter les cas manquants dans `NotificationAlumniService` si des icones specifiques sont souhaitees.
- Reseau: la methode fait plusieurs requetes batch SQL; verifier performances si volumetrie augmente.
- Carte: `MapService` retourne un tableau brut (pas d'enveloppe `success`) — ne pas adapter le JSP consommateur au format standard sans modifier le service.
