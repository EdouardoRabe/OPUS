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
--   Evenement      (TPB000003) : 11 publications
--   Projet         (TPB000004) : 23 publications
--   Recherche d'opportunite (TPB000005) : 9 publications
--   Autre          (TPB000006) : 40 publications
--
-- Novembre 2025 (PUB000011-PUB000050) : 40 publications
-- Decembre 2025 (PUB000051-PUB000075) : 25 publications
-- Janvier 2026  (PUB000076-PUB000097) : 22 publications
-- Fevrier 2026  (PUB000098-PUB000110) : 13 publications

-- ====== NOVEMBRE 2025 ======

INSERT INTO publication VALUES ('PUB000011','2025-11-03','Je viens de terminer mon premier projet Spring Boot avec PostgreSQL en production. Le passage de dev a prod etait stressant mais ca tourne ! Tips pour les prochains : bien parametrer les pool de connexions HikariCP.',1,NULL,'08:14','TPB000004',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000012','2025-11-04','Quelqu''un utilise Hibernate avec des entites complexes et a des problemes de N+1 queries ? J''ai passe 2 jours a deboguer ca chez mon entreprise, finalement resolu avec @BatchSize.',1,NULL,'09:32','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000013','2025-11-05','Je cherche des camarades ayant une experience en Python pour une collaboration sur un projet de classification de texte (NLP). On a deja le dataset, il faut des bras !',1,NULL,'11:00','TPB000005',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000014','2025-11-06','Partage d''experience : premier mois chez Axian Data en tant que Data Scientist. Les donnees reelles sont TRES differentes des datasets propres des cours. Courage a tous !',1,NULL,'14:22','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000015','2025-11-07','Annonce importante : Notre association alumni organise un meetup le 15 novembre a l''ITU. Theme : "Insertion professionnelle en 2025". Inscrivez-vous !',1,NULL,'10:05','TPB000003',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000016','2025-11-08','Conseil a tous les juniors backend : ne pas negliger les index en base de donnees. Sur une table de 2M lignes, une requete passait de 8s a 12ms apres indexation. Les chiffres ne mentent pas.',1,NULL,'16:48','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000017','2025-11-10','Je recrute ! Mon enterprise cherche un stagiaire en reseaux pour 6 mois a Antananarivo. Connaissances Cisco exigees, Fortinet un plus. Envoyez vos CV en MP.',1,NULL,'09:15','TPB000002',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000018','2025-11-11','Retour de la Cisco Networking Academy Conference. Beaucoup de choses sur le SD-WAN et le Zero Trust Network Access. L''avenir des reseaux est clairement software-defined.',1,NULL,'18:30','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000019','2025-11-12','Question pour les devs frontend : est-ce que vous utilisez encore Redux ou vous avez migre vers Zustand/Jotai ? En React Native, Redux me semble un peu overkill maintenant.',1,NULL,'11:45','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000020','2025-11-13','On vient de deployer notre premier pipeline CI/CD avec GitLab sur Docker Swarm. Pour les juniors DevOps : commencez par les fondamentaux Linux avant de sauter sur Kubernetes.',1,NULL,'17:02','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000021','2025-11-14','Votre avis sur l''apprentissage automatique applique a la detectiond''intrusion reseau ? Je prepare un memoire la-dessus et cherche des retours d''experience du terrain.',1,NULL,'13:20','TPB000005',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000022','2025-11-15','Conference alumni ce soir ! Plus de 80 participants inscrits. Pour ceux qui ne peuvent pas venir, on diffuse en live sur le groupe WhatsApp.',1,NULL,'08:00','TPB000003',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000023','2025-11-17','Ressource utile : j''ai compile une liste de repos GitHub incontournables pour apprendre Java avance (Design Patterns, JVM tuning, concurrence). DM pour recevoir le lien.',1,NULL,'10:30','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000024','2025-11-18','Mon premier modele de prediction de prix de l''immobilier a Madagascar est en ligne ! Regression lineaire + featurisation temporelle. Precisiona 78%. Pas parfait mais je suis fier.',1,NULL,'15:55','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000025','2025-11-19','Offre d''emploi : Ingenieur Securite Reseaux chez RiT, CDI. 2 ans d''experience minimum, certification CEH appreciee. Poste base a Tana. Contactez HR.',1,NULL,'09:48','TPB000001',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000026','2025-11-20','Petit flex personnel : j''ai passe ma certification AWS Cloud Practitioner ! Premier pas vers Solutions Architect. Ca vaut le coup d''investir dans les certifs cloud.',1,NULL,'12:10','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000027','2025-11-21','Pour ceux qui utilisent Flutter : comment gerez-vous la gestion d''etat dans des apps complexes ? Riverpod vs Bloc, j''ai du mal a choisir pour mon projet actuel.',1,NULL,'14:40','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000028','2025-11-22','Conseil du jour : si vous travaillez sur des APIs REST, documentez avec Swagger/OpenAPI DES LE DEBUT. Reprendre une doc en retard est une souffrance inutile.',1,NULL,'16:15','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000029','2025-11-24','Stage disponible : 3 mois en Data Science chez Orange Labs Madagascar. Prerequis : Python solide + notions de machine learning. Bac+4/5 requis. Dossier avant le 5 dec.',1,NULL,'11:00','TPB000002',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000030','2025-11-25','Je cherche un associe pour monter une startup autour de la cybersecurite pour les PME malgaches. Si tu as des competences en pentest ou audit securite, ecris-moi.',1,NULL,'19:30','TPB000005',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000031','2025-11-26','Partage de cours : j''ai resume toutes mes notes du cours "Architecture des Reseaux" en 30 pages PDF. Disponible pour les anciens etudiants sur demande.',1,NULL,'10:20','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000032','2025-11-27','Publication de mon article Medium : "Pourquoi TypeScript a change ma vision du developpement JavaScript". 3 mois de pratique intensive, je ne reviendrai plus en arriere.',1,NULL,'13:05','TPB000004',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000033','2025-11-28','Hackathon Alumni ITU annonce ! Theme : "Tech pour le developpement durable a Madagascar". Equipes de 3-5 personnes. Inscriptions du 1 au 15 dec.',1,NULL,'09:00','TPB000003',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000034','2025-11-29','Retour sur 3 mois de Kubernetes en production : ca marche bien mais la courbe d''apprentissage est reelle. Helm charts + ArgoCD = combo gagnant pour nos deploiements.',1,NULL,'17:45','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000035','2025-11-30','Qui utilise deja LangChain en production ici ? Je teste pour un chatbot RAG et j''ai des questions sur la gestion du contexte long pour les PDFs.',1,NULL,'12:22','TPB000006',100) ON CONFLICT DO NOTHING;

INSERT INTO publication VALUES ('PUB000036','2025-11-07','Opportunite : notre equipe cherche un dev React Native pour une app de suivi scolaire. Start-up locale, ambiance startup, salaire competitif. DM si interesse.',1,NULL,'10:00','TPB000001',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000037','2025-11-10','Petit rappel pour tout le monde : verifiez TOUJOURS vos variables d''environnement avant de push sur Git. Un collegue a pousse des credentials AWS ce matin... stressant.',1,NULL,'15:33','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000038','2025-11-12','Je viens de terminer la formation Terraform sur Udemy. L''infrastructure as code c''est vraiment le niveau superieur pour les DevOps. Qui a des projets concrets sur lesquels pratiquer ?',1,NULL,'11:10','TPB000005',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000039','2025-11-15','Offre de stage : 6 mois minimum, developpeur Angular + Spring Boot, societe Groupe SOA. Niveau Bac+3 minimum. Remuneration + transport. Ecrire a stage@groupesoa.mg',1,NULL,'08:50','TPB000002',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000040','2025-11-20','Alerte bonne pratique SQL : utilisez des transactions explicites pour les operations critiques. J''ai eu un bug de donnees corrompues en prod la semaine derniere a cause d''un rollback non gere.',1,NULL,'16:00','TPB000006',102) ON CONFLICT DO NOTHING;

INSERT INTO publication VALUES ('PUB000041','2025-11-05','Les graphes de connaissances et Neo4j : quelqu''un a deja utilise ca pour des recommandations ? Je construis un moteur de recommandation pour une plateforme e-learning locale.',1,NULL,'14:15','TPB000004',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000042','2025-11-09','10 outils que tout ingenieur reseaux devrait maitriser en 2025 : Wireshark, GNS3, Ansible pour les reseaux, PRTG, Zabbix... Je peux faire un post detaille si ca interesse.',1,NULL,'11:30','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000043','2025-11-13','Ecran noir chez mon client : la VLAN mal configuree bloquait tout le trafic inter-services. 4h de debug. Lecon : documenter TOUTE configuration reseau, meme les "petits" changements.',1,NULL,'20:10','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000044','2025-11-17','Je propose des sessions de mentorat gratuites sur Python et Machine Learning pour les etudiants en L3/M1. Une heure par semaine max, sur Discord. Qui est interesse ?',1,NULL,'09:40','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000045','2025-11-21','Annonce : je rejoins Axian Cloud comme DevOps Engineer le mois prochain ! Merci a tous les alumni qui m''ont aide a preparer les entretiens. La communaute ITU est en or.',1,NULL,'18:05','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000046','2025-11-24','Discussion : React vs Vue vs Angular en 2025. Mon equipe veut standardiser. Quel framework recommendez-vous pour de grosses apps d''entreprise ?',1,NULL,'13:55','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000047','2025-11-26','Petit projet perso : j''ai construit un homelab avec Proxmox + pfSense pour m''entrainer. Ca coute pas grand chose et l''apprentissage est immense pour les dbutants en infra.',1,NULL,'21:00','TPB000004',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000048','2025-11-27','Offre d''emploi : Chef de Projet IT chez BNI Madagascar. 3 ans experience IT minimum, PMP appreciee. Envoyer CV + lettre de motivation sur recrutement@bni.mg',1,NULL,'08:30','TPB000001',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000049','2025-11-28','Partage : j''ai publie mon premier package npm (un utilitaire de validation de formulaire). Ca m''a appris enormement sur la gestion de dependances et le versioning semver.',1,NULL,'14:00','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000050','2025-11-30','Retour d''experience : migration d''une app monolithique Java vers microservices. 6 mois de travail, mais les resultats en prod sont spectaculaires niveau scalabilite.',1,NULL,'16:30','TPB000004',100) ON CONFLICT DO NOTHING;

-- ====== DECEMBRE 2025 ======

INSERT INTO publication VALUES ('PUB000051','2025-12-01','Hackathon ITU Alumni : les inscriptions sont ouvertes ! Deja 12 equipes formees en 24h. Place limitee a 25 equipes. Rejoignez-nous sur alumni.itu.mg/hackathon',1,NULL,'08:00','TPB000003',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000052','2025-12-02','Deep Learning vs Machine Learning classique pour la detection d''anomalies reseau : selon mon experience, le ML classique (Isolation Forest) surpasse souvent le DL pour les petits datasets.',1,NULL,'11:20','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000053','2025-12-03','Mise a jour : mon modele NLP pour l''analyse de sentiment en malgache est maintenant a 85% de precision. Dataset fait main, 12.000 tweets. Publication Github bientot.',1,NULL,'15:40','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000054','2025-12-04','Opportunite de stage : 4 mois DevOps chez CloudMada. Stack : AWS + Terraform + Ansible. Rejoignez une equipe jeune et dynamique. Bac+4 minimum.',1,NULL,'09:10','TPB000002',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000055','2025-12-05','Rappel technique du vendredi : en PostgreSQL, `EXPLAIN ANALYZE` est votre meilleur ami pour optimiser les requetes. N''attendez pas que la prod plante pour regarder vos query plans.',1,NULL,'17:00','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000056','2025-12-08','Mon setup homelab DevOps pour 2025 : Proxmox + K3s + ArgoCD + Prometheus/Grafana + MinIO. Tout auto-heberge, ca tourne sur du recyclage de materiel. Partage des configs si besoin.',1,NULL,'10:45','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000057','2025-12-09','Quelqu''un a de l''experience avec Keycloak pour la gestion IAM ? On l''implemente chez un client et la config SSO avec des apps legacy Java est complexe.',1,NULL,'14:30','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000058','2025-12-10','Astuce Angular : utilisez OnPush change detection strategy + async pipe sur vos composants de liste. On a divise par 3 le re-rendering sur notre dashboard.',1,NULL,'11:55','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000059','2025-12-11','Offre : poste d''Architecte Logiciel senior chez Tsinjo Solutions. Maitrise Java, microservices, Docker requis. Experience 5 ans minimum. Salaire tres attractif.',1,NULL,'08:20','TPB000001',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000060','2025-12-12','Retour sur le Hackathon Alumni : notre equipe a remporte le 2eme prix avec un systeme de monitoring de la qualite de l''eau par IoT + IA. Fiers de ce qu''on a accompli ensemble !',1,NULL,'19:15','TPB000003',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000061','2025-12-13','Bonne pratique DevOps : toujours tagger vos images Docker avec un hash de commit, pas juste "latest". On a eu une regression en prod a cause de ca le mois dernier.',1,NULL,'16:20','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000062','2025-12-15','Workshop securite organise par notre association : "Ethical Hacking pour debutants". Samedi 20 dec, campus ITU, 8h-12h. Maximum 30 participants. Inscription requise.',1,NULL,'09:00','TPB000003',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000063','2025-12-16','J''ai migre mon API de REST vers GraphQL cette semaine. Pour des dashboards avec des queries flexibles, la difference de performance cote client est remarkable.',1,NULL,'13:40','TPB000004',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000064','2025-12-17','Qui connait de bons cours en ligne sur Spark et le traitement de donnees distribues ? Je dois monter en competences rapidement pour un projet Big Data chez un operateur telecom.',1,NULL,'11:05','TPB000005',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000065','2025-12-18','Conseil carriere : ne sous-estimez pas l''importance du soft skills en IT. Un techn excellent mais qui communique mal perd souvent face a un collegue plus moyen techniquement mais brillant en reunion.',1,NULL,'15:00','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000066','2025-12-19','Mon premier CTF (Capture The Flag) : classement 47/230. Challenges en cryptographie et reverse engineering. Pour ceux qui veulent commencer : TryHackMe est tres accessible.',1,NULL,'22:05','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000067','2025-12-22','Joyeux fetes a toute la communaute Alumni ITU ! Cette annee a ete riche : certifications, nouvelles embauches, premieres lignes de code en prod. Soyez fiers du chemin parcouru.',1,NULL,'10:00','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000068','2025-12-23','Avant les conges : backup de vos projets persos ! GitHub + disque dur externe. J''ai perdu 3 semaines de travail il y a 2 ans pour ne pas avoir sauvegarde. Ne faites pas la meme erreur.',1,NULL,'08:30','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000069','2025-12-26','Lecture de vacances recommandee : "Designing Data-Intensive Applications" de Kleppmann. Meilleur livre technique que j''ai lu en 2025, applicable tous les jours en prod.',1,NULL,'14:20','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000070','2025-12-27','Projet vacances : j''ai implemente un simple load balancer en Go pour comprendre les internals. Liens inter-cluster et round-robin. Le code est sur mon GitHub si quelqu''un veut etudier.',1,NULL,'16:50','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000071','2025-12-28','Resolutions 2026 : passer AWS SAA, contribuer a 3 repos open source, creer mon premier package Python public. Quelles sont les votres ?',1,NULL,'11:00','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000072','2025-12-29','Off. d''emploi en CDI : Developpeur React.js chez WebMada Madagascar. Junior accepte avec bonne maitrise des hooks et Redux. CV sur jobs@webmada.mg',1,NULL,'09:45','TPB000001',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000073','2025-12-30','Prediction 2026 : l''IA generative va transformer les metiers du developpement mais ne les supprimera pas. Les devs qui sauront prompter et valider le code IA auront un enorme avantage.',1,NULL,'17:30','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000074','2025-12-31','Bilan 2025 : premiere certification obtenue, premier salaire en IT, premiere app deployee en prod. Merci ITU et merci la communaute alumni. Bonne annee 2026 !',1,NULL,'23:30','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000075','2025-12-15','Stage 5 mois en Machine Learning chez TELMA. Travail sur des modeles de churn prediction. Candidature ouverte jusqu''au 22 dec. Niveau M1 requis. Python + sklearn indispensables.',1,NULL,'10:30','TPB000002',100) ON CONFLICT DO NOTHING;

-- ====== JANVIER 2026 ======

INSERT INTO publication VALUES ('PUB000076','2026-01-02','Debut 2026 par une bonne nouvelle : notre POC microservices est valide par la direction. On passe en developpement officiel ! Equipe de 4 cherchee, dont 2 backend Java.',1,NULL,'09:00','TPB000004',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000077','2026-01-05','Apprentissage en cours : Rust. Apres 2 semaines, je comprends enfin pourquoi le borrow checker existe. La memoire sans GC, c''est difficile mais fascinant.',1,NULL,'20:00','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000078','2026-01-07','Question technique : comment gerez-vous les secrets dans vos pipelines CI/CD ? HashiCorp Vault, AWS Secrets Manager, ou juste les env vars du CI ? On cherche la meilleure pratique.',1,NULL,'10:55','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000079','2026-01-08','Offre d''emploi : Data Engineer chez DataMada. Maitrise Python + Spark + Airflow requise. Experience Data Warehouse appreciee. Poste senior, negociation salariale possible.',1,NULL,'08:40','TPB000001',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000080','2026-01-09','Retour d''experience : implmentation d''un systeme de monitoring avec Prometheus + Grafana + AlertManager. Les alertes PagerDuty ont sauve notre nuit 3 fois en 2 semaines.',1,NULL,'15:15','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000081','2026-01-12','Je cherche un expert en optimisation de requetes PostgreSQL pour une consultation de 2-3 jours. Freelance accepte. Base de donnees de 50Go, problemes de performance sur les JOINS complexes.',1,NULL,'11:30','TPB000005',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000082','2026-01-13','Webinaire gratuit organise par l''association alumni : "IA et Machine Learning : quel avenir pour Madagascar ?" - Vendredi 17 janvier, 18h. Lien Zoom en commentaire.',1,NULL,'09:20','TPB000003',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000083','2026-01-14','J''ai fini de construire mon premier homelab SD-WAN avec VyOS + BGP entre 3 sites virtuels. Les concepts de routage dynamique sont clarifies enfin. Tutorial en court d''edition.',1,NULL,'21:40','TPB000004',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000084','2026-01-15','Stage Data Visualisation disponible : 3 mois chez E-Media. Stack : Python + Power BI + SQL. Niveau L3 minimum. Dossier avant le 25 jan. Envoyer sur stage@emedia.mg',1,NULL,'10:00','TPB000002',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000085','2026-01-16','Discussion du jour : vaut-il mieux specialiser ou generaliser en debut de carriere IT ? Mon parcours m''a montre qu''une forte specialisation ouvre plus de portes rapidement.',1,NULL,'14:00','TPB000005',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000086','2026-01-19','Partage technique : j''ai reduit les cold starts de nos Lambda AWS de 3s a 400ms en passant sur des Provisioned Concurrency + SnapStart pour Java. Impact direct sur l''UX.',1,NULL,'17:25','TPB000006',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000087','2026-01-20','Nouvel article sur mon blog : "Comment j''ai construit un pipeline MLOps complet en 30 jours avec des outils open source". MLflow + DVC + FastAPI + Docker. Lien en commentaire.',1,NULL,'12:00','TPB000004',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000088','2026-01-21','Question : quelqu''un a de l''experience avec la migration d''Oracle vers PostgreSQL en production ? On a un schema complexe avec beaucoup de packages PL/SQL a reedcrire.',1,NULL,'09:45','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000089','2026-01-22','Offre d''emploi : Ingenieur DevOps chez OrangeCloud. Kubernetes + Terraform + monitoring. 2 ans d''experience min. Package salarial attractif + teletravail partiel.',1,NULL,'08:00','TPB000001',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000090','2026-01-23','Conseil pour les juniors mobile : avant de plonger dans un framework cross-platform, maitrisez les fondamentaux natifs. Ca rend le debug 10x plus simple quand ca plante.',1,NULL,'16:10','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000091','2026-01-26','Workshop JavaScript avance ce samedi : closures, event loop, prototypes et le modele objet. Campus ITU, 9h-13h. Gratuit pour les membres de l''association alumni.',1,NULL,'10:00','TPB000003',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000092','2026-01-27','Partage : notre equipe a passe de deployments manuels a un pipeline GitOps complet en 6 semaines. Retour en arriere impossible. ArgoCD + Helm + Renovate Bot = chef.',1,NULL,'15:50','TPB000004',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000093','2026-01-28','Recrutement : cherche associe technique pour une startup EdTech focus sur la preparation aux exams universitaires. Vision long terme, participation au capital possible.',1,NULL,'11:15','TPB000005',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000094','2026-01-29','Rapport de bug interessant : une race condition dans mon service de paiement n''apparaissait qu''avec plus de 200 requetes/s simultanees. Trouve grace aux tests de charge JMeter.',1,NULL,'19:00','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000095','2026-01-30','Nouvelle certification obtenue : Certified Kubernetes Administrator (CKA). 3 mois de preparation intensive. Exam tres pratique, pas de QCM. Pour ceux qui visent le cloud natif, ca vaut le coup.',1,NULL,'13:45','TPB000006',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000096','2026-01-21','Stage securite reseau 4 mois chez Cyber Defense. Prerequis : reseaux solides + notions de penetration testing. Niveau M1 ou fin de licence pro. Avant le 30 jan.',1,NULL,'09:30','TPB000002',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000097','2026-01-31','Bilan janvier : 8 alumni ont decroches de nouvelles offres ce mois-ci via notre reseau. Le pouvoir du networking ! Si vous cherchez un poste, postez ici, la communaute joue le jeu.',1,NULL,'18:00','TPB000006',100) ON CONFLICT DO NOTHING;

-- ====== FEVRIER 2026 ======

INSERT INTO publication VALUES ('PUB000098','2026-02-02','J''ai parcouru 50 offres d''emploi IT a Madagascar ce weekend. Constat : 80% demandent Java ou Python, 60% citent Docker/Kubernetes, 40% mentionnent une certification cloud. Orientez votre apprentissage en consequence.',1,NULL,'10:00','TPB000005',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000099','2026-02-03','Webinaire alumni this week : "Construire votre marque personnelle sur LinkedIn". Partage d''experiences de 3 alumni qui ont recu des offres inbound. Mercredi 18h, lien en commentaire.',1,NULL,'09:00','TPB000003',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000100','2026-02-05','Partage d''un repo perso : algorithmes de graphes en Python (BFS, DFS, Dijkstra, A*) avec visualisation interactives en Matplotlib. Utile pour les entretiens techniques.',1,NULL,'14:20','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000101','2026-02-07','Offre d''emploi : Developpeur Full Stack React + Node.js chez Ikalika. Junior a confirme. Remote possible. Envoyer test technique + CV a tech@ikalika.mg',1,NULL,'08:30','TPB000001',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000102','2026-02-10','Je travaille sur une lib Java pour simplifier les appels aux APIs locales malgaches (paiement mobile, operateurs). Qui veut contribuer ou tester ? Alpha prete dans 2 semaines.',1,NULL,'11:00','TPB000004',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000103','2026-02-12','Experience partagee : passer d''un monolith Rails a une archi event-driven avec Kafka. La courbe est raide mais l''observabilite et la resilience valent chaque heure investie.',1,NULL,'16:00','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000104','2026-02-13','Offre de stage urgente : 2 mois, analyse de donnees Python chez Blueline. Objectif : tableau de bord de performance reseau temps reel. Debut mars 2026. Postuler sur linkedin.',1,NULL,'09:15','TPB000002',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000105','2026-02-14','Meetup Valentine Day Alumni : ce soir 18h30 au Cafe de la Gare, networking informel pour tous les alumni tech. N''oubliez pas vos cartes de visite !',1,NULL,'12:00','TPB000003',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000106','2026-02-17','Astuce du lundi : `git bisect` pour trouver le commit exact qui a introduce un bug. Combinee avec des tests unitaires, cette commande vous sauvera des heures.',1,NULL,'08:00','TPB000006',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000107','2026-02-19','Notre premier produit SaaS B2B (gestion RH pour PME) vient de signer son 3eme client. Stack : Spring Boot + React + PostgreSQL + Render.com. La tech malgache avance !',1,NULL,'17:30','TPB000004',102) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000108','2026-02-21','Je prepare un atelier pratique Wireshark : analyse de trafic reseau, detection d anomalies, forensics basique. Niveau intermediaire requis. Qui est interesse ?',1,NULL,'10:40','TPB000003',100) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000109','2026-02-22','Poste a pourvoir : Data Scientist junior chez Mora Tech. Votre mission : ameliorer nos modeles de scoring credit. Python + scikit-learn requis. CDI apres 3 mois essai.',1,NULL,'09:00','TPB000001',101) ON CONFLICT DO NOTHING;
INSERT INTO publication VALUES ('PUB000110','2026-02-24','La plateforme Alumni ITU est maintenant dotee d''un fil d''actualite avec chargement progressif ! Merci a toute l''equipe technique. Continuez a partager vos experiences, votre reseau vous lira.',1,NULL,'11:00','TPB000004',101) ON CONFLICT DO NOTHING;

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

-- ======================== MISE A JOUR SEQUENCES ========================
SELECT setval('seq_publication',     120);
SELECT setval('seq_media',            40);
SELECT setval('seq_typepublication',  10);
