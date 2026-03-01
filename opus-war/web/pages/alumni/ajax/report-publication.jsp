<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.PublicationActionService" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        String idpub = request.getParameter("idpublication");
        String description = request.getParameter("description");
        String[] typesSignalement = request.getParameterValues("typesignalement");
        if (idpub == null || idpub.trim().isEmpty()) { out.print("{\"success\":false,\"error\":\"idpublication manquant\"}"); return; }
        if (typesSignalement == null || typesSignalement.length == 0) { out.print("{\"success\":false,\"error\":\"Veuillez selectionner au moins un motif\"}"); return; }
        int refuser = u.getUser().getRefuser();
        out.print(PublicationActionService.reportPublication(refuser, idpub, description, typesSignalement));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>