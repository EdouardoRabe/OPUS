-- Donnees de test Alumni
-- Le flow : ETU (colonne id) → resolution loginuser → testeValide(loginuser, pass) avec cryptage du framework
--
-- Cryptage : meme algo que UtilitaireAcade.cryptWord()
--   - Decalage de caractere (Caesar cipher sur Character.getNumericValue)
--   - Parametres dans la table paramcrypt (niveau, croissante) par utilisateur
--   - Ici : niveau=4, croissante=1 (sens descendant)
--   - Mot de passe en clair "test" → crypte en "paop"
--     t(29)-4=25→p, e(14)-4=10→a, s(28)-4=24→o, t(29)-4=25→p
--
-- Pour se connecter : ETU000001 / test  ou  ETU000002 / test

-- Utilisateurs
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, idrole, id, estactif)
VALUES (100, 'ETU000001', 'paop', 'Rakoto Jean', 'etu', 'ETU000001', 1);

INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, idrole, id, estactif)
VALUES (101, 'ETU000002', 'paop', 'Rasoa Marie', 'etu', 'ETU000002', 1);

-- Parametres de cryptage (obligatoire pour que testeValide fonctionne)
-- Meme format que l'admin existant : CRY000088 / niveau=4 / croissante=1 / idutilisateur=1
INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY000100', 4, 1, '100');

INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY000101', 4, 1, '101');
