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

- `SpecialiteAdminService.modifier(...)`
  - Met a jour libelle/description/photo.

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
  - Valeur minimale acceptee: `-1`.
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

- Publication admin est en soft delete, donc les donnees restent en base.
- En admin specialite, la gestion fichier image est decouplee (upload JSP, persistance service).
- Les limites de role impactent directement `CreerPublicationService.verifierDroitPublication`.
