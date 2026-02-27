-- Active: 1736646695640@@127.0.0.1@5432@opus4
-- =====================================================================
-- DONNEES DE TEST - 100 Publications pour le Fil d'Actualite
-- Prerequis:
--   - 2026-02-25-OPUS-COMPLETE.sql (schema + donnees de reference)
-- IDs publications : PUB000011 -> PUB000110
-- Dates couvrent Nov 2025 -> Feb 2026 pour tester la pagination
-- =====================================================================
-- Types de publication disponibles :
--   TPB000001 : Offre d'emploi
--   TPB000002 : Stage
--   TPB000003 : Evenement
--   TPB000004 : Projet         (NOUVEAU)
--   TPB000005 : Recherche d'opportunite (NOUVEAU)
--   TPB000006 : Autre          (NOUVEAU)
-- =====================================================================

-- ======================== UTILISATEURS DE TEST ========================
-- 3 utilisateurs de base (100, 101, 102) pour publier
-- adruser = DIR42 obligatoire (JOIN direction dans utilisateurvue)
-- Mot de passe en clair : "test" -> crypte "paop"
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, adruser, idrole, id, estactif)
VALUES (100, 'ETU000001', 'paop', 'Rakoto Jean', 'DIR42', 'etu', 'ETU000001', 1) ON CONFLICT DO NOTHING;
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, adruser, idrole, id, estactif)
VALUES (101, 'ETU000002', 'paop', 'Rasoa Marie', 'DIR42', 'alu', 'ETU000002', 1) ON CONFLICT DO NOTHING;
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, adruser, idrole, id, estactif)
VALUES (102, 'ETU000003', 'paop', 'Rasolobe Andry', 'DIR42', 'md', 'ETU000003', 1) ON CONFLICT DO NOTHING;

-- Parametres de cryptage (obligatoire pour login)
INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY000100', 4, 1, '100') ON CONFLICT DO NOTHING;
INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY000101', 4, 1, '101') ON CONFLICT DO NOTHING;
INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY000102', 4, 1, '102') ON CONFLICT DO NOTHING;

-- ======================== PROFILS ========================
-- Lies aux utilisateurs : refuser 100 (Rakoto Jean), 101 (Rasoa Marie), 102 (Rasolobe Andry)
-- Prerequis : parcours PRC000001, promotion PRM000001, genre GEN000001/GEN000002 (dans OPUS-COMPLETE.sql)
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre)
VALUES ('PRF000001', 'rakoto@itu.mg', 'Rakoto', 'Jean', '2000-01-15', '034 00 000 01', 'PRM000001', 'PRC000001', 100, 'GEN000001') ON CONFLICT DO NOTHING;
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre)
VALUES ('PRF000002', 'rasoa@itu.mg', 'Rasoa', 'Marie', '2001-03-20', '034 00 000 02', 'PRM000001', 'PRC000001', 101, 'GEN000002') ON CONFLICT DO NOTHING;
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre)
VALUES ('PRF000003', 'rasolobe@itu.mg', 'Rasolobe', 'Andry', '1999-06-10', '034 00 000 03', 'PRM000001', 'PRC000001', 102, 'GEN000001') ON CONFLICT DO NOTHING;

-- ======================== TYPES DE PUBLICATION SUPPLEMENTAIRES ========================
INSERT INTO typepublication (idtypepublication, libelle) VALUES ('TPB000004', 'Projet') ON CONFLICT DO NOTHING;
INSERT INTO typepublication (idtypepublication, libelle) VALUES ('TPB000005', 'Recherche d''opportunite') ON CONFLICT DO NOTHING;
INSERT INTO typepublication (idtypepublication, libelle) VALUES ('TPB000006', 'Autre') ON CONFLICT DO NOTHING;

-- ======================== 100 PUBLICATIONS ========================
-- Repartition thematique :
--   Offre d'emploi (TPB000001) : 9 publications
--   Stage          (TPB000002) : 8 publications
--   Evenement      (TPB000003) : 5 publications (liees a la table evenement)
--   Projet         (TPB000004) : 26 publications
--   Recherche d'opportunite (TPB000005) : 9 publications
--   Autre          (TPB000006) : 47 publications
--
-- Novembre 2025 (PUB000011-PUB000050) : 40 publications
-- Decembre 2025 (PUB000051-PUB000075) : 25 publications
-- Janvier 2026  (PUB000076-PUB000097) : 22 publications
-- Fevrier 2026  (PUB000098-PUB000110) : 13 publications

