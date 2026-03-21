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
    - `color` genere

- `insererEvenement(...)`
  - Cree l'evenement.
  - Notifie tous les autres profils du systeme.

- `updateEvenement(...)`
  - Met a jour description/date debut/date fin.

- `participer(...)`
  - Insere participation dans `participation_evenement`.

- `annulerParticipation(...)`
  - Supprime la participation existante.

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
