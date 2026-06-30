# Cartographie Rapide des Fonctions

But : passer d'un bug/feature a la bonne methode Java en moins de 5 minutes.

## Publication / Feed

| Action | Methode |
|--------|---------|
| Creer publication | `alumni.CreerPublicationService.creerPublication` |
| Verifier quota publication | `alumni.CreerPublicationService.verifierDroitPublication` |
| Charger feed | `alumni.FeedHtmlService.chargerFeed` |
| Voir une publication | `alumni.FeedHtmlService.voirPublication` |
| Publications d'un profil | `alumni.FeedHtmlService.publicationsProfil` |
| Commenter | `alumni.CommentaireService.commenter` |
| Charger commentaires | `alumni.CommentaireService.chargerCommentaires` |
| Reagir a une publication | `alumni.ReactionService.reagirPublication` |
| Reagir a un commentaire | `alumni.ReactionService.reagirCommentaire` |
| Detail des reactions | `alumni.ReactionService.detailReactions` |
| Marquer comme vu | `alumni.PublicationActionService.marquerVue` |
| Sauvegarder/desauvegarder | `alumni.PublicationActionService.toggleSave` |
| Signaler | `alumni.PublicationActionService.reportPublication` |
| Partager | `alumni.PublicationActionService.partagerPublication` |
| Modifier (admin) | `alumni.PublicationAdminService.modifier` |
| Supprimer (admin, soft) | `alumni.PublicationAdminService.supprimer` |

## Profil

| Action | Methode |
|--------|---------|
| Infos profil (nom, prenom, tel) | `alumni.ProfilService.updateProfilInfo` |
| Changer mot de passe | `alumni.ProfilService.changePassword` |
| Upload photo | `alumni.ProfilService.uploadPhoto` |
| Upload CV | `alumni.ProfilService.uploadCv` |
| Supprimer CV | `alumni.ProfilService.deleteCv` |
| CRUD experience | `alumni.ProfilService.crudExperience` |
| CRUD localisation | `alumni.ProfilService.crudLocalisation` |
| Update statut | `alumni.ProfilService.updateStatut` |
| CRUD social media | `alumni.ProfilService.crudSocialMedia` |
| CRUD specialite profil | `alumni.ProfilService.crudSpecialite` |
| Confidentialite | `alumni.ProfilService.updateConfidentialite` |

## Evenement

| Action | Methode |
|--------|---------|
| Liste calendrier JSON | `alumni.EvenementService.listeJson` |
| Inserer evenement | `alumni.EvenementService.insererEvenement` |
| Modifier evenement | `alumni.EvenementService.updateEvenement` |
| Publier evenement en publication | `alumni.EvenementService.publierEvenement` |
| Participer | `alumni.EvenementService.participer` |
| Annuler participation | `alumni.EvenementService.annulerParticipation` |
| Verifier participation | `alumni.EvenementService.checkParticipation` |

## Annuaire / Notifications / Reseau / Carte

| Action | Methode |
|--------|---------|
| Recherche annuaire | `alumni.AnnuaireService.rechercher` |
| Charger notifications | `alumni.NotificationAlumniService.chargerNotifications` |
| Marquer notification lue | `alumni.NotificationAlumniService.marquerLu` |
| Calcul reseau professionnel | `alumni.ReseauService.calculerReseau` |
| Charger alumni map | `alumni.MapService.getAlumni` |

## Admin Referentiel

| Action | Methode |
|--------|---------|
| Inserer specialite | `alumni.SpecialiteAdminService.inserer` |
| Modifier specialite | `alumni.SpecialiteAdminService.modifier` |
| Modifier limite role | `alumni.LimiteroleService.modifier` |

## Procedure de triage bug

1. Identifier l'endpoint JSP appele depuis la page.
2. Identifier la methode service invoquee.
3. Verifier les tables touchees par cette methode.
4. Reproduire avec payload minimal.
5. Corriger au niveau service (pas uniquement UI), puis valider le flux complet.
