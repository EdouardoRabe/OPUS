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
  - Toute la methode est dans une seule transaction (`setAutoCommit(false)` / `commit`). Un echec partiel rollback tout.
  - Cree la publication (`publication`) avec type par defaut `TPB000001`.
  - Ajoute medias (`media`) deja uploades par JSP.
  - Ajoute identifications (`identification`) et declenche notifications cibles.
  - Parse hashtags de `description` et cree des liens dans `publicationhashtag`.
  - Point technique: `publicationhashtag` est en PK SERIAL, insertion via SQL raw avec `ON CONFLICT DO NOTHING`.
  - Cree notifications "hashtag" en ciblant les utilisateurs concernes.
  - Persiste regles de visibilite dans `publicationvisibilite` (SPECIALITE/PARCOURS/PROMOTION).
  - Gere la logique de visibilite `AND` via `publication.logique_visibilite`.

**Logique de matching hashtag (important):**
- Regex : `#([A-Za-z0-9]+)`, normalise en majuscules sans caracteres speciaux.
- **Les caracteres accentues sont supprimes silencieusement** : `#Génie` → token `GNIE`. Un utilisateur qui tape `#Genie` sans accent arrive au meme token, mais `#Génie` avec accent rate le match si le libelle contient l'accent et est normalise differemment.
- Specialite : match flou (prefixe OU suffixe suffisant — `sNorm.startsWith(tok) || tok.startsWith(sNorm)`).
- Promotion : match EXACT uniquement.
- Parcours : match flou (meme logique que specialite).
- Consequence : `#DEV` peut matcher "DEVELOPPEMENT" (prefixe), et inversement.
- **Notifications de masse** : un hashtag SPECIALITE envoie une notification a TOUS les utilisateurs ayant cette specialite. Aucune limite de destinataires. Pour une specialite populaire, une seule publication peut generer des centaines d'inserts DB + WebSocket pushes en une seule transaction.
- Message de notification hashtag hardcode : `"a publie une offre qui vous concerne"` — utilise ce texte pour tous les types de publication, y compris les evenements ou questions.

**Logique de visibilite dans le feed (`FeedHtmlService.buildVisibiliteClause`):**
- Une publication EST visible si : auteur = connecte, OU aucune regle dans `publicationvisibilite`, OU regles matchent.
- Logique OR (defaut) : ANY des criteres (SPECIALITE ou PARCOURS ou PROMOTION) suffit.
- Logique AND (`logique_visibilite='AND'`) : TOUS les criteres **presents** doivent matcher. Si une dimension est absente (ex: pas de ligne PROMOTION), cette dimension est considered comme satisfaite. Exemple : AND avec seulement une ligne SPECIALITE est visible a toutes les promotions et tous les parcours.
- Critere PROMOTION : compare l'annee (`promotion.annee`) de l'utilisateur connecte contre `anneeref` et `anneedirection` ('+' = annee >= anneeref, '-' = annee <= anneeref) — pas par idpromotion.
- Le feed exclut automatiquement les publications des utilisateurs bannis (`estactif=0`). L'auteur voit toujours SES propres publications meme si elles seraient exclues par la visibilite pour les autres.

**Filtre multi-hashtag dans le feed (`buildHashtagClause`):**
- Plusieurs filtres actifs en meme temps : combines en AND si `filterLier=1`, sinon OR.

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
  - Tri **chronologique** par `idpublication DESC` — pas de score. La page profil n'utilise PAS la formule de ranking.
  - Ne filtre PAS les publications des utilisateurs bannis (contrairement au feed principal). Un moderateur qui consulte le profil d'un banni peut voir toutes ses publications.
  - Pagination par `cursorId` uniquement (pas de cursorScore).

Classe: `CommentaireService`

- `commenter(...)`
  - Insert commentaire (`publicationcommentaire`), gere reply (`idparent`) et mentions.
  - Cree notifications type reply/comment/mention avec anti-doublon utilisateurs notifies.

- `chargerCommentaires(...)`
  - Retourne JSON complet: commentaires, reactionTypes, reactions agragees, `myReaction`, info auteur/photo/profil, statut banni.

Classe: `ReactionService`

- `reagirPublication(...)`
  - Toggle : supprime reaction existante, re-insere seulement si type DIFFERENT (clic sur meme type = suppression pure).
  - Notification envoyee UNIQUEMENT sur NOUVELLE reaction (pas sur changement de type, pas sur suppression).
  - Auto-reaction interdite : proprietaire de la publication n'est jamais notifie de sa propre reaction.

- `reagirCommentaire(...)`
  - Meme logique que reagirPublication, notification au proprietaire du commentaire.

- `detailReactions(...)`
  - Retourne detail par type: emoji, count, liste utilisateurs reacteurs.
  - Emojis derives du libelle : mots-cles `adore/love` → ❤️, `haha/humour` → 😂, `surprise/wow` → 😮, `triste/sad` → 😢, `grrr/ang` → 😠, sinon 👍.

