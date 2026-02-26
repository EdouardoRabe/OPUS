-- ═══════════════════════════════════════════════════════════════════════════════
-- MIGRATION: Table limiterole + role alu
-- Date: 2026-02-26
-- Description:
--   - Creer la table limiterole pour definir le nombre max de publications/jour par role
--   - Chaque changement de limite = nouvelle ligne avec date
--   - La limite en vigueur = la plus recente par role
--   - Inserer les limites : etu=0 (ne peut pas publier), alu=3, md=100
--   - Roles absents de limiterole = pas de limite
--   - Mettre a jour ETU000002, ETU000014, ETU000015 en role 'alu' pour les tests
-- ═══════════════════════════════════════════════════════════════════════════════

-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ TABLE: limiterole                                                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝
DROP TABLE IF EXISTS limiterole;
drop view if exists limiteroleactuel;

CREATE TABLE limiterole (
    idlimiterole VARCHAR(20) PRIMARY KEY,
    idrole VARCHAR(20) NOT NULL,
    maxpublicationparjour INTEGER NOT NULL DEFAULT 0,
    daty DATE NOT NULL DEFAULT CURRENT_DATE,
    heure VARCHAR(20) NOT NULL DEFAULT TO_CHAR(CURRENT_TIMESTAMP, 'HH24:MI:SS')
);

-- Sequence pour generer les PK
CREATE SEQUENCE IF NOT EXISTS seq_limiterole START 1;

CREATE OR REPLACE FUNCTION get_seq_limiterole() RETURNS VARCHAR AS $$
    SELECT NEXTVAL('seq_limiterole')::VARCHAR;
$$ LANGUAGE SQL;

-- Donnees initiales
INSERT INTO limiterole (idlimiterole, idrole, maxpublicationparjour, daty, heure) VALUES ('LMR001', 'etu', 0, CURRENT_DATE, TO_CHAR(CURRENT_TIMESTAMP, 'HH24:MI:SS'));
INSERT INTO limiterole (idlimiterole, idrole, maxpublicationparjour, daty, heure) VALUES ('LMR002', 'alu', 3, CURRENT_DATE, TO_CHAR(CURRENT_TIMESTAMP, 'HH24:MI:SS'));
INSERT INTO limiterole (idlimiterole, idrole, maxpublicationparjour, daty, heure) VALUES ('LMR003', 'md', 100, CURRENT_DATE, TO_CHAR(CURRENT_TIMESTAMP, 'HH24:MI:SS'));
SELECT SETVAL('seq_limiterole', 3);


select*from limiterole;

-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║ MISE A JOUR UTILISATEURS : passer certains en role 'alu'                      ║
-- ╚═════
UPDATE utilisateur SET idrole = 'alu' WHERE id = 'ETU000015';
