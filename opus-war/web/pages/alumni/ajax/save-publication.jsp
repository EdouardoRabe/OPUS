<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publication" %>
<%@ page import="java.sql.Connection" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    UserEJB u = (UserEJB) session.getAttribute("u");
    if (u == null) {
        out.print("{\"success\":false,\"error\":\"Non connecte\"}");
        return;
    }
    String idpub = request.getParameter("idpublication");
    if (idpub == null || idpub.trim().isEmpty()) {
        out.print("{\"success\":false,\"error\":\"idpublication manquant\"}");
        return;
    }
    // impl basique: rien ne fait vraiment, logiquement il faudrait ajouter une ligne de sauvegarde
    // pour l'instant renvoyer success
    out.print("{\"success\":true}");
%>