-- ====== NOVEMBRE 2025 ======

INSERT INTO publication VALUES ('PUB000011','2025-11-03','Premier projet Spring Boot + PostgreSQL en prod ! Tips : bien parametrer HikariCP pour les connexions.',1,NULL,'08:14','TPB000004',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000012','2025-11-04','Problemes de N+1 queries avec Hibernate ? 2 jours de debug, resolu avec @BatchSize. Qui a eu ca aussi ?',1,NULL,'09:32','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000013','2025-11-05','Cherche devs Python pour projet NLP classification de texte. Dataset pret, besoin de collaborateurs !',1,NULL,'11:00','TPB000005',210) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000014','2025-11-06','Premier mois chez Axian Data. Les donnees reelles sont TRES differentes des cours. Courage a tous !',1,NULL,'14:22','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000015','2025-11-07','Annonce importante : Journee d''Integration des nouveaux etudiants le 15 mars 2026 a l''ITU. Activites, jeux et networking au programme. Inscrivez-vous !',1,'EVT000001','10:05','TPB000003',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000016','2025-11-08','Conseil backend : indexez vos tables ! Sur 2M lignes, requete passee de 8s a 12ms. Enorme difference.',1,NULL,'16:48','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000017','2025-11-10','Stage reseaux 6 mois a Tana. Cisco requis, Fortinet un plus. CV en MP !',1,NULL,'09:15','TPB000002',220) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000018','2025-11-11','Retour Cisco Conference : SD-WAN et Zero Trust en force. L''avenir est software-defined !',1,NULL,'18:30','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000019','2025-11-12','Devs frontend : Redux ou Zustand/Jotai ? Redux semble overkill en React Native maintenant.',1,NULL,'11:45','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000020','2025-11-13','Premier pipeline CI/CD GitLab + Docker Swarm deploye ! Juniors : maitrisez Linux avant Kubernetes.',1,NULL,'17:02','TPB000004',240) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000021','2025-11-14','ML pour detection d''intrusion reseau ? Je prepare un memoire, besoin de retours terrain.',1,NULL,'13:20','TPB000005',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000022','2025-11-15','Interprom 2026 : Rencontre interpromotionnelle le 20 avril 2026 ! Anciens et nouveaux alumni, venez echanger sur vos parcours. DJ et buffet inclus.',1,'EVT000002','08:00','TPB000003',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000023','2025-11-17','Liste de repos GitHub pour Java avance : Design Patterns, JVM, concurrence. DM pour le lien !',1,NULL,'10:30','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000024','2025-11-18','Mon premier modele de prediction de prix de l''immobilier a Madagascar est en ligne ! Regression lineaire + featurisation temporelle. Precisiona 78%. Pas parfait mais je suis fier.',1,NULL,'15:55','TPB000004',211) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000025','2025-11-19','CDI Ingenieur Securite Reseaux chez RiT. 2 ans exp min, CEH appreciee. Tana.',1,NULL,'09:48','TPB000001',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000026','2025-11-20','Petit flex personnel : j''ai passe ma certification AWS Cloud Practitioner ! Premier pas vers Solutions Architect. Ca vaut le coup d''investir dans les certifs cloud.',1,NULL,'12:10','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000027','2025-11-21','Flutter : Riverpod vs Bloc pour la gestion d''etat ? J''hesite pour mon projet.',1,NULL,'14:40','TPB000006',232) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000028','2025-11-22','APIs REST : documentez avec Swagger DES LE DEBUT. Reprendre une doc en retard = souffrance.',1,NULL,'16:15','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000029','2025-11-24','Stage 3 mois Data Science chez Orange Labs. Python + ML requis. Bac+4/5. Avant le 5 dec.',1,NULL,'11:00','TPB000002',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000030','2025-11-25','Startup cybersecurite PME : cherche associe avec competences pentest/audit. Ecris-moi !',1,NULL,'19:30','TPB000005',227) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000031','2025-11-26','Notes Architecture Reseaux resumees en 30 pages PDF. Dispo sur demande !',1,NULL,'10:20','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000032','2025-11-27','Article Medium : "Pourquoi TypeScript a change ma vision". 3 mois de pratique, plus de retour !',1,NULL,'13:05','TPB000004',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000033','2025-11-28','Conference DevOps Days Madagascar 2026 le 15 mars ! Speakers internationaux, workshops pratiques. Inscriptions sur devopsdays.mg/madagascar-2026',1,'EVT000003','09:00','TPB000003',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000034','2025-11-29','3 mois de K8s en prod : courbe d''apprentissage reelle. Helm + ArgoCD = combo gagnant.',1,NULL,'17:45','TPB000004',241) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000035','2025-11-30','LangChain en prod pour chatbot RAG ? Questions sur la gestion du contexte long pour PDFs.',1,NULL,'12:22','TPB000006',100) ON CONFLICT DO NOTHING;

