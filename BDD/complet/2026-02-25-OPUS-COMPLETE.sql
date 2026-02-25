-- ═══════════════════════════════════════════════════════════════════════════════
-- SCRIPT COMPLET OPUS ALUMNI
-- Date: 2026-02-25
-- Note: Les tables 'utilisateur' et 'role' existent dejà dans la base
-- ═══════════════════════════════════════════════════════════════════════════════
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 1: TABLES DE BASE (sans FK vers utilisateur)                          ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE TABLE poste(
    idposte VARCHAR(20),
    libelle VARCHAR(150) NOT NULL,
    PRIMARY KEY(idposte)
);
CREATE TABLE parcours(
    idparcours VARCHAR(20),
    libelle VARCHAR(250) NOT NULL,
    PRIMARY KEY(idparcours)
);
CREATE TABLE specialite(
    idspecialite VARCHAR(20),
    libelle VARCHAR(250) NOT NULL,
    photo VARCHAR(500),
    description TEXT,
    PRIMARY KEY(idspecialite)
);
CREATE TABLE diplome(
    iddiplome VARCHAR(20),
    libelle VARCHAR(250) NOT NULL,
    PRIMARY KEY(iddiplome)
);
CREATE TABLE option(
    idoption VARCHAR(50),
    libelle VARCHAR(250) NOT NULL,
    PRIMARY KEY(idoption)
);
CREATE TABLE mediatype(
    idmediatype VARCHAR(20),
    libelle VARCHAR(50) NOT NULL,
    PRIMARY KEY(idmediatype)
);
CREATE TABLE typepublication(
    idtypepublication VARCHAR(20),
    libelle VARCHAR(250) NOT NULL,
    PRIMARY KEY(idtypepublication)
);
CREATE TABLE reactiontype(
    idreactiontype VARCHAR(50),
    libelle VARCHAR(50) NOT NULL,
    PRIMARY KEY(idreactiontype)
);
CREATE TABLE typesignalement(
    idtypesignalement VARCHAR(20),
    libelle VARCHAR(150) NOT NULL,
    PRIMARY KEY(idtypesignalement)
);
CREATE TABLE genre(
    idgenre VARCHAR(20),
    libelle VARCHAR(50),
    PRIMARY KEY (idgenre)
);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 2: TABLES AVEC FK VERS parcours                                       ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE TABLE promotion(
    idpromotion VARCHAR(20),
    annee INTEGER NOT NULL,
    libelle VARCHAR(50) NOT NULL,
    idparcours VARCHAR(20) NOT NULL,
    PRIMARY KEY(idpromotion),
    FOREIGN KEY(idparcours) REFERENCES parcours(idparcours)
);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 3: TABLE PROFIL (avec FK utilisateur, promotion, parcours, genre)     ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE TABLE profil(
    idprofil VARCHAR(20),
    email VARCHAR(250),
    nom VARCHAR(450) NOT NULL,
    prenom VARCHAR(450) NOT NULL,
    dtn DATE NOT NULL,
    telephone VARCHAR(250) NOT NULL,
    idpromotion VARCHAR(20) NOT NULL,
    idparcours VARCHAR(20) NOT NULL,
    idutilisateur INTEGER NOT NULL,
    idgenre VARCHAR(20) NOT NULL,
    PRIMARY KEY(idprofil),
    UNIQUE(idutilisateur),
    UNIQUE(email),
    FOREIGN KEY(idpromotion) REFERENCES promotion(idpromotion),
    FOREIGN KEY(idparcours) REFERENCES parcours(idparcours),
    FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
    FOREIGN KEY(idgenre) REFERENCES genre(idgenre)
);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 4: TABLES DÉPENDANT DE PROFIL                                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE TABLE visibilite(
    idvisibilite VARCHAR(20),
    champvisibilite VARCHAR(50) NOT NULL,
    status INTEGER NOT NULL,
    daty DATE,
    idprofil VARCHAR(20) NOT NULL,
    PRIMARY KEY(idvisibilite),
    FOREIGN KEY(idprofil) REFERENCES profil(idprofil)
);
CREATE TABLE experience(
    idexperience VARCHAR(20),
    entreprise VARCHAR(500) NOT NULL,
    debut DATE NOT NULL,
    fin DATE NOT NULL,
    description TEXT,
    etat INTEGER NOT NULL,
    idprofil VARCHAR(20) NOT NULL,
    idposte VARCHAR(20) NOT NULL,
    PRIMARY KEY(idexperience),
    FOREIGN KEY(idprofil) REFERENCES profil(idprofil),
    FOREIGN KEY(idposte) REFERENCES poste(idposte)
);
CREATE TABLE specialiteprofil(
    idspecialite VARCHAR(20),
    idprofil VARCHAR(20),
    specialiteprofil VARCHAR(20),
    etat INTEGER NOT NULL,
    niveau INTEGER NOT NULL,
    PRIMARY KEY(idspecialite, idprofil, specialiteprofil),
    FOREIGN KEY(idspecialite) REFERENCES specialite(idspecialite),
    FOREIGN KEY(idprofil) REFERENCES profil(idprofil)
);
CREATE TABLE profildiplome(
    idoption VARCHAR(50),
    idprofil VARCHAR(20),
    idprofildiplome VARCHAR(20),
    etat INTEGER NOT NULL,
    iddiplome VARCHAR(20) NOT NULL,
    PRIMARY KEY(idoption, idprofil, idprofildiplome),
    FOREIGN KEY(idoption) REFERENCES option(idoption),
    FOREIGN KEY(idprofil) REFERENCES profil(idprofil),
    FOREIGN KEY(iddiplome) REFERENCES diplome(iddiplome)
);
CREATE TABLE photo(
    idphoto VARCHAR(20),
    image TEXT NOT NULL,
    type INTEGER NOT NULL,
    daty DATE NOT NULL,
    heure VARCHAR(50) NOT NULL,
    idprofil VARCHAR(20) NOT NULL,
    PRIMARY KEY(idphoto),
    FOREIGN KEY(idprofil) REFERENCES profil(idprofil)
);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 5: TABLES DÉPENDANT DE UTILISATEUR (sans profil)                      ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE TABLE utilisateurhistoetat(
    idutilisateurhistoetat VARCHAR(20),
    daty DATE NOT NULL,
    etat INTEGER NOT NULL,
    remarque VARCHAR(250) NOT NULL,
    idutilisateur INTEGER NOT NULL,
    PRIMARY KEY(idutilisateurhistoetat),
    FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser)
);
CREATE TABLE notification(
    idnotification VARCHAR(20),
    objet VARCHAR(250) NOT NULL,
    daty DATE NOT NULL,
    idorigine VARCHAR(50),
    lien TEXT,
    etat INTEGER NOT NULL,
    heure VARCHAR(50) NOT NULL,
    typenotif VARCHAR(50),
    idutilisateur INTEGER NOT NULL,
    PRIMARY KEY(idnotification),
    FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser)
);
CREATE TABLE evenement(
    idevenement VARCHAR(20),
    description TEXT,
    daty DATE NOT NULL,
    datefin DATE,
    datedebut DATE NOT NULL,
    idutilisateur INTEGER NOT NULL,
    PRIMARY KEY(idevenement),
    FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser)
);
CREATE TABLE historiqueactif(
    id VARCHAR(250) NOT NULL,
    idutilisateur VARCHAR(250),
    estactif INTEGER,
    daty TIMESTAMP WITHOUT TIME ZONE,
    description VARCHAR(250),
    PRIMARY KEY(id)
);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 6: TABLE PUBLICATION ET DÉPENDANCES                                   ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE TABLE publication(
    idpublication VARCHAR(20),
    daty DATE NOT NULL,
    descritpion TEXT,
    etat INTEGER NOT NULL,
    idorigine VARCHAR(50),
    heure VARCHAR(50) NOT NULL,
    idtypepublication VARCHAR(20) NOT NULL,
    idutilisateur INTEGER NOT NULL,
    logique_visibilite VARCHAR(3) DEFAULT 'OR',
    idpuborigine VARCHAR(20) DEFAULT NULL,
    PRIMARY KEY(idpublication),
    FOREIGN KEY(idtypepublication) REFERENCES typepublication(idtypepublication),
    FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
    FOREIGN KEY(idpuborigine) REFERENCES publication(idpublication) ON DELETE
    SET NULL
);
CREATE TABLE media(
    idmedia VARCHAR(20),
    mediaurl TEXT NOT NULL,
    idmediatype VARCHAR(20) NOT NULL,
    idpublication VARCHAR(20) NOT NULL,
    PRIMARY KEY(idmedia),
    FOREIGN KEY(idmediatype) REFERENCES mediatype(idmediatype),
    FOREIGN KEY(idpublication) REFERENCES publication(idpublication)
);
CREATE TABLE identification(
    ididentification VARCHAR(20),
    idutilisateur INTEGER NOT NULL,
    idpublication VARCHAR(20) NOT NULL,
    PRIMARY KEY(ididentification),
    FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
    FOREIGN KEY(idpublication) REFERENCES publication(idpublication)
);
CREATE TABLE publicationreaction(
    idpublicationreaction VARCHAR(20),
    idreactiontype VARCHAR(50) NOT NULL,
    idutilisateur INTEGER NOT NULL,
    idpublication VARCHAR(20) NOT NULL,
    PRIMARY KEY(idpublicationreaction),
    FOREIGN KEY(idreactiontype) REFERENCES reactiontype(idreactiontype),
    FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
    FOREIGN KEY(idpublication) REFERENCES publication(idpublication)
);
CREATE TABLE publicationcommentaire(
    idpublicationcommentaire VARCHAR(20),
    description VARCHAR(250) NOT NULL,
    etat INTEGER NOT NULL,
    idutilisateur INTEGER NOT NULL,
    idpublicationcommentaire_1 VARCHAR(20),
    idpublication VARCHAR(20) NOT NULL,
    PRIMARY KEY(idpublicationcommentaire),
    FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
    FOREIGN KEY(idpublicationcommentaire_1) REFERENCES publicationcommentaire(idpublicationcommentaire),
    FOREIGN KEY(idpublication) REFERENCES publication(idpublication)
);
CREATE TABLE commentairereaction(
    idcommentairereaction VARCHAR(20),
    idutilisateur INTEGER NOT NULL,
    idpublicationcommentaire VARCHAR(20) NOT NULL,
    idreactiontype VARCHAR(50) NOT NULL,
    PRIMARY KEY(idcommentairereaction),
    FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
    FOREIGN KEY(idpublicationcommentaire) REFERENCES publicationcommentaire(idpublicationcommentaire),
    FOREIGN KEY(idreactiontype) REFERENCES reactiontype(idreactiontype)
);
CREATE TABLE signalementpublication(
    idsignalementpublication VARCHAR(20),
    daty DATE NOT NULL,
    descritpion VARCHAR(50),
    typesignalement VARCHAR(20) NOT NULL,
    heure VARCHAR(20) NOT NULL,
    idpublication VARCHAR(20) NOT NULL,
    idutilisateur INTEGER NOT NULL,
    PRIMARY KEY(idsignalementpublication),
    FOREIGN KEY(typesignalement) REFERENCES typesignalement(idtypesignalement),
    FOREIGN KEY(idpublication) REFERENCES publication(idpublication),
    FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser)
);
CREATE TABLE mention(
    idmention VARCHAR(20),
    idutilisateur INTEGER NOT NULL,
    idpublicationcommentaire VARCHAR(20) NOT NULL,
    PRIMARY KEY(idmention),
    FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
    FOREIGN KEY(idpublicationcommentaire) REFERENCES publicationcommentaire(idpublicationcommentaire)
);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 7: TABLES HASHTAG ET VISIBILITE PUBLICATION                           ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE TABLE publicationhashtag (
    idpublicationhashtag SERIAL PRIMARY KEY,
    idpublication VARCHAR(20) NOT NULL,
    hashtag VARCHAR(50) NOT NULL,
    typetag VARCHAR(15) NOT NULL,
    idref VARCHAR(20) NOT NULL,
    FOREIGN KEY (idpublication) REFERENCES publication(idpublication)
);
CREATE TABLE publicationvisibilite (
    idpublicationvisibilite SERIAL PRIMARY KEY,
    idpublication VARCHAR(20) NOT NULL,
    typecible VARCHAR(15) NOT NULL,
    idref VARCHAR(20),
    anneemin INTEGER,
    FOREIGN KEY (idpublication) REFERENCES publication(idpublication)
);
CREATE TABLE publicationvue (
    idpublicationvue SERIAL PRIMARY KEY,
    idutilisateur INTEGER NOT NULL,
    idpublication VARCHAR(20) NOT NULL,
    datvue TIMESTAMP NOT NULL DEFAULT NOW(),
    nbvue INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT uq_pubvue UNIQUE (idutilisateur, idpublication)
);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 8: PARTICIPATION EVENEMENT                                            ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE TABLE participation_evenement (
    idparticipation VARCHAR(20) PRIMARY KEY,
    idevenement VARCHAR(20) NOT NULL REFERENCES evenement(idevenement) ON DELETE CASCADE,
    idutilisateur INTEGER NOT NULL,
    dateparticipation DATE NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE(idevenement, idutilisateur)
);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 9: RESEAUX SOCIAUX                                                    ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE TABLE reseauxsociaux (
    idreseausocial VARCHAR(20) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE,
    urlpattern VARCHAR(255),
    iconeclass VARCHAR(50),
    couleurhex VARCHAR(7),
    priorite INT DEFAULT 0,
    actif INT DEFAULT 1
);
CREATE TABLE profilsocialmedia (
    idprofilsocial VARCHAR(50) PRIMARY KEY,
    idprofil VARCHAR(20) NOT NULL,
    idreseausocial VARCHAR(20) NOT NULL,
    valeur VARCHAR(255) NOT NULL,
    datycreation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    datymodification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idprofil) REFERENCES profil(idprofil) ON DELETE CASCADE,
    FOREIGN KEY (idreseausocial) REFERENCES reseauxsociaux(idreseausocial) ON DELETE CASCADE,
    UNIQUE(idprofil, idreseausocial)
);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 10: CONTRAINTES D'UNICITE                                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
ALTER TABLE publicationreaction
ADD CONSTRAINT uq_publicationreaction_user_publication UNIQUE (idutilisateur, idpublication);
ALTER TABLE commentairereaction
ADD CONSTRAINT uq_commentairereaction_user_commentaire UNIQUE (idutilisateur, idpublicationcommentaire);
ALTER TABLE signalementpublication
ADD CONSTRAINT uq_signalementpublication_user_publication UNIQUE (idutilisateur, idpublication);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 11: INDEX                                                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE UNIQUE INDEX uq_pubhashtag ON publicationhashtag (idpublication, hashtag);
CREATE INDEX idx_pubhashtag_pub ON publicationhashtag (idpublication);
CREATE INDEX idx_pubhashtag_idref ON publicationhashtag (idref);
CREATE UNIQUE INDEX uq_pubvis_spec ON publicationvisibilite (idpublication, idref)
WHERE typecible = 'SPECIALITE';
CREATE UNIQUE INDEX uq_pubvis_promo ON publicationvisibilite (idpublication)
WHERE typecible = 'PROMOTION';
CREATE INDEX idx_pubvis_pub ON publicationvisibilite (idpublication);
CREATE INDEX idx_pubvue_user_pub ON publicationvue (idutilisateur, idpublication);
CREATE INDEX idx_pubvue_pub ON publicationvue (idpublication);
CREATE INDEX idx_publicationreaction_pub ON publicationreaction (idpublication);
CREATE INDEX idx_publicationcommentaire_pub ON publicationcommentaire (idpublication);
CREATE INDEX idx_pub_puborigine ON publication (idpuborigine)
WHERE idpuborigine IS NOT NULL;
CREATE INDEX idxprofilsocialmediaidprofil ON profilsocialmedia(idprofil);
CREATE INDEX idxprofilsocialmediareseau ON profilsocialmedia(idreseausocial);
CREATE INDEX idxreseauxsociauxactif ON reseauxsociaux(actif, priorite DESC);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 12: SEQUENCES ET FONCTIONS                                            ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE SEQUENCE seq_poste START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_poste() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_poste');
END $$;
CREATE SEQUENCE seq_parcours START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_parcours() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_parcours');
END $$;
CREATE SEQUENCE seq_promotion START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_promotion() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_promotion');
END $$;
CREATE SEQUENCE seq_specialite START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_specialite() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_specialite');
END $$;
CREATE SEQUENCE seq_diplome START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_diplome() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_diplome');
END $$;
CREATE SEQUENCE seq_option START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_option() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_option');
END $$;
CREATE SEQUENCE seq_mediatype START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_mediatype() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_mediatype');
END $$;
CREATE SEQUENCE seq_typepublication START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_typepublication() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_typepublication');
END $$;
CREATE SEQUENCE seq_reactiontype START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_reactiontype() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_reactiontype');
END $$;
CREATE SEQUENCE seq_typesignalement START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_typesignalement() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_typesignalement');
END $$;
CREATE SEQUENCE seq_profil START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_profil() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_profil');
END $$;
CREATE SEQUENCE seq_visibilite START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_visibilite() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_visibilite');
END $$;
CREATE SEQUENCE seq_experience START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_experience() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_experience');
END $$;
CREATE SEQUENCE seq_specialiteprofil START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_specialiteprofil() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_specialiteprofil');
END $$;
CREATE SEQUENCE seq_profildiplome START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_profildiplome() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_profildiplome');
END $$;
CREATE SEQUENCE seq_utilisateurhistoetat START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_utilisateurhistoetat() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_utilisateurhistoetat');
END $$;
CREATE SEQUENCE seq_photo START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_photo() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_photo');
END $$;
CREATE SEQUENCE seq_publication START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_publication() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_publication');
END $$;
CREATE SEQUENCE seq_media START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_media() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_media');
END $$;
CREATE SEQUENCE seq_identification START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_identification() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_identification');
END $$;
CREATE SEQUENCE seq_publicationreaction START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_publicationreaction() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_publicationreaction');
END $$;
CREATE SEQUENCE seq_publicationcommentaire START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_publicationcommentaire() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_publicationcommentaire');
END $$;
CREATE SEQUENCE seq_commentairereaction START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_commentairereaction() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_commentairereaction');
END $$;
CREATE SEQUENCE seq_evenement START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_evenement() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_evenement');
END $$;
CREATE SEQUENCE seq_signalementpublication START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_signalementpublication() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_signalementpublication');
END $$;
CREATE SEQUENCE seq_genre START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_genre() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_genre');
END $$;
CREATE SEQUENCE seq_mention START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_mention() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_mention');
END $$;
CREATE SEQUENCE seq_participation_evenement START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_participation_evenement() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_participation_evenement');
END $$;
CREATE SEQUENCE seq_profilsocialmedia START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION getseqprofilsocialmedia() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_profilsocialmedia');
END $$;
CREATE SEQUENCE seqHistoriqueActif START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION getseqhistoriqueactif() RETURNS BIGINT LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seqHistoriqueActif');
END $$;
CREATE SEQUENCE cnapsuser_id_seq START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION getseqcnapsuser() RETURNS BIGINT LANGUAGE sql AS $$
SELECT nextval('cnapsuser_id_seq');
$$;
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 13: VUES                                                              ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE VIEW promotionvue AS
SELECT p.idpromotion,
    p.annee,
    p.libelle,
    p.idparcours,
    pr.libelle AS libelleparcours
