package alumni;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour le chargement du fil d'actualite et des publications HTML.
 * Pre-charge toutes les donnees (medias, reactions, commentaires, identifications,
 * enregistrements, publications partagees) pour que publication.jsp n'ait plus
 * besoin de connexion.
 * Gere sa propre connexion (aucune connexion dans les JSP).
 */
public class FeedHtmlService {

    /* ═══════════════════════════════════════════════════════════
     * POIDS DE PONDERATION DU SCORE (modifiables)
     * ═══════════════════════════════════════════════════════════ */

    /** Poids d'une reaction sur le score d'une publication */
    public static int POIDS_REACTION     = 2;
    /** Poids d'un commentaire sur le score d'une publication */
    public static int POIDS_COMMENTAIRE  = 3;
    /** Penalite par vue de l'utilisateur connecte */
    public static int POIDS_VUE          = 4;
    /** Bonus si la publication date d'aujourd'hui */
    public static int POIDS_AUJOURD_HUI  = 15;
    /** Bonus si la publication date de cette semaine (7 jours) */
    public static int POIDS_CETTE_SEMAINE = 8;
    /** Bonus si la publication date de ce mois (30 jours) */
    public static int POIDS_CE_MOIS      = 3;

    /** Nombre de publications par page (feed et profil) */
    public static int PAGE_SIZE          = 10;

    /* ═══════════════════════════════════════════════════════════
     * HELPERS UTILITAIRES
     * ═══════════════════════════════════════════════════════════ */

    /** Calcule les initiales a partir du nom complet */
    private static String computeInitials(String nom) {
        if (nom == null || nom.trim().isEmpty()) return "U";
        String[] parts = nom.trim().split("\\s+");
        String ini = (parts.length > 0 && parts[0].length() > 0)
                ? String.valueOf(Character.toUpperCase(parts[0].charAt(0))) : "U";
        if (parts.length > 1 && parts[parts.length - 1].length() > 0)
            ini += Character.toUpperCase(parts[parts.length - 1].charAt(0));
        return ini;
    }

    /* ═══════════════════════════════════════════════════════════
     * CHARGEMENT DES DONNEES COMMUNES (types, profils, photos)
     * ═══════════════════════════════════════════════════════════ */

