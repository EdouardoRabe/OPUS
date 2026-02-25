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
--   Cluster B (210-219): Python + IA         | Data Science  | Promotion 2024
--   Cluster C (220-229): Reseaux + Securite  | Reseaux       | Promotion 2023
--   Cluster D (230-239): JavaScript + Mobile | Informatique  | Promotion 2023
--   Cluster E (240-249): DevOps + Cloud      | Genie Logiciel| Promotion 2022
-- =====================================================================

-- =====================================================================
-- SECTION 1 : PARCOURS (4 nouveaux, PRC000001 Informatique deja existant)
-- =====================================================================
INSERT INTO parcours (idparcours, libelle) VALUES
('PRC000002', 'Reseaux et Telecommunications'),
('PRC000003', 'Data Science et Big Data'),
('PRC000004', 'Cybersecurite'),
('PRC000005', 'Genie Logiciel');

-- =====================================================================
-- SECTION 2 : PROMOTIONS
-- PRM000001 (2024, PRC000001) deja existante
-- =====================================================================
INSERT INTO promotion (idpromotion, annee, libelle, idparcours) VALUES
('PRM000002', 2023, 'P18', 'PRC000001'),
('PRM000003', 2022, 'P17', 'PRC000001'),
('PRM000004', 2021, 'P16', 'PRC000001'),
('PRM000005', 2025, 'P20', 'PRC000001'),
('PRM000006', 2023, 'P18-RT', 'PRC000002'),
('PRM000007', 2024, 'P19-RT', 'PRC000002'),
('PRM000008', 2024, 'P19-DS', 'PRC000003'),
('PRM000009', 2024, 'P19-CS', 'PRC000004'),
('PRM000010', 2022, 'P17-GL', 'PRC000005');

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

-- --- CLUSTER B : Python + IA | Data Science 2024 ---
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

-- --- CLUSTER C : Reseaux + Securite | Reseaux 2023 ---
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

-- --- CLUSTER D : JavaScript + Mobile | Informatique 2023 ---
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

-- --- CLUSTER E : DevOps + Cloud | Genie Logiciel 2022 ---
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
-- Cluster B -> PRM000008 (2024), PRC000003 (Data Science)
-- Cluster C -> PRM000006 (2023), PRC000002 (Reseaux)
-- Cluster D -> PRM000002 (2023), PRC000001 (Informatique)
-- Cluster E -> PRM000010 (2022), PRC000005 (Genie Logiciel)
-- =====================================================================

-- Cluster A
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre) VALUES
('PRF000010','andriamina.toky@itu.mg',       'Andriamina',      'Toky',       '2000-03-12','034 10 000 00','PRM000001','PRC000001',200,'GEN000001'),
('PRF000011','rakotoarisoa.lalaina@itu.mg',   'Rakotoarisoa',    'Lalaina',    '2001-07-25','034 10 000 01','PRM000001','PRC000001',201,'GEN000002'),
('PRF000012','razafimahefa.nivo@itu.mg',      'Razafimahefa',    'Nivo',       '2000-11-08','034 10 000 02','PRM000001','PRC000001',202,'GEN000001'),
('PRF000013','andrianasolo.heritiana@itu.mg', 'Andrianasolo',    'Heritiana',  '1999-05-17','034 10 000 03','PRM000001','PRC000001',203,'GEN000001'),
('PRF000014','rabemanantsoa.hary@itu.mg',     'Rabemanantsoa',   'Hary',       '2001-01-30','034 10 000 04','PRM000001','PRC000001',204,'GEN000002'),
('PRF000015','ratsimbazafy.mahefa@itu.mg',    'Ratsimbazafy',    'Mahefa',     '2000-09-14','034 10 000 05','PRM000001','PRC000001',205,'GEN000001'),
('PRF000016','andrianiaina.faniry@itu.mg',    'Andrianiaina',    'Faniry',     '2001-04-22','034 10 000 06','PRM000001','PRC000001',206,'GEN000002'),
('PRF000017','rajoelison.tantely@itu.mg',     'Rajoelison',      'Tantely',    '2000-08-05','034 10 000 07','PRM000001','PRC000001',207,'GEN000001'),
('PRF000018','randriamiarana.zo@itu.mg',      'Randriamiarana',  'Zo',         '2001-12-19','034 10 000 08','PRM000001','PRC000001',208,'GEN000002'),
('PRF000019','rakotomalala.fanja@itu.mg',     'Rakotomalala',    'Fanja',      '2000-06-03','034 10 000 09','PRM000001','PRC000001',209,'GEN000002');

