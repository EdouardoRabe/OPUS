-- Active: 1736646695640@@127.0.0.1@5432@opus4
-- =====================================================================
-- DONNEES DE TEST - Reseau Professionnel (50 utilisateurs)
-- Prerequis:
--   - 2026-02-22-db-opus.sql
--   - 2026-02-22-db-sequences.sql
--   - data/2026-02-22-data-utilisateur.sql (refuser 100/101/102 deja existants)
--
-- Mot de passe en clair : "test"
--   Crypte : t(29)-4=25->p, e(14)-4=10->a, s(28)-4=24->o, t(29)-4=25->p => "paop"
-- Login  : ETU000010 a ETU000059
-- refuser: 200 a 249
--
-- Clusters thematiques (pour accentuer les scores de compatibilite) :
--   Cluster A (200-209): Java + BDD          | Informatique  | Promotion 2024
--   Cluster B (210-219): Python + IA         | Design        | Promotion 2024
--   Cluster C (220-229): Reseaux + Securite  | Informatique  | Promotion 2023
--   Cluster D (230-239): JavaScript + Mobile | Design        | Promotion 2023
--   Cluster E (240-249): DevOps + Cloud      | Informatique  | Promotion 2022
-- =====================================================================

-- =====================================================================
-- SECTION 1 : PARCOURS (1 nouveau, PRC000001 Informatique deja existant)
-- =====================================================================
INSERT INTO parcours (idparcours, libelle) VALUES
('PRC000002', 'Design');

-- =====================================================================
-- SECTION 2 : PROMOTIONS
-- PRM000001 (2024, PRC000001) deja existante
-- =====================================================================
INSERT INTO promotion (idpromotion, annee, libelle, idparcours) VALUES
('PRM000002', 2023, 'P18', 'PRC000001'),
('PRM000003', 2022, 'P17', 'PRC000001'),
('PRM000004', 2021, 'P16', 'PRC000001'),
('PRM000005', 2025, 'P20', 'PRC000001'),
('PRM000006', 2023, 'P18-D', 'PRC000002'),
('PRM000007', 2024, 'P19-D', 'PRC000002'),
('PRM000008', 2022, 'P17-D', 'PRC000002'),
('PRM000009', 2021, 'P16-D', 'PRC000002'),
('PRM000010', 2025, 'P20-D', 'PRC000002');

-- =====================================================================
-- SECTION 3 : SPECIALITES (tags du reseau)
-- =====================================================================
INSERT INTO specialite (idspecialite, libelle) VALUES
('SPE000001', 'Java'),
('SPE000002', 'Python'),
('SPE000003', 'JavaScript'),
('SPE000004', 'Intelligence Artificielle'),
('SPE000005', 'Reseaux Informatiques'),
('SPE000006', 'Base de Donnees'),
('SPE000007', 'Securite Informatique'),
('SPE000008', 'DevOps et Cloud'),
('SPE000009', 'Developpement Mobile'),
('SPE000010', 'Data Visualisation');

-- =====================================================================
-- SECTION 4 : POSTES
-- =====================================================================
INSERT INTO poste (idposte, libelle) VALUES
('POS000001', 'Developpeur Full Stack'),
('POS000002', 'Developpeur Backend'),
('POS000003', 'Developpeur Frontend'),
('POS000004', 'Ingenieur Reseaux'),
('POS000005', 'Data Scientist'),
('POS000006', 'Ingenieur Securite'),
('POS000007', 'Chef de Projet IT'),
('POS000008', 'DevOps Engineer'),
('POS000009', 'Architecte Logiciel'),
('POS000010', 'Consultant Freelance IT');

-- =====================================================================
-- SECTION 5 : UTILISATEURS (refuser 200-249)
-- adruser = DIR42 obligatoire (JOIN direction dans utilisateurvue)
-- =====================================================================

-- --- CLUSTER A : Java + BDD | Informatique 2024 ---
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, adruser, idrole, id, estactif) VALUES
(200, 'ETU000010', 'paop', 'Andriamina Toky',        'DIR42', 'md', 'ETU000010', 1),
(201, 'ETU000011', 'paop', 'Rakotoarisoa Lalaina',    'DIR42', 'etu', 'ETU000011', 1),
(202, 'ETU000012', 'paop', 'Razafimahefa Nivo',       'DIR42', 'etu', 'ETU000012', 1),
(203, 'ETU000013', 'paop', 'Andrianasolo Heritiana',  'DIR42', 'etu', 'ETU000013', 1),
(204, 'ETU000014', 'paop', 'Rabemanantsoa Hary',      'DIR42', 'etu', 'ETU000014', 1),
(205, 'ETU000015', 'paop', 'Ratsimbazafy Mahefa',     'DIR42', 'etu', 'ETU000015', 1),
(206, 'ETU000016', 'paop', 'Andrianiaina Faniry',     'DIR42', 'etu', 'ETU000016', 1),
(207, 'ETU000017', 'paop', 'Rajoelison Tantely',      'DIR42', 'etu', 'ETU000017', 1),
(208, 'ETU000018', 'paop', 'Randriamiarana Zo',       'DIR42', 'etu', 'ETU000018', 1),
(209, 'ETU000019', 'paop', 'Rakotomalala Fanja',      'DIR42', 'etu', 'ETU000019', 1);

-- --- CLUSTER B : Python + IA | Design 2024 ---
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, adruser, idrole, id, estactif) VALUES
(210, 'ETU000020', 'paop', 'Rajaonarison Miora',      'DIR42', 'etu', 'ETU000020', 1),
(211, 'ETU000021', 'paop', 'Randrianarisoa Vola',     'DIR42', 'etu', 'ETU000021', 1),
(212, 'ETU000022', 'paop', 'Ravoavy Harena',          'DIR42', 'etu', 'ETU000022', 1),
(213, 'ETU000023', 'paop', 'Andriamasinoro Tiana',    'DIR42', 'etu', 'ETU000023', 1),
(214, 'ETU000024', 'paop', 'Rakotomanana Haja',       'DIR42', 'etu', 'ETU000024', 1),
(215, 'ETU000025', 'paop', 'Razanamasy Fitia',        'DIR42', 'etu', 'ETU000025', 1),
(216, 'ETU000026', 'paop', 'Andriambelo Nina',        'DIR42', 'etu', 'ETU000026', 1),
(217, 'ETU000027', 'paop', 'Randriatsara Haingo',     'DIR42', 'etu', 'ETU000027', 1),
(218, 'ETU000028', 'paop', 'Rakotonirina Narindra',   'DIR42', 'etu', 'ETU000028', 1),
(219, 'ETU000029', 'paop', 'Andriamalala Hasina',     'DIR42', 'etu', 'ETU000029', 1);

-- --- CLUSTER C : Reseaux + Securite | Informatique 2023 ---
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, adruser, idrole, id, estactif) VALUES
(220, 'ETU000030', 'paop', 'Razafy Elia',             'DIR42', 'etu', 'ETU000030', 1),
(221, 'ETU000031', 'paop', 'Randriamahefa Onjaniaina','DIR42', 'etu', 'ETU000031', 1),
(222, 'ETU000032', 'paop', 'Rakotovao Tsiry',         'DIR42', 'etu', 'ETU000032', 1),
(223, 'ETU000033', 'paop', 'Andrianasy Mialy',        'DIR42', 'etu', 'ETU000033', 1),
(224, 'ETU000034', 'paop', 'Rabemananjara Nirina',    'DIR42', 'etu', 'ETU000034', 1),
(225, 'ETU000035', 'paop', 'Razandriamanana Faly',    'DIR42', 'etu', 'ETU000035', 1),
(226, 'ETU000036', 'paop', 'Andrianarivo Soja',       'DIR42', 'etu', 'ETU000036', 1),
(227, 'ETU000037', 'paop', 'Randriambololona Mija',   'DIR42', 'etu', 'ETU000037', 1),
(228, 'ETU000038', 'paop', 'Rakotoarivony Lanto',     'DIR42', 'etu', 'ETU000038', 1),
(229, 'ETU000039', 'paop', 'Razoharinoro Mamitiana',  'DIR42', 'etu', 'ETU000039', 1);

-- --- CLUSTER D : JavaScript + Mobile | Design 2023 ---
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, adruser, idrole, id, estactif) VALUES
(230, 'ETU000040', 'paop', 'Randrianarivo Adeline',   'DIR42', 'etu', 'ETU000040', 1),
(231, 'ETU000041', 'paop', 'Rasamoelina Voahirana',   'DIR42', 'etu', 'ETU000041', 1),
(232, 'ETU000042', 'paop', 'Razafindrakoto Beby',     'DIR42', 'etu', 'ETU000042', 1),
(233, 'ETU000043', 'paop', 'Andriamahefarivo Dina',   'DIR42', 'etu', 'ETU000043', 1),
(234, 'ETU000044', 'paop', 'Ranaivo Mamy',            'DIR42', 'etu', 'ETU000044', 1),
(235, 'ETU000045', 'paop', 'Rajaonaivo Laingo',       'DIR42', 'etu', 'ETU000045', 1),
(236, 'ETU000046', 'paop', 'Andrianaivo Felana',      'DIR42', 'etu', 'ETU000046', 1),
(237, 'ETU000047', 'paop', 'Ramanantsoa Lova',        'DIR42', 'etu', 'ETU000047', 1),
(238, 'ETU000048', 'paop', 'Rabetsimba Herica',       'DIR42', 'etu', 'ETU000048', 1),
(239, 'ETU000049', 'paop', 'Andrianjafy Mihaja',      'DIR42', 'etu', 'ETU000049', 1);

