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
     * HELPERS
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

    /** Charge les donnees communes (types, profils, photos) dans le Map result */
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
            String origId = pubs[i].getIdpuborigine();
            if (origId != null && !origId.trim().isEmpty()) {
                origId = origId.trim();
                if (!origPubs.containsKey(origId)) {
                    Publication[] origArr = (Publication[]) CGenUtil.rechercher(
                            new Publication(), null, null, conn,
                            " and idpublication = '" + origId + "'");
                    if (origArr != null && origArr.length > 0) {
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
                }
            }
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
     * CHARGER FEED (score-based, filtres hashtag + visibilite)
     * ═══════════════════════════════════════════════════════════ */

    public static Map chargerFeed(int refuser, String nomConnecte, String ctx,
            int cursorScore, String cursorId,
            String filterSpec, String filterParc, String filterPromo,
            String filterTypepub, String filterLier) throws Exception {

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            Map result = new HashMap();
            result.put("initialConnecte", computeInitials(nomConnecte));
            loadCommonData(conn, refuser, ctx, false, result);

            Map userNames = (Map) result.get("userNames");
            Map userPhotos = (Map) result.get("userPhotos");
            Map userProfils = (Map) result.get("userProfils");

            // ── Filtre visibilite ──
            String vsSpec = "(SELECT sp.idspecialite FROM specialiteprofil sp JOIN profil _pr ON sp.idprofil=_pr.idprofil WHERE _pr.idutilisateur=" + refuser + ")";
            String vsParc = "(SELECT _pr.idparcours FROM profil _pr WHERE _pr.idutilisateur=" + refuser + " LIMIT 1)";
            String vsUserAnnee = "(SELECT _pt.annee FROM promotion _pt JOIN profil _pr ON _pt.idpromotion=_pr.idpromotion WHERE _pr.idutilisateur=" + refuser + " LIMIT 1)";
            String vsPromoCond = "(_pv.typecible='PROMOTION' AND ((_pv.anneedirection='+' AND " + vsUserAnnee + ">=_pv.anneeref) OR (_pv.anneedirection='-' AND " + vsUserAnnee + "<=_pv.anneeref)))";
            String vsSpecExist = "EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND _pv.typecible='SPECIALITE' AND _pv.idref IN " + vsSpec + ")";
            String vsPromoExist = "EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND " + vsPromoCond + ")";
            String vsParcExist = "EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND _pv.typecible='PARCOURS' AND _pv.idref=" + vsParc + ")";

            String visW = " AND (p.idutilisateur=" + refuser
                + " OR NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication)"
                + " OR (COALESCE(p.logique_visibilite,'OR')='OR' AND ("
                + vsSpecExist + " OR " + vsPromoExist + " OR " + vsParcExist
                + "))"
                + " OR (p.logique_visibilite='AND'"
                + " AND (NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND _pv.typecible='SPECIALITE') OR " + vsSpecExist + ")"
                + " AND (NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND _pv.typecible='PROMOTION') OR " + vsPromoExist + ")"
                + " AND (NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND _pv.typecible='PARCOURS') OR " + vsParcExist + ")))";

            // ── Filtre hashtag ──
            List fConds = new ArrayList();
            if (filterSpec != null && !filterSpec.isEmpty())
                fConds.add("EXISTS (SELECT 1 FROM publicationhashtag _ph WHERE _ph.idpublication=p.idpublication AND _ph.typetag='SPECIALITE' AND _ph.idref='" + filterSpec + "')");
            if (filterParc != null && !filterParc.isEmpty())
                fConds.add("EXISTS (SELECT 1 FROM publicationhashtag _ph WHERE _ph.idpublication=p.idpublication AND _ph.typetag='PARCOURS' AND _ph.idref='" + filterParc + "')");
            if (filterPromo != null && !filterPromo.isEmpty() && filterPromo.matches("\\d{4}[+-]")) {
                int fpAnnee = Integer.parseInt(filterPromo.substring(0, 4));
                char fpDir = filterPromo.charAt(4);
                String fpCmp = (fpDir == '+') ? ">=" : "<=";
                fConds.add("EXISTS (SELECT 1 FROM publicationhashtag _ph WHERE _ph.idpublication=p.idpublication AND _ph.typetag='PROMOTION' AND (SELECT _pt2.annee FROM promotion _pt2 WHERE _pt2.idpromotion=_ph.idref LIMIT 1)" + fpCmp + fpAnnee + ")");
            }
            if (filterTypepub != null && !filterTypepub.isEmpty())
                fConds.add("p.idtypepublication='" + filterTypepub + "'");

            String hashW = "";
            if (fConds.size() == 1) {
                hashW = " AND " + fConds.get(0);
            } else if (fConds.size() > 1) {
                String join = "1".equals(filterLier) ? " AND " : " OR ";
                StringBuffer sb = new StringBuffer(" AND (");
                for (int ci = 0; ci < fConds.size(); ci++) {
                    if (ci > 0) sb.append(join);
                    sb.append(fConds.get(ci));
                }
                sb.append(")");
                hashW = sb.toString();
            }

            // ── Calcul de score ──
            String sC = "COALESCE((SELECT COUNT(*) FROM publicationreaction pr WHERE pr.idpublication=p.idpublication),0)*2"
                + "+COALESCE((SELECT COUNT(*) FROM publicationcommentaire pc WHERE pc.idpublication=p.idpublication AND pc.etat=1),0)*3"
                + "-COALESCE((SELECT pv.nbvue FROM publicationvue pv WHERE pv.idpublication=p.idpublication AND pv.idutilisateur=" + refuser + "),0)*4"
                + "+CASE WHEN p.daty::date=CURRENT_DATE THEN 15 WHEN p.daty::date>=CURRENT_DATE-7 THEN 8 WHEN p.daty::date>=CURRENT_DATE-30 THEN 3 ELSE 0 END";

            // ── Requete principale ──
            String pSql = "SELECT sub.idpublication, sub.score FROM ("
                + "  SELECT p.idpublication,(" + sC + ") AS score FROM publication p WHERE p.etat=1" + visW + hashW
                + ") sub WHERE sub.score < " + cursorScore
                + " OR (sub.score = " + cursorScore + " AND sub.idpublication < '" + cursorId + "')"
                + " ORDER BY sub.score DESC, sub.idpublication DESC LIMIT 10";

            List pids = new ArrayList();
            List pscores = new ArrayList();
            Statement st = null; ResultSet rs = null;
            try {
                st = conn.createStatement(); rs = st.executeQuery(pSql);
                while (rs.next()) {
                    pids.add(rs.getString("idpublication"));
                    pscores.add(new Integer(rs.getInt("score")));
                }
            } finally {
                if (rs != null) try { rs.close(); } catch (Exception x) {}
                if (st != null) try { st.close(); } catch (Exception x) {}
            }

            Publication[] pubs = new Publication[pids.size()];
            for (int i = 0; i < pids.size(); i++) {
                Publication[] pa = (Publication[]) CGenUtil.rechercher(
                    new Publication(), null, null, conn,
                    " and idpublication='" + pids.get(i) + "'");
                pubs[i] = (pa != null && pa.length > 0) ? pa[0] : new Publication();
            }
            result.put("pubs", pubs);

            // Curseur suivant
            String nextId = "";
            int nextScore = 0;
            boolean hasMore = (pids.size() == 10);
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
            loadPerPublicationData(conn, pubs, refuser, userNames, userPhotos, userProfils, ctx, result);

            return result;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * VOIR UNE PUBLICATION
     * ═══════════════════════════════════════════════════════════ */

    public static Map voirPublication(int refuser, String nomConnecte, String ctx,
            String idpublication) throws Exception {

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            Map result = new HashMap();
            result.put("initialConnecte", computeInitials(nomConnecte));
            loadCommonData(conn, refuser, ctx, true, result);

            Map userNames = (Map) result.get("userNames");
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

            loadPerPublicationData(conn, pubs, refuser, userNames, userPhotos, userProfils, ctx, result);

            return result;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * PUBLICATIONS D'UN PROFIL
     * ═══════════════════════════════════════════════════════════ */

    public static Map publicationsProfil(int refuser, String nomConnecte, String ctx,
            String paramIdUser, String paramIdProfil, String cursorId) throws Exception {

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            Map result = new HashMap();
            result.put("initialConnecte", computeInitials(nomConnecte));
            loadCommonData(conn, refuser, ctx, true, result);

            Map userNames = (Map) result.get("userNames");
            Map userPhotos = (Map) result.get("userPhotos");
            Map userProfils = (Map) result.get("userProfils");

            // Resoudre l'idutilisateur
            int targetUser = -1;
            if (paramIdUser != null && !paramIdUser.trim().isEmpty()) {
                try { targetUser = Integer.parseInt(paramIdUser.trim()); } catch (NumberFormatException nfe) {}
            } else if (paramIdProfil != null && !paramIdProfil.trim().isEmpty()) {
                ProfilLib filtre = new ProfilLib();
                filtre.setIdprofil(paramIdProfil.trim());
                ProfilLib[] pArr = (ProfilLib[]) CGenUtil.rechercher(filtre, null, null, conn, "");
                if (pArr != null && pArr.length > 0) targetUser = pArr[0].getIdutilisateur();
            }
            if (targetUser == -1) {
                result.put("pubs", new Publication[0]);
                result.put("userNotFound", Boolean.TRUE);
                return result;
            }

            // Charger les publications (10 dernieres, paginées)
            String cursorCond = "";
            if (cursorId != null && !cursorId.trim().isEmpty()) {
                cursorCond = " AND idpublication < '" + cursorId.replaceAll("[^A-Za-z0-9]", "") + "'";
            }
            String pubSql = "SELECT idpublication FROM publication WHERE idutilisateur=" + targetUser
                + " AND etat=1" + cursorCond + " ORDER BY idpublication DESC LIMIT 10";

            List pubIds = new ArrayList();
            Statement st = null; ResultSet rs = null;
            try {
                st = conn.createStatement(); rs = st.executeQuery(pubSql);
                while (rs.next()) pubIds.add(rs.getString("idpublication"));
            } finally {
                if (rs != null) try { rs.close(); } catch (Exception x) {}
                if (st != null) try { st.close(); } catch (Exception x) {}
            }

            if (pubIds.isEmpty()) {
                result.put("pubs", new Publication[0]);
                result.put("empty", Boolean.TRUE);
                return result;
            }

            Publication[] pubs = new Publication[pubIds.size()];
            for (int i = 0; i < pubIds.size(); i++) {
                Publication[] pa = (Publication[]) CGenUtil.rechercher(
                    new Publication(), null, null, conn,
                    " and idpublication='" + pubIds.get(i) + "'");
                pubs[i] = (pa != null && pa.length > 0) ? pa[0] : new Publication();
            }
            result.put("pubs", pubs);

            boolean hasMore = (pubIds.size() == 10);
            String lastPubId = hasMore ? (String) pubIds.get(pubIds.size() - 1) : "";
            result.put("hasMore", hasMore ? Boolean.TRUE : Boolean.FALSE);
            result.put("lastPubId", lastPubId);

            loadPerPublicationData(conn, pubs, refuser, userNames, userPhotos, userProfils, ctx, result);

            return result;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
