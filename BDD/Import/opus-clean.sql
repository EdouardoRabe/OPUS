--
-- PostgreSQL database dump
--

-- Dumped from database version 16.12
-- Dumped by pg_dump version 17.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: actiondependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.actiondependante(identite character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare tmp varchar; test varchar;
begin
	select string_agg(case
						when idmere = '' then null
						else idmere
						end, '-') into tmp
	from action
	where idfille = any (string_to_array(identite, '-'));

	if tmp is null then
		return rep;
	else
		select string_agg(unnest,'-') into test from unnest(string_to_array(tmp, '-'))
		where unnest = any (string_to_array(rep, '-'));
		if test is not null then
			return rep;
		end if;

		if rep is null then
			rep = tmp;
		else rep = rep||'-'||tmp;
		end if;

		return actionDependante(tmp, rep);
	end if;
end;
$$;


--
-- Name: basedependance(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.basedependance(idbase character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idfille, ',') into tmp
	 from baserelation
	 where idmere = any (string_to_array(idbase, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return basedependance(tmp, rep);
	 end if;
 end;
 $$;


--
-- Name: basedependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.basedependante(idbase character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idmere, ',') into tmp
	 from baserelation
	 where idfille = any (string_to_array(idbase, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return basedependante(tmp, rep);
	 end if;
 end;
 $$;


--
-- Name: constructabsence(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.constructabsence(utilisateur_ character varying) RETURNS TABLE(id date, absence double precision)
    LANGUAGE plpgsql
    AS $$
declare r record; datytmp date; nbrejourtmp float8; nbrejourtotal float8;
begin
	for r in (select *
				from absence where utilisateur = utilisateur_) loop
																datytmp:= r.datedebut;
																nbrejourtmp:= r.nombrejour;
																nbrejourtotal:=r.nombrejour;
																	loop
																		if isJourFerie(datytmp) = 1 then
																			datytmp:= datytmp + interval '1 day';
																			continue;
																		end if;
																		if nbrejourtmp <=  0 then
																			exit;
																		end if;
																		if nbrejourtmp < 1 then
																			id:=datytmp;
																			absence:= nbrejourtmp;
																			nbrejourtmp:=0;
																		else absence:=0;
																			id:=datytmp;
																			nbrejourtmp:= nbrejourtmp - 1;
																			datytmp:= datytmp + interval '1 day';
																		end if;
																		return next;
																	end loop;
																end loop;
end;
$$;


--
-- Name: constructlistabsence(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.constructlistabsence() RETURNS TABLE(id date, utilisateur character varying, jourperdu double precision)
    LANGUAGE plpgsql
    AS $$
declare 
    r record;
    datytmp date;
    nbrejourtmp float8;
    nbrejourtotal float8;
begin
    for r in (select * from absence) loop
        datytmp := r.datedebut;
        nbrejourtmp := (r.datefin - r.datedebut) + 1;
        nbrejourtotal := nbrejourtmp;
        loop
            if isJourFerie(datytmp) = 1 then
                datytmp := datytmp + interval '1 day';
                continue;
            end if;
            if nbrejourtmp <= 0 then
                exit;
            end if;
            if nbrejourtmp < 1 then
                id := datytmp;
                jourperdu := nbrejourtmp;
                utilisateur := r.utilisateur;
                nbrejourtmp := 0;
            else
                jourperdu := 1;
                id := datytmp;
                utilisateur := r.utilisateur;
                nbrejourtmp := nbrejourtmp - 1;
                datytmp := datytmp + interval '1 day';
            end if;
            return next;
        end loop;
    end loop;
end;
$$;


--
-- Name: entitedependante(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.entitedependante(identite character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare rep varchar; entitefille varchar; actionDependante varchar;
begin
	actionDependante = actionDependante(identite, null);
	if actionDependante is not null and actionDependante != '' then
		rep = actionDependante;
		identite = actionDependante || '-' || identite;
	end if;

	entitefille = entitefille(identite, null);
	if entitefille is not null and entitefille != '' then
		if rep is not null then
			rep = rep || '-' || entitefille;
		else rep = entitefille;
		end if;
	end if;

	return rep;
end;
$$;


--
-- Name: entitefille(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.entitefille(identite character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare tmp varchar;
begin
	select string_agg(id, '-') into tmp
	from entite
	where idmere = any (string_to_array(identite, '-'));
	if tmp is null then
		return rep;
	else
		if rep is null then
			rep = tmp;
		else rep = rep||'-'||tmp;
		end if;
		return entitefille(tmp, rep);
	end if;
end;
$$;


--
-- Name: entitefilleclass(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.entitefilleclass(identite character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare tmp varchar;
begin
	select string_agg(id, '-') into tmp
	from entite
	where idmere = any (string_to_array(identite, '-'))
	and idcategorieniveau = any(select id
								from categorieniveau
								where idniveau = 'CLASS' and lower(val) = lower('class'));
	if tmp is null then
		return rep;
	else
		if rep is null then
			rep = tmp;
		else rep = rep||'-'||tmp;
		end if;
		return entitefilleclass(tmp, rep);
	end if;
end;
$$;


--
-- Name: f_etat_devis(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_etat_devis(p_debut date, p_fin date) RETURNS TABLE(nbdevisafaire integer, nbdevisfait integer, nbdevisvalidehm integer, nbdevisvalideclient integer, nbdevis integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT
                    COUNT(*) FILTER (WHERE etat = 1)::INTEGER,
                    COUNT(*) FILTER (WHERE etat = 20)::INTEGER,
                    COUNT(*) FILTER (WHERE etat = 30)::INTEGER,
                    COUNT(*) FILTER (WHERE etat = 40)::INTEGER,
                    COUNT(*)::INTEGER
        FROM devis
        WHERE
            (p_debut IS NULL OR daty >= p_debut)
          AND
            (p_fin IS NULL OR daty <= p_fin);
END;
$$;


--
-- Name: f_status_projets(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_status_projets(p_debut date, p_fin date) RETURNS TABLE(nbstandby integer, nbencours integer, nbfait integer, nbprojet integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT
                    COUNT(*) FILTER (WHERE etat = 20)::INTEGER,
                    COUNT(*) FILTER (WHERE etat = 30)::INTEGER,
                    COUNT(*) FILTER (WHERE etat = 40)::INTEGER,
                    COUNT(*)::INTEGER
        FROM creation_projet
        WHERE
            (p_debut IS NULL OR fin >= p_debut)
          AND
            (p_fin IS NULL OR debut <= p_fin);
END;
$$;


--
-- Name: format_minutes(double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.format_minutes(total_minutes double precision) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    h int;
    m int;
BEGIN
    h := FLOOR(total_minutes / 60)::int;
    m := MOD(FLOOR(total_minutes), 60)::int;
    RETURN h || 'H ' || m || 'min';
END;
$$;


--
-- Name: format_minutes(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.format_minutes(total_minutes integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    h int;
    m int;
BEGIN
    h := total_minutes / 60;
    m := total_minutes % 60;
    RETURN h || 'H ' || m || 'min';
END;
$$;


--
-- Name: get_seq_absence(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_absence() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_absence'));
END
$$;


--
-- Name: get_seq_actionprojet(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_actionprojet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_ACTIONPROJET'));
        END
    $$;


--
-- Name: get_seq_alert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_alert() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_ALERT'));
END
$$;


--
-- Name: get_seq_boutonchamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_boutonchamp() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_boutonchamp');

END;

$$;


--
-- Name: get_seq_boutonpage(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_boutonpage() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_boutonpage');

END;

$$;


--
-- Name: get_seq_caisse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_caisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_caisse'));
END
$$;


--
-- Name: get_seq_champdynamique(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_champdynamique() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_champdynamique'));

END

$$;


--
-- Name: get_seq_champsspeciaux(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_champsspeciaux() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_champsspeciaux'));

END

$$;


--
-- Name: get_seq_commentairereaction(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_commentairereaction() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_commentairereaction');
END $$;


--
-- Name: get_seq_connexion(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_connexion() RETURNS integer
    LANGUAGE plpgsql
    AS $$ begin return (
select
	nextval('seq_connexion'));
end $$;


--
-- Name: get_seq_coutprevisionnel(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_coutprevisionnel() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COUTPREVISIONNEL'));
        END
    $$;


--
-- Name: get_seq_devis(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_devis() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_DEVIS'));
        END
    $$;


--
-- Name: get_seq_devisfille(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_devisfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_DEVISFILLE'));
        END
    $$;


--
-- Name: get_seq_diplome(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_diplome() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_diplome');
END $$;


--
-- Name: get_seq_entitescript(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_entitescript() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_entitescript'));
		END
		$$;


--
-- Name: get_seq_evenement(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_evenement() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_evenement');
END $$;


--
-- Name: get_seq_exceptiontache(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_exceptiontache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_exceptiontache'));
END
    $$;


--
-- Name: get_seq_experience(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_experience() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_experience');
END $$;


--
-- Name: get_seq_genre(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_genre() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_genre');
END $$;


--
-- Name: get_seq_histoinsert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_histoinsert() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_HistoInsert'));
        END
    $$;


--
-- Name: get_seq_honoraire(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_honoraire() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_HONORAIRE'));
        END
    $$;


--
-- Name: get_seq_identification(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_identification() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_identification');
END $$;


--
-- Name: get_seq_indisponibilite(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_indisponibilite() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN (SELECT nextval('seq_indisponibilite'));

END

$$;


--
-- Name: get_seq_jourrepos(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_jourrepos() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_jourrepos'));
END
$$;


--
-- Name: get_seq_limiterole(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_limiterole() RETURNS character varying
    LANGUAGE sql
    AS $$
    SELECT NEXTVAL('seq_limiterole')::VARCHAR;
$$;


--
-- Name: get_seq_magasin2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_magasin2() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_magasin2'));
END
$$;


--
-- Name: get_seq_mappingtypeattribut(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_mappingtypeattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_mappingtypeattribut');

END;

$$;


--
-- Name: get_seq_media(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_media() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_media');
END $$;


--
-- Name: get_seq_mediatype(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_mediatype() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_mediatype');
END $$;


--
-- Name: get_seq_mention(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_mention() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_mention');
END $$;


--
-- Name: get_seq_module(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_module() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_module'));
        END
    $$;


--
-- Name: get_seq_module_projet(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_module_projet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_module'));
        END
    $$;


--
-- Name: get_seq_niveauclient(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_niveauclient() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_NIVEAUCLIENT'));
        END
    $$;


--
-- Name: get_seq_notification(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_notification() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_notification'));
END
$$;


--
-- Name: get_seq_notificationdetails(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_notificationdetails() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_NotificationDetails'));

END

$$;


--
-- Name: get_seq_notificationgroupe(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_notificationgroupe() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_notificationGroupe'));

END

$$;


--
-- Name: get_seq_notificationsignal(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_notificationsignal() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_notificationSignal'));
END
$$;


--
-- Name: get_seq_option(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_option() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_option');
END $$;


--
-- Name: get_seq_pageanalyse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_pageanalyse() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pageanalyse');

END;

$$;


--
-- Name: get_seq_pageanalyseattribut(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_pageanalyseattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pageanalyseattribut');

END;

$$;


--
-- Name: get_seq_pageattribut(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_pageattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_pageattribut'));

END

$$;


--
-- Name: get_seq_pagefiche(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_pagefiche() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pagefiche');

END;

$$;


--
-- Name: get_seq_pageficheattribut(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_pageficheattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pageficheattribut');

END;

$$;


--
-- Name: get_seq_pageliste(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_pageliste() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pageliste');

END;

$$;


--
-- Name: get_seq_pagelisteattribut(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_pagelisteattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pagelisteattribut');

END;

$$;


--
-- Name: get_seq_pagesaisie(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_pagesaisie() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_pagesaisie'));

END

$$;


--
-- Name: get_seq_panalysechampfiltre(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_panalysechampfiltre() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_panalysechampfiltre');

END;

$$;


--
-- Name: get_seq_parcours(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_parcours() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_parcours');
END $$;


--
-- Name: get_seq_participation_evenement(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_participation_evenement() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_participation_evenement');
END $$;


--
-- Name: get_seq_pays(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_pays() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PAYS'));
        END
    $$;


--
-- Name: get_seq_phaseproject(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_phaseproject() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PHASEPROJECT'));
        END
    $$;


--
-- Name: get_seq_photo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_photo() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_photo');
END $$;


--
-- Name: get_seq_plistchampfiltre(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_plistchampfiltre() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_plistchampfiltre');

END;

$$;


--
-- Name: get_seq_pointage(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_pointage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_pointage'));
        END
    $$;


--
-- Name: get_seq_poste(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_poste() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_poste');
END $$;


--
-- Name: get_seq_profil(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_profil() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_profil');
END $$;


--
-- Name: get_seq_profildiplome(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_profildiplome() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_profildiplome');
END $$;


--
-- Name: get_seq_profilemplacement(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_profilemplacement() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_profilemplacement');
END;
$$;


--
-- Name: get_seq_projetutilisateur(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_projetutilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PROJETUTILISATEUR'));
        END
    $$;


--
-- Name: get_seq_promotion(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_promotion() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_promotion');
END $$;


--
-- Name: get_seq_proposition(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_proposition() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN (SELECT nextval('seq_proposition'));

END

$$;


--
-- Name: get_seq_province(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_province() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PROVINCE'));
        END
    $$;


--
-- Name: get_seq_publication(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_publication() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_publication');
END $$;


--
-- Name: get_seq_publicationcommentaire(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_publicationcommentaire() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_publicationcommentaire');
END $$;


--
-- Name: get_seq_publicationenregistrement(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_publicationenregistrement() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_publicationenregistrement');
END $$;


--
-- Name: get_seq_publicationreaction(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_publicationreaction() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_publicationreaction');
END $$;


--
-- Name: get_seq_qualite(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_qualite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_QUALITE'));
        END
    $$;


--
-- Name: get_seq_reactiontype(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_reactiontype() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_reactiontype');
END $$;


--
-- Name: get_seq_script(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_script() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_script'));
		END
		$$;


--
-- Name: get_seq_scriptversionning(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_scriptversionning() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_scriptversionning'));
		END
		$$;


--
-- Name: get_seq_signalementpublication(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_signalementpublication() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_signalementpublication');
END $$;


--
-- Name: get_seq_specialite(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_specialite() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_specialite');
END $$;


--
-- Name: get_seq_specialiteprofil(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_specialiteprofil() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_specialiteprofil');
END $$;


--
-- Name: get_seq_tache_git_details(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_tache_git_details() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN (SELECT nextval('seq_tache_git_details'));

END

$$;


--
-- Name: get_seq_tache_git_mere(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_tache_git_mere() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN (SELECT nextval('seq_tache_git_mere'));

END

$$;


--
-- Name: get_seq_tauxhonoraire(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_tauxhonoraire() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TAUXHONORAIRE'));
        END
    $$;


--
-- Name: get_seq_tempstravail(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_tempstravail() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_tempstravail'));
END
$$;


--
-- Name: get_seq_timingapplication(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_timingapplication() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TIMINGAPPLICATION'));
        END
    $$;


--
-- Name: get_seq_type_utilisateur(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_type_utilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TYPE_UTILISATEUR'));
        END
    $$;


--
-- Name: get_seq_typechampsspeciaux(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_typechampsspeciaux() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_typechampsspeciaux'));

END

$$;


--
-- Name: get_seq_typemagasin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_typemagasin() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typemagasin'));
END
$$;


--
-- Name: get_seq_typeouinon(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_typeouinon() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_typeouinon'));

END

$$;


--
-- Name: get_seq_typepageliste(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_typepageliste() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_typepageliste');

END;

$$;


--
-- Name: get_seq_typepagesaisie(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_typepagesaisie() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_typepagesaisie'));

END

$$;


--
-- Name: get_seq_typeplistchampfiltre(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_typeplistchampfiltre() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_typeplistchampfiltre');

END;

$$;


--
-- Name: get_seq_typepublication(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_typepublication() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_typepublication');
END $$;


--
-- Name: get_seq_typescript(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_typescript() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_typescript'));
		END
		$$;


--
-- Name: get_seq_typesignalement(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_typesignalement() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_typesignalement');
END $$;


--
-- Name: get_seq_typetache(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_typetache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_typetache'));
        END
    $$;


--
-- Name: get_seq_utilisateurhistoetat(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_utilisateurhistoetat() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_utilisateurhistoetat');
END $$;


--
-- Name: get_seq_visibilite(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seq_visibilite() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_visibilite');
END $$;


--
-- Name: get_seqattacher_fichier(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqattacher_fichier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqattacher_fichier'));
END
$$;


--
-- Name: get_seqbranche(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqbranche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqbranche'));
END
$$;


--
-- Name: get_seqclient(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqclient() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqclient'));
END
$$;


--
-- Name: get_seqdiagramclass(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqdiagramclass() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramClass'));
END
$$;


--
-- Name: get_seqdiagramclasscomposant(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqdiagramclasscomposant() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramClassComposant'));
END
$$;


--
-- Name: get_seqdiagramclasscomposanttype(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqdiagramclasscomposanttype() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramClassComposantType'));
END
$$;


--
-- Name: get_seqdiagramclasspackage(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqdiagramclasspackage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramClassPackage'));
END
$$;


--
-- Name: get_seqdiagramcomposant(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqdiagramcomposant() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramComposant'));
END
$$;


--
-- Name: get_seqdiagrampackage(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqdiagrampackage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramPackage'));
END
$$;


--
-- Name: get_seqdiagramtable(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqdiagramtable() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTable'));
END
$$;


--
-- Name: get_seqdiagramtablecolonne(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqdiagramtablecolonne() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTableColonne'));
END
$$;


--
-- Name: get_seqexecution_script(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqexecution_script() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqEXECUTION_SCRIPT'));
END
$$;


--
-- Name: get_seqexecution_scriptfille(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqexecution_scriptfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqEXECUTION_SCRIPTFILLE'));
END
$$;


--
-- Name: get_seqexternal_work(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqexternal_work() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqexternal_work'));
END
$$;


--
-- Name: get_seqfonctionnalite(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqfonctionnalite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqfonctionnalite'));
END
$$;


--
-- Name: get_seqpage(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqpage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqpage'));
END
$$;


--
-- Name: get_seqparamcrypt(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqparamcrypt() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqparamcrypt'));
END
$$;


--
-- Name: get_seqpiecejointe(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqpiecejointe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqpieceJointe'));
END
$$;


--
-- Name: get_seqprojet(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqprojet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqprojet'));
END
$$;


--
-- Name: get_seqscript_projet(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqscript_projet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqscript_projet'));
END
$$;


--
-- Name: get_seqtachemere(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqtachemere() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqtacheMere'));
END
$$;


--
-- Name: get_seqtachemere_detailsdefaut(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqtachemere_detailsdefaut() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TAUXHONORAIRE'));
        END
    $$;


--
-- Name: get_seqtachemeredefaut(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqtachemeredefaut() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TAUXHONORAIRE'));
        END
    $$;


--
-- Name: get_seqtimingsoustache(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqtimingsoustache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_TIMINGSOUSTACHE'));
END
$$;


--
-- Name: get_seqtypefichier(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqtypefichier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqtypeFichier'));
END
$$;


--
-- Name: get_seqwork_branche(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqwork_branche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqwork_branche'));
END
$$;


--
-- Name: get_seqwork_type(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_seqwork_type() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqwork_type'));
END
$$;


--
-- Name: getattributclasse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getattributclasse() RETURNS integer
    LANGUAGE sql
    AS $$

SELECT nextval('seq_attributclasse')::integer;

$$;


--
-- Name: getcategorieniveau(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getcategorieniveau() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqcategorieniveau'));
END
$$;


--
-- Name: getheuresup(date, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getheuresup(daty_ date, debut_ timestamp without time zone, fin_ timestamp without time zone) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
	declare rep float8;
			dmatin time;
			fmatin time;
			dapresmidi time;
			fapresmidi time;
			refs time;
			refsdebut timestamp;
			refsfin timestamp;
			dmatinref timestamp;
			fmatinref timestamp;
			dapresmidiref timestamp;
			fapresmidiref timestamp;
			tmp timestamp;
begin
	select cast(debutmatin as time), cast(finmatin as time), cast(debutapresmidi as time), cast(finapresmidi as time) into dmatin, fmatin, dapresmidi, fapresmidi
				from tempstravail t where id in(
					select max(id) from "tempstravail" c where daty in (
						select max(daty) from tempstravail where daty<=daty_));
	rep = 0;
	if debut_>=fin_ then
		return rep;
	end if;

	if cast(debut_ as time) >= fapresmidi and cast(fin_ as time) >= fapresmidi and date(debut_) = date(fin_) then
		rep = rep + date_part('epoch'::text, fin_ - debut_)/60;
	elsif cast(debut_ as time) >= fapresmidi and cast(fin_ as time) <= dmatin and date(fin_) = (date(debut_) + '1 day'::interval) then
		rep = rep + date_part('epoch'::text, '24:00'::time - cast(debut_ as time))/60 + date_part('epoch'::text, cast(fin_ as time) - '00:00'::time) /60;
	elsif cast(debut_ as time) <= dmatin and cast(fin_ as time) <= dmatin and date(debut_) = date(fin_) then
	 		rep = rep + date_part('epoch'::text, fin_ - debut_)/60;
	elsif cast(debut_ as time) >= fmatin and cast(debut_ as time) <= dapresmidi and cast(fin_ as time) >= fmatin and cast(fin_ as time) <= dapresmidi and date(debut_) = date(fin_) then
			rep = rep + date_part('epoch'::text, fin_ - debut_)/60;
	else
		refs = cast(debut_ as time);
		refsdebut = date(debut_);
		if refs = dmatin or refs = fmatin or refs = dapresmidi or refs = fapresmidi then
			refsdebut = debut_;
		else
			if refs>=fapresmidi or refs<=dmatin then
				if refs<='24:00'::time and refs>=fapresmidi then
					rep = rep + date_part('epoch'::text, '24:00'::time - refs)/60;
					refs = '00:00'::time;
					refsdebut = refsdebut  + '1 day'::interval;
				end if;
				if refs<=dmatin and refs>='00:00'::time then
					rep = rep + date_part('epoch'::text, dmatin - refs)/60;
					refsdebut = refsdebut + dmatin;
				end if;
			end if;
			if refs>=fmatin and refs<=dapresmidi then
				if refs != dapresmidi then
					rep = rep + date_part('epoch'::text, dapresmidi - refs)/60;
				end if;
				refsdebut = refsdebut + dapresmidi;
			end if;
			if refs>=dmatin and refs<=fmatin then
				refsdebut = refsdebut + fmatin;
			end if;
			if refs>=dapresmidi and refs<=fapresmidi then
				refsdebut = refsdebut + fapresmidi;
			end if;
		end if;

		refs = cast (fin_ as time);
		refsfin = date(fin_);
		if refs>=fapresmidi or refs<=dmatin then
			if refs<=dmatin and refs>='00:00'::time then
				rep = rep + date_part('epoch'::text, refs - '00:00'::time)/60;
				refs = '24:00'::time;
				refsfin = refsfin - '1 day'::interval;
			end if;
			if refs<='24:00'::time and refs>=fapresmidi then
				rep = rep + date_part('epoch'::text, refs - fapresmidi)/60;
				refsfin = refsfin + fapresmidi;
			end if;
		end if;
		if refs>=fmatin and refs<=dapresmidi then
			if refs != dapresmidi then
				rep = rep + date_part('epoch'::text, refs - fmatin)/60;
			end if;
			refsfin = refsfin + fmatin;
		end if;
		if refs>=dmatin and refs<=fmatin then
			refsfin = refsfin + dmatin;
		end if;
		if refs>=dapresmidi and refs<=fapresmidi then
			refsfin = refsfin + dapresmidi;
		end if;

		tmp = date(refsdebut);
		loop
				if date(refsfin) < tmp then
					exit;
				end if;
				dmatinref = tmp::timestamp + dmatin;
				fmatinref = tmp::timestamp + fmatin;
				dapresmidiref = tmp::timestamp + dapresmidi;
				fapresmidiref = tmp::timestamp + fapresmidi;
				if fmatinref>=refsdebut and dapresmidiref<=refsfin then
					rep = rep + date_part('epoch'::text, dapresmidiref - fmatinref)/60;
				end if;
				if fapresmidiref>=refsdebut and ((date(fapresmidiref) + '1 day'::interval)::timestamp + dmatin)<=refsfin then
					rep = rep + date_part('epoch'::text, ((date(fapresmidiref) + '1 day'::interval)::timestamp + dmatin) - fapresmidiref)/60;
				end if;
				tmp = tmp + '1 day'::interval;
		end loop;
	end if;

	return rep;
end;
$$;


--
-- Name: getheuretravailmax(date, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getheuretravailmax(daty_ date, unite character varying) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
	declare rep float8;
			dmatin time;
			fmatin time;
			dapresmidi time;
			fapresmidi time;

begin
	select cast(debutmatin as time), cast(finmatin as time), cast(debutapresmidi as time), cast(finapresmidi as time) into dmatin, fmatin, dapresmidi, fapresmidi
				from tempstravail t where id in(
					select max(id) from "tempstravail" c where daty in (
						select max(daty) from tempstravail where daty<=daty_));
	rep = 0;
	rep = (date_part('epoch'::text, fmatin - dmatin)/60) + date_part('epoch'::text, fapresmidi - dapresmidi)/60;

	if unite = 'h' then
		rep = rep/60;
	end if;
	return rep;
end;
$$;


--
-- Name: getseq_analyses(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_analyses() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN (SELECT nextval('seq_analyses'));

END;

$$;


--
-- Name: getseq_apjclasse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_apjclasse() RETURNS integer
    LANGUAGE sql
    AS $$

SELECT nextval('seq_apjclasse')::integer;

$$;


--
-- Name: getseq_attacher_fichier(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_attacher_fichier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqattacher_fichier'));
END
$$;


--
-- Name: getseq_attribusentite(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_attribusentite() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_attribusentite')::integer;

$$;


--
-- Name: getseq_attributoracle(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_attributoracle() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_attributoracle')::integer;

$$;


--
-- Name: getseq_attributpostgres(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_attributpostgres() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_attributpostgres')::integer;

$$;


--
-- Name: getseq_attributtype(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_attributtype() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_attributtype')::integer;

$$;


--
-- Name: getseq_cheminprojetuser(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_cheminprojetuser() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_cheminprojetuser')::integer;

$$;


--
-- Name: getseq_diagramaffichage(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_diagramaffichage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramAffichage'));
END
$$;


--
-- Name: getseq_diagramtable(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_diagramtable() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTable'));
END
$$;


--
-- Name: getseq_diagramtablecolonne(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_diagramtablecolonne() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTableColonne'));
END
$$;


--
-- Name: getseq_histoinsert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_histoinsert() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    retour BIGINT;
BEGIN
    SELECT nextval('seq_histoinsert') INTO retour;
    RETURN retour;
END;
$$;


--
-- Name: getseq_proposition(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_proposition() RETURNS integer
    LANGUAGE sql
    AS $$
SELECT nextval('seq_proposition')::integer;
$$;


--
-- Name: getseq_relation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_relation() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_relation')::integer;

$$;


--
-- Name: getseq_serveur(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_serveur() RETURNS integer
    LANGUAGE sql
    AS $$
     SELECT nextval('seq_serveur')::integer;
$$;


--
-- Name: getseq_typeclasse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_typeclasse() RETURNS integer
    LANGUAGE sql
    AS $$

SELECT nextval('seq_typeclasse')::integer;

$$;


--
-- Name: getseq_typedependancediagram(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_typedependancediagram() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typeDependanceDiagram'));
END
$$;


--
-- Name: getseq_typedependanceobjet(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_typedependanceobjet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typeDependanceObjet'));
END
$$;


--
-- Name: getseq_typeliaison(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_typeliaison() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_typeliaison')::integer;

$$;


--
-- Name: getseq_typerelation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_typerelation() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_typerelation')::integer;

$$;


--
-- Name: getseq_v_classeetfiche(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_v_classeetfiche() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    retour BIGINT;
BEGIN
    SELECT nextval('seq_v_classeetfiche') INTO retour;
    RETURN retour;
END;
$$;


--
-- Name: getseq_v_classetfiche(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseq_v_classetfiche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_v_ClassEtFiche'));
        END
    $$;


--
-- Name: getseqaction(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqaction() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqaction'));
END
$$;


--
-- Name: getseqactiontache(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqactiontache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqactionTache'));
END
$$;


--
-- Name: getseqarchitecture(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqarchitecture() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqarchitecture'));
 END
 $$;


--
-- Name: getseqavoirfc(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqavoirfc() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQAVOIRFC'));
END
$$;


--
-- Name: getseqavoirfcfille(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqavoirfcfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQAVOIRFCFILLE'));
END
$$;


--
-- Name: getseqbase(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqbase() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqbase'));
 END
 $$;


--
-- Name: getseqbaserelation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqbaserelation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqbaserelation'));
 END
 $$;


--
-- Name: getseqbranche(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqbranche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_branche'));
		END
		$$;


--
-- Name: getseqcaisse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQCAISSE'));
END
$$;


--
-- Name: getseqcanevatache(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcanevatache() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN nextval('seqCanevaTache');
END;
$$;


--
-- Name: getseqcateging(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcateging() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQCATEGING'));
END
$$;


--
-- Name: getseqcategorie(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcategorie() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('Seqcategorie'));
END;
$$;


--
-- Name: getseqcategorieavoirfc(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcategorieavoirfc() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQCATEGORIEAVOIRFC'));
END
$$;


--
-- Name: getseqcategoriecaisse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcategoriecaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqcategoriecaisse'));
END
$$;


--
-- Name: getseqclasse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqclasse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_classe'));
END
$$;


--
-- Name: getseqclient(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqclient() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqclient'));
END
$$;


--
-- Name: getseqcnapsuser(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcnapsuser() RETURNS bigint
    LANGUAGE sql
    AS $$
SELECT nextval('cnapsuser_id_seq');
$$;


--
-- Name: getseqcomptaclassecompte(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptaclassecompte() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTACLASSECOMPTE'));
        END
    $$;


--
-- Name: getseqcomptacompte(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptacompte() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTACOMPTE'));
        END
    $$;


--
-- Name: getseqcomptacomptebackup(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptacomptebackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTACOMPTEBACKUP'));
        END
    $$;


--
-- Name: getseqcomptaecriture(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptaecriture() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAECRITURE'));
        END
    $$;


--
-- Name: getseqcomptaecriturebackup(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptaecriturebackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAECRITUREBACKUP'));
        END
    $$;


--
-- Name: getseqcomptaexercice(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptaexercice() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAEXERCICE'));
        END
    $$;


--
-- Name: getseqcomptajournal(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptajournal() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAJOURNAL'));
        END
    $$;


--
-- Name: getseqcomptajournalbackup(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptajournalbackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAJOURNALBACKUP'));
        END
    $$;


--
-- Name: getseqcomptalettrage(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptalettrage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTALETTRAGE'));
        END
    $$;


--
-- Name: getseqcomptaorigine(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptaorigine() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAORIGINE'));
        END
    $$;


--
-- Name: getseqcomptasousecriture(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptasousecriture() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTASOUSECRITURE'));
        END
    $$;


--
-- Name: getseqcomptasousecriturebackup(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptasousecriturebackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTASOUSECRITUREBACKUP'));
        END
    $$;


--
-- Name: getseqcomptatypecompte(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcomptatypecompte() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTATYPECOMPTE'));
        END
    $$;


--
-- Name: getseqconception_pm(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqconception_pm() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_Conception_PM'));
END
$$;


--
-- Name: getseqcote(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcote() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqCote'));
END;
$$;


--
-- Name: getseqcrcontent(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcrcontent() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqCRContent')); END $$;


--
-- Name: getseqcrcontentfille(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcrcontentfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqCRContentFille')); END $$;


--
-- Name: getseqcreation_projet(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqcreation_projet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqCreation_projet'));
END;
$$;


--
-- Name: getseqdeploiement(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqdeploiement() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_deploiement'));
		END
		$$;


--
-- Name: getseqdevise(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqdevise() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqdevise'));
END
$$;


--
-- Name: getseqentite(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqentite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqentite'));
END
$$;


--
-- Name: getseqequipe(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqequipe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqequipe'));
END;
$$;


--
-- Name: getseqexecutions(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqexecutions() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN nextval('seqphase');  -- gets the next value from the sequence
END;
$$;


--
-- Name: getseqfonctionnalite(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqfonctionnalite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqfonctionnalite'));
END
$$;


--
-- Name: getseqfournisseur(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqfournisseur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQFOURNISSEUR'));
END
$$;


--
-- Name: getseqhistoimport(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqhistoimport() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqhistoimport'));
END
    $$;


--
-- Name: getseqhistorique(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqhistorique() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('seqhistorique'));
END;
$$;


--
-- Name: getseqhistoriqueactif(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqhistoriqueactif() RETURNS bigint
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN nextval('seqHistoriqueActif');

END;

$$;


--
-- Name: getseqhistovaleur(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqhistovaleur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('seqhistovaleur'));
END;
$$;


--
-- Name: getseqingredients(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqingredients() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQINGREDIENTS'));
END
$$;


--
-- Name: getseqmagasin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqmagasin() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQMAGASIN'));
END
$$;


--
-- Name: getseqmailcc(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqmailcc() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqmailcc'));
 END
 $$;


--
-- Name: getseqmailrapport(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqmailrapport() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqMailRapport')); END $$;


--
-- Name: getseqmetier(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqmetier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqmetier'));
 END
 $$;


--
-- Name: getseqmetierfille(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqmetierfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_MetierFille'));
END
$$;


--
-- Name: getseqmetierrelation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqmetierrelation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqmetierrelation'));
 END
 $$;


--
-- Name: getseqmodule(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqmodule() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_module'));
        END
    $$;


--
-- Name: getseqmotifavoirfc(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqmotifavoirfc() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQMOTIFAVOIRFC'));
END
$$;


--
-- Name: getseqmouvementcaisse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqmouvementcaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQMOUVEMENTCAISSE'));
END
$$;


--
-- Name: getseqmvtcaisseprevision(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqmvtcaisseprevision() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqmvtcaisseprevision'));
END
$$;


--
-- Name: getseqniveau(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqniveau() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqniveau'));
END
$$;


--
-- Name: getseqnotificationaction(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqnotificationaction() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqnotificationAction'));
END
$$;


--
-- Name: getseqordonnerpaiement(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqordonnerpaiement() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqordonnerpaiement'));
END
$$;


--
-- Name: getseqpagerelation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqpagerelation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqpagerelation'));
 END
 $$;


--
-- Name: getseqparamcrypt(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqparamcrypt() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqparamcrypt'));
END
$$;


--
-- Name: getseqpoint(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqpoint() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQPOINT'));
END
$$;


--
-- Name: getseqprevision(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqprevision() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQPREVISION'));
END
$$;


--
-- Name: getseqproequipe(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqproequipe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqprojetequipe'));
END;
$$;


--
-- Name: getseqprofilsocialmedia(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqprofilsocialmedia() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN nextval('seq_profilsocialmedia');
END $$;


--
-- Name: getseqprofilstatut(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqprofilstatut() RETURNS character varying
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN 'PS' || lpad(nextval('seq_profilstatut')::text, 5, '0');
END;
$$;


--
-- Name: getseqprofiltypestatut(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqprofiltypestatut() RETURNS character varying
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN 'PTS' || lpad(nextval('seq_profiltypestatut')::text, 5, '0');
END;
$$;


--
-- Name: getseqpromesse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqpromesse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqpromesse'));
END
$$;


--
-- Name: getseqrepartition(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqrepartition() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqrep'));
END
$$;


--
-- Name: getseqrepartitiondet(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqrepartitiondet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqrepd'));
END
$$;


--
-- Name: getseqreportcaisse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqreportcaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqreportcaisse'));
END
$$;


--
-- Name: getseqrequeteaenvoyer(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqrequeteaenvoyer() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_REQUETEAENVOYER'));
        END
    $$;


--
-- Name: getseqsource(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqsource() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqsource'));
END
$$;


--
-- Name: getseqtache(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqTache'));
END;
$$;


--
-- Name: getseqtauxavancementmodule(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtauxavancementmodule() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seqTauxAvancementModule'));

END

    $$;


--
-- Name: getseqtauxavancementprojet(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtauxavancementprojet() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seqTauxAvancementProjet'));

END

    $$;


--
-- Name: getseqtauxdechange(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtauxdechange() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqtauxdechange'));
END
$$;


--
-- Name: getseqtype(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtype() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqType'));
END;
$$;


--
-- Name: getseqtypeabsence(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtypeabsence() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqtypeabsence'));
END
$$;


--
-- Name: getseqtypeaction(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtypeaction() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqtypeaction'));
END
$$;


--
-- Name: getseqtypeactionmetier(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtypeactionmetier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typeactionmetier'));
END
$$;


--
-- Name: getseqtypebase(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtypebase() RETURNS integer
    LANGUAGE plpgsql
    AS $$    

BEGIN

RETURN (SELECT nextval('seqtypebase'));	

END

$$;


--
-- Name: getseqtypecaisse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtypecaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQTYPECAISSE'));
END
$$;


--
-- Name: getseqtypemetier(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtypemetier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqtypemetier'));
 END
 $$;


--
-- Name: getseqtypepage(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtypepage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqtypepage'));
 END
 $$;


--
-- Name: getseqtyperepos(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtyperepos() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqtyperepos'));
END
$$;


--
-- Name: getseqtypetache(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqtypetache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_typetache'));
        END
    $$;


--
-- Name: getsequdonation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getsequdonation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seqdonation'));
        END
    $$;


--
-- Name: getsequnite(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getsequnite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQUNITE'));
END
$$;


--
-- Name: getsequserequipe(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getsequserequipe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('sequserequipe'));
END;
$$;


--
-- Name: getsequtilisateur(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getsequtilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('sequtilisateur'));
END;
$$;


--
-- Name: getseqvente(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqvente() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQVENTE'));
END
$$;


--
-- Name: getseqventedetails(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getseqventedetails() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQVENTEDETAILS'));
END
$$;


--
-- Name: gettypeattributclasse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gettypeattributclasse() RETURNS integer
    LANGUAGE sql
    AS $$

SELECT nextval('seq_typeattributclasse')::integer;

$$;


--
-- Name: gettypefournisseur(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gettypefournisseur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQTYPEFOURNISSEUR'));
END
$$;


--
-- Name: isferie(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.isferie(daty_ date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	declare rep varchar;
begin
	select valeur into rep from jourreposferie where valeur = daty_::varchar and daty<=daty_;
	if rep is null	then
		return 0;
	end if;
	return 1;
end;
$$;


--
-- Name: isferieweekend(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.isferieweekend(daty_ date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	declare rep varchar;
begin
	select max(id) into rep from "jourreposweekend" c where daty in (
															select max(daty) from jourreposweekend where daty<=daty_ and valeur = extract(isodow from daty_)::varchar) and valeur = extract(isodow from daty_)::varchar;
	if rep is null	then
		return 0;
	end if;
	return 1;
end;
$$;


--
-- Name: isjourferie(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.isjourferie(daty_ date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
	if isFerie(daty_) = 1 then
		return 1;
	end if;
	if isFerieWeekEnd(daty_) = 1 then
		return 1;
	end if;
	return 0;
end;
$$;


--
-- Name: metierdependance(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.metierdependance(idmetier character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idfille, ',') into tmp
	 from metierrelation
	 where idmere = any (string_to_array(idmetier, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return metierdependance(tmp, rep);
	 end if;
 end;
 $$;


--
-- Name: metierdependancecomplet(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.metierdependancecomplet(idmetier character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare rep varchar; metierdependance varchar; metiermere varchar; metiermeredep varchar;
 begin
	 metiermere = metiermere(idmetier, null);
	if metiermere is not null and metiermere != '' then
		rep = metiermere;
	end if;

	metierdependance = metierdependance(idmetier, null);
	if metierdependance is not null and metierdependance != '' then
		if rep is not null then
			rep = rep || ',' || metierdependance;
		else rep = metierdependance;
		end if;
		metiermeredep = metiermere(metierdependance, null);
		if metiermeredep is not null and metiermeredep != '' then
			rep = rep || ',' || metiermeredep;
		end if;
	end if;
	return rep;
 end;
 $$;


--
-- Name: metierdependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.metierdependante(idmetier character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idmere, ',') into tmp
	 from metierrelationlib
	 where idfille = any (string_to_array(idmetier, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return metierdependante(tmp, rep);
	 end if;
 end;
 $$;


--
-- Name: metierdependantecomplet(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.metierdependantecomplet(idmetier character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare rep varchar; metierdependante varchar; metierfille varchar;
 begin
	 metierdependante = metierdependante(idmetier, null);
	if metierdependante is not null and metierdependante != '' then
		rep = metierdependante;
		idmetier = idmetier || ',' || metierdependante;
	end if;

	metierfille = metierfille(idmetier, null);
	if metierfille is not null and metierfille != '' then
		if rep is not null then
			rep = rep || ',' || metierfille;
		else rep = metierfille;
		end if;
	end if;
	return rep;
 end;
 $$;


--
-- Name: metierfille(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.metierfille(idmetier character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar;
 begin
	 select string_agg(id, ',') into tmp
	 from metierlib
	 where idmere = any (string_to_array(idmetier, ','));
	 if tmp is null then
		 return rep;
	 else
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return metierfille(tmp, rep);
	 end if;
 end;
 $$;


--
-- Name: metiermere(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.metiermere(idmetier character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar;
 begin
	 select string_agg(idmere, ',') into tmp
	 from metier
	 where id = any (string_to_array(idmetier, ','));
	 if tmp is null then
		 return rep;
	 else
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return metiermere(tmp, rep);
	 end if;
 end;
 $$;


--
-- Name: nombreutilisateur(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.nombreutilisateur(role character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare rep int;
begin
	select count(refuser) into rep from utilisateur where idrole = role;
	return rep;
end;
$$;


--
-- Name: pagedependance(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pagedependance(idpage character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idfille, ',') into tmp
	 from pagerelation
	 where idmere = any (string_to_array(idpage, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;

		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return pagedependance(tmp, rep);
	 end if;
 end;
 $$;


--
-- Name: pagedependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pagedependante(idpage character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idmere, ',') into tmp
	 from pagerelation
	 where idfille = any (string_to_array(idpage, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return pagedependante(tmp, rep);
	 end if;
 end;
 $$;


--
-- Name: propositionestimation(character varying, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propositionestimation(cote_ character varying, type_ character varying, niveau_ integer, responsable_ character varying) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
declare tempspasse_ float8;
begin
		select tempspasse into tempspasse_
		from moyenneTempsTacheResponsable
		where cote = cote_ and type = type_ and niveau = niveau_ and responsable = responsable_;

		if tempspasse_ is null then
			select tempspasse into tempspasse_
			from moyenneTempsTacheDefaut
			where cote = cote_ and type = type_ and niveau = niveau_;
		end if;

		if tempspasse_ is null then
			if niveau_>=0 then
				return propositionEstimation(cote_, type_, (niveau_ - 1), responsable_) + (30::numeric/60::numeric);
			end if;
			return (10::numeric/60::numeric);
		elsif tempspasse_ < (3::numeric/60::numeric) then
			return (3::numeric/60::numeric);
		else return tempspasse_;
		end if;
end;
$$;


--
-- Name: propositionestimation(character varying, character varying, integer, character varying, date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propositionestimation(cote_ character varying, type_ character varying, niveau_ integer, responsable_ character varying, datymin date, datymax date) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
declare tempspasse_ float8;
begin
		if datymin is null then
			datymin = '1940-01-01';
		end if;
		if datymax is null then
			datymax = now();
		end if;

		select avg(dureetachedouble) as tempspasse, cote, type, responsable, niveau into tempspasse_
		from tache_libcompletformat tl
		where etatfille != 80 and responsable is not null and responsable != ''
				and fin is not null and debut is not null
				and cote = cote_ and type = type_ and niveau = niveau_ and responsable = responsable_
				and daty>=datymin and daty<=datymax
		group by cote, type, responsable, niveau;


		if tempspasse_ is null then
			select  avg(dureetachedouble) as tempspasse, cote, type, niveau into tempspasse_
			from tache_libcompletformat tl
			where etatfille != 80 and responsable is not null and responsable != ''
				and fin is not null and debut is not null
				and cote = cote_ and type = type_ and niveau = niveau_
				and daty>=datymin and daty<=datymax
			group by cote, type, niveau;
		end if;

		if tempspasse_ is null then
			if niveau_>=0 then
				return propositionEstimation(cote_, type_, (niveau_ - 1), responsable_, datymin, datymax) + (30::numeric/60::numeric);
			end if;
			return (10::numeric/60::numeric);
		elsif tempspasse_ < (3::numeric/60::numeric) then
			return (3::numeric/60::numeric);
		else return tempspasse_;
		--else return round(tempspasse_::numeric, 0);
		end if;
end;
$$;


--
-- Name: set_idattribut_self(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_idattribut_self() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    IF NEW.idattribut = 'no_id' THEN

        NEW.idattribut := NEW.id;

    END IF;

    RETURN NEW;

END;

$$;


--
-- Name: set_idliaison_relation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_idliaison_relation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    IF NEW.idliaison = 'no_id' THEN

        NEW.idliaison := NEW.idrelation;

    END IF;

    RETURN NEW;

END;

$$;


--
-- Name: set_idmere_self(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_idmere_self() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    IF NEW.idmere = 'no_id' THEN

        NEW.idmere := NEW.id;

    END IF;

    RETURN NEW;

END;

$$;


--
-- Name: tachedependance(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tachedependance(idtache_ character varying) RETURNS TABLE(id character varying)
    LANGUAGE plpgsql
    AS $$
declare r record;
begin
	for r in(select idtache, idmere, idfille
	from actionTacheLibvalide
	where (idtype = 'CREER' or idtype='MODIF') and idtache!=idtache_ and ((idmere in(
	select unnest(
			case
				when idtype = 'USAGE' then array[idmere::varchar, idfille::varchar]
				else
					case
						when (idmere is not null and idmere != '') and (idfille is not null and idfille != '') then array[idfille::varchar]
						when (idmere is null or (idmere is not null and idmere = '')) and (idfille is not null and idfille != '') then array[idfille::varchar]
						when (idfille is null or (idfille is not null and idfille = '')) and (idmere is not null and idmere != '') then array[idmere::varchar]
					end
			end
			)
	from actionTacheLibvalide
	where idtache = idtache_)) or ((idmere = '' or idmere is null) and idfille in(
	select unnest(
			case
				when idtype = 'USAGE' then array[idmere::varchar, idfille::varchar]
				else
					case
						when (idmere is not null and idmere != '') and (idfille is not null and idfille != '') then array[idfille::varchar]
						when (idmere is null or (idmere is not null and idmere = '')) and (idfille is not null and idfille != '') then array[idfille::varchar]
						when (idfille is null or (idfille is not null and idfille = '')) and (idmere is not null and idmere != '') then array[idmere::varchar]
					end
			end
			)
	from actionTacheLibvalide
	where idtache = idtache_)))) loop
									id:=r.idtache;
									return next;
								end loop;
end;
$$;


--
-- Name: v_allocation_charges_all(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.v_allocation_charges_all(date_debut date, date_fin date) RETURNS TABLE(idutilisateur character varying, nomutilisateur character varying, idtypeutilisateur character varying, typeutilisateur character varying, nombretache integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT
            u.refuser::VARCHAR AS idutilisateur,
            u.nomuser AS nomutilisateur,
            u.idtypeutilisateur,
            tu.val AS typeutilisateur,
            COUNT(t.id)::INTEGER AS nombretache
        FROM
            tache t
                JOIN utilisateur u ON t.responsable::TEXT = u.refuser::VARCHAR::TEXT
                LEFT JOIN type_utilisateur tu ON u.idtypeutilisateur::TEXT = tu.id::TEXT
                LEFT JOIN tachemere tm ON t.idmere::TEXT = tm.id::TEXT
                LEFT JOIN creation_projet cp ON tm.projet::TEXT = cp.id::TEXT
                AND (
                    (date_debut IS NULL AND date_fin IS NULL)
                        OR (
                        (date_debut IS NOT NULL AND date_fin IS NOT NULL) AND (
                            (cp.debut BETWEEN date_debut AND date_fin)
                                OR (cp.fin BETWEEN date_debut AND date_fin)
                                OR (cp.debut <= date_debut AND cp.fin >= date_fin)
                                OR (cp.debut IS NULL AND cp.fin IS NULL)
                            )
                        )
                    )
        GROUP BY u.refuser, u.nomuser, u.idtypeutilisateur, tu.val
        ORDER BY COUNT(t.id) DESC
        LIMIT 10;
END;
$$;


--
-- Name: v_phase_projets(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.v_phase_projets(date_debut date, date_fin date) RETURNS TABLE(idphase character varying, nomphase character varying, nbprojet integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT
            ph.id AS idphase,
            ph.val AS nomphase,
            COUNT(p.id)::INTEGER AS nbprojet
        FROM
            phase ph
                LEFT JOIN creation_projet p
                          ON p.phase::TEXT = ph.id::TEXT
                              AND (
                                 -- Si les deux dates sont null, on prend tout
                                 (date_debut IS NULL AND date_fin IS NULL)

                                     -- Sinon, on applique les conditions de chevauchement
                                     OR (
                                     (date_debut IS NOT NULL AND date_fin IS NOT NULL) AND (
                                         (p.debut BETWEEN date_debut AND date_fin)
                                             OR (p.fin BETWEEN date_debut AND date_fin)
                                             OR (p.debut <= date_debut AND p.fin >= date_fin)
                                             OR (p.debut IS NULL AND p.fin IS NULL)
                                         )
                                     )
                                 )
        GROUP BY ph.id, ph.val
        ORDER BY ph.id;
END;
$$;


--
-- Name: cnapsuser_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cnapsuser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: commentairereaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commentairereaction (
    idcommentairereaction character varying(20) NOT NULL,
    idutilisateur integer NOT NULL,
    idpublicationcommentaire character varying(20) NOT NULL,
    idreactiontype character varying(50) NOT NULL
);


--
-- Name: crdateformu; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.crdateformu AS
 SELECT ('now'::text)::date AS daty;


--
-- Name: decalageprevision; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.decalageprevision AS
 SELECT ''::text AS id,
    ''::text AS idprevision,
    ''::text AS iddevise,
    (0)::numeric(30,2) AS debit,
    (0)::numeric(30,2) AS credit,
    NULL::date AS datynouveau;


--
-- Name: diplome; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diplome (
    iddiplome character varying(20) NOT NULL,
    libelle character varying(250) NOT NULL
);


--
-- Name: direction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.direction (
    id character varying(50) NOT NULL,
    val character varying(100),
    desce character varying(200)
);


--
-- Name: evenement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evenement (
    idevenement character varying(20) NOT NULL,
    description text,
    daty date NOT NULL,
    datefin date,
    datedebut date NOT NULL,
    idutilisateur integer NOT NULL
);


--
-- Name: experience; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.experience (
    idexperience character varying(20) NOT NULL,
    entreprise character varying(500) NOT NULL,
    debut date NOT NULL,
    fin date NOT NULL,
    description text,
    etat integer NOT NULL,
    idprofil character varying(20) NOT NULL,
    idposte character varying(20) NOT NULL
);


--
-- Name: poste; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.poste (
    idposte character varying(20) NOT NULL,
    libelle character varying(150) NOT NULL
);


--
-- Name: profil; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profil (
    idprofil character varying(20) NOT NULL,
    email character varying(250),
    nom character varying(450) NOT NULL,
    prenom character varying(450) NOT NULL,
    dtn date NOT NULL,
    telephone character varying(250) NOT NULL,
    idpromotion character varying(20) NOT NULL,
    idparcours character varying(20) NOT NULL,
    idutilisateur integer NOT NULL,
    idgenre character varying(20) NOT NULL,
    cv character varying(150)
);


--
-- Name: experiencelib; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.experiencelib AS
 SELECT e.idexperience,
    e.entreprise,
    e.debut,
    e.fin,
    e.description,
    e.etat,
    e.idprofil,
    e.idposte,
    p.libelle AS postelib,
    pr.idutilisateur
   FROM ((public.experience e
     LEFT JOIN public.poste p ON (((p.idposte)::text = (e.idposte)::text)))
     LEFT JOIN public.profil pr ON (((pr.idprofil)::text = (e.idprofil)::text)));


--
-- Name: generate_series; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.generate_series AS
 SELECT NULL::character varying AS id,
    NULL::character varying AS val,
    NULL::character varying AS desce,
    NULL::double precision AS max,
    NULL::integer AS droppable;


--
-- Name: genre; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genre (
    idgenre character varying(20) NOT NULL,
    libelle character varying(50)
);


--
-- Name: histoinsert; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.histoinsert (
    idhistorique character varying(20) NOT NULL,
    datehistorique date,
    heure character varying(25),
    objet character varying(100),
    action character varying(50),
    idutilisateur character varying(255) NOT NULL,
    refobjet character varying(255),
    remarque character varying(255)
);


--
-- Name: historique; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.historique (
    idhistorique character varying(50) NOT NULL,
    datehistorique date,
    heure character varying(50),
    objet character varying(100),
    action character varying(50),
    idutilisateur character varying(50),
    refobjet character varying(50)
);


--
-- Name: historiqueactif; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.historiqueactif (
    id character varying(250) NOT NULL,
    idutilisateur character varying(250),
    estactif integer,
    daty timestamp without time zone,
    description character varying(250)
);


--
-- Name: historiqueactiflib; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.historiqueactiflib AS
 SELECT id,
    idutilisateur,
    estactif,
    daty,
        CASE
            WHEN (estactif = 0) THEN 'Inactif'::text
            WHEN (estactif = 1) THEN 'Actif'::text
            ELSE 'Inconnu'::text
        END AS estactiflib,
    description
   FROM public.historiqueactif;


--
-- Name: identification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identification (
    ididentification character varying(20) NOT NULL,
    idutilisateur integer NOT NULL,
    idpublication character varying(20) NOT NULL
);


--
-- Name: limiterole; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.limiterole (
    idlimiterole character varying(20) NOT NULL,
    idrole character varying(20) NOT NULL,
    maxpublicationparjour integer DEFAULT 0 NOT NULL,
    daty date DEFAULT CURRENT_DATE NOT NULL,
    heure character varying(20) DEFAULT to_char(CURRENT_TIMESTAMP, 'HH24:MI:SS'::text) NOT NULL
);


--
-- Name: media; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media (
    idmedia character varying(20) NOT NULL,
    mediaurl text NOT NULL,
    idmediatype character varying(20) NOT NULL,
    idpublication character varying(20) NOT NULL
);


--
-- Name: mediatype; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mediatype (
    idmediatype character varying(20) NOT NULL,
    libelle character varying(50) NOT NULL
);


--
-- Name: mention; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mention (
    idmention character varying(20) NOT NULL,
    idutilisateur integer NOT NULL,
    idpublicationcommentaire character varying(20) NOT NULL
);


--
-- Name: menudynamique; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menudynamique (
    id character varying(50) NOT NULL,
    libelle character varying(50),
    icone character varying(250),
    href character varying(250),
    rang integer,
    niveau integer,
    id_pere character varying(50)
);


--
-- Name: menu_fils; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.menu_fils AS
 SELECT id,
    libelle,
    icone,
    href,
    rang,
    niveau,
    id_pere
   FROM public.menudynamique
  WHERE ((href)::text <> '#'::text);


--
-- Name: menudynamiquelib; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.menudynamiquelib AS
 SELECT mf.id,
    ((((mf.libelle)::text || ' '::text) || (menu.libelle)::text))::character varying(200) AS libelle,
    mf.icone,
    mf.href,
    mf.rang,
    mf.niveau,
    mf.id_pere
   FROM (public.menu_fils mf
     JOIN public.menudynamique menu ON (((menu.id)::text = (mf.id_pere)::text)));


--
-- Name: notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification (
    idnotification character varying(20) NOT NULL,
    objet character varying(250) NOT NULL,
    daty date NOT NULL,
    idorigine character varying(50),
    lien text,
    etat integer NOT NULL,
    heure character varying(50) NOT NULL,
    typenotif character varying(50),
    idutilisateur integer NOT NULL
);


--
-- Name: option; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.option (
    idoption character varying(50) NOT NULL,
    libelle character varying(250) NOT NULL
);


--
-- Name: paramcrypt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paramcrypt (
    id character varying(100) NOT NULL,
    niveau integer,
    croissante integer,
    idutilisateur character varying(100)
);


--
-- Name: parcours; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parcours (
    idparcours character varying(20) NOT NULL,
    libelle character varying(250) NOT NULL
);


--
-- Name: participation_evenement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.participation_evenement (
    idparticipation character varying(20) NOT NULL,
    idevenement character varying(20) NOT NULL,
    idutilisateur integer NOT NULL,
    dateparticipation date DEFAULT CURRENT_DATE NOT NULL
);


--
-- Name: photo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.photo (
    idphoto character varying(20) NOT NULL,
    image text NOT NULL,
    type integer NOT NULL,
    daty date NOT NULL,
    heure character varying(50) NOT NULL,
    idprofil character varying(20) NOT NULL
);


--
-- Name: profildiplome; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profildiplome (
    idoption character varying(50) NOT NULL,
    idprofil character varying(20) NOT NULL,
    idprofildiplome character varying(20) NOT NULL,
    etat integer NOT NULL,
    iddiplome character varying(20) NOT NULL
);


--
-- Name: profilemplacement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profilemplacement (
    id character varying(20) NOT NULL,
    idprofil character varying(20) NOT NULL,
    longitude double precision NOT NULL,
    latitude double precision NOT NULL
);


--
-- Name: promotion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion (
    idpromotion character varying(20) NOT NULL,
    annee integer NOT NULL,
    libelle character varying(50) NOT NULL,
    idparcours character varying(20) NOT NULL
);


--
-- Name: utilisateur; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.utilisateur (
    refuser integer NOT NULL,
    loginuser character varying(200),
    pwduser character varying(200),
    nomuser character varying(200),
    adruser character varying(200),
    teluser character varying(100),
    idrole character varying(100),
    acronyme character varying(3),
    id character varying(50),
    matricule character varying(255),
    profile character varying(255),
    idtypeutilisateur character varying,
    estactif integer,
    idequipe character varying(100)
);


--
-- Name: profillib; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.profillib AS
 SELECT pr.idprofil,
    pr.email,
    pr.nom,
    pr.prenom,
    pr.dtn,
    pr.telephone,
    u.refuser AS idutilisateur,
    p.idpromotion,
    p.libelle AS promotionlib,
    p.annee AS promotionannee,
    parc.idparcours,
    parc.libelle AS parcourslib,
    g.idgenre,
    g.libelle AS genrelib,
    ( SELECT photo.image
           FROM public.photo
          WHERE (((photo.idprofil)::text = (pr.idprofil)::text) AND (photo.type = 1))
          ORDER BY photo.daty DESC, photo.heure DESC
         LIMIT 1) AS photoprofil,
    ( SELECT photo.image
           FROM public.photo
          WHERE (((photo.idprofil)::text = (pr.idprofil)::text) AND (photo.type = 0))
          ORDER BY photo.daty DESC, photo.heure DESC
         LIMIT 1) AS photocouverture,
    u.estactif,
    u.profile,
    u.idrole,
    u.refuser,
    u.loginuser,
    COALESCE(( SELECT ha.estactif
           FROM public.historiqueactif ha
          WHERE ((ha.idutilisateur)::text = ((u.refuser)::character varying)::text)
          ORDER BY ha.daty DESC, ha.id DESC
         LIMIT 1),
        CASE
            WHEN (u.estactif = 1) THEN 1
            ELSE 0
        END) AS etatdetail,
    COALESCE(( SELECT
                CASE
                    WHEN (ha.estactif = 0) THEN 'Banni'::text
                    WHEN (ha.estactif = 1) THEN 'Cree'::text
                    WHEN (ha.estactif = 11) THEN 'Valide'::text
                    WHEN (ha.estactif = 100) THEN 'Actif'::text
                    ELSE 'Inconnu'::text
                END AS "case"
           FROM public.historiqueactif ha
          WHERE ((ha.idutilisateur)::text = ((u.refuser)::character varying)::text)
          ORDER BY ha.daty DESC, ha.id DESC
         LIMIT 1),
        CASE
            WHEN (u.estactif = 1) THEN 'Cree'::text
            ELSE 'Banni'::text
        END) AS etatlib,
    pr.cv
   FROM ((((public.utilisateur u
     LEFT JOIN public.profil pr ON ((pr.idutilisateur = u.refuser)))
     LEFT JOIN public.promotion p ON (((p.idpromotion)::text = (pr.idpromotion)::text)))
     LEFT JOIN public.parcours parc ON (((parc.idparcours)::text = (pr.idparcours)::text)))
     LEFT JOIN public.genre g ON (((g.idgenre)::text = (pr.idgenre)::text)));


--
-- Name: profilsocialmedia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profilsocialmedia (
    idprofilsocial character varying(50) NOT NULL,
    idprofil character varying(20) NOT NULL,
    idreseausocial character varying(20) NOT NULL,
    valeur character varying(255) NOT NULL,
    datycreation timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    datymodification timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: profilstatut; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profilstatut (
    id character varying(12) NOT NULL,
    idprofil character varying(50) NOT NULL,
    idprofiltypestatut character varying(12) NOT NULL,
    daty timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: profiltypestatut; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiltypestatut (
    idprofiltypestatut character varying(12) NOT NULL,
    libelle character varying(100) NOT NULL,
    couleur character varying(7) DEFAULT '#000000'::character varying
);


--
-- Name: promotionvue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.promotionvue AS
 SELECT p.idpromotion,
    p.annee,
    p.libelle,
    p.idparcours,
    pr.libelle AS libelleparcours
   FROM (public.promotion p
     JOIN public.parcours pr ON (((p.idparcours)::text = (pr.idparcours)::text)));


--
-- Name: publication; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publication (
    idpublication character varying(20) NOT NULL,
    daty date NOT NULL,
    descritpion text,
    etat integer NOT NULL,
    idorigine character varying(50),
    heure character varying(50) NOT NULL,
    idtypepublication character varying(20) NOT NULL,
    idutilisateur integer NOT NULL,
    logique_visibilite character varying(3) DEFAULT 'OR'::character varying,
    idpuborigine character varying(20) DEFAULT NULL::character varying
);


--
-- Name: publicationcommentaire; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publicationcommentaire (
    idpublicationcommentaire character varying(20) NOT NULL,
    description character varying(250) NOT NULL,
    etat integer NOT NULL,
    idutilisateur integer NOT NULL,
    idpublicationcommentaire_1 character varying(20),
    idpublication character varying(20) NOT NULL
);


--
-- Name: publicationenregistrement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publicationenregistrement (
    idpublicationenregistrement character varying(20) NOT NULL,
    idpublication character varying(20) NOT NULL,
    idutilisateur integer NOT NULL,
    daty date DEFAULT now() NOT NULL,
    heure character varying(8) DEFAULT to_char(now(), ' HH24:MI:SS'::text) NOT NULL
);


--
-- Name: publicationenregistrement_idpublicationenregistrement_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publicationenregistrement_idpublicationenregistrement_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publicationenregistrement_idpublicationenregistrement_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.publicationenregistrement_idpublicationenregistrement_seq OWNED BY public.publicationenregistrement.idpublicationenregistrement;


--
-- Name: publicationhashtag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publicationhashtag (
    idpublicationhashtag integer NOT NULL,
    idpublication character varying(20) NOT NULL,
    hashtag character varying(50) NOT NULL,
    typetag character varying(15) NOT NULL,
    idref character varying(20) NOT NULL
);


--
-- Name: publicationhashtag_idpublicationhashtag_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publicationhashtag_idpublicationhashtag_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publicationhashtag_idpublicationhashtag_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.publicationhashtag_idpublicationhashtag_seq OWNED BY public.publicationhashtag.idpublicationhashtag;


--
-- Name: publicationreaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publicationreaction (
    idpublicationreaction character varying(20) NOT NULL,
    idreactiontype character varying(50) NOT NULL,
    idutilisateur integer NOT NULL,
    idpublication character varying(20) NOT NULL
);


--
-- Name: publicationvisibilite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publicationvisibilite (
    idpublicationvisibilite integer NOT NULL,
    idpublication character varying(20) NOT NULL,
    typecible character varying(15) NOT NULL,
    idref character varying(20),
    anneemin integer,
    anneeref integer,
    anneedirection character(1) DEFAULT '+'::bpchar
);


--
-- Name: publicationvisibilite_idpublicationvisibilite_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publicationvisibilite_idpublicationvisibilite_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publicationvisibilite_idpublicationvisibilite_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.publicationvisibilite_idpublicationvisibilite_seq OWNED BY public.publicationvisibilite.idpublicationvisibilite;


--
-- Name: publicationvue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publicationvue (
    idpublicationvue integer NOT NULL,
    idutilisateur integer NOT NULL,
    idpublication character varying(20) NOT NULL,
    datvue timestamp without time zone DEFAULT now() NOT NULL,
    nbvue integer DEFAULT 1 NOT NULL
);


--
-- Name: publicationvue_idpublicationvue_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publicationvue_idpublicationvue_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publicationvue_idpublicationvue_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.publicationvue_idpublicationvue_seq OWNED BY public.publicationvue.idpublicationvue;


--
-- Name: reactiontype; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reactiontype (
    idreactiontype character varying(50) NOT NULL,
    libelle character varying(50) NOT NULL
);


--
-- Name: reseauxsociaux; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reseauxsociaux (
    idreseausocial character varying(20) NOT NULL,
    libelle character varying(100) NOT NULL,
    urlpattern character varying(255),
    iconeclass character varying(50),
    couleurhex character varying(7),
    priorite integer DEFAULT 0,
    actif integer DEFAULT 1
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    idrole character varying NOT NULL,
    descrole character varying,
    rang integer
);


--
-- Name: seq_absence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_absence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_actionprojet; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_actionprojet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_alert; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_alert
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_analyses; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_analyses
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


--
-- Name: seq_apjclasse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_apjclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_attribusentite; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_attribusentite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_attributclasse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_attributclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_attributoracle; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_attributoracle
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_attributpostgres; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_attributpostgres
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_attributtype; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_attributtype
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_boutonchamp; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_boutonchamp
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_boutonpage; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_boutonpage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_branche; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_branche
    START WITH 10
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_caisse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_caisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_champdynamique; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_champdynamique
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_champsspeciaux; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_champsspeciaux
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_cheminprojetuser; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_cheminprojetuser
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_classe; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_classe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


--
-- Name: seq_commentairereaction; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_commentairereaction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_comptaclassecompte; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptaclassecompte
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptacompte; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptacompte
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptacomptebackup; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptacomptebackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptaecriture; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptaecriture
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptaecriturebackup; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptaecriturebackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptaexercice; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptaexercice
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptajournal; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptajournal
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptajournalbackup; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptajournalbackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptalettrage; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptalettrage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptaorigine; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptaorigine
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptasousecriture; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptasousecriture
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptasousecriturebackup; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptasousecriturebackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_comptatypecompte; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_comptatypecompte
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_conception_pm; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_conception_pm
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


--
-- Name: seq_connexion; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_connexion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_coutprevisionnel; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_coutprevisionnel
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_deploiement; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_deploiement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_devis; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_devis
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_devisfille; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_devisfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_diagramaffichage; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_diagramaffichage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_diagramclass; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_diagramclass
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_diagramclasscomposant; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_diagramclasscomposant
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_diagramclasscomposanttype; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_diagramclasscomposanttype
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_diagramclasspackage; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_diagramclasspackage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_diagramcomposant; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_diagramcomposant
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_diagrampackage; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_diagrampackage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_diagramtable; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_diagramtable
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_diagramtablecolonne; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_diagramtablecolonne
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_diplome; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_diplome
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_donation; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_donation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


--
-- Name: seq_entitescript; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_entitescript
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_evenement; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_evenement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_exceptiontache; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_exceptiontache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_experience; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_experience
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_genre; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_genre
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_histoinsert; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_histoinsert
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_honoraire; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_honoraire
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_identification; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_identification
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_indisponibilite; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_indisponibilite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_jourrepos; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_jourrepos
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_limiterole; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_limiterole
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_magasin2; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_magasin2
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_mappingtypeattribut; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_mappingtypeattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_media; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_media
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_mediatype; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_mediatype
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_mention; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_mention
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_metierfille; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_metierfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


--
-- Name: seq_module; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_module
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_module_projet; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_module_projet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 1;


--
-- Name: seq_niveauclient; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_niveauclient
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_notification; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_notification
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_notificationdetails; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_notificationdetails
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_notificationgroupe; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_notificationgroupe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_notificationsignal; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_notificationsignal
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_option; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_option
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_pageanalyse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_pageanalyse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_pageanalyseattribut; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_pageanalyseattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_pageattribut; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_pageattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_pagefiche; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_pagefiche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_pageficheattribut; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_pageficheattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_pageliste; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_pageliste
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_pagelisteattribut; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_pagelisteattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_pagesaisie; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_pagesaisie
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_panalysechampfiltre; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_panalysechampfiltre
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_parcours; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_parcours
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_participation_evenement; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_participation_evenement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_pays; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_pays
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_phaseproject; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_phaseproject
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_photo; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_photo
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_plistchampfiltre; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_plistchampfiltre
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_pointage; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_pointage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_poste; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_poste
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_profil; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_profil
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_profildiplome; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_profildiplome
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_profilemplacement; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_profilemplacement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_profilsocialmedia; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_profilsocialmedia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_profilstatut; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_profilstatut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_profiltypestatut; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_profiltypestatut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_projetutilisateur; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_projetutilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_promotion; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_promotion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_proposition; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_proposition
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_province; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_province
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_publication; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_publication
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_publicationcommentaire; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_publicationcommentaire
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_publicationenregistrement; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_publicationenregistrement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_publicationreaction; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_publicationreaction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_qualite; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_qualite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_reactiontype; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_reactiontype
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_relation; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_relation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_requeteaenvoyer; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_requeteaenvoyer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_script; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_script
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_scriptversionning; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_scriptversionning
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_serveur; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_serveur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_signalementpublication; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_signalementpublication
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_specialite; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_specialite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_specialiteprofil; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_specialiteprofil
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_tache; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_tache
    START WITH 182
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_tache_git_details; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_tache_git_details
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_tache_git_mere; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_tache_git_mere
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_tauxhonoraire; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_tauxhonoraire
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_tempstravail; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_tempstravail
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_timingapplication; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_timingapplication
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_timingsoustache; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_timingsoustache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_type_utilisateur; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_type_utilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_typeactionmetier; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typeactionmetier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


--
-- Name: seq_typeattributclasse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typeattributclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_typechampsspeciaux; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typechampsspeciaux
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_typeclasse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typeclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_typedependancediagram; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typedependancediagram
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_typedependanceobjet; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typedependanceobjet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_typeliaison; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typeliaison
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_typemagasin; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typemagasin
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_typeouinon; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typeouinon
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_typepageanalyse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typepageanalyse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_typepageliste; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typepageliste
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_typepagesaisie; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typepagesaisie
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_typeplistchampfiltre; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typeplistchampfiltre
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seq_typepublication; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typepublication
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_typerelation; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typerelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_typescript; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typescript
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_typesignalement; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typesignalement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_typetache; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_typetache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_utilisateurhistoetat; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_utilisateurhistoetat
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_v_classeetfiche; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_v_classeetfiche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_v_classetfiche; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_v_classetfiche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seq_visibilite; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_visibilite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqaction; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqaction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqactiontache; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqactiontache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqarchitecture; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqarchitecture
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqattacher_fichier; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqattacher_fichier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqavoirfc; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqavoirfc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqavoirfcfille; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqavoirfcfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqbase; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqbase
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqbaserelation; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqbaserelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqbranche; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqbranche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqcaisse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqcaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqcanevatache; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqcanevatache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqcateging; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqcateging
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqcategorie; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqcategorie
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


--
-- Name: seqcategorieavoirfc; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqcategorieavoirfc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqcategoriecaisse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqcategoriecaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqcategorieniveau; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqcategorieniveau
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqclient; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqclient
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqcote; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqcote
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


--
-- Name: seqcrcontent; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqcrcontent
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqcrcontentfille; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqcrcontentfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqcreation_projet; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqcreation_projet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


--
-- Name: seqdevise; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqdevise
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqdonation; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqdonation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqentite; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqentite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqequipe; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqequipe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


--
-- Name: seqexecution_script; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqexecution_script
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqexecution_scriptfille; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqexecution_scriptfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqexecutions; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqexecutions
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqexternal_work; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqexternal_work
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqfonctionnalite; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqfonctionnalite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqfournisseur; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqfournisseur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqhistoimport; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqhistoimport
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqhistorique; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqhistorique
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


--
-- Name: seqhistoriqueactif; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqhistoriqueactif
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqhistovaleur; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqhistovaleur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


--
-- Name: seqingredients; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqingredients
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqmagasin; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqmagasin
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqmailcc; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqmailcc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqmailrapport; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqmailrapport
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqmetier; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqmetier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqmetierrelation; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqmetierrelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqmotifavoirfc; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqmotifavoirfc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqmouvementcaisse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqmouvementcaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqmvtcaisseprevision; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqmvtcaisseprevision
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqniveau; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqniveau
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqnotificationaction; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqnotificationaction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqordonnerpaiement; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqordonnerpaiement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqpage; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqpage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqpagerelation; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqpagerelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqparamcrypt; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqparamcrypt
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqphase; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqphase
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqpiecejointe; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqpiecejointe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqpoint; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqpoint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqprevision; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqprevision
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqprojet; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqprojet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqprojetequipe; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqprojetequipe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


--
-- Name: seqpromesse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqpromesse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqrep; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqrep
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 1;


--
-- Name: seqrepd; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqrepd
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 1;


--
-- Name: seqreportcaisse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqreportcaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqrequeteaenvoyer; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqrequeteaenvoyer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqscript_projet; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqscript_projet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqsource; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqsource
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqtache; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


--
-- Name: seqtachemere; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtachemere
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqtachemere_detailsdefaut; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtachemere_detailsdefaut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqtachemeredefaut; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtachemeredefaut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqtauxavancementmodule; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtauxavancementmodule
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqtauxavancementprojet; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtauxavancementprojet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqtauxdechange; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtauxdechange
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


--
-- Name: seqtype; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtype
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


--
-- Name: seqtypeabsence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtypeabsence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqtypeaction; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtypeaction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqtypebase; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtypebase
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqtypecaisse; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtypecaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqtypefichier; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtypefichier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqtypefournisseur; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtypefournisseur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqtypemetier; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtypemetier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqtypepage; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtypepage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqtyperepos; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqtyperepos
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: sequnite; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sequnite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sequserequipe; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sequserequipe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


--
-- Name: sequtilisateur; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sequtilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


--
-- Name: seqvente; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqvente
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqventedetails; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqventedetails
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seqwork_branche; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqwork_branche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: seqwork_type; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seqwork_type
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


--
-- Name: signalementpublication; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.signalementpublication (
    idsignalementpublication character varying(20) NOT NULL,
    daty date NOT NULL,
    descritpion character varying(50),
    typesignalement character varying(20) NOT NULL,
    heure character varying(20) NOT NULL,
    idpublication character varying(20) NOT NULL,
    idutilisateur integer NOT NULL
);


--
-- Name: typesignalement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.typesignalement (
    idtypesignalement character varying(20) NOT NULL,
    libelle character varying(150) NOT NULL
);


--
-- Name: signalementpublicationlib; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.signalementpublicationlib AS
 SELECT s.idsignalementpublication AS idsignalement,
    s.idpublication,
    s.idutilisateur AS idsignalant,
    COALESCE((((prsignalant.prenom)::text || ' '::text) || (prsignalant.nom)::text), ('Utilisateur #'::text || s.idutilisateur)) AS nomsignalant,
    pub.idutilisateur AS idsignale,
    COALESCE((((prsignale.prenom)::text || ' '::text) || (prsignale.nom)::text), ('Utilisateur #'::text || pub.idutilisateur)) AS nomsignale,
    s.typesignalement,
    s.daty,
    s.heure,
    s.descritpion AS motifdesc,
    sp.libelle AS motiflibelle
   FROM ((((public.signalementpublication s
     JOIN public.publication pub ON (((pub.idpublication)::text = (s.idpublication)::text)))
     JOIN public.typesignalement sp ON (((sp.idtypesignalement)::text = (s.typesignalement)::text)))
     LEFT JOIN public.profil prsignalant ON ((prsignalant.idutilisateur = s.idutilisateur)))
     LEFT JOIN public.profil prsignale ON ((prsignale.idutilisateur = pub.idutilisateur)));


--
-- Name: specialite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.specialite (
    idspecialite character varying(20) NOT NULL,
    libelle character varying(250) NOT NULL,
    photo character varying(500),
    description text
);


--
-- Name: specialitecpl; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.specialitecpl AS
 SELECT idspecialite,
    libelle,
    description,
    photo,
        CASE
            WHEN ((photo IS NOT NULL) AND ((photo)::text <> ''::text)) THEN (('<img src="__CTX__/'::text || (photo)::text) || '" style="max-height:60px; max-width:80px;"/>'::text)
            ELSE ''::text
        END AS photohtml
   FROM public.specialite;


--
-- Name: specialiteprofil; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.specialiteprofil (
    idspecialite character varying(20) NOT NULL,
    idprofil character varying(20) NOT NULL,
    specialiteprofil character varying(20) NOT NULL,
    etat integer NOT NULL,
    niveau integer NOT NULL
);


--
-- Name: touslesdate; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.touslesdate AS
 SELECT generate_series((to_date('2000-01-01'::text, 'YYYY-MM-DD'::text))::timestamp with time zone, (to_date('2030-12-31'::text, 'YYYY-MM-DD'::text))::timestamp with time zone, '1 day'::interval) AS daty;


--
-- Name: typepublication; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.typepublication (
    idtypepublication character varying(20) NOT NULL,
    libelle character varying(250) NOT NULL
);


--
-- Name: usermenu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usermenu (
    id character varying(50) NOT NULL,
    refuser character varying(50),
    idmenu character varying(50),
    idrole character varying(50),
    codeservice character varying(50),
    codedir character varying(50),
    interdit integer
);


--
-- Name: utilisateuracade_vue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.utilisateuracade_vue AS
 SELECT u.refuser,
    u.loginuser,
    u.pwduser,
    u.nomuser,
    d.desce AS adruser,
    u.teluser,
    u.idrole,
    u.profile,
    u.matricule,
    u.acronyme,
    r.rang
   FROM public.utilisateur u,
    public.direction d,
    public.roles r
  WHERE (((u.adruser)::text = (d.id)::text) AND ((r.idrole)::text = (u.idrole)::text));


--
-- Name: utilisateurhistoetat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.utilisateurhistoetat (
    idutilisateurhistoetat character varying(20) NOT NULL,
    daty date NOT NULL,
    etat integer NOT NULL,
    remarque character varying(250) NOT NULL,
    idutilisateur integer NOT NULL
);


--
-- Name: utilisateurvalide; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.utilisateurvalide AS
 SELECT u.refuser,
    u.loginuser,
    u.pwduser,
    u.nomuser,
    u.adruser,
    u.teluser,
    r.idrole,
    r.rang
   FROM (public.utilisateur u
     JOIN public.roles r ON (((u.idrole)::text = (r.idrole)::text)))
  WHERE (u.estactif = 1);


--
-- Name: utilisateurvue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.utilisateurvue AS
 SELECT u.refuser,
    u.loginuser,
    u.pwduser,
    u.nomuser,
    d.desce AS adruser,
    u.teluser,
    u.idrole,
    r.rang,
    u.id
   FROM public.utilisateur u,
    public.direction d,
    public.roles r
  WHERE (((u.adruser)::text = (d.id)::text) AND ((r.idrole)::text = (u.idrole)::text));


--
-- Name: utilisateurvue_roles; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.utilisateurvue_roles AS
 SELECT u.refuser,
    u.loginuser,
    u.pwduser,
    u.nomuser,
    d.desce AS adruser,
    u.teluser,
    (r.descrole)::character varying(100) AS idrole,
    r.rang,
    u.id,
    (u.estactif)::character varying(255) AS estactif,
        CASE
            WHEN (u.estactif = 1) THEN '<span style="color:#155724;background-color:#d4edda;padding:3px 8px;border-radius:4px;font-weight:600;font-size:12px;">Actif</span>'::text
            ELSE '<span style="color:#721c24;background-color:#f8d7da;padding:3px 8px;border-radius:4px;font-weight:600;font-size:12px;">Inactif</span>'::text
        END AS estactiflib
   FROM ((public.utilisateur u
     JOIN public.direction d ON (((u.adruser)::text = (d.id)::text)))
     JOIN public.roles r ON (((r.idrole)::text = (u.idrole)::text)));


--
-- Name: visibilite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visibilite (
    idvisibilite character varying(20) NOT NULL,
    champvisibilite character varying(50) NOT NULL,
    status integer NOT NULL,
    daty date,
    idprofil character varying(20) NOT NULL
);


--
-- Name: v_profil_localisation; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_profil_localisation AS
 SELECT p.idprofil,
    p.email,
    p.nom,
    p.prenom,
    p.dtn,
    p.telephone,
    p.idutilisateur,
    p.idpromotion,
    p.promotionlib,
    p.promotionannee,
    p.idparcours,
    p.parcourslib,
    p.idgenre,
    p.genrelib,
    p.photoprofil,
    p.photocouverture,
    p.estactif,
    p.profile,
    p.idrole,
    p.refuser,
    p.loginuser,
    p.etatdetail,
    p.etatlib,
    pe.longitude,
    pe.latitude,
    pe.id AS idemplacement
   FROM (public.profillib p
     JOIN public.profilemplacement pe ON (((p.idprofil)::text = (pe.idprofil)::text)))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM public.visibilite v
          WHERE (((v.idprofil)::text = (p.idprofil)::text) AND ((v.champvisibilite)::text = 'localisation'::text) AND (v.status = 0)))));


--
-- Name: v_profilstatut_latest; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_profilstatut_latest AS
 SELECT ps.id,
    ps.idprofil,
    ps.idprofiltypestatut,
    pts.libelle,
    pts.couleur,
    ps.daty
   FROM (public.profilstatut ps
     JOIN public.profiltypestatut pts ON (((ps.idprofiltypestatut)::text = (pts.idprofiltypestatut)::text)))
  WHERE (((ps.idprofil)::text, ps.daty) IN ( SELECT profilstatut.idprofil,
            max(profilstatut.daty) AS max
           FROM public.profilstatut
          GROUP BY profilstatut.idprofil));


--
-- Name: publicationenregistrement idpublicationenregistrement; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationenregistrement ALTER COLUMN idpublicationenregistrement SET DEFAULT nextval('public.publicationenregistrement_idpublicationenregistrement_seq'::regclass);


--
-- Name: publicationhashtag idpublicationhashtag; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationhashtag ALTER COLUMN idpublicationhashtag SET DEFAULT nextval('public.publicationhashtag_idpublicationhashtag_seq'::regclass);


--
-- Name: publicationvisibilite idpublicationvisibilite; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationvisibilite ALTER COLUMN idpublicationvisibilite SET DEFAULT nextval('public.publicationvisibilite_idpublicationvisibilite_seq'::regclass);


--
-- Name: publicationvue idpublicationvue; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationvue ALTER COLUMN idpublicationvue SET DEFAULT nextval('public.publicationvue_idpublicationvue_seq'::regclass);



--
-- Data for Name: commentairereaction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.commentairereaction (idcommentairereaction, idutilisateur, idpublicationcommentaire, idreactiontype) FROM stdin;
\.


--
-- Data for Name: diplome; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.diplome (iddiplome, libelle) FROM stdin;
\.


--
-- Data for Name: direction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.direction (id, val, desce) FROM stdin;
DIR42	opus	opus
\.


--
-- Data for Name: evenement; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.evenement (idevenement, description, daty, datefin, datedebut, idutilisateur) FROM stdin;
\.


--
-- Data for Name: experience; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.experience (idexperience, entreprise, debut, fin, description, etat, idprofil, idposte) FROM stdin;
\.


--
-- Data for Name: genre; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.genre (idgenre, libelle) FROM stdin;
GEN000001	homme
GEN000002	femme
\.


--
-- Data for Name: histoinsert; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.histoinsert (idhistorique, datehistorique, heure, objet, action, idutilisateur, refobjet, remarque) FROM stdin;
\.


--
-- Data for Name: historique; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.historique (idhistorique, datehistorique, heure, objet, action, idutilisateur, refobjet) FROM stdin;
\.


--
-- Data for Name: historiqueactif; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.historiqueactif (id, idutilisateur, estactif, daty, description) FROM stdin;
\.


--
-- Data for Name: identification; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.identification (ididentification, idutilisateur, idpublication) FROM stdin;
\.


--
-- Data for Name: limiterole; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.limiterole (idlimiterole, idrole, maxpublicationparjour, daty, heure) FROM stdin;
LMR001	etu	10	2026-02-26	11:40:57
LMR002	alu	4	2026-02-26	11:40:57
LMR003	md	100	2026-02-26	11:40:58
\.


--
-- Data for Name: media; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.media (idmedia, mediaurl, idmediatype, idpublication) FROM stdin;
\.


--
-- Data for Name: mediatype; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mediatype (idmediatype, libelle) FROM stdin;
MDT000001	Image
MDT000002	Video
\.


--
-- Data for Name: mention; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mention (idmention, idutilisateur, idpublicationcommentaire) FROM stdin;
\.


--
-- Data for Name: menudynamique; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.menudynamique (id, libelle, icone, href, rang, niveau, id_pere) FROM stdin;
MENDYN000001	Accueil	bi-house-door-fill	module.jsp?but=accueil.jsp	1	0	\N
MENDYN000002	Reseau	bi-people-fill	#	2	0	\N
MENDYN000004	Mon Profil	bi-person-circle	#	5	0	\N
MENDYN000999	Administration	bi-gear-fill	#	99	0	\N
MENDYN000005	Annuaire	bi-book-fill	module.jsp?but=annuaire/annuaire.jsp	1	1	MENDYN000002
MENDYN000006	Gestion Specialites	bi-tags-fill	module.jsp?but=specialite/specialite-list.jsp	2	1	MENDYN000999
MENDYN000007	Offres d'emploi	bi-list-ul	module.jsp?but=carriere/offres.jsp	1	1	MENDYN000003
MENDYN000008	Publier une offre	bi-plus-circle-fill	module.jsp?but=carriere/publier-offre.jsp	2	1	MENDYN000003
MENDYN000009	Voir ma fiche	bi-person-badge-fill	module.jsp?but=profil/voir.jsp	1	1	MENDYN000004
MENDYN000011	Deconnexion	bi-box-arrow-right	deconnexion.jsp	3	1	MENDYN000004
MENDYN000023	Gestion des utilisateurs	bi-people	module.jsp?but=mod/gestion-utilisateurs.jsp	1	1	MENDYN000999
MENDYN000024	Gestion des signalements	bi-shield-exclamation	module.jsp?but=mod/gestion-signalements.jsp	2	1	MENDYN000999
MENDYN000014	Notifications	bi-bell-fill	#	6	0	\N
MENDYN000015	Evenements	bi-calendar-event-fill	#	4	0	\N
MENDYN000016	Saisie	bi-plus-circle-fill	module.jsp?but=evenement/evenement-saisie.jsp	1	1	MENDYN000015
MENDYN000017	Liste	bi-list-ul	module.jsp?but=evenement/evenement-list.jsp	2	1	MENDYN000015
MENDYN000018	Calendrier	bi-calendar-heart-fill	module.jsp?but=evenement/evenement-calendar.jsp	3	1	MENDYN000015
MENDYN000019	Reseau pro	bi-diagram-3-fill	module.jsp?but=alumni/reseau-professionnel.jsp	3	1	MENDYN000002
MENDYN000020	Carte	bi-globe-americas	module.jsp?but=map/cart.jsp	3	0	\N
MENDYN000026	Dashboard	bi-clipboard-data	module.jsp?but=dashboard/dashboard.jsp	1	1	MENDYN000999
MENDYN000027	Historique	bi-clock-history	module.jsp?but=dashboard/historique-list.jsp	2	1	MENDYN000999
MENDYN000028	Limites publications	bi-speedometer2	module.jsp?but=limiterole/limiterole-list.jsp	3	1	MENDYN000999
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notification (idnotification, objet, daty, idorigine, lien, etat, heure, typenotif, idutilisateur) FROM stdin;
\.


--
-- Data for Name: option; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.option (idoption, libelle) FROM stdin;
\.


--
-- Data for Name: paramcrypt; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.paramcrypt (id, niveau, croissante, idutilisateur) FROM stdin;
CRY000088	4	1	1
\.


--
-- Data for Name: parcours; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parcours (idparcours, libelle) FROM stdin;
PRC000001	Informatique
PRC000002	Design
\.


--
-- Data for Name: participation_evenement; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.participation_evenement (idparticipation, idevenement, idutilisateur, dateparticipation) FROM stdin;
\.


--
-- Data for Name: photo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.photo (idphoto, image, type, daty, heure, idprofil) FROM stdin;
\.


--
-- Data for Name: poste; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.poste (idposte, libelle) FROM stdin;
POS000001	Developpeur Full Stack
POS000002	Developpeur Backend
POS000003	Developpeur Frontend
POS000004	Ingenieur Reseaux
POS000005	Data Scientist
POS000006	Ingenieur Securite
POS000007	Chef de Projet IT
POS000008	DevOps Engineer
POS000009	Architecte Logiciel
POS000010	Consultant Freelance IT
\.


--
-- Data for Name: profil; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profil (idprofil, email, nom, prenom, dtn, telephone, idpromotion, idparcours, idutilisateur, idgenre, cv) FROM stdin;
PRF000001	admin@opus.edu	Admin	OPUS	2000-01-01	0340000000	PRM000001	PRC000001	1	GEN000001	\N
\.


--
-- Data for Name: profildiplome; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profildiplome (idoption, idprofil, idprofildiplome, etat, iddiplome) FROM stdin;
\.


--
-- Data for Name: profilemplacement; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profilemplacement (id, idprofil, longitude, latitude) FROM stdin;
\.


--
-- Data for Name: profilsocialmedia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profilsocialmedia (idprofilsocial, idprofil, idreseausocial, valeur, datycreation, datymodification) FROM stdin;
\.


--
-- Data for Name: profilstatut; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profilstatut (id, idprofil, idprofiltypestatut, daty) FROM stdin;
\.


--
-- Data for Name: profiltypestatut; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profiltypestatut (idprofiltypestatut, libelle, couleur) FROM stdin;
PTS00001	Open to work	#28a745
PTS00002	Hiring	#e69a45
PTS00003	Original	#0a66c2
\.


--
-- Data for Name: promotion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion (idpromotion, annee, libelle, idparcours) FROM stdin;
PRM000001	2006	P1	PRC000001
PRM000002	2007	P2	PRC000001
PRM000003	2008	P3	PRC000001
PRM000004	2009	P4	PRC000001
PRM000005	2010	P5	PRC000001
PRM000006	2011	P6	PRC000001
PRM000007	2012	P7	PRC000001
PRM000008	2013	P8	PRC000001
PRM000009	2014	P9	PRC000001
PRM000010	2015	P10	PRC000001
PRM000011	2016	P11	PRC000001
PRM000012	2017	P12	PRC000001
PRM000013	2018	P13	PRC000001
PRM000014	2019	P14	PRC000001
PRM000015	2020	P15	PRC000001
PRM000016	2021	P16	PRC000001
PRM000017	2022	P17	PRC000001
PRM000018	2023	P18	PRC000001
PRM000019	2024	P19	PRC000001
PRM000020	2025	P20	PRC000001
PRM000021	2019	DSP1	PRC000002
PRM000022	2020	DSP2	PRC000002
PRM000023	2021	DSP3	PRC000002
PRM000024	2022	DSP4	PRC000002
PRM000025	2023	DSP5	PRC000002
PRM000026	2024	DSP6	PRC000002
PRM000027	2025	DSP7	PRC000002
\.


--
--
-- Data for Name: publication; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.publication (idpublication, daty, descritpion, etat, idorigine, heure, idtypepublication, idutilisateur, logique_visibilite, idpuborigine) FROM stdin;
\.


--
-- Data for Name: publicationcommentaire; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.publicationcommentaire (idpublicationcommentaire, description, etat, idutilisateur, idpublicationcommentaire_1, idpublication) FROM stdin;
\.


--
-- Data for Name: publicationenregistrement; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.publicationenregistrement (idpublicationenregistrement, idpublication, idutilisateur, daty, heure) FROM stdin;
\.


--
-- Data for Name: publicationhashtag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.publicationhashtag (idpublicationhashtag, idpublication, hashtag, typetag, idref) FROM stdin;
\.


--
-- Data for Name: publicationreaction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.publicationreaction (idpublicationreaction, idreactiontype, idutilisateur, idpublication) FROM stdin;
\.


--
-- Data for Name: publicationvisibilite; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.publicationvisibilite (idpublicationvisibilite, idpublication, typecible, idref, anneemin, anneeref, anneedirection) FROM stdin;
\.


--
-- Data for Name: publicationvue; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.publicationvue (idpublicationvue, idutilisateur, idpublication, datvue, nbvue) FROM stdin;
\.


--
-- Data for Name: reactiontype; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reactiontype (idreactiontype, libelle) FROM stdin;
RCT000001	Like
RCT000002	Love
RCT000003	Haha
RCT000004	Wow
RCT000005	Triste
RCT000006	Enerve
\.


--
-- Data for Name: reseauxsociaux; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reseauxsociaux (idreseausocial, libelle, urlpattern, iconeclass, couleurhex, priorite, actif) FROM stdin;
linkedin	LinkedIn	https://linkedin.com/in/{value}	fab fa-linkedin	#0A66C2	100	1
github	GitHub	https://github.com/{value}	fab fa-github	#181717	95	1
gitlab	GitLab	https://gitlab.com/{value}	fab fa-gitlab	#FC6D26	90	1
bitbucket	Bitbucket	https://bitbucket.org/{value}	fab fa-bitbucket	#0052CC	85	1
stackoverflow	Stack Overflow	https://stackoverflow.com/users/{value}	fab fa-stack-overflow	#F48024	80	1
codepen	CodePen	https://codepen.io/{value}	fab fa-codepen	#000000	75	1
behance	Behance	https://behance.net/{value}	fab fa-behance	#1769FF	70	1
twitter	Twitter	https://twitter.com/{value}	fab fa-twitter	#1DA1F2	90	1
facebook	Facebook	https://facebook.com/{value}	fab fa-facebook	#1877F2	85	1
instagram	Instagram	https://instagram.com/{value}	fab fa-instagram	#E4405F	88	1
tiktok	TikTok	https://tiktok.com/@{value}	fab fa-tiktok	#000000	75	1
youtube	YouTube	https://youtube.com/@{value}	fab fa-youtube	#FF0000	80	1
discord	Discord	https://discord.com/users/{value}	fab fa-discord	#5865F2	70	1
portfolio	Portfolio	{value}	fas fa-globe	#3B82F6	65	1
website	Site Web	{value}	fas fa-link	#666666	60	1
devto	Dev.to	https://dev.to/{value}	fab fa-dev	#0A0E27	65	1
medium	Medium	https://medium.com/@{value}	fab fa-medium	#000000	60	1
hashnode	Hashnode	https://hashnode.com/@{value}	fas fa-h	#2962FF	62	1
substack	Substack	https://substack.com/@{value}	fas fa-envelope	#FF6600	58	1
whatsapp	WhatsApp	https://wa.me/{value}	fab fa-whatsapp	#25D366	50	1
telegram	Telegram	https://t.me/{value}	fab fa-telegram	#0088cc	50	1
skype	Skype	https://join.skype.com/{value}	fab fa-skype	#00AFF0	45	1
email	Email	mailto:{value}	fas fa-envelope	#EA4335	55	1
phone	Telephone	tel:{value}	fas fa-phone	#34C759	40	1
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (idrole, descrole, rang) FROM stdin;
md	Moderateur	10
etu	Etudiant	3
alu	Alumni	1
\.


--
-- Data for Name: signalementpublication; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.signalementpublication (idsignalementpublication, daty, descritpion, typesignalement, heure, idpublication, idutilisateur) FROM stdin;
\.


--
-- Data for Name: specialite; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.specialite (idspecialite, libelle, photo, description) FROM stdin;
SPE000001	Java	\N	\N
SPE000002	Python	\N	\N
SPE000003	JavaScript	\N	\N
SPE000004	Intelligence Artificielle	\N	\N
SPE000005	Reseaux Informatiques	\N	\N
SPE000006	Base de Donnees	\N	\N
SPE000007	Securite Informatique	\N	\N
SPE000008	DevOps et Cloud	\N	\N
SPE000009	Developpement Mobile	\N	\N
SPE000010	Data Visualisation	\N	\N
\.


--
-- Data for Name: specialiteprofil; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.specialiteprofil (idspecialite, idprofil, specialiteprofil, etat, niveau) FROM stdin;
\.


--
-- Data for Name: typepublication; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.typepublication (idtypepublication, libelle) FROM stdin;
TPB000001	Offre d'emploi
TPB000002	Stage
TPB000003	Evenement
TPB000004	Projet
TPB000005	Recherche d'opportunite
TPB000006	Autre
\.


--
-- Data for Name: typesignalement; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.typesignalement (idtypesignalement, libelle) FROM stdin;
TSG000001	Contenu pour adultes
TSG000002	Contenu violent
TSG000003	Scam, fraude ou fausse information
TSG000004	Harcelement ou discrimination
\.


--
-- Data for Name: usermenu; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) FROM stdin;
USRM000001	*	MENDYN000001	etu	\N	\N	0
USRM000002	*	MENDYN000002	etu	\N	\N	0
USRM000004	*	MENDYN000004	etu	\N	\N	0
USRM000005	*	MENDYN000005	etu	\N	\N	0
USRM000007	*	MENDYN000007	etu	\N	\N	0
USRM000008	*	MENDYN000008	etu	\N	\N	0
USRM000009	*	MENDYN000009	etu	\N	\N	0
USRM000011	*	MENDYN000011	etu	\N	\N	0
USRM000025	*	MENDYN000024	etu	\N	\N	1
USRM000027	*	MENDYN000014	etu	\N	\N	0
USRM000029	*	MENDYN000015	etu	\N	\N	0
USRM000035	*	MENDYN000018	etu	\N	\N	0
USRM000101	*	MENDYN000001	alu	\N	\N	0
USRM000102	*	MENDYN000002	alu	\N	\N	0
USRM000104	*	MENDYN000004	alu	\N	\N	0
USRM000105	*	MENDYN000005	alu	\N	\N	0
USRM000107	*	MENDYN000007	alu	\N	\N	0
USRM000108	*	MENDYN000008	alu	\N	\N	0
USRM000109	*	MENDYN000009	alu	\N	\N	0
USRM000111	*	MENDYN000011	alu	\N	\N	0
USRM000125	*	MENDYN000024	alu	\N	\N	1
USRM000127	*	MENDYN000014	alu	\N	\N	0
USRM000129	*	MENDYN000015	alu	\N	\N	0
USRM000135	*	MENDYN000018	alu	\N	\N	0
USRM000012	*	MENDYN000001	md	\N	\N	0
USRM000013	*	MENDYN000002	md	\N	\N	0
USRM000015	*	MENDYN000004	md	\N	\N	0
USRM000016	*	MENDYN000005	md	\N	\N	0
USRM000017	*	MENDYN000006	md	\N	\N	0
USRM000018	*	MENDYN000007	md	\N	\N	0
USRM000019	*	MENDYN000008	md	\N	\N	0
USRM000020	*	MENDYN000009	md	\N	\N	0
USRM000022	*	MENDYN000011	md	\N	\N	0
USRM000099	*	MENDYN000999	md	\N	\N	0
USRM000023	*	MENDYN000023	md	\N	\N	0
USRM000024	*	MENDYN000024	md	\N	\N	0
USRM000028	*	MENDYN000014	md	\N	\N	0
USRM000030	*	MENDYN000015	md	\N	\N	0
USRM000032	*	MENDYN000016	md	\N	\N	0
USRM000034	*	MENDYN000017	md	\N	\N	0
USRM000036	*	MENDYN000018	md	\N	\N	0
USRM000045	*	MENDYN000019	etu	\N	\N	0
USRM000145	*	MENDYN000019	alu	\N	\N	0
USRM000046	*	MENDYN000019	md	\N	\N	0
USRM000047	*	MENDYN000020	etu	\N	\N	0
USRM000147	*	MENDYN000020	alu	\N	\N	0
USRM000048	*	MENDYN000020	md	\N	\N	0
USRM000049	*	MENDYN000027	md	\N	\N	0
USRM000050	*	MENDYN000026	md	\N	\N	0
USRM000051	*	MENDYN000028	md	\N	\N	0
\.


--
-- Data for Name: utilisateur; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.utilisateur (refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole, acronyme, id, matricule, profile, idtypeutilisateur, estactif, idequipe) FROM stdin;
1	ETU000001	paop	ETU000001	DIR42	\N	md	\N	ETU000001	\N	\N	\N	1	\N
\.


--
-- Data for Name: utilisateurhistoetat; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.utilisateurhistoetat (idutilisateurhistoetat, daty, etat, remarque, idutilisateur) FROM stdin;
\.


--
-- Data for Name: visibilite; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.visibilite (idvisibilite, champvisibilite, status, daty, idprofil) FROM stdin;
\.



--
-- Name: cnapsuser_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cnapsuser_id_seq', 1, false);


--
-- Name: publicationenregistrement_idpublicationenregistrement_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.publicationenregistrement_idpublicationenregistrement_seq', 1, false);


--
-- Name: publicationhashtag_idpublicationhashtag_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.publicationhashtag_idpublicationhashtag_seq', 1, false);


--
-- Name: publicationvisibilite_idpublicationvisibilite_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.publicationvisibilite_idpublicationvisibilite_seq', 1, false);


--
-- Name: publicationvue_idpublicationvue_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.publicationvue_idpublicationvue_seq', 1, false);


--
-- Name: seq_absence; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_absence', 4, true);


--
-- Name: seq_actionprojet; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_actionprojet', 1, false);


--
-- Name: seq_alert; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_alert', 1680, true);


--
-- Name: seq_analyses; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_analyses', 1800, true);


--
-- Name: seq_apjclasse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_apjclasse', 34, true);


--
-- Name: seq_attribusentite; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_attribusentite', 142, true);


--
-- Name: seq_attributclasse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_attributclasse', 120, true);


--
-- Name: seq_attributoracle; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_attributoracle', 1, false);


--
-- Name: seq_attributpostgres; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_attributpostgres', 1, false);


--
-- Name: seq_attributtype; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_attributtype', 1, false);


--
-- Name: seq_boutonchamp; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_boutonchamp', 1, false);


--
-- Name: seq_boutonpage; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_boutonpage', 1, false);


--
-- Name: seq_branche; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_branche', 223, true);


--
-- Name: seq_caisse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_caisse', 1, false);


--
-- Name: seq_champdynamique; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_champdynamique', 1, false);


--
-- Name: seq_champsspeciaux; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_champsspeciaux', 11, true);


--
-- Name: seq_cheminprojetuser; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_cheminprojetuser', 2, true);


--
-- Name: seq_classe; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_classe', 40, true);


--
-- Name: seq_commentairereaction; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_commentairereaction', 1, false);


--
-- Name: seq_comptaclassecompte; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptaclassecompte', 1, false);


--
-- Name: seq_comptacompte; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptacompte', 1, false);


--
-- Name: seq_comptacomptebackup; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptacomptebackup', 1, false);


--
-- Name: seq_comptaecriture; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptaecriture', 520, true);


--
-- Name: seq_comptaecriturebackup; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptaecriturebackup', 1, false);


--
-- Name: seq_comptaexercice; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptaexercice', 1, false);


--
-- Name: seq_comptajournal; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptajournal', 1, false);


--
-- Name: seq_comptajournalbackup; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptajournalbackup', 1, false);


--
-- Name: seq_comptalettrage; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptalettrage', 1, false);


--
-- Name: seq_comptaorigine; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptaorigine', 1, false);


--
-- Name: seq_comptasousecriture; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptasousecriture', 300, true);


--
-- Name: seq_comptasousecriturebackup; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptasousecriturebackup', 1, false);


--
-- Name: seq_comptatypecompte; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_comptatypecompte', 1, false);


--
-- Name: seq_conception_pm; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_conception_pm', 60, true);


--
-- Name: seq_connexion; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_connexion', 4, true);


--
-- Name: seq_coutprevisionnel; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_coutprevisionnel', 20, true);


--
-- Name: seq_deploiement; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_deploiement', 45, true);


--
-- Name: seq_devis; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_devis', 1280, true);


--
-- Name: seq_devisfille; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_devisfille', 680, true);


--
-- Name: seq_diagramaffichage; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_diagramaffichage', 7, true);


--
-- Name: seq_diagramclass; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_diagramclass', 30, true);


--
-- Name: seq_diagramclasscomposant; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_diagramclasscomposant', 18, true);


--
-- Name: seq_diagramclasscomposanttype; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_diagramclasscomposanttype', 3, true);


--
-- Name: seq_diagramclasspackage; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_diagramclasspackage', 2, true);


--
-- Name: seq_diagramcomposant; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_diagramcomposant', 1, false);


--
-- Name: seq_diagrampackage; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_diagrampackage', 5, true);


--
-- Name: seq_diagramtable; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_diagramtable', 13, true);


--
-- Name: seq_diagramtablecolonne; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_diagramtablecolonne', 1, false);


--
-- Name: seq_diplome; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_diplome', 1, false);


--
-- Name: seq_donation; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_donation', 80, true);


--
-- Name: seq_entitescript; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_entitescript', 1, false);


--
-- Name: seq_evenement; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_evenement', 1, false);


--
-- Name: seq_exceptiontache; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_exceptiontache', 1080, true);


--
-- Name: seq_experience; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_experience', 1, false);


--
-- Name: seq_genre; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_genre', 10, true);


--
-- Name: seq_histoinsert; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_histoinsert', 13174, true);


--
-- Name: seq_honoraire; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_honoraire', 1, false);


--
-- Name: seq_identification; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_identification', 1, false);


--
-- Name: seq_indisponibilite; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_indisponibilite', 120, true);


--
-- Name: seq_jourrepos; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_jourrepos', 1, false);


--
-- Name: seq_limiterole; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_limiterole', 3, true);


--
-- Name: seq_magasin2; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_magasin2', 1, false);


--
-- Name: seq_mappingtypeattribut; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_mappingtypeattribut', 1, false);


--
-- Name: seq_media; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_media', 1, false);


--
-- Name: seq_mediatype; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_mediatype', 10, true);


--
-- Name: seq_mention; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_mention', 1, false);


--
-- Name: seq_metierfille; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_metierfille', 20, true);


--
-- Name: seq_module; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_module', 260, true);


--
-- Name: seq_module_projet; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_module_projet', 1, false);


--
-- Name: seq_niveauclient; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_niveauclient', 1, false);


--
-- Name: seq_notification; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_notification', 1, false);


--
-- Name: seq_notificationdetails; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_notificationdetails', 7, true);


--
-- Name: seq_notificationgroupe; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_notificationgroupe', 5, true);


--
-- Name: seq_notificationsignal; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_notificationsignal', 12, true);


--
-- Name: seq_option; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_option', 1, false);


--
-- Name: seq_pageanalyse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_pageanalyse', 1, false);


--
-- Name: seq_pageanalyseattribut; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_pageanalyseattribut', 1, false);


--
-- Name: seq_pageattribut; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_pageattribut', 62, true);


--
-- Name: seq_pagefiche; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_pagefiche', 1, false);


--
-- Name: seq_pageficheattribut; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_pageficheattribut', 1, false);


--
-- Name: seq_pageliste; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_pageliste', 2, true);


--
-- Name: seq_pagelisteattribut; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_pagelisteattribut', 6, true);


--
-- Name: seq_pagesaisie; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_pagesaisie', 17, true);


--
-- Name: seq_panalysechampfiltre; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_panalysechampfiltre', 1, false);


--
-- Name: seq_parcours; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_parcours', 10, true);


--
-- Name: seq_participation_evenement; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_participation_evenement', 1, false);


--
-- Name: seq_pays; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_pays', 1, false);


--
-- Name: seq_phaseproject; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_phaseproject', 4180, true);


--
-- Name: seq_photo; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_photo', 1, false);


--
-- Name: seq_plistchampfiltre; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_plistchampfiltre', 1, false);


--
-- Name: seq_pointage; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_pointage', 100, true);


--
-- Name: seq_poste; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_poste', 15, true);


--
-- Name: seq_profil; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_profil', 1, true);


--
-- Name: seq_profildiplome; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_profildiplome', 1, false);


--
-- Name: seq_profilemplacement; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_profilemplacement', 1, false);


--
-- Name: seq_profilsocialmedia; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_profilsocialmedia', 1, false);


--
-- Name: seq_profilstatut; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_profilstatut', 1, false);


--
-- Name: seq_profiltypestatut; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_profiltypestatut', 3, true);


--
-- Name: seq_projetutilisateur; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_projetutilisateur', 1080, true);


--
-- Name: seq_promotion; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_promotion', 27, true);


--
-- Name: seq_proposition; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_proposition', 11, true);


--
-- Name: seq_province; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_province', 1, false);


--
-- Name: seq_publication; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_publication', 1, false);


--
-- Name: seq_publicationcommentaire; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_publicationcommentaire', 1, false);


--
-- Name: seq_publicationenregistrement; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_publicationenregistrement', 1, false);


--
-- Name: seq_publicationreaction; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_publicationreaction', 1, false);


--
-- Name: seq_qualite; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_qualite', 1, false);


--
-- Name: seq_reactiontype; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_reactiontype', 10, true);


--
-- Name: seq_relation; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_relation', 34, true);


--
-- Name: seq_requeteaenvoyer; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_requeteaenvoyer', 327720, true);


--
-- Name: seq_script; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_script', 1080, true);


--
-- Name: seq_scriptversionning; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_scriptversionning', 1120, true);


--
-- Name: seq_serveur; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_serveur', 1, true);


--
-- Name: seq_signalementpublication; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_signalementpublication', 1, false);


--
-- Name: seq_specialite; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_specialite', 15, true);


--
-- Name: seq_specialiteprofil; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_specialiteprofil', 1, false);


--
-- Name: seq_tache; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_tache', 184, true);


--
-- Name: seq_tache_git_details; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_tache_git_details', 260, true);


--
-- Name: seq_tache_git_mere; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_tache_git_mere', 180, true);


--
-- Name: seq_tauxhonoraire; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_tauxhonoraire', 1, false);


--
-- Name: seq_tempstravail; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_tempstravail', 1, false);


--
-- Name: seq_timingapplication; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_timingapplication', 226920, true);


--
-- Name: seq_timingsoustache; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_timingsoustache', 149160, true);


--
-- Name: seq_type_utilisateur; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_type_utilisateur', 20, true);


--
-- Name: seq_typeactionmetier; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typeactionmetier', 20, true);


--
-- Name: seq_typeattributclasse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typeattributclasse', 1, false);


--
-- Name: seq_typechampsspeciaux; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typechampsspeciaux', 1, false);


--
-- Name: seq_typeclasse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typeclasse', 1, false);


--
-- Name: seq_typedependancediagram; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typedependancediagram', 1, false);


--
-- Name: seq_typedependanceobjet; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typedependanceobjet', 1, false);


--
-- Name: seq_typeliaison; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typeliaison', 1, false);


--
-- Name: seq_typemagasin; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typemagasin', 1, false);


--
-- Name: seq_typeouinon; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typeouinon', 1, false);


--
-- Name: seq_typepageanalyse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typepageanalyse', 1, false);


--
-- Name: seq_typepageliste; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typepageliste', 1, false);


--
-- Name: seq_typepagesaisie; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typepagesaisie', 1, false);


--
-- Name: seq_typeplistchampfiltre; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typeplistchampfiltre', 1, false);


--
-- Name: seq_typepublication; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typepublication', 10, true);


--
-- Name: seq_typerelation; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typerelation', 1, false);


--
-- Name: seq_typescript; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typescript', 40, true);


--
-- Name: seq_typesignalement; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typesignalement', 10, true);


--
-- Name: seq_typetache; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_typetache', 20, true);


--
-- Name: seq_utilisateurhistoetat; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_utilisateurhistoetat', 1, false);


--
-- Name: seq_v_classeetfiche; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_v_classeetfiche', 1, false);


--
-- Name: seq_v_classetfiche; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_v_classetfiche', 1, false);


--
-- Name: seq_visibilite; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_visibilite', 1, false);


--
-- Name: seqaction; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqaction', 1, false);


--
-- Name: seqactiontache; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqactiontache', 1, false);


--
-- Name: seqarchitecture; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqarchitecture', 5, true);


--
-- Name: seqattacher_fichier; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqattacher_fichier', 113, true);


--
-- Name: seqavoirfc; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqavoirfc', 1, false);


--
-- Name: seqavoirfcfille; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqavoirfcfille', 1, false);


--
-- Name: seqbase; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqbase', 20, true);


--
-- Name: seqbaserelation; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqbaserelation', 18, true);


--
-- Name: seqbranche; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqbranche', 1, false);


--
-- Name: seqcaisse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqcaisse', 1, false);


--
-- Name: seqcanevatache; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqcanevatache', 2, true);


--
-- Name: seqcateging; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqcateging', 1, false);


--
-- Name: seqcategorie; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqcategorie', 100, true);


--
-- Name: seqcategorieavoirfc; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqcategorieavoirfc', 1, false);


--
-- Name: seqcategoriecaisse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqcategoriecaisse', 1, false);


--
-- Name: seqcategorieniveau; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqcategorieniveau', 1, false);


--
-- Name: seqclient; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqclient', 58, true);


--
-- Name: seqcote; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqcote', 120, true);


--
-- Name: seqcrcontent; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqcrcontent', 80, true);


--
-- Name: seqcrcontentfille; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqcrcontentfille', 80, true);


--
-- Name: seqcreation_projet; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqcreation_projet', 5100, true);


--
-- Name: seqdevise; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqdevise', 1, false);


--
-- Name: seqdonation; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqdonation', 7080, true);


--
-- Name: seqentite; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqentite', 4098, true);


--
-- Name: seqequipe; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqequipe', 20, true);


--
-- Name: seqexecution_script; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqexecution_script', 7, true);


--
-- Name: seqexecution_scriptfille; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqexecution_scriptfille', 7, true);


--
-- Name: seqexecutions; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqexecutions', 2, true);


--
-- Name: seqexternal_work; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqexternal_work', 2, true);


--
-- Name: seqfonctionnalite; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqfonctionnalite', 425, true);


--
-- Name: seqfournisseur; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqfournisseur', 1, false);


--
-- Name: seqhistoimport; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqhistoimport', 6960, true);


--
-- Name: seqhistorique; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqhistorique', 2877320, true);


--
-- Name: seqhistoriqueactif; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqhistoriqueactif', 69, true);


--
-- Name: seqhistovaleur; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqhistovaleur', 8280, true);


--
-- Name: seqingredients; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqingredients', 1, false);


--
-- Name: seqmagasin; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqmagasin', 1, false);


--
-- Name: seqmailcc; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqmailcc', 1, false);


--
-- Name: seqmailrapport; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqmailrapport', 60, true);


--
-- Name: seqmetier; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqmetier', 932, true);


--
-- Name: seqmetierrelation; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqmetierrelation', 1, true);


--
-- Name: seqmotifavoirfc; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqmotifavoirfc', 1, false);


--
-- Name: seqmouvementcaisse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqmouvementcaisse', 21, true);


--
-- Name: seqmvtcaisseprevision; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqmvtcaisseprevision', 1, false);


--
-- Name: seqniveau; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqniveau', 1, false);


--
-- Name: seqnotificationaction; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqnotificationaction', 1, false);


--
-- Name: seqordonnerpaiement; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqordonnerpaiement', 1, false);


--
-- Name: seqpage; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqpage', 8268, true);


--
-- Name: seqpagerelation; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqpagerelation', 1, false);


--
-- Name: seqparamcrypt; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqparamcrypt', 90, true);


--
-- Name: seqphase; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqphase', 3, true);


--
-- Name: seqpiecejointe; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqpiecejointe', 211, true);


--
-- Name: seqpoint; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqpoint', 1, false);


--
-- Name: seqprevision; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqprevision', 1, false);


--
-- Name: seqprojet; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqprojet', 1, true);


--
-- Name: seqprojetequipe; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqprojetequipe', 100, true);


--
-- Name: seqpromesse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqpromesse', 1, false);


--
-- Name: seqrep; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqrep', 1, false);


--
-- Name: seqrepd; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqrepd', 1, false);


--
-- Name: seqreportcaisse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqreportcaisse', 100, true);


--
-- Name: seqrequeteaenvoyer; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqrequeteaenvoyer', 1, false);


--
-- Name: seqscript_projet; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqscript_projet', 85, true);


--
-- Name: seqsource; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqsource', 1, false);


--
-- Name: seqtache; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtache', 339659, true);


--
-- Name: seqtachemere; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtachemere', 17726, true);


--
-- Name: seqtachemere_detailsdefaut; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtachemere_detailsdefaut', 1, false);


--
-- Name: seqtachemeredefaut; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtachemeredefaut', 1, false);


--
-- Name: seqtauxavancementmodule; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtauxavancementmodule', 1, false);


--
-- Name: seqtauxavancementprojet; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtauxavancementprojet', 1, false);


--
-- Name: seqtauxdechange; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtauxdechange', 1, false);


--
-- Name: seqtype; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtype', 100, true);


--
-- Name: seqtypeabsence; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtypeabsence', 1, false);


--
-- Name: seqtypeaction; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtypeaction', 1, false);


--
-- Name: seqtypebase; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtypebase', 2, true);


--
-- Name: seqtypecaisse; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtypecaisse', 1, false);


--
-- Name: seqtypefichier; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtypefichier', 1, false);


--
-- Name: seqtypefournisseur; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtypefournisseur', 1, false);


--
-- Name: seqtypemetier; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtypemetier', 2, true);


--
-- Name: seqtypepage; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtypepage', 4, true);


--
-- Name: seqtyperepos; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqtyperepos', 1, false);


--
-- Name: sequnite; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sequnite', 1, false);


--
-- Name: sequserequipe; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sequserequipe', 120, true);


--
-- Name: sequtilisateur; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sequtilisateur', 2340, true);


--
-- Name: seqvente; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqvente', 22, true);


--
-- Name: seqventedetails; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqventedetails', 53, true);


--
-- Name: seqwork_branche; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqwork_branche', 1, false);


--
-- Name: seqwork_type; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seqwork_type', 1, false);


--
-- Name: commentairereaction commentairereaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentairereaction
    ADD CONSTRAINT commentairereaction_pkey PRIMARY KEY (idcommentairereaction);


--
-- Name: diplome diplome_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diplome
    ADD CONSTRAINT diplome_pkey PRIMARY KEY (iddiplome);


--
-- Name: direction direction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.direction
    ADD CONSTRAINT direction_pkey PRIMARY KEY (id);


--
-- Name: evenement evenement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evenement
    ADD CONSTRAINT evenement_pkey PRIMARY KEY (idevenement);


--
-- Name: experience experience_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT experience_pkey PRIMARY KEY (idexperience);


--
-- Name: genre genre_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_pkey PRIMARY KEY (idgenre);


--
-- Name: histoinsert histoinsert_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.histoinsert
    ADD CONSTRAINT histoinsert_pkey PRIMARY KEY (idhistorique);


--
-- Name: historique historique_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historique
    ADD CONSTRAINT historique_pkey PRIMARY KEY (idhistorique);


--
-- Name: historiqueactif historiqueactif_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historiqueactif
    ADD CONSTRAINT historiqueactif_pkey PRIMARY KEY (id);


--
-- Name: identification identification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identification
    ADD CONSTRAINT identification_pkey PRIMARY KEY (ididentification);


--
-- Name: limiterole limiterole_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.limiterole
    ADD CONSTRAINT limiterole_pkey PRIMARY KEY (idlimiterole);


--
-- Name: media media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (idmedia);


--
-- Name: mediatype mediatype_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mediatype
    ADD CONSTRAINT mediatype_pkey PRIMARY KEY (idmediatype);


--
-- Name: mention mention_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mention
    ADD CONSTRAINT mention_pkey PRIMARY KEY (idmention);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (idnotification);


--
-- Name: option option_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.option
    ADD CONSTRAINT option_pkey PRIMARY KEY (idoption);


--
-- Name: paramcrypt paramcrypt_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paramcrypt
    ADD CONSTRAINT paramcrypt_pk PRIMARY KEY (id);


--
-- Name: parcours parcours_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parcours
    ADD CONSTRAINT parcours_pkey PRIMARY KEY (idparcours);


--
-- Name: participation_evenement participation_evenement_idevenement_idutilisateur_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participation_evenement
    ADD CONSTRAINT participation_evenement_idevenement_idutilisateur_key UNIQUE (idevenement, idutilisateur);


--
-- Name: participation_evenement participation_evenement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participation_evenement
    ADD CONSTRAINT participation_evenement_pkey PRIMARY KEY (idparticipation);


--
-- Name: photo photo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_pkey PRIMARY KEY (idphoto);


--
-- Name: menudynamique pkmenud; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menudynamique
    ADD CONSTRAINT pkmenud PRIMARY KEY (id);


--
-- Name: poste poste_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poste
    ADD CONSTRAINT poste_pkey PRIMARY KEY (idposte);


--
-- Name: profil profil_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil
    ADD CONSTRAINT profil_email_key UNIQUE (email);


--
-- Name: profil profil_idutilisateur_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil
    ADD CONSTRAINT profil_idutilisateur_key UNIQUE (idutilisateur);


--
-- Name: profil profil_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil
    ADD CONSTRAINT profil_pkey PRIMARY KEY (idprofil);


--
-- Name: profildiplome profildiplome_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profildiplome
    ADD CONSTRAINT profildiplome_pkey PRIMARY KEY (idoption, idprofil, idprofildiplome);


--
-- Name: profilemplacement profilemplacement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profilemplacement
    ADD CONSTRAINT profilemplacement_pkey PRIMARY KEY (id);


--
-- Name: profilsocialmedia profilsocialmedia_idprofil_idreseausocial_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profilsocialmedia
    ADD CONSTRAINT profilsocialmedia_idprofil_idreseausocial_key UNIQUE (idprofil, idreseausocial);


--
-- Name: profilsocialmedia profilsocialmedia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profilsocialmedia
    ADD CONSTRAINT profilsocialmedia_pkey PRIMARY KEY (idprofilsocial);


--
-- Name: profilstatut profilstatut_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profilstatut
    ADD CONSTRAINT profilstatut_pkey PRIMARY KEY (id);


--
-- Name: profiltypestatut profiltypestatut_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiltypestatut
    ADD CONSTRAINT profiltypestatut_pkey PRIMARY KEY (idprofiltypestatut);


--
-- Name: promotion promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (idpromotion);


--
-- Name: publication publication_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_pkey PRIMARY KEY (idpublication);


--
-- Name: publicationcommentaire publicationcommentaire_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationcommentaire
    ADD CONSTRAINT publicationcommentaire_pkey PRIMARY KEY (idpublicationcommentaire);


--
-- Name: publicationenregistrement publicationenregistrement_idpublication_idutilisateur_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationenregistrement
    ADD CONSTRAINT publicationenregistrement_idpublication_idutilisateur_key UNIQUE (idpublication, idutilisateur);


--
-- Name: publicationenregistrement publicationenregistrement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationenregistrement
    ADD CONSTRAINT publicationenregistrement_pkey PRIMARY KEY (idpublicationenregistrement);


--
-- Name: publicationhashtag publicationhashtag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationhashtag
    ADD CONSTRAINT publicationhashtag_pkey PRIMARY KEY (idpublicationhashtag);


--
-- Name: publicationreaction publicationreaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationreaction
    ADD CONSTRAINT publicationreaction_pkey PRIMARY KEY (idpublicationreaction);


--
-- Name: publicationvisibilite publicationvisibilite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationvisibilite
    ADD CONSTRAINT publicationvisibilite_pkey PRIMARY KEY (idpublicationvisibilite);


--
-- Name: publicationvue publicationvue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationvue
    ADD CONSTRAINT publicationvue_pkey PRIMARY KEY (idpublicationvue);


--
-- Name: reactiontype reactiontype_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactiontype
    ADD CONSTRAINT reactiontype_pkey PRIMARY KEY (idreactiontype);


--
-- Name: reseauxsociaux reseauxsociaux_libelle_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reseauxsociaux
    ADD CONSTRAINT reseauxsociaux_libelle_key UNIQUE (libelle);


--
-- Name: reseauxsociaux reseauxsociaux_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reseauxsociaux
    ADD CONSTRAINT reseauxsociaux_pkey PRIMARY KEY (idreseausocial);


--
-- Name: signalementpublication signalementpublication_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signalementpublication
    ADD CONSTRAINT signalementpublication_pkey PRIMARY KEY (idsignalementpublication);


--
-- Name: specialite specialite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.specialite
    ADD CONSTRAINT specialite_pkey PRIMARY KEY (idspecialite);


--
-- Name: specialiteprofil specialiteprofil_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.specialiteprofil
    ADD CONSTRAINT specialiteprofil_pkey PRIMARY KEY (idspecialite, idprofil, specialiteprofil);


--
-- Name: typepublication typepublication_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.typepublication
    ADD CONSTRAINT typepublication_pkey PRIMARY KEY (idtypepublication);


--
-- Name: typesignalement typesignalement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.typesignalement
    ADD CONSTRAINT typesignalement_pkey PRIMARY KEY (idtypesignalement);


--
-- Name: utilisateur unique_utilisateur_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT unique_utilisateur_id UNIQUE (id);


--
-- Name: commentairereaction uq_commentairereaction_user_commentaire; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentairereaction
    ADD CONSTRAINT uq_commentairereaction_user_commentaire UNIQUE (idutilisateur, idpublicationcommentaire);


--
-- Name: publicationreaction uq_publicationreaction_user_publication; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationreaction
    ADD CONSTRAINT uq_publicationreaction_user_publication UNIQUE (idutilisateur, idpublication);


--
-- Name: publicationvue uq_pubvue; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationvue
    ADD CONSTRAINT uq_pubvue UNIQUE (idutilisateur, idpublication);


--
-- Name: signalementpublication uq_signalementpublication_user_publication; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signalementpublication
    ADD CONSTRAINT uq_signalementpublication_user_publication UNIQUE (idutilisateur, idpublication);


--
-- Name: usermenu usermenu_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usermenu
    ADD CONSTRAINT usermenu_pkey PRIMARY KEY (id);


--
-- Name: utilisateur utilisateur_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_pk PRIMARY KEY (refuser);


--
-- Name: utilisateurhistoetat utilisateurhistoetat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurhistoetat
    ADD CONSTRAINT utilisateurhistoetat_pkey PRIMARY KEY (idutilisateurhistoetat);


--
-- Name: visibilite visibilite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visibilite
    ADD CONSTRAINT visibilite_pkey PRIMARY KEY (idvisibilite);


--
-- Name: idx_pub_puborigine; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pub_puborigine ON public.publication USING btree (idpuborigine) WHERE (idpuborigine IS NOT NULL);


--
-- Name: idx_pubhashtag_idref; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pubhashtag_idref ON public.publicationhashtag USING btree (idref);


--
-- Name: idx_pubhashtag_pub; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pubhashtag_pub ON public.publicationhashtag USING btree (idpublication);


--
-- Name: idx_publicationcommentaire_pub; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicationcommentaire_pub ON public.publicationcommentaire USING btree (idpublication);


--
-- Name: idx_publicationreaction_pub; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicationreaction_pub ON public.publicationreaction USING btree (idpublication);


--
-- Name: idx_pubvis_pub; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pubvis_pub ON public.publicationvisibilite USING btree (idpublication);


--
-- Name: idx_pubvue_pub; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pubvue_pub ON public.publicationvue USING btree (idpublication);


--
-- Name: idx_pubvue_user_pub; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pubvue_user_pub ON public.publicationvue USING btree (idutilisateur, idpublication);


--
-- Name: idxprofilsocialmediaidprofil; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idxprofilsocialmediaidprofil ON public.profilsocialmedia USING btree (idprofil);


--
-- Name: idxprofilsocialmediareseau; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idxprofilsocialmediareseau ON public.profilsocialmedia USING btree (idreseausocial);


--
-- Name: idxreseauxsociauxactif; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idxreseauxsociauxactif ON public.reseauxsociaux USING btree (actif, priorite DESC);


--
-- Name: uq_pubhashtag; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_pubhashtag ON public.publicationhashtag USING btree (idpublication, hashtag);


--
-- Name: uq_pubvis_promo; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_pubvis_promo ON public.publicationvisibilite USING btree (idpublication) WHERE ((typecible)::text = 'PROMOTION'::text);


--
-- Name: uq_pubvis_spec; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_pubvis_spec ON public.publicationvisibilite USING btree (idpublication, idref) WHERE ((typecible)::text = 'SPECIALITE'::text);


--
-- Name: commentairereaction commentairereaction_idpublicationcommentaire_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentairereaction
    ADD CONSTRAINT commentairereaction_idpublicationcommentaire_fkey FOREIGN KEY (idpublicationcommentaire) REFERENCES public.publicationcommentaire(idpublicationcommentaire);


--
-- Name: commentairereaction commentairereaction_idreactiontype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentairereaction
    ADD CONSTRAINT commentairereaction_idreactiontype_fkey FOREIGN KEY (idreactiontype) REFERENCES public.reactiontype(idreactiontype);


--
-- Name: commentairereaction commentairereaction_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentairereaction
    ADD CONSTRAINT commentairereaction_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: evenement evenement_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evenement
    ADD CONSTRAINT evenement_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: experience experience_idposte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT experience_idposte_fkey FOREIGN KEY (idposte) REFERENCES public.poste(idposte);


--
-- Name: experience experience_idprofil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT experience_idprofil_fkey FOREIGN KEY (idprofil) REFERENCES public.profil(idprofil);


--
-- Name: identification identification_idpublication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identification
    ADD CONSTRAINT identification_idpublication_fkey FOREIGN KEY (idpublication) REFERENCES public.publication(idpublication);


--
-- Name: identification identification_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identification
    ADD CONSTRAINT identification_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: media media_idmediatype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_idmediatype_fkey FOREIGN KEY (idmediatype) REFERENCES public.mediatype(idmediatype);


--
-- Name: media media_idpublication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_idpublication_fkey FOREIGN KEY (idpublication) REFERENCES public.publication(idpublication);


--
-- Name: mention mention_idpublicationcommentaire_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mention
    ADD CONSTRAINT mention_idpublicationcommentaire_fkey FOREIGN KEY (idpublicationcommentaire) REFERENCES public.publicationcommentaire(idpublicationcommentaire);


--
-- Name: mention mention_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mention
    ADD CONSTRAINT mention_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: notification notification_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: participation_evenement participation_evenement_idevenement_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participation_evenement
    ADD CONSTRAINT participation_evenement_idevenement_fkey FOREIGN KEY (idevenement) REFERENCES public.evenement(idevenement) ON DELETE CASCADE;


--
-- Name: photo photo_idprofil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_idprofil_fkey FOREIGN KEY (idprofil) REFERENCES public.profil(idprofil);


--
-- Name: profil profil_idgenre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil
    ADD CONSTRAINT profil_idgenre_fkey FOREIGN KEY (idgenre) REFERENCES public.genre(idgenre);


--
-- Name: profil profil_idparcours_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil
    ADD CONSTRAINT profil_idparcours_fkey FOREIGN KEY (idparcours) REFERENCES public.parcours(idparcours);


--
-- Name: profil profil_idpromotion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil
    ADD CONSTRAINT profil_idpromotion_fkey FOREIGN KEY (idpromotion) REFERENCES public.promotion(idpromotion);


--
-- Name: profil profil_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil
    ADD CONSTRAINT profil_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: profildiplome profildiplome_iddiplome_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profildiplome
    ADD CONSTRAINT profildiplome_iddiplome_fkey FOREIGN KEY (iddiplome) REFERENCES public.diplome(iddiplome);


--
-- Name: profildiplome profildiplome_idoption_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profildiplome
    ADD CONSTRAINT profildiplome_idoption_fkey FOREIGN KEY (idoption) REFERENCES public.option(idoption);


--
-- Name: profildiplome profildiplome_idprofil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profildiplome
    ADD CONSTRAINT profildiplome_idprofil_fkey FOREIGN KEY (idprofil) REFERENCES public.profil(idprofil);


--
-- Name: profilemplacement profilemplacement_idprofil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profilemplacement
    ADD CONSTRAINT profilemplacement_idprofil_fkey FOREIGN KEY (idprofil) REFERENCES public.profil(idprofil);


--
-- Name: profilsocialmedia profilsocialmedia_idprofil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profilsocialmedia
    ADD CONSTRAINT profilsocialmedia_idprofil_fkey FOREIGN KEY (idprofil) REFERENCES public.profil(idprofil) ON DELETE CASCADE;


--
-- Name: profilsocialmedia profilsocialmedia_idreseausocial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profilsocialmedia
    ADD CONSTRAINT profilsocialmedia_idreseausocial_fkey FOREIGN KEY (idreseausocial) REFERENCES public.reseauxsociaux(idreseausocial) ON DELETE CASCADE;


--
-- Name: profilstatut profilstatut_idprofil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profilstatut
    ADD CONSTRAINT profilstatut_idprofil_fkey FOREIGN KEY (idprofil) REFERENCES public.profil(idprofil);


--
-- Name: profilstatut profilstatut_idprofiltypestatut_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profilstatut
    ADD CONSTRAINT profilstatut_idprofiltypestatut_fkey FOREIGN KEY (idprofiltypestatut) REFERENCES public.profiltypestatut(idprofiltypestatut);


--
-- Name: promotion promotion_idparcours_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_idparcours_fkey FOREIGN KEY (idparcours) REFERENCES public.parcours(idparcours);


--
-- Name: publication publication_idpuborigine_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_idpuborigine_fkey FOREIGN KEY (idpuborigine) REFERENCES public.publication(idpublication) ON DELETE SET NULL;


--
-- Name: publication publication_idtypepublication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_idtypepublication_fkey FOREIGN KEY (idtypepublication) REFERENCES public.typepublication(idtypepublication);


--
-- Name: publication publication_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication
    ADD CONSTRAINT publication_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: publicationcommentaire publicationcommentaire_idpublication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationcommentaire
    ADD CONSTRAINT publicationcommentaire_idpublication_fkey FOREIGN KEY (idpublication) REFERENCES public.publication(idpublication);


--
-- Name: publicationcommentaire publicationcommentaire_idpublicationcommentaire_1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationcommentaire
    ADD CONSTRAINT publicationcommentaire_idpublicationcommentaire_1_fkey FOREIGN KEY (idpublicationcommentaire_1) REFERENCES public.publicationcommentaire(idpublicationcommentaire);


--
-- Name: publicationcommentaire publicationcommentaire_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationcommentaire
    ADD CONSTRAINT publicationcommentaire_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: publicationenregistrement publicationenregistrement_idpublication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationenregistrement
    ADD CONSTRAINT publicationenregistrement_idpublication_fkey FOREIGN KEY (idpublication) REFERENCES public.publication(idpublication);


--
-- Name: publicationenregistrement publicationenregistrement_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationenregistrement
    ADD CONSTRAINT publicationenregistrement_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: publicationhashtag publicationhashtag_idpublication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationhashtag
    ADD CONSTRAINT publicationhashtag_idpublication_fkey FOREIGN KEY (idpublication) REFERENCES public.publication(idpublication);


--
-- Name: publicationreaction publicationreaction_idpublication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationreaction
    ADD CONSTRAINT publicationreaction_idpublication_fkey FOREIGN KEY (idpublication) REFERENCES public.publication(idpublication);


--
-- Name: publicationreaction publicationreaction_idreactiontype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationreaction
    ADD CONSTRAINT publicationreaction_idreactiontype_fkey FOREIGN KEY (idreactiontype) REFERENCES public.reactiontype(idreactiontype);


--
-- Name: publicationreaction publicationreaction_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationreaction
    ADD CONSTRAINT publicationreaction_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: publicationvisibilite publicationvisibilite_idpublication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicationvisibilite
    ADD CONSTRAINT publicationvisibilite_idpublication_fkey FOREIGN KEY (idpublication) REFERENCES public.publication(idpublication);


--
-- Name: signalementpublication signalementpublication_idpublication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signalementpublication
    ADD CONSTRAINT signalementpublication_idpublication_fkey FOREIGN KEY (idpublication) REFERENCES public.publication(idpublication);


--
-- Name: signalementpublication signalementpublication_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signalementpublication
    ADD CONSTRAINT signalementpublication_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: signalementpublication signalementpublication_typesignalement_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signalementpublication
    ADD CONSTRAINT signalementpublication_typesignalement_fkey FOREIGN KEY (typesignalement) REFERENCES public.typesignalement(idtypesignalement);


--
-- Name: specialiteprofil specialiteprofil_idprofil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.specialiteprofil
    ADD CONSTRAINT specialiteprofil_idprofil_fkey FOREIGN KEY (idprofil) REFERENCES public.profil(idprofil);


--
-- Name: specialiteprofil specialiteprofil_idspecialite_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.specialiteprofil
    ADD CONSTRAINT specialiteprofil_idspecialite_fkey FOREIGN KEY (idspecialite) REFERENCES public.specialite(idspecialite);


--
-- Name: utilisateurhistoetat utilisateurhistoetat_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurhistoetat
    ADD CONSTRAINT utilisateurhistoetat_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: visibilite visibilite_idprofil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visibilite
    ADD CONSTRAINT visibilite_idprofil_fkey FOREIGN KEY (idprofil) REFERENCES public.profil(idprofil);


--
-- PostgreSQL database dump complete
--

