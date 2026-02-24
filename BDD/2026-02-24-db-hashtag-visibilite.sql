-- Active: 1736646695640@@127.0.0.1@5432@opus@public
-- =====================================================================
-- Hashtags et visibilite des publications
-- =====================================================================

-- Hashtags lies a une publication (extraits du texte via #)
CREATE TABLE IF NOT EXISTS publicationhashtag (
    idpublicationhashtag SERIAL PRIMARY KEY,
    idpublication        VARCHAR(20) NOT NULL,
    hashtag              VARCHAR(50) NOT NULL,  -- ex: '#P19', '#JAVA'  (toujours majuscules)
    typetag              VARCHAR(15) NOT NULL,  -- 'SPECIALITE' ou 'PROMOTION'
    idref                VARCHAR(20) NOT NULL,  -- idspecialite ou idpromotion
    FOREIGN KEY (idpublication) REFERENCES publication(idpublication)
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_pubhashtag ON publicationhashtag (idpublication, hashtag);
CREATE INDEX IF NOT EXISTS idx_pubhashtag_pub   ON publicationhashtag (idpublication);
CREATE INDEX IF NOT EXISTS idx_pubhashtag_idref ON publicationhashtag (idref);

-- Visibilite restreinte d'une publication (absence de ligne = visible par tous)
CREATE TABLE IF NOT EXISTS publicationvisibilite (
    idpublicationvisibilite SERIAL PRIMARY KEY,
    idpublication           VARCHAR(20) NOT NULL,
    typecible               VARCHAR(15) NOT NULL, -- 'SPECIALITE' ou 'PROMOTION'
    idref                   VARCHAR(20),          -- idspecialite; NULL pour type PROMOTION
    anneemin                INTEGER,              -- PROMOTION: visible si annee_user >= anneemin
    FOREIGN KEY (idpublication) REFERENCES publication(idpublication)
);
-- Index partiels pour upsert / unicite
CREATE UNIQUE INDEX IF NOT EXISTS uq_pubvis_spec  ON publicationvisibilite (idpublication, idref)
    WHERE typecible = 'SPECIALITE';
CREATE UNIQUE INDEX IF NOT EXISTS uq_pubvis_promo ON publicationvisibilite (idpublication)
    WHERE typecible = 'PROMOTION';
CREATE INDEX IF NOT EXISTS idx_pubvis_pub ON publicationvisibilite (idpublication);

-- Logique de combinaison des regles de visibilite (AND / OR)
ALTER TABLE publication ADD COLUMN IF NOT EXISTS logique_visibilite VARCHAR(3) DEFAULT 'OR';
