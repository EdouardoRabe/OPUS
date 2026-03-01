<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.ProfilService" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        int refuser = u.getUser().getRefuser();
        String action       = request.getParameter("action");
        String id           = request.getParameter("id");
        String idprofil     = request.getParameter("idprofil");
        String latitude     = request.getParameter("latitude");
        String longitude    = request.getParameter("longitude");
        out.print(ProfilService.crudLocalisation(refuser, action, id, idprofil, latitude, longitude));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = (e.getMessage() != null ? e.getMessage().replace("\"","'").replace("\n"," ") : "Erreur inconnue");
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>