INSERT INTO publication VALUES ('PUB000036','2025-11-07','On cherche un dev React Native pour app de suivi scolaire. Startup locale, bon salaire. DM !',1,NULL,'10:00','TPB000001',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000037','2025-11-10','Rappel : verifiez vos .env avant de push ! Un collegue a pousse des credentials AWS ce matin...',1,NULL,'15:33','TPB000006',205) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000038','2025-11-12','Formation Terraform terminee ! L''IaC c''est le niveau superieur. Projets pour pratiquer ?',1,NULL,'11:10','TPB000005',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000039','2025-11-15','Stage 6 mois Angular + Spring Boot chez Groupe SOA. Bac+3 min. stage@groupesoa.mg',1,NULL,'08:50','TPB000002',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000040','2025-11-20','Bonne pratique SQL : transactions explicites pour ops critiques. Bug de rollback non gere en prod...',1,NULL,'16:00','TPB000006',200) ON CONFLICT DO NOTHING;

INSERT INTO publication VALUES ('PUB000041','2025-11-05','Neo4j pour recommandations ? Je construis un moteur pour plateforme e-learning locale.',1,NULL,'14:15','TPB000004',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000042','2025-11-09','10 outils pour ingenieurs reseaux 2025 : Wireshark, GNS3, Ansible, PRTG, Zabbix... Post detaille ?',1,NULL,'11:30','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000043','2025-11-13','VLAN mal configuree = 4h de debug. Lecon : documenter TOUTE config reseau !',1,NULL,'20:10','TPB000006',230) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000044','2025-11-17','Mentorat gratuit Python/ML pour L3/M1. 1h/semaine sur Discord. Interesse ?',1,NULL,'09:40','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000045','2025-11-21','Annonce : je rejoins Axian Cloud comme DevOps Engineer le mois prochain ! Merci a tous les alumni qui m''ont aide a preparer les entretiens. La communaute ITU est en or.',1,NULL,'18:05','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000046','2025-11-24','React vs Vue vs Angular 2025 ? Mon equipe veut standardiser pour grosses apps entreprise.',1,NULL,'13:55','TPB000006',231) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000047','2025-11-26','Homelab Proxmox + pfSense construit. Pas cher et apprentissage immense pour debutants infra !',1,NULL,'21:00','TPB000004',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000048','2025-11-27','CDI Chef de Projet IT chez BNI. 3 ans exp min, PMP appreciee. recrutement@bni.mg',1,NULL,'08:30','TPB000001',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000049','2025-11-28','Premier package npm publie ! Utilitaire de validation formulaire. Apprentissage sur semver enorme.',1,NULL,'14:00','TPB000004',242) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000050','2025-11-30','Migration monolithe Java vers microservices : 6 mois mais scalabilite spectaculaire en prod !',1,NULL,'16:30','TPB000004',100) ON CONFLICT DO NOTHING;

-- ====== DECEMBRE 2025 ======

