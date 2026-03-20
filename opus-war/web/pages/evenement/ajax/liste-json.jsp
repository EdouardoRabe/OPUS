<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.EvenementService" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        int currentUserId = (u != null) ? u.getUser().getRefuser() : 0;
        String pStart = request.getParameter("start");
        String pEnd   = request.getParameter("end");
        out.print(EvenementService.listeJson(currentUserId, pStart, pEnd));
    } catch (Exception e) {
        e.printStackTrace();
        out.print("[]");
    }
%>
