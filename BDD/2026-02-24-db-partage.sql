-- ============================================================
-- PARTAGE DE PUBLICATION
-- Ajout du champ idpuborigine dans la table publication
-- pour identifier les publications partagées (republications)
-- ============================================================

ALTER TABLE publication
    ADD COLUMN IF NOT EXISTS idpuborigine VARCHAR(20) DEFAULT NULL
        REFERENCES publication(idpublication) ON DELETE SET NULL;

-- Index pour charger rapidement tous les partages d'une publication
CREATE INDEX IF NOT EXISTS idx_pub_puborigine ON publication (idpuborigine)
    WHERE idpuborigine IS NOT NULL;
