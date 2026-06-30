# Module Evenement

## Portee

Creation, modification, publication d'evenement, participation, annulation, listing JSON calendrier.

## UI et endpoints

Pages principales:

- `opus-war/web/pages/evenement/evenement-calendar.jsp`
- `opus-war/web/pages/evenement/evenement-list.jsp`
- `opus-war/web/pages/evenement/evenement-fiche.jsp`
- `opus-war/web/pages/evenement/evenement-saisie.jsp`
- `opus-war/web/pages/evenement/evenement-modif.jsp`

Endpoints AJAX:

- `opus-war/web/pages/evenement/ajax/liste-json.jsp` -> `EvenementService.listeJson`
- `opus-war/web/pages/evenement/ajax/traitement-insert.jsp` -> `EvenementService.insererEvenement`
- `opus-war/web/pages/evenement/ajax/traitement-update.jsp` -> `EvenementService.updateEvenement`
- `opus-war/web/pages/evenement/ajax/traitement-publier.jsp` -> `EvenementService.publierEvenement`
- `opus-war/web/pages/evenement/ajax/traitement-participer.jsp` -> `EvenementService.participer`
- `opus-war/web/pages/evenement/ajax/traitement-annuler.jsp` -> `EvenementService.annulerParticipation`
- `opus-war/web/pages/evenement/ajax/check-participation.jsp` -> `EvenementService.checkParticipation`

## Service metier (EJB)

- `opus-ejb/src/java/alumni/EvenementService.java`

## Fonctions cles et responsabilites (code)

Classe: `EvenementService`

- `checkParticipation(int refuser, String idevenement)`
  - Verifie si l'utilisateur participe deja.
  - Retourne aussi le nombre total de participants (`total`).

- `listeJson(int refuser, String pStart, String pEnd)`
  - Retour FullCalendar JSON sur intervalle de dates.
  - Enrichit chaque evenement avec:
    - `participating` (si user connecte participe)
    - `nbParticipants`
    - `color` : couleur issue d'un tableau de 8 codes hex hardcodes, cyclee par index (`i % 8`). Si on ajoute plus de 8 evenements simultanement, les couleurs se repetent.
  - Charge TOUTES les participations de la base en memoire (`CGenUtil.rechercher(..., "")`) pour calculer `nbParticipants`. A surveiller si la table grossit.

- `insererEvenement(...)`
  - Cree l'evenement.
  - Notifie TOUS les autres profils du systeme (une notification par profil, hors createur). Peut generer beaucoup de notifications si la base est large.
  - `datefin` est optionnel (peut etre `null`).

- `updateEvenement(...)`
  - Met a jour description/date debut/date fin.
  - Si `datefin` est vide, il est remis a `null` (suppression de la date de fin).
  - **Aucun controle de propriete** : n'importe quel utilisateur authentifie peut modifier n'importe quel evenement. Le controle doit etre fait dans le JSP appelant.
  - **Ne met pas a jour la publication associee** : si un evenement a deja ete publie via `publierEvenement`, modifier l'evenement ne met pas a jour le texte de la publication sur le feed. Les deux divergent silencieusement.

- `participer(...)`
  - **Aucun check de doublon avant insert** : si la participation existe deja, une exception DB est levee (erreur non geree proprement). Toujours appeler `checkParticipation` avant.
  - **Aucun check que l'evenement existe** : un `idevenement` fantaisiste insere une participation orpheline jusqu'a echec FK.

- `participer(...)`
  - Insere participation dans `participation_evenement` via `insertToTableWithHisto` (historisee).

- `annulerParticipation(...)`
  - Supprime via `deleteToTable` (PAS `deleteToTableWithHisto`) — annulation NON historisee, asymetrique avec `participer`.

- `publierEvenement(...)`
  - Verifie existence evenement.
  - Verifie qu'aucune publication n'existe deja (`idorigine=idevenement`).
  - Cree une publication `TPB000003` avec texte formate de l'evenement.

## Entites/tables frequentes

- `Evenement` -> `evenement`
- `ParticipationEvenement` -> `participation_evenement`
- `Notification` -> `notification` (selon regles de publication/participation)

## Cas typiques de modification

- Ajouter un nouvel etat d'evenement:
  - adapter validation dans `EvenementService`
  - controler affichage dans calendrier/liste
  - migration SQL si nouveau champ/enum

- Changer regles de participation:
  - `traitement-participer.jsp` et `traitement-annuler.jsp`
  - `EvenementService.participer/annulerParticipation`

## Tables les plus impactees

- `evenement`
- `participation_evenement`
- `publication` (quand publication d'evenement)
- `notification` (a l'insertion d'evenement)

## Points de vigilance relais

- `publierEvenement` depend d'un id type publication hardcode (`TPB000003`), verifier la reference en base.
- Une republication du meme evenement est bloquee par check sur `publication.idorigine`.
- Si calendrier vide, verifier filtres `pStart/pEnd` et format date attendu.
