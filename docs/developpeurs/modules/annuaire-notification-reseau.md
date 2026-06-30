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
	- Pagination: page numerique, taille fixe 12.
	- Filtrage entreprise/poste base sur derniere experience (`ExperienceLib`).
	- Filtrage specialite via `specialiteprofil`.
	- Exclut profils inactifs (`estactif = 1`).
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

## Reseau professionnel

Page:

- `opus-war/web/pages/alumni/reseau-professionnel.jsp`

Endpoint:

- `opus-war/web/pages/alumni/ajax/calculer-reseau.jsp` -> `ReseauService.calculerReseau`

Service:

- `opus-ejb/src/java/alumni/ReseauService.java`

Fonction cle:

- `ReseauService.calculerReseau(int refuser, String nomuser)`
	- Calcule un score de compatibilite /100:
		- tags specialites (Jaccard, max 50)
		- parcours commun (20)
		- poste commun (15)
		- proximite annee promo (15)
	- Retourne graphe JSON `nodes` + `edges` pour rendu reseau.

## Carte alumni

Page:

- `opus-war/web/pages/map/cart.jsp`

Endpoint:

- `opus-war/web/pages/map/ajax/get-alumni.jsp` -> `MapService.getAlumni`

Service:

- `opus-ejb/src/java/alumni/MapService.java`

Fonction cle:

- `MapService.getAlumni(String contextPath)`
	- Retourne un JSON array brut (pas d'enveloppe `success`).
	- Charge profils localises actifs (`v_profil_localisation`).
	- Enrichit avec specialites, photo, initiales, promo, parcours.

## Entites/tables frequentes

- `Profil` / `ProfilLib`
- `Notification`
- `VProfilLocalisation`
- `Promotion`, `Parcours`, `Specialite` (filtres annuaire)

## Points de vigilance relais

- La recherche annuaire combine filtres APJ + post-filtrage Java; bien tester cumul de filtres.
- Notifications: attention au `limitParam` cote front pour eviter surcharge inutile.
- Reseau: la methode fait plusieurs requetes batch SQL; verifier performances si volumetrie augmente.
- Carte: verifier que `contextPath` est correct, sinon photos cassent.