-- --- CLUSTER E : DevOps + Cloud | Informatique 2022 ---
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, adruser, idrole, id, estactif) VALUES
(240, 'ETU000050', 'paop', 'Rasoamampionona Tantely', 'DIR42', 'etu', 'ETU000050', 1),
(241, 'ETU000051', 'paop', 'Randriamanana Aina',      'DIR42', 'etu', 'ETU000051', 1),
(242, 'ETU000052', 'paop', 'Rakotobe Nary',           'DIR42', 'etu', 'ETU000052', 1),
(243, 'ETU000053', 'paop', 'Andrianantenaina Soa',    'DIR42', 'etu', 'ETU000053', 1),
(244, 'ETU000054', 'paop', 'Razanajatovo Solo',       'DIR42', 'etu', 'ETU000054', 1),
(245, 'ETU000055', 'paop', 'Randriamboavonjy Feno',   'DIR42', 'etu', 'ETU000055', 1),
(246, 'ETU000056', 'paop', 'Raharinoro Manitra',      'DIR42', 'etu', 'ETU000056', 1),
(247, 'ETU000057', 'paop', 'Andriamasinoro Harisoa',  'DIR42', 'etu', 'ETU000057', 1),
(248, 'ETU000058', 'paop', 'Rakotovelo Tsanta',       'DIR42', 'etu', 'ETU000058', 1),
(249, 'ETU000059', 'paop', 'Ramaharosoa Finaritra',   'DIR42', 'etu', 'ETU000059', 1);

-- =====================================================================
-- SECTION 6 : PARAMCRYPT (obligatoire pour login)
-- =====================================================================
INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur) VALUES
('CRY000200', 4, 1, '200'), ('CRY000201', 4, 1, '201'), ('CRY000202', 4, 1, '202'),
('CRY000203', 4, 1, '203'), ('CRY000204', 4, 1, '204'), ('CRY000205', 4, 1, '205'),
('CRY000206', 4, 1, '206'), ('CRY000207', 4, 1, '207'), ('CRY000208', 4, 1, '208'),
('CRY000209', 4, 1, '209'), ('CRY000210', 4, 1, '210'), ('CRY000211', 4, 1, '211'),
('CRY000212', 4, 1, '212'), ('CRY000213', 4, 1, '213'), ('CRY000214', 4, 1, '214'),
('CRY000215', 4, 1, '215'), ('CRY000216', 4, 1, '216'), ('CRY000217', 4, 1, '217'),
('CRY000218', 4, 1, '218'), ('CRY000219', 4, 1, '219'), ('CRY000220', 4, 1, '220'),
('CRY000221', 4, 1, '221'), ('CRY000222', 4, 1, '222'), ('CRY000223', 4, 1, '223'),
('CRY000224', 4, 1, '224'), ('CRY000225', 4, 1, '225'), ('CRY000226', 4, 1, '226'),
('CRY000227', 4, 1, '227'), ('CRY000228', 4, 1, '228'), ('CRY000229', 4, 1, '229'),
('CRY000230', 4, 1, '230'), ('CRY000231', 4, 1, '231'), ('CRY000232', 4, 1, '232'),
('CRY000233', 4, 1, '233'), ('CRY000234', 4, 1, '234'), ('CRY000235', 4, 1, '235'),
('CRY000236', 4, 1, '236'), ('CRY000237', 4, 1, '237'), ('CRY000238', 4, 1, '238'),
('CRY000239', 4, 1, '239'), ('CRY000240', 4, 1, '240'), ('CRY000241', 4, 1, '241'),
('CRY000242', 4, 1, '242'), ('CRY000243', 4, 1, '243'), ('CRY000244', 4, 1, '244'),
('CRY000245', 4, 1, '245'), ('CRY000246', 4, 1, '246'), ('CRY000247', 4, 1, '247'),
('CRY000248', 4, 1, '248'), ('CRY000249', 4, 1, '249');

-- =====================================================================
-- SECTION 7 : PROFILS
-- idprofil : PRF000010 a PRF000059 (PRF000001-003 deja existants)
-- idgenre  : GEN000001=Masculin  GEN000002=Feminin
-- Cluster A -> PRM000001 (2024), PRC000001 (Informatique)
-- Cluster B -> PRM000007 (2024), PRC000002 (Design)
-- Cluster C -> PRM000002 (2023), PRC000001 (Informatique)
-- Cluster D -> PRM000006 (2023), PRC000002 (Design)
-- Cluster E -> PRM000003 (2022), PRC000001 (Informatique)
-- =====================================================================

-- Cluster A (promotions variees: 2024, 2023, 2022, 2021, 2025)
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre) VALUES
('PRF000010','andriamina.toky@itu.mg',       'Andriamina',      'Toky',       '2000-03-12','034 10 000 00','PRM000001','PRC000001',200,'GEN000001'),
('PRF000011','rakotoarisoa.lalaina@itu.mg',   'Rakotoarisoa',    'Lalaina',    '2001-07-25','034 10 000 01','PRM000002','PRC000001',201,'GEN000002'),
('PRF000012','razafimahefa.nivo@itu.mg',      'Razafimahefa',    'Nivo',       '2000-11-08','034 10 000 02','PRM000003','PRC000001',202,'GEN000001'),
('PRF000013','andrianasolo.heritiana@itu.mg', 'Andrianasolo',    'Heritiana',  '1999-05-17','034 10 000 03','PRM000004','PRC000001',203,'GEN000001'),
('PRF000014','rabemanantsoa.hary@itu.mg',     'Rabemanantsoa',   'Hary',       '2001-01-30','034 10 000 04','PRM000005','PRC000001',204,'GEN000002'),
('PRF000015','ratsimbazafy.mahefa@itu.mg',    'Ratsimbazafy',    'Mahefa',     '2000-09-14','034 10 000 05','PRM000002','PRC000001',205,'GEN000001'),
('PRF000016','andrianiaina.faniry@itu.mg',    'Andrianiaina',    'Faniry',     '2001-04-22','034 10 000 06','PRM000003','PRC000001',206,'GEN000002'),
('PRF000017','rajoelison.tantely@itu.mg',     'Rajoelison',      'Tantely',    '2000-08-05','034 10 000 07','PRM000004','PRC000001',207,'GEN000001'),
('PRF000018','randriamiarana.zo@itu.mg',      'Randriamiarana',  'Zo',         '2001-12-19','034 10 000 08','PRM000005','PRC000001',208,'GEN000002'),
('PRF000019','rakotomalala.fanja@itu.mg',     'Rakotomalala',    'Fanja',      '2000-06-03','034 10 000 09','PRM000001','PRC000001',209,'GEN000002');

-- Cluster B (promotions variees: 2024, 2023, 2022, 2021, 2025)
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre) VALUES
('PRF000020','rajaonarison.miora@itu.mg',     'Rajaonarison',    'Miora',      '2000-02-14','034 20 000 00','PRM000007','PRC000002',210,'GEN000002'),
('PRF000021','randrianarisoa.vola@itu.mg',    'Randrianarisoa',  'Vola',       '2001-10-07','034 20 000 01','PRM000006','PRC000002',211,'GEN000002'),
('PRF000022','ravoavy.harena@itu.mg',         'Ravoavy',         'Harena',     '1999-08-21','034 20 000 02','PRM000008','PRC000002',212,'GEN000001'),
('PRF000023','andriamasinoro.tiana@itu.mg',   'Andriamasinoro',  'Tiana',      '2001-03-15','034 20 000 03','PRM000009','PRC000002',213,'GEN000002'),
('PRF000024','rakotomanana.haja@itu.mg',      'Rakotomanana',    'Haja',       '2000-07-28','034 20 000 04','PRM000010','PRC000002',214,'GEN000001'),
('PRF000025','razanamasy.fitia@itu.mg',       'Razanamasy',      'Fitia',      '2001-11-02','034 20 000 05','PRM000006','PRC000002',215,'GEN000002'),
('PRF000026','andriambelo.nina@itu.mg',       'Andriambelo',     'Nina',       '2000-05-18','034 20 000 06','PRM000008','PRC000002',216,'GEN000002'),
('PRF000027','randriatsara.haingo@itu.mg',    'Randriatsara',    'Haingo',     '1999-09-11','034 20 000 07','PRM000009','PRC000002',217,'GEN000002'),
('PRF000028','rakotonirina.narindra@itu.mg',  'Rakotonirina',    'Narindra',   '2001-01-24','034 20 000 08','PRM000010','PRC000002',218,'GEN000001'),
('PRF000029','andriamalala.hasina@itu.mg',    'Andriamalala',    'Hasina',     '2000-04-06','034 20 000 09','PRM000007','PRC000002',219,'GEN000001');

