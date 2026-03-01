<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.PublicationActionService" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    try {
        UserEJB uEJB = (UserEJB) session.getAttribute("u");
        if (uEJB == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        int refuser = uEJB.getUser().getRefuser();
        String idpuborigine = request.getParameter("idpublication");
        String description = request.getParameter("description");
        if (idpuborigine == null || idpuborigine.trim().isEmpty()) { out.print("{\"success\":false,\"error\":\"Identifiant de publication manquant\"}"); return; }
        out.print(PublicationActionService.partagerPublication(refuser, idpuborigine.trim(), description != null ? description : ""));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