INSERT INTO publication VALUES ('PUB000051','2025-12-01','Salon des Etudiants Madagascar 2026 le 10 mai ! Stands entreprises, conferences metiers, offres de stage. Entree libre pour tous les etudiants ITU.',1,'EVT000004','08:00','TPB000003',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000052','2025-12-02','Detection anomalies : ML classique (Isolation Forest) surpasse souvent DL pour petits datasets.',1,NULL,'11:20','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000053','2025-12-03','Modele NLP sentiment malgache a 85% precision. 12k tweets. GitHub bientot !',1,NULL,'15:40','TPB000004',212) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000054','2025-12-04','Stage 4 mois DevOps CloudMada. AWS + Terraform + Ansible. Bac+4 min.',1,NULL,'09:10','TPB000002',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000055','2025-12-05','PostgreSQL : EXPLAIN ANALYZE est votre ami. Optimisez avant que la prod plante !',1,NULL,'17:00','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000056','2025-12-08','Mon setup homelab DevOps pour 2025 : Proxmox + K3s + ArgoCD + Prometheus/Grafana + MinIO. Tout auto-heberge, ca tourne sur du recyclage de materiel. Partage des configs si besoin.',1,NULL,'10:45','TPB000004',243) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000057','2025-12-09','Keycloak pour IAM ? Config SSO avec apps legacy Java complexe. Retours ?',1,NULL,'14:30','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000058','2025-12-10','Angular : OnPush + async pipe = re-rendering divise par 3 sur notre dashboard !',1,NULL,'11:55','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000059','2025-12-11','CDI Architecte Logiciel senior Tsinjo Solutions. Java, microservices, Docker. 5 ans exp.',1,NULL,'08:20','TPB000001',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000060','2025-12-12','Hackathon Alumni ITU 2026 le 22 fevrier ! Theme : "Tech pour le developpement durable". Equipes de 3-5 personnes, prix attractifs. Inscrivez-vous maintenant !',1,'EVT000005','19:15','TPB000003',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000061','2025-12-13','DevOps : tagger images Docker avec hash commit, pas "latest". Regression en prod sinon.',1,NULL,'16:20','TPB000006',244) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000062','2025-12-15','Workshop securite organise par notre association : "Ethical Hacking pour debutants". Samedi 20 dec, campus ITU, 8h-12h. Maximum 30 participants. Inscription requise.',1,NULL,'09:00','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000063','2025-12-16','J''ai migre mon API de REST vers GraphQL cette semaine. Pour des dashboards avec des queries flexibles, la difference de performance cote client est remarkable.',1,NULL,'13:40','TPB000004',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000064','2025-12-17','Bons cours en ligne Spark/Big Data ? Projet chez operateur telecom, besoin de monter vite.',1,NULL,'11:05','TPB000005',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000065','2025-12-18','Conseil : soft skills importants en IT ! Tech moyen + bonne comm bat souvent tech excellent seul.',1,NULL,'15:00','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000066','2025-12-19','Mon premier CTF (Capture The Flag) : classement 47/230. Challenges en cryptographie et reverse engineering. Pour ceux qui veulent commencer : TryHackMe est tres accessible.',1,NULL,'22:05','TPB000006',228) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000067','2025-12-22','Joyeux fetes a toute la communaute Alumni ITU ! Cette annee a ete riche : certifications, nouvelles embauches, premieres lignes de code en prod. Soyez fiers du chemin parcouru.',1,NULL,'10:00','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000068','2025-12-23','Backup avant conges ! GitHub + disque externe. J''ai perdu 3 semaines de travail y a 2 ans.',1,NULL,'08:30','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000069','2025-12-26','Lecture : "Designing Data-Intensive Applications" Kleppmann. Meilleur livre tech 2025.',1,NULL,'14:20','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000070','2025-12-27','Projet vacances : j''ai implemente un simple load balancer en Go pour comprendre les internals. Liens inter-cluster et round-robin. Le code est sur mon GitHub si quelqu''un veut etudier.',1,NULL,'16:50','TPB000004',245) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000071','2025-12-28','Resolutions 2026 : AWS SAA, 3 contribs open source, package Python public. Et vous ?',1,NULL,'11:00','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000072','2025-12-29','CDI Dev React.js WebMada. Junior accepte avec hooks/Redux. jobs@webmada.mg',1,NULL,'09:45','TPB000001',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000073','2025-12-30','Prediction 2026 : IA generative transformera le dev mais ne le supprimera pas. Prompters avantages !',1,NULL,'17:30','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000074','2025-12-31','Bilan 2025 : premiere certification obtenue, premier salaire en IT, premiere app deployee en prod. Merci ITU et merci la communaute alumni. Bonne annee 2026 !',1,NULL,'23:30','TPB000006',215) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000075','2025-12-15','Stage 5 mois ML chez TELMA. Churn prediction. M1 requis, Python + sklearn. Avant 22 dec.',1,NULL,'10:30','TPB000002',100) ON CONFLICT DO NOTHING;