-- Cluster C (promotions variees: 2023, 2024, 2022, 2021, 2025)
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre) VALUES
('PRF000030','razafy.elia@itu.mg',            'Razafy',          'Elia',       '1999-12-09','034 30 000 00','PRM000002','PRC000001',220,'GEN000001'),
('PRF000031','randriamahefa.onjaniaina@itu.mg','Randriamahefa',  'Onjaniaina', '2000-10-17','034 30 000 01','PRM000001','PRC000001',221,'GEN000002'),
('PRF000032','rakotovao.tsiry@itu.mg',        'Rakotovao',       'Tsiry',      '2001-06-30','034 30 000 02','PRM000003','PRC000001',222,'GEN000001'),
('PRF000033','andrianasy.mialy@itu.mg',       'Andrianasy',      'Mialy',      '1999-02-13','034 30 000 03','PRM000004','PRC000001',223,'GEN000002'),
('PRF000034','rabemananjara.nirina@itu.mg',   'Rabemananjara',   'Nirina',     '2000-08-26','034 30 000 04','PRM000005','PRC000001',224,'GEN000002'),
('PRF000035','razandriamanana.faly@itu.mg',   'Razandriamanana', 'Faly',       '2001-04-10','034 30 000 05','PRM000001','PRC000001',225,'GEN000001'),
('PRF000036','andrianarivo.soja@itu.mg',      'Andrianarivo',    'Soja',       '1999-11-23','034 30 000 06','PRM000003','PRC000001',226,'GEN000001'),
('PRF000037','randriambololona.mija@itu.mg',  'Randriambololona','Mija',       '2000-03-07','034 30 000 07','PRM000004','PRC000001',227,'GEN000002'),
('PRF000038','rakotoarivony.lanto@itu.mg',    'Rakotoarivony',   'Lanto',      '2001-09-20','034 30 000 08','PRM000005','PRC000001',228,'GEN000002'),
('PRF000039','razoharinoro.mamitiana@itu.mg', 'Razoharinoro',    'Mamitiana',  '1999-07-04','034 30 000 09','PRM000002','PRC000001',229,'GEN000001');

-- Cluster D (promotions variees: 2023, 2024, 2022, 2021, 2025)
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre) VALUES
('PRF000040','randrianarivo.adeline@itu.mg',  'Randrianarivo',   'Adeline',    '2001-05-16','034 40 000 00','PRM000006','PRC000002',230,'GEN000002'),
('PRF000041','rasamoelina.voahirana@itu.mg',  'Rasamoelina',     'Voahirana',  '2000-01-29','034 40 000 01','PRM000007','PRC000002',231,'GEN000002'),
('PRF000042','razafindrakoto.beby@itu.mg',    'Razafindrakoto',  'Beby',       '1999-10-11','034 40 000 02','PRM000008','PRC000002',232,'GEN000002'),
('PRF000043','andriamahefarivo.dina@itu.mg',  'Andriamahefarivo','Dina',       '2001-07-24','034 40 000 03','PRM000009','PRC000002',233,'GEN000002'),
('PRF000044','ranaivo.mamy@itu.mg',           'Ranaivo',         'Mamy',       '2000-03-08','034 40 000 04','PRM000010','PRC000002',234,'GEN000001'),
('PRF000045','rajaonaivo.laingo@itu.mg',      'Rajaonaivo',      'Laingo',     '1999-12-21','034 40 000 05','PRM000007','PRC000002',235,'GEN000001'),
('PRF000046','andrianaivo.felana@itu.mg',     'Andrianaivo',     'Felana',     '2001-08-04','034 40 000 06','PRM000008','PRC000002',236,'GEN000002'),
('PRF000047','ramanantsoa.lova@itu.mg',       'Ramanantsoa',     'Lova',       '2000-04-17','034 40 000 07','PRM000009','PRC000002',237,'GEN000001'),
('PRF000048','rabetsimba.herica@itu.mg',      'Rabetsimba',      'Herica',     '1999-11-30','034 40 000 08','PRM000010','PRC000002',238,'GEN000001'),
('PRF000049','andrianjafy.mihaja@itu.mg',     'Andrianjafy',     'Mihaja',     '2001-06-13','034 40 000 09','PRM000006','PRC000002',239,'GEN000002');

-- Cluster E (promotions variees: 2022, 2024, 2023, 2021, 2025)
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre) VALUES
('PRF000050','rasoamampionona.tantely@itu.mg','Rasoamampionona', 'Tantely',    '1999-04-26','034 50 000 00','PRM000003','PRC000001',240,'GEN000002'),
('PRF000051','randriamanana.aina@itu.mg',     'Randriamanana',   'Aina',       '2000-09-09','034 50 000 01','PRM000001','PRC000001',241,'GEN000002'),
('PRF000052','rakotobe.nary@itu.mg',          'Rakotobe',        'Nary',       '2001-02-22','034 50 000 02','PRM000002','PRC000001',242,'GEN000001'),
('PRF000053','andrianantenaina.soa@itu.mg',   'Andrianantenaina','Soa',        '1999-08-05','034 50 000 03','PRM000004','PRC000001',243,'GEN000002'),
('PRF000054','razanajatovo.solo@itu.mg',      'Razanajatovo',    'Solo',       '2000-12-18','034 50 000 04','PRM000005','PRC000001',244,'GEN000001'),
('PRF000055','randriamboavonjy.feno@itu.mg',  'Randriamboavonjy','Feno',       '2001-05-31','034 50 000 05','PRM000001','PRC000001',245,'GEN000001'),
('PRF000056','raharinoro.manitra@itu.mg',     'Raharinoro',      'Manitra',    '1999-03-14','034 50 000 06','PRM000002','PRC000001',246,'GEN000002'),
('PRF000057','andriamasinoro.harisoa@itu.mg', 'Andriamasinoro',  'Harisoa',    '2000-07-27','034 50 000 07','PRM000004','PRC000001',247,'GEN000002'),
('PRF000058','rakotovelo.tsanta@itu.mg',      'Rakotovelo',      'Tsanta',     '2001-01-10','034 50 000 08','PRM000005','PRC000001',248,'GEN000001'),
('PRF000059','ramaharosoa.finaritra@itu.mg',  'Ramaharosoa',     'Finaritra',  '1999-06-23','034 50 000 09','PRM000003','PRC000001',249,'GEN000002');

-- =====================================================================
-- SECTION 8 : SPECIALITEPROFIL
-- (idspecialite, idprofil, specialiteprofil, etat, niveau)
-- Distribution variee des specialites pour chaque profil
-- Specialites disponibles :
--   SPE000001: Java           SPE000002: Python          SPE000003: JavaScript
--   SPE000004: IA             SPE000005: Reseaux         SPE000006: Base de Donnees
--   SPE000007: Securite       SPE000008: DevOps/Cloud    SPE000009: Mobile
--   SPE000010: Data Viz
-- =====================================================================

-- PRF000010 : Andriamina Toky (Backend Java) - Java, BDD, DevOps, Python
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000001','PRF000010','SPP000001',1,4), ('SPE000006','PRF000010','SPP000002',1,3),
('SPE000008','PRF000010','SPP000003',1,2), ('SPE000002','PRF000010','SPP000004',1,2);

-- PRF000011 : Rakotoarisoa Lalaina - Java, JavaScript, Mobile, Securite
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000001','PRF000011','SPP000005',1,3), ('SPE000003','PRF000011','SPP000006',1,3),
('SPE000009','PRF000011','SPP000007',1,2), ('SPE000007','PRF000011','SPP000008',1,1);

-- PRF000012 : Razafimahefa Nivo - Java, BDD, Reseaux, IA
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000001','PRF000012','SPP000009',1,4), ('SPE000006','PRF000012','SPP000010',1,4),
('SPE000005','PRF000012','SPP000011',1,2), ('SPE000004','PRF000012','SPP000012',1,1);

-- PRF000013 : Andrianasolo Heritiana - Java, Python, DevOps, Data Viz
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000001','PRF000013','SPP000013',1,3), ('SPE000002','PRF000013','SPP000014',1,3),
('SPE000008','PRF000013','SPP000015',1,2), ('SPE000010','PRF000013','SPP000016',1,2);

-- PRF000014 : Rabemanantsoa Hary - BDD, JavaScript, Securite, Mobile
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000006','PRF000014','SPP000017',1,4), ('SPE000003','PRF000014','SPP000018',1,2),
('SPE000007','PRF000014','SPP000019',1,3), ('SPE000009','PRF000014','SPP000020',1,2);

-- PRF000015 : Ratsimbazafy Mahefa - Java, Python, IA, BDD
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000001','PRF000015','SPP000021',1,3), ('SPE000002','PRF000015','SPP000022',1,4),
('SPE000004','PRF000015','SPP000023',1,3), ('SPE000006','PRF000015','SPP000024',1,2);

-- PRF000016 : Andrianiaina Faniry - JavaScript, Mobile, Java, Data Viz
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000003','PRF000016','SPP000025',1,4), ('SPE000009','PRF000016','SPP000026',1,4),
('SPE000001','PRF000016','SPP000027',1,2), ('SPE000010','PRF000016','SPP000028',1,1);

-- PRF000017 : Rajoelison Tantely - DevOps, Reseaux, Python, Securite
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000008','PRF000017','SPP000029',1,4), ('SPE000005','PRF000017','SPP000030',1,3),
('SPE000002','PRF000017','SPP000031',1,2), ('SPE000007','PRF000017','SPP000032',1,2);

