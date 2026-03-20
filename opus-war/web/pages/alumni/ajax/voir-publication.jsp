<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.FeedHtmlService" %>
<%@ page import="alumni.Publication" %>
<%@ page import="java.util.Map" %>
<%
    /* ============================================================
       AJAX : Charger UNE publication comme carte complete
       Parametre GET : idpublication
       ============================================================ */
    UserEJB uVP = (UserEJB) session.getAttribute("u");
    if (uVP == null) { out.print("<p style='color:#888'>Connectez-vous.</p>"); return; }

    MapUtilisateur mapVP = uVP.getUser();
    int refuserConnecte = mapVP.getRefuser();
    String nomConnecte  = mapVP.getNomuser() != null ? mapVP.getNomuser() : "";
    String ctx          = request.getContextPath();

    String idpub = request.getParameter("idpublication");
    if (idpub == null || idpub.trim().isEmpty()) { out.print("<p style='color:#888'>Publication introuvable.</p>"); return; }
    idpub = idpub.replaceAll("[^A-Za-z0-9]", "");

    try {
        Map data = FeedHtmlService.voirPublication(refuserConnecte, nomConnecte, ctx, idpub);

        if (data.containsKey("notFound")) {
            out.print("<p style='color:#888'>Publication introuvable.</p>");
            return;
        }

        request.setAttribute("_pub_pubs", data.get("pubs"));
        request.setAttribute("_pub_userNames", data.get("userNames"));
        request.setAttribute("_pub_userPhotos", data.get("userPhotos"));
        request.setAttribute("_pub_userProfils", data.get("userProfils"));
        request.setAttribute("_pub_userBanned", data.get("userBanned"));
        request.setAttribute("_pub_reactTypes", data.get("reactTypes"));
        request.setAttribute("_pub_typesPub", data.get("typesPub"));
        request.setAttribute("_pub_refuser", new Integer(refuserConnecte));
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
    } catch (Exception e) {
        e.printStackTrace();
        out.print("<p style='color:red;font-size:13px;'>Erreur: " + e.getMessage() + "</p>");
    }
%>