-- Cluster B
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre) VALUES
('PRF000020','rajaonarison.miora@itu.mg',     'Rajaonarison',    'Miora',      '2000-02-14','034 20 000 00','PRM000008','PRC000003',210,'GEN000002'),
('PRF000021','randrianarisoa.vola@itu.mg',    'Randrianarisoa',  'Vola',       '2001-10-07','034 20 000 01','PRM000008','PRC000003',211,'GEN000002'),
('PRF000022','ravoavy.harena@itu.mg',         'Ravoavy',         'Harena',     '1999-08-21','034 20 000 02','PRM000008','PRC000003',212,'GEN000001'),
('PRF000023','andriamasinoro.tiana@itu.mg',   'Andriamasinoro',  'Tiana',      '2001-03-15','034 20 000 03','PRM000008','PRC000003',213,'GEN000002'),
('PRF000024','rakotomanana.haja@itu.mg',      'Rakotomanana',    'Haja',       '2000-07-28','034 20 000 04','PRM000008','PRC000003',214,'GEN000001'),
('PRF000025','razanamasy.fitia@itu.mg',       'Razanamasy',      'Fitia',      '2001-11-02','034 20 000 05','PRM000008','PRC000003',215,'GEN000002'),
('PRF000026','andriambelo.nina@itu.mg',       'Andriambelo',     'Nina',       '2000-05-18','034 20 000 06','PRM000008','PRC000003',216,'GEN000002'),
('PRF000027','randriatsara.haingo@itu.mg',    'Randriatsara',    'Haingo',     '1999-09-11','034 20 000 07','PRM000008','PRC000003',217,'GEN000002'),
('PRF000028','rakotonirina.narindra@itu.mg',  'Rakotonirina',    'Narindra',   '2001-01-24','034 20 000 08','PRM000008','PRC000003',218,'GEN000001'),
('PRF000029','andriamalala.hasina@itu.mg',    'Andriamalala',    'Hasina',     '2000-04-06','034 20 000 09','PRM000008','PRC000003',219,'GEN000001');

-- Cluster C
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre) VALUES
('PRF000030','razafy.elia@itu.mg',            'Razafy',          'Elia',       '1999-12-09','034 30 000 00','PRM000006','PRC000002',220,'GEN000001'),
('PRF000031','randriamahefa.onjaniaina@itu.mg','Randriamahefa',  'Onjaniaina', '2000-10-17','034 30 000 01','PRM000006','PRC000002',221,'GEN000002'),
('PRF000032','rakotovao.tsiry@itu.mg',        'Rakotovao',       'Tsiry',      '2001-06-30','034 30 000 02','PRM000006','PRC000002',222,'GEN000001'),
('PRF000033','andrianasy.mialy@itu.mg',       'Andrianasy',      'Mialy',      '1999-02-13','034 30 000 03','PRM000006','PRC000002',223,'GEN000002'),
('PRF000034','rabemananjara.nirina@itu.mg',   'Rabemananjara',   'Nirina',     '2000-08-26','034 30 000 04','PRM000006','PRC000002',224,'GEN000002'),
('PRF000035','razandriamanana.faly@itu.mg',   'Razandriamanana', 'Faly',       '2001-04-10','034 30 000 05','PRM000006','PRC000002',225,'GEN000001'),
('PRF000036','andrianarivo.soja@itu.mg',      'Andrianarivo',    'Soja',       '1999-11-23','034 30 000 06','PRM000006','PRC000002',226,'GEN000001'),
('PRF000037','randriambololona.mija@itu.mg',  'Randriambololona','Mija',       '2000-03-07','034 30 000 07','PRM000006','PRC000002',227,'GEN000002'),
('PRF000038','rakotoarivony.lanto@itu.mg',    'Rakotoarivony',   'Lanto',      '2001-09-20','034 30 000 08','PRM000006','PRC000002',228,'GEN000002'),
('PRF000039','razoharinoro.mamitiana@itu.mg', 'Razoharinoro',    'Mamitiana',  '1999-07-04','034 30 000 09','PRM000006','PRC000002',229,'GEN000001');