-- PRF000018 : Randriamiarana Zo - BDD, Java, IA, Reseaux
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000006','PRF000018','SPP000033',1,4), ('SPE000001','PRF000018','SPP000034',1,3),
('SPE000004','PRF000018','SPP000035',1,2), ('SPE000005','PRF000018','SPP000036',1,1);

-- PRF000019 : Rakotomalala Fanja - Mobile, JavaScript, Python, DevOps
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000009','PRF000019','SPP000037',1,4), ('SPE000003','PRF000019','SPP000038',1,3),
('SPE000002','PRF000019','SPP000039',1,2), ('SPE000008','PRF000019','SPP000040',1,2);

-- PRF000020 : Rajaonarison Miora (Data Scientist) - Python, IA, Data Viz, BDD
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000002','PRF000020','SPP000041',1,4), ('SPE000004','PRF000020','SPP000042',1,4),
('SPE000010','PRF000020','SPP000043',1,3), ('SPE000006','PRF000020','SPP000044',1,2);

-- PRF000021 : Randrianarisoa Vola - Python, IA, JavaScript, DevOps
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000002','PRF000021','SPP000045',1,4), ('SPE000004','PRF000021','SPP000046',1,3),
('SPE000003','PRF000021','SPP000047',1,2), ('SPE000008','PRF000021','SPP000048',1,2);

-- PRF000022 : Ravoavy Harena - IA, Python, Reseaux, Securite
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000004','PRF000022','SPP000049',1,4), ('SPE000002','PRF000022','SPP000050',1,3),
('SPE000005','PRF000022','SPP000051',1,2), ('SPE000007','PRF000022','SPP000052',1,1);

-- PRF000023 : Andriamasinoro Tiana - Python, Data Viz, Java, Mobile
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000002','PRF000023','SPP000053',1,3), ('SPE000010','PRF000023','SPP000054',1,4),
('SPE000001','PRF000023','SPP000055',1,2), ('SPE000009','PRF000023','SPP000056',1,1);

-- PRF000024 : Rakotomanana Haja - IA, Python, BDD, DevOps
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000004','PRF000024','SPP000057',1,4), ('SPE000002','PRF000024','SPP000058',1,4),
('SPE000006','PRF000024','SPP000059',1,3), ('SPE000008','PRF000024','SPP000060',1,2);

-- PRF000025 : Razanamasy Fitia - Python, JavaScript, IA, Mobile
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000002','PRF000025','SPP000061',1,3), ('SPE000003','PRF000025','SPP000062',1,3),
('SPE000004','PRF000025','SPP000063',1,2), ('SPE000009','PRF000025','SPP000064',1,2);

-- PRF000026 : Andriambelo Nina - Data Viz, Python, IA, BDD
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000010','PRF000026','SPP000065',1,4), ('SPE000002','PRF000026','SPP000066',1,3),
('SPE000004','PRF000026','SPP000067',1,3), ('SPE000006','PRF000026','SPP000068',1,2);

-- PRF000027 : Randriatsara Haingo - IA, Securite, Python, Reseaux
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000004','PRF000027','SPP000069',1,4), ('SPE000007','PRF000027','SPP000070',1,3),
('SPE000002','PRF000027','SPP000071',1,2), ('SPE000005','PRF000027','SPP000072',1,1);

-- PRF000028 : Rakotonirina Narindra - Python, DevOps, IA, Java
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000002','PRF000028','SPP000073',1,3), ('SPE000008','PRF000028','SPP000074',1,3),
('SPE000004','PRF000028','SPP000075',1,4), ('SPE000001','PRF000028','SPP000076',1,2);

-- PRF000029 : Andriamalala Hasina - Data Viz, JavaScript, Python, Mobile
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000010','PRF000029','SPP000077',1,4), ('SPE000003','PRF000029','SPP000078',1,3),
('SPE000002','PRF000029','SPP000079',1,3), ('SPE000009','PRF000029','SPP000080',1,2);

-- PRF000030 : Razafy Elia (Ingenieur Reseaux) - Reseaux, Securite, DevOps, Python
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000005','PRF000030','SPP000081',1,4), ('SPE000007','PRF000030','SPP000082',1,4),
('SPE000008','PRF000030','SPP000083',1,2), ('SPE000002','PRF000030','SPP000084',1,1);

-- PRF000031 : Randriamahefa Onjaniaina - Reseaux, DevOps, Java, Securite
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000005','PRF000031','SPP000085',1,4), ('SPE000008','PRF000031','SPP000086',1,3),
('SPE000001','PRF000031','SPP000087',1,2), ('SPE000007','PRF000031','SPP000088',1,3);

-- PRF000032 : Rakotovao Tsiry - Securite, Reseaux, Python, IA
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000007','PRF000032','SPP000089',1,4), ('SPE000005','PRF000032','SPP000090',1,3),
('SPE000002','PRF000032','SPP000091',1,2), ('SPE000004','PRF000032','SPP000092',1,2);

-- PRF000033 : Andrianasy Mialy - Reseaux, BDD, Securite, JavaScript
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000005','PRF000033','SPP000093',1,3), ('SPE000006','PRF000033','SPP000094',1,3),
('SPE000007','PRF000033','SPP000095',1,2), ('SPE000003','PRF000033','SPP000096',1,1);

-- PRF000034 : Rabemananjara Nirina - Securite, IA, Reseaux, Python
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000007','PRF000034','SPP000097',1,4), ('SPE000004','PRF000034','SPP000098',1,3),
('SPE000005','PRF000034','SPP000099',1,3), ('SPE000002','PRF000034','SPP000100',1,2);

-- PRF000035 : Razandriamanana Faly - Reseaux, DevOps, Securite, Mobile
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000005','PRF000035','SPP000101',1,4), ('SPE000008','PRF000035','SPP000102',1,3),
('SPE000007','PRF000035','SPP000103',1,3), ('SPE000009','PRF000035','SPP000104',1,1);

-- PRF000036 : Andrianarivo Soja - DevOps, Reseaux, Java, BDD
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000008','PRF000036','SPP000105',1,4), ('SPE000005','PRF000036','SPP000106',1,3),
('SPE000001','PRF000036','SPP000107',1,2), ('SPE000006','PRF000036','SPP000108',1,2);

-- PRF000037 : Randriambololona Mija - Securite, Python, Reseaux, Data Viz
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000007','PRF000037','SPP000109',1,4), ('SPE000002','PRF000037','SPP000110',1,3),
('SPE000005','PRF000037','SPP000111',1,2), ('SPE000010','PRF000037','SPP000112',1,2);

-- PRF000038 : Rakotoarivony Lanto - Reseaux, JavaScript, Securite, DevOps
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000005','PRF000038','SPP000113',1,3), ('SPE000003','PRF000038','SPP000114',1,3),
('SPE000007','PRF000038','SPP000115',1,4), ('SPE000008','PRF000038','SPP000116',1,2);

-- PRF000039 : Razoharinoro Mamitiana - Securite, IA, BDD, Python
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000007','PRF000039','SPP000117',1,4), ('SPE000004','PRF000039','SPP000118',1,2),
('SPE000006','PRF000039','SPP000119',1,3), ('SPE000002','PRF000039','SPP000120',1,2);

-- PRF000040 : Randrianarivo Adeline (Frontend) - JavaScript, Mobile, Python, Data Viz
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000003','PRF000040','SPP000121',1,4), ('SPE000009','PRF000040','SPP000122',1,4),
('SPE000002','PRF000040','SPP000123',1,2), ('SPE000010','PRF000040','SPP000124',1,2);

-- PRF000041 : Rasamoelina Voahirana - JavaScript, Java, Mobile, DevOps
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000003','PRF000041','SPP000125',1,4), ('SPE000001','PRF000041','SPP000126',1,3),
('SPE000009','PRF000041','SPP000127',1,3), ('SPE000008','PRF000041','SPP000128',1,1);

-- PRF000042 : Razafindrakoto Beby - Mobile, JavaScript, BDD, IA
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000009','PRF000042','SPP000129',1,4), ('SPE000003','PRF000042','SPP000130',1,3),
('SPE000006','PRF000042','SPP000131',1,2), ('SPE000004','PRF000042','SPP000132',1,2);

-- PRF000043 : Andriamahefarivo Dina - JavaScript, Python, Mobile, Securite
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000003','PRF000043','SPP000133',1,4), ('SPE000002','PRF000043','SPP000134',1,2),
('SPE000009','PRF000043','SPP000135',1,3), ('SPE000007','PRF000043','SPP000136',1,1);

-- PRF000044 : Ranaivo Mamy - Mobile, DevOps, JavaScript, Reseaux
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000009','PRF000044','SPP000137',1,4), ('SPE000008','PRF000044','SPP000138',1,3),
('SPE000003','PRF000044','SPP000139',1,3), ('SPE000005','PRF000044','SPP000140',1,1);

-- PRF000045 : Rajaonaivo Laingo - JavaScript, Java, Mobile, Data Viz
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000003','PRF000045','SPP000141',1,4), ('SPE000001','PRF000045','SPP000142',1,3),
('SPE000009','PRF000045','SPP000143',1,3), ('SPE000010','PRF000045','SPP000144',1,2);

-- PRF000046 : Andrianaivo Felana - JavaScript, BDD, Python, IA
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000003','PRF000046','SPP000145',1,4), ('SPE000006','PRF000046','SPP000146',1,3),
('SPE000002','PRF000046','SPP000147',1,2), ('SPE000004','PRF000046','SPP000148',1,2);

