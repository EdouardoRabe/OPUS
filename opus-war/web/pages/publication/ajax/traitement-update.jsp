<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.PublicationAdminService" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    request.setCharacterEncoding("UTF-8");
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        int refUser = u.getUser().getRefuser();
        String userId = String.valueOf(refUser);
        String idpublication     = request.getParameter("idpublication");
        String descritpion       = request.getParameter("descritpion");
        String idtypepublication = request.getParameter("idtypepublication");
        out.print(PublicationAdminService.modifier(refUser, userId, idpublication, descritpion, idtypepublication));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
