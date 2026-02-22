-- =====================================================================
-- Sequences et fonctions pour la generation des cles primaires
-- A executer APRES le script 2026-02-22-db-opus.sql
-- =====================================================================

-- ======================== POSTE ========================
CREATE SEQUENCE public.seq_poste START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_poste OWNER TO postgres;

CREATE FUNCTION public.get_seq_poste() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_poste'));
END
$$;
ALTER FUNCTION public.get_seq_poste() OWNER TO postgres;

-- ======================== PARCOURS ========================
CREATE SEQUENCE public.seq_parcours START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_parcours OWNER TO postgres;

CREATE FUNCTION public.get_seq_parcours() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_parcours'));
END
$$;
ALTER FUNCTION public.get_seq_parcours() OWNER TO postgres;

-- ======================== PROMOTION ========================
CREATE SEQUENCE public.seq_promotion START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_promotion OWNER TO postgres;

CREATE FUNCTION public.get_seq_promotion() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_promotion'));
END
$$;
ALTER FUNCTION public.get_seq_promotion() OWNER TO postgres;

-- ======================== SPECIALITE ========================
CREATE SEQUENCE public.seq_specialite START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_specialite OWNER TO postgres;

CREATE FUNCTION public.get_seq_specialite() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_specialite'));
END
$$;
ALTER FUNCTION public.get_seq_specialite() OWNER TO postgres;

-- ======================== DIPLOME ========================
CREATE SEQUENCE public.seq_diplome START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_diplome OWNER TO postgres;

CREATE FUNCTION public.get_seq_diplome() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_diplome'));
END
$$;
ALTER FUNCTION public.get_seq_diplome() OWNER TO postgres;

-- ======================== OPTION ========================
CREATE SEQUENCE public.seq_option START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_option OWNER TO postgres;

CREATE FUNCTION public.get_seq_option() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_option'));
END
$$;
ALTER FUNCTION public.get_seq_option() OWNER TO postgres;

-- ======================== MEDIATYPE ========================
CREATE SEQUENCE public.seq_mediatype START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_mediatype OWNER TO postgres;

CREATE FUNCTION public.get_seq_mediatype() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_mediatype'));
END
$$;
ALTER FUNCTION public.get_seq_mediatype() OWNER TO postgres;

-- ======================== TYPEPUBLICATION ========================
CREATE SEQUENCE public.seq_typepublication START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_typepublication OWNER TO postgres;

CREATE FUNCTION public.get_seq_typepublication() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_typepublication'));
END
$$;
ALTER FUNCTION public.get_seq_typepublication() OWNER TO postgres;

-- ======================== REACTIONTYPE ========================
CREATE SEQUENCE public.seq_reactiontype START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_reactiontype OWNER TO postgres;

CREATE FUNCTION public.get_seq_reactiontype() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_reactiontype'));
END
$$;
ALTER FUNCTION public.get_seq_reactiontype() OWNER TO postgres;

-- ======================== TYPESIGNALEMENT ========================
CREATE SEQUENCE public.seq_typesignalement START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_typesignalement OWNER TO postgres;

CREATE FUNCTION public.get_seq_typesignalement() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_typesignalement'));
END
$$;
ALTER FUNCTION public.get_seq_typesignalement() OWNER TO postgres;

-- ======================== PROFIL ========================
CREATE SEQUENCE public.seq_profil START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_profil OWNER TO postgres;

CREATE FUNCTION public.get_seq_profil() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_profil'));
END
$$;
ALTER FUNCTION public.get_seq_profil() OWNER TO postgres;

-- ======================== VISIBILITE ========================
CREATE SEQUENCE public.seq_visibilite START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_visibilite OWNER TO postgres;

CREATE FUNCTION public.get_seq_visibilite() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_visibilite'));
END
$$;
ALTER FUNCTION public.get_seq_visibilite() OWNER TO postgres;

-- ======================== EXPERIENCE ========================
CREATE SEQUENCE public.seq_experience START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_experience OWNER TO postgres;

CREATE FUNCTION public.get_seq_experience() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_experience'));
END
$$;
ALTER FUNCTION public.get_seq_experience() OWNER TO postgres;

-- ======================== SPECIALITEPROFIL ========================
CREATE SEQUENCE public.seq_specialiteprofil START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_specialiteprofil OWNER TO postgres;

