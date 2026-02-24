-- ═══════════════════════════════════════════════════════════════
-- Création de la séquence pour profilsocialmedia
-- Date: 2026-02-24
-- ═══════════════════════════════════════════════════════════════
-- ── SÉQUENCE: getseqprofilsocialmedia ──
-- Génère les identifiants uniques pour la table profilsocialmedia
CREATE SEQUENCE IF NOT EXISTS seq_profilsocialmedia START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE OR REPLACE FUNCTION public.getseqprofilsocialmedia() RETURNS integer LANGUAGE plpgsql AS $function$ BEGIN RETURN (
        SELECT nextval('seq_profilsocialmedia')
    );
END;
$function$;