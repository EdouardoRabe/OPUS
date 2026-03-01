<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.ReactionService" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        String idpub = request.getParameter("idpublication");
        String idreaction = request.getParameter("idreactiontype");
        if (idpub == null || idreaction == null) { out.print("{\"success\":false,\"error\":\"Parametres manquants\"}"); return; }
        int refuser = u.getUser().getRefuser();
        out.print(ReactionService.reagirPublication(refuser, idpub, idreaction));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
