<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.CommentaireService" %>
<%
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        int refuser = u.getUser().getRefuser();
        String idpub = request.getParameter("idpublication");
        out.print(CommentaireService.chargerCommentaires(refuser, idpub));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
