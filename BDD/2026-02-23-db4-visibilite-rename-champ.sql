-- Renommer la colonne 'champ' en 'champvisibilite' dans la table visibilite
-- Date: 2026-02-23

ALTER TABLE visibilite RENAME COLUMN champ TO champvisibilite;

-- Verification
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'visibilite';

-- Test
SELECT * FROM visibilite;
