-- =====================================================================
-- TABLE : publicationvue
-- Suit les publications qu'un utilisateur a deja vues.
-- Utilisee pour personaliser et faire varier le fil d'actualite :
--   - les posts deja vus ont un score reduit => descendent naturellement
--   - un reload affiche donc de nouveaux posts en priorite
-- =====================================================================

CREATE TABLE IF NOT EXISTS publicationvue (
    idpublicationvue  SERIAL        PRIMARY KEY,
    idutilisateur     INTEGER       NOT NULL,
    idpublication     VARCHAR(20)   NOT NULL,
    datvue            TIMESTAMP     NOT NULL DEFAULT NOW(),
    nbvue             INTEGER       NOT NULL DEFAULT 1,
    CONSTRAINT uq_pubvue UNIQUE (idutilisateur, idpublication)
);

-- Index principal : lookup par user + publication (UPSERT rapide)
CREATE INDEX IF NOT EXISTS idx_pubvue_user_pub ON publicationvue (idutilisateur, idpublication);

-- Index pour les sous-requetes du score feed (par publication)
CREATE INDEX IF NOT EXISTS idx_pubvue_pub ON publicationvue (idpublication);

-- Index de performance pour les sous-requetes reactions / commentaires
CREATE INDEX IF NOT EXISTS idx_publicationreaction_pub    ON publicationreaction (idpublication);
CREATE INDEX IF NOT EXISTS idx_publicationcommentaire_pub ON publicationcommentaire (idpublication);