    private static void loadCommonData(Connection conn, int refuser, String ctx,
            boolean loadBanned, Map result) throws Exception {

        Typepublication[] typesPub = (Typepublication[]) CGenUtil.rechercher(
                new Typepublication(), null, null, conn, " order by idtypepublication");
        if (typesPub == null) typesPub = new Typepublication[0];
        result.put("typesPub", typesPub);

        Reactiontype[] reactTypes = (Reactiontype[]) CGenUtil.rechercher(
                new Reactiontype(), null, null, conn, " order by idreactiontype");
        if (reactTypes == null) reactTypes = new Reactiontype[0];
        result.put("reactTypes", reactTypes);

        ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(
                new ProfilLib(), null, null, conn, "");
        Map userNames  = new HashMap();
        Map userPhotos = new HashMap();
        Map userProfils = new HashMap();
        Map userBanned = new HashMap();
        if (allProfils != null) {
            for (int i = 0; i < allProfils.length; i++) {
                Integer key = new Integer(allProfils[i].getIdutilisateur());
                userNames.put(key, allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                if (allProfils[i].getPhotoProfil() != null && !allProfils[i].getPhotoProfil().trim().isEmpty())
                    userPhotos.put(key, ctx + "/" + allProfils[i].getPhotoProfil().trim());
                if (allProfils[i].getIdprofil() != null && !allProfils[i].getIdprofil().trim().isEmpty())
                    userProfils.put(key, allProfils[i].getIdprofil().trim());
                if (loadBanned && allProfils[i].getEstactif() == 0)
                    userBanned.put(key, Boolean.TRUE);
            }
        }
        result.put("userNames", userNames);
        result.put("userPhotos", userPhotos);
        result.put("userProfils", userProfils);
        result.put("userBanned", userBanned);

        String connPhotoUrl = "";
        ProfilLib[] myProfils = (ProfilLib[]) CGenUtil.rechercher(
                new ProfilLib(), null, null, conn, " and refuser=" + refuser);
        if (myProfils != null && myProfils.length > 0) {
            if (myProfils[0].getPhotoProfil() != null && !myProfils[0].getPhotoProfil().trim().isEmpty())
                connPhotoUrl = ctx + "/" + myProfils[0].getPhotoProfil().trim();
        }
        result.put("connPhotoUrl", connPhotoUrl);
    }

    /* ═══════════════════════════════════════════════════════════
     * CONSTRUCTION DU FILTRE DE VISIBILITE
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Construit la clause WHERE de visibilite pour le feed.
     * L'utilisateur voit : ses propres publications, celles sans visibilite,
     * et celles dont la visibilite correspond a son profil (specialite, parcours, promotion).
     */
    private static String buildVisibiliteClause(int refuser) {
        String vsSpec = "(SELECT sp.idspecialite FROM specialiteprofil sp "
            + "JOIN profil _pr ON sp.idprofil=_pr.idprofil WHERE _pr.idutilisateur=" + refuser + ")";
        String vsParc = "(SELECT _pr.idparcours FROM profil _pr "
            + "WHERE _pr.idutilisateur=" + refuser + " LIMIT 1)";
        String vsUserAnnee = "(SELECT _pt.annee FROM promotion _pt "
            + "JOIN profil _pr ON _pt.idpromotion=_pr.idpromotion "
            + "WHERE _pr.idutilisateur=" + refuser + " LIMIT 1)";
        String vsPromoCond = "(_pv.typecible='PROMOTION' AND ((_pv.anneedirection='+' AND "
            + vsUserAnnee + ">=_pv.anneeref) OR (_pv.anneedirection='-' AND "
            + vsUserAnnee + "<=_pv.anneeref)))";

        String vsSpecExist = "EXISTS (SELECT 1 FROM publicationvisibilite _pv "
            + "WHERE _pv.idpublication=p.idpublication AND _pv.typecible='SPECIALITE' "
            + "AND _pv.idref IN " + vsSpec + ")";
        String vsPromoExist = "EXISTS (SELECT 1 FROM publicationvisibilite _pv "
            + "WHERE _pv.idpublication=p.idpublication AND " + vsPromoCond + ")";
        String vsParcExist = "EXISTS (SELECT 1 FROM publicationvisibilite _pv "
            + "WHERE _pv.idpublication=p.idpublication AND _pv.typecible='PARCOURS' "
            + "AND _pv.idref=" + vsParc + ")";

        return " AND (p.idutilisateur=" + refuser
            + " OR NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv "
            +     "WHERE _pv.idpublication=p.idpublication)"
            + " OR (COALESCE(p.logique_visibilite,'OR')='OR' AND ("
            +     vsSpecExist + " OR " + vsPromoExist + " OR " + vsParcExist + "))"
            + " OR (p.logique_visibilite='AND'"
            +     " AND (NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv "
            +         "WHERE _pv.idpublication=p.idpublication AND _pv.typecible='SPECIALITE') OR " + vsSpecExist + ")"
            +     " AND (NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv "
            +         "WHERE _pv.idpublication=p.idpublication AND _pv.typecible='PROMOTION') OR " + vsPromoExist + ")"
            +     " AND (NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv "
            +         "WHERE _pv.idpublication=p.idpublication AND _pv.typecible='PARCOURS') OR " + vsParcExist + ")))";
    }

    /* ═══════════════════════════════════════════════════════════
     * CONSTRUCTION DU FILTRE HASHTAG
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Construit la clause WHERE pour les filtres hashtag actifs.
     * Si aucun filtre n'est actif, retourne une chaine vide.
     */
    private static String buildHashtagClause(String filterSpec, String filterParc,
            String filterPromo, String filterTypepub, String filterLier) {

        List fConds = new ArrayList();

        if (filterSpec != null && !filterSpec.isEmpty())
            fConds.add("EXISTS (SELECT 1 FROM publicationhashtag _ph "
                + "WHERE _ph.idpublication=p.idpublication "
                + "AND _ph.typetag='SPECIALITE' AND _ph.idref='" + filterSpec + "')");

        if (filterParc != null && !filterParc.isEmpty())
            fConds.add("EXISTS (SELECT 1 FROM publicationhashtag _ph "
                + "WHERE _ph.idpublication=p.idpublication "
                + "AND _ph.typetag='PARCOURS' AND _ph.idref='" + filterParc + "')");

        if (filterPromo != null && !filterPromo.isEmpty()
                && filterPromo.matches("\\d{4}[+-]")) {
            int fpAnnee = Integer.parseInt(filterPromo.substring(0, 4));
            char fpDir = filterPromo.charAt(4);
            String fpCmp = (fpDir == '+') ? ">=" : "<=";
            fConds.add("EXISTS (SELECT 1 FROM publicationhashtag _ph "
                + "WHERE _ph.idpublication=p.idpublication AND _ph.typetag='PROMOTION' "
                + "AND (SELECT _pt2.annee FROM promotion _pt2 "
                + "WHERE _pt2.idpromotion=_ph.idref LIMIT 1)" + fpCmp + fpAnnee + ")");
        }

        if (filterTypepub != null && !filterTypepub.isEmpty())
            fConds.add("p.idtypepublication='" + filterTypepub + "'");

        if (fConds.isEmpty()) return "";

        if (fConds.size() == 1) return " AND " + fConds.get(0);

        String join = "1".equals(filterLier) ? " AND " : " OR ";
        StringBuffer sb = new StringBuffer(" AND (");
        for (int ci = 0; ci < fConds.size(); ci++) {
            if (ci > 0) sb.append(join);
            sb.append(fConds.get(ci));
        }
        sb.append(")");
        return sb.toString();
    }

    /* ═══════════════════════════════════════════════════════════
     * CONSTRUCTION DE LA FORMULE DE SCORE
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Construit la formule SQL de score pour le classement du feed.
     * Utilise les poids statiques de la classe.
     */
    private static String buildScoreFormula(int refuser) {
        return "COALESCE((SELECT COUNT(*) FROM publicationreaction pr "
            +     "WHERE pr.idpublication=p.idpublication),0)*" + POIDS_REACTION
            + "+COALESCE((SELECT COUNT(*) FROM publicationcommentaire pc "
            +     "WHERE pc.idpublication=p.idpublication AND pc.etat=1),0)*" + POIDS_COMMENTAIRE
            + "-COALESCE((SELECT pv.nbvue FROM publicationvue pv "
            +     "WHERE pv.idpublication=p.idpublication AND pv.idutilisateur=" + refuser + "),0)*" + POIDS_VUE
            + "+CASE WHEN p.daty::date=CURRENT_DATE THEN " + POIDS_AUJOURD_HUI
            +   " WHEN p.daty::date>=CURRENT_DATE-7 THEN " + POIDS_CETTE_SEMAINE
            +   " WHEN p.daty::date>=CURRENT_DATE-30 THEN " + POIDS_CE_MOIS
            +   " ELSE 0 END";
    }

    /* ═══════════════════════════════════════════════════════════
     * EXECUTION DE LA REQUETE FEED AVEC SCORE
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Recupere les IDs et scores des publications pour le feed.
     * Pagination par curseur (score, id).
     * @return int[0] = ids (List of String), int[1] = scores (List of Integer)
     */
    private static Object[] fetchFeedIds(Connection conn, String scoreFormula,
            String visW, String hashW, int cursorScore, String cursorId) throws Exception {

        String sql = "SELECT sub.idpublication, sub.score FROM ("
            + "  SELECT p.idpublication,(" + scoreFormula + ") AS score "
            + "  FROM publication p WHERE p.etat=1" + visW + hashW
            + ") sub WHERE sub.score < " + cursorScore
            + " OR (sub.score = " + cursorScore + " AND sub.idpublication < '" + cursorId + "')"
            + " ORDER BY sub.score DESC, sub.idpublication DESC LIMIT " + PAGE_SIZE;

        List ids = new ArrayList();
        List scores = new ArrayList();
        Statement st = null;
        ResultSet rs = null;
        try {
            st = conn.createStatement();
            rs = st.executeQuery(sql);
            while (rs.next()) {
                ids.add(rs.getString("idpublication"));
                scores.add(new Integer(rs.getInt("score")));
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception x) {}
            if (st != null) try { st.close(); } catch (Exception x) {}
        }
        return new Object[]{ ids, scores };
    }

    /* ═══════════════════════════════════════════════════════════
     * EXECUTION DE LA REQUETE PUBLICATIONS PROFIL
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Recupere les IDs de publications d'un utilisateur (pagination par curseur id).
     */
    private static List fetchProfilPubIds(Connection conn, int targetUser,
            String cursorId) throws Exception {

        String cursorCond = "";
        if (cursorId != null && !cursorId.trim().isEmpty())
            cursorCond = " AND idpublication < '" + cursorId.replaceAll("[^A-Za-z0-9]", "") + "'";

        String sql = "SELECT idpublication FROM publication WHERE idutilisateur=" + targetUser
            + " AND etat=1" + cursorCond + " ORDER BY idpublication DESC LIMIT " + PAGE_SIZE;

        List ids = new ArrayList();
        Statement st = null;
        ResultSet rs = null;
        try {
            st = conn.createStatement();
            rs = st.executeQuery(sql);
            while (rs.next()) ids.add(rs.getString("idpublication"));
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception x) {}
            if (st != null) try { st.close(); } catch (Exception x) {}
        }
        return ids;
    }

