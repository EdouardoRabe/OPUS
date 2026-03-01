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
        String idprofil          = request.getParameter("idprofil");
        String idprofiltypestatut = request.getParameter("idprofiltypestatut");
        out.print(ProfilService.updateStatut(refuser, idprofil, idprofiltypestatut));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = (e.getMessage() != null ? e.getMessage().replace("\"","'").replace("\n"," ") : "Erreur inconnue");
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>