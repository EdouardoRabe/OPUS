<%@ page pageEncoding="UTF-8" contentType="text/plain; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.PublicationActionService" %>
<%
    response.setHeader("Cache-Control", "no-store");
    try {
        UserEJB uVue = (UserEJB) session.getAttribute("u");
        if (uVue == null) { out.print("err"); return; }
        String idpub = request.getParameter("idpublication");
        if (idpub == null || idpub.trim().isEmpty()) { out.print("err"); return; }
        idpub = idpub.replaceAll("[^A-Za-z0-9]", "");
        if (idpub.isEmpty()) { out.print("err"); return; }
        int refuser = uVue.getUser().getRefuser();
        out.print(PublicationActionService.marquerVue(refuser, idpub));
    } catch (Exception e) {
        out.print("err");
    }
%>