    /* ═══════════════════════════════════════════════════════════
     * CHARGEMENT DE PUBLICATIONS PAR IDS
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Charge les objets Publication correspondant a une liste d'IDs.
     */
    private static Publication[] loadPublicationsById(Connection conn,
            List pubIds) throws Exception {

        Publication[] pubs = new Publication[pubIds.size()];
        for (int i = 0; i < pubIds.size(); i++) {
            Publication[] pa = (Publication[]) CGenUtil.rechercher(
                new Publication(), null, null, conn,
                " and idpublication='" + pubIds.get(i) + "'");
            pubs[i] = (pa != null && pa.length > 0) ? pa[0] : new Publication();
        }
        return pubs;
    }

    /* ═══════════════════════════════════════════════════════════
     * CHARGEMENT DES DONNEES PAR PUBLICATION
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Pre-charge les donnees par publication :
     *   pubMedias, pubReactions, pubComments, pubIdentifications,
     *   pubSaved, origPubs, origMedias
     */
    private static void loadPerPublicationData(Connection conn, Publication[] pubs,
            int refuser, Map userNames, Map userPhotos, Map userProfils,
            String ctx, Map result) throws Exception {

        Map pubMedias = new HashMap();
        Map pubReactions = new HashMap();
        Map pubComments = new HashMap();
        Map pubIdentifications = new HashMap();
        Map pubSaved = new HashMap();
        Map origPubs = new HashMap();
        Map origMedias = new HashMap();

        for (int i = 0; i < pubs.length; i++) {
            String idpub = pubs[i].getIdpublication();
            if (idpub == null) continue;

            // Enregistrement (saved/bookmark)
            Publicationenregistrement[] enrArr = (Publicationenregistrement[]) CGenUtil.rechercher(
                    new Publicationenregistrement(), null, null, conn,
                    " and idpublication = '" + idpub + "' and idutilisateur = " + refuser);
            if (enrArr != null && enrArr.length > 0) pubSaved.put(idpub, Boolean.TRUE);

            // Medias
            Media[] medias = (Media[]) CGenUtil.rechercher(
                    new Media(), null, null, conn, " and idpublication = '" + idpub + "'");
            pubMedias.put(idpub, medias != null ? medias : new Media[0]);

            // Reactions
            Publicationreaction[] reactions = (Publicationreaction[]) CGenUtil.rechercher(
                    new Publicationreaction(), null, null, conn, " and idpublication = '" + idpub + "'");
            pubReactions.put(idpub, reactions != null ? reactions : new Publicationreaction[0]);

            // Commentaires
            Publicationcommentaire[] comments = (Publicationcommentaire[]) CGenUtil.rechercher(
                    new Publicationcommentaire(), null, null, conn,
                    " and idpublication = '" + idpub + "' and etat = 1");
            pubComments.put(idpub, comments != null ? comments : new Publicationcommentaire[0]);

            // Identifications
            Identification[] idents = (Identification[]) CGenUtil.rechercher(
                    new Identification(), null, null, conn, " and idpublication = '" + idpub + "'");
            pubIdentifications.put(idpub, idents != null ? idents : new Identification[0]);

            // Publication partagee (shared post)
            loadOriginalPublication(conn, pubs[i], origPubs, origMedias,
                    userNames, userPhotos, userProfils, ctx);
        }

        result.put("pubMedias", pubMedias);
        result.put("pubReactions", pubReactions);
        result.put("pubComments", pubComments);
        result.put("pubIdentifications", pubIdentifications);
        result.put("pubSaved", pubSaved);
        result.put("origPubs", origPubs);
        result.put("origMedias", origMedias);
    }

