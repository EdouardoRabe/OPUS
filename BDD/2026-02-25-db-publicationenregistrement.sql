-- Migration: publicationenregistrement PK SERIAL -> VARCHAR(20) + sequence APJ
-- Date: 2026-02-25

-- 1) Supprimer la table existante (SERIAL) si elle existe
DROP TABLE IF EXISTS publicationenregistrement;

-- 2) Recreer avec PK VARCHAR(20) comme les autres beans APJ
CREATE TABLE publicationenregistrement (
    idpublicationenregistrement VARCHAR(20) PRIMARY KEY,
    idpublication VARCHAR(20) NOT NULL,
    idutilisateur INTEGER NOT NULL,
    daty DATE NOT NULL DEFAULT CURRENT_DATE,
    heure VARCHAR(8) NOT NULL DEFAULT to_char(NOW(), 'HH24:MI:SS'),
    UNIQUE(idpublication, idutilisateur),
    FOREIGN KEY (idpublication) REFERENCES publication(idpublication),
    FOREIGN KEY (idutilisateur) REFERENCES utilisateur(refuser)
);

-- 3) Sequence + fonction APJ
CREATE SEQUENCE seq_publicationenregistrement START WITH 1 INCREMENT BY 1 CACHE 1;
CREATE FUNCTION get_seq_publicationenregistrement() RETURNS INTEGER LANGUAGE plpgsql AS $$ BEGIN RETURN nextval('seq_publicationenregistrement');
END $$;

select * from publicationenregistrement;
