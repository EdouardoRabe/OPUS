
SET search_path = public;   -- ou le nom de votre schéma


SELECT * FROM pg_class WHERE relname='cnapsuser_id_seq';

-- créer la séquence (une seule fois) :
CREATE SEQUENCE cnapsuser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;

-- drop old version if it has incompatible signature
DROP FUNCTION IF EXISTS getseqcnapsuser();

-- (re)créer la fonction d’aide :
CREATE OR REPLACE FUNCTION getseqcnapsuser()
RETURNS bigint
LANGUAGE sql
AS $$
  SELECT nextval('cnapsuser_id_seq');
$$;

-- tester l’appel :
SELECT getseqcnapsuser();