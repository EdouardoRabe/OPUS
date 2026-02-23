
-- ═══ ÉTAPE 1: SUPPRIMER LES ANCIENS MENUS DE TEST (si existent) ═══
DELETE FROM USERMENU WHERE idmenu LIKE 'MENDYN%' OR idmenu LIKE 'MENU_TEST%';
DELETE FROM MENUDYNAMIQUE WHERE id LIKE 'MENDYN%' OR id LIKE 'MENU_TEST%';

-- ═══ ÉTAPE 2: INSÉRER LES MENUS PRINCIPAUX (NIVEAU 0) ═══

INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000001', 'Accueil', 'fa-home', 'module.jsp?but=accueil.jsp', 1, 0, NULL),
('MENDYN000002', 'Réseau', 'fa-users', '#', 2, 0, NULL),
('MENDYN000003', 'Carrière', 'fa-briefcase', '#', 3, 0, NULL),
('MENDYN000004', 'Mon Profil', 'fa-user-circle', '#', 4, 0, NULL),
('MENDYN000012', 'Administration', 'fa-cogs', '#', 5, 0, NULL);

INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000005', 'Annuaire', 'fa-address-book', 'module.jsp?but=annuaire/annuaire.jsp', 1, 1, 'MENDYN000002'),
('MENDYN000006', 'Spécialités', 'fa-tags', 'module.jsp?but=specialites/specialites.jsp', 2, 1, 'MENDYN000002');
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000007', 'Offres d''emploi', 'fa-list-alt', 'module.jsp?but=carriere/offres.jsp', 1, 1, 'MENDYN000003'),
('MENDYN000008', 'Publier une offre', 'fa-plus-circle', 'module.jsp?but=carriere/publier-offre.jsp', 2, 1, 'MENDYN000003');
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000009', 'Voir ma fiche', 'fa-id-card', 'module.jsp?but=profil/voir.jsp', 1, 1, 'MENDYN000004'),
('MENDYN000010', 'Modifier le profil', 'fa-edit', 'module.jsp?but=profil/modifier.jsp', 2, 1, 'MENDYN000004'),
('MENDYN000011', 'Déconnexion', 'fa-sign-out', 'deconnexion.jsp', 3, 1, 'MENDYN000004');
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000013', 'Gestion Utilisateurs', 'fa-users-cog', 'module.jsp?but=admin/gerer-utilisateurs.jsp', 1, 1, 'MENDYN000012'),
('MENDYN000014', 'Contenus signalés', 'fa-user-shield', 'module.jsp?but=admin/gerer-roles.jsp', 2, 1, 'MENDYN000012'),
('MENDYN000015', 'Configuration Référentiels', 'fa-th-list', 'module.jsp?but=admin/gerer-menus.jsp', 3, 1, 'MENDYN000012');

-- ═══ ÉTAPE 4: INSÉRER LES DROITS D'ACCÈS (USERMENU) ═══

-- Tous les menus accessibles à tous les rôles (*) par défaut
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
-- Menus niveau 0 pour étudiants
('USRM000001', 'MENDYN000001', '*', 0, 'etu'),  -- Accueil
('USRM000002', 'MENDYN000002', '*', 0, 'etu'),  -- Réseau
('USRM000003', 'MENDYN000003', '*', 0, 'etu'),  -- Carrière
('USRM000004', 'MENDYN000004', '*', 0, 'etu'),  -- Mon Profil

-- Sous-menus Réseau
('USRM000005', 'MENDYN000005', '*', 0, 'etu'),  -- Annuaire
('USRM000006', 'MENDYN000006', '*', 0, 'etu'),  -- Spécialités

-- Sous-menus Carrière
('USRM000007', 'MENDYN000007', '*', 0, 'etu'),  -- Offres d'emploi
('USRM000008', 'MENDYN000008', '*', 0, 'etu'),  -- Publier une offre

-- Sous-menus Mon Profil
('USRM000009', 'MENDYN000009', '*', 0, 'etu'),  -- Voir ma fiche
('USRM000010', 'MENDYN000010', '*', 0, 'etu'),  -- Modifier le profil
('USRM000011', 'MENDYN000011', '*', 0, 'etu');  -- Déconnexion

-- Si vous avez d'autres rôles (admin, dg, etc.), ajouter aussi:
-- Menus pour le rôle 'dg' (Direction Générale)
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000012', 'MENDYN000001', '*', 0, 'dg'),
       ('USRM000013', 'MENDYN000002', '*', 0, 'dg'),
       ('USRM000014', 'MENDYN000003', '*', 0, 'dg'),
       ('USRM000015', 'MENDYN000004', '*', 0, 'dg'),
       ('USRM000016', 'MENDYN000005', '*', 0, 'dg'),
       ('USRM000017', 'MENDYN000006', '*', 0, 'dg'),
       ('USRM000018', 'MENDYN000007', '*', 0, 'dg'),
       ('USRM000019', 'MENDYN000008', '*', 0, 'dg'),
       ('USRM000020', 'MENDYN000009', '*', 0, 'dg'),
       ('USRM000021', 'MENDYN000010', '*', 0, 'dg'),
       ('USRM000022', 'MENDYN000011', '*', 0, 'dg'),
       ('USRM000040', 'MENDYN000012', '*', 0, 'dg'),
       ('USRM000041', 'MENDYN000013', '*', 0, 'dg'),
       ('USRM000042', 'MENDYN000014', '*', 0, 'dg'),
       ('USRM000043', 'MENDYN000015', '*', 0, 'dg');;

-- Menus pour le rôle 'admin' (Administrateur)
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000023', 'MENDYN000001', '*', 0, 'mod'),
('USRM000024', 'MENDYN000002', '*', 0, 'mod'),
('USRM000025', 'MENDYN000003', '*', 0, 'mod'),
('USRM000026', 'MENDYN000004', '*', 0, 'mod'),
('USRM000027', 'MENDYN000005', '*', 0, 'mod'),
('USRM000028', 'MENDYN000006', '*', 0, 'mod'),
('USRM000029', 'MENDYN000007', '*', 0, 'mod'),
('USRM000030', 'MENDYN000008', '*', 0, 'mod'),
('USRM000031', 'MENDYN000009', '*', 0, 'mod'),
('USRM000032', 'MENDYN000010', '*', 0, 'mod'),
('USRM000033', 'MENDYN000011', '*', 0, 'mod'),
('USRM000034', 'MENDYN000012', '*', 0, 'mod'),
('USRM000035', 'MENDYN000013', '*', 0, 'mod'),
('USRM000036', 'MENDYN000014', '*', 0, 'mod'),
('USRM000037', 'MENDYN000015', '*', 0, 'mod');;