FROM promotion p
    JOIN parcours pr ON p.idparcours = pr.idparcours;
CREATE VIEW profillib AS
SELECT pr.idprofil,
    pr.email,
    pr.nom,
    pr.prenom,
    pr.dtn,
    pr.telephone,
    u.refuser AS idutilisateur,
    p.idpromotion,
    p.libelle AS promotionlib,
    p.annee AS promotionannee,
    parc.idparcours,
    parc.libelle AS parcourslib,
    g.idgenre,
    g.libelle AS genrelib,
    (
        SELECT image
        FROM photo
        WHERE photo.idprofil = pr.idprofil
            AND type = 1
        ORDER BY daty DESC,
            heure DESC
        LIMIT 1
    ) AS photoprofil,
    (
        SELECT image
        FROM photo
        WHERE photo.idprofil = pr.idprofil
            AND type = 0
        ORDER BY daty DESC,
            heure DESC
        LIMIT 1
    ) AS photocouverture,
    u.estactif,
    u.profile,
    u.idrole,
    u.refuser,
    u.loginuser,
    COALESCE(
        (
            SELECT ha.estactif
            FROM historiqueactif ha
            WHERE ha.idutilisateur = CAST(u.refuser AS varchar)
            ORDER BY ha.daty DESC,
                ha.id DESC
            LIMIT 1
        ), CASE
            WHEN u.estactif = 1 THEN 1
            ELSE 0
        END
    ) AS etatdetail,
    COALESCE(
        (
            SELECT CASE
                    WHEN ha.estactif = 0 THEN 'Banni'
                    WHEN ha.estactif = 1 THEN 'Cree'
                    WHEN ha.estactif = 11 THEN 'Valide'
                    WHEN ha.estactif = 100 THEN 'Actif'
                    ELSE 'Inconnu'
                END
            FROM historiqueactif ha
            WHERE ha.idutilisateur = CAST(u.refuser AS varchar)
            ORDER BY ha.daty DESC,
                ha.id DESC
            LIMIT 1
        ), CASE
            WHEN u.estactif = 1 THEN 'Cree'
            ELSE 'Banni'
        END
    ) AS etatlib
