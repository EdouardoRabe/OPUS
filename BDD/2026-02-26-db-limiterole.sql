-- ═══════════════════════════════════════════════════════════════════════════════
-- MIGRATION: Table limiterole + role alu
-- Date: 2026-02-26
-- Description:
--   - Creer la table limiterole pour definir le nombre max de publications/jour par role
--   - Inserer les limites : etu=0 (ne peut pas publier), alu=3
--   - Roles absents de limiterole = pas de limite (ex: md)
--   - Mettre a jour ETU000002 en role 'alu' pour les tests
-- ═══════════════════════════════════════════════════════════════════════════════

-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ TABLE: limiterole                                                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
CREATE TABLE IF NOT EXISTS limiterole (
    idrole VARCHAR(20) PRIMARY KEY,
    maxpublicationparjour INTEGER NOT NULL DEFAULT 0
);

-- Donnees : limites par role
INSERT INTO limiterole (idrole, maxpublicationparjour) VALUES ('etu', 0)
ON CONFLICT (idrole) DO UPDATE SET maxpublicationparjour = EXCLUDED.maxpublicationparjour;

INSERT INTO limiterole (idrole, maxpublicationparjour) VALUES ('alu', 3)
ON CONFLICT (idrole) DO UPDATE SET maxpublicationparjour = EXCLUDED.maxpublicationparjour;

INSERT INTO limiterole (idrole, maxpublicationparjour) VALUES ('md', 100)
ON CONFLICT (idrole) DO UPDATE SET maxpublicationparjour = EXCLUDED.maxpublicationparjour;

-- Les roles NON presents dans limiterole (ex: md, admin, dg) n'ont PAS de limite

-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ MISE A JOUR UTILISATEURS : passer certains en role 'alu'                      ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
-- ETU000002 (refuser=101) : obligatoire pour les tests
UPDATE utilisateur SET idrole = 'alu' WHERE id = 'ETU000002';
UPDATE utilisateur SET idrole = 'alu' WHERE id = 'ETU000014';
UPDATE utilisateur SET idrole = 'alu' WHERE id = 'ETU000015';
