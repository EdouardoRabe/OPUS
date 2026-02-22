-- =====================================================================
-- Donnees de profil Alumni
-- Prerequis: 
--   - 2026-02-22-db-opus.sql (tables alumni)
--   - data/2026-02-22-data-utilisateur.sql (utilisateurs de test)
-- =====================================================================


-- ======================== PARCOURS ========================
INSERT INTO parcours (idparcours, libelle) VALUES ('PRC000001', 'Informatique');


-- ======================== PROMOTION ========================
INSERT INTO promotion (idpromotion, annee, libelle, idparcours) VALUES ('PRM000001', 2024, 'P19', 'PRC000001');

-- ======================== PROFILS ========================
-- Lies aux utilisateurs : refuser 100 (Rakoto Jean), 101 (Rasoa Marie), 102 (Rasolobe Andry)
INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre)
VALUES ('PRF000001', 'rakoto@itu.mg', 'Rakoto', 'Jean', '2000-01-15', '034 00 000 01', 'PRM000001', 'PRC000001', 100, 'GEN000001');

INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre)
VALUES ('PRF000002', 'rasoa@itu.mg', 'Rasoa', 'Marie', '2001-03-20', '034 00 000 02', 'PRM000001', 'PRC000001', 101, 'GEN000002');

INSERT INTO profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre)
VALUES ('PRF000003', 'rasolobe@itu.mg', 'Rasolobe', 'Andry', '1999-06-10', '034 00 000 03', 'PRM000001', 'PRC000001', 102, 'GEN000001');

-- Mettre a jour les sequences
SELECT setval('seq_promotion', 10);
SELECT setval('seq_parcours', 10);
SELECT setval('seq_profil', 10);