-- ====== JANVIER 2026 ======

INSERT INTO publication VALUES ('PUB000076','2026-01-02','POC microservices valide ! On passe en dev officiel. Equipe de 4 cherchee, 2 backend Java.',1,NULL,'09:00','TPB000004',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000077','2026-01-05','Apprentissage Rust : 2 semaines, borrow checker compris. Memoire sans GC = fascinant.',1,NULL,'20:00','TPB000006',203) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000078','2026-01-07','Secrets en CI/CD : Vault, AWS Secrets Manager ou env vars ? Meilleure pratique ?',1,NULL,'10:55','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000079','2026-01-08','CDI Data Engineer DataMada. Python + Spark + Airflow. Poste senior.',1,NULL,'08:40','TPB000001',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000080','2026-01-09','Retour d''experience : implmentation d''un systeme de monitoring avec Prometheus + Grafana + AlertManager. Les alertes PagerDuty ont sauve notre nuit 3 fois en 2 semaines.',1,NULL,'15:15','TPB000004',246) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000081','2026-01-12','Cherche expert PostgreSQL pour consult 2-3 jours. BDD 50Go, perf JOINS complexes.',1,NULL,'11:30','TPB000005',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000082','2026-01-13','Webinaire gratuit : "IA et ML : avenir pour Madagascar ?" Vendredi 17 jan, 18h.',1,NULL,'09:20','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000083','2026-01-14','Homelab SD-WAN avec VyOS + BGP entre 3 sites virtuels. Tutorial en cours !',1,NULL,'21:40','TPB000004',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000084','2026-01-15','Stage 3 mois Data Viz E-Media. Python + Power BI + SQL. L3 min. stage@emedia.mg',1,NULL,'10:00','TPB000002',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000085','2026-01-16','Specialiser ou generaliser en debut de carriere IT ? Specialisation ouvre plus de portes.',1,NULL,'14:00','TPB000005',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000086','2026-01-19','Lambda AWS : cold starts de 3s a 400ms avec Provisioned Concurrency + SnapStart Java !',1,NULL,'17:25','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000087','2026-01-20','Nouvel article sur mon blog : "Comment j''ai construit un pipeline MLOps complet en 30 jours avec des outils open source". MLflow + DVC + FastAPI + Docker. Lien en commentaire.',1,NULL,'12:00','TPB000004',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000088','2026-01-21','Migration Oracle vers PostgreSQL en prod ? Schema complexe, packages PL/SQL a reecrire.',1,NULL,'09:45','TPB000006',201) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000089','2026-01-22','CDI Ingenieur DevOps OrangeCloud. K8s + Terraform. 2 ans min. Teletravail partiel.',1,NULL,'08:00','TPB000001',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000090','2026-01-23','Juniors mobile : maitrisez les fondamentaux natifs avant cross-platform. Debug 10x plus simple.',1,NULL,'16:10','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000091','2026-01-26','Workshop JavaScript avance ce samedi : closures, event loop, prototypes et le modele objet. Campus ITU, 9h-13h. Gratuit pour les membres de l''association alumni.',1,NULL,'10:00','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000092','2026-01-27','Partage : notre equipe a passe de deployments manuels a un pipeline GitOps complet en 6 semaines. Retour en arriere impossible. ArgoCD + Helm + Renovate Bot = chef.',1,NULL,'15:50','TPB000004',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000093','2026-01-28','Recrutement : cherche associe technique pour une startup EdTech focus sur la preparation aux exams universitaires. Vision long terme, participation au capital possible.',1,NULL,'11:15','TPB000005',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000094','2026-01-29','Race condition paiement a 200 req/s. Trouve grace aux tests JMeter !',1,NULL,'19:00','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000095','2026-01-30','Nouvelle certification obtenue : Certified Kubernetes Administrator (CKA). 3 mois de preparation intensive. Exam tres pratique, pas de QCM. Pour ceux qui visent le cloud natif, ca vaut le coup.',1,NULL,'13:45','TPB000006',247) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000096','2026-01-21','Stage securite reseau 4 mois Cyber Defense. Reseaux + pentest. M1 ou licence pro.',1,NULL,'09:30','TPB000002',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000097','2026-01-31','Bilan janvier : 8 alumni ont decroche de nouvelles offres via notre reseau. Networking !',1,NULL,'18:00','TPB000006',100) ON CONFLICT DO NOTHING;

-- ====== FEVRIER 2026 ======

INSERT INTO publication VALUES ('PUB000098','2026-02-02','50 offres IT analysees : 80% Java/Python, 60% Docker/K8s, 40% certif cloud. Orientez-vous !',1,NULL,'10:00','TPB000005',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000099','2026-02-03','Webinaire : "Marque personnelle LinkedIn". 3 alumni partagent leurs exp. Mercredi 18h.',1,NULL,'09:00','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000100','2026-02-05','Repo perso : algos de graphes Python (BFS, DFS, Dijkstra, A*) avec visu Matplotlib.',1,NULL,'14:20','TPB000004',213) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000101','2026-02-07','CDI Full Stack React + Node.js Ikalika. Junior ok. Remote possible. tech@ikalika.mg',1,NULL,'08:30','TPB000001',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000102','2026-02-10','Lib Java pour APIs malgaches (paiement mobile, operateurs). Alpha dans 2 semaines !',1,NULL,'11:00','TPB000004',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000103','2026-02-12','Migration Rails vers event-driven Kafka. Courbe raide mais observabilite top !',1,NULL,'16:00','TPB000004',248) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000104','2026-02-13','Stage urgent 2 mois analyse donnees Blueline. Dashboard perf reseau. Debut mars.',1,NULL,'09:15','TPB000002',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000105','2026-02-14','Meetup Valentine Alumni ce soir 18h30 Cafe de la Gare. Networking informel !',1,NULL,'12:00','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000106','2026-02-17','Astuce : git bisect pour trouver le commit qui a introduit un bug. Combine avec tests = top.',1,NULL,'08:00','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000107','2026-02-19','SaaS RH pour PME : 3eme client signe ! Spring Boot + React + PostgreSQL. Ca avance !',1,NULL,'17:30','TPB000004',249) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000108','2026-02-21','Atelier Wireshark : analyse trafic, detection anomalies, forensics. Niveau intermed. Interesse ?',1,NULL,'10:40','TPB000004',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000109','2026-02-22','CDI Data Scientist junior Mora Tech. Scoring credit. Python + sklearn. CDI apres essai.',1,NULL,'09:00','TPB000001',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000110','2026-02-24','Plateforme Alumni ITU avec fil d''actualite progressif ! Merci l''equipe technique.',1,NULL,'11:00','TPB000004',101) ON CONFLICT DO NOTHING;

