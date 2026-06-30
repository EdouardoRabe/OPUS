# Administration

## Acces

Le panneau d'administration est accessible uniquement avec le role moderateur (`md`). Le compte par defaut est `ETU000001` (mot de passe : `test`).

## Gestion des utilisateurs

Depuis le menu Moderation > Utilisateurs :

- **Lister** : tous les membres avec leur role, statut, promotion et parcours. Stats en en-tete (actifs, en attente, bannis).
- **Valider** : un compte nouvellement inscrit passe de l'etat "En attente" a "Actif". Disponible via le menu trois points sur la fiche.
- **Bannir** : desactiver un compte avec une raison optionnelle. L'utilisateur ne peut plus se connecter.
- **Reactiver** : remettre un compte banni en etat actif.
- **Voir le profil** : lien vers la fiche annuaire du membre.

## Gestion des signalements

Depuis le menu Moderation > Signalements :

- Liste paginee de tous les signalements avec signalant, signale, motif et date.
- Cliquer sur "Voir le detail" pour ouvrir la fiche complete du signalement avec lien vers la publication concernee.

## Gestion des evenements

Fonctionnalites reservees au moderateur :

- **Creer un evenement** : renseigner titre, description, date de debut et de fin. Tous les membres recoivent une notification a la creation.
- **Modifier un evenement** : mettre a jour description ou dates.
- **Publier un evenement sur le feed** : cree une publication dans le fil d'actualite avec les details. Ne peut etre fait qu'une seule fois par evenement.
- **Voir la liste des evenements** : vue tableau avec recherche.

## Gestion des specialites

Depuis le menu Administration > Specialites :

- **Ajouter une specialite** : renseigner le libelle, la description et optionnellement une image.
- **Modifier une specialite** : modifier libelle, description ou photo.

Les specialites sont disponibles pour tous les membres dans leur profil et dans les filtres de l'annuaire.

## Limites de publication par role

Depuis le menu Administration > Limites de role :

| Role | Limite par defaut |
|------|------------------|
| etu (etudiant) | 10 |
| alu (alumni) | 4 |
| md (moderateur) | 100 |

Modifier la valeur et valider. La valeur `-1` signifie illimite.

## Gestion des menus

Depuis le menu Administration > Menus, ajouter, modifier ou reordonner les entrees du menu de navigation.

## Tableau de bord

Le dashboard affiche une vue synthetique de l'activite du reseau.
