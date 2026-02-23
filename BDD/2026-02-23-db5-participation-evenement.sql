-- ======================== PARTICIPATION EVENEMENT ========================
-- Table pour gerer la participation des utilisateurs aux evenements

CREATE TABLE participation_evenement (
    idparticipation   VARCHAR(20) PRIMARY KEY,
    idevenement       VARCHAR(20) NOT NULL REFERENCES evenement(idevenement) ON DELETE CASCADE,
    idutilisateur     INTEGER NOT NULL,
    dateparticipation DATE NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE(idevenement, idutilisateur)
);

-- Sequence
CREATE SEQUENCE seq_participation_evenement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;

-- Fonction generateur de PK
CREATE OR REPLACE FUNCTION get_seq_participation_evenement()
RETURNS INTEGER
LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_participation_evenement'));
END
$$;

INSERT INTO typepublication (idtypepublication, libelle) VALUES ('TPB000003', 'Evenement');
