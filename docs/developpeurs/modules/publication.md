# Module Publication

## Portee

Fil d'actualite, creation publication, commentaires, reactions, mentions, hashtag, partage, enregistrement, signalement.

## UI et endpoints

Pages principales:

- `opus-war/web/pages/accueil.jsp`
- `opus-war/web/pages/publication.jsp`
- `opus-war/web/pages/alumni/fil-actualite.jsp`
- `opus-war/web/pages/alumni/publications-enregistrees.jsp`
- `opus-war/web/pages/alumni/signaler-publication.jsp`

Endpoints AJAX majeurs (WAR):

- `opus-war/web/pages/alumni/ajax/creer-publication.jsp` -> `CreerPublicationService`
- `opus-war/web/pages/alumni/ajax/charger-feed.jsp` -> `FeedHtmlService`
- `opus-war/web/pages/alumni/ajax/commenter.jsp` -> `CommentaireService`
- `opus-war/web/pages/alumni/ajax/charger-commentaires.jsp` -> `CommentaireService`
- `opus-war/web/pages/alumni/ajax/reagir-publication.jsp` -> `ReactionService`
- `opus-war/web/pages/alumni/ajax/reagir-commentaire.jsp` -> `ReactionService`
- `opus-war/web/pages/alumni/ajax/partager-publication.jsp` -> `PublicationActionService`
- `opus-war/web/pages/alumni/ajax/save-publication.jsp` -> `PublicationActionService`
- `opus-war/web/pages/alumni/ajax/marquer-vue.jsp` -> `PublicationActionService`
- `opus-war/web/pages/alumni/ajax/report-publication.jsp` -> `PublicationActionService`
- `opus-war/web/pages/alumni/ajax/hashtag-suggest.jsp` -> `HashtagSuggestService`
- `opus-war/web/pages/alumni/ajax/identifier.jsp` -> `IdentificationService`

## Services metier (EJB)

- `opus-ejb/src/java/alumni/CreerPublicationService.java`
- `opus-ejb/src/java/alumni/FeedHtmlService.java`
- `opus-ejb/src/java/alumni/CommentaireService.java`
- `opus-ejb/src/java/alumni/ReactionService.java`
- `opus-ejb/src/java/alumni/PublicationActionService.java`
- `opus-ejb/src/java/alumni/PublicationAdminService.java`
- `opus-ejb/src/java/alumni/HashtagSuggestService.java`
- `opus-ejb/src/java/alumni/IdentificationService.java`

## Fonctions cles et responsabilites (code)

Classe: `CreerPublicationService`

- `verifierDroitPublication(String idrole, int refuser)`
  - Delegue au controle de quota via `Limiterole.verifierDroitPublication`.
  - Retourne `null` si autorise, sinon message metier bloquant.

- `creerPublication(...)`
  - Cree la publication (`publication`) avec type par defaut `TPB000001`.
  - Ajoute medias (`media`) deja uploades par JSP.
  - Ajoute identifications (`identification`) et declenche notifications cibles.
  - Parse hashtags de `description` et cree des liens dans `publicationhashtag`.
  - Cree notifications "hashtag" en ciblant les utilisateurs concernes.
  - Persiste regles de visibilite dans `publicationvisibilite` (SPECIALITE/PARCOURS/PROMOTION).
  - Gere la logique de visibilite `AND` via `publication.logique_visibilite`.
  - Point technique important: `publicationhashtag` est en PK SERIAL, insertion via SQL raw dediee.

Classe: `FeedHtmlService`

- Variables de score modifiables:
  - `POIDS_REACTION=2`, `POIDS_COMMENTAIRE=3`, `POIDS_VUE=4`, bonus recence (`15/8/3`).
  - `PAGE_SIZE=10`.

- `chargerFeed(...)`
  - Applique visibilite (`buildVisibiliteClause`) + filtres hashtag/type (`buildHashtagClause`).
  - Classement par score SQL (`buildScoreFormula`) puis pagination par curseur (`cursorScore`, `cursorId`).
  - Pre-charge toutes les donnees de rendu pour `publication.jsp`:
    - medias, reactions, commentaires, identifications, bookmarks, pub originale partagee.

- `voirPublication(...)`
  - Charge une publication unique + toutes donnees associees de rendu.

- `publicationsProfil(...)`
  - Resout cible via `paramIdUser` ou `paramIdProfil`, puis pagination par `cursorId`.

Classe: `CommentaireService`

- `commenter(...)`
  - Insert commentaire (`publicationcommentaire`), gere reply (`idparent`) et mentions.
  - Cree notifications type reply/comment/mention avec anti-doublon utilisateurs notifies.

- `chargerCommentaires(...)`
  - Retourne JSON complet: commentaires, reactionTypes, reactions agragees, `myReaction`, info auteur/photo/profil, statut banni.

Classe: `ReactionService`

- `reagirPublication(...)`
  - Toggle reaction utilisateur sur publication (delete + optional insert si changement).
  - Notifie le proprietaire de publication.

- `reagirCommentaire(...)`
  - Meme logique pour commentaire, notification au proprietaire du commentaire.

- `detailReactions(...)`
  - Retourne detail par type: emoji, count, liste utilisateurs reacteurs.

Classe: `PublicationActionService`

- `marquerVue(...)`
  - Upsert `publicationvue` + incrementation `nbvue`.

- `toggleSave(...)`
  - Toggle bookmark dans `publicationenregistrement`.

- `reportPublication(...)`
  - Cree une entree `signalementpublication` par type selectionne.

- `partagerPublication(...)`
  - Cree nouvelle publication partagee (`idpuborigine`), interdit auto-partage, notifie auteur original.

Classe: `PublicationAdminService`

- `supprimer(...)`
  - Soft delete via `etat=0` apres verification de propriete.

- `modifier(...)`
  - Met a jour description/type apres verification de propriete.

## Entites/tables frequentes

- `Publication` -> `publication`
- `Publicationcommentaire` -> `publicationcommentaire`
- `Publicationreaction` -> `publicationreaction`
- `Publicationenregistrement` -> `publicationenregistrement`
- `Publicationhashtag` -> `publicationhashtag`
- `Mention` -> `mention`
- `Notification` -> `notification`
- `Signalementpublication` / `Typesignalement`

## Cas typiques de modification

- Ajouter un nouveau type d'action publication:
  - endpoint JSP AJAX
  - methode dans `PublicationActionService`
  - table associee (+ script SQL)
  - rendu feed dans `FeedHtmlService`

- Changer les regles de droit de publication:
  - `CreerPublicationService` et possiblement `LimiteroleService`

## Tables les plus impactees

- `publication`
- `media`
- `publicationcommentaire`
- `publicationreaction`
- `commentairereaction`
- `publicationhashtag`
- `publicationvisibilite`
- `publicationvue`
- `publicationenregistrement`
- `identification`
- `mention`
- `notification`
- `signalementpublication`

## Points de vigilance relais

- Ne pas casser la pagination curseur du feed (`cursorScore` + `cursorId`) sinon duplications/trous.
- Eviter de deplacer la logique metier dans les JSP AJAX; garder les regles dans services `alumni`.
- Les rules de visibilite/hashtag combinent SQL et logique metier, donc tester feed avec plusieurs profils.

## Scenarios de test minimum apres modif

- Creation publication avec medias + hashtags + visibilite.
- Commentaire + reply + mention (verification notifications).
- Reaction publication/commentaire (toggle + notification).
- Partage publication + rendu de la publication originale.
- Signalement multi-types.
