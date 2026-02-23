-- =====================================================================
-- Donnees de reference pour le module Publication Alumni
-- Prerequis: 
--   - 2026-02-22-db-opus.sql (tables alumni)
--   - 2026-02-22-db-sequences.sql (sequences)
--   - data/2026-02-22-data-utilisateur.sql (utilisateurs de test)
-- =====================================================================

-- ======================== TYPES DE PUBLICATION ========================
INSERT INTO typepublication (idtypepublication, libelle) VALUES ('TPB000001', 'Offre d''emploi');
INSERT INTO typepublication (idtypepublication, libelle) VALUES ('TPB000002', 'Stage');

-- ======================== TYPES DE MEDIA ========================
INSERT INTO mediatype (idmediatype, libelle) VALUES ('MDT000001', 'Image');
INSERT INTO mediatype (idmediatype, libelle) VALUES ('MDT000002', 'Video');

-- ======================== TYPES DE REACTION ========================
INSERT INTO reactiontype (idreactiontype, libelle) VALUES ('RCT000001', 'Like');
INSERT INTO reactiontype (idreactiontype, libelle) VALUES ('RCT000002', 'Love');
INSERT INTO reactiontype (idreactiontype, libelle) VALUES ('RCT000003', 'Haha');
INSERT INTO reactiontype (idreactiontype, libelle) VALUES ('RCT000004', 'Wow');
INSERT INTO reactiontype (idreactiontype, libelle) VALUES ('RCT000005', 'Triste');
INSERT INTO reactiontype (idreactiontype, libelle) VALUES ('RCT000006', 'Enerve');

-- ======================== PUBLICATIONS DE TEST ========================
INSERT INTO publication (idpublication, daty, descritpion, etat, idorigine, heure, idtypepublication, idutilisateur)
VALUES ('PUB000001', '2026-02-22', 'Bienvenue sur la plateforme Alumni ITU ! Content de retrouver tout le monde ici.', 1, NULL, '10:30', 'TPB000001', 100);

INSERT INTO publication (idpublication, daty, descritpion, etat, idorigine, heure, idtypepublication, idutilisateur)
VALUES ('PUB000002', '2026-02-22', 'Quelqu''un a des nouvelles du projet de fin d''etude en IA ? Je cherche des partenaires.', 1, NULL, '11:45', 'TPB000001', 101);

INSERT INTO publication (idpublication, daty, descritpion, etat, idorigine, heure, idtypepublication, idutilisateur)
VALUES ('PUB000003', '2026-02-22', 'Photo souvenir de la remise de diplomes 2024 !', 1, NULL, '14:00', 'TPB000001', 102);

INSERT INTO media (idmedia, mediaurl, idmediatype, idpublication)
VALUES ('MDA000001', 'https://picsum.photos/600/400', 'MDT000001', 'PUB000003');

-- ======================== REACTIONS DE TEST ========================
INSERT INTO publicationreaction (idpublicationreaction, idreactiontype, idutilisateur, idpublication)
VALUES ('PRE000001', 'RCT000001', 101, 'PUB000001');

INSERT INTO publicationreaction (idpublicationreaction, idreactiontype, idutilisateur, idpublication)
VALUES ('PRE000002', 'RCT000002', 102, 'PUB000001');

INSERT INTO publicationreaction (idpublicationreaction, idreactiontype, idutilisateur, idpublication)
VALUES ('PRE000003', 'RCT000001', 100, 'PUB000002');

-- ======================== COMMENTAIRES DE TEST ========================
INSERT INTO publicationcommentaire (idpublicationcommentaire, description, etat, idutilisateur, idpublicationcommentaire_1, idpublication)
VALUES ('PCM000001', 'Super initiative ! Bienvenue a tous.', 1, 101, NULL, 'PUB000001');

INSERT INTO publicationcommentaire (idpublicationcommentaire, description, etat, idutilisateur, idpublicationcommentaire_1, idpublication)
VALUES ('PCM000002', 'Merci Rasoa !', 1, 100, 'PCM000001', 'PUB000001');

INSERT INTO publicationcommentaire (idpublicationcommentaire, description, etat, idutilisateur, idpublicationcommentaire_1, idpublication)
VALUES ('PCM000003', 'Je suis interesse par le projet IA, on en parle ?', 1, 102, NULL, 'PUB000002');

-- ======================== REACTIONS SUR COMMENTAIRES ========================
INSERT INTO commentairereaction (idcommentairereaction, idutilisateur, idpublicationcommentaire, idreactiontype)
VALUES ('CRE000001', 100, 'PCM000001', 'RCT000001');

-- Mettre a jour les sequences pour eviter les conflits
SELECT setval('seq_publication', 10);
SELECT setval('seq_media', 10);
SELECT setval('seq_publicationreaction', 10);
SELECT setval('seq_publicationcommentaire', 10);
SELECT setval('seq_commentairereaction', 10);
SELECT setval('seq_reactiontype', 10);
SELECT setval('seq_typepublication', 10);
SELECT setval('seq_mediatype', 10);
