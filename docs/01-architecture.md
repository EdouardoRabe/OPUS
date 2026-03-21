# Architecture Technique OPUS

## Vue d'ensemble

Le projet est decoupe en deux modules principaux:

- `opus-war`: interface web (JSP), endpoints AJAX JSP, servlets utilitaires.
- `opus-ejb`: logique metier et acces donnees via classes metier/services.

Build/deploiement principal: `build.xml` racine (Ant) qui compile EJB puis WAR, puis copie dans WildFly.

## Flux d'execution standard

1. L'utilisateur charge une page via `module.jsp?but=...`.
2. La page front appelle un endpoint AJAX JSP dans `opus-war/web/pages/**/ajax`.
3. L'endpoint appelle une methode de service `alumni.*Service`.
4. Le service manipule les classes metier `alumni.*` mappees sur les tables SQL.
5. Le resultat est renvoye en JSON/HTML puis injecte dans l'UI.

## Emplacements importants

- UI principale: `opus-war/web/pages`
- Endpoints AJAX: `opus-war/web/pages/*/ajax`
- Servlets utilitaires: `opus-war/src/java/servlet`, `opus-war/src/java/web`
- Services metier: `opus-ejb/src/java/alumni/*Service.java`
- Entites metier (mapping table): `opus-ejb/src/java/alumni/*.java`
- Scripts SQL: `BDD/`
- Base de reference complete: `BDD/complet/2026-02-25-OPUS-COMPLETE.sql`

## Raccourcis de comprehension

- Si vous devez modifier un comportement metier: commencer par le service `alumni.*Service`.
- Si vous devez modifier l'affichage: commencer par JSP dans `opus-war/web/pages`.
- Si vous devez modifier les donnees persistees: verifier classe `alumni.*` + script SQL associe dans `BDD/`.

## Build et deploiement

Le build principal est orchestre par `build.xml` racine:

- `clean` -> nettoie artefacts
- `init` -> prepare arborescence de build
- `compile` -> compile EJB
- `buildEjbJar` -> package EJB
- `compileWar` -> compile WAR
- `deploy` -> copie dans `deploy.dir` WildFly

Penser a verifier `deploy.dir` selon l'environnement local.
