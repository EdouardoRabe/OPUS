-- ═══════════════════════════════════════════════════════════════
-- Script complet: Menus ITU Alumni (Côté Étudiant)
-- ═══════════════════════════════════════════════════════════════
-- Date: 2026-02-23
-- Structure:
--   Niveau 0: Accueil, Réseau, Carrière, Mon Profil
--   Niveau 1: Sous-menus (Annuaire, Spécialités, Offres, Publier, etc.)
-- ═══════════════════════════════════════════════════════════════

-- ═══ ÉTAPE 1: SUPPRIMER LES ANCIENS MENUS DE TEST (si existent) ═══
DELETE FROM USERMENU WHERE idmenu LIKE 'MENDYN%' OR idmenu LIKE 'MENU_TEST%';
DELETE FROM MENUDYNAMIQUE WHERE id LIKE 'MENDYN%' OR id LIKE 'MENU_TEST%';

-- ═══ ÉTAPE 2: INSÉRER LES MENUS PRINCIPAUX (NIVEAU 0) ═══

INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
-- 1. Accueil (Racine - Niveau 0)
('MENDYN000001', 'Accueil', 'fa-home', 'mdule.jsp?but=accueil.jsp', 1, 0, NULL),

-- 2. Réseau (Dropdown - Niveau 0)
('MENDYN000002', 'Réseau', 'fa-users', '#', 2, 0, NULL),

-- 3. Carrière (Dropdown - Niveau 0)
('MENDYN000003', 'Carrière', 'fa-briefcase', '#', 3, 0, NULL),

-- 4. Mon Profil (Dropdown User à droite - Niveau 0)
('MENDYN000004', 'Mon Profil', 'fa-user-circle', '#', 4, 0, NULL);

-- ═══ ÉTAPE 3: INSÉRER LES SOUS-MENUS (NIVEAU 1) ═══

-- Sous-menus de RÉSEAU
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000005', 'Annuaire', 'fa-address-book', 'mdule.jsp?but=annuaire/annuaire.jsp', 1, 1, 'MENDYN000002'),
('MENDYN000006', 'Spécialités', 'fa-tags', 'mdule.jsp?but=specialites/specialites.jsp', 2, 1, 'MENDYN000002');

-- Sous-menus de CARRIÈRE
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000007', 'Offres d''emploi', 'fa-list-alt', 'mdule.jsp?but=carriere/offres.jsp', 1, 1, 'MENDYN000003'),
('MENDYN000008', 'Publier une offre', 'fa-plus-circle', 'mdule.jsp?but=carriere/publier-offre.jsp', 2, 1, 'MENDYN000003');

-- Sous-menus de MON PROFIL
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000009', 'Voir ma fiche', 'fa-id-card', 'mdule.jsp?but=profil/voir.jsp', 1, 1, 'MENDYN000004'),
('MENDYN000010', 'mdifier le profil', 'fa-edit', 'mdule.jsp?but=profil/mdifier.jsp', 2, 1, 'MENDYN000004'),
('MENDYN000011', 'Déconnexion', 'fa-sign-out', 'deconnexion.jsp', 3, 1, 'MENDYN000004');

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
('USRM000011', 'MENDYN000011', '*', 0, 'etu');  -- Déconnexion

-- Si vous avez d'autres rôles (admin, md, etc.), ajouter aussi:
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
       ('USRM000022', 'MENDYN000011', '*', 0, 'md');

