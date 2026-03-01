<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.LimiteroleService" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        String userId = String.valueOf(u.getUser().getRefuser());
        String idrole = request.getParameter("idrole");
        String maxpubStr = request.getParameter("maxpublicationparjour");
        out.print(LimiteroleService.modifier(userId, idrole, maxpubStr));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
