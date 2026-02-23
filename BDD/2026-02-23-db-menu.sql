-- ═══════════════════════════════════════════════════════════════
-- Script complet: Menus ITU Alumni (Côté Étudiant)
-- ═══════════════════════════════════════════════════════════════
-- Date: 2026-02-23
-- Structure:
--   Niveau 0: Accueil, Réseau, Carrière, Mon Profil
--   Niveau 1: Sous-menus (Annuaire, Spécialités, Offres, Publier, etc.)
-- Icônes: Bootstrap Icons (bi-*)
-- ═══════════════════════════════════════════════════════════════

-- ═══ ÉTAPE 1: SUPPRIMER LES ANCIENS MENUS DE TEST (si existent) ═══
DELETE FROM USERMENU WHERE idmenu LIKE 'MENDYN%' OR idmenu LIKE 'MENU_TEST%';
DELETE FROM MENUDYNAMIQUE WHERE id LIKE 'MENDYN%' OR id LIKE 'MENU_TEST%';

-- ═══ ÉTAPE 2: INSÉRER LES MENUS PRINCIPAUX (NIVEAU 0) ═══

INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
-- 1. Accueil (Racine - Niveau 0)
('MENDYN000001', 'Accueil', 'bi-house-door-fill', 'module.jsp?but=accueil.jsp', 1, 0, NULL),

-- 2. Réseau (Dropdown - Niveau 0)
('MENDYN000002', 'Réseau', 'bi-people-fill', '#', 2, 0, NULL),

-- 3. Carrière (Dropdown - Niveau 0)
('MENDYN000003', 'Carrière', 'bi-briefcase-fill', '#', 3, 0, NULL),

-- 4. Mon Profil (Dropdown User à droite - Niveau 0)
('MENDYN000004', 'Mon Profil', 'bi-person-circle', '#', 4, 0, NULL),

-- 5. Administration (pour modérateurs)
('MENDYN000999', 'Administration', 'bi-gear-fill', '#', 99, 0, NULL);

-- ═══ ÉTAPE 3: INSÉRER LES SOUS-MENUS (NIVEAU 1) ═══

-- Sous-menus de RÉSEAU
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000005', 'Annuaire', 'bi-book-fill', 'module.jsp?but=annuaire/annuaire.jsp', 1, 1, 'MENDYN000002'),
('MENDYN000006', 'Spécialités', 'bi-tags-fill', 'module.jsp?but=specialites/specialites.jsp', 2, 1, 'MENDYN000002');

-- Sous-menus de CARRIÈRE
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000007', 'Offres d''emploi', 'bi-list-ul', 'module.jsp?but=carriere/offres.jsp', 1, 1, 'MENDYN000003'),
('MENDYN000008', 'Publier une offre', 'bi-plus-circle-fill', 'module.jsp?but=carriere/publier-offre.jsp', 2, 1, 'MENDYN000003');

-- Sous-menus de MON PROFIL
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000009', 'Voir ma fiche', 'bi-person-badge-fill', 'module.jsp?but=profil/voir.jsp', 1, 1, 'MENDYN000004'),
('MENDYN000010', 'Modifier le profil', 'bi-pencil-square', 'module.jsp?but=profil/modifier.jsp', 2, 1, 'MENDYN000004'),
('MENDYN000011', 'Déconnexion', 'bi-box-arrow-right', 'deconnexion.jsp', 3, 1, 'MENDYN000004');

-- Sous-menus de ADMINISTRATION (pour le rôle 'md')
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000023', 'Gestion des utilisateurs', 'bi-people', 'module.jsp?but=mod/gestion-utilisateurs.jsp', 1, 1, 'MENDYN000999'),
('MENDYN000024', 'Gestion des signalements', 'bi-shield-exclamation', 'module.jsp?but=mod/gestion-signalements.jsp', 2, 1, 'MENDYN000999');


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
('USRM000010', 'MENDYN000010', '*', 0, 'etu'),  -- mdifier le profil
('USRM000011', 'MENDYN000011', '*', 0, 'etu'),
('USRM000025', 'MENDYN000024', '*', 1, 'etu');  -- Déconnexion

-- Menus pour le rôle 'md' (Direction Générale)
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000012', 'MENDYN000001', '*', 0, 'md'),
       ('USRM000013', 'MENDYN000002', '*', 0, 'md'),
       ('USRM000014', 'MENDYN000003', '*', 0, 'md'),
       ('USRM000015', 'MENDYN000004', '*', 0, 'md'),
       ('USRM000016', 'MENDYN000005', '*', 0, 'md'),
       ('USRM000017', 'MENDYN000006', '*', 0, 'md'),
       ('USRM000018', 'MENDYN000007', '*', 0, 'md'),
       ('USRM000019', 'MENDYN000008', '*', 0, 'md'),
       ('USRM000020', 'MENDYN000009', '*', 0, 'md'),
       ('USRM000021', 'MENDYN000010', '*', 0, 'md'),
       ('USRM000022', 'MENDYN000011', '*', 0, 'md'),
       ('USRM000099', 'MENDYN000999', '*', 0, 'md'),
       ('USRM000023', 'MENDYN000023', '*', 0, 'md'),
       ('USRM000024', 'MENDYN000024', '*', 0, 'md');

-- ═══ ÉTAPE 5: MENU PUBLICATIONS ═══

-- Menu principal Publications (Niveau 0)
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000012', 'Publications', 'fa-newspaper-o', '#', 2, 0, NULL);

-- Sous-menu Fil d'actualité (Niveau 1)
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000013', 'Fil d''actualite', 'fa-list', 'module.jsp?but=alumni/fil-actualite.jsp', 1, 1, 'MENDYN000012');

-- Droits: role etu
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000023', 'MENDYN000012', '*', 0, 'etu'),
('USRM000024', 'MENDYN000013', '*', 0, 'etu');

-- Droits: role md
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000025', 'MENDYN000012', '*', 0, 'md'),
('USRM000026', 'MENDYN000013', '*', 0, 'md');

-- ═══ ÉTAPE 6: MENU NOTIFICATIONS ═══

-- Sous-menu Notifications sous Publications (Niveau 1)
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000014', 'Notifications', 'bi-bell-fill', 'module.jsp?but=alumni/notifications.jsp', 2, 1, 'MENDYN000012');

-- Droits: role etu
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000027', 'MENDYN000014', '*', 0, 'etu');

-- Droits: role md
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000028', 'MENDYN000014', '*', 0, 'md');

