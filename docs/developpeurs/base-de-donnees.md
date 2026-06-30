# Base de Donnees

## Scripts de reference

### Deploiement production

Utiliser `BDD/Import/opus-clean.sql` : dump propre sans donnees de test, pret pour la mise en production.

- Seul utilisateur present : `ETU000001` (role `md`, mot de passe `test`)
- Toutes les sequences reinitialises a 1
- Donnees de configuration uniquement (limiterole, usermenu, poste, typepublication, etc.)

### Developpement / reprise complete

Appliquer les scripts dans cet ordre :

1. `BDD/complet/2026-02-22-db-clean.sql` — supprime et recree le schema
2. `BDD/complet/2026-02-25-OPUS-COMPLETE.sql` — DDL complet
3. `BDD/complet/2026-02-25-OPUS-data.sql` — donnees de reference
4. `BDD/complet/2026-02-25-OPUS-data-publications-feed.sql` — donnees de feed exemple

### Dump de developpement complet

`BDD/Import/opus.sql` — dump complet incluant les donnees de test (ne pas utiliser en production).

## Strategie de scripts incrementaux

- `BDD/` contient l'historique des scripts incrementaux nommes par date.
- `BDD/complet/` contient les scripts de reconstruction complete.
- Toute evolution de schema ou de donnees de reference doit etre ajoutee par un nouveau script date dans `BDD/`.

## Procedure de migration

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
