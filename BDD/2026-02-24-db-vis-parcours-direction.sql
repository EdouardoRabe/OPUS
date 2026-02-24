-- Active: 1736646695640@@127.0.0.1@5432@opus@public
-- =====================================================================
-- Extension hashtag/visibilite : Parcours + direction promo (annee+/-)
-- =====================================================================

-- La table publicationvisibilite supporte deja typecible libre.
-- On ajoute la direction pour les regles de promotion (yyyy+ ou yyyy-)
ALTER TABLE publicationvisibilite
    ADD COLUMN IF NOT EXISTS anneeref       INTEGER,
    ADD COLUMN IF NOT EXISTS anneedirection CHAR(1) DEFAULT '+';

-- Migrer les anciennes lignes (anneemin -> anneeref, direction par defaut '+')
UPDATE publicationvisibilite
SET anneeref = anneemin, anneedirection = '+'
WHERE typecible = 'PROMOTION' AND anneemin IS NOT NULL AND anneeref IS NULL;

-- publicationhashtag supporte deja typetag libre ('PARCOURS' fonctionne tel quel).
-- Aucune autre modification structurelle necessaire.