INSERT INTO publication VALUES ('PUB000111','2026-02-25','CDI Backend Java TechMada. 3 ans exp. Spring Boot, PostgreSQL, Docker. recrutement@techmada.mg',1,NULL,'09:30','TPB000001',100) ON CONFLICT DO NOTHING;

INSERT INTO publication VALUES ('PUB000112','2026-02-26','Workshop DevOps reussi ! 50+ participants. Slides sur notre GitHub. Merci a tous !',1,NULL,'14:00','TPB000004',101) ON CONFLICT DO NOTHING;

INSERT INTO publication VALUES ('PUB000113','2026-02-26','Projet open source : API REST microservices + monitoring. github.com/rasolobe-andry',1,NULL,'16:45','TPB000004',102) ON CONFLICT DO NOTHING;

INSERT INTO publication VALUES ('PUB000114','2026-02-27','Stage 6 mois IA AILab Madagascar. Vision par ordinateur agriculture. Python, TensorFlow/PyTorch.',1,NULL,'10:15','TPB000002',100) ON CONFLICT DO NOTHING;

-- ======================== MEDIAS (images pour ~25 publications) ========================
-- seq_media demarre a 10 (defini dans 2026-02-23-data-publication.sql)
-- MDA000011 -> MDA000035 utilises ici
-- Images via picsum.photos (seed = numero unique pour varier les visuels)