-- PRF000047 : Ramanantsoa Lova - Mobile, JavaScript, DevOps, Securite
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000009','PRF000047','SPP000149',1,4), ('SPE000003','PRF000047','SPP000150',1,3),
('SPE000008','PRF000047','SPP000151',1,2), ('SPE000007','PRF000047','SPP000152',1,2);

-- PRF000048 : Rabetsimba Herica - JavaScript, Reseaux, Mobile, Java
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000003','PRF000048','SPP000153',1,3), ('SPE000005','PRF000048','SPP000154',1,3),
('SPE000009','PRF000048','SPP000155',1,4), ('SPE000001','PRF000048','SPP000156',1,2);

-- PRF000049 : Andrianjafy Mihaja - Mobile, Data Viz, JavaScript, Python
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000009','PRF000049','SPP000157',1,4), ('SPE000010','PRF000049','SPP000158',1,3),
('SPE000003','PRF000049','SPP000159',1,3), ('SPE000002','PRF000049','SPP000160',1,2);

-- PRF000050 : Rasoamampionona Tantely (DevOps) - DevOps, Reseaux, Python, Securite
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000008','PRF000050','SPP000161',1,4), ('SPE000005','PRF000050','SPP000162',1,3),
('SPE000002','PRF000050','SPP000163',1,3), ('SPE000007','PRF000050','SPP000164',1,2);

-- PRF000051 : Randriamanana Aina - DevOps, Java, Reseaux, BDD
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000008','PRF000051','SPP000165',1,4), ('SPE000001','PRF000051','SPP000166',1,3),
('SPE000005','PRF000051','SPP000167',1,2), ('SPE000006','PRF000051','SPP000168',1,2);

-- PRF000052 : Rakotobe Nary - DevOps, Python, IA, Reseaux
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000008','PRF000052','SPP000169',1,4), ('SPE000002','PRF000052','SPP000170',1,4),
('SPE000004','PRF000052','SPP000171',1,3), ('SPE000005','PRF000052','SPP000172',1,2);

-- PRF000053 : Andrianantenaina Soa - Reseaux, DevOps, Securite, JavaScript
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000005','PRF000053','SPP000173',1,4), ('SPE000008','PRF000053','SPP000174',1,3),
('SPE000007','PRF000053','SPP000175',1,3), ('SPE000003','PRF000053','SPP000176',1,1);

-- PRF000054 : Razanajatovo Solo - DevOps, Data Viz, Python, Mobile
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000008','PRF000054','SPP000177',1,4), ('SPE000010','PRF000054','SPP000178',1,3),
('SPE000002','PRF000054','SPP000179',1,3), ('SPE000009','PRF000054','SPP000180',1,1);

-- PRF000055 : Randriamboavonjy Feno - DevOps, Python, IA, Java
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000008','PRF000055','SPP000181',1,4), ('SPE000002','PRF000055','SPP000182',1,4),
('SPE000004','PRF000055','SPP000183',1,3), ('SPE000001','PRF000055','SPP000184',1,2);

-- PRF000056 : Raharinoro Manitra - DevOps, Securite, Reseaux, BDD
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000008','PRF000056','SPP000185',1,4), ('SPE000007','PRF000056','SPP000186',1,3),
('SPE000005','PRF000056','SPP000187',1,3), ('SPE000006','PRF000056','SPP000188',1,2);

-- PRF000057 : Andriamasinoro Harisoa - Python, DevOps, IA, Data Viz
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000002','PRF000057','SPP000189',1,4), ('SPE000008','PRF000057','SPP000190',1,3),
('SPE000004','PRF000057','SPP000191',1,3), ('SPE000010','PRF000057','SPP000192',1,2);

-- PRF000058 : Rakotovelo Tsanta - DevOps, JavaScript, Python, Mobile
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000008','PRF000058','SPP000193',1,4), ('SPE000003','PRF000058','SPP000194',1,3),
('SPE000002','PRF000058','SPP000195',1,2), ('SPE000009','PRF000058','SPP000196',1,2);

-- PRF000059 : Ramaharosoa Finaritra - DevOps, Reseaux, Java, Securite
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000008','PRF000059','SPP000197',1,4), ('SPE000005','PRF000059','SPP000198',1,3),
('SPE000001','PRF000059','SPP000199',1,2), ('SPE000007','PRF000059','SPP000200',1,2);

-- =====================================================================
-- SECTION 9 : EXPERIENCES
-- Poste par cluster :
--   A -> POS000002 Developpeur Backend
--   B -> POS000005 Data Scientist
--   C -> POS000004 Ingenieur Reseaux
--   D -> POS000003 Developpeur Frontend
--   E -> POS000008 DevOps Engineer
-- Ponts : poste mixte (Chef de Projet ou Architecte)
-- =====================================================================

-- Cluster A (postes varies: Backend, Full Stack, Architecte, Chef Projet)
INSERT INTO experience (idexperience, entreprise, debut, fin, description, etat, idprofil, idposte) VALUES
('EXP000001','TechMada','2024-09-01','2025-08-31','Stage Developpeur Backend Java',1,'PRF000010','POS000002'),
('EXP000002','Axian IT','2024-09-01','2025-08-31','Developpeur Full Stack Java/Vue',1,'PRF000011','POS000001'),
('EXP000003','OrangeMada','2024-10-01','2025-09-30','Backend Java / PostgreSQL',1,'PRF000012','POS000002'),
('EXP000004','BNI IT','2024-09-01','2025-08-31','Architecte application bancaire',1,'PRF000013','POS000006'),
('EXP000005','HaitiTech','2024-11-01','2025-10-31','Developpeur Java EE',1,'PRF000014','POS000002'),
('EXP000006','Freelance','2024-09-01','2025-08-31','Chef de Projet IT',1,'PRF000015','POS000007'),
('EXP000007','Tsinjo Solutions','2024-09-01','2025-08-31','Developpeur Full Stack',1,'PRF000016','POS000001'),
('EXP000008','Logistimo','2024-10-01','2025-09-30','Backend Java Spring',1,'PRF000017','POS000002'),
('EXP000009','Groupe SOA','2024-09-01','2025-08-31','Architecte Logiciel Java',1,'PRF000018','POS000006'),
('EXP000010','Tanamanao','2024-11-01','2025-10-31','Backend Java REST API',1,'PRF000019','POS000002');

-- Cluster B (postes varies: Data Scientist, Backend, DevOps, Architecte)
INSERT INTO experience (idexperience, entreprise, debut, fin, description, etat, idprofil, idposte) VALUES
('EXP000011','DataMada','2024-09-01','2025-08-31','Data Scientist Python / TensorFlow',1,'PRF000020','POS000005'),
('EXP000012','Orange Labs','2024-09-01','2025-08-31','Developpeur Backend Python',1,'PRF000021','POS000002'),
('EXP000013','Blueline','2024-10-01','2025-09-30','Data Analyst Python / Pandas',1,'PRF000022','POS000005'),
('EXP000014','Jirama IT','2024-09-01','2025-08-31','DevOps MLOps Engineer',1,'PRF000023','POS000008'),
('EXP000015','Axian Data','2024-11-01','2025-10-31','Scientist Python NLP',1,'PRF000024','POS000005'),
('EXP000016','Freelance Data','2024-09-01','2025-08-31','Chef de Projet Data',1,'PRF000025','POS000007'),
('EXP000017','E-Media','2024-09-01','2025-08-31','Architecte Data',1,'PRF000026','POS000006'),
('EXP000018','OceanData','2024-10-01','2025-09-30','IA Python / Keras',1,'PRF000027','POS000005'),
('EXP000019','TELMA DS','2024-09-01','2025-08-31','Backend Python Django',1,'PRF000028','POS000002'),
('EXP000020','Mora Tech','2024-11-01','2025-10-31','Data Scientist ML',1,'PRF000029','POS000005');

-- Cluster C (postes varies: Reseaux, DevOps, Architecte, Backend)
INSERT INTO experience (idexperience, entreprise, debut, fin, description, etat, idprofil, idposte) VALUES
('EXP000021','TELMA','2024-09-01','2025-08-31','Ingenieur Reseaux LAN/WAN',1,'PRF000030','POS000004'),
('EXP000022','Orange Mada','2024-09-01','2025-08-31','DevOps Reseaux',1,'PRF000031','POS000008'),
('EXP000023','Axian Telecom','2024-10-01','2025-09-30','Admin Reseaux Cisco',1,'PRF000032','POS000004'),
('EXP000024','SOFT','2024-09-01','2025-08-31','Architecte Securite',1,'PRF000033','POS000006'),
('EXP000025','RiT','2024-11-01','2025-10-31','Reseaux MPLS',1,'PRF000034','POS000004'),
('EXP000026','Cyber Defense','2024-09-01','2025-08-31','Chef de Projet Securite',1,'PRF000035','POS000007'),
('EXP000027','CNRE','2024-09-01','2025-08-31','Admin Reseaux Linux',1,'PRF000036','POS000004'),
('EXP000028','NetMada','2024-10-01','2025-09-30','Backend Infrastructure',1,'PRF000037','POS000002'),
('EXP000029','GOT IT','2024-09-01','2025-08-31','DevOps Firewall',1,'PRF000038','POS000008'),
('EXP000030','GPTW','2024-11-01','2025-10-31','Ingenieur Reseaux',1,'PRF000039','POS000004');