-- Cluster D
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre) VALUES
('PRF000040','randrianarivo.adeline@itu.mg',  'Randrianarivo',   'Adeline',    '2001-05-16','034 40 000 00','PRM000002','PRC000001',230,'GEN000002'),
('PRF000041','rasamoelina.voahirana@itu.mg',  'Rasamoelina',     'Voahirana',  '2000-01-29','034 40 000 01','PRM000002','PRC000001',231,'GEN000002'),
('PRF000042','razafindrakoto.beby@itu.mg',    'Razafindrakoto',  'Beby',       '1999-10-11','034 40 000 02','PRM000002','PRC000001',232,'GEN000002'),
('PRF000043','andriamahefarivo.dina@itu.mg',  'Andriamahefarivo','Dina',       '2001-07-24','034 40 000 03','PRM000002','PRC000001',233,'GEN000002'),
('PRF000044','ranaivo.mamy@itu.mg',           'Ranaivo',         'Mamy',       '2000-03-08','034 40 000 04','PRM000002','PRC000001',234,'GEN000001'),
('PRF000045','rajaonaivo.laingo@itu.mg',      'Rajaonaivo',      'Laingo',     '1999-12-21','034 40 000 05','PRM000002','PRC000001',235,'GEN000001'),
('PRF000046','andrianaivo.felana@itu.mg',     'Andrianaivo',     'Felana',     '2001-08-04','034 40 000 06','PRM000002','PRC000001',236,'GEN000002'),
('PRF000047','ramanantsoa.lova@itu.mg',       'Ramanantsoa',     'Lova',       '2000-04-17','034 40 000 07','PRM000002','PRC000001',237,'GEN000001'),
('PRF000048','rabetsimba.herica@itu.mg',      'Rabetsimba',      'Herica',     '1999-11-30','034 40 000 08','PRM000002','PRC000001',238,'GEN000001'),
('PRF000049','andrianjafy.mihaja@itu.mg',     'Andrianjafy',     'Mihaja',     '2001-06-13','034 40 000 09','PRM000002','PRC000001',239,'GEN000002');

-- Cluster E
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre) VALUES
('PRF000050','rasoamampionona.tantely@itu.mg','Rasoamampionona', 'Tantely',    '1999-04-26','034 50 000 00','PRM000010','PRC000005',240,'GEN000002'),
('PRF000051','randriamanana.aina@itu.mg',     'Randriamanana',   'Aina',       '2000-09-09','034 50 000 01','PRM000010','PRC000005',241,'GEN000002'),
('PRF000052','rakotobe.nary@itu.mg',          'Rakotobe',        'Nary',       '2001-02-22','034 50 000 02','PRM000010','PRC000005',242,'GEN000001'),
('PRF000053','andrianantenaina.soa@itu.mg',   'Andrianantenaina','Soa',        '1999-08-05','034 50 000 03','PRM000010','PRC000005',243,'GEN000002'),
('PRF000054','razanajatovo.solo@itu.mg',      'Razanajatovo',    'Solo',       '2000-12-18','034 50 000 04','PRM000010','PRC000005',244,'GEN000001'),
('PRF000055','randriamboavonjy.feno@itu.mg',  'Randriamboavonjy','Feno',       '2001-05-31','034 50 000 05','PRM000010','PRC000005',245,'GEN000001'),
('PRF000056','raharinoro.manitra@itu.mg',     'Raharinoro',      'Manitra',    '1999-03-14','034 50 000 06','PRM000010','PRC000005',246,'GEN000002'),
('PRF000057','andriamasinoro.harisoa@itu.mg', 'Andriamasinoro',  'Harisoa',    '2000-07-27','034 50 000 07','PRM000010','PRC000005',247,'GEN000002'),
('PRF000058','rakotovelo.tsanta@itu.mg',      'Rakotovelo',      'Tsanta',     '2001-01-10','034 50 000 08','PRM000010','PRC000005',248,'GEN000001'),
('PRF000059','ramaharosoa.finaritra@itu.mg',  'Ramaharosoa',     'Finaritra',  '1999-06-23','034 50 000 09','PRM000010','PRC000005',249,'GEN000002');

