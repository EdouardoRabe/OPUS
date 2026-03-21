# Module Profil

## Portee

Profil utilisateur, infos personnelles, photo, CV, experiences, statut, specialites, reseaux sociaux, confidentialite, mot de passe.

## UI et endpoints

Pages principales:

- `opus-war/web/pages/profil/voir.jsp`
- `opus-war/web/pages/profil/profil-modif.jsp`
- `opus-war/web/pages/profil/confidentialite.jsp`

Endpoints AJAX majeurs:

- `opus-war/web/pages/profil/ajax/traitement-profil-info.jsp` -> `ProfilService.updateProfilInfo`
- `opus-war/web/pages/profil/ajax/traitement-password.jsp` -> `ProfilService.changePassword`
- `opus-war/web/pages/profil/ajax/traitement-photo.jsp` -> `ProfilService.uploadPhoto`
- `opus-war/web/pages/profil/ajax/traitement-cv.jsp` -> `ProfilService.uploadCv`
- `opus-war/web/pages/profil/ajax/traitement-cv-delete.jsp` -> `ProfilService.deleteCv`
- `opus-war/web/pages/profil/ajax/traitement-experience.jsp` -> `ProfilService.crudExperience`
- `opus-war/web/pages/profil/ajax/traitement-specialite.jsp` -> `ProfilService.crudSpecialite`
- `opus-war/web/pages/profil/ajax/traitement-socialmedia.jsp` -> `ProfilService.crudSocialMedia`
- `opus-war/web/pages/profil/ajax/traitement-localisation.jsp` -> `ProfilService.crudLocalisation`
- `opus-war/web/pages/profil/ajax/traitement-profilstatut.jsp` -> `ProfilService.updateStatut`
- `opus-war/web/pages/profil/ajax/traitement-confidentialite.jsp` -> `ProfilService.updateConfidentialite`

## Services metier (EJB)

- `opus-ejb/src/java/alumni/ProfilService.java`
- `opus-ejb/src/java/alumni/UtilisateurSearchService.java` (recherche utilisateur associee)

## Fonctions cles et responsabilites (code)

Classe: `ProfilService`

- `updateConfidentialite(int refuser, String idprofil, Map statusMap)`
  - Resout `idprofil` automatiquement si absent via `Profil.findByRefUser`.
  - Parcourt 12 champs (`nom`, `prenom`, `dtn`, `experience`, `specialite`, `promotion`, `email`, `parcours`, `telephone`, `genre`, `socialmedia`, `localisation`).
  - Fait un upsert logique dans `visibilite` (update si existe, sinon insert) avec historisation.
  - Retour JSON: `{"success":true}` ou erreur explicite.

- `deleteCv(int refuser)`
  - Supprime physiquement le fichier CV sur disque sous `jboss.server.base.dir/deployments/opus.war/...`.
  - Met ensuite `profil.cv` a `null` et historise.

- `uploadCv(int refuser, String cvRelPath)`
  - Le JSP se charge du stockage fichier, le service ne fait que persister le chemin relatif en DB.

- `crudExperience(...)`
  - Actions supportees: `create`, `update`, `delete`, `list`.
  - Verifie que l'experience appartient bien au profil de l'utilisateur connecte.
  - Retourne aussi `postelib` (via `ExperienceLib`) pour mise a jour UI immediate.

- `crudLocalisation(...)`
  - Actions supportees: `create`, `update`.
  - Persiste latitude/longitude dans `profilemplacement`.

- `changePassword(...)`
  - Verifie ancien mot de passe via `Paramcrypt` + `Utilitaire.cryptWord`.
  - Fait un `UPDATE utilisateur SET pwduser = ?` en SQL prepare.
  - Retourne `_pwdCrypt` pour permettre au JSP de resynchroniser la session.

- `uploadPhoto(int refuser, int photoType, String photoRelPath)`
  - Inserte une nouvelle ligne dans `photo` (pas un update in-place), avec date/heure.

- `updateProfilInfo(int refuser, String nom, String prenom, String telephone)`
  - Met a jour `utilisateur.nomuser` et `utilisateur.teluser`.
  - Utilise SQL prepare (contournement de probleme de type sur `refuser` integer).

- `updateStatut(...)`
  - Cree une nouvelle entree dans `profilstatut` (historisation de statut).

- `crudSocialMedia(...)`
  - Actions: `add`, `delete`, `list`.
  - Anti-doublon sur (`idprofil`, `idreseausocial`).
  - Retour enrichi (`libelle`, `icone`, `couleur`, `urlpattern`) pour rendu front.

- `crudSpecialite(...)`
  - Actions: `add`, `update`, `delete`, `list`.
  - Anti-doublon sur (`idprofil`, `idspecialite`).
  - Gere le `niveau` de specialite.

## Entites/tables frequentes

- `Profil` -> `profil`
- `ProfilLib` -> `profillib`
- `Photo` -> `photo`
- `Experience` / `ExperienceLib` -> `experience` / `experiencelib`
- `Specialiteprofil` -> `specialiteprofil`
- `ProfilSocialMedia` -> `profilsocialmedia`
- `Profilemplacement` -> `profilemplacement`
- `ProfilStatut` / `ProfilTypeStatut`
- `Visibilite` (confidentialite)

## Cas typiques de modification

- Ajouter un nouveau champ profil:
  - UI dans `profil-modif.jsp` ou `voir.jsp`
  - endpoint AJAX associe
  - `ProfilService`
  - classe metier/table SQL + script BDD

- Modifier la logique de confidentialite:
  - `traitement-confidentialite.jsp`
  - `ProfilService.updateConfidentialite`
  - table `visibilite`

## Points de vigilance relais

- Les endpoints JSP `profil/ajax/*` font une partie de la validation d'entree, mais la regle metier doit rester dans `ProfilService`.
- Pour mot de passe et infos utilisateur, le service utilise du SQL prepare volontairement (ne pas "simplifier" en cassant le typage).
- Upload CV/photo: verifier le couple fichier disque + chemin relatif persiste, sinon liens casses en UI.

## Runbook debug rapide

- Si le profil ne se met pas a jour:
  - verifier session user dans endpoint JSP
  - verifier JSON retour de `ProfilService`
  - verifier lignes impactees en DB (`profil`, `utilisateur`, `visibilite`)

- Si CV/photo ne s'affiche pas:
  - verifier path relatif stocke
  - verifier presence du fichier sous deployment WildFly
  - verifier construction d'URL dans JSP
