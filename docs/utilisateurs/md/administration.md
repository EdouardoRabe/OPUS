# Administration (Moderateur)

## Acces

Toutes les fonctionnalites de cette page sont reservees au role `md`. Le compte par defaut est `ETU000001` (mot de passe : `test`).

---

## Dashboard

Accessible via le menu Dashboard. Affiche une vue synthetique de l'activite du reseau :

- Nombre total d'alumni actifs
- Nombre total de publications
- Graphique des connexions sur les 7 derniers jours
- Top 5 des specialites les plus representees dans les profils
- Specialites les plus mentionnees dans les publications (hashtags)

## Historique des actions

Accessible via Dashboard > Historique. Liste toutes les actions de tous les utilisateurs (connexions, etc.) avec date, heure et objet. Recherche et pagination disponibles.

---

## Gestion des utilisateurs

Accessible via Moderation > Utilisateurs.

- **Liste** : tous les membres avec role, statut, promotion, parcours. Stats en en-tete (actifs, en attente, bannis, total).
- **Valider** : passe un compte "En attente" (nouvel inscrit) a "Actif". Disponible via le menu trois points.
- **Bannir** : desactive un compte avec une raison optionnelle. L'utilisateur ne peut plus se connecter.
- **Reactiver** : remet un compte banni en etat actif.
- **Voir le profil** : lien vers la fiche annuaire du membre.

Flux d'inscription : un nouvel utilisateur s'inscrit → son compte reste en attente → le moderateur le valide ici.

---

## Gestion des signalements

Accessible via Moderation > Signalements.

- **Liste** : tous les signalements avec signalant, signale, motif et date. Pagination 12 par page.
- **Detail** : cliquer sur "Voir le detail" pour afficher la fiche du signalement avec la publication concernee.
- **Supprimer la publication signalée** : depuis le detail, le moderateur peut supprimer n'importe quelle publication (meme celle d'un autre utilisateur). Cette action est irreversible cote interface (soft delete en base).

---

## Gestion des evenements

Le moderateur est le seul a pouvoir creer et gerer les evenements.

- **Creer un evenement** : renseigner titre, description, date de debut et de fin. Tous les membres recoivent une notification a la creation.
- **Modifier un evenement** : mettre a jour description ou dates.
- **Publier un evenement dans le feed** : cree automatiquement une publication dans le fil d'actualite avec les details de l'evenement. Ne peut etre fait qu'une seule fois par evenement.
- **Liste de gestion** : vue tableau de tous les evenements avec recherche.

Tous les utilisateurs peuvent voir le calendrier et participer aux evenements. Seul le moderateur peut en creer et modifier.

---

## Gestion des specialites

Accessible via Administration > Specialites.

- **Ajouter** : renseigner libelle, description et optionnellement une image.
- **Modifier** : mettre a jour libelle, description ou photo.

Les specialites sont utilisees dans les profils et dans les filtres de l'annuaire.

---

## Limites de publication par role

Accessible via Administration > Limites de role.

| Role | Limite par defaut |
|------|------------------|
| etu (etudiant) | 10 publications/jour |
| alu (alumni) | 4 publications/jour |
| md (moderateur) | 100 publications/jour |

Modifier la valeur et valider. La valeur `-1` signifie illimite. Ces limites impactent tous les membres immediatement.
