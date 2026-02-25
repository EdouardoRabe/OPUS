<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Media" %>
<%@ page import="alumni.Publicationreaction" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.Typepublication" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.Identification" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.regex.Matcher" %>
<%!
    private static String linkifyDesc(String raw) {
        if (raw == null || raw.trim().isEmpty()) return "";
        String s = raw.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
        s = s.replace("\n", "<br>");
        s = s.replaceAll(
            "(https?://[A-Za-z0-9._~:/?#\\[\\]@!$&'()*+,;=%-]+)",
            "<a href=\"$1\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"pub-link\">$1</a>"
        );
        s = s.replaceAll(
            "(?<!href=\\\"|/)(www\\.[A-Za-z0-9._~:/?#\\[\\]@!$&'()*+,;=%-]+)",
            "<a href=\"http://$1\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"pub-link\">$1</a>"
        );
        s = s.replaceAll(
            "#([A-Za-z0-9_]+)",
            "<span class=\"pub-hashtag\">#$1</span>"
        );
        s = s.replaceAll(
            "@([A-Za-z\\u00C0-\\u00FF]+(?: [A-Za-z\\u00C0-\\u00FF]+){0,2})",
            "<span class=\"mention-badge\">@$1</span>"
        );
        return s;
    }
%>
<%
    // =========================================================
    // AJAX : Chargement progressif du fil d'actualite (score-based)
    // Parametres GET :
    //   cursor_score = score de la derniere publication affichee
    //   cursor_id    = idpublication de la derniere publication affichee
    // =========================================================

    UserEJB uFeed = (UserEJB) session.getAttribute("u");
    if (uFeed == null) { return; }

    MapUtilisateur mapFeed = uFeed.getUser();
    int refuserConnecte   = mapFeed.getRefuser();
    String nomConnecte    = mapFeed.getNomuser() != null ? mapFeed.getNomuser() : "";
    String ctx            = request.getContextPath();

    // Initiales du user connecte (pour zone commentaires)
    String[] _partsConn = nomConnecte.trim().split("\\s+");
    String initialConnecte = (_partsConn.length > 0 && _partsConn[0].length() > 0)
            ? String.valueOf(Character.toUpperCase(_partsConn[0].charAt(0))) : "U";
    if (_partsConn.length > 1 && _partsConn[_partsConn.length - 1].length() > 0)
        initialConnecte += Character.toUpperCase(_partsConn[_partsConn.length - 1].charAt(0));

    // --- Lecture et sanitisation des parametres curseur ---
    String cursorScoreStr = request.getParameter("cursor_score");
    String cursorId       = request.getParameter("cursor_id");

    if (cursorId == null || cursorId.trim().isEmpty()) { return; }

    cursorId = cursorId.replaceAll("[^A-Za-z0-9]", "");
    int cursorScore = 0;
    try { cursorScore = Integer.parseInt(cursorScoreStr != null ? cursorScoreStr.replaceAll("[^0-9\\-]", "") : "0"); } catch (NumberFormatException _nfe) {}

    // --- Filtres hashtag ---
    String filterSpec    = request.getParameter("filter_spec");    if (filterSpec == null) filterSpec = "";
    String filterParc    = request.getParameter("filter_parc");    if (filterParc == null) filterParc = "";
    String filterPromo   = request.getParameter("filter_promo");   if (filterPromo == null) filterPromo = "";
    String filterTypepub = request.getParameter("filter_typepub"); if (filterTypepub == null) filterTypepub = "";
    String filterLier    = request.getParameter("filter_lier");    if (filterLier == null) filterLier = "";
    filterSpec    = filterSpec.replaceAll("[^A-Za-z0-9]","");
    filterParc    = filterParc.replaceAll("[^A-Za-z0-9]","");
    filterPromo   = filterPromo.replaceAll("[^0-9+\\-]",""); // format: yyyy+ ou yyyy-
    filterTypepub = filterTypepub.replaceAll("[^A-Za-z0-9]","");

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        // --- Types de publication ---
        Typepublication[] typesPub = (Typepublication[]) CGenUtil.rechercher(
                new Typepublication(), null, null, conn, " order by idtypepublication");
        if (typesPub == null) typesPub = new Typepublication[0];

        // --- Types de reaction ---
        Reactiontype[] reactTypes = (Reactiontype[]) CGenUtil.rechercher(
                new Reactiontype(), null, null, conn, " order by idreactiontype");
        if (reactTypes == null) reactTypes = new Reactiontype[0];

        // --- Lookup noms + photos de tous les profils ---
        ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(
                new ProfilLib(), null, null, conn, "");
        Map userNames  = new HashMap();
        Map userPhotos = new HashMap();
        Map userProfils = new HashMap();
        Map userBanned = new HashMap(); // Integer -> Boolean (true if banned)
        if (allProfils != null) {
            for (int i = 0; i < allProfils.length; i++) {
                Integer _key = new Integer(allProfils[i].getIdutilisateur());
                userNames.put(_key, allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                if (allProfils[i].getPhotoProfil() != null && !allProfils[i].getPhotoProfil().trim().isEmpty())
                    userPhotos.put(_key, ctx + "/" + allProfils[i].getPhotoProfil().trim());
                if (allProfils[i].getIdprofil() != null && !allProfils[i].getIdprofil().trim().isEmpty())
                    userProfils.put(_key, allProfils[i].getIdprofil().trim());
                if (allProfils[i].getEstactif() == 0)
                    userBanned.put(_key, Boolean.TRUE);
            }
        }

        // --- Photo de profil du connecte (zone commentaires) ---
        String _connPhotoUrl = "";
        ProfilLib[] _myProfils = (ProfilLib[]) CGenUtil.rechercher(
                new ProfilLib(), null, null, conn, " and refuser=" + refuserConnecte);
        if (_myProfils != null && _myProfils.length > 0) {
            if (_myProfils[0].getPhotoProfil() != null && !_myProfils[0].getPhotoProfil().trim().isEmpty())
                _connPhotoUrl = ctx + "/" + _myProfils[0].getPhotoProfil().trim();
        }

        // --- Requete score-based avec curseur + visibilite + filtre ---
        // Filtre visibilite (avec PARCOURS + anneedirection)
        String _vsSpec2     = "(SELECT sp.idspecialite FROM specialiteprofil sp JOIN profil _pr ON sp.idprofil=_pr.idprofil WHERE _pr.idutilisateur=" + refuserConnecte + ")";
        String _vsParc2     = "(SELECT _pr.idparcours FROM profil _pr WHERE _pr.idutilisateur=" + refuserConnecte + " LIMIT 1)";
        String _vsUserAnnee2= "(SELECT _pt.annee FROM promotion _pt JOIN profil _pr ON _pt.idpromotion=_pr.idpromotion WHERE _pr.idutilisateur=" + refuserConnecte + " LIMIT 1)";
        String _vsPromoCond2= "(_pv.typecible='PROMOTION' AND ((_pv.anneedirection='+' AND " + _vsUserAnnee2 + ">=_pv.anneeref) OR (_pv.anneedirection='-' AND " + _vsUserAnnee2 + "<=_pv.anneeref)))";
        String _vsSpecExist2 = "EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND _pv.typecible='SPECIALITE' AND _pv.idref IN " + _vsSpec2 + ")";
        String _vsPromoExist2= "EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND " + _vsPromoCond2 + ")";
        String _vsParcExist2 = "EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND _pv.typecible='PARCOURS' AND _pv.idref=" + _vsParc2 + ")";
        String _visW2 =
            " AND (NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication)"
            + " OR (COALESCE(p.logique_visibilite,'OR')='OR' AND ("
            + _vsSpecExist2 + " OR " + _vsPromoExist2 + " OR " + _vsParcExist2
            + "))"
            + " OR (p.logique_visibilite='AND'"
            + " AND (NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND _pv.typecible='SPECIALITE') OR " + _vsSpecExist2 + ")"
            + " AND (NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND _pv.typecible='PROMOTION') OR " + _vsPromoExist2 + ")"
            + " AND (NOT EXISTS (SELECT 1 FROM publicationvisibilite _pv WHERE _pv.idpublication=p.idpublication AND _pv.typecible='PARCOURS') OR " + _vsParcExist2 + ")))";
        // Filtre hashtag — typepub suit le flag lier comme les autres
        java.util.List _fConds = new java.util.ArrayList();
        if (!filterSpec.isEmpty())
            _fConds.add("EXISTS (SELECT 1 FROM publicationhashtag _ph WHERE _ph.idpublication=p.idpublication AND _ph.typetag='SPECIALITE' AND _ph.idref='" + filterSpec + "')");
        if (!filterParc.isEmpty())
            _fConds.add("EXISTS (SELECT 1 FROM publicationhashtag _ph WHERE _ph.idpublication=p.idpublication AND _ph.typetag='PARCOURS' AND _ph.idref='" + filterParc + "')");
        if (!filterPromo.isEmpty() && filterPromo.matches("\\d{4}[+-]")) {
            int _fpAnnee = Integer.parseInt(filterPromo.substring(0,4));
            char _fpDir  = filterPromo.charAt(4);
            String _fpUserAnnee = "(SELECT _pt.annee FROM promotion _pt JOIN profil _pr ON _pt.idpromotion=_pr.idpromotion WHERE _pr.idutilisateur=" + refuserConnecte + " LIMIT 1)";
            String _fpCmp = (_fpDir == '+') ? ">=" : "<=";
            _fConds.add("EXISTS (SELECT 1 FROM publicationhashtag _ph WHERE _ph.idpublication=p.idpublication AND _ph.typetag='PROMOTION' AND (SELECT _pt2.annee FROM promotion _pt2 WHERE _pt2.idpromotion=_ph.idref LIMIT 1)" + _fpCmp + _fpAnnee + ")");
        }
        if (!filterTypepub.isEmpty())
            _fConds.add("p.idtypepublication='" + filterTypepub + "'");
        String _hashW = "";
        if (_fConds.size() == 1) {
            _hashW = " AND " + _fConds.get(0);
        } else if (_fConds.size() > 1) {
            String _join = "1".equals(filterLier) ? " AND " : " OR ";
            StringBuilder _sb = new StringBuilder(" AND (");
            for (int _ci = 0; _ci < _fConds.size(); _ci++) {
                if (_ci > 0) _sb.append(_join);
                _sb.append(_fConds.get(_ci));
            }
            _sb.append(")");
            _hashW = _sb.toString();
        }
        String _sC =
            "COALESCE((SELECT COUNT(*) FROM publicationreaction pr WHERE pr.idpublication=p.idpublication),0)*2"
            + "+COALESCE((SELECT COUNT(*) FROM publicationcommentaire pc WHERE pc.idpublication=p.idpublication AND pc.etat=1),0)*3"
            + "-COALESCE((SELECT pv.nbvue FROM publicationvue pv WHERE pv.idpublication=p.idpublication AND pv.idutilisateur=" + refuserConnecte + "),0)*4"
            + "+CASE WHEN p.daty::date=CURRENT_DATE THEN 15 WHEN p.daty::date>=CURRENT_DATE-7 THEN 8 WHEN p.daty::date>=CURRENT_DATE-30 THEN 3 ELSE 0 END";
        // --- Filtre utilisateurs bannis ---
        String _banW = " AND p.idutilisateur NOT IN (SELECT refuser FROM utilisateur WHERE estactif = 0)";
        String _pSql =
            "SELECT sub.idpublication, sub.score FROM ("
            + "  SELECT p.idpublication,(" + _sC + ") AS score FROM publication p WHERE p.etat=1" + _banW + _visW2 + _hashW
            + ") sub WHERE sub.score < " + cursorScore
            + " OR (sub.score = " + cursorScore + " AND sub.idpublication < '" + cursorId + "')"
            + " ORDER BY sub.score DESC, sub.idpublication DESC LIMIT 10";
        java.util.List _pids = new java.util.ArrayList();
        java.util.List _pscores = new java.util.ArrayList();
        java.sql.Statement _st = null; java.sql.ResultSet _rs = null;
        try {
            _st = conn.createStatement(); _rs = _st.executeQuery(_pSql);
            while (_rs.next()) { _pids.add(_rs.getString("idpublication")); _pscores.add(new Integer(_rs.getInt("score"))); }
        } finally {
            if (_rs != null) try { _rs.close(); } catch (Exception _x) {}
            if (_st != null) try { _st.close(); } catch (Exception _x) {}
        }
        Publication[] pubs = new Publication[_pids.size()];
        for (int _i = 0; _i < _pids.size(); _i++) {
            Publication[] _pa = (Publication[]) CGenUtil.rechercher(new Publication(), null, null, conn, " and idpublication='" + _pids.get(_i) + "'");
            pubs[_i] = (_pa != null && _pa.length > 0) ? _pa[0] : new Publication();
        }
        // --- Curseur suivant ---
        String nextId    = "";
        int    nextScore = 0;
        boolean hasMore  = (_pids.size() == 10);
        if (!_pids.isEmpty()) {
            nextId    = (String) _pids.get(_pids.size()-1);
            nextScore = ((Integer) _pscores.get(_pscores.size()-1)).intValue();
        }
%>
<%-- Element meta : contient le prochain curseur, lu par le JS avant injection --%>
<div id="feed-meta-new" style="display:none"
     data-score="<%= nextScore %>"
     data-id="<%= nextId %>"
     data-has-more="<%= hasMore %>"
     data-filter-spec="<%= filterSpec %>"
     data-filter-parc="<%= filterParc %>"
     data-filter-promo="<%= filterPromo %>"
     data-filter-typepub="<%= filterTypepub %>"
     data-filter-lier="<%= filterLier %>"></div>
<%
        // --- Passer les donnees au composant publication.jsp ---
        request.setAttribute("_pub_pubs", pubs);
        request.setAttribute("_pub_userNames", userNames);
        request.setAttribute("_pub_userPhotos", userPhotos);
        request.setAttribute("_pub_userProfils", userProfils);
        request.setAttribute("_pub_reactTypes", reactTypes);
        request.setAttribute("_pub_typesPub", typesPub);
        request.setAttribute("_pub_refuser", new Integer(refuserConnecte));
        request.setAttribute("_pub_initialConnecte", initialConnecte);
        request.setAttribute("_pub_connPhotoUrl", _connPhotoUrl);
        request.setAttribute("_pub_ctx", ctx);
        request.setAttribute("_pub_conn", conn);
        request.setAttribute("_pub_cardsOnly", Boolean.TRUE);
%>
<jsp:include page="../../publication.jsp" />
<%
    } catch (Exception e) {
        e.printStackTrace();
        // En cas d'erreur : retourner silencieusement (le JS ne recharge rien)
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