Classe: `PublicationActionService`

- `marquerVue(...)`
  - Upsert `publicationvue` + incrementation `nbvue`.

- `toggleSave(...)`
  - Toggle bookmark dans `publicationenregistrement`.

- `reportPublication(...)`
  - Signalement multi-types : cree UNE ligne dans `signalementpublication` par type de motif coche. Un signalement avec 3 motifs = 3 inserts.
  - Au moins un type requis, sinon retourne erreur metier.

- `partagerPublication(...)`
  - Interdit auto-partage (`origPub.idutilisateur == refuser` → erreur).
  - Interdit partage d'une publication inactive (`etat != 1`).
  - Copie le `idtypepublication` de la publication originale (pas TPB000001 par defaut).
  - Notification a l'auteur original via `TYPE_MENTION` (pas un TYPE_SHARE dedie — a retenir pour triage de bugs notifications).

Classe: `PublicationAdminService`

- `supprimer(...)`
  - Verification de propriete via `CGenUtil.rechercher(critere, null, null, "")` SANS connexion passee (APJ ouvre la sienne).
  - Soft delete via `updateToTableDirecte` (raw SQL UPDATE) — PAS via `updateToTableWithHisto` : la suppression n'est PAS historisee.

- `modifier(...)`
  - Meme verification de propriete sans connexion.
  - Mise a jour via `updateToTableWithHisto` (historisee, contrairement a supprimer).
  - **Ne reprocesse pas les hashtags ni la visibilite** : si l'utilisateur retire un hashtag de la description modifiee, les anciennes lignes `publicationhashtag` restent en base.

Classe: `PublicationActionService` — points supplementaires

- `marquerVue` : compteur `nbvue` incremente a chaque appel (`ON CONFLICT DO UPDATE SET nbvue = nbvue + 1`). Ouvrir la meme publication plusieurs fois augmente la penalite de score dans le feed de cet utilisateur.
- `partagerPublication` : ne verifie pas si l'auteur du partage peut voir la publication originale. Un utilisateur peut partager une publication dont il ne fait pas partie du public cible, s'il en connait l'ID.
- `reportPublication` : aucun check de doublon — un meme utilisateur peut signaler la meme publication avec le meme motif plusieurs fois.

**Upload media (JSP `creer-publication.jsp`) — details techniques :**
- Taille max : **50 Mo par fichier** ET **50 Mo total** (les deux limites sont identiques en pratique).
- Toutes les images (PNG, GIF, WEBP, etc.) sont **recompressees en JPEG** : les transparences PNG sont perdues, le format d'origine est abandonne.
- Redimensionnement seulement si > 1200×1200 px ; en dessous, l'image est quand meme recodee en JPEG.
- Les fichiers sont stockes dans **`dossier.war/async/publications/`**, PAS sous `opus.war`. Le deploiement doit inclure `dossier.war` en parallele sinon les uploads echouent silencieusement.
- Types media hardcodes : `MDT000001` (image), `MDT000002` (video si `contentType.startsWith("video/")`). Tout autre type est traite comme image.
- Le `idtypepublication` par defaut `TPB000001` est defini DEUX fois : dans le JSP ET dans `CreerPublicationService`. Si on change la valeur, modifier les deux endroits.

Classe: `CommentaireService`

- Anti-doublon notifications : utilise un `Set notifiedUsers`. Si le propriétaire de la pub est aussi l'auteur du commentaire parent, il ne reçoit qu'une notification (reply), pas deux.
- `chargerCommentaires` : commentaires tries par `idpublicationcommentaire ASC` (ordre chronologique insertion).

Classe: `HashtagSuggestService`

- `suggest(String query)`
  - Recherche insensible a la casse et aux espaces (`UPPER(REPLACE(libelle,' ',''))`).
  - Retourne max 5 resultats par categorie (5 promotions + 5 specialites + 5 parcours = 15 suggestions max).
  - Tags specialite et parcours tronques a **21 caracteres** (hashtag compris). Si un libelle depasse 20 chars, le hashtag sera coupe.
  - Promotions triees par annee DESC, specialites/parcours par libelle ASC.

Classe: `IdentificationService`

- `identifier(int refuser, String idpublication, String idsUtilisateurs)`
  - Anti-doublon : n'insere pas si l'utilisateur est deja identifie dans cette publication.
  - Envoie notification `TYPE_IDENTIFICATION` uniquement pour les NOUVELLES identifications.
  - Retourne `nbIdentifies` (nb nouvelles identifications, pas le total).
  - Le lien de notification utilise `#pub-<id>` (ancre HTML), different de `&scrollTo=pub-` utilise par `creerPublication`.

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