FROM utilisateur u
    LEFT JOIN profil pr ON pr.idutilisateur = u.refuser
    LEFT JOIN promotion p ON p.idpromotion = pr.idpromotion
    LEFT JOIN parcours parc ON parc.idparcours = pr.idparcours
    LEFT JOIN genre g ON g.idgenre = pr.idgenre;
CREATE VIEW experiencelib AS
SELECT e.idexperience,
    e.entreprise,
    e.debut,
    e.fin,
    e.description,
    e.etat,
    e.idprofil,
    e.idposte,
    p.libelle AS postelib,
    pr.idutilisateur
FROM experience e
    LEFT JOIN poste p ON p.idposte = e.idposte
    LEFT JOIN profil pr ON pr.idprofil = e.idprofil;
CREATE VIEW specialitecpl AS
SELECT idspecialite,
    libelle,
    description,
    photo,
    CASE
        WHEN photo IS NOT NULL
        AND photo <> '' THEN '<img src="__CTX__/' || photo || '" style="max-height:60px; max-width:80px;"/>'
        ELSE ''
    END AS photohtml
FROM specialite;
CREATE VIEW historiqueactiflib AS
SELECT id,
    idutilisateur,
    estactif,
    daty,
    CASE
        WHEN estactif = 0 THEN 'Inactif'
        WHEN estactif = 1 THEN 'Actif'
        ELSE 'Inconnu'
    END AS estactiflib,
    description
