-- =============================================================
-- Script complet: Menus ITU Alumni (Cote Etudiant)
-- Date: 2026-02-23
-- Structure:
--   Niveau 0: Accueil, Reseau, Carriere, Mon Profil
--   Niveau 1: Sous-menus (Annuaire, Specialites, Offres, Publier, etc.)
-- Icones: Bootstrap Icons (bi-*)
-- =============================================================

-- ETAPE 1: SUPPRIMER LES ANCIENS MENUS DE TEST
DELETE FROM USERMENU WHERE idmenu LIKE 'MENDYN%' OR idmenu LIKE 'MENU_TEST%';
DELETE FROM MENUDYNAMIQUE WHERE id LIKE 'MENDYN%' OR id LIKE 'MENU_TEST%';

-- ETAPE 2: INSERER LES MENUS PRINCIPAUX (NIVEAU 0)
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000001', 'Accueil',        'bi-house-door-fill', 'module.jsp?but=accueil.jsp', 1,  0, NULL),
('MENDYN000002', 'Reseau',         'bi-people-fill',     '#',                           2,  0, NULL),
('MENDYN000003', 'Carriere',       'bi-briefcase-fill',  '#',                           3,  0, NULL),
('MENDYN000004', 'Mon Profil',     'bi-person-circle',   '#',                           5,  0, NULL),
('MENDYN000999', 'Administration', 'bi-gear-fill',       '#',                           99, 0, NULL);

-- ETAPE 3: INSERER LES SOUS-MENUS (NIVEAU 1)

-- Sous-menus de RESEAU
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000005', 'Annuaire',    'bi-book-fill', 'module.jsp?but=annuaire/annuaire.jsp',       1, 1, 'MENDYN000002'),
('MENDYN000006', 'Specialites', 'bi-tags-fill', 'module.jsp?but=specialite/specialite-list.jsp', 2, 1, 'MENDYN000002');

-- Sous-menus de CARRIERE
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000007', 'Offres d''emploi',  'bi-list-ul',         'module.jsp?but=carriere/offres.jsp',        1, 1, 'MENDYN000003'),
('MENDYN000008', 'Publier une offre', 'bi-plus-circle-fill', 'module.jsp?but=carriere/publier-offre.jsp', 2, 1, 'MENDYN000003');

-- Sous-menus de MON PROFIL
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000009', 'Voir ma fiche',     'bi-person-badge-fill', 'module.jsp?but=profil/voir.jsp',     1, 1, 'MENDYN000004'),
('MENDYN000010', 'Modifier le profil','bi-pencil-square',     'module.jsp?but=profil/modifier.jsp', 2, 1, 'MENDYN000004'),
('MENDYN000011', 'Deconnexion',       'bi-box-arrow-right',   'deconnexion.jsp',                    3, 1, 'MENDYN000004');

-- Sous-menus de ADMINISTRATION
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000023', 'Gestion des utilisateurs', 'bi-people',             'module.jsp?but=mod/gestion-utilisateurs.jsp', 1, 1, 'MENDYN000999'),
('MENDYN000024', 'Gestion des signalements', 'bi-shield-exclamation', 'module.jsp?but=mod/gestion-signalements.jsp', 2, 1, 'MENDYN000999');

-- ETAPE 4: INSERER LES DROITS D'ACCES (USERMENU) - role etu
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000001', 'MENDYN000001', '*', 0, 'etu'),
('USRM000002', 'MENDYN000002', '*', 0, 'etu'),
('USRM000003', 'MENDYN000003', '*', 0, 'etu'),
('USRM000004', 'MENDYN000004', '*', 0, 'etu'),
('USRM000005', 'MENDYN000005', '*', 0, 'etu'),
('USRM000006', 'MENDYN000006', '*', 0, 'etu'),
('USRM000007', 'MENDYN000007', '*', 0, 'etu'),
('USRM000008', 'MENDYN000008', '*', 0, 'etu'),
('USRM000009', 'MENDYN000009', '*', 0, 'etu'),
('USRM000010', 'MENDYN000010', '*', 0, 'etu'),
('USRM000011', 'MENDYN000011', '*', 0, 'etu'),
('USRM000025', 'MENDYN000024', '*', 1, 'etu');

-- ETAPE 4: INSERER LES DROITS D'ACCES (USERMENU) - role md
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000012', 'MENDYN000001', '*', 0, 'md'),
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

-- ETAPE 5: MENU NOTIFICATIONS

-- Sous-menu Notifications sous Publications (Niveau 1)
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000014', 'Notifications', 'bi-bell-fill', '#', 6, 0, NULL);

-- Droits role etu
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000027', 'MENDYN000014', '*', 0, 'etu');

-- Droits role md
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000028', 'MENDYN000014', '*', 0, 'md');

-- ETAPE 6: MENU CALENDRIER
-- menu Calendrier (Niveau 0)
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000015', 'Evenements', 'bi-calendar-event-fill', '#', 4, 0, NULL),
('MENDYN000016', 'Saisie', 'bi-plus-circle-fill', 'module.jsp?but=evenement/evenement-saisie.jsp', 1, 1, 'MENDYN000015'),
('MENDYN000017', 'Liste', 'bi-list-ul', 'module.jsp?but=evenement/evenement-list.jsp', 2, 1, 'MENDYN000015'),
('MENDYN000018', 'Calendrier', 'bi-calendar-heart-fill', 'module.jsp?but=evenement/evenement-calendar.jsp', 3, 1, 'MENDYN000015');

-- Droits role etu
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000029', 'MENDYN000015', '*', 0, 'etu'),
('USRM000030', 'MENDYN000018', '*', 0, 'etu');

-- Droits role md
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000031', 'MENDYN000015', '*', 0, 'md'),
('USRM000032', 'MENDYN000016', '*', 0, 'md'),
('USRM000033', 'MENDYN000017', '*', 0, 'md'),
('USRM000034', 'MENDYN000018', '*', 0, 'md');   