-- Cluster D (postes varies: Frontend, Full Stack, Mobile, Chef Projet)
INSERT INTO experience (idexperience, entreprise, debut, fin, description, etat, idprofil, idposte) VALUES
('EXP000031','WebMada','2024-09-01','2025-08-31','Frontend JavaScript React',1,'PRF000040','POS000003'),
('EXP000032','TechPixel','2024-09-01','2025-08-31','Full Stack JS Vue/Node',1,'PRF000041','POS000001'),
('EXP000033','Toky Design','2024-10-01','2025-09-30','Mobile Flutter + Angular',1,'PRF000042','POS000003'),
('EXP000034','Airtelots','2024-09-01','2025-08-31','Chef de Projet Mobile',1,'PRF000043','POS000007'),
('EXP000035','Clik Agency','2024-11-01','2025-10-31','Frontend JS React',1,'PRF000044','POS000003'),
('EXP000036','Fary Digital','2024-09-01','2025-08-31','Full Stack JS + Java',1,'PRF000045','POS000001'),
('EXP000037','Ikalika','2024-09-01','2025-08-31','Architecte Frontend',1,'PRF000046','POS000006'),
('EXP000038','Mija Tech','2024-10-01','2025-09-30','React Developer',1,'PRF000047','POS000003'),
('EXP000039','SoaWeb','2024-09-01','2025-08-31','Full Stack Designer',1,'PRF000048','POS000001'),
('EXP000040','PixelMada','2024-11-01','2025-10-31','Mobile Developer',1,'PRF000049','POS000003');

-- Cluster E (postes varies: DevOps, Backend, Architecte, Reseaux)
INSERT INTO experience (idexperience, entreprise, debut, fin, description, etat, idprofil, idposte) VALUES
('EXP000041','CloudMada','2024-09-01','2025-08-31','DevOps Docker / Kubernetes',1,'PRF000050','POS000008'),
('EXP000042','OrangeCloud','2024-09-01','2025-08-31','Backend Cloud Python',1,'PRF000051','POS000002'),
('EXP000043','Axian Cloud','2024-10-01','2025-09-30','DevOps AWS / Terraform',1,'PRF000052','POS000008'),
('EXP000044','SysAdmin Co','2024-09-01','2025-08-31','Ingenieur Reseaux Cloud',1,'PRF000053','POS000004'),
('EXP000045','GCloud Mada','2024-11-01','2025-10-31','GCP DevOps Engineer',1,'PRF000054','POS000008'),
('EXP000046','DataOps','2024-09-01','2025-08-31','Architecte Cloud',1,'PRF000055','POS000006'),
('EXP000047','Tsinjo IT','2024-09-01','2025-08-31','DevOps Jenkins',1,'PRF000056','POS000008'),
('EXP000048','Kubernetes Mada','2024-10-01','2025-09-30','Backend Go/Docker',1,'PRF000057','POS000002'),
('EXP000049','CloudNative','2024-09-01','2025-08-31','Chef Projet Infrastructure',1,'PRF000058','POS000007'),
('EXP000050','IaaS Mada','2024-11-01','2025-10-31','DevOps Azure',1,'PRF000059','POS000008');

-- =====================================================================
-- SECTION 10 : RESEAUX SOCIAUX PROFILS
-- Liens varies pour chaque profil (1 a 4 reseaux par profil)
-- Reseaux disponibles : linkedin, github, gitlab, bitbucket, stackoverflow,
--                       codepen, behance, twitter, facebook, instagram
-- =====================================================================

-- PRF000010 : Andriamina Toky (Backend Java) - LinkedIn, GitHub, Stack Overflow
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000001', 'PRF000010', 'linkedin', 'andriamina-toky'),
('PSM000002', 'PRF000010', 'github', 'toky-andriamina'),
('PSM000003', 'PRF000010', 'stackoverflow', '12345678/toky-andriamina');

-- PRF000011 : Rakotoarisoa Lalaina - LinkedIn, GitHub
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000004', 'PRF000011', 'linkedin', 'lalaina-rakotoarisoa'),
('PSM000005', 'PRF000011', 'github', 'lalaina-dev');

-- PRF000012 : Razafimahefa Nivo - LinkedIn, GitLab, Twitter
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000006', 'PRF000012', 'linkedin', 'nivo-razafimahefa'),
('PSM000007', 'PRF000012', 'gitlab', 'nivo-raza'),
('PSM000008', 'PRF000012', 'twitter', 'nivo_dev');

-- PRF000013 : Andrianasolo Heritiana - GitHub, Stack Overflow
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000009', 'PRF000013', 'github', 'heritiana-andrianasolo'),
('PSM000010', 'PRF000013', 'stackoverflow', '23456789/heritiana-dev');

-- PRF000014 : Rabemanantsoa Hary - LinkedIn
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000011', 'PRF000014', 'linkedin', 'hary-rabemanantsoa');

-- PRF000015 : Ratsimbazafy Mahefa - LinkedIn, GitHub, Bitbucket
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000012', 'PRF000015', 'linkedin', 'mahefa-ratsimbazafy'),
('PSM000013', 'PRF000015', 'github', 'mahefa-ratsimba'),
('PSM000014', 'PRF000015', 'bitbucket', 'mahefa-dev');

-- PRF000016 : Andrianiaina Faniry - LinkedIn, Instagram, CodePen
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000015', 'PRF000016', 'linkedin', 'faniry-andrianiaina'),
('PSM000016', 'PRF000016', 'instagram', 'faniry.tech'),
('PSM000017', 'PRF000016', 'codepen', 'faniry-dev');

-- PRF000017 : Rajoelison Tantely - GitHub, LinkedIn, Twitter, Stack Overflow
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000018', 'PRF000017', 'github', 'tantely-rajoelison'),
('PSM000019', 'PRF000017', 'linkedin', 'tantely-rajoelison'),
('PSM000020', 'PRF000017', 'twitter', 'tantely_devops'),
('PSM000021', 'PRF000017', 'stackoverflow', '34567890/tantely');

-- PRF000018 : Randriamiarana Zo - LinkedIn, GitHub
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000022', 'PRF000018', 'linkedin', 'zo-randriamiarana'),
('PSM000023', 'PRF000018', 'github', 'zo-dev-mg');

-- PRF000019 : Rakotomalala Fanja - LinkedIn, GitHub, Instagram
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000024', 'PRF000019', 'linkedin', 'fanja-rakotomalala'),
('PSM000025', 'PRF000019', 'github', 'fanja-mobile'),
('PSM000026', 'PRF000019', 'instagram', 'fanja.code');

-- PRF000020 : Rajaonarison Miora (Data Scientist) - LinkedIn, GitHub, Twitter
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000027', 'PRF000020', 'linkedin', 'miora-rajaonarison'),
('PSM000028', 'PRF000020', 'github', 'miora-data'),
('PSM000029', 'PRF000020', 'twitter', 'miora_ai');

-- PRF000021 : Randrianarisoa Vola - LinkedIn, GitHub
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000030', 'PRF000021', 'linkedin', 'vola-randrianarisoa'),
('PSM000031', 'PRF000021', 'github', 'vola-ml');

-- PRF000022 : Ravoavy Harena - GitHub, Stack Overflow, LinkedIn
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000032', 'PRF000022', 'github', 'harena-ravoavy'),
('PSM000033', 'PRF000022', 'stackoverflow', '45678901/harena-ai'),
('PSM000034', 'PRF000022', 'linkedin', 'harena-ravoavy');

-- PRF000023 : Andriamasinoro Tiana - LinkedIn, Behance, Instagram
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000035', 'PRF000023', 'linkedin', 'tiana-andriamasinoro'),
('PSM000036', 'PRF000023', 'behance', 'tiana-dataviz'),
('PSM000037', 'PRF000023', 'instagram', 'tiana.data');

-- PRF000024 : Rakotomanana Haja - LinkedIn, GitHub, GitLab
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000038', 'PRF000024', 'linkedin', 'haja-rakotomanana'),
('PSM000039', 'PRF000024', 'github', 'haja-ai'),
('PSM000040', 'PRF000024', 'gitlab', 'haja-mlops');

-- PRF000025 : Razanamasy Fitia - LinkedIn, Twitter
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000041', 'PRF000025', 'linkedin', 'fitia-razanamasy'),
('PSM000042', 'PRF000025', 'twitter', 'fitia_python');

-- PRF000026 : Andriambelo Nina - LinkedIn, GitHub, Behance, Instagram
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000043', 'PRF000026', 'linkedin', 'nina-andriambelo'),
('PSM000044', 'PRF000026', 'github', 'nina-dataviz'),
('PSM000045', 'PRF000026', 'behance', 'nina-viz'),
('PSM000046', 'PRF000026', 'instagram', 'nina.viz');

-- PRF000027 : Randriatsara Haingo - LinkedIn, GitHub
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000047', 'PRF000027', 'linkedin', 'haingo-randriatsara'),
('PSM000048', 'PRF000027', 'github', 'haingo-security');

