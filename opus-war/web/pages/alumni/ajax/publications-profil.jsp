<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.FeedHtmlService" %>
<%@ page import="alumni.Publication" %>
<%@ page import="java.util.Map" %>
<%!
    private static String pvEsc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
    }
%>
<%
    /* ============================================================
       AJAX - Publications d'un utilisateur pour la page profil
       ============================================================ */
    UserEJB uEJB = (UserEJB) session.getAttribute("u");
    if (uEJB == null) { out.print("<p style='color:#888'>Connectez-vous pour voir les publications.</p>"); return; }

    MapUtilisateur mapPP = uEJB.getUser();
    String ctx = request.getContextPath();
    int myRefuser = mapPP.getRefuser();
    String nomConnecte = mapPP.getNomuser() != null ? mapPP.getNomuser() : "";

    String paramIdUser  = request.getParameter("idutilisateur");
    String paramIdProfil = request.getParameter("idprofil");
    String cursorId      = request.getParameter("cursor_id");

    try {
        Map data = FeedHtmlService.publicationsProfil(myRefuser, nomConnecte, ctx,
                paramIdUser, paramIdProfil, cursorId);

        if (data.containsKey("userNotFound")) {
            out.print("<p style='color:#888'>Utilisateur introuvable.</p>");
            return;
        }
        if (data.containsKey("empty")) {
            out.print("<p style='color:#aaa;font-size:13px;padding:12px 0;text-align:center;'>Aucune publication.</p>");
            return;
        }

        request.setAttribute("_pub_pubs", data.get("pubs"));
        request.setAttribute("_pub_userNames", data.get("userNames"));
        request.setAttribute("_pub_userPhotos", data.get("userPhotos"));
        request.setAttribute("_pub_userProfils", data.get("userProfils"));
        request.setAttribute("_pub_userBanned", data.get("userBanned"));
        request.setAttribute("_pub_reactTypes", data.get("reactTypes"));
        request.setAttribute("_pub_typesPub", data.get("typesPub"));
        request.setAttribute("_pub_refuser", new Integer(myRefuser));
        request.setAttribute("_pub_initialConnecte", data.get("initialConnecte"));
        request.setAttribute("_pub_connPhotoUrl", data.get("connPhotoUrl"));
        request.setAttribute("_pub_ctx", ctx);
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
        // Marqueur pagination
        boolean hasMore = ((Boolean) data.get("hasMore")).booleanValue();
        if (hasMore) {
            String lastId = (String) data.get("lastPubId");
%>
<div class="ppub-load-more-wrap" style="text-align:center;margin:8px 0 16px;">
    <button class="ppub-load-more-btn" style="background:transparent;border:1.5px solid #0a66c2;color:#0a66c2;border-radius:20px;padding:7px 22px;font-size:13px;font-weight:700;cursor:pointer;" onmouseover="this.style.background='#0a66c2';this.style.color='#fff';" onmouseout="this.style.background='transparent';this.style.color='#0a66c2';" onclick="ppubLoadMore(this,'<%= paramIdUser != null ? paramIdUser : "" %>','<%= paramIdProfil != null ? paramIdProfil.replace("'","\\'") : "" %>','<%= lastId %>')">
        Voir plus de publications
    </button>
</div>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.print("<p style='color:red;font-size:13px;'>Erreur chargement publications: " + pvEsc(e.getMessage()) + "</p>");
    }
%>