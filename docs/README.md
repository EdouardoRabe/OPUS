# Documentation OPUS

## Structure

```
docs/
  developpeurs/   — documentation technique pour les developpeurs
  utilisateurs/   — modes d'emploi fonctionnels par profil
```

## Developpeurs

| Fichier | Contenu |
|---------|---------|
| `developpeurs/demarrage.md` | Checklist de prise en main jour 1, config de base |
| `developpeurs/architecture.md` | Architecture applicative, flux d'execution, chemins importants |
| `developpeurs/cartographie.md` | Index rapide fonction -> classe Java |
| `developpeurs/base-de-donnees.md` | Scripts SQL de reference, strategie de migration |
| `developpeurs/modules/publication.md` | Feed, reactions, commentaires, partages, signalements |
| `developpeurs/modules/profil.md` | Profil utilisateur, experiences, CV, social, confidentialite |
| `developpeurs/modules/evenement.md` | Calendrier, publication evenement, participation |
| `developpeurs/modules/annuaire-notification-reseau.md` | Annuaire, notifications, reseau, carte |
| `developpeurs/modules/admin-reference.md` | Administration publication, specialite, roles, menus |

## Utilisateurs

Seul le moderateur (`md`) a des fonctionnalites differentes des autres roles. Tous les autres membres (alu, etu) ont acces aux memes pages — la seule difference est le quota de publications par jour (alu : 4, etu : 10).

### Communs (md + alu + etu)

| Fichier | Contenu |
|---------|---------|
| `utilisateurs/communs/feed.md` | Fil d'actualite, reactions, commentaires, partage, signalement |
| `utilisateurs/communs/publications.md` | Creer une publication, limites par role |
| `utilisateurs/communs/publications-enregistrees.md` | Sauvegarder et retrouver des publications |
| `utilisateurs/communs/profil.md` | Modifier son profil, photo, CV, experiences, confidentialite |
| `utilisateurs/communs/evenements.md` | Calendrier, participation aux evenements |
| `utilisateurs/communs/annuaire.md` | Recherche de membres |
| `utilisateurs/communs/notifications.md` | Gestion des notifications |
| `utilisateurs/communs/reseau-professionnel.md` | Graphe de reseau professionnel |
| `utilisateurs/communs/carte.md` | Carte de localisation des membres |

### Moderateur (md)

| Fichier | Contenu |
|---------|---------|
| `utilisateurs/md/moderation.md` | Moderation des publications (soft delete, modification) |
| `utilisateurs/md/administration.md` | Gestion utilisateurs, signalements, evenements, specialites, limites, menus |
