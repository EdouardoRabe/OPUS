-- =====================================================================
-- Ajout du champ email a la table utilisateur du framework APJ
-- Date : 2026-02-22
-- =====================================================================

ALTER TABLE utilisateur ADD COLUMN email VARCHAR(250);
