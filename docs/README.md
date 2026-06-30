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

| Dossier | Public cible |
|---------|-------------|
| `utilisateurs/communs/` | Fonctionnalites accessibles a tous (md, alu, etu) |
| `utilisateurs/md/` | Fonctionnalites specifiques au moderateur |
| `utilisateurs/alu/` | Fonctionnalites specifiques aux alumni |
| `utilisateurs/etu/` | Fonctionnalites specifiques aux etudiants |

### Communs (md + alu + etu)

- `utilisateurs/communs/feed.md` — fil d'actualite, reactions, commentaires
- `utilisateurs/communs/profil.md` — modifier son profil, photo, CV, confidentialite
- `utilisateurs/communs/evenements.md` — calendrier, participation aux evenements
- `utilisateurs/communs/annuaire.md` — recherche d'alumni
- `utilisateurs/communs/notifications.md` — gestion des notifications

### Moderateur (md)

- `utilisateurs/md/moderation.md` — moderation des publications
- `utilisateurs/md/administration.md` — specialites, limites de role, menus, dashboard

### Alumni (alu)

- `utilisateurs/alu/publications.md` — creer une publication (limite: 4/jour)
- `utilisateurs/alu/reseau-professionnel.md` — graphe de reseau professionnel
- `utilisateurs/alu/carte.md` — carte de localisation des alumni

### Etudiants (etu)

- `utilisateurs/etu/publications.md` — creer une publication (limite: 10/jour)
