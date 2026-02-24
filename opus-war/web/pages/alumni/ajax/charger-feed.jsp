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
        if (allProfils != null) {
            for (int i = 0; i < allProfils.length; i++) {
                Integer _key = new Integer(allProfils[i].getIdutilisateur());
                userNames.put(_key, allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                if (allProfils[i].getPhotoProfil() != null && !allProfils[i].getPhotoProfil().trim().isEmpty())
                    userPhotos.put(_key, ctx + "/" + allProfils[i].getPhotoProfil().trim());
                if (allProfils[i].getIdprofil() != null && !allProfils[i].getIdprofil().trim().isEmpty())
                    userProfils.put(_key, allProfils[i].getIdprofil().trim());
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
        String _pSql =
            "SELECT sub.idpublication, sub.score FROM ("
            + "  SELECT p.idpublication,(" + _sC + ") AS score FROM publication p WHERE p.etat=1" + _visW2 + _hashW
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
        // --- Rendu de chaque carte publication ---
        for (int p = 0; p < pubs.length; p++) {
            Publication pub = pubs[p];
            String idpub  = pub.getIdpublication();
            String auteur = (String) userNames.get(new Integer(pub.getIdutilisateur()));
            if (auteur == null) auteur = "Utilisateur";

            // Initiales auteur
            String[] _partsA = auteur.trim().split("\\s+");
            String initA = String.valueOf(Character.toUpperCase(_partsA[0].charAt(0)));
            if (_partsA.length > 1) initA += Character.toUpperCase(_partsA[_partsA.length - 1].charAt(0));
            String _authorPhoto = (String) userPhotos.get(new Integer(pub.getIdutilisateur()));

            // Medias
            Media[] medias = (Media[]) CGenUtil.rechercher(
                    new Media(), null, null, conn, " and idpublication = '" + idpub + "'");
            if (medias == null) medias = new Media[0];

            // Reactions
            Publicationreaction[] reactions = (Publicationreaction[]) CGenUtil.rechercher(
                    new Publicationreaction(), null, null, conn, " and idpublication = '" + idpub + "'");
            if (reactions == null) reactions = new Publicationreaction[0];

            Map reactCounts = new HashMap();
            int totalReactions = 0;
            String myReaction  = "";
            for (int r = 0; r < reactions.length; r++) {
                String type    = reactions[r].getIdreactiontype();
                Integer cnt    = (Integer) reactCounts.get(type);
                reactCounts.put(type, cnt == null ? new Integer(1) : new Integer(cnt.intValue() + 1));
                totalReactions++;
                if (reactions[r].getIdutilisateur() == refuserConnecte) myReaction = type;
            }

            // Commentaires (compte seulement)
            Publicationcommentaire[] comments = (Publicationcommentaire[]) CGenUtil.rechercher(
                    new Publicationcommentaire(), null, null, conn,
                    " and idpublication = '" + idpub + "' and etat = 1");
            if (comments == null) comments = new Publicationcommentaire[0];
            int nbComm = comments.length;

            // Identifications / tags
            Identification[] identTags = (Identification[]) CGenUtil.rechercher(
                    new Identification(), null, null, conn, " and idpublication = '" + idpub + "'");
            if (identTags == null) identTags = new Identification[0];
            String taggedNames = "";
            if (identTags.length > 0) {
                StringBuffer sbTags = new StringBuffer();
                for (int tg = 0; tg < identTags.length; tg++) {
                    String tName = (String) userNames.get(new Integer(identTags[tg].getIdutilisateur()));
                    if (tName != null) {
                        if (sbTags.length() > 0) sbTags.append(", ");
                        sbTags.append(tName);
                    }
                }
                if (sbTags.length() > 0) taggedNames = sbTags.toString();
            }

            // Description echappee
            String desc     = pub.getDescritpion();
            String descSafe = "";
            if (desc != null) {
                descSafe = desc.replace("&", "&amp;").replace("<", "&lt;")
                        .replace(">", "&gt;").replace("\n", "<br>");
            }

            // ---- Partage: charger la pub originale si idpuborigine est defini ----
            boolean ffIsShared = pub.getIdpuborigine() != null && !pub.getIdpuborigine().trim().isEmpty();
            String ffOrigDesc = "", ffOrigAuteur = "", ffOrigDate = "", ffOrigMediaUrl = "", ffOrigTypePubLib = "";
            String ffOrigId = ffIsShared ? pub.getIdpuborigine().trim() : "";
            if (ffIsShared) {
                Publication[] ffOrigPubs = (Publication[]) CGenUtil.rechercher(
                    new Publication(), null, null, conn, " and idpublication = '" + ffOrigId + "'");
                if (ffOrigPubs != null && ffOrigPubs.length > 0) {
                    Publication ffOrig = ffOrigPubs[0];
                    String ffod = ffOrig.getDescritpion();
                    ffOrigDesc = ffod != null ? ffod.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\n","<br>") : "";
                    ffOrigDate = (ffOrig.getDaty() != null ? ffOrig.getDaty().toString() : "") + " \u00e0 " + (ffOrig.getHeure() != null ? ffOrig.getHeure() : "");
                    String ffOrigTypePubId = ffOrig.getIdtypepublication() != null ? ffOrig.getIdtypepublication() : "";
                    ffOrigTypePubLib = ffOrigTypePubId;
                    for (int t2 = 0; t2 < typesPub.length; t2++) {
                        if (typesPub[t2].getIdtypepublication().equals(ffOrigTypePubId)) { ffOrigTypePubLib = typesPub[t2].getLibelle(); break; }
                    }
                    String ffOA = (String) userNames.get(new Integer(ffOrig.getIdutilisateur()));
                    if (ffOA == null) {
                        ProfilLib[] ffOP = (ProfilLib[]) CGenUtil.rechercher(
                            new ProfilLib(), null, null, conn, " and refuser = " + ffOrig.getIdutilisateur());
                        if (ffOP != null && ffOP.length > 0) { ffOA = (ffOP[0].getNom() != null ? ffOP[0].getNom() : "") + (ffOP[0].getPrenom() != null ? " " + ffOP[0].getPrenom() : ""); }
                    }
                    ffOrigAuteur = ffOA != null ? ffOA.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;") : "Utilisateur";
                    Media[] ffOM = (Media[]) CGenUtil.rechercher(new Media(), null, null, conn, " and idpublication = '" + ffOrigId + "'");
                    if (ffOM != null && ffOM.length > 0 && ffOM[0].getMediaurl() != null) {
                        String omu = ffOM[0].getMediaurl();
                        ffOrigMediaUrl = omu.startsWith("http") ? omu : ctx + "/UploadDownloadFileServlet?fileName=" + java.net.URLEncoder.encode(omu, "UTF-8");
                    }
                } else { ffIsShared = false; }
            }

            // Libelle type publication
            String typePubLib = pub.getIdtypepublication() != null ? pub.getIdtypepublication() : "";
            for (int t = 0; t < typesPub.length; t++) {
                if (typesPub[t].getIdtypepublication().equals(typePubLib)) {
                    typePubLib = typesPub[t].getLibelle();
                    break;
                }
            }

            // Libelle de ma reaction active
            String myReactLib = "";
            for (int rt = 0; rt < reactTypes.length; rt++) {
                if (reactTypes[rt].getIdreactiontype().equals(myReaction)) {
                    myReactLib = reactTypes[rt].getLibelle();
                    break;
                }
            }
            // URL du profil auteur
            String ffProfileUrl;
            if (pub.getIdutilisateur() == refuserConnecte) {
                ffProfileUrl = ctx + "/pages/module.jsp?but=profil/voir.jsp";
            } else {
                String ffIdprofil = (String) userProfils.get(new Integer(pub.getIdutilisateur()));
                ffProfileUrl = (ffIdprofil != null && !ffIdprofil.isEmpty())
                    ? ctx + "/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp?idprofil=" + ffIdprofil
                    : "#";
            }
%>
<!-- ====== CARD PUBLICATION (chargement progressif) ====== -->
<div id="pub-<%= idpub %>" class="fa-post-card">

    <!-- EN-TETE -->
    <div class="fa-post-header">
        <a href="<%= ffProfileUrl %>" style="text-decoration:none;cursor:pointer;">
            <div class="fa-avatar fa-avatar--md" style="<%= _authorPhoto != null ? "background:transparent;" : "" %>cursor:pointer;"><% if (_authorPhoto != null) { %><img src="<%= _authorPhoto %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= initA %><% } %></div>
        </a>
        <div class="fa-post-meta">
            <!-- Menu 3 points -->
            <div class="pub-menu">
                <button class="pub-menu-btn" onclick="togglePubMenu(this,event)" title="Plus d'options"><i class="bi bi-three-dots-vertical"></i></button>
                <div class="pub-menu-dropdown">
                    <button class="pub-menu-item" onclick="savePublication('<%= idpub %>')">
                        <i class="bi bi-bookmark"></i> Enregistrer
                    </button>
                    <button class="pub-menu-item" onclick="reportPublication('<%= idpub %>')">
                        <i class="bi bi-flag"></i> Signaler
                    </button>
                </div>
            </div>
            <div class="fa-post-author">
                <a href="<%= ffProfileUrl %>" style="text-decoration:none;color:inherit;cursor:pointer;"><strong style="cursor:pointer;"><%= auteur %></strong></a>
                <% if (!taggedNames.isEmpty()) { %>
                <span class="fa-post-with">avec <strong><%= taggedNames %></strong></span>
                <% } %>
            </div>
            <div class="fa-post-date">
                <%= pub.getDaty() %>&nbsp;&agrave;&nbsp;<%= pub.getHeure() != null ? pub.getHeure() : "" %>
                <span class="fa-type-badge"><%= typePubLib %></span>
            </div>
        </div>
    </div>

    <!-- CORPS -->
    <div class="fa-post-body">
        <% if (descSafe != null && !descSafe.isEmpty()) { %>
        <p class="fa-post-text"><%= descSafe %></p>
        <% } %>
        <% for (int m = 0; m < medias.length; m++) {
            String mUrl = medias[m].getMediaurl();
            if (mUrl != null && !mUrl.startsWith("http")) {
                mUrl = ctx + "/UploadDownloadFileServlet?fileName=" + java.net.URLEncoder.encode(mUrl, "UTF-8");
            }
        %>
        <div class="fa-post-media">
            <img src="<%= mUrl %>" class="fa-post-img" alt="media" onclick="openMediaZoom(this.src)">
        </div>
        <% } %>

        <% if (ffIsShared) { %>
        <div class="fa-shared-embed">
            <div class="fa-shared-embed-header">
                <span class="fa-shared-embed-author"><%= ffOrigAuteur %></span>
                <span class="fa-shared-embed-date">&nbsp;&middot;&nbsp;<%= ffOrigDate %></span>
                <% if (!ffOrigTypePubLib.isEmpty()) { %><span class="fa-type-badge"><%= ffOrigTypePubLib %></span><% } %>
            </div>
            <% if (!ffOrigDesc.isEmpty()) { %><div class="fa-shared-embed-text"><%= ffOrigDesc %></div><% } %>
            <% if (!ffOrigMediaUrl.isEmpty()) { %><img src="<%= ffOrigMediaUrl %>" alt="" onclick="openMediaZoom(this.src)" style="width:100%;border-radius:8px;margin-top:6px;max-height:200px;object-fit:cover;cursor:pointer;"><% } %>
        </div>
        <% } %>
    </div>

    <!-- COMPTEURS -->
    <div class="fa-post-counters">
        <% if (totalReactions > 0) { %>
        <span class="fa-counter" style="cursor:pointer;" title="Voir les r&eacute;actions" onclick="openReactionDetails('<%= idpub %>')"><i class="bi bi-hand-thumbs-up-fill" style="color:var(--itu-blue,#008BFF);"></i>&nbsp;<%= totalReactions %></span>
        <% } else { %><span></span><% } %>
        <span id="nb-comm-<%= idpub %>" class="fa-counter fa-counter--link"
              onclick="toggleCommentaires('<%= idpub %>')">
            <%= nbComm > 0 ? nbComm + " commentaire" + (nbComm > 1 ? "s" : "") : "" %>
        </span>
    </div>

    <div class="fa-post-divider"></div>

    <!-- BARRE D'ACTIONS -->
    <div class="fa-post-actions">

        <!-- Reaction -->
        <div class="fa-reaction-wrap" id="reaction-wrap-<%= idpub %>">
            <button class="fa-action-btn <%= !myReaction.isEmpty() ? "fa-action-btn--reacted" : "" %>"
                    id="react-btn-<%= idpub %>"
                    onclick="toggleReactionBar('<%= idpub %>', event)">
                <i class="bi bi-hand-thumbs-up<%= !myReaction.isEmpty() ? "-fill" : "" %>"></i>
                <span><%= !myReaction.isEmpty() ? myReactLib : "J&apos;aime" %></span>
            </button>
            <div class="fa-reaction-bar" id="reaction-bar-<%= idpub %>">
                <% for (int rt = 0; rt < reactTypes.length; rt++) {
                    String rtId     = reactTypes[rt].getIdreactiontype();
                    String rtLib    = reactTypes[rt].getLibelle();
                    boolean isMyR   = rtId.equals(myReaction);
                    String rtLibLow = rtLib.toLowerCase();
                    String rtEmoji  = "\uD83D\uDC4D";
                    if (rtLibLow.contains("adore") || rtLibLow.contains("love"))         rtEmoji = "\u2764\uFE0F";
                    else if (rtLibLow.contains("haha") || rtLibLow.contains("humour"))    rtEmoji = "\uD83D\uDE02";
                    else if (rtLibLow.contains("surprise") || rtLibLow.contains("wow"))   rtEmoji = "\uD83D\uDE2E";
                    else if (rtLibLow.contains("triste") || rtLibLow.contains("sad"))     rtEmoji = "\uD83D\uDE22";
                    else if (rtLibLow.contains("grrr") || rtLibLow.contains("ang"))       rtEmoji = "\uD83D\uDE20";
                %>
                <button class="fa-reaction-item <%= isMyR ? "fa-reaction-item--active" : "" %>"
                        onclick="selectReaction('<%= idpub %>', '<%= rtId %>', event)" title="<%= rtLib %>">
                    <span class="fa-reaction-emoji"><%= rtEmoji %></span>
                    <span class="fa-reaction-label"><%= rtLib %></span>
                </button>
                <% } %>
            </div>
        </div>

        <!-- Commenter -->
        <button class="fa-action-btn" onclick="toggleCommentaires('<%= idpub %>')">
            <i class="bi bi-chat-left-text"></i>&nbsp;<span>Commenter</span>
        </button>

        <!-- Identifier (seulement pour l'auteur) -->
        <% if (pub.getIdutilisateur() == refuserConnecte) { %>
        <button class="fa-action-btn" onclick="toggleIdentifier('<%= idpub %>')">
            <i class="bi bi-tag"></i>&nbsp;<span>Identifier</span>
        </button>
        <% } %>

        <!-- Partager (non auteur, non partage) -->
        <% if (pub.getIdutilisateur() != refuserConnecte && !ffIsShared) { %>
        <%  String _ffShareAuteurEsc = auteur.replace("'","\\'").replace("\"","\\\"");
            String _ffShareTexteEsc  = descSafe.isEmpty() ? "" : descSafe.replace("<br>"," ").replace("'","\\'").replace("\"","\\\""); %>
        <button class="fa-action-btn" onclick="openShareModal('<%= idpub %>','<%= _ffShareAuteurEsc %>','<%= pub.getDaty() %>&nbsp;&agrave;&nbsp;<%= pub.getHeure() != null ? pub.getHeure() : "" %>','<%= _ffShareTexteEsc %>')">
            <i class="bi bi-share"></i>&nbsp;<span>Partager</span>
        </button>
        <% } %>
    </div>

    <!-- ZONE IDENTIFIER -->
    <div id="identifier-<%= idpub %>" style="display:none;" class="fa-tag-zone">
        <p class="fa-tag-zone-title">Identifier des personnes :</p>
        <input type="text" id="tag-search-<%= idpub %>" placeholder="Rechercher un utilisateur..."
               oninput="rechercherPourTag('<%= idpub %>')" class="fa-input">
        <div id="tag-suggestions-<%= idpub %>" class="fa-suggestions-list"></div>
        <div id="tag-selected-<%= idpub %>" class="fa-chips-row"></div>
        <button onclick="envoyerIdentifications('<%= idpub %>')" class="fa-btn-primary fa-btn-sm" style="margin-top:8px;">Valider</button>
    </div>

    <!-- ZONE COMMENTAIRES -->
    <div id="commentaires-<%= idpub %>" style="display:none;" class="fa-comments-zone">
        <div id="liste-comm-<%= idpub %>"></div>
        <div class="fa-comment-input-wrap">
            <div class="fa-avatar fa-avatar--sm"<%= !_connPhotoUrl.isEmpty() ? " style=\"background:transparent;\"" : "" %>><% if (!_connPhotoUrl.isEmpty()) { %><img src="<%= _connPhotoUrl %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= initialConnecte %><% } %></div>
            <div class="fa-comment-input-box">
                <input type="text" id="comm-text-<%= idpub %>"
                       placeholder="&Eacute;crire un commentaire... (@ pour mentionner)"
                       class="fa-comment-input"
                       oninput="onCommentInput(this, '<%= idpub %>')"
                       onkeydown="onCommentKeydown(event, '<%= idpub %>')">
                <input type="hidden" id="comm-mentions-<%= idpub %>" value="">
                <div id="mention-suggestions-<%= idpub %>" class="mention-dropdown" style="display:none;"></div>
                <button class="fa-comment-send-btn" onclick="ajouterCommentaire('<%= idpub %>')">
                    <i class="bi bi-send-fill"></i>
                </button>
            </div>
        </div>
    </div>

</div><!-- /fa-post-card -->
<%
        } // fin for pubs

    } catch (Exception e) {
        e.printStackTrace();
        // En cas d'erreur : retourner silencieusement (le JS ne recharge rien)
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