-- PUB000015 - Meetup alumni : banniere evenement
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000011','https://picsum.photos/seed/meetup15/800/400','MDT000001','PUB000015') ON CONFLICT DO NOTHING;

-- PUB000022 - Conference alumni en direct
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000012','https://picsum.photos/seed/conf22/800/450','MDT000001','PUB000022') ON CONFLICT DO NOTHING;

-- PUB000024 - Modele ML immobilier : capture de courbe de regression
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000013','https://picsum.photos/seed/ml24/700/400','MDT000001','PUB000024') ON CONFLICT DO NOTHING;

-- PUB000026 - Certification AWS Cloud Practitioner : badge/screenshot
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000014','https://picsum.photos/seed/aws26/600/400','MDT000001','PUB000026') ON CONFLICT DO NOTHING;

-- PUB000033 - Hackathon Alumni : affiche officielle
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000015','https://picsum.photos/seed/hack33/800/500','MDT000001','PUB000033') ON CONFLICT DO NOTHING;

-- PUB000045 - Annonce nouveau poste chez Axian Cloud
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000016','https://picsum.photos/seed/job45/700/400','MDT000001','PUB000045') ON CONFLICT DO NOTHING;

-- PUB000051 - Hackathon : ouverture des inscriptions (12 equipes)
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000017','https://picsum.photos/seed/hack51/800/450','MDT000001','PUB000051') ON CONFLICT DO NOTHING;

-- PUB000056 - Setup homelab DevOps : screenshot du dashboard Proxmox/Grafana
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000018','https://picsum.photos/seed/lab56/800/500','MDT000001','PUB000056') ON CONFLICT DO NOTHING;

-- PUB000060 - Resultat hackathon : photo equipe 2eme prix
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000019','https://picsum.photos/seed/team60/800/500','MDT000001','PUB000060') ON CONFLICT DO NOTHING;

-- PUB000062 - Workshop Ethical Hacking : affiche
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000020','https://picsum.photos/seed/sec62/700/400','MDT000001','PUB000062') ON CONFLICT DO NOTHING;

-- PUB000066 - CTF : screenshot classement
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000021','https://picsum.photos/seed/ctf66/700/450','MDT000001','PUB000066') ON CONFLICT DO NOTHING;

-- PUB000067 - Voeux de fin d'annee
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000022','https://picsum.photos/seed/xmas67/800/400','MDT000001','PUB000067') ON CONFLICT DO NOTHING;

-- PUB000070 - Code load balancer Go : screenshot repo GitHub
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000023','https://picsum.photos/seed/git70/700/400','MDT000001','PUB000070') ON CONFLICT DO NOTHING;

-- PUB000074 - Bilan 2025 : photo diplome / premier job
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000024','https://picsum.photos/seed/year74/800/500','MDT000001','PUB000074') ON CONFLICT DO NOTHING;

-- PUB000080 - Dashboard Prometheus + Grafana : screenshot monitoring
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000025','https://picsum.photos/seed/graf80/800/450','MDT000001','PUB000080') ON CONFLICT DO NOTHING;

-- PUB000082 - Webinaire IA & Madagascar : banniere
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000026','https://picsum.photos/seed/web82/800/400','MDT000001','PUB000082') ON CONFLICT DO NOTHING;

-- PUB000087 - Article MLOps blog : image couverture
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000027','https://picsum.photos/seed/mlops87/800/450','MDT000001','PUB000087') ON CONFLICT DO NOTHING;

-- PUB000091 - Workshop JavaScript avance : affiche
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000028','https://picsum.photos/seed/js91/700/400','MDT000001','PUB000091') ON CONFLICT DO NOTHING;

-- PUB000095 - Certification CKA : badge screenshot
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000029','https://picsum.photos/seed/cka95/600/400','MDT000001','PUB000095') ON CONFLICT DO NOTHING;

