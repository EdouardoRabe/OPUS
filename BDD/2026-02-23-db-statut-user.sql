-- corrected definitions with varchar identifiers, sequences and helpers
-- sequence & function for profiltypestatut
CREATE SEQUENCE IF NOT EXISTS seq_profiltypestatut START 1;
CREATE OR REPLACE FUNCTION getseqprofiltypestatut() RETURNS varchar LANGUAGE plpgsql AS $$ BEGIN RETURN 'PTS' || lpad(nextval('seq_profiltypestatut')::text, 5, '0');
END;
$$;
CREATE TABLE IF NOT EXISTS profiltypestatut (
    idprofiltypestatut VARCHAR(12) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    couleur VARCHAR(7) DEFAULT '#000000' -- hex code for display
);
-- initial data for profiltypestatut
INSERT INTO profiltypestatut(idprofiltypestatut, libelle, couleur)
SELECT getseqprofiltypestatut(),
    'Open to work', '#28a745'
WHERE NOT EXISTS (
        SELECT 1
        FROM profiltypestatut
        WHERE libelle = 'Open to work'
    );
INSERT INTO profiltypestatut(idprofiltypestatut, libelle, couleur)
SELECT getseqprofiltypestatut(),
    'Taken', '#dc3545'
WHERE NOT EXISTS (
        SELECT 1
        FROM profiltypestatut
        WHERE libelle = 'Taken'
    );
INSERT INTO profiltypestatut(idprofiltypestatut, libelle, couleur)
SELECT getseqprofiltypestatut(),
    'Neutre', '#808080'
WHERE NOT EXISTS (
        SELECT 1
        FROM profiltypestatut
        WHERE libelle = 'Neutre'
    );
-- sequence & function for profilstatut
CREATE SEQUENCE IF NOT EXISTS seq_profilstatut START 1;
CREATE OR REPLACE FUNCTION getseqprofilstatut() RETURNS varchar LANGUAGE plpgsql AS $$ BEGIN RETURN 'PS' || lpad(nextval('seq_profilstatut')::text, 5, '0');
END;
$$;
CREATE TABLE IF NOT EXISTS profilstatut (
    id VARCHAR(12) PRIMARY KEY,
    idprofil VARCHAR(50) NOT NULL REFERENCES profil(idprofil),
    idprofiltypestatut VARCHAR(12) NOT NULL REFERENCES profiltypestatut(idprofiltypestatut),
    daty TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- initial data for profilstatut
INSERT INTO profilstatut(id, idprofil, idprofiltypestatut)
SELECT getseqprofilstatut(), 'PRF000010', (SELECT idprofiltypestatut FROM profiltypestatut WHERE libelle = 'Taken');

-- View: latest profile status with type details
CREATE OR REPLACE VIEW v_profilstatut_latest AS
SELECT
    ps.id,
    ps.idprofil,
    ps.idprofiltypestatut,
    pts.libelle,
    pts.couleur,
    ps.daty
FROM profilstatut ps
INNER JOIN profiltypestatut pts ON ps.idprofiltypestatut = pts.idprofiltypestatut
WHERE (ps.idprofil, ps.daty) IN (
    SELECT idprofil, MAX(daty)
    FROM profilstatut
    GROUP BY idprofil
);