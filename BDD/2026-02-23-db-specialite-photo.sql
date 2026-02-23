-- Active: 1736646695640@@127.0.0.1@5432@opus@public
ALTER TABLE specialite ADD COLUMN photo VARCHAR(500);

CREATE OR REPLACE VIEW specialitecpl AS
SELECT
    idspecialite,
    libelle,
    photo,
    CASE WHEN photo IS NOT NULL AND photo <> ''
        THEN '<img src="__CTX__/' || photo || '" style="max-height:60px; max-width:80px;"/>'
        ELSE ''
    END AS photohtml
FROM specialite;
