--
-- PostgreSQL database dump
--

-- \restrict 1bnegjh1b0OudEjWtO5J7WaLPkwxFgOdNnaB5T5i30vnVHbCi1MZkXhUq29xfss

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: actiondependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.actiondependante(identite character varying, rep character varying) OWNER TO postgres;

--
-- Name: basedependance(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.basedependance(idbase character varying, rep character varying) OWNER TO postgres;

--
-- Name: basedependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.basedependante(idbase character varying, rep character varying) OWNER TO postgres;

--
-- Name: constructabsence(character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.constructabsence(utilisateur_ character varying) OWNER TO postgres;

--
-- Name: constructlistabsence(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.constructlistabsence() OWNER TO postgres;

--
-- Name: entitedependante(character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.entitedependante(identite character varying) OWNER TO postgres;

--
-- Name: entitefille(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.entitefille(identite character varying, rep character varying) OWNER TO postgres;

--
-- Name: entitefilleclass(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.entitefilleclass(identite character varying, rep character varying) OWNER TO postgres;

--
-- Name: f_etat_devis(date, date); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.f_etat_devis(p_debut date, p_fin date) OWNER TO postgres;

--
-- Name: f_status_projets(date, date); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.f_status_projets(p_debut date, p_fin date) OWNER TO postgres;

--
-- Name: format_minutes(double precision); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.format_minutes(total_minutes double precision) OWNER TO postgres;

--
-- Name: format_minutes(integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.format_minutes(total_minutes integer) OWNER TO postgres;

--
-- Name: get_seq_absence(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_absence() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_absence'));
END
$$;


ALTER FUNCTION public.get_seq_absence() OWNER TO postgres;

--
-- Name: get_seq_actionprojet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_actionprojet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_ACTIONPROJET'));
        END
    $$;


ALTER FUNCTION public.get_seq_actionprojet() OWNER TO postgres;

--
-- Name: get_seq_alert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_alert() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_ALERT'));
END
$$;


ALTER FUNCTION public.get_seq_alert() OWNER TO postgres;

--
-- Name: get_seq_boutonchamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_boutonchamp() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_boutonchamp');

END;

$$;


ALTER FUNCTION public.get_seq_boutonchamp() OWNER TO postgres;

--
-- Name: get_seq_boutonpage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_boutonpage() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_boutonpage');

END;

$$;


ALTER FUNCTION public.get_seq_boutonpage() OWNER TO postgres;

--
-- Name: get_seq_caisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_caisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_caisse'));
END
$$;


ALTER FUNCTION public.get_seq_caisse() OWNER TO postgres;

--
-- Name: get_seq_champdynamique(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_champdynamique() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_champdynamique'));

END

$$;


ALTER FUNCTION public.get_seq_champdynamique() OWNER TO postgres;

--
-- Name: get_seq_champsspeciaux(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_champsspeciaux() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_champsspeciaux'));

END

$$;


ALTER FUNCTION public.get_seq_champsspeciaux() OWNER TO postgres;

--
-- Name: get_seq_connexion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_connexion() RETURNS integer
    LANGUAGE plpgsql
    AS $$ begin return (
select
	nextval('seq_connexion'));
end $$;


ALTER FUNCTION public.get_seq_connexion() OWNER TO postgres;

--
-- Name: get_seq_coutprevisionnel(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_coutprevisionnel() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COUTPREVISIONNEL'));
        END
    $$;


ALTER FUNCTION public.get_seq_coutprevisionnel() OWNER TO postgres;

--
-- Name: get_seq_devis(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_devis() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_DEVIS'));
        END
    $$;


ALTER FUNCTION public.get_seq_devis() OWNER TO postgres;

--
-- Name: get_seq_devisfille(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_devisfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_DEVISFILLE'));
        END
    $$;


ALTER FUNCTION public.get_seq_devisfille() OWNER TO postgres;

--
-- Name: get_seq_entitescript(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_entitescript() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_entitescript'));
		END
		$$;


ALTER FUNCTION public.get_seq_entitescript() OWNER TO postgres;

--
-- Name: get_seq_exceptiontache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_exceptiontache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_exceptiontache'));
END
    $$;


ALTER FUNCTION public.get_seq_exceptiontache() OWNER TO postgres;

--
-- Name: get_seq_histoinsert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_histoinsert() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_HistoInsert'));
        END
    $$;


ALTER FUNCTION public.get_seq_histoinsert() OWNER TO postgres;

--
-- Name: get_seq_honoraire(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_honoraire() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_HONORAIRE'));
        END
    $$;


ALTER FUNCTION public.get_seq_honoraire() OWNER TO postgres;

--
-- Name: get_seq_indisponibilite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_indisponibilite() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN (SELECT nextval('seq_indisponibilite'));

END

$$;


ALTER FUNCTION public.get_seq_indisponibilite() OWNER TO postgres;

--
-- Name: get_seq_jourrepos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_jourrepos() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_jourrepos'));
END
$$;


ALTER FUNCTION public.get_seq_jourrepos() OWNER TO postgres;

--
-- Name: get_seq_magasin2(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_magasin2() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_magasin2'));
END
$$;


ALTER FUNCTION public.get_seq_magasin2() OWNER TO postgres;

--
-- Name: get_seq_mappingtypeattribut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_mappingtypeattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_mappingtypeattribut');

END;

$$;


ALTER FUNCTION public.get_seq_mappingtypeattribut() OWNER TO postgres;

--
-- Name: get_seq_module(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_module() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_module'));
        END
    $$;


ALTER FUNCTION public.get_seq_module() OWNER TO postgres;

--
-- Name: get_seq_module_projet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_module_projet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_module'));
        END
    $$;


ALTER FUNCTION public.get_seq_module_projet() OWNER TO postgres;

--
-- Name: get_seq_niveauclient(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_niveauclient() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_NIVEAUCLIENT'));
        END
    $$;


ALTER FUNCTION public.get_seq_niveauclient() OWNER TO postgres;

--
-- Name: get_seq_notification(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_notification() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_notification'));
END
$$;


ALTER FUNCTION public.get_seq_notification() OWNER TO postgres;

--
-- Name: get_seq_notificationdetails(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_notificationdetails() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_NotificationDetails'));

END

$$;


ALTER FUNCTION public.get_seq_notificationdetails() OWNER TO postgres;

--
-- Name: get_seq_notificationgroupe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_notificationgroupe() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_notificationGroupe'));

END

$$;


ALTER FUNCTION public.get_seq_notificationgroupe() OWNER TO postgres;

--
-- Name: get_seq_notificationsignal(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_notificationsignal() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_notificationSignal'));
END
$$;


ALTER FUNCTION public.get_seq_notificationsignal() OWNER TO postgres;

--
-- Name: get_seq_pageanalyse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pageanalyse() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pageanalyse');

END;

$$;


ALTER FUNCTION public.get_seq_pageanalyse() OWNER TO postgres;

--
-- Name: get_seq_pageanalyseattribut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pageanalyseattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pageanalyseattribut');

END;

$$;


ALTER FUNCTION public.get_seq_pageanalyseattribut() OWNER TO postgres;

--
-- Name: get_seq_pageattribut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pageattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_pageattribut'));

END

$$;


ALTER FUNCTION public.get_seq_pageattribut() OWNER TO postgres;

--
-- Name: get_seq_pagefiche(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pagefiche() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pagefiche');

END;

$$;


ALTER FUNCTION public.get_seq_pagefiche() OWNER TO postgres;

--
-- Name: get_seq_pageficheattribut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pageficheattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pageficheattribut');

END;

$$;


ALTER FUNCTION public.get_seq_pageficheattribut() OWNER TO postgres;

--
-- Name: get_seq_pageliste(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pageliste() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pageliste');

END;

$$;


ALTER FUNCTION public.get_seq_pageliste() OWNER TO postgres;

--
-- Name: get_seq_pagelisteattribut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pagelisteattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_pagelisteattribut');

END;

$$;


ALTER FUNCTION public.get_seq_pagelisteattribut() OWNER TO postgres;

--
-- Name: get_seq_pagesaisie(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pagesaisie() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_pagesaisie'));

END

$$;


ALTER FUNCTION public.get_seq_pagesaisie() OWNER TO postgres;

--
-- Name: get_seq_panalysechampfiltre(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_panalysechampfiltre() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_panalysechampfiltre');

END;

$$;


ALTER FUNCTION public.get_seq_panalysechampfiltre() OWNER TO postgres;

--
-- Name: get_seq_pays(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pays() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PAYS'));
        END
    $$;


ALTER FUNCTION public.get_seq_pays() OWNER TO postgres;

--
-- Name: get_seq_phaseproject(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_phaseproject() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PHASEPROJECT'));
        END
    $$;


ALTER FUNCTION public.get_seq_phaseproject() OWNER TO postgres;

--
-- Name: get_seq_plistchampfiltre(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_plistchampfiltre() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_plistchampfiltre');

END;

$$;


ALTER FUNCTION public.get_seq_plistchampfiltre() OWNER TO postgres;

--
-- Name: get_seq_pointage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pointage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_pointage'));
        END
    $$;


ALTER FUNCTION public.get_seq_pointage() OWNER TO postgres;

--
-- Name: get_seq_projetutilisateur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_projetutilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PROJETUTILISATEUR'));
        END
    $$;


ALTER FUNCTION public.get_seq_projetutilisateur() OWNER TO postgres;

--
-- Name: get_seq_proposition(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_proposition() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN (SELECT nextval('seq_proposition'));

END

$$;


ALTER FUNCTION public.get_seq_proposition() OWNER TO postgres;

--
-- Name: get_seq_province(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_province() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PROVINCE'));
        END
    $$;


ALTER FUNCTION public.get_seq_province() OWNER TO postgres;

--
-- Name: get_seq_qualite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_qualite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_QUALITE'));
        END
    $$;


ALTER FUNCTION public.get_seq_qualite() OWNER TO postgres;

--
-- Name: get_seq_script(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_script() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_script'));
		END
		$$;


ALTER FUNCTION public.get_seq_script() OWNER TO postgres;

--
-- Name: get_seq_scriptversionning(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_scriptversionning() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_scriptversionning'));
		END
		$$;


ALTER FUNCTION public.get_seq_scriptversionning() OWNER TO postgres;

--
-- Name: get_seq_tache_git_details(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_tache_git_details() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN (SELECT nextval('seq_tache_git_details'));

END

$$;


ALTER FUNCTION public.get_seq_tache_git_details() OWNER TO postgres;

--
-- Name: get_seq_tache_git_mere(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_tache_git_mere() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN (SELECT nextval('seq_tache_git_mere'));

END

$$;


ALTER FUNCTION public.get_seq_tache_git_mere() OWNER TO postgres;

--
-- Name: get_seq_tauxhonoraire(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_tauxhonoraire() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TAUXHONORAIRE'));
        END
    $$;


ALTER FUNCTION public.get_seq_tauxhonoraire() OWNER TO postgres;

--
-- Name: get_seq_tempstravail(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_tempstravail() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_tempstravail'));
END
$$;


ALTER FUNCTION public.get_seq_tempstravail() OWNER TO postgres;

--
-- Name: get_seq_timingapplication(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_timingapplication() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TIMINGAPPLICATION'));
        END
    $$;


ALTER FUNCTION public.get_seq_timingapplication() OWNER TO postgres;

--
-- Name: get_seq_type_utilisateur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_type_utilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TYPE_UTILISATEUR'));
        END
    $$;


ALTER FUNCTION public.get_seq_type_utilisateur() OWNER TO postgres;

--
-- Name: get_seq_typechampsspeciaux(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typechampsspeciaux() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_typechampsspeciaux'));

END

$$;


ALTER FUNCTION public.get_seq_typechampsspeciaux() OWNER TO postgres;

--
-- Name: get_seq_typemagasin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typemagasin() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typemagasin'));
END
$$;


ALTER FUNCTION public.get_seq_typemagasin() OWNER TO postgres;

--
-- Name: get_seq_typeouinon(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typeouinon() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_typeouinon'));

END

$$;


ALTER FUNCTION public.get_seq_typeouinon() OWNER TO postgres;

--
-- Name: get_seq_typepageliste(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typepageliste() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_typepageliste');

END;

$$;


ALTER FUNCTION public.get_seq_typepageliste() OWNER TO postgres;

--
-- Name: get_seq_typepagesaisie(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typepagesaisie() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seq_typepagesaisie'));

END

$$;


ALTER FUNCTION public.get_seq_typepagesaisie() OWNER TO postgres;

--
-- Name: get_seq_typeplistchampfiltre(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typeplistchampfiltre() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN nextval('seq_typeplistchampfiltre');

END;

$$;


ALTER FUNCTION public.get_seq_typeplistchampfiltre() OWNER TO postgres;

--
-- Name: get_seq_typescript(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typescript() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_typescript'));
		END
		$$;


ALTER FUNCTION public.get_seq_typescript() OWNER TO postgres;

--
-- Name: get_seq_typetache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typetache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_typetache'));
        END
    $$;


ALTER FUNCTION public.get_seq_typetache() OWNER TO postgres;

--
-- Name: get_seqattacher_fichier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqattacher_fichier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqattacher_fichier'));
END
$$;


ALTER FUNCTION public.get_seqattacher_fichier() OWNER TO postgres;

--
-- Name: get_seqbranche(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqbranche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqbranche'));
END
$$;


ALTER FUNCTION public.get_seqbranche() OWNER TO postgres;

--
-- Name: get_seqclient(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqclient() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqclient'));
END
$$;


ALTER FUNCTION public.get_seqclient() OWNER TO postgres;

--
-- Name: get_seqdiagramclass(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramclass() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramClass'));
END
$$;


ALTER FUNCTION public.get_seqdiagramclass() OWNER TO postgres;

--
-- Name: get_seqdiagramclasscomposant(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramclasscomposant() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramClassComposant'));
END
$$;


ALTER FUNCTION public.get_seqdiagramclasscomposant() OWNER TO postgres;

--
-- Name: get_seqdiagramclasscomposanttype(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramclasscomposanttype() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramClassComposantType'));
END
$$;


ALTER FUNCTION public.get_seqdiagramclasscomposanttype() OWNER TO postgres;

--
-- Name: get_seqdiagramclasspackage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramclasspackage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramClassPackage'));
END
$$;


ALTER FUNCTION public.get_seqdiagramclasspackage() OWNER TO postgres;

--
-- Name: get_seqdiagramcomposant(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramcomposant() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramComposant'));
END
$$;


ALTER FUNCTION public.get_seqdiagramcomposant() OWNER TO postgres;

--
-- Name: get_seqdiagrampackage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagrampackage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramPackage'));
END
$$;


ALTER FUNCTION public.get_seqdiagrampackage() OWNER TO postgres;

--
-- Name: get_seqdiagramtable(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramtable() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTable'));
END
$$;


ALTER FUNCTION public.get_seqdiagramtable() OWNER TO postgres;

--
-- Name: get_seqdiagramtablecolonne(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramtablecolonne() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTableColonne'));
END
$$;


ALTER FUNCTION public.get_seqdiagramtablecolonne() OWNER TO postgres;

--
-- Name: get_seqexecution_script(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqexecution_script() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqEXECUTION_SCRIPT'));
END
$$;


ALTER FUNCTION public.get_seqexecution_script() OWNER TO postgres;

--
-- Name: get_seqexecution_scriptfille(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqexecution_scriptfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqEXECUTION_SCRIPTFILLE'));
END
$$;


ALTER FUNCTION public.get_seqexecution_scriptfille() OWNER TO postgres;

--
-- Name: get_seqexternal_work(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqexternal_work() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqexternal_work'));
END
$$;


ALTER FUNCTION public.get_seqexternal_work() OWNER TO postgres;

--
-- Name: get_seqfonctionnalite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqfonctionnalite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqfonctionnalite'));
END
$$;


ALTER FUNCTION public.get_seqfonctionnalite() OWNER TO postgres;

--
-- Name: get_seqpage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqpage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqpage'));
END
$$;


ALTER FUNCTION public.get_seqpage() OWNER TO postgres;

--
-- Name: get_seqparamcrypt(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqparamcrypt() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqparamcrypt'));
END
$$;


ALTER FUNCTION public.get_seqparamcrypt() OWNER TO postgres;

--
-- Name: get_seqpiecejointe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqpiecejointe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqpieceJointe'));
END
$$;


ALTER FUNCTION public.get_seqpiecejointe() OWNER TO postgres;

--
-- Name: get_seqprojet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqprojet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqprojet'));
END
$$;


ALTER FUNCTION public.get_seqprojet() OWNER TO postgres;

--
-- Name: get_seqscript_projet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqscript_projet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqscript_projet'));
END
$$;


ALTER FUNCTION public.get_seqscript_projet() OWNER TO postgres;

--
-- Name: get_seqtachemere(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqtachemere() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqtacheMere'));
END
$$;


ALTER FUNCTION public.get_seqtachemere() OWNER TO postgres;

--
-- Name: get_seqtachemere_detailsdefaut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqtachemere_detailsdefaut() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TAUXHONORAIRE'));
        END
    $$;


ALTER FUNCTION public.get_seqtachemere_detailsdefaut() OWNER TO postgres;

--
-- Name: get_seqtachemeredefaut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqtachemeredefaut() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TAUXHONORAIRE'));
        END
    $$;


ALTER FUNCTION public.get_seqtachemeredefaut() OWNER TO postgres;

--
-- Name: get_seqtimingsoustache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqtimingsoustache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_TIMINGSOUSTACHE'));
END
$$;


ALTER FUNCTION public.get_seqtimingsoustache() OWNER TO postgres;

--
-- Name: get_seqtypefichier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqtypefichier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqtypeFichier'));
END
$$;


ALTER FUNCTION public.get_seqtypefichier() OWNER TO postgres;

--
-- Name: get_seqwork_branche(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqwork_branche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqwork_branche'));
END
$$;


ALTER FUNCTION public.get_seqwork_branche() OWNER TO postgres;

--
-- Name: get_seqwork_type(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqwork_type() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqwork_type'));
END
$$;


ALTER FUNCTION public.get_seqwork_type() OWNER TO postgres;

--
-- Name: getattributclasse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getattributclasse() RETURNS integer
    LANGUAGE sql
    AS $$

SELECT nextval('seq_attributclasse')::integer;

$$;


ALTER FUNCTION public.getattributclasse() OWNER TO postgres;

--
-- Name: getcategorieniveau(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getcategorieniveau() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqcategorieniveau'));
END
$$;


ALTER FUNCTION public.getcategorieniveau() OWNER TO postgres;

--
-- Name: getheuresup(date, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.getheuresup(daty_ date, debut_ timestamp without time zone, fin_ timestamp without time zone) OWNER TO postgres;

--
-- Name: getheuretravailmax(date, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.getheuretravailmax(daty_ date, unite character varying) OWNER TO postgres;

--
-- Name: getseq_analyses(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_analyses() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN (SELECT nextval('seq_analyses'));

END;

$$;


ALTER FUNCTION public.getseq_analyses() OWNER TO postgres;

--
-- Name: getseq_apjclasse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_apjclasse() RETURNS integer
    LANGUAGE sql
    AS $$

SELECT nextval('seq_apjclasse')::integer;

$$;


ALTER FUNCTION public.getseq_apjclasse() OWNER TO postgres;

--
-- Name: getseq_attacher_fichier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_attacher_fichier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqattacher_fichier'));
END
$$;


ALTER FUNCTION public.getseq_attacher_fichier() OWNER TO postgres;

--
-- Name: getseq_attribusentite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_attribusentite() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_attribusentite')::integer;

$$;


ALTER FUNCTION public.getseq_attribusentite() OWNER TO postgres;

--
-- Name: getseq_attributoracle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_attributoracle() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_attributoracle')::integer;

$$;


ALTER FUNCTION public.getseq_attributoracle() OWNER TO postgres;

--
-- Name: getseq_attributpostgres(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_attributpostgres() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_attributpostgres')::integer;

$$;


ALTER FUNCTION public.getseq_attributpostgres() OWNER TO postgres;

--
-- Name: getseq_attributtype(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_attributtype() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_attributtype')::integer;

$$;


ALTER FUNCTION public.getseq_attributtype() OWNER TO postgres;

--
-- Name: getseq_cheminprojetuser(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_cheminprojetuser() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_cheminprojetuser')::integer;

$$;


ALTER FUNCTION public.getseq_cheminprojetuser() OWNER TO postgres;

--
-- Name: getseq_diagramaffichage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_diagramaffichage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramAffichage'));
END
$$;


ALTER FUNCTION public.getseq_diagramaffichage() OWNER TO postgres;

--
-- Name: getseq_diagramtable(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_diagramtable() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTable'));
END
$$;


ALTER FUNCTION public.getseq_diagramtable() OWNER TO postgres;

--
-- Name: getseq_diagramtablecolonne(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_diagramtablecolonne() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTableColonne'));
END
$$;


ALTER FUNCTION public.getseq_diagramtablecolonne() OWNER TO postgres;

--
-- Name: getseq_histoinsert(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.getseq_histoinsert() OWNER TO postgres;

--
-- Name: getseq_proposition(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_proposition() RETURNS integer
    LANGUAGE sql
    AS $$
SELECT nextval('seq_proposition')::integer;
$$;


ALTER FUNCTION public.getseq_proposition() OWNER TO postgres;

--
-- Name: getseq_relation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_relation() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_relation')::integer;

$$;


ALTER FUNCTION public.getseq_relation() OWNER TO postgres;

--
-- Name: getseq_serveur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_serveur() RETURNS integer
    LANGUAGE sql
    AS $$
     SELECT nextval('seq_serveur')::integer;
$$;


ALTER FUNCTION public.getseq_serveur() OWNER TO postgres;

--
-- Name: getseq_typeclasse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_typeclasse() RETURNS integer
    LANGUAGE sql
    AS $$

SELECT nextval('seq_typeclasse')::integer;

$$;


ALTER FUNCTION public.getseq_typeclasse() OWNER TO postgres;

--
-- Name: getseq_typedependancediagram(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_typedependancediagram() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typeDependanceDiagram'));
END
$$;


ALTER FUNCTION public.getseq_typedependancediagram() OWNER TO postgres;

--
-- Name: getseq_typedependanceobjet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_typedependanceobjet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typeDependanceObjet'));
END
$$;


ALTER FUNCTION public.getseq_typedependanceobjet() OWNER TO postgres;

--
-- Name: getseq_typeliaison(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_typeliaison() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_typeliaison')::integer;

$$;


ALTER FUNCTION public.getseq_typeliaison() OWNER TO postgres;

--
-- Name: getseq_typerelation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_typerelation() RETURNS integer
    LANGUAGE sql
    AS $$

    SELECT nextval('seq_typerelation')::integer;

$$;


ALTER FUNCTION public.getseq_typerelation() OWNER TO postgres;

--
-- Name: getseq_v_classeetfiche(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.getseq_v_classeetfiche() OWNER TO postgres;

--
-- Name: getseq_v_classetfiche(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_v_classetfiche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_v_ClassEtFiche'));
        END
    $$;


ALTER FUNCTION public.getseq_v_classetfiche() OWNER TO postgres;

--
-- Name: getseqaction(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqaction() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqaction'));
END
$$;


ALTER FUNCTION public.getseqaction() OWNER TO postgres;

--
-- Name: getseqactiontache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqactiontache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqactionTache'));
END
$$;


ALTER FUNCTION public.getseqactiontache() OWNER TO postgres;

--
-- Name: getseqarchitecture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqarchitecture() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqarchitecture'));
 END
 $$;


ALTER FUNCTION public.getseqarchitecture() OWNER TO postgres;

--
-- Name: getseqavoirfc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqavoirfc() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQAVOIRFC'));
END
$$;


ALTER FUNCTION public.getseqavoirfc() OWNER TO postgres;

--
-- Name: getseqavoirfcfille(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqavoirfcfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQAVOIRFCFILLE'));
END
$$;


ALTER FUNCTION public.getseqavoirfcfille() OWNER TO postgres;

--
-- Name: getseqbase(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqbase() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqbase'));
 END
 $$;


ALTER FUNCTION public.getseqbase() OWNER TO postgres;

--
-- Name: getseqbaserelation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqbaserelation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqbaserelation'));
 END
 $$;


ALTER FUNCTION public.getseqbaserelation() OWNER TO postgres;

--
-- Name: getseqbranche(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqbranche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_branche'));
		END
		$$;


ALTER FUNCTION public.getseqbranche() OWNER TO postgres;

--
-- Name: getseqcaisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQCAISSE'));
END
$$;


ALTER FUNCTION public.getseqcaisse() OWNER TO postgres;

--
-- Name: getseqcanevatache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcanevatache() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN nextval('seqCanevaTache');
END;
$$;


ALTER FUNCTION public.getseqcanevatache() OWNER TO postgres;

--
-- Name: getseqcateging(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcateging() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQCATEGING'));
END
$$;


ALTER FUNCTION public.getseqcateging() OWNER TO postgres;

--
-- Name: getseqcategorie(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcategorie() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('Seqcategorie'));
END;
$$;


ALTER FUNCTION public.getseqcategorie() OWNER TO postgres;

--
-- Name: getseqcategorieavoirfc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcategorieavoirfc() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQCATEGORIEAVOIRFC'));
END
$$;


ALTER FUNCTION public.getseqcategorieavoirfc() OWNER TO postgres;

--
-- Name: getseqcategoriecaisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcategoriecaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqcategoriecaisse'));
END
$$;


ALTER FUNCTION public.getseqcategoriecaisse() OWNER TO postgres;

--
-- Name: getseqclasse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqclasse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_classe'));
END
$$;


ALTER FUNCTION public.getseqclasse() OWNER TO postgres;

--
-- Name: getseqclient(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqclient() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqclient'));
END
$$;


ALTER FUNCTION public.getseqclient() OWNER TO postgres;

--
-- Name: getseqcomptaclassecompte(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptaclassecompte() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTACLASSECOMPTE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptaclassecompte() OWNER TO postgres;

--
-- Name: getseqcomptacompte(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptacompte() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTACOMPTE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptacompte() OWNER TO postgres;

--
-- Name: getseqcomptacomptebackup(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptacomptebackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTACOMPTEBACKUP'));
        END
    $$;


ALTER FUNCTION public.getseqcomptacomptebackup() OWNER TO postgres;

--
-- Name: getseqcomptaecriture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptaecriture() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAECRITURE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptaecriture() OWNER TO postgres;

--
-- Name: getseqcomptaecriturebackup(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptaecriturebackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAECRITUREBACKUP'));
        END
    $$;


ALTER FUNCTION public.getseqcomptaecriturebackup() OWNER TO postgres;

--
-- Name: getseqcomptaexercice(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptaexercice() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAEXERCICE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptaexercice() OWNER TO postgres;

--
-- Name: getseqcomptajournal(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptajournal() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAJOURNAL'));
        END
    $$;


ALTER FUNCTION public.getseqcomptajournal() OWNER TO postgres;

--
-- Name: getseqcomptajournalbackup(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptajournalbackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAJOURNALBACKUP'));
        END
    $$;


ALTER FUNCTION public.getseqcomptajournalbackup() OWNER TO postgres;

--
-- Name: getseqcomptalettrage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptalettrage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTALETTRAGE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptalettrage() OWNER TO postgres;

--
-- Name: getseqcomptaorigine(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptaorigine() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAORIGINE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptaorigine() OWNER TO postgres;

--
-- Name: getseqcomptasousecriture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptasousecriture() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTASOUSECRITURE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptasousecriture() OWNER TO postgres;

--
-- Name: getseqcomptasousecriturebackup(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptasousecriturebackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTASOUSECRITUREBACKUP'));
        END
    $$;


ALTER FUNCTION public.getseqcomptasousecriturebackup() OWNER TO postgres;

--
-- Name: getseqcomptatypecompte(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptatypecompte() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTATYPECOMPTE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptatypecompte() OWNER TO postgres;

--
-- Name: getseqconception_pm(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqconception_pm() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_Conception_PM'));
END
$$;


ALTER FUNCTION public.getseqconception_pm() OWNER TO postgres;

--
-- Name: getseqcote(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcote() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqCote'));
END;
$$;


ALTER FUNCTION public.getseqcote() OWNER TO postgres;

--
-- Name: getseqcrcontent(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcrcontent() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqCRContent')); END $$;


ALTER FUNCTION public.getseqcrcontent() OWNER TO postgres;

--
-- Name: getseqcrcontentfille(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcrcontentfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqCRContentFille')); END $$;


ALTER FUNCTION public.getseqcrcontentfille() OWNER TO postgres;

--
-- Name: getseqcreation_projet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcreation_projet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqCreation_projet'));
END;
$$;


ALTER FUNCTION public.getseqcreation_projet() OWNER TO postgres;

--
-- Name: getseqdeploiement(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqdeploiement() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_deploiement'));
		END
		$$;


ALTER FUNCTION public.getseqdeploiement() OWNER TO postgres;

--
-- Name: getseqdevise(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqdevise() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqdevise'));
END
$$;


ALTER FUNCTION public.getseqdevise() OWNER TO postgres;

--
-- Name: getseqentite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqentite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqentite'));
END
$$;


ALTER FUNCTION public.getseqentite() OWNER TO postgres;

--
-- Name: getseqequipe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqequipe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqequipe'));
END;
$$;


ALTER FUNCTION public.getseqequipe() OWNER TO postgres;

--
-- Name: getseqexecutions(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqexecutions() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN nextval('seqphase');  -- gets the next value from the sequence
END;
$$;


ALTER FUNCTION public.getseqexecutions() OWNER TO postgres;

--
-- Name: getseqfonctionnalite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqfonctionnalite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqfonctionnalite'));
END
$$;


ALTER FUNCTION public.getseqfonctionnalite() OWNER TO postgres;

--
-- Name: getseqfournisseur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqfournisseur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQFOURNISSEUR'));
END
$$;


ALTER FUNCTION public.getseqfournisseur() OWNER TO postgres;

--
-- Name: getseqhistoimport(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqhistoimport() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqhistoimport'));
END
    $$;


ALTER FUNCTION public.getseqhistoimport() OWNER TO postgres;

--
-- Name: getseqhistorique(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqhistorique() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('seqhistorique'));
END;
$$;


ALTER FUNCTION public.getseqhistorique() OWNER TO postgres;

--
-- Name: getseqhistoriqueactif(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqhistoriqueactif() RETURNS bigint
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN nextval('seqHistoriqueActif');

END;

$$;


ALTER FUNCTION public.getseqhistoriqueactif() OWNER TO postgres;

--
-- Name: getseqhistovaleur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqhistovaleur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('seqhistovaleur'));
END;
$$;


ALTER FUNCTION public.getseqhistovaleur() OWNER TO postgres;

--
-- Name: getseqingredients(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqingredients() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQINGREDIENTS'));
END
$$;


ALTER FUNCTION public.getseqingredients() OWNER TO postgres;

--
-- Name: getseqmagasin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmagasin() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQMAGASIN'));
END
$$;


ALTER FUNCTION public.getseqmagasin() OWNER TO postgres;

--
-- Name: getseqmailcc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmailcc() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqmailcc'));
 END
 $$;


ALTER FUNCTION public.getseqmailcc() OWNER TO postgres;

--
-- Name: getseqmailrapport(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmailrapport() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqMailRapport')); END $$;


ALTER FUNCTION public.getseqmailrapport() OWNER TO postgres;

--
-- Name: getseqmetier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmetier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqmetier'));
 END
 $$;


ALTER FUNCTION public.getseqmetier() OWNER TO postgres;

--
-- Name: getseqmetierfille(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmetierfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_MetierFille'));
END
$$;


ALTER FUNCTION public.getseqmetierfille() OWNER TO postgres;

--
-- Name: getseqmetierrelation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmetierrelation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqmetierrelation'));
 END
 $$;


ALTER FUNCTION public.getseqmetierrelation() OWNER TO postgres;

--
-- Name: getseqmodule(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmodule() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_module'));
        END
    $$;


ALTER FUNCTION public.getseqmodule() OWNER TO postgres;

--
-- Name: getseqmotifavoirfc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmotifavoirfc() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQMOTIFAVOIRFC'));
END
$$;


ALTER FUNCTION public.getseqmotifavoirfc() OWNER TO postgres;

--
-- Name: getseqmouvementcaisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmouvementcaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQMOUVEMENTCAISSE'));
END
$$;


ALTER FUNCTION public.getseqmouvementcaisse() OWNER TO postgres;

--
-- Name: getseqmvtcaisseprevision(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmvtcaisseprevision() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqmvtcaisseprevision'));
END
$$;


ALTER FUNCTION public.getseqmvtcaisseprevision() OWNER TO postgres;

--
-- Name: getseqniveau(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqniveau() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqniveau'));
END
$$;


ALTER FUNCTION public.getseqniveau() OWNER TO postgres;

--
-- Name: getseqnotificationaction(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqnotificationaction() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqnotificationAction'));
END
$$;


ALTER FUNCTION public.getseqnotificationaction() OWNER TO postgres;

--
-- Name: getseqordonnerpaiement(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqordonnerpaiement() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqordonnerpaiement'));
END
$$;


ALTER FUNCTION public.getseqordonnerpaiement() OWNER TO postgres;

--
-- Name: getseqpagerelation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpagerelation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqpagerelation'));
 END
 $$;


ALTER FUNCTION public.getseqpagerelation() OWNER TO postgres;

--
-- Name: getseqparamcrypt(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqparamcrypt() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqparamcrypt'));
END
$$;


ALTER FUNCTION public.getseqparamcrypt() OWNER TO postgres;

--
-- Name: getseqpoint(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpoint() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQPOINT'));
END
$$;


ALTER FUNCTION public.getseqpoint() OWNER TO postgres;

--
-- Name: getseqprevision(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqprevision() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQPREVISION'));
END
$$;


ALTER FUNCTION public.getseqprevision() OWNER TO postgres;

--
-- Name: getseqproequipe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqproequipe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqprojetequipe'));
END;
$$;


ALTER FUNCTION public.getseqproequipe() OWNER TO postgres;

--
-- Name: getseqpromesse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpromesse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqpromesse'));
END
$$;


ALTER FUNCTION public.getseqpromesse() OWNER TO postgres;

--
-- Name: getseqrepartition(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqrepartition() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqrep'));
END
$$;


ALTER FUNCTION public.getseqrepartition() OWNER TO postgres;

--
-- Name: getseqrepartitiondet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqrepartitiondet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqrepd'));
END
$$;


ALTER FUNCTION public.getseqrepartitiondet() OWNER TO postgres;

--
-- Name: getseqreportcaisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqreportcaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqreportcaisse'));
END
$$;


ALTER FUNCTION public.getseqreportcaisse() OWNER TO postgres;

--
-- Name: getseqrequeteaenvoyer(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqrequeteaenvoyer() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_REQUETEAENVOYER'));
        END
    $$;


ALTER FUNCTION public.getseqrequeteaenvoyer() OWNER TO postgres;

--
-- Name: getseqsource(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqsource() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqsource'));
END
$$;


ALTER FUNCTION public.getseqsource() OWNER TO postgres;

--
-- Name: getseqtache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqTache'));
END;
$$;


ALTER FUNCTION public.getseqtache() OWNER TO postgres;

--
-- Name: getseqtauxavancementmodule(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtauxavancementmodule() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seqTauxAvancementModule'));

END

    $$;


ALTER FUNCTION public.getseqtauxavancementmodule() OWNER TO postgres;

--
-- Name: getseqtauxavancementprojet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtauxavancementprojet() RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN (SELECT nextval('seqTauxAvancementProjet'));

END

    $$;


ALTER FUNCTION public.getseqtauxavancementprojet() OWNER TO postgres;

--
-- Name: getseqtauxdechange(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtauxdechange() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqtauxdechange'));
END
$$;


ALTER FUNCTION public.getseqtauxdechange() OWNER TO postgres;

--
-- Name: getseqtype(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtype() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqType'));
END;
$$;


ALTER FUNCTION public.getseqtype() OWNER TO postgres;

--
-- Name: getseqtypeabsence(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypeabsence() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqtypeabsence'));
END
$$;


ALTER FUNCTION public.getseqtypeabsence() OWNER TO postgres;

--
-- Name: getseqtypeaction(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypeaction() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqtypeaction'));
END
$$;


ALTER FUNCTION public.getseqtypeaction() OWNER TO postgres;

--
-- Name: getseqtypeactionmetier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypeactionmetier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typeactionmetier'));
END
$$;


ALTER FUNCTION public.getseqtypeactionmetier() OWNER TO postgres;

--
-- Name: getseqtypebase(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypebase() RETURNS integer
    LANGUAGE plpgsql
    AS $$    

BEGIN

RETURN (SELECT nextval('seqtypebase'));	

END

$$;


ALTER FUNCTION public.getseqtypebase() OWNER TO postgres;

--
-- Name: getseqtypecaisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypecaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQTYPECAISSE'));
END
$$;


ALTER FUNCTION public.getseqtypecaisse() OWNER TO postgres;

--
-- Name: getseqtypemetier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypemetier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqtypemetier'));
 END
 $$;


ALTER FUNCTION public.getseqtypemetier() OWNER TO postgres;

--
-- Name: getseqtypepage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypepage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqtypepage'));
 END
 $$;


ALTER FUNCTION public.getseqtypepage() OWNER TO postgres;

--
-- Name: getseqtyperepos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtyperepos() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqtyperepos'));
END
$$;


ALTER FUNCTION public.getseqtyperepos() OWNER TO postgres;

--
-- Name: getseqtypetache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypetache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_typetache'));
        END
    $$;


ALTER FUNCTION public.getseqtypetache() OWNER TO postgres;

--
-- Name: getsequdonation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequdonation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seqdonation'));
        END
    $$;


ALTER FUNCTION public.getsequdonation() OWNER TO postgres;

--
-- Name: getsequnite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequnite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQUNITE'));
END
$$;


ALTER FUNCTION public.getsequnite() OWNER TO postgres;

--
-- Name: getsequserequipe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequserequipe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('sequserequipe'));
END;
$$;


ALTER FUNCTION public.getsequserequipe() OWNER TO postgres;

--
-- Name: getsequtilisateur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequtilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('sequtilisateur'));
END;
$$;


ALTER FUNCTION public.getsequtilisateur() OWNER TO postgres;

--
-- Name: getseqvente(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqvente() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQVENTE'));
END
$$;


ALTER FUNCTION public.getseqvente() OWNER TO postgres;

--
-- Name: getseqventedetails(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqventedetails() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQVENTEDETAILS'));
END
$$;


ALTER FUNCTION public.getseqventedetails() OWNER TO postgres;

--
-- Name: gettypeattributclasse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gettypeattributclasse() RETURNS integer
    LANGUAGE sql
    AS $$

SELECT nextval('seq_typeattributclasse')::integer;

$$;


ALTER FUNCTION public.gettypeattributclasse() OWNER TO postgres;

--
-- Name: gettypefournisseur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gettypefournisseur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQTYPEFOURNISSEUR'));
END
$$;


ALTER FUNCTION public.gettypefournisseur() OWNER TO postgres;

--
-- Name: isferie(date); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.isferie(daty_ date) OWNER TO postgres;

--
-- Name: isferieweekend(date); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.isferieweekend(daty_ date) OWNER TO postgres;

--
-- Name: isjourferie(date); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.isjourferie(daty_ date) OWNER TO postgres;

--
-- Name: make_identite_devis(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.make_identite_devis(p_iddevis character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_annee        TEXT;
    v_numero       TEXT;
    v_categorie    TEXT;
    v_client       TEXT;
    v_localisation TEXT;
    v_result       TEXT;
BEGIN
    SELECT
        TO_CHAR(d.daty, 'YYYY'),
        d.iddevis,
        cat.val,
        cl.nom,
        cp.localisation
    INTO
        v_annee,
        v_numero,
        v_categorie,
        v_client,
        v_localisation
    FROM devis d
             JOIN creation_projet cp ON d.idcreationprojet = cp.id
             LEFT JOIN categorie cat ON cp.categorie = cat.id
             LEFT JOIN client cl ON cp.client = cl.id
    WHERE d.iddevis = p_idDevis;

    v_result :=
            COALESCE(v_annee, '???') || '_' ||
            COALESCE(v_numero, '???') || '_' ||
            COALESCE(v_categorie, '???') || '_' ||
            COALESCE(v_client, '???') || '_' ||
            COALESCE(v_localisation, '???') || '_Devis';

    RETURN v_result;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Aucune donnée pour ce devis';
    WHEN OTHERS THEN
        RETURN 'Erreur: ' || SQLERRM;
END;
$$;


ALTER FUNCTION public.make_identite_devis(p_iddevis character varying) OWNER TO postgres;

--
-- Name: make_identite_projet(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.make_identite_projet(p_idcreationprojet character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
v_annee        TEXT;
    v_numero       TEXT;
    v_categorie    TEXT;
    v_client       TEXT;
    v_localisation TEXT;
    v_result       TEXT;
BEGIN
SELECT
    TO_CHAR(cp.debut, 'YYYY'),
    cp.id,
    cat.val,
    cl.nom,
    cp.localisation
INTO
    v_annee,
    v_numero,
    v_categorie,
    v_client,
    v_localisation
FROM
    creation_projet cp
        LEFT JOIN categorie cat ON cp.categorie = cat.id
        LEFT JOIN client cl ON cp.client = cl.id
WHERE cp.id = p_idCreationProjet;

v_result :=
            COALESCE(v_annee, '???') || '_' ||
            COALESCE(v_numero, '???') || '_' ||
            COALESCE(v_categorie, '???') || '_' ||
            COALESCE(v_client, '???') || '_' ||
            COALESCE(v_localisation, '???');

RETURN v_result;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Aucune donnée pour ce devis';
WHEN OTHERS THEN
        RETURN 'Erreur: ' || SQLERRM;
END;
$$;


ALTER FUNCTION public.make_identite_projet(p_idcreationprojet character varying) OWNER TO postgres;

--
-- Name: metierdependance(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.metierdependance(idmetier character varying, rep character varying) OWNER TO postgres;

--
-- Name: metierdependancecomplet(character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.metierdependancecomplet(idmetier character varying) OWNER TO postgres;

--
-- Name: metierdependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.metierdependante(idmetier character varying, rep character varying) OWNER TO postgres;

--
-- Name: metierdependantecomplet(character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.metierdependantecomplet(idmetier character varying) OWNER TO postgres;

--
-- Name: metierfille(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.metierfille(idmetier character varying, rep character varying) OWNER TO postgres;

--
-- Name: metiermere(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.metiermere(idmetier character varying, rep character varying) OWNER TO postgres;

--
-- Name: nombreutilisateur(character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.nombreutilisateur(role character varying) OWNER TO postgres;

--
-- Name: pagedependance(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.pagedependance(idpage character varying, rep character varying) OWNER TO postgres;

--
-- Name: pagedependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.pagedependante(idpage character varying, rep character varying) OWNER TO postgres;

--
-- Name: propositionestimation(character varying, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.propositionestimation(cote_ character varying, type_ character varying, niveau_ integer, responsable_ character varying) OWNER TO postgres;

--
-- Name: propositionestimation(character varying, character varying, integer, character varying, date, date); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.propositionestimation(cote_ character varying, type_ character varying, niveau_ integer, responsable_ character varying, datymin date, datymax date) OWNER TO postgres;

--
-- Name: set_idattribut_self(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.set_idattribut_self() OWNER TO postgres;

--
-- Name: set_idliaison_relation(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.set_idliaison_relation() OWNER TO postgres;

--
-- Name: set_idmere_self(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.set_idmere_self() OWNER TO postgres;

--
-- Name: tachedependance(character varying); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.tachedependance(idtache_ character varying) OWNER TO postgres;

--
-- Name: v_allocation_charges_all(date, date); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.v_allocation_charges_all(date_debut date, date_fin date) OWNER TO postgres;

--
-- Name: v_phase_projets(date, date); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.v_phase_projets(date_debut date, date_fin date) OWNER TO postgres;

--
-- Name: crdateformu; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.crdateformu AS
 SELECT ('now'::text)::date AS daty;


ALTER VIEW public.crdateformu OWNER TO postgres;

--
-- Name: decalageprevision; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.decalageprevision AS
 SELECT ''::text AS id,
    ''::text AS idprevision,
    ''::text AS iddevise,
    (0)::numeric(30,2) AS debit,
    (0)::numeric(30,2) AS credit,
    NULL::date AS datynouveau;


ALTER VIEW public.decalageprevision OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: direction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.direction (
    id character varying(50) NOT NULL,
    val character varying(100),
    desce character varying(200)
);


ALTER TABLE public.direction OWNER TO postgres;

--
-- Name: generate_series; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.generate_series AS
 SELECT NULL::character varying AS id,
    NULL::character varying AS val,
    NULL::character varying AS desce,
    NULL::double precision AS max,
    NULL::integer AS droppable;


ALTER VIEW public.generate_series OWNER TO postgres;

--
-- Name: histoinsert; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.histoinsert OWNER TO postgres;

--
-- Name: historique; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.historique OWNER TO postgres;

--
-- Name: menudynamique; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.menudynamique OWNER TO postgres;

--
-- Name: menu_fils; Type: VIEW; Schema: public; Owner: postgres
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


ALTER VIEW public.menu_fils OWNER TO postgres;

--
-- Name: menudynamiquelib; Type: VIEW; Schema: public; Owner: postgres
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


ALTER VIEW public.menudynamiquelib OWNER TO postgres;

--
-- Name: paramcrypt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paramcrypt (
    id character varying(100) NOT NULL,
    niveau integer,
    croissante integer,
    idutilisateur character varying(100)
);


ALTER TABLE public.paramcrypt OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    idrole character varying NOT NULL,
    descrole character varying,
    rang integer
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: seq_absence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_absence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_absence OWNER TO postgres;

--
-- Name: seq_actionprojet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_actionprojet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_actionprojet OWNER TO postgres;

--
-- Name: seq_alert; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_alert
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_alert OWNER TO postgres;

--
-- Name: seq_analyses; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_analyses
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_analyses OWNER TO postgres;

--
-- Name: seq_apjclasse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_apjclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_apjclasse OWNER TO postgres;

--
-- Name: seq_attribusentite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_attribusentite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_attribusentite OWNER TO postgres;

--
-- Name: seq_attributclasse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_attributclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_attributclasse OWNER TO postgres;

--
-- Name: seq_attributoracle; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_attributoracle
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_attributoracle OWNER TO postgres;

--
-- Name: seq_attributpostgres; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_attributpostgres
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_attributpostgres OWNER TO postgres;

--
-- Name: seq_attributtype; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_attributtype
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_attributtype OWNER TO postgres;

--
-- Name: seq_boutonchamp; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_boutonchamp
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_boutonchamp OWNER TO postgres;

--
-- Name: seq_boutonpage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_boutonpage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_boutonpage OWNER TO postgres;

--
-- Name: seq_branche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_branche
    START WITH 10
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_branche OWNER TO postgres;

--
-- Name: seq_caisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_caisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_caisse OWNER TO postgres;

--
-- Name: seq_champdynamique; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_champdynamique
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_champdynamique OWNER TO postgres;

--
-- Name: seq_champsspeciaux; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_champsspeciaux
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_champsspeciaux OWNER TO postgres;

--
-- Name: seq_cheminprojetuser; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_cheminprojetuser
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_cheminprojetuser OWNER TO postgres;

--
-- Name: seq_classe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_classe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_classe OWNER TO postgres;

--
-- Name: seq_comptaclassecompte; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptaclassecompte
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptaclassecompte OWNER TO postgres;

--
-- Name: seq_comptacompte; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptacompte
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptacompte OWNER TO postgres;

--
-- Name: seq_comptacomptebackup; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptacomptebackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptacomptebackup OWNER TO postgres;

--
-- Name: seq_comptaecriture; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptaecriture
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptaecriture OWNER TO postgres;

--
-- Name: seq_comptaecriturebackup; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptaecriturebackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptaecriturebackup OWNER TO postgres;

--
-- Name: seq_comptaexercice; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptaexercice
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptaexercice OWNER TO postgres;

--
-- Name: seq_comptajournal; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptajournal
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptajournal OWNER TO postgres;

--
-- Name: seq_comptajournalbackup; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptajournalbackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptajournalbackup OWNER TO postgres;

--
-- Name: seq_comptalettrage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptalettrage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptalettrage OWNER TO postgres;

--
-- Name: seq_comptaorigine; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptaorigine
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptaorigine OWNER TO postgres;

--
-- Name: seq_comptasousecriture; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptasousecriture
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptasousecriture OWNER TO postgres;

--
-- Name: seq_comptasousecriturebackup; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptasousecriturebackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptasousecriturebackup OWNER TO postgres;

--
-- Name: seq_comptatypecompte; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptatypecompte
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptatypecompte OWNER TO postgres;

--
-- Name: seq_conception_pm; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_conception_pm
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_conception_pm OWNER TO postgres;

--
-- Name: seq_connexion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_connexion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_connexion OWNER TO postgres;

--
-- Name: seq_coutprevisionnel; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_coutprevisionnel
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_coutprevisionnel OWNER TO postgres;

--
-- Name: seq_deploiement; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_deploiement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_deploiement OWNER TO postgres;

--
-- Name: seq_devis; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_devis
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_devis OWNER TO postgres;

--
-- Name: seq_devisfille; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_devisfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_devisfille OWNER TO postgres;

--
-- Name: seq_diagramaffichage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramaffichage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramaffichage OWNER TO postgres;

--
-- Name: seq_diagramclass; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramclass
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramclass OWNER TO postgres;

--
-- Name: seq_diagramclasscomposant; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramclasscomposant
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramclasscomposant OWNER TO postgres;

--
-- Name: seq_diagramclasscomposanttype; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramclasscomposanttype
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramclasscomposanttype OWNER TO postgres;

--
-- Name: seq_diagramclasspackage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramclasspackage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramclasspackage OWNER TO postgres;

--
-- Name: seq_diagramcomposant; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramcomposant
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramcomposant OWNER TO postgres;

--
-- Name: seq_diagrampackage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagrampackage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagrampackage OWNER TO postgres;

--
-- Name: seq_diagramtable; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramtable
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramtable OWNER TO postgres;

--
-- Name: seq_diagramtablecolonne; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramtablecolonne
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramtablecolonne OWNER TO postgres;

--
-- Name: seq_donation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_donation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER SEQUENCE public.seq_donation OWNER TO postgres;

--
-- Name: seq_entitescript; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_entitescript
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_entitescript OWNER TO postgres;

--
-- Name: seq_exceptiontache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_exceptiontache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_exceptiontache OWNER TO postgres;

--
-- Name: seq_histoinsert; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_histoinsert
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_histoinsert OWNER TO postgres;

--
-- Name: seq_honoraire; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_honoraire
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_honoraire OWNER TO postgres;

--
-- Name: seq_indisponibilite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_indisponibilite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_indisponibilite OWNER TO postgres;

--
-- Name: seq_jourrepos; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_jourrepos
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_jourrepos OWNER TO postgres;

--
-- Name: seq_magasin2; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_magasin2
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_magasin2 OWNER TO postgres;

--
-- Name: seq_mappingtypeattribut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_mappingtypeattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_mappingtypeattribut OWNER TO postgres;

--
-- Name: seq_metierfille; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_metierfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_metierfille OWNER TO postgres;

--
-- Name: seq_module; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_module
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_module OWNER TO postgres;

--
-- Name: seq_module_projet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_module_projet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_module_projet OWNER TO postgres;

--
-- Name: seq_niveauclient; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_niveauclient
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_niveauclient OWNER TO postgres;

--
-- Name: seq_notification; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_notification
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_notification OWNER TO postgres;

--
-- Name: seq_notificationdetails; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_notificationdetails
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_notificationdetails OWNER TO postgres;

--
-- Name: seq_notificationgroupe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_notificationgroupe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_notificationgroupe OWNER TO postgres;

--
-- Name: seq_notificationsignal; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_notificationsignal
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_notificationsignal OWNER TO postgres;

--
-- Name: seq_pageanalyse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pageanalyse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pageanalyse OWNER TO postgres;

--
-- Name: seq_pageanalyseattribut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pageanalyseattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pageanalyseattribut OWNER TO postgres;

--
-- Name: seq_pageattribut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pageattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pageattribut OWNER TO postgres;

--
-- Name: seq_pagefiche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pagefiche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pagefiche OWNER TO postgres;

--
-- Name: seq_pageficheattribut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pageficheattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pageficheattribut OWNER TO postgres;

--
-- Name: seq_pageliste; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pageliste
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pageliste OWNER TO postgres;

--
-- Name: seq_pagelisteattribut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pagelisteattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pagelisteattribut OWNER TO postgres;

--
-- Name: seq_pagesaisie; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pagesaisie
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pagesaisie OWNER TO postgres;

--
-- Name: seq_panalysechampfiltre; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_panalysechampfiltre
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_panalysechampfiltre OWNER TO postgres;

--
-- Name: seq_pays; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pays
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_pays OWNER TO postgres;

--
-- Name: seq_phaseproject; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_phaseproject
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_phaseproject OWNER TO postgres;

--
-- Name: seq_plistchampfiltre; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_plistchampfiltre
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_plistchampfiltre OWNER TO postgres;

--
-- Name: seq_pointage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pointage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_pointage OWNER TO postgres;

--
-- Name: seq_projetutilisateur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_projetutilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_projetutilisateur OWNER TO postgres;

--
-- Name: seq_proposition; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_proposition
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_proposition OWNER TO postgres;

--
-- Name: seq_province; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_province
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_province OWNER TO postgres;

--
-- Name: seq_qualite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_qualite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_qualite OWNER TO postgres;

--
-- Name: seq_relation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_relation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_relation OWNER TO postgres;

--
-- Name: seq_requeteaenvoyer; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_requeteaenvoyer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_requeteaenvoyer OWNER TO postgres;

--
-- Name: seq_script; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_script
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_script OWNER TO postgres;

--
-- Name: seq_scriptversionning; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_scriptversionning
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_scriptversionning OWNER TO postgres;

--
-- Name: seq_serveur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_serveur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_serveur OWNER TO postgres;

--
-- Name: seq_tache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_tache
    START WITH 182
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_tache OWNER TO postgres;

--
-- Name: seq_tache_git_details; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_tache_git_details
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_tache_git_details OWNER TO postgres;

--
-- Name: seq_tache_git_mere; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_tache_git_mere
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_tache_git_mere OWNER TO postgres;

--
-- Name: seq_tauxhonoraire; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_tauxhonoraire
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_tauxhonoraire OWNER TO postgres;

--
-- Name: seq_tempstravail; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_tempstravail
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_tempstravail OWNER TO postgres;

--
-- Name: seq_timingapplication; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_timingapplication
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_timingapplication OWNER TO postgres;

--
-- Name: seq_timingsoustache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_timingsoustache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_timingsoustache OWNER TO postgres;

--
-- Name: seq_type_utilisateur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_type_utilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_type_utilisateur OWNER TO postgres;

--
-- Name: seq_typeactionmetier; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeactionmetier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_typeactionmetier OWNER TO postgres;

--
-- Name: seq_typeattributclasse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeattributclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_typeattributclasse OWNER TO postgres;

--
-- Name: seq_typechampsspeciaux; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typechampsspeciaux
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typechampsspeciaux OWNER TO postgres;

--
-- Name: seq_typeclasse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_typeclasse OWNER TO postgres;

--
-- Name: seq_typedependancediagram; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typedependancediagram
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typedependancediagram OWNER TO postgres;

--
-- Name: seq_typedependanceobjet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typedependanceobjet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typedependanceobjet OWNER TO postgres;

--
-- Name: seq_typeliaison; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeliaison
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_typeliaison OWNER TO postgres;

--
-- Name: seq_typemagasin; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typemagasin
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_typemagasin OWNER TO postgres;

--
-- Name: seq_typeouinon; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeouinon
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typeouinon OWNER TO postgres;

--
-- Name: seq_typepageanalyse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typepageanalyse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typepageanalyse OWNER TO postgres;

--
-- Name: seq_typepageliste; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typepageliste
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typepageliste OWNER TO postgres;

--
-- Name: seq_typepagesaisie; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typepagesaisie
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typepagesaisie OWNER TO postgres;

--
-- Name: seq_typeplistchampfiltre; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeplistchampfiltre
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typeplistchampfiltre OWNER TO postgres;

--
-- Name: seq_typerelation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typerelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_typerelation OWNER TO postgres;

--
-- Name: seq_typescript; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typescript
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_typescript OWNER TO postgres;

--
-- Name: seq_typetache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typetache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_typetache OWNER TO postgres;

--
-- Name: seq_v_classeetfiche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_v_classeetfiche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_v_classeetfiche OWNER TO postgres;

--
-- Name: seq_v_classetfiche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_v_classetfiche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_v_classetfiche OWNER TO postgres;

--
-- Name: seqaction; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqaction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqaction OWNER TO postgres;

--
-- Name: seqactiontache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqactiontache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqactiontache OWNER TO postgres;

--
-- Name: seqarchitecture; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqarchitecture
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqarchitecture OWNER TO postgres;

--
-- Name: seqattacher_fichier; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqattacher_fichier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqattacher_fichier OWNER TO postgres;

--
-- Name: seqavoirfc; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqavoirfc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqavoirfc OWNER TO postgres;

--
-- Name: seqavoirfcfille; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqavoirfcfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqavoirfcfille OWNER TO postgres;

--
-- Name: seqbase; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqbase
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqbase OWNER TO postgres;

--
-- Name: seqbaserelation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqbaserelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqbaserelation OWNER TO postgres;

--
-- Name: seqbranche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqbranche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqbranche OWNER TO postgres;

--
-- Name: seqcaisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqcaisse OWNER TO postgres;

--
-- Name: seqcanevatache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcanevatache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqcanevatache OWNER TO postgres;

--
-- Name: seqcateging; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcateging
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqcateging OWNER TO postgres;

--
-- Name: seqcategorie; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcategorie
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqcategorie OWNER TO postgres;

--
-- Name: seqcategorieavoirfc; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcategorieavoirfc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqcategorieavoirfc OWNER TO postgres;

--
-- Name: seqcategoriecaisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcategoriecaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqcategoriecaisse OWNER TO postgres;

--
-- Name: seqcategorieniveau; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcategorieniveau
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqcategorieniveau OWNER TO postgres;

--
-- Name: seqclient; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqclient
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqclient OWNER TO postgres;

--
-- Name: seqcote; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcote
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqcote OWNER TO postgres;

--
-- Name: seqcrcontent; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcrcontent
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqcrcontent OWNER TO postgres;

--
-- Name: seqcrcontentfille; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcrcontentfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqcrcontentfille OWNER TO postgres;

--
-- Name: seqcreation_projet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcreation_projet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqcreation_projet OWNER TO postgres;

--
-- Name: seqdevise; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqdevise
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqdevise OWNER TO postgres;

--
-- Name: seqdonation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqdonation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqdonation OWNER TO postgres;

--
-- Name: seqentite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqentite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqentite OWNER TO postgres;

--
-- Name: seqequipe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqequipe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqequipe OWNER TO postgres;

--
-- Name: seqexecution_script; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqexecution_script
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqexecution_script OWNER TO postgres;

--
-- Name: seqexecution_scriptfille; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqexecution_scriptfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqexecution_scriptfille OWNER TO postgres;

--
-- Name: seqexecutions; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqexecutions
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqexecutions OWNER TO postgres;

--
-- Name: seqexternal_work; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqexternal_work
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqexternal_work OWNER TO postgres;

--
-- Name: seqfonctionnalite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqfonctionnalite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqfonctionnalite OWNER TO postgres;

--
-- Name: seqfournisseur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqfournisseur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqfournisseur OWNER TO postgres;

--
-- Name: seqhistoimport; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqhistoimport
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqhistoimport OWNER TO postgres;

--
-- Name: seqhistorique; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqhistorique
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqhistorique OWNER TO postgres;

--
-- Name: seqhistoriqueactif; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqhistoriqueactif
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqhistoriqueactif OWNER TO postgres;

--
-- Name: seqhistovaleur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqhistovaleur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqhistovaleur OWNER TO postgres;

--
-- Name: seqingredients; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqingredients
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqingredients OWNER TO postgres;

--
-- Name: seqmagasin; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmagasin
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqmagasin OWNER TO postgres;

--
-- Name: seqmailcc; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmailcc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqmailcc OWNER TO postgres;

--
-- Name: seqmailrapport; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmailrapport
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqmailrapport OWNER TO postgres;

--
-- Name: seqmetier; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmetier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqmetier OWNER TO postgres;

--
-- Name: seqmetierrelation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmetierrelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqmetierrelation OWNER TO postgres;

--
-- Name: seqmotifavoirfc; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmotifavoirfc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqmotifavoirfc OWNER TO postgres;

--
-- Name: seqmouvementcaisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmouvementcaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqmouvementcaisse OWNER TO postgres;

--
-- Name: seqmvtcaisseprevision; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmvtcaisseprevision
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqmvtcaisseprevision OWNER TO postgres;

--
-- Name: seqniveau; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqniveau
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqniveau OWNER TO postgres;

--
-- Name: seqnotificationaction; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqnotificationaction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqnotificationaction OWNER TO postgres;

--
-- Name: seqordonnerpaiement; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqordonnerpaiement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqordonnerpaiement OWNER TO postgres;

--
-- Name: seqpage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqpage OWNER TO postgres;

--
-- Name: seqpagerelation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpagerelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqpagerelation OWNER TO postgres;

--
-- Name: seqparamcrypt; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqparamcrypt
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqparamcrypt OWNER TO postgres;

--
-- Name: seqphase; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqphase
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqphase OWNER TO postgres;

--
-- Name: seqpiecejointe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpiecejointe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqpiecejointe OWNER TO postgres;

--
-- Name: seqpoint; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpoint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqpoint OWNER TO postgres;

--
-- Name: seqprevision; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqprevision
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqprevision OWNER TO postgres;

--
-- Name: seqprojet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqprojet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqprojet OWNER TO postgres;

--
-- Name: seqprojetequipe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqprojetequipe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqprojetequipe OWNER TO postgres;

--
-- Name: seqpromesse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpromesse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqpromesse OWNER TO postgres;

--
-- Name: seqrep; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqrep
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 1;


ALTER SEQUENCE public.seqrep OWNER TO postgres;

--
-- Name: seqrepd; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqrepd
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 1;


ALTER SEQUENCE public.seqrepd OWNER TO postgres;

--
-- Name: seqreportcaisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqreportcaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqreportcaisse OWNER TO postgres;

--
-- Name: seqrequeteaenvoyer; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqrequeteaenvoyer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqrequeteaenvoyer OWNER TO postgres;

--
-- Name: seqscript_projet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqscript_projet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqscript_projet OWNER TO postgres;

--
-- Name: seqsource; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqsource
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqsource OWNER TO postgres;

--
-- Name: seqtache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtache OWNER TO postgres;

--
-- Name: seqtachemere; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtachemere
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtachemere OWNER TO postgres;

--
-- Name: seqtachemere_detailsdefaut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtachemere_detailsdefaut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtachemere_detailsdefaut OWNER TO postgres;

--
-- Name: seqtachemeredefaut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtachemeredefaut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtachemeredefaut OWNER TO postgres;

--
-- Name: seqtauxavancementmodule; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtauxavancementmodule
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtauxavancementmodule OWNER TO postgres;

--
-- Name: seqtauxavancementprojet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtauxavancementprojet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtauxavancementprojet OWNER TO postgres;

--
-- Name: seqtauxdechange; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtauxdechange
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtauxdechange OWNER TO postgres;

--
-- Name: seqtype; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtype
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtype OWNER TO postgres;

--
-- Name: seqtypeabsence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypeabsence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypeabsence OWNER TO postgres;

--
-- Name: seqtypeaction; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypeaction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypeaction OWNER TO postgres;

--
-- Name: seqtypebase; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypebase
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypebase OWNER TO postgres;

--
-- Name: seqtypecaisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypecaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqtypecaisse OWNER TO postgres;

--
-- Name: seqtypefichier; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypefichier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypefichier OWNER TO postgres;

--
-- Name: seqtypefournisseur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypefournisseur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqtypefournisseur OWNER TO postgres;

--
-- Name: seqtypemetier; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypemetier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypemetier OWNER TO postgres;

--
-- Name: seqtypepage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypepage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypepage OWNER TO postgres;

--
-- Name: seqtyperepos; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtyperepos
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtyperepos OWNER TO postgres;

--
-- Name: sequnite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sequnite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sequnite OWNER TO postgres;

--
-- Name: sequserequipe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sequserequipe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.sequserequipe OWNER TO postgres;

--
-- Name: sequtilisateur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sequtilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.sequtilisateur OWNER TO postgres;

--
-- Name: seqvente; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqvente
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqvente OWNER TO postgres;

--
-- Name: seqventedetails; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqventedetails
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqventedetails OWNER TO postgres;

--
-- Name: seqwork_branche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqwork_branche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqwork_branche OWNER TO postgres;

--
-- Name: seqwork_type; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqwork_type
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqwork_type OWNER TO postgres;

--
-- Name: touslesdate; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.touslesdate AS
 SELECT generate_series((to_date('2000-01-01'::text, 'YYYY-MM-DD'::text))::timestamp with time zone, (to_date('2030-12-31'::text, 'YYYY-MM-DD'::text))::timestamp with time zone, '1 day'::interval) AS daty;


ALTER VIEW public.touslesdate OWNER TO postgres;

--
-- Name: usermenu; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.usermenu OWNER TO postgres;

--
-- Name: utilisateur; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.utilisateur OWNER TO postgres;

--
-- Name: utilisateuracade_vue; Type: VIEW; Schema: public; Owner: postgres
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


ALTER VIEW public.utilisateuracade_vue OWNER TO postgres;

--
-- Name: utilisateurvalide; Type: VIEW; Schema: public; Owner: postgres
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


ALTER VIEW public.utilisateurvalide OWNER TO postgres;

--
-- Name: utilisateurvue; Type: VIEW; Schema: public; Owner: postgres
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


ALTER VIEW public.utilisateurvue OWNER TO postgres;

--
-- Name: utilisateurvue_roles; Type: VIEW; Schema: public; Owner: postgres
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


ALTER VIEW public.utilisateurvue_roles OWNER TO postgres;

--
-- Data for Name: direction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.direction (id, val, desce) FROM stdin;
DIR42	opus	opus
\.


--
-- Data for Name: histoinsert; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.histoinsert (idhistorique, datehistorique, heure, objet, action, idutilisateur, refobjet, remarque) FROM stdin;
\.


--
-- Data for Name: historique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historique (idhistorique, datehistorique, heure, objet, action, idutilisateur, refobjet) FROM stdin;
EX0002872501	2026-02-22	18:53:55:124	mg.cnaps.utilisateur.CNAPSUser	login	1	1
\.


--
-- Data for Name: menudynamique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.menudynamique (id, libelle, icone, href, rang, niveau, id_pere) FROM stdin;
MEN0079	Saisie	add	module.jsp?but=donation/donation-saisie.jsp	1	2	MEN0019
MEN0019	Donation	person	#	1	1	\N
MEN0082	Import	add	module.jsp?but=donation/donation-import.jsp	5	2	MEN0019
MEN0080	Liste des dons en argent	list_alt	module.jsp?but=donation/donation-liste.jsp	2	2	MEN0019
MEN0081	Analyse	list_alt	module.jsp?but=donation/donation-analyse.jsp	4	2	MEN0019
MEN0083	Liste des dons matériels	list_alt	module.jsp?but=donation/donation-liste-tous.jsp	3	2	MEN0019
MEN0084	Import opérateur	add	module.jsp?but=donation/donation-import-operateur.jsp	6	2	MEN0019
MENDYN1771406514762419	Situation des dons matériels	visibility	module.jsp?but=donation/donation-reste.jsp	7	2	MEN0019
MENDYN1771406542221630	R&eacute;partition	link		4	1	\N
MENDYN1771406568052608	Saisie	add	module.jsp?but=repartition/repartition-saisie.jsp	1	2	MENDYN1771406542221630
MENDYN1771406598671705	Liste	notes	module.jsp?but=repartition/repartition-liste.jsp	2	2	MENDYN1771406542221630
MEN0085	Promesse	person	#	2	1	\N
MEN00851	Saisie	add	module.jsp?but=promesse/promesse-saisie.jsp	1	2	MEN0085
MEN00852	Liste	list_alt	module.jsp?but=promesse/promesse-liste.jsp	2	2	MEN0085
\.


--
-- Data for Name: paramcrypt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.paramcrypt (id, niveau, croissante, idutilisateur) FROM stdin;
CRY000088	4	1	1
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (idrole, descrole, rang) FROM stdin;
md	Moderateur	10
etu	Etudiant	3
\.


--
-- Data for Name: usermenu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) FROM stdin;
USRM006	*	MEN0019	\N	\N	\N	0
UMB76C42E8	*	MEN0086	\N	\N	\N	0
UM34044686	*	MENDYN1771406542221630	\N	\N	\N	0
USRM0062121	*	MEN0085	\N	\N	\N	0
\.


--
-- Data for Name: utilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utilisateur (refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole, acronyme, id, matricule, profile, idtypeutilisateur, estactif, idequipe) FROM stdin;
1	admin	paop	admin	DIR42	1002067	md	\N	\N	\N	\N	\N	1	\N
\.


--
-- Name: seq_absence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_absence', 4, true);


--
-- Name: seq_actionprojet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_actionprojet', 1, false);


--
-- Name: seq_alert; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_alert', 1680, true);


--
-- Name: seq_analyses; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_analyses', 1800, true);


--
-- Name: seq_apjclasse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_apjclasse', 34, true);


--
-- Name: seq_attribusentite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_attribusentite', 142, true);


--
-- Name: seq_attributclasse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_attributclasse', 120, true);


--
-- Name: seq_attributoracle; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_attributoracle', 1, false);


--
-- Name: seq_attributpostgres; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_attributpostgres', 1, false);


--
-- Name: seq_attributtype; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_attributtype', 1, false);


--
-- Name: seq_boutonchamp; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_boutonchamp', 1, false);


--
-- Name: seq_boutonpage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_boutonpage', 1, false);


--
-- Name: seq_branche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_branche', 223, true);


--
-- Name: seq_caisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_caisse', 1, false);


--
-- Name: seq_champdynamique; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_champdynamique', 1, false);


--
-- Name: seq_champsspeciaux; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_champsspeciaux', 11, true);


--
-- Name: seq_cheminprojetuser; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_cheminprojetuser', 2, true);


--
-- Name: seq_classe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_classe', 40, true);


--
-- Name: seq_comptaclassecompte; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptaclassecompte', 1, false);


--
-- Name: seq_comptacompte; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptacompte', 1, false);


--
-- Name: seq_comptacomptebackup; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptacomptebackup', 1, false);


--
-- Name: seq_comptaecriture; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptaecriture', 520, true);


--
-- Name: seq_comptaecriturebackup; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptaecriturebackup', 1, false);


--
-- Name: seq_comptaexercice; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptaexercice', 1, false);


--
-- Name: seq_comptajournal; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptajournal', 1, false);


--
-- Name: seq_comptajournalbackup; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptajournalbackup', 1, false);


--
-- Name: seq_comptalettrage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptalettrage', 1, false);


--
-- Name: seq_comptaorigine; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptaorigine', 1, false);


--
-- Name: seq_comptasousecriture; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptasousecriture', 300, true);


--
-- Name: seq_comptasousecriturebackup; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptasousecriturebackup', 1, false);


--
-- Name: seq_comptatypecompte; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptatypecompte', 1, false);


--
-- Name: seq_conception_pm; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_conception_pm', 60, true);


--
-- Name: seq_connexion; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_connexion', 4, true);


--
-- Name: seq_coutprevisionnel; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_coutprevisionnel', 20, true);


--
-- Name: seq_deploiement; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_deploiement', 45, true);


--
-- Name: seq_devis; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_devis', 1280, true);


--
-- Name: seq_devisfille; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_devisfille', 680, true);


--
-- Name: seq_diagramaffichage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramaffichage', 7, true);


--
-- Name: seq_diagramclass; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramclass', 30, true);


--
-- Name: seq_diagramclasscomposant; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramclasscomposant', 18, true);


--
-- Name: seq_diagramclasscomposanttype; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramclasscomposanttype', 3, true);


--
-- Name: seq_diagramclasspackage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramclasspackage', 2, true);


--
-- Name: seq_diagramcomposant; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramcomposant', 1, false);


--
-- Name: seq_diagrampackage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagrampackage', 5, true);


--
-- Name: seq_diagramtable; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramtable', 13, true);


--
-- Name: seq_diagramtablecolonne; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramtablecolonne', 1, false);


--
-- Name: seq_donation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_donation', 80, true);


--
-- Name: seq_entitescript; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_entitescript', 1, false);


--
-- Name: seq_exceptiontache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_exceptiontache', 1080, true);


--
-- Name: seq_histoinsert; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_histoinsert', 13174, true);


--
-- Name: seq_honoraire; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_honoraire', 1, false);


--
-- Name: seq_indisponibilite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_indisponibilite', 120, true);


--
-- Name: seq_jourrepos; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_jourrepos', 1, false);


--
-- Name: seq_magasin2; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_magasin2', 1, false);


--
-- Name: seq_mappingtypeattribut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_mappingtypeattribut', 1, false);


--
-- Name: seq_metierfille; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_metierfille', 20, true);


--
-- Name: seq_module; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_module', 260, true);


--
-- Name: seq_module_projet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_module_projet', 1, false);


--
-- Name: seq_niveauclient; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_niveauclient', 1, false);


--
-- Name: seq_notification; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_notification', 20560, true);


--
-- Name: seq_notificationdetails; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_notificationdetails', 7, true);


--
-- Name: seq_notificationgroupe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_notificationgroupe', 5, true);


--
-- Name: seq_notificationsignal; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_notificationsignal', 12, true);


--
-- Name: seq_pageanalyse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pageanalyse', 1, false);


--
-- Name: seq_pageanalyseattribut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pageanalyseattribut', 1, false);


--
-- Name: seq_pageattribut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pageattribut', 62, true);


--
-- Name: seq_pagefiche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pagefiche', 1, false);


--
-- Name: seq_pageficheattribut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pageficheattribut', 1, false);


--
-- Name: seq_pageliste; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pageliste', 2, true);


--
-- Name: seq_pagelisteattribut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pagelisteattribut', 6, true);


--
-- Name: seq_pagesaisie; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pagesaisie', 17, true);


--
-- Name: seq_panalysechampfiltre; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_panalysechampfiltre', 1, false);


--
-- Name: seq_pays; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pays', 1, false);


--
-- Name: seq_phaseproject; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_phaseproject', 4180, true);


--
-- Name: seq_plistchampfiltre; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_plistchampfiltre', 1, false);


--
-- Name: seq_pointage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pointage', 100, true);


--
-- Name: seq_projetutilisateur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_projetutilisateur', 1080, true);


--
-- Name: seq_proposition; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_proposition', 11, true);


--
-- Name: seq_province; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_province', 1, false);


--
-- Name: seq_qualite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_qualite', 1, false);


--
-- Name: seq_relation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_relation', 34, true);


--
-- Name: seq_requeteaenvoyer; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_requeteaenvoyer', 327720, true);


--
-- Name: seq_script; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_script', 1080, true);


--
-- Name: seq_scriptversionning; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_scriptversionning', 1120, true);


--
-- Name: seq_serveur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_serveur', 1, true);


--
-- Name: seq_tache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_tache', 184, true);


--
-- Name: seq_tache_git_details; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_tache_git_details', 260, true);


--
-- Name: seq_tache_git_mere; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_tache_git_mere', 180, true);


--
-- Name: seq_tauxhonoraire; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_tauxhonoraire', 1, false);


--
-- Name: seq_tempstravail; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_tempstravail', 1, false);


--
-- Name: seq_timingapplication; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_timingapplication', 226920, true);


--
-- Name: seq_timingsoustache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_timingsoustache', 149160, true);


--
-- Name: seq_type_utilisateur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_type_utilisateur', 20, true);


--
-- Name: seq_typeactionmetier; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeactionmetier', 20, true);


--
-- Name: seq_typeattributclasse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeattributclasse', 1, false);


--
-- Name: seq_typechampsspeciaux; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typechampsspeciaux', 1, false);


--
-- Name: seq_typeclasse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeclasse', 1, false);


--
-- Name: seq_typedependancediagram; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typedependancediagram', 1, false);


--
-- Name: seq_typedependanceobjet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typedependanceobjet', 1, false);


--
-- Name: seq_typeliaison; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeliaison', 1, false);


--
-- Name: seq_typemagasin; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typemagasin', 1, false);


--
-- Name: seq_typeouinon; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeouinon', 1, false);


--
-- Name: seq_typepageanalyse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typepageanalyse', 1, false);


--
-- Name: seq_typepageliste; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typepageliste', 1, false);


--
-- Name: seq_typepagesaisie; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typepagesaisie', 1, false);


--
-- Name: seq_typeplistchampfiltre; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeplistchampfiltre', 1, false);


--
-- Name: seq_typerelation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typerelation', 1, false);


--
-- Name: seq_typescript; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typescript', 40, true);


--
-- Name: seq_typetache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typetache', 20, true);


--
-- Name: seq_v_classeetfiche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_v_classeetfiche', 1, false);


--
-- Name: seq_v_classetfiche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_v_classetfiche', 1, false);


--
-- Name: seqaction; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqaction', 1, false);


--
-- Name: seqactiontache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqactiontache', 1, false);


--
-- Name: seqarchitecture; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqarchitecture', 5, true);


--
-- Name: seqattacher_fichier; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqattacher_fichier', 113, true);


--
-- Name: seqavoirfc; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqavoirfc', 1, false);


--
-- Name: seqavoirfcfille; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqavoirfcfille', 1, false);


--
-- Name: seqbase; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqbase', 20, true);


--
-- Name: seqbaserelation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqbaserelation', 18, true);


--
-- Name: seqbranche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqbranche', 1, false);


--
-- Name: seqcaisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcaisse', 1, false);


--
-- Name: seqcanevatache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcanevatache', 2, true);


--
-- Name: seqcateging; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcateging', 1, false);


--
-- Name: seqcategorie; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcategorie', 100, true);


--
-- Name: seqcategorieavoirfc; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcategorieavoirfc', 1, false);


--
-- Name: seqcategoriecaisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcategoriecaisse', 1, false);


--
-- Name: seqcategorieniveau; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcategorieniveau', 1, false);


--
-- Name: seqclient; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqclient', 58, true);


--
-- Name: seqcote; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcote', 120, true);


--
-- Name: seqcrcontent; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcrcontent', 80, true);


--
-- Name: seqcrcontentfille; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcrcontentfille', 80, true);


--
-- Name: seqcreation_projet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcreation_projet', 5100, true);


--
-- Name: seqdevise; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqdevise', 1, false);


--
-- Name: seqdonation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqdonation', 7080, true);


--
-- Name: seqentite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqentite', 4098, true);


--
-- Name: seqequipe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqequipe', 20, true);


--
-- Name: seqexecution_script; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqexecution_script', 7, true);


--
-- Name: seqexecution_scriptfille; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqexecution_scriptfille', 7, true);


--
-- Name: seqexecutions; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqexecutions', 2, true);


--
-- Name: seqexternal_work; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqexternal_work', 2, true);


--
-- Name: seqfonctionnalite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqfonctionnalite', 425, true);


--
-- Name: seqfournisseur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqfournisseur', 1, false);


--
-- Name: seqhistoimport; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqhistoimport', 6960, true);


--
-- Name: seqhistorique; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqhistorique', 2872520, true);


--
-- Name: seqhistoriqueactif; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqhistoriqueactif', 9, true);


--
-- Name: seqhistovaleur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqhistovaleur', 8280, true);


--
-- Name: seqingredients; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqingredients', 1, false);


--
-- Name: seqmagasin; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmagasin', 1, false);


--
-- Name: seqmailcc; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmailcc', 1, false);


--
-- Name: seqmailrapport; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmailrapport', 60, true);


--
-- Name: seqmetier; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmetier', 932, true);


--
-- Name: seqmetierrelation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmetierrelation', 1, true);


--
-- Name: seqmotifavoirfc; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmotifavoirfc', 1, false);


--
-- Name: seqmouvementcaisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmouvementcaisse', 21, true);


--
-- Name: seqmvtcaisseprevision; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmvtcaisseprevision', 1, false);


--
-- Name: seqniveau; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqniveau', 1, false);


--
-- Name: seqnotificationaction; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqnotificationaction', 1, false);


--
-- Name: seqordonnerpaiement; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqordonnerpaiement', 1, false);


--
-- Name: seqpage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpage', 8268, true);


--
-- Name: seqpagerelation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpagerelation', 1, false);


--
-- Name: seqparamcrypt; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqparamcrypt', 87, true);


--
-- Name: seqphase; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqphase', 3, true);


--
-- Name: seqpiecejointe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpiecejointe', 211, true);


--
-- Name: seqpoint; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpoint', 1, false);


--
-- Name: seqprevision; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqprevision', 1, false);


--
-- Name: seqprojet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqprojet', 1, true);


--
-- Name: seqprojetequipe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqprojetequipe', 100, true);


--
-- Name: seqpromesse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpromesse', 1, false);


--
-- Name: seqrep; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqrep', 1, false);


--
-- Name: seqrepd; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqrepd', 1, false);


--
-- Name: seqreportcaisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqreportcaisse', 100, true);


--
-- Name: seqrequeteaenvoyer; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqrequeteaenvoyer', 1, false);


--
-- Name: seqscript_projet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqscript_projet', 85, true);


--
-- Name: seqsource; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqsource', 1, false);


--
-- Name: seqtache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtache', 339659, true);


--
-- Name: seqtachemere; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtachemere', 17726, true);


--
-- Name: seqtachemere_detailsdefaut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtachemere_detailsdefaut', 1, false);


--
-- Name: seqtachemeredefaut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtachemeredefaut', 1, false);


--
-- Name: seqtauxavancementmodule; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtauxavancementmodule', 1, false);


--
-- Name: seqtauxavancementprojet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtauxavancementprojet', 1, false);


--
-- Name: seqtauxdechange; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtauxdechange', 1, false);


--
-- Name: seqtype; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtype', 100, true);


--
-- Name: seqtypeabsence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypeabsence', 1, false);


--
-- Name: seqtypeaction; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypeaction', 1, false);


--
-- Name: seqtypebase; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypebase', 2, true);


--
-- Name: seqtypecaisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypecaisse', 1, false);


--
-- Name: seqtypefichier; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypefichier', 1, false);


--
-- Name: seqtypefournisseur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypefournisseur', 1, false);


--
-- Name: seqtypemetier; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypemetier', 2, true);


--
-- Name: seqtypepage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypepage', 4, true);


--
-- Name: seqtyperepos; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtyperepos', 1, false);


--
-- Name: sequnite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sequnite', 1, false);


--
-- Name: sequserequipe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sequserequipe', 120, true);


--
-- Name: sequtilisateur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sequtilisateur', 2280, true);


--
-- Name: seqvente; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqvente', 22, true);


--
-- Name: seqventedetails; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqventedetails', 53, true);


--
-- Name: seqwork_branche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqwork_branche', 1, false);


--
-- Name: seqwork_type; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqwork_type', 1, false);


--
-- Name: direction direction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direction
    ADD CONSTRAINT direction_pkey PRIMARY KEY (id);


--
-- Name: histoinsert histoinsert_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.histoinsert
    ADD CONSTRAINT histoinsert_pkey PRIMARY KEY (idhistorique);


--
-- Name: historique historique_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historique
    ADD CONSTRAINT historique_pkey PRIMARY KEY (idhistorique);


--
-- Name: paramcrypt paramcrypt_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paramcrypt
    ADD CONSTRAINT paramcrypt_pk PRIMARY KEY (id);


--
-- Name: menudynamique pkmenud; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menudynamique
    ADD CONSTRAINT pkmenud PRIMARY KEY (id);


--
-- Name: utilisateur unique_utilisateur_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT unique_utilisateur_id UNIQUE (id);


--
-- Name: usermenu usermenu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usermenu
    ADD CONSTRAINT usermenu_pkey PRIMARY KEY (id);


--
-- Name: utilisateur utilisateur_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_pk PRIMARY KEY (refuser);


--
-- PostgreSQL database dump complete
--

\unrestrict 1bnegjh1b0OudEjWtO5J7WaLPkwxFgOdNnaB5T5i30vnVHbCi1MZkXhUq29xfss

