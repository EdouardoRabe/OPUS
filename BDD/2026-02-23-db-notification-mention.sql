-- =====================================================================
-- Migration: Notification enrichie + Mention (@) 
-- A executer APRES 2026-02-22-db-opus.sql et 2026-02-22-db-sequences.sql
-- =====================================================================

-- 1) Ajouter le champ typenotif a la table notification
--    Types: COMMENT, REPLY, PUB_REACTION, COMM_REACTION, MENTION, IDENTIFICATION
ALTER TABLE notification ADD COLUMN typenotif VARCHAR(50);

-- 2) Rendre certains champs nullable pour plus de flexibilite
ALTER TABLE notification ALTER COLUMN lien DROP NOT NULL;
ALTER TABLE notification ALTER COLUMN idorigine DROP NOT NULL;

-- ======================== TABLE MENTION ========================
-- Stocke les mentions @utilisateur dans les commentaires
CREATE TABLE mention(
   idmention VARCHAR(20),
   idutilisateur integer NOT NULL,
   idpublicationcommentaire VARCHAR(20) NOT NULL,
   PRIMARY KEY(idmention),
   FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
   FOREIGN KEY(idpublicationcommentaire) REFERENCES publicationcommentaire(idpublicationcommentaire)
);

-- ======================== SEQUENCE MENTION ========================
CREATE SEQUENCE public.seq_mention START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_mention OWNER TO postgres;

CREATE FUNCTION public.get_seq_mention() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_mention'));
END
$$;
ALTER FUNCTION public.get_seq_mention() OWNER TO postgres;
