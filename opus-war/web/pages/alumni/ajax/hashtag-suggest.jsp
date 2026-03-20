<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.HashtagSuggestService" %>
<%
    response.setHeader("Cache-Control", "no-store");
    UserEJB _u = (UserEJB) session.getAttribute("u");
    if (_u == null) { out.print("[]"); return; }
    String _q = request.getParameter("q");
    try {
        out.print(HashtagSuggestService.suggest(_q));
    } catch (Exception e) {
        e.printStackTrace();
        out.print("[]");
    }
%>
