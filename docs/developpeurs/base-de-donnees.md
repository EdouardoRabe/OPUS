# Base de Donnees

## Script de reference unique

Le seul script a utiliser pour initialiser la base est :

```
BDD/Import/opus-clean.sql
```

Ce fichier contient le schema complet (DDL), les donnees de configuration, et un seul compte utilisateur par defaut :

| Champ | Valeur |
|-------|--------|
| Login | `ETU000001` |
| Mot de passe | `test` |
| Role | `md` (moderateur) |

Toutes les sequences sont initialisees a 1. Aucune donnee de test n'est incluse.

## Importer la base

```bash
psql -U <utilisateur> -d opus -f BDD/Import/opus-clean.sql
```

Ou depuis psql :

```sql
\i BDD/Import/opus-clean.sql
```

## Strategie de scripts incrementaux

Pour toute evolution de schema ou de donnees de reference apres le deploiement initial :

1. Creer un script date dans `BDD/` (ex: `2026-07-01-ajout-colonne-xxx.sql`).
2. Ajouter ou adapter la classe metier `alumni.*` si le schema change.
3. Ajuster le service metier correspondant.
4. Adapter l'endpoint JSP AJAX et l'UI.
5. Documenter dans la fiche module correspondante sous `docs/developpeurs/modules/`.

## Connexion

Configuration dans `opus-ejb/src/java/apj.properties` :

```properties
# URL de connexion PostgreSQL
# Utilisateur et mot de passe de la base
```

Les services accedent a la base via `new UtilDB().GetConn()`. Les connexions sont gerees manuellement dans chaque service (ouverture + fermeture dans un bloc try/finally).

## Mapping technique

- Les classes `alumni.*` declarent leur table via `setNomTable(...)`.
- Les operations metier sont orchestrees dans `alumni.*Service`.
- Les endpoints AJAX JSP appellent directement ces services.
- Les sequences PostgreSQL sont nommees `get_seq_*` pour les IDs prefixes (ex: `get_seq_profil` → `PRF000001`).