FROM historiqueactif;
CREATE VIEW signalementpublicationlib AS
SELECT s.idsignalementpublication AS idsignalement,
    s.idpublication,
    s.idutilisateur AS idsignalant,
    COALESCE(
        prsignalant.prenom || ' ' || prsignalant.nom,
        'Utilisateur #' || s.idutilisateur
    ) AS nomsignalant,
    pub.idutilisateur AS idsignale,
    COALESCE(
        prsignale.prenom || ' ' || prsignale.nom,
        'Utilisateur #' || pub.idutilisateur
    ) AS nomsignale,
    s.typesignalement,
    s.daty,
    s.heure,
    s.descritpion AS motifdesc,
    sp.libelle AS motiflibelle
FROM signalementpublication s
    JOIN publication pub ON pub.idpublication = s.idpublication
    JOIN typesignalement sp ON sp.idtypesignalement = s.typesignalement
    LEFT JOIN profil prsignalant ON prsignalant.idutilisateur = s.idutilisateur
    LEFT JOIN profil prsignale ON prsignale.idutilisateur = pub.idutilisateur;
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 14: DONNEES DE REFERENCE                                              ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
-- Genre
INSERT INTO genre (idgenre, libelle)
VALUES ('GEN000001', 'homme');
INSERT INTO genre (idgenre, libelle)
VALUES ('GEN000002', 'femme');
-- Types de publication
INSERT INTO typepublication (idtypepublication, libelle)
VALUES ('TPB000001', 'Offre d''emploi');
INSERT INTO typepublication (idtypepublication, libelle)
VALUES ('TPB000002', 'Stage');
INSERT INTO typepublication (idtypepublication, libelle)
VALUES ('TPB000003', 'Evenement');
-- Types de media
INSERT INTO mediatype (idmediatype, libelle)
VALUES ('MDT000001', 'Image');
INSERT INTO mediatype (idmediatype, libelle)
VALUES ('MDT000002', 'Video');
-- Types de reaction
INSERT INTO reactiontype (idreactiontype, libelle)
VALUES ('RCT000001', 'Like');
INSERT INTO reactiontype (idreactiontype, libelle)
VALUES ('RCT000002', 'Love');
INSERT INTO reactiontype (idreactiontype, libelle)
VALUES ('RCT000003', 'Haha');
INSERT INTO reactiontype (idreactiontype, libelle)
VALUES ('RCT000004', 'Wow');
INSERT INTO reactiontype (idreactiontype, libelle)
VALUES ('RCT000005', 'Triste');
INSERT INTO reactiontype (idreactiontype, libelle)
VALUES ('RCT000006', 'Enerve');
-- Types de signalement
INSERT INTO typesignalement (idtypesignalement, libelle)
VALUES ('TSG000001', 'Contenu pour adultes');
INSERT INTO typesignalement (idtypesignalement, libelle)
VALUES ('TSG000002', 'Contenu violent');
INSERT INTO typesignalement (idtypesignalement, libelle)
VALUES (
        'TSG000003',
        'Scam, fraude ou fausse information'
    );