-- PRF000028 : Rakotonirina Narindra - GitHub, GitLab, LinkedIn
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000049', 'PRF000028', 'github', 'narindra-rak'),
('PSM000050', 'PRF000028', 'gitlab', 'narindra-devops'),
('PSM000051', 'PRF000028', 'linkedin', 'narindra-rakotonirina');

-- PRF000029 : Andriamalala Hasina - LinkedIn, CodePen, Instagram
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000052', 'PRF000029', 'linkedin', 'hasina-andriamalala'),
('PSM000053', 'PRF000029', 'codepen', 'hasina-frontend'),
('PSM000054', 'PRF000029', 'instagram', 'hasina.dev');

-- PRF000030 : Razafy Elia (Ing. Reseaux) - LinkedIn, GitHub, Twitter
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000055', 'PRF000030', 'linkedin', 'elia-razafy'),
('PSM000056', 'PRF000030', 'github', 'elia-network'),
('PSM000057', 'PRF000030', 'twitter', 'elia_cisco');

-- PRF000031 : Randriamahefa Onjaniaina - LinkedIn
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000058', 'PRF000031', 'linkedin', 'onjaniaina-randriamahefa');

-- PRF000032 : Rakotovao Tsiry - LinkedIn, GitHub, Stack Overflow
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000059', 'PRF000032', 'linkedin', 'tsiry-rakotovao'),
('PSM000060', 'PRF000032', 'github', 'tsiry-sec'),
('PSM000061', 'PRF000032', 'stackoverflow', '56789012/tsiry-security');

-- PRF000033 : Andrianasy Mialy - LinkedIn, Facebook
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000062', 'PRF000033', 'linkedin', 'mialy-andrianasy'),
('PSM000063', 'PRF000033', 'facebook', 'mialy.andrianasy');

-- PRF000034 : Rabemananjara Nirina - LinkedIn, GitHub
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000064', 'PRF000034', 'linkedin', 'nirina-rabemananjara'),
('PSM000065', 'PRF000034', 'github', 'nirina-cybersec');

-- PRF000035 : Razandriamanana Faly - LinkedIn, GitHub, Twitter
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000066', 'PRF000035', 'linkedin', 'faly-razandriamanana'),
('PSM000067', 'PRF000035', 'github', 'faly-devops'),
('PSM000068', 'PRF000035', 'twitter', 'faly_network');

-- PRF000036 : Andrianarivo Soja - GitHub, GitLab, LinkedIn
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000069', 'PRF000036', 'github', 'soja-andrianarivo'),
('PSM000070', 'PRF000036', 'gitlab', 'soja-infra'),
('PSM000071', 'PRF000036', 'linkedin', 'soja-andrianarivo');

-- PRF000037 : Randriambololona Mija - LinkedIn, Twitter
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000072', 'PRF000037', 'linkedin', 'mija-randriambololona'),
('PSM000073', 'PRF000037', 'twitter', 'mija_sec');

-- PRF000038 : Rakotoarivony Lanto - LinkedIn, GitHub
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000074', 'PRF000038', 'linkedin', 'lanto-rakotoarivony'),
('PSM000075', 'PRF000038', 'github', 'lanto-net');

-- PRF000039 : Razoharinoro Mamitiana - LinkedIn, GitHub, Stack Overflow
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000076', 'PRF000039', 'linkedin', 'mamitiana-razoharinoro'),
('PSM000077', 'PRF000039', 'github', 'mamitiana-sec'),
('PSM000078', 'PRF000039', 'stackoverflow', '67890123/mamitiana');

-- PRF000040 : Randrianarivo Adeline (Frontend) - LinkedIn, CodePen, Instagram, Behance
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000079', 'PRF000040', 'linkedin', 'adeline-randrianarivo'),
('PSM000080', 'PRF000040', 'codepen', 'adeline-frontend'),
('PSM000081', 'PRF000040', 'instagram', 'adeline.design'),
('PSM000082', 'PRF000040', 'behance', 'adeline-ui');

-- PRF000041 : Rasamoelina Voahirana - LinkedIn, GitHub
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000083', 'PRF000041', 'linkedin', 'voahirana-rasamoelina'),
('PSM000084', 'PRF000041', 'github', 'voahirana-js');

-- PRF000042 : Razafindrakoto Beby - LinkedIn, GitHub, Instagram
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000085', 'PRF000042', 'linkedin', 'beby-razafindrakoto'),
('PSM000086', 'PRF000042', 'github', 'beby-mobile'),
('PSM000087', 'PRF000042', 'instagram', 'beby.flutter');

-- PRF000043 : Andriamahefarivo Dina - LinkedIn, CodePen
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000088', 'PRF000043', 'linkedin', 'dina-andriamahefarivo'),
('PSM000089', 'PRF000043', 'codepen', 'dina-react');

-- PRF000044 : Ranaivo Mamy - LinkedIn, GitHub, Twitter
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000090', 'PRF000044', 'linkedin', 'mamy-ranaivo'),
('PSM000091', 'PRF000044', 'github', 'mamy-mobile'),
('PSM000092', 'PRF000044', 'twitter', 'mamy_flutter');

-- PRF000045 : Rajaonaivo Laingo - LinkedIn, GitHub, Behance
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000093', 'PRF000045', 'linkedin', 'laingo-rajaonaivo'),
('PSM000094', 'PRF000045', 'github', 'laingo-fullstack'),
('PSM000095', 'PRF000045', 'behance', 'laingo-ux');

-- PRF000046 : Andrianaivo Felana - LinkedIn, Instagram
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000096', 'PRF000046', 'linkedin', 'felana-andrianaivo'),
('PSM000097', 'PRF000046', 'instagram', 'felana.code');

-- PRF000047 : Ramanantsoa Lova - GitHub, LinkedIn, Stack Overflow
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000098', 'PRF000047', 'github', 'lova-ramanantsoa'),
('PSM000099', 'PRF000047', 'linkedin', 'lova-ramanantsoa'),
('PSM000100', 'PRF000047', 'stackoverflow', '78901234/lova-dev');

-- PRF000048 : Rabetsimba Herica - LinkedIn, GitHub
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000101', 'PRF000048', 'linkedin', 'herica-rabetsimba'),
('PSM000102', 'PRF000048', 'github', 'herica-frontend');

-- PRF000049 : Andrianjafy Mihaja - LinkedIn, GitHub, Behance, Instagram
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000103', 'PRF000049', 'linkedin', 'mihaja-andrianjafy'),
('PSM000104', 'PRF000049', 'github', 'mihaja-mobile'),
('PSM000105', 'PRF000049', 'behance', 'mihaja-design'),
('PSM000106', 'PRF000049', 'instagram', 'mihaja.apps');

-- PRF000050 : Rasoamampionona Tantely (DevOps) - LinkedIn, GitHub, GitLab, Twitter
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000107', 'PRF000050', 'linkedin', 'tantely-rasoamampionona'),
('PSM000108', 'PRF000050', 'github', 'tantely-devops'),
('PSM000109', 'PRF000050', 'gitlab', 'tantely-infra'),
('PSM000110', 'PRF000050', 'twitter', 'tantely_k8s');

-- PRF000051 : Randriamanana Aina - LinkedIn, GitHub
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000111', 'PRF000051', 'linkedin', 'aina-randriamanana'),
('PSM000112', 'PRF000051', 'github', 'aina-devops');

-- PRF000052 : Rakotobe Nary - GitHub, GitLab, LinkedIn, Stack Overflow
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000113', 'PRF000052', 'github', 'nary-rakotobe'),
('PSM000114', 'PRF000052', 'gitlab', 'nary-mlops'),
('PSM000115', 'PRF000052', 'linkedin', 'nary-rakotobe'),
('PSM000116', 'PRF000052', 'stackoverflow', '89012345/nary-devops');

-- PRF000053 : Andrianantenaina Soa - LinkedIn, Twitter
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000117', 'PRF000053', 'linkedin', 'soa-andrianantenaina'),
('PSM000118', 'PRF000053', 'twitter', 'soa_network');

-- PRF000054 : Razanajatovo Solo - LinkedIn, GitHub
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000119', 'PRF000054', 'linkedin', 'solo-razanajatovo'),
('PSM000120', 'PRF000054', 'github', 'solo-devops');

-- PRF000055 : Randriamboavonjy Feno - LinkedIn, GitHub, GitLab, Twitter
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000121', 'PRF000055', 'linkedin', 'feno-randriamboavonjy'),
('PSM000122', 'PRF000055', 'github', 'feno-mlops'),
('PSM000123', 'PRF000055', 'gitlab', 'feno-ai'),
('PSM000124', 'PRF000055', 'twitter', 'feno_mlops');

-- PRF000056 : Raharinoro Manitra - LinkedIn, GitHub
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000125', 'PRF000056', 'linkedin', 'manitra-raharinoro'),
('PSM000126', 'PRF000056', 'github', 'manitra-devops');

-- PRF000057 : Andriamasinoro Harisoa - LinkedIn, GitHub, Behance
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000127', 'PRF000057', 'linkedin', 'harisoa-andriamasinoro'),
('PSM000128', 'PRF000057', 'github', 'harisoa-data'),
('PSM000129', 'PRF000057', 'behance', 'harisoa-viz');

