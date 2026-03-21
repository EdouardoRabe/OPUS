# Cartographie Rapide des Fonctions (Relais)

But: permettre a un dev entrant de passer d'un bug/feature a la bonne methode en moins de 5 minutes.

## Publication / Feed

- Creer publication: `alumni.CreerPublicationService.creerPublication`
- Verifier quota publication: `alumni.CreerPublicationService.verifierDroitPublication`
- Charger feed: `alumni.FeedHtmlService.chargerFeed`
- Voir une publication: `alumni.FeedHtmlService.voirPublication`
- Publications d'un profil: `alumni.FeedHtmlService.publicationsProfil`
- Commenter publication: `alumni.CommentaireService.commenter`
- Charger commentaires: `alumni.CommentaireService.chargerCommentaires`
- Reagir publication: `alumni.ReactionService.reagirPublication`
- Reagir commentaire: `alumni.ReactionService.reagirCommentaire`
- Detail reactions: `alumni.ReactionService.detailReactions`
- Marquer vue: `alumni.PublicationActionService.marquerVue`
- Sauvegarder/desauvegarder publication: `alumni.PublicationActionService.toggleSave`
- Signaler publication: `alumni.PublicationActionService.reportPublication`
- Partager publication: `alumni.PublicationActionService.partagerPublication`
- Modifier publication (admin): `alumni.PublicationAdminService.modifier`
- Supprimer publication (admin, soft): `alumni.PublicationAdminService.supprimer`

## Profil

- Infos profil (nom, prenom, tel): `alumni.ProfilService.updateProfilInfo`
- Changer mot de passe: `alumni.ProfilService.changePassword`
- Upload photo: `alumni.ProfilService.uploadPhoto`
- Upload CV: `alumni.ProfilService.uploadCv`
- Delete CV: `alumni.ProfilService.deleteCv`
- CRUD experience: `alumni.ProfilService.crudExperience`
- CRUD localisation: `alumni.ProfilService.crudLocalisation`
- Update statut: `alumni.ProfilService.updateStatut`
- CRUD social media: `alumni.ProfilService.crudSocialMedia`
- CRUD specialite profil: `alumni.ProfilService.crudSpecialite`
- Confidentialite: `alumni.ProfilService.updateConfidentialite`

## Evenement

- Liste calendrier JSON: `alumni.EvenementService.listeJson`
- Inserer evenement: `alumni.EvenementService.insererEvenement`
- Update evenement: `alumni.EvenementService.updateEvenement`
- Publier evenement en publication: `alumni.EvenementService.publierEvenement`
- Participer: `alumni.EvenementService.participer`
- Annuler participation: `alumni.EvenementService.annulerParticipation`
- Check participation: `alumni.EvenementService.checkParticipation`

## Annuaire / Notifications / Reseau / Carte

- Recherche annuaire: `alumni.AnnuaireService.rechercher`
- Charger notifications: `alumni.NotificationAlumniService.chargerNotifications`
- Marquer notification lue: `alumni.NotificationAlumniService.marquerLu`
- Calcul reseau professionnel: `alumni.ReseauService.calculerReseau`
- Charger alumni map: `alumni.MapService.getAlumni`

## Admin Referentiel

- Inserer specialite: `alumni.SpecialiteAdminService.inserer`
- Modifier specialite: `alumni.SpecialiteAdminService.modifier`
- Modifier limite role: `alumni.LimiteroleService.modifier`

## Regle de triage bug (obligatoire en relais)

1. Identifier endpoint JSP appele depuis la page.
2. Identifier la methode service invoquee.
3. Verifier les tables touchees par cette methode.
4. Reproduire avec payload minimal.
5. Corriger au niveau service (pas uniquement UI), puis valider flux complet.