INSERT INTO typesignalement (idtypesignalement, libelle)
VALUES ('TSG000004', 'Harcelement ou discrimination');
-- Reseaux sociaux
INSERT INTO reseauxsociaux (
        idreseausocial,
        libelle,
        urlpattern,
        iconeclass,
        couleurhex,
        priorite
    )
VALUES (
        'linkedin',
        'LinkedIn',
        'https://linkedin.com/in/{value}',
        'fab fa-linkedin',
        '#0A66C2',
        100
    ),
    (
        'github',
        'GitHub',
        'https://github.com/{value}',
        'fab fa-github',
        '#181717',
        95
    ),
    (
        'gitlab',
        'GitLab',
        'https://gitlab.com/{value}',
        'fab fa-gitlab',
        '#FC6D26',
        90
    ),
    (
        'bitbucket',
        'Bitbucket',
        'https://bitbucket.org/{value}',
        'fab fa-bitbucket',
        '#0052CC',
        85
    ),
    (
        'stackoverflow',
        'Stack Overflow',
        'https://stackoverflow.com/users/{value}',
        'fab fa-stack-overflow',
        '#F48024',
        80
    ),
    (
        'codepen',
        'CodePen',
        'https://codepen.io/{value}',
        'fab fa-codepen',
        '#000000',
        75
    ),
    (
        'behance',
        'Behance',
        'https://behance.net/{value}',
        'fab fa-behance',
        '#1769FF',
        70
    ),
    (
        'twitter',
        'Twitter',
        'https://twitter.com/{value}',
        'fab fa-twitter',
        '#1DA1F2',
        90
    ),
    (
        'facebook',
        'Facebook',
        'https://facebook.com/{value}',
        'fab fa-facebook',
        '#1877F2',
        85
    ),
    (
        'instagram',
        'Instagram',
        'https://instagram.com/{value}',
        'fab fa-instagram',
        '#E4405F',
        88
    ),
    (
        'tiktok',
        'TikTok',
        'https://tiktok.com/@{value}',
        'fab fa-tiktok',
        '#000000',
        75
    ),
    (
        'youtube',
        'YouTube',
        'https://youtube.com/@{value}',
        'fab fa-youtube',
        '#FF0000',
        80
    ),
    (
        'discord',
        'Discord',
        'https://discord.com/users/{value}',
        'fab fa-discord',
        '#5865F2',
        70
    ),
    (
        'portfolio',
        'Portfolio',
        '{value}',
        'fas fa-globe',
        '#3B82F6',
        65
    ),
    (
        'website',
        'Site Web',
        '{value}',
        'fas fa-link',
        '#666666',
        60
    ),
    (
        'devto',
        'Dev.to',
        'https://dev.to/{value}',
        'fab fa-dev',
        '#0A0E27',
        65
    ),
    (
        'medium',
        'Medium',
        'https://medium.com/@{value}',
        'fab fa-medium',
        '#000000',
        60
    ),
    (
        'hashnode',
        'Hashnode',
        'https://hashnode.com/@{value}',
        'fas fa-h',
        '#2962FF',
        62
    ),
    (
        'substack',
        'Substack',
        'https://substack.com/@{value}',
        'fas fa-envelope',
        '#FF6600',
        58
    ),
    (
        'whatsapp',
        'WhatsApp',
        'https://wa.me/{value}',
        'fab fa-whatsapp',
        '#25D366',
        50
    ),
    (
        'telegram',
        'Telegram',
        'https://t.me/{value}',
        'fab fa-telegram',
        '#0088cc',
        50
    ),
    (
        'skype',
        'Skype',
        'https://join.skype.com/{value}',
        'fab fa-skype',
        '#00AFF0',
        45
    ),
    (
        'email',
        'Email',
        'mailto:{value}',
        'fas fa-envelope',
        '#EA4335',
        55
    ),
    (
        'phone',
        'Telephone',
        'tel:{value}',
        'fas fa-phone',
        '#34C759',
        40
    );