-- PUB000097 - Bilan janvier alumni : infographie
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000030','https://picsum.photos/seed/jan97/800/400','MDT000001','PUB000097') ON CONFLICT DO NOTHING;

-- PUB000099 - Webinaire LinkedIn branding : banniere
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000031','https://picsum.photos/seed/li99/800/400','MDT000001','PUB000099') ON CONFLICT DO NOTHING;

-- PUB000105 - Meetup Saint-Valentin : photo lieu / affiche
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000032','https://picsum.photos/seed/vday105/700/450','MDT000001','PUB000105') ON CONFLICT DO NOTHING;

-- PUB000107 - SaaS RH : screenshot de l'application
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000033','https://picsum.photos/seed/saas107/800/500','MDT000001','PUB000107') ON CONFLICT DO NOTHING;

-- PUB000108 - Atelier Wireshark : affiche / capture reseau
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000034','https://picsum.photos/seed/wire108/700/400','MDT000001','PUB000108') ON CONFLICT DO NOTHING;

-- PUB000110 - Lancement fil d'actualite plateforme : screenshot
INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication) VALUES ('MDA000035','https://picsum.photos/seed/launch110/800/450','MDT000001','PUB000110') ON CONFLICT DO NOTHING;

-- ======================== EVENEMENTS (5 evenements) ========================
-- Seul l'utilisateur 102 (role 'md') peut creer des evenements
-- Structure: idevenement, description, daty, datefin, datedebut, idutilisateur

-- EVT000001 : Integration des nouveaux etudiants
INSERT INTO evenement (idevenement, description, daty, datefin, datedebut, idutilisateur) VALUES
('EVT000001', 'Journee d''Integration des nouveaux etudiants ITU 2026. Activites ludiques, presentations des associations, jeux et networking. Bienvenue aux nouveaux !', '2025-11-07', '2026-03-15', '2026-03-15', 102) ON CONFLICT DO NOTHING;

-- EVT000002 : Interprom (rencontre interpromotionnelle)
INSERT INTO evenement (idevenement, description, daty, datefin, datedebut, idutilisateur) VALUES
('EVT000002', 'Interprom 2026 : Grande rencontre interpromotionnelle des alumni ITU. Echanges, temoignages, DJ et buffet. Retrouvez vos anciens camarades et rencontrez les nouvelles promotions !', '2025-11-15', '2026-04-20', '2026-04-20', 102) ON CONFLICT DO NOTHING;

-- EVT000003 : Conference DevOps Days Madagascar
INSERT INTO evenement (idevenement, description, daty, datefin, datedebut, idutilisateur) VALUES
('EVT000003', 'DevOps Days Madagascar 2026 : Conference internationale sur les pratiques DevOps. Speakers internationaux, workshops pratiques Kubernetes/Docker, networking. Places limitees a 200 participants.', '2025-11-28', '2026-03-15', '2026-03-15', 102) ON CONFLICT DO NOTHING;

-- EVT000004 : Salon des Etudiants
INSERT INTO evenement (idevenement, description, daty, datefin, datedebut, idutilisateur) VALUES
('EVT000004', 'Salon des Etudiants Madagascar 2026 : Plus de 50 entreprises presentes, conferences metiers, offres de stage et d''emploi. Entree libre pour tous les etudiants et alumni ITU.', '2025-12-01', '2026-05-10', '2026-05-10', 102) ON CONFLICT DO NOTHING;

-- EVT000005 : Hackathon Alumni ITU
INSERT INTO evenement (idevenement, description, daty, datefin, datedebut, idutilisateur) VALUES
('EVT000005', 'Hackathon Alumni ITU 2026 : Theme "Tech pour le developpement durable a Madagascar". Equipes de 3-5 personnes, 48h de code intensif, prix attractifs et visibilite aupres des recruteurs.', '2025-12-12', '2026-02-23', '2026-02-22', 102) ON CONFLICT DO NOTHING;

-- ======================== MISE A JOUR SEQUENCES ========================
SELECT setval('seq_publication',     124);
SELECT setval('seq_media',            40);
SELECT setval('seq_typepublication',  10);
SELECT setval('seq_evenement',         5);
