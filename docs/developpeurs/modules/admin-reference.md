# Module Administration et Referentiel

## Portee

Administration des publications, specialites, limites de role, menus, tableaux de bord.

## Publication Admin

Pages:

- `opus-war/web/pages/publication/publication-modif.jsp`

Endpoints:

- `opus-war/web/pages/publication/ajax/traitement-update.jsp` -> `PublicationAdminService.modifier`
- `opus-war/web/pages/publication/ajax/traitement-delete.jsp` -> `PublicationAdminService.supprimer`

Service:

- `opus-ejb/src/java/alumni/PublicationAdminService.java`

Fonctions cles:

- `PublicationAdminService.supprimer(int refuser, String idpublication)`
  - Verifie propriete de la publication.
  - Fait un soft delete (`etat=0`).

- `PublicationAdminService.modifier(...)`
  - Verifie propriete de la publication.
  - Met a jour description + type publication, avec historisation.

## Specialite Admin

Pages:

- `opus-war/web/pages/specialite/specialite-list.jsp`
- `opus-war/web/pages/specialite/specialite-saisie.jsp`
- `opus-war/web/pages/specialite/specialite-modif.jsp`

Endpoints:

- `opus-war/web/pages/specialite/ajax/traitement-insert.jsp` -> `SpecialiteAdminService.inserer`
- `opus-war/web/pages/specialite/ajax/traitement-update.jsp` -> `SpecialiteAdminService.modifier`

Service:

- `opus-ejb/src/java/alumni/SpecialiteAdminService.java`

Fonctions cles:

- `SpecialiteAdminService.inserer(...)`
  - Cree specialite avec photo (chemin relatif deja gere cote JSP).
  - **Aucun controle de doublon sur le libelle** : deux specialites avec le meme nom peuvent etre inserees. Le matching hashtag normalise les libelles et peut alors produire des doublons dans `publicationhashtag`.

- `SpecialiteAdminService.modifier(...)`
  - Met a jour libelle/description/photo.
  - **L'ancien fichier photo n'est pas supprime du disque** lors d'un changement de photo. Les anciens fichiers s'accumulent indefiniment dans le repertoire de deploiement.

## Limite de role

Pages:

- `opus-war/web/pages/limiterole/limiterole-list.jsp`
- `opus-war/web/pages/limiterole/limiterole-modif.jsp`

Endpoint:

- `opus-war/web/pages/limiterole/ajax/traitement-update.jsp` -> `LimiteroleService.modifier`

Service:

- `opus-ejb/src/java/alumni/LimiteroleService.java`

Fonction cle:

- `LimiteroleService.modifier(String userId, String idrole, String maxpubStr)`
  - Convertit et valide `maxpubStr`.
  - **Semantique des valeurs** : `-1` = illimite, `0` = publication totalement bloquee, `> 0` = quota journalier.
  - Valeur minimale acceptee: `-1` (valeurs < -1 rejetees avec erreur explicite).
  - **Nouveau role sans ligne dans `limiterole`** : la methode `Limiterole.verifierDroitPublication()` retourne `-1` par defaut → publications illimitees par defaut pour tout role non configure.
  - **Faille quota** : les publications soft-deletees (`etat=0`) ne sont PAS comptees dans le quota journalier. Un utilisateur peut supprimer et republier pour contourner la limite.
  - Met a jour `maxpublicationparjour`.

## Menu et Dashboard

- Menu CRUD: `opus-war/web/pages/menu/*`
- Dashboard: `opus-war/web/pages/dashboard/dashboard.jsp`

## Entites/tables frequentes

- `Limiterole` -> `limiterole`
- `Specialite` -> `specialite`
- `Publication` -> `publication`
- Menus: verifier scripts et pages dans `menu/` selon besoin

## Cas typiques de modification

- Changer un droit admin:
  - controler logique dans service metier
  - verifier restrictions front dans JSP
  - valider impact sur menu/navigation

## Points de vigilance relais

- **Suppression moderateur (`mod/detail-signalement.jsp`)** : la suppression par le md est faite via SQL direct dans le JSP (`UPDATE publication SET etat = 0`) — PAS via `PublicationAdminService.supprimer()`. Elle ne verifie pas la propriete (le md peut supprimer n'importe quelle publication) et **n'est pas historisee**. Les suppressions de l'utilisateur normal via `PublicationAdminService` sont, elles, soumises au check de propriete mais aussi sans historisation (`updateToTableDirecte`).
- **Role check mod** : `"md".equals(roleConnecte)` est hardcode dans le JSP. Tout renommage du role md necessite une modification de ce JSP.
- Publication admin est en soft delete, donc les donnees restent en base. Les medias, hashtags, reactions, commentaires associes NE sont PAS supprimes.
- En admin specialite, la gestion fichier image est decouplee (upload JSP, persistance service). L'ancienne photo n'est jamais supprimee du disque.
- Les limites de role impactent directement `CreerPublicationService.verifierDroitPublication`. Un role sans ligne dans `limiterole` a un quota illimite par defaut.
