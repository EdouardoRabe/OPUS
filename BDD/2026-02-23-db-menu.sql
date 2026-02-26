DELETE FROM USERMENU
WHERE idmenu LIKE 'MENDYN%';
DELETE FROM MENUDYNAMIQUE
WHERE id LIKE 'MENDYN%';
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere)
VALUES (
           'MENDYN000001',
           'Accueil',
           'bi-house-door-fill',
           'module.jsp?but=accueil.jsp',
           1,
           0,
           NULL
       ),
       (
           'MENDYN000002',
           'Reseau',
           'bi-people-fill',
           '#',
           2,
           0,
           NULL
       ),
       (
           'MENDYN000004',
           'Mon Profil',
           'bi-person-circle',
           '#',
           5,
           0,
           NULL
       ),
       (
           'MENDYN000999',
           'Administration',
           'bi-gear-fill',
           '#',
           99,
           0,
           NULL
       );
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere)
VALUES (
           'MENDYN000005',
           'Annuaire',
           'bi-book-fill',
           'module.jsp?but=annuaire/annuaire.jsp',
           1,
           1,
           'MENDYN000002'
       ),
       (
           'MENDYN000006',
           'Gestion Specialites',
           'bi-tags-fill',
           'module.jsp?but=specialite/specialite-list.jsp',
           2,
           1,
           'MENDYN000999'
       );
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere)
VALUES (
           'MENDYN000007',
           'Offres d''emploi',
           'bi-list-ul',
           'module.jsp?but=carriere/offres.jsp',
           1,
           1,
           'MENDYN000003'
       ),
       (
           'MENDYN000008',
           'Publier une offre',
           'bi-plus-circle-fill',
           'module.jsp?but=carriere/publier-offre.jsp',
           2,
           1,
           'MENDYN000003'
       );
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere)
VALUES (
           'MENDYN000009',
           'Voir ma fiche',
           'bi-person-badge-fill',
           'module.jsp?but=profil/voir.jsp',
           1,
           1,
           'MENDYN000004'
       ),
       (
           'MENDYN000011',
           'Deconnexion',
           'bi-box-arrow-right',
           'deconnexion.jsp',
           3,
           1,
           'MENDYN000004'
       );
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere)
VALUES (
           'MENDYN000023',
           'Gestion des utilisateurs',
           'bi-people',
           'module.jsp?but=mod/gestion-utilisateurs.jsp',
           1,
           1,
           'MENDYN000999'
       ),
       (
           'MENDYN000024',
           'Gestion des signalements',
           'bi-shield-exclamation',
           'module.jsp?but=mod/gestion-signalements.jsp',
           2,
           1,
           'MENDYN000999'
       );
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere)
VALUES (
           'MENDYN000014',
           'Notifications',
           'bi-bell-fill',
           '#',
           6,
           0,
           NULL
       );
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere)
VALUES (
           'MENDYN000015',
           'Evenements',
           'bi-calendar-event-fill',
           '#',
           4,
           0,
           NULL
       ),
       (
           'MENDYN000016',
           'Saisie',
           'bi-plus-circle-fill',
           'module.jsp?but=evenement/evenement-saisie.jsp',
           1,
           1,
           'MENDYN000015'
       ),
       (
           'MENDYN000017',
           'Liste',
           'bi-list-ul',
           'module.jsp?but=evenement/evenement-list.jsp',
           2,
           1,
           'MENDYN000015'
       ),
       (
           'MENDYN000018',
           'Calendrier',
           'bi-calendar-heart-fill',
           'module.jsp?but=evenement/evenement-calendar.jsp',
           3,
           1,
           'MENDYN000015'
       );
ALTER TABLE publicationvisibilite
    ADD COLUMN IF NOT EXISTS anneeref INTEGER,
    ADD COLUMN IF NOT EXISTS anneedirection CHAR(1) DEFAULT '+';
-- Migrer les anciennes lignes (anneemin -> anneeref, direction par defaut '+')
UPDATE publicationvisibilite
SET anneeref = anneemin,
    anneedirection = '+'
WHERE typecible = 'PROMOTION'
  AND anneemin IS NOT NULL
  AND anneeref IS NULL;
