CREATE TABLE profilemplacement (
    id VARCHAR(20) PRIMARY KEY,
    idprofil VARCHAR(20) NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    FOREIGN KEY(idprofil) REFERENCES profil(idprofil)
);

CREATE SEQUENCE seq_profilemplacement;

CREATE OR REPLACE FUNCTION get_seq_profilemplacement() RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN nextval('seq_profilemplacement');
END;
$$;

CREATE VIEW v_profil_localisation AS
SELECT 
    p.*,
    pe.longitude,
    pe.latitude,
    pe.id AS idemplacement
FROM 
    profillib p
JOIN 
    profilemplacement pe ON p.idprofil = pe.idprofil
WHERE 
    NOT EXISTS (
        SELECT 1 FROM visibilite v 
        WHERE v.idprofil = p.idprofil 
        AND v.champvisibilite = 'localisation' 
        AND v.status = 0
    );