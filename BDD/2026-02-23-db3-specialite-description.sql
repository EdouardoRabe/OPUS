ALTER TABLE specialite
    ADD COLUMN IF NOT EXISTS description TEXT;

drop VIEW IF EXISTS specialitecpl;

CREATE OR REPLACE VIEW specialitecpl AS
SELECT
    idspecialite,
    libelle,
    description,
    photo,
    CASE WHEN photo IS NOT NULL AND photo <> ''
        THEN '<img src="__CTX__/' || photo || '" style="max-height:60px; max-width:80px;"/>'
        ELSE ''
    END AS photohtml
FROM specialite;