-- Droits role etu
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000001', 'MENDYN000001', '*', 0, 'etu'),
       ('USRM000002', 'MENDYN000002', '*', 0, 'etu'),
       ('USRM000004', 'MENDYN000004', '*', 0, 'etu'),
       ('USRM000005', 'MENDYN000005', '*', 0, 'etu'),
       ('USRM000007', 'MENDYN000007', '*', 0, 'etu'),
       ('USRM000008', 'MENDYN000008', '*', 0, 'etu'),
       ('USRM000009', 'MENDYN000009', '*', 0, 'etu'),
       ('USRM000011', 'MENDYN000011', '*', 0, 'etu'),
       ('USRM000025', 'MENDYN000024', '*', 1, 'etu'),
       ('USRM000027', 'MENDYN000014', '*', 0, 'etu'),
       ('USRM000029', 'MENDYN000015', '*', 0, 'etu'),
       ('USRM000035', 'MENDYN000018', '*', 0, 'etu');

-- Droits role alu
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000101', 'MENDYN000001', '*', 0, 'alu'),
       ('USRM000102', 'MENDYN000002', '*', 0, 'alu'),
       ('USRM000104', 'MENDYN000004', '*', 0, 'alu'),
       ('USRM000105', 'MENDYN000005', '*', 0, 'alu'),
       ('USRM000107', 'MENDYN000007', '*', 0, 'alu'),
       ('USRM000108', 'MENDYN000008', '*', 0, 'alu'),
       ('USRM000109', 'MENDYN000009', '*', 0, 'alu'),
       ('USRM000111', 'MENDYN000011', '*', 0, 'alu'),
       ('USRM000125', 'MENDYN000024', '*', 1, 'alu'),
       ('USRM000127', 'MENDYN000014', '*', 0, 'alu'),
       ('USRM000129', 'MENDYN000015', '*', 0, 'alu'),
       ('USRM000135', 'MENDYN000018', '*', 0, 'alu');
-- Droits role md
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000012', 'MENDYN000001', '*', 0, 'md'),
       ('USRM000013', 'MENDYN000002', '*', 0, 'md'),
       ('USRM000015', 'MENDYN000004', '*', 0, 'md'),
       ('USRM000016', 'MENDYN000005', '*', 0, 'md'),
       ('USRM000017', 'MENDYN000006', '*', 0, 'md'),
       ('USRM000018', 'MENDYN000007', '*', 0, 'md'),
       ('USRM000019', 'MENDYN000008', '*', 0, 'md'),
       ('USRM000020', 'MENDYN000009', '*', 0, 'md'),
       ('USRM000022', 'MENDYN000011', '*', 0, 'md'),
       ('USRM000099', 'MENDYN000999', '*', 0, 'md'),
       ('USRM000023', 'MENDYN000023', '*', 0, 'md'),
       ('USRM000024', 'MENDYN000024', '*', 0, 'md'),
       ('USRM000028', 'MENDYN000014', '*', 0, 'md'),
       ('USRM000030', 'MENDYN000015', '*', 0, 'md'),
       ('USRM000032', 'MENDYN000016', '*', 0, 'md'),
       ('USRM000034', 'MENDYN000017', '*', 0, 'md'),
       ('USRM000036', 'MENDYN000018', '*', 0, 'md');
-- Sous-menu Reseau Professionnel sous RESEAU (niveau 1)
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere)
VALUES (
           'MENDYN000019',
           'Reseau pro',
           'bi-diagram-3-fill',
           'module.jsp?but=alumni/reseau-professionnel.jsp',
           3,
           1,
           'MENDYN000002'
       );
-- Droits role etu
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000045', 'MENDYN000019', '*', 0, 'etu');

-- Droits role etu
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000145', 'MENDYN000019', '*', 0, 'alu');

-- Droits role md
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000046', 'MENDYN000019', '*', 0, 'md');

-- Sous-menu Carte sous RESEAU (niveau 1)
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere)
VALUES (
           'MENDYN000020',
           'Carte',
           'bi-globe-americas',
           'module.jsp?but=map/cart.jsp',
           3,
           0,
           NULL
       );

-- Droits role etu pour la Carte
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000047', 'MENDYN000020', '*', 0, 'etu');

-- Droits role etu pour la Carte
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000147', 'MENDYN000020', '*', 0, 'etu');

-- Droits role md pour la Carte
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000048', 'MENDYN000020', '*', 0, 'md');

-- Sous-menu Dashboard et Historique sous Administration (niveau 1)
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere)
VALUES (
           'MENDYN000026',
           'Dashboard',
           'bi-clipboard-data',
           'module.jsp?but=dashboard/dashboard.jsp',
           1,
           1,
           'MENDYN000999'
       ),
       (
           'MENDYN000027',
           'Historique',
           'bi-clock-history',
           'module.jsp?but=dashboard/historique-list.jsp',
           2,
           1,
           'MENDYN000999'
       );

INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole)
VALUES ('USRM000049', 'MENDYN000027', '*', 0, 'md'),
       ('USRM000050', 'MENDYN000026', '*', 0, 'md');