    /* ═══════════════════════════════════════════════════════════
     * CHARGEMENT D'UNE PUBLICATION ORIGINALE (PARTAGEE)
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Charge la publication originale si c'est un partage,
     * ainsi que l'auteur et les medias de l'originale.
     */
    private static void loadOriginalPublication(Connection conn, Publication pub,
            Map origPubs, Map origMedias,
            Map userNames, Map userPhotos, Map userProfils,
            String ctx) throws Exception {

        String origId = pub.getIdpuborigine();
        if (origId == null || origId.trim().isEmpty()) return;
        origId = origId.trim();

        if (origPubs.containsKey(origId)) return; // deja charge

        Publication[] origArr = (Publication[]) CGenUtil.rechercher(
                new Publication(), null, null, conn,
                " and idpublication = '" + origId + "'");
        if (origArr == null || origArr.length == 0) return;

        origPubs.put(origId, origArr[0]);

        // Charger l'auteur de la pub originale s'il n'est pas en cache
        Integer origAuthorKey = new Integer(origArr[0].getIdutilisateur());
        if (!userNames.containsKey(origAuthorKey)) {
            ProfilLib[] op = (ProfilLib[]) CGenUtil.rechercher(
                    new ProfilLib(), null, null, conn,
                    " and refuser = " + origArr[0].getIdutilisateur());
            if (op != null && op.length > 0) {
                userNames.put(origAuthorKey,
                    (op[0].getNom() != null ? op[0].getNom() : "")
                    + " " + (op[0].getPrenom() != null ? op[0].getPrenom() : ""));
                if (op[0].getPhotoProfil() != null && !op[0].getPhotoProfil().trim().isEmpty())
                    userPhotos.put(origAuthorKey, ctx + "/" + op[0].getPhotoProfil().trim());
                if (op[0].getIdprofil() != null && !op[0].getIdprofil().trim().isEmpty())
                    userProfils.put(origAuthorKey, op[0].getIdprofil().trim());
            }
        }

        // Medias de la pub originale
        Media[] oMedias = (Media[]) CGenUtil.rechercher(
                new Media(), null, null, conn,
                " and idpublication = '" + origId + "'");
        origMedias.put(origId, oMedias != null ? oMedias : new Media[0]);
    }

