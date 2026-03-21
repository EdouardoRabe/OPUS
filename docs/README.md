# Documentation de Relais - OPUS

Objectif: permettre a une nouvelle equipe de reprendre rapidement le projet sans devoir reverse-engineerer tout le code.

## Point d'entree de la documentation

1. Lire `02-relai-rapide.md` pour la prise en main immediate.
2. Lire `01-architecture.md` pour la carte technique globale.
3. Lire `03-cartographie-fonctions.md` pour retrouver rapidement la bonne methode Java.
4. Aller dans `modules/` selon la fonctionnalite a modifier.
5. Verifier `database.md` avant toute modif de schema ou de data.

## Arborescence docs

- `01-architecture.md`: architecture applicative et conventions de navigation.
- `02-relai-rapide.md`: checklist de reprise (jour 1).
- `03-cartographie-fonctions.md`: index rapide fonction -> classe.
- `database.md`: scripts SQL de reference et strategie DB.
- `modules/publication.md`: feed, reactions, commentaires, partages, signalements.
- `modules/profil.md`: profil utilisateur, experiences, cv, social, confidentialite.
- `modules/evenement.md`: calendrier, publication evenement, participation.
- `modules/annuaire-notification-reseau.md`: annuaire, notifications, reseau, carte.
- `modules/admin-reference.md`: administration publication/specialite/roles/menu.

## Convention de recherche rapide

Pour localiser un point de code, utiliser `rg`:

```bash
rg "nomMethodeService" opus-war/web/pages opus-ejb/src/java
rg "module.jsp?but=" opus-war/web/pages
rg "setNomTable\(" opus-ejb/src/java/alumni
```

## Definition de done (pour transfert)

- Chaque ticket de correction mentionne: page JSP impactee + endpoint AJAX + service Java + table SQL.
- Les scripts SQL sont versionnes dans `BDD/` (pas de modif manuelle silencieuse en base).
- Toute nouvelle fonctionnalite ajoute sa fiche dans `docs/modules/`.
