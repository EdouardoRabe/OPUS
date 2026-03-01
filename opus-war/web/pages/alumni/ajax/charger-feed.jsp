<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.FeedHtmlService" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.Typepublication" %>
<%@ page import="java.util.Map" %>
<%
    // =========================================================
    // AJAX : Chargement progressif du fil d'actualite (score-based)
    // =========================================================
    UserEJB uFeed = (UserEJB) session.getAttribute("u");
    if (uFeed == null) { return; }

    MapUtilisateur mapFeed = uFeed.getUser();
    int refuserConnecte   = mapFeed.getRefuser();
    String nomConnecte    = mapFeed.getNomuser() != null ? mapFeed.getNomuser() : "";
    String ctx            = request.getContextPath();

    // --- Lecture et sanitisation des parametres curseur ---
    String cursorScoreStr = request.getParameter("cursor_score");
    String cursorIdRaw    = request.getParameter("cursor_id");

    if (cursorIdRaw == null || cursorIdRaw.trim().isEmpty()) { return; }

    String cursorId = cursorIdRaw.replaceAll("[^A-Za-z0-9]", "");
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
    filterPromo   = filterPromo.replaceAll("[^0-9+\\-]","");
    filterTypepub = filterTypepub.replaceAll("[^A-Za-z0-9]","");

    try {
        // Appel du service (gere sa propre connexion)
        Map data = FeedHtmlService.chargerFeed(refuserConnecte, nomConnecte, ctx,
                cursorScore, cursorId, filterSpec, filterParc, filterPromo, filterTypepub, filterLier);

        Publication[] pubs = (Publication[]) data.get("pubs");
        String nextId      = (String) data.get("nextId");
        int nextScore      = ((Integer) data.get("nextScore")).intValue();
        boolean hasMore    = ((Boolean) data.get("hasMore")).booleanValue();
%>
<%-- Element meta : contient le prochain curseur, lu par le JS avant injection --%>
<div id="feed-meta-new" style="display:none"
     data-score="<%= nextScore %>"
     data-id="<%= nextId %>"
     data-has-more="<%= hasMore %>"
     data-filter-spec="<%= data.get("filterSpec") %>"
     data-filter-parc="<%= data.get("filterParc") %>"
     data-filter-promo="<%= data.get("filterPromo") %>"
     data-filter-typepub="<%= data.get("filterTypepub") %>"
     data-filter-lier="<%= data.get("filterLier") %>"></div>
<%
        // --- Passer les donnees au composant publication.jsp ---
        request.setAttribute("_pub_pubs", pubs);
        request.setAttribute("_pub_userNames", data.get("userNames"));
        request.setAttribute("_pub_userPhotos", data.get("userPhotos"));
        request.setAttribute("_pub_userProfils", data.get("userProfils"));
        request.setAttribute("_pub_reactTypes", data.get("reactTypes"));
        request.setAttribute("_pub_typesPub", data.get("typesPub"));
        request.setAttribute("_pub_refuser", new Integer(refuserConnecte));
        request.setAttribute("_pub_initialConnecte", data.get("initialConnecte"));
        request.setAttribute("_pub_connPhotoUrl", data.get("connPhotoUrl"));
        request.setAttribute("_pub_ctx", ctx);
        request.setAttribute("_pub_cardsOnly", Boolean.TRUE);
        // Donnees pre-chargees par publication
        request.setAttribute("_pub_pubMedias", data.get("pubMedias"));
        request.setAttribute("_pub_pubReactions", data.get("pubReactions"));
        request.setAttribute("_pub_pubComments", data.get("pubComments"));
        request.setAttribute("_pub_pubIdents", data.get("pubIdentifications"));
        request.setAttribute("_pub_pubSaved", data.get("pubSaved"));
        request.setAttribute("_pub_origPubs", data.get("origPubs"));
        request.setAttribute("_pub_origMedias", data.get("origMedias"));
%>
<jsp:include page="../../publication.jsp" />
<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>