CREATE FUNCTION public.get_seq_specialiteprofil() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_specialiteprofil'));
END
$$;
ALTER FUNCTION public.get_seq_specialiteprofil() OWNER TO postgres;

-- ======================== PROFILDIPLOME ========================
CREATE SEQUENCE public.seq_profildiplome START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_profildiplome OWNER TO postgres;

CREATE FUNCTION public.get_seq_profildiplome() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_profildiplome'));
END
$$;
ALTER FUNCTION public.get_seq_profildiplome() OWNER TO postgres;

-- ======================== UTILISATEURHISTOETAT ========================
CREATE SEQUENCE public.seq_utilisateurhistoetat START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_utilisateurhistoetat OWNER TO postgres;

CREATE FUNCTION public.get_seq_utilisateurhistoetat() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_utilisateurhistoetat'));
END
$$;
ALTER FUNCTION public.get_seq_utilisateurhistoetat() OWNER TO postgres;

-- ======================== PHOTO ========================
CREATE SEQUENCE public.seq_photo START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_photo OWNER TO postgres;

CREATE FUNCTION public.get_seq_photo() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_photo'));
END
$$;
ALTER FUNCTION public.get_seq_photo() OWNER TO postgres;

-- ======================== PUBLICATION ========================
CREATE SEQUENCE public.seq_publication START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_publication OWNER TO postgres;

CREATE FUNCTION public.get_seq_publication() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_publication'));
END
$$;
ALTER FUNCTION public.get_seq_publication() OWNER TO postgres;

-- ======================== MEDIA ========================
CREATE SEQUENCE public.seq_media START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_media OWNER TO postgres;

CREATE FUNCTION public.get_seq_media() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_media'));
END
$$;
ALTER FUNCTION public.get_seq_media() OWNER TO postgres;

-- ======================== NOTIFICATION (alumni) ========================
-- Nom distinct pour eviter le conflit avec seq_notification du framework APJ
CREATE SEQUENCE public.seq_notifalumni START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_notifalumni OWNER TO postgres;

CREATE FUNCTION public.get_seq_notifalumni() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_notifalumni'));
END
$$;
ALTER FUNCTION public.get_seq_notifalumni() OWNER TO postgres;

-- ======================== IDENTIFICATION ========================
CREATE SEQUENCE public.seq_identification START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_identification OWNER TO postgres;

CREATE FUNCTION public.get_seq_identification() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_identification'));
END
$$;
ALTER FUNCTION public.get_seq_identification() OWNER TO postgres;

-- ======================== PUBLICATIONREACTION ========================
CREATE SEQUENCE public.seq_publicationreaction START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_publicationreaction OWNER TO postgres;

CREATE FUNCTION public.get_seq_publicationreaction() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_publicationreaction'));
END
$$;
ALTER FUNCTION public.get_seq_publicationreaction() OWNER TO postgres;

-- ======================== PUBLICATIONCOMMENTAIRE ========================
CREATE SEQUENCE public.seq_publicationcommentaire START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_publicationcommentaire OWNER TO postgres;

CREATE FUNCTION public.get_seq_publicationcommentaire() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_publicationcommentaire'));
END
$$;
ALTER FUNCTION public.get_seq_publicationcommentaire() OWNER TO postgres;

-- ======================== COMMENTAIREREACTION ========================
CREATE SEQUENCE public.seq_commentairereaction START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_commentairereaction OWNER TO postgres;

CREATE FUNCTION public.get_seq_commentairereaction() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_commentairereaction'));
END
$$;
ALTER FUNCTION public.get_seq_commentairereaction() OWNER TO postgres;

-- ======================== EVENEMENT ========================
CREATE SEQUENCE public.seq_evenement START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_evenement OWNER TO postgres;

CREATE FUNCTION public.get_seq_evenement() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_evenement'));
END
$$;
ALTER FUNCTION public.get_seq_evenement() OWNER TO postgres;

-- ======================== SIGNALEMENTPUBLICATION ========================
CREATE SEQUENCE public.seq_signalementpublication START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_signalementpublication OWNER TO postgres;

CREATE FUNCTION public.get_seq_signalementpublication() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_signalementpublication'));
END
$$;
ALTER FUNCTION public.get_seq_signalementpublication() OWNER TO postgres;