    /* ═══════════════════════════════════════════════════════════
     * RESOLUTION DE L'UTILISATEUR CIBLE (pour publicationsProfil)
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Resout l'idutilisateur a partir de paramIdUser ou paramIdProfil.
     * @return idutilisateur, ou -1 si non trouve.
     */
    private static int resolveTargetUser(Connection conn, String paramIdUser,
            String paramIdProfil) throws Exception {

        if (paramIdUser != null && !paramIdUser.trim().isEmpty()) {
            try { return Integer.parseInt(paramIdUser.trim()); }
            catch (NumberFormatException nfe) { /* continue */ }
        }

        if (paramIdProfil != null && !paramIdProfil.trim().isEmpty()) {
            ProfilLib filtre = new ProfilLib();
            filtre.setIdprofil(paramIdProfil.trim());
            ProfilLib[] pArr = (ProfilLib[]) CGenUtil.rechercher(filtre, null, null, conn, "");
            if (pArr != null && pArr.length > 0) return pArr[0].getIdutilisateur();
        }

        return -1;
    }

    /* ═══════════════════════════════════════════════════════════
     * PREPARATION DU MAP RESULTAT COMMUN
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Prepare le Map resultat avec les donnees communes.
     * @return le Map result pret a etre complete.
     */
    private static Map prepareBaseResult(Connection conn, int refuser,
            String nomConnecte, String ctx, boolean loadBanned) throws Exception {

        Map result = new HashMap();
        result.put("initialConnecte", computeInitials(nomConnecte));
        loadCommonData(conn, refuser, ctx, loadBanned, result);
        return result;
    }

