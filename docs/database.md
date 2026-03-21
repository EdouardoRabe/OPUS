# Documentation Base de Donnees

## Source officielle

La base de donnee officielle pour reprise complete est:

- `BDD/complet/2026-02-25-OPUS-COMPLETE.sql`

Donnees de complement:

- `BDD/complet/2026-02-25-OPUS-data.sql`
- `BDD/complet/2026-02-25-OPUS-data-publications-feed.sql`

## Strategie de scripts

- `BDD/` contient l'historique des scripts incrementaux.
- `BDD/complet/` contient les scripts de reconstruction complete.
- Toute evolution doit etre ajoutee par un nouveau script date.

## Mapping technique (ou chercher)

- Les classes `alumni.*` declarent les tables via `setNomTable(...)`.
- Les operations metier sont orchestrees dans `alumni.*Service`.
- Les endpoints AJAX JSP appellent directement ces services.

## Conseils de migration

1. Creer script date dans `BDD/`.
2. Ajouter/adapter classe metier `alumni.*` si besoin.
3. Ajuster service metier.
4. Adapter endpoint JSP AJAX et UI.
5. Documenter dans le fichier module correspondant sous `docs/modules/`.