-- PRF000058 : Rakotovelo Tsanta - GitHub, GitLab, LinkedIn
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000130', 'PRF000058', 'github', 'tsanta-rakotovelo'),
('PSM000131', 'PRF000058', 'gitlab', 'tsanta-infra'),
('PSM000132', 'PRF000058', 'linkedin', 'tsanta-rakotovelo');

-- PRF000059 : Ramaharosoa Finaritra - LinkedIn, GitHub, Twitter
INSERT INTO profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur) VALUES
('PSM000133', 'PRF000059', 'linkedin', 'finaritra-ramaharosoa'),
('PSM000134', 'PRF000059', 'github', 'finaritra-devops'),
('PSM000135', 'PRF000059', 'twitter', 'finaritra_cloud');

-- =====================================================================
-- MISE A JOUR DES SEQUENCES
-- =====================================================================
SELECT setval('seq_parcours',    10);
SELECT setval('seq_promotion',   15);
SELECT setval('seq_profil',      70);
SELECT setval('seq_poste',       15);
SELECT setval('seq_specialite',  15);
SELECT setval('seq_experience',  60);
SELECT setval('seq_specialiteprofil', 210);
SELECT setval('seq_profilsocialmedia', 150);

-- initial data for profilstatut
INSERT INTO profilstatut(id, idprofil, idprofiltypestatut)
SELECT getseqprofilstatut(),
    'PRF000010',
    (
        SELECT idprofiltypestatut
        FROM profiltypestatut
        WHERE libelle = 'Taken'
    );
-- View: latest profile status with type details
CREATE OR REPLACE VIEW v_profilstatut_latest AS
SELECT ps.id,
    ps.idprofil,
    ps.idprofiltypestatut,
    pts.libelle,
    pts.couleur,
    ps.daty
FROM profilstatut ps
    INNER JOIN profiltypestatut pts ON ps.idprofiltypestatut = pts.idprofiltypestatut
WHERE (ps.idprofil, ps.daty) IN (
        SELECT idprofil,
            MAX(daty)
        FROM profilstatut
        GROUP BY idprofil
    );

-- =====================================================================
-- SECTION : HISTORIQUE ACTIF (estactif = 100 => Actif)
-- Tous les utilisateurs (refuser 100-102 + 200-249)
-- =====================================================================
INSERT INTO historiqueactif (id, idutilisateur, estactif, daty, description) VALUES
(CAST(getseqhistoriqueactif() AS VARCHAR), '100', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '101', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '102', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '200', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '201', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '202', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '203', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '204', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '205', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '206', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '207', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '208', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '209', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '210', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '211', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '212', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '213', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '214', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '215', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '216', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '217', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '218', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '219', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '220', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '221', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '222', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '223', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '224', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '225', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '226', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '227', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '228', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '229', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '230', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '231', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '232', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '233', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '234', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '235', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '236', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '237', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '238', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '239', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '240', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '241', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '242', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '243', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '244', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '245', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '246', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '247', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '248', 100, CURRENT_DATE, 'Activation initiale'),
(CAST(getseqhistoriqueactif() AS VARCHAR), '249', 100, CURRENT_DATE, 'Activation initiale');

-- ============================================================
-- LOCALISATION DES PROFILS (profilemplacement)
-- Coordonnees variees : Madagascar + Monde entier
-- ============================================================

-- Cluster A (PRF000011-PRF000020) : Web Dev - Madagascar + France
INSERT INTO profilemplacement (id, idprofil, longitude, latitude) VALUES
('PEM000001', 'PRF000011', 47.5255, -18.8792),   -- Antananarivo, Madagascar
('PEM000002', 'PRF000012', 2.3522, 48.8566),     -- Paris, France
('PEM000003', 'PRF000013', 47.5180, -18.9100),   -- Ankorondrano, Madagascar
('PEM000004', 'PRF000014', 4.8357, 45.7640),     -- Lyon, France
('PEM000005', 'PRF000015', 5.3698, 43.2965),     -- Marseille, France
('PEM000006', 'PRF000016', 47.5400, -18.8600),   -- Andraharo, Madagascar
('PEM000007', 'PRF000017', 1.4442, 43.6047),     -- Toulouse, France
('PEM000008', 'PRF000018', 47.5050, -18.9200),   -- Andoharanofotsy, Madagascar
('PEM000009', 'PRF000019', 7.2620, 43.7102),     -- Nice, France
('PEM000010', 'PRF000020', 47.4800, -18.9300);   -- Anosizato, Madagascar

-- Cluster B (PRF000021-PRF000030) : Data Science - Canada + USA + Madagascar
INSERT INTO profilemplacement (id, idprofil, longitude, latitude) VALUES
('PEM000011', 'PRF000021', -73.5673, 45.5017),   -- Montreal, Canada
('PEM000012', 'PRF000022', -122.4194, 37.7749),  -- San Francisco, USA
('PEM000013', 'PRF000023', 49.3958, -18.1443),   -- Toamasina, Madagascar
('PEM000014', 'PRF000024', -74.0060, 40.7128),   -- New York, USA
('PEM000015', 'PRF000025', -71.2082, 46.8139),   -- Quebec City, Canada
('PEM000016', 'PRF000026', 47.0340, -19.8659),   -- Antsirabe, Madagascar
('PEM000017', 'PRF000027', -79.3832, 43.6532),   -- Toronto, Canada
('PEM000018', 'PRF000028', -118.2437, 34.0522),  -- Los Angeles, USA
('PEM000019', 'PRF000029', -123.1216, 49.2827),  -- Vancouver, Canada
('PEM000020', 'PRF000030', 47.0500, -19.8500);   -- Antsirabe Nord, Madagascar

-- Cluster C (PRF000031-PRF000040) : Cybersecurite - Europe + Madagascar
INSERT INTO profilemplacement (id, idprofil, longitude, latitude) VALUES
('PEM000021', 'PRF000031', 4.3517, 50.8503),     -- Bruxelles, Belgique
('PEM000022', 'PRF000032', 6.1432, 46.2044),     -- Geneve, Suisse
('PEM000023', 'PRF000033', 47.0856, -21.4417),   -- Fianarantsoa, Madagascar
('PEM000024', 'PRF000034', 8.5417, 47.3769),     -- Zurich, Suisse
('PEM000025', 'PRF000035', 13.4050, 52.5200),    -- Berlin, Allemagne
('PEM000026', 'PRF000036', 46.3167, -15.7167),   -- Mahajanga, Madagascar
('PEM000027', 'PRF000037', -0.1276, 51.5074),    -- Londres, UK
('PEM000028', 'PRF000038', 12.4964, 41.9028),    -- Rome, Italie
('PEM000029', 'PRF000039', -3.7038, 40.4168),    -- Madrid, Espagne
('PEM000030', 'PRF000040', 47.0750, -21.4500);   -- Fianarantsoa Centre, Madagascar

-- Cluster D (PRF000041-PRF000050) : Mobile/IoT - Ocean Indien + Asie + Madagascar
INSERT INTO profilemplacement (id, idprofil, longitude, latitude) VALUES
('PEM000031', 'PRF000041', 57.5522, -20.1609),   -- Port-Louis, Maurice
('PEM000032', 'PRF000042', 55.4550, -21.1151),   -- Saint-Denis, Reunion
('PEM000033', 'PRF000043', 49.2913, -12.2795),   -- Antsiranana, Madagascar
('PEM000034', 'PRF000044', 103.8198, 1.3521),    -- Singapour
('PEM000035', 'PRF000045', 121.4737, 31.2304),   -- Shanghai, Chine
('PEM000036', 'PRF000046', 43.6667, -23.3500),   -- Toliara, Madagascar
('PEM000037', 'PRF000047', 139.6917, 35.6895),   -- Tokyo, Japon
('PEM000038', 'PRF000048', 126.9780, 37.5665),   -- Seoul, Coree du Sud
('PEM000039', 'PRF000049', 72.8777, 19.0760),    -- Mumbai, Inde
('PEM000040', 'PRF000050', 55.5364, -4.6796);    -- Victoria, Seychelles

-- Cluster E (PRF000051-PRF000060) : DevOps/Cloud - Mix mondial + Madagascar
INSERT INTO profilemplacement (id, idprofil, longitude, latitude) VALUES
('PEM000041', 'PRF000051', 47.5255, -18.8792),   -- Antananarivo, Madagascar
('PEM000042', 'PRF000052', 151.2093, -33.8688),  -- Sydney, Australie
('PEM000043', 'PRF000053', 174.7633, -36.8485),  -- Auckland, Nouvelle-Zelande
('PEM000044', 'PRF000054', 18.4241, -33.9249),   -- Cape Town, Afrique du Sud
('PEM000045', 'PRF000055', 3.3792, 6.5244),      -- Lagos, Nigeria
('PEM000046', 'PRF000056', 47.5180, -18.9100),   -- Ankorondrano, Madagascar
('PEM000047', 'PRF000057', 28.0473, -26.2041),   -- Johannesburg, Afrique du Sud
('PEM000048', 'PRF000058', -46.6333, -23.5505),  -- Sao Paulo, Bresil
('PEM000049', 'PRF000059', -58.3816, -34.6037),  -- Buenos Aires, Argentine
('PEM000050', 'PRF000059', 47.5400, -18.8600);   -- Andraharo, Madagascar

-- Mise a jour de la sequence profilemplacement
SELECT setval('seq_profilemplacement', 50);

