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
        String idexperience = request.getParameter("idexperience");
        String entreprise   = request.getParameter("entreprise");
        String debut        = request.getParameter("debut");
        String fin          = request.getParameter("fin");
        String description  = request.getParameter("description");
        String idposte      = request.getParameter("idposte");
        out.print(ProfilService.crudExperience(refuser, action, idexperience, entreprise, debut, fin, description, idposte));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = (e.getMessage() != null ? e.getMessage().replace("\"","'").replace("\n"," ") : "Erreur inconnue");
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>