    /* ═══════════════════════════════════════════════════════════
     *  METHODE PUBLIQUE : CHARGER LE FEED
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Charge le fil d'actualite avec score, visibilite et filtres hashtag.
     * Pagination par curseur (cursorScore, cursorId).
     */
    public static Map chargerFeed(int refuser, String nomConnecte, String ctx,
            int cursorScore, String cursorId,
            String filterSpec, String filterParc, String filterPromo,
            String filterTypepub, String filterLier) throws Exception {

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            Map result = prepareBaseResult(conn, refuser, nomConnecte, ctx, false);

            Map userNames  = (Map) result.get("userNames");
            Map userPhotos = (Map) result.get("userPhotos");
            Map userProfils = (Map) result.get("userProfils");

            // Construction des clauses SQL
            String visW   = buildVisibiliteClause(refuser);
            String hashW  = buildHashtagClause(filterSpec, filterParc, filterPromo,
                                               filterTypepub, filterLier);
            String scoreF = buildScoreFormula(refuser);

            // Recuperer les publications
            Object[] feedResult = fetchFeedIds(conn, scoreF, visW, hashW,
                                               cursorScore, cursorId);
            List pids = (List) feedResult[0];
            List pscores = (List) feedResult[1];

            Publication[] pubs = loadPublicationsById(conn, pids);
            result.put("pubs", pubs);

            // Curseur suivant
            String nextId = "";
            int nextScore = 0;
            boolean hasMore = (pids.size() == PAGE_SIZE);
            if (!pids.isEmpty()) {
                nextId = (String) pids.get(pids.size() - 1);
                nextScore = ((Integer) pscores.get(pscores.size() - 1)).intValue();
            }
            result.put("nextId", nextId);
            result.put("nextScore", new Integer(nextScore));
            result.put("hasMore", hasMore ? Boolean.TRUE : Boolean.FALSE);
            result.put("filterSpec", filterSpec != null ? filterSpec : "");
            result.put("filterParc", filterParc != null ? filterParc : "");
            result.put("filterPromo", filterPromo != null ? filterPromo : "");
            result.put("filterTypepub", filterTypepub != null ? filterTypepub : "");
            result.put("filterLier", filterLier != null ? filterLier : "");

            // Pre-charger les donnees par publication
            loadPerPublicationData(conn, pubs, refuser, userNames, userPhotos,
                                   userProfils, ctx, result);
            return result;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     *  METHODE PUBLIQUE : VOIR UNE PUBLICATION
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Charge une seule publication par son ID.
     */
    public static Map voirPublication(int refuser, String nomConnecte, String ctx,
            String idpublication) throws Exception {

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            Map result = prepareBaseResult(conn, refuser, nomConnecte, ctx, true);

            Map userNames  = (Map) result.get("userNames");
            Map userPhotos = (Map) result.get("userPhotos");
            Map userProfils = (Map) result.get("userProfils");

            Publication[] pArr = (Publication[]) CGenUtil.rechercher(
                new Publication(), null, null, conn,
                " and idpublication='" + idpublication + "'");
            if (pArr == null || pArr.length == 0) {
                result.put("pubs", new Publication[0]);
                result.put("notFound", Boolean.TRUE);
                return result;
            }
            Publication[] pubs = new Publication[]{ pArr[0] };
            result.put("pubs", pubs);

            loadPerPublicationData(conn, pubs, refuser, userNames, userPhotos,
                                   userProfils, ctx, result);
            return result;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     *  METHODE PUBLIQUE : PUBLICATIONS D'UN PROFIL
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Charge les publications d'un utilisateur/profil avec pagination par curseur.
     */
    public static Map publicationsProfil(int refuser, String nomConnecte, String ctx,
            String paramIdUser, String paramIdProfil, String cursorId) throws Exception {

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            Map result = prepareBaseResult(conn, refuser, nomConnecte, ctx, true);

            Map userNames  = (Map) result.get("userNames");
            Map userPhotos = (Map) result.get("userPhotos");
            Map userProfils = (Map) result.get("userProfils");

            // Resoudre l'utilisateur cible
            int targetUser = resolveTargetUser(conn, paramIdUser, paramIdProfil);
            if (targetUser == -1) {
                result.put("pubs", new Publication[0]);
                result.put("userNotFound", Boolean.TRUE);
                return result;
            }

            // Charger les IDs de publications
            List pubIds = fetchProfilPubIds(conn, targetUser, cursorId);
            if (pubIds.isEmpty()) {
                result.put("pubs", new Publication[0]);
                result.put("empty", Boolean.TRUE);
                return result;
            }

            Publication[] pubs = loadPublicationsById(conn, pubIds);
            result.put("pubs", pubs);

            boolean hasMore = (pubIds.size() == PAGE_SIZE);
            String lastPubId = hasMore ? (String) pubIds.get(pubIds.size() - 1) : "";
            result.put("hasMore", hasMore ? Boolean.TRUE : Boolean.FALSE);
            result.put("lastPubId", lastPubId);

            loadPerPublicationData(conn, pubs, refuser, userNames, userPhotos,
                                   userProfils, ctx, result);
            return result;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}