-- =====================================================================
-- SECTION 8 : SPECIALITEPROFIL
-- (idspecialite, idprofil, specialiteprofil, etat, niveau)
-- Cluster A : SPE000001 Java + SPE000006 BDD (+ SPE000009 Mobile pour 205-209)
-- Cluster B : SPE000002 Python + SPE000004 IA (+ SPE000010 DataViz pour 215-219)
-- Cluster C : SPE000005 Reseaux + SPE000007 Securite (+ SPE000008 DevOps pour 225-229)
-- Cluster D : SPE000003 JS + SPE000009 Mobile (+ SPE000006 BDD pour 235-239)
-- Cluster E : SPE000008 DevOps + SPE000005 Reseaux (+ SPE000002 Python pour 245-249)
-- Utilisateurs "pont" inter-clusters pour relier le graphe :
--   205 (A+B) : Java + Python  |  215 (B+D) : Python + JS
--   225 (C+E) : Reseaux + DevOps  |  235 (D+A) : JS + Java
--   245 (E+B) : DevOps + IA
-- =====================================================================

-- Cluster A : 200-204 (Java + BDD)
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000001','PRF000010','SPP000001',1,3), ('SPE000006','PRF000010','SPP000002',1,2),
('SPE000001','PRF000011','SPP000003',1,3), ('SPE000006','PRF000011','SPP000004',1,2),
('SPE000001','PRF000012','SPP000005',1,4), ('SPE000006','PRF000012','SPP000006',1,3),
('SPE000001','PRF000013','SPP000007',1,3), ('SPE000006','PRF000013','SPP000008',1,2),
('SPE000001','PRF000014','SPP000009',1,2), ('SPE000006','PRF000014','SPP000010',1,3);

-- Cluster A : 205-209 (Java + BDD + tag pont)
-- 205 = pont A<->B : Java + Python
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000001','PRF000015','SPP000011',1,3), ('SPE000002','PRF000015','SPP000012',1,2), ('SPE000006','PRF000015','SPP000013',1,2),
-- 206-209 : Java + BDD + Mobile
('SPE000001','PRF000016','SPP000014',1,4), ('SPE000006','PRF000016','SPP000015',1,2), ('SPE000009','PRF000016','SPP000016',1,1),
('SPE000001','PRF000017','SPP000017',1,3), ('SPE000006','PRF000017','SPP000018',1,3), ('SPE000009','PRF000017','SPP000019',1,2),
('SPE000001','PRF000018','SPP000020',1,2), ('SPE000006','PRF000018','SPP000021',1,4), ('SPE000009','PRF000018','SPP000022',1,1),
('SPE000001','PRF000019','SPP000023',1,3), ('SPE000006','PRF000019','SPP000024',1,2), ('SPE000009','PRF000019','SPP000025',1,3);

-- Cluster B : 210-214 (Python + IA)
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000002','PRF000020','SPP000026',1,4), ('SPE000004','PRF000020','SPP000027',1,3),
('SPE000002','PRF000021','SPP000028',1,3), ('SPE000004','PRF000021','SPP000029',1,4),
('SPE000002','PRF000022','SPP000030',1,3), ('SPE000004','PRF000022','SPP000031',1,2),
('SPE000002','PRF000023','SPP000032',1,2), ('SPE000004','PRF000023','SPP000033',1,3),
('SPE000002','PRF000024','SPP000034',1,4), ('SPE000004','PRF000024','SPP000035',1,3);

-- Cluster B : 215-219 (Python + IA + tag pont)
-- 215 = pont B<->D : Python + JS
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000002','PRF000025','SPP000036',1,3), ('SPE000003','PRF000025','SPP000037',1,2), ('SPE000004','PRF000025','SPP000038',1,3),
-- 216-219 : Python + IA + DataViz
('SPE000002','PRF000026','SPP000039',1,4), ('SPE000004','PRF000026','SPP000040',1,2), ('SPE000010','PRF000026','SPP000041',1,2),
('SPE000002','PRF000027','SPP000042',1,3), ('SPE000004','PRF000027','SPP000043',1,3), ('SPE000010','PRF000027','SPP000044',1,1),
('SPE000002','PRF000028','SPP000045',1,2), ('SPE000004','PRF000028','SPP000046',1,4), ('SPE000010','PRF000028','SPP000047',1,2),
('SPE000002','PRF000029','SPP000048',1,3), ('SPE000004','PRF000029','SPP000049',1,2), ('SPE000010','PRF000029','SPP000050',1,3);

-- Cluster C : 220-224 (Reseaux + Securite)
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000005','PRF000030','SPP000051',1,3), ('SPE000007','PRF000030','SPP000052',1,3),
('SPE000005','PRF000031','SPP000053',1,4), ('SPE000007','PRF000031','SPP000054',1,2),
('SPE000005','PRF000032','SPP000055',1,2), ('SPE000007','PRF000032','SPP000056',1,4),
('SPE000005','PRF000033','SPP000057',1,3), ('SPE000007','PRF000033','SPP000058',1,3),
('SPE000005','PRF000034','SPP000059',1,2), ('SPE000007','PRF000034','SPP000060',1,3);

-- Cluster C : 225-229 (Reseaux + Securite + tag pont)
-- 225 = pont C<->E : Reseaux + DevOps
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000005','PRF000035','SPP000061',1,3), ('SPE000007','PRF000035','SPP000062',1,2), ('SPE000008','PRF000035','SPP000063',1,2),
-- 226-229 : Reseaux + Securite + DevOps
('SPE000005','PRF000036','SPP000064',1,4), ('SPE000007','PRF000036','SPP000065',1,2), ('SPE000008','PRF000036','SPP000066',1,1),
('SPE000005','PRF000037','SPP000067',1,3), ('SPE000007','PRF000037','SPP000068',1,3), ('SPE000008','PRF000037','SPP000069',1,2),
('SPE000005','PRF000038','SPP000070',1,2), ('SPE000007','PRF000038','SPP000071',1,4), ('SPE000008','PRF000038','SPP000072',1,1),
('SPE000005','PRF000039','SPP000073',1,3), ('SPE000007','PRF000039','SPP000074',1,2), ('SPE000008','PRF000039','SPP000075',1,3);

-- Cluster D : 230-234 (JS + Mobile)
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000003','PRF000040','SPP000076',1,4), ('SPE000009','PRF000040','SPP000077',1,3),
('SPE000003','PRF000041','SPP000078',1,3), ('SPE000009','PRF000041','SPP000079',1,4),
('SPE000003','PRF000042','SPP000080',1,2), ('SPE000009','PRF000042','SPP000081',1,3),
('SPE000003','PRF000043','SPP000082',1,4), ('SPE000009','PRF000043','SPP000083',1,2),
('SPE000003','PRF000044','SPP000084',1,3), ('SPE000009','PRF000044','SPP000085',1,3);

-- Cluster D : 235-239 (JS + Mobile + tag pont)
-- 235 = pont D<->A : JS + Java
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000001','PRF000045','SPP000086',1,2), ('SPE000003','PRF000045','SPP000087',1,3), ('SPE000009','PRF000045','SPP000088',1,2),
-- 236-239 : JS + Mobile + BDD
('SPE000003','PRF000046','SPP000089',1,4), ('SPE000009','PRF000046','SPP000090',1,2), ('SPE000006','PRF000046','SPP000091',1,1),
('SPE000003','PRF000047','SPP000092',1,3), ('SPE000009','PRF000047','SPP000093',1,3), ('SPE000006','PRF000047','SPP000094',1,2),
('SPE000003','PRF000048','SPP000095',1,2), ('SPE000009','PRF000048','SPP000096',1,4), ('SPE000006','PRF000048','SPP000097',1,1),
('SPE000003','PRF000049','SPP000098',1,3), ('SPE000009','PRF000049','SPP000099',1,2), ('SPE000006','PRF000049','SPP000100',1,3);

-- Cluster E : 240-244 (DevOps + Reseaux)
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000008','PRF000050','SPP000101',1,4), ('SPE000005','PRF000050','SPP000102',1,2),
('SPE000008','PRF000051','SPP000103',1,3), ('SPE000005','PRF000051','SPP000104',1,3),
('SPE000008','PRF000052','SPP000105',1,4), ('SPE000005','PRF000052','SPP000106',1,2),
('SPE000008','PRF000053','SPP000107',1,2), ('SPE000005','PRF000053','SPP000108',1,3),
('SPE000008','PRF000054','SPP000109',1,3), ('SPE000005','PRF000054','SPP000110',1,4);

-- Cluster E : 245-249 (DevOps + tag pont)
-- 245 = pont E<->B : DevOps + Python + IA
INSERT INTO specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) VALUES
('SPE000002','PRF000055','SPP000111',1,2), ('SPE000004','PRF000055','SPP000112',1,2), ('SPE000008','PRF000055','SPP000113',1,3),
-- 246-249 : DevOps + Python
('SPE000008','PRF000056','SPP000114',1,4), ('SPE000002','PRF000056','SPP000115',1,2), ('SPE000005','PRF000056','SPP000116',1,1),
('SPE000008','PRF000057','SPP000117',1,3), ('SPE000002','PRF000057','SPP000118',1,3), ('SPE000005','PRF000057','SPP000119',1,2),
('SPE000008','PRF000058','SPP000120',1,2), ('SPE000002','PRF000058','SPP000121',1,4), ('SPE000005','PRF000058','SPP000122',1,1),
('SPE000008','PRF000059','SPP000123',1,3), ('SPE000002','PRF000059','SPP000124',1,2), ('SPE000005','PRF000059','SPP000125',1,3);

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

-- Cluster A (POS000002 Backend)
INSERT INTO experience (idexperience, entreprise, debut, fin, description, etat, idprofil, idposte) VALUES
('EXP000001','TechMada','2024-09-01','2025-08-31','Stage Developpeur Backend Java',1,'PRF000010','POS000002'),
('EXP000002','Axian IT','2024-09-01','2025-08-31','Developpeur Java Spring Boot',1,'PRF000011','POS000002'),
('EXP000003','OrangeMada','2024-10-01','2025-09-30','Backend Java / PostgreSQL',1,'PRF000012','POS000002'),
('EXP000004','BNI IT','2024-09-01','2025-08-31','Developpeur application bancaire Java',1,'PRF000013','POS000002'),
('EXP000005','HaitiTech','2024-11-01','2025-10-31','Developpeur Java EE',1,'PRF000014','POS000002'),
('EXP000006','Freelance','2024-09-01','2025-08-31','Full Stack Java + Vue.js',1,'PRF000015','POS000007'),
('EXP000007','Tsinjo Solutions','2024-09-01','2025-08-31','Developpeur Backend Java',1,'PRF000016','POS000002'),
('EXP000008','Logistimo','2024-10-01','2025-09-30','Backend Java Spring',1,'PRF000017','POS000002'),
('EXP000009','Groupe SOA','2024-09-01','2025-08-31','Developpeur Java / Oracle',1,'PRF000018','POS000002'),
('EXP000010','Tanamanao','2024-11-01','2025-10-31','Backend Java REST API',1,'PRF000019','POS000002');

-- Cluster B (POS000005 Data Scientist)
INSERT INTO experience (idexperience, entreprise, debut, fin, description, etat, idprofil, idposte) VALUES
('EXP000011','DataMada','2024-09-01','2025-08-31','Data Scientist Python / TensorFlow',1,'PRF000020','POS000005'),
('EXP000012','Orange Labs','2024-09-01','2025-08-31','Machine Learning Python',1,'PRF000021','POS000005'),
('EXP000013','Blueline','2024-10-01','2025-09-30','Data Analyst Python / Pandas',1,'PRF000022','POS000005'),
('EXP000014','Jirama IT','2024-09-01','2025-08-31','Data Science IA',1,'PRF000023','POS000005'),
('EXP000015','Axian Data','2024-11-01','2025-10-31','Scientist Python NLP',1,'PRF000024','POS000005'),
('EXP000016','Freelance Data','2024-09-01','2025-08-31','Python Data / Dashboard',1,'PRF000025','POS000007'),
('EXP000017','E-Media','2024-09-01','2025-08-31','Data Analyst Python',1,'PRF000026','POS000005'),
('EXP000018','OceanData','2024-10-01','2025-09-30','IA Python / Keras',1,'PRF000027','POS000005'),
('EXP000019','TELMA DS','2024-09-01','2025-08-31','Data Scientist',1,'PRF000028','POS000005'),
('EXP000020','Mora Tech','2024-11-01','2025-10-31','Python ML Engineer',1,'PRF000029','POS000005');

