<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.IdentificationService" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    request.setCharacterEncoding("UTF-8");
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        int refuser = u.getUser().getRefuser();
        String idpub = request.getParameter("idpublication");
        String idsUtilisateurs = request.getParameter("idutilisateurs");
        out.print(IdentificationService.identifier(refuser, idpub, idsUtilisateurs));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
