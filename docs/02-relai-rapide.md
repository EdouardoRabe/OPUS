# Prise de Relais Rapide (Jour 1)

## Objectif

Permettre a un nouveau developpeur d'etre operationnel en moins d'une demi-journee.

## Checklist de reprise

1. Lire `docs/README.md` puis `docs/01-architecture.md`.
2. Restaurer la base officielle avec les scripts de `BDD/complet/`.
3. Verifier la config `deploy.dir` dans `build.xml` racine.
4. Lancer un build/deploiement Ant (`ant deploy`).
5. Valider les parcours critiques:
   - authentification
   - fil d'actualite
   - profil
   - annuaire
   - evenement calendrier

## Comment intervenir vite sur une fonctionnalite

1. Identifier la page UI chargee via `module.jsp?but=...`.
2. Trouver l'appel AJAX dans la page.
3. Ouvrir le JSP endpoint dans `pages/.../ajax`.
4. Identifier la methode service appelee (`alumni.*Service`).
5. Remonter vers les entites/tables impactees.
6. Ecrire le script SQL de migration si schema/data change.

## Regles de transfert

- Toujours documenter le chainage complet: UI -> AJAX JSP -> Service -> Table.
- Ne jamais modifier le schema sans script dans `BDD/`.
- Conserver les noms de fichiers et conventions existantes pour rester compatible avec les ecrans actuels.

## Points d'attention

- Beaucoup de logique est dans les JSP AJAX: verifier les validations serveur dans ces fichiers.
- Les services `alumni.*Service` centralisent les regles metier, ne pas dupliquer cette logique dans le front.
- Les fichiers `build-file/lib` sont des dependances compilees, eviter les changements non maitrises.