-- Cluster C (POS000004 Ingenieur Reseaux)
INSERT INTO experience (idexperience, entreprise, debut, fin, description, etat, idprofil, idposte) VALUES
('EXP000021','TELMA','2024-09-01','2025-08-31','Ingenieur Reseaux LAN/WAN',1,'PRF000030','POS000004'),
('EXP000022','Orange Mada','2024-09-01','2025-08-31','Reseaux et Securite',1,'PRF000031','POS000004'),
('EXP000023','Axian Telecom','2024-10-01','2025-09-30','Admin Reseaux Cisco',1,'PRF000032','POS000004'),
('EXP000024','SOFT','2024-09-01','2025-08-31','Securite Reseaux',1,'PRF000033','POS000004'),
('EXP000025','RiT','2024-11-01','2025-10-31','Reseaux MPLS',1,'PRF000034','POS000004'),
('EXP000026','Cyber Defense','2024-09-01','2025-08-31','Reseaux + Securite DevOps',1,'PRF000035','POS000006'),
('EXP000027','CNRE','2024-09-01','2025-08-31','Admin Reseaux Linux',1,'PRF000036','POS000004'),
('EXP000028','NetMada','2024-10-01','2025-09-30','Ingenieur IP/MPLS',1,'PRF000037','POS000004'),
('EXP000029','GOT IT','2024-09-01','2025-08-31','Reseaux & Firewall',1,'PRF000038','POS000004'),
('EXP000030','GPTW','2024-11-01','2025-10-31','Admin Systeme et Reseaux',1,'PRF000039','POS000004');

-- Cluster D (POS000003 Developpeur Frontend)
INSERT INTO experience (idexperience, entreprise, debut, fin, description, etat, idprofil, idposte) VALUES
('EXP000031','WebMada','2024-09-01','2025-08-31','Frontend JavaScript React',1,'PRF000040','POS000003'),
('EXP000032','TechPixel','2024-09-01','2025-08-31','Frontend JS Vue.js',1,'PRF000041','POS000003'),
('EXP000033','Toky Design','2024-10-01','2025-09-30','Mobile Flutter + Angular',1,'PRF000042','POS000003'),
('EXP000034','Airtelots','2024-09-01','2025-08-31','React Native Developer',1,'PRF000043','POS000003'),
('EXP000035','Clik Agency','2024-11-01','2025-10-31','Frontend JS',1,'PRF000044','POS000003'),
('EXP000036','Fary Digital','2024-09-01','2025-08-31','JS Full Stack + Java',1,'PRF000045','POS000001'),
('EXP000037','Ikalika','2024-09-01','2025-08-31','Frontend Angular',1,'PRF000046','POS000003'),
('EXP000038','Mija Tech','2024-10-01','2025-09-30','React Developer',1,'PRF000047','POS000003'),
('EXP000039','SoaWeb','2024-09-01','2025-08-31','Designer UI / JS',1,'PRF000048','POS000003'),
('EXP000040','PixelMada','2024-11-01','2025-10-31','Mobile Developer',1,'PRF000049','POS000003');

-- Cluster E (POS000008 DevOps)
INSERT INTO experience (idexperience, entreprise, debut, fin, description, etat, idprofil, idposte) VALUES
('EXP000041','CloudMada','2024-09-01','2025-08-31','DevOps Docker / Kubernetes',1,'PRF000050','POS000008'),
('EXP000042','OrangeCloud','2024-09-01','2025-08-31','DevOps CI/CD',1,'PRF000051','POS000008'),
('EXP000043','Axian Cloud','2024-10-01','2025-09-30','DevOps AWS / Terraform',1,'PRF000052','POS000008'),
('EXP000044','SysAdmin Co','2024-09-01','2025-08-31','Linux DevOps',1,'PRF000053','POS000008'),
('EXP000045','GCloud Mada','2024-11-01','2025-10-31','GCP DevOps Engineer',1,'PRF000054','POS000008'),
('EXP000046','DataOps','2024-09-01','2025-08-31','DevOps + Python ML Ops',1,'PRF000055','POS000009'),
('EXP000047','Tsinjo IT','2024-09-01','2025-08-31','DevOps Jenkins',1,'PRF000056','POS000008'),
('EXP000048','Kubernetes Mada','2024-10-01','2025-09-30','Container Orchestration',1,'PRF000057','POS000008'),
('EXP000049','CloudNative','2024-09-01','2025-08-31','Infra as Code Ansible',1,'PRF000058','POS000008'),
('EXP000050','IaaS Mada','2024-11-01','2025-10-31','DevOps Azure',1,'PRF000059','POS000008');

-- =====================================================================
-- MISE A JOUR DES SEQUENCES
-- =====================================================================
SELECT setval('seq_parcours',    10);
SELECT setval('seq_promotion',   15);
SELECT setval('seq_profil',      70);
SELECT setval('seq_poste',       15);
SELECT setval('seq_specialite',  15);
SELECT setval('seq_experience',  60);