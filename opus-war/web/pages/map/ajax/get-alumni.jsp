<%@ page pageEncoding="UTF-8" %>
<%@ page import="alumni.MapService" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    String ctx = request.getContextPath();
    try {
        out.print(MapService.getAlumni(ctx));
    } catch (Exception e) {
        e.printStackTrace();
        out.print("[]");
    }
%>
