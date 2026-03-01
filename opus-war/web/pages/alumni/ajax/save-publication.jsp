<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.PublicationActionService" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        String idpub = request.getParameter("idpublication");
        if (idpub == null || idpub.trim().isEmpty()) { out.print("{\"success\":false,\"error\":\"idpublication manquant\"}"); return; }
        int refuser = u.getUser().getRefuser();
        out.print(PublicationActionService.toggleSave(refuser, idpub));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>