-- Parcours
INSERT INTO parcours (idparcours, libelle)
VALUES ('PRC000001', 'Informatique');
-- Promotion
INSERT INTO promotion (idpromotion, annee, libelle, idparcours)
VALUES ('PRM000001', 2024, 'P19', 'PRC000001');
-- Postes
INSERT INTO poste (idposte, libelle)
VALUES ('PST000001', 'Developpeur Full Stack');
INSERT INTO poste (idposte, libelle)
VALUES ('PST000002', 'Chef de Projet Informatique');
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 15: MENUS DYNAMIQUES                                                  ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
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
        'MENDYN000003',
        'Carriere',
        'bi-briefcase-fill',
        '#',
        3,
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
        'MENDYN000010',
        'Modifier le profil',
        'bi-pencil-square',
        'module.jsp?but=profil/modifier.jsp',
        2,
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
    ('USRM000003', 'MENDYN000003', '*', 0, 'etu'),
    ('USRM000004', 'MENDYN000004', '*', 0, 'etu'),
    ('USRM000005', 'MENDYN000005', '*', 0, 'etu'),
    ('USRM000007', 'MENDYN000007', '*', 0, 'etu'),
    ('USRM000008', 'MENDYN000008', '*', 0, 'etu'),
    ('USRM000009', 'MENDYN000009', '*', 0, 'etu'),
    ('USRM000010', 'MENDYN000010', '*', 0, 'etu'),
    ('USRM000011', 'MENDYN000011', '*', 0, 'etu'),
    ('USRM000025', 'MENDYN000024', '*', 1, 'etu'),
    ('USRM000027', 'MENDYN000014', '*', 0, 'etu'),
    ('USRM000029', 'MENDYN000015', '*', 0, 'etu'),
    ('USRM000031', 'MENDYN000016', '*', 0, 'etu'),
    ('USRM000033', 'MENDYN000017', '*', 0, 'etu'),
    ('USRM000035', 'MENDYN000018', '*', 0, 'etu');
-- Droits role md
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
    ('USRM000024', 'MENDYN000024', '*', 0, 'md'),
    ('USRM000028', 'MENDYN000014', '*', 0, 'md'),
    ('USRM000030', 'MENDYN000015', '*', 0, 'md'),
    ('USRM000032', 'MENDYN000016', '*', 0, 'md'),
    ('USRM000034', 'MENDYN000017', '*', 0, 'md'),
    ('USRM000036', 'MENDYN000018', '*', 0, 'md');

-- Sous-menu Reseau Professionnel sous RESEAU (niveau 1)
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
    ('MENDYN000019', 'Reseau pro', 'bi-diagram-3-fill', 'module.jsp?but=alumni/reseau-professionnel.jsp', 3, 1, 'MENDYN000002');

-- Droits role etu
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
    ('USRM000035', 'MENDYN000019', '*', 0, 'etu');

-- Droits role md
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
    ('USRM000036', 'MENDYN000019', '*', 0, 'md');
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ SECTION 16: MISE A JOUR DES SEQUENCES                                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
SELECT setval('seq_promotion', 10);
SELECT setval('seq_parcours', 10);
SELECT setval('seq_profil', 10);
SELECT setval('seq_genre', 10);
SELECT setval('seq_poste', 10);
SELECT setval('seq_typepublication', 10);
SELECT setval('seq_mediatype', 10);
SELECT setval('seq_reactiontype', 10);
SELECT setval('seq_typesignalement', 10);
-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ VERIFICATION                                                                  ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
SELECT 'Tables crees' AS status,
    COUNT(*) AS nb
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE';
SELECT 'Vues crees' AS status,
    COUNT(*) AS nb
FROM information_schema.views
WHERE table_schema = 'public';
SELECT 'Sequences crees' AS status,
    COUNT(*) AS nb
FROM information_schema.sequences
WHERE sequence_schema = 'public';