# Demarrage Rapide (Jour 1)

## Configuration de base

| Parametre | Valeur |
|-----------|--------|
| URL locale | `http://localhost:8080/opus/` |
| Moderateur par defaut | `ETU000001` |
| Mot de passe par defaut | `test` |
| Base de donnees | PostgreSQL `opus` |
| Serveur d'application | WildFly |

> Le compte `ETU000001` est le seul compte present dans un deploiement propre (`BDD/Import/opus-clean.sql`). Il a le role `md` (moderateur) et permet d'acceder a toutes les fonctionnalites d'administration.

## Prerequis

- Java JDK installe (verifier avec `ant -version`)
- WildFly en cours d'execution
- PostgreSQL avec la base `opus` creee et les scripts appliques (voir `developpeurs/base-de-donnees.md`)
- `build.xml` configure avec le bon `deploy.dir` pointant vers `standalone/deployments/`
- `opus-ejb/src/java/apj.properties` configure avec l'URL, l'utilisateur et le mot de passe PostgreSQL

## Checklist de prise en main

1. Lire `docs/README.md` puis `docs/developpeurs/architecture.md`.
2. Appliquer les scripts de base dans l'ordre (voir `developpeurs/base-de-donnees.md`).
3. Verifier `deploy.dir` dans `build.xml` racine.
4. Lancer le build : `ant deploy`.
5. Ouvrir `http://localhost:8080/opus/` et se connecter avec `ETU000001` / `test`.
6. Valider les parcours critiques :
   - authentification
   - fil d'actualite
   - profil
   - annuaire
   - evenement calendrier

## Intervenir vite sur une fonctionnalite

1. Identifier la page UI chargee via `module.jsp?but=...`.
2. Trouver l'appel AJAX dans la page.
3. Ouvrir le JSP endpoint dans `pages/.../ajax/`.
4. Identifier la methode service appelee (`alumni.*Service`).
5. Remonter vers les entites/tables impactees.
6. Ecrire le script SQL de migration si le schema ou les donnees changent.

## Regles de transfert

- Toujours documenter le chainage complet : UI -> AJAX JSP -> Service -> Table.
- Ne jamais modifier le schema sans script versionne dans `BDD/`.
- Conserver les noms de fichiers et conventions existantes pour rester compatible avec les ecrans actuels.

## Flux d'inscription d'un nouvel utilisateur

1. L'utilisateur remplit le formulaire sur `inscription.jsp` (login ETU/nom, email, telephone, role, promotion, parcours).
2. Son compte est cree avec l'etat "En attente" (`attenteValidation.jsp` lui est affiche).
3. Le moderateur voit le compte dans Moderation > Utilisateurs et clique "Valider".
4. L'utilisateur peut alors se connecter.

Pages impliquees : `inscription.jsp` → `detailsInscription.jsp` → `attenteValidation.jsp` → `mod/gestion-utilisateurs.jsp` (validation md).
Methode EJB : `UserEJBBean.createUtilisateurs()` pour la creation, `UserEJBBean.activeUtilisateur()` pour la validation.

## Points d'attention

- Beaucoup de logique de validation est dans les JSP AJAX : verifier ces fichiers en priorite.
- Les services `alumni.*Service` centralisent les regles metier, ne pas dupliquer cette logique dans le front.
- Les fichiers `build-file/lib/` sont des dependances compilees (`apj-core.jar`, `apj-core2.jar`), eviter les changements non maitrises.
- Les sources Java doivent etre enregistrees en `iso-8859-1` (encoding configure dans `build.xml`).
