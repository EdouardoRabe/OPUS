<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.ReactionService" %>
<%
    try {
        UserEJB uDR = (UserEJB) session.getAttribute("u");
        if (uDR == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        String _idpub = request.getParameter("idpublication");
        String ctx = request.getContextPath();
        int _myId = uDR.getUser().getRefuser();
        out.print(ReactionService.detailReactions(_myId, _idpub, ctx));
    } catch (Exception _ex) {
        _ex.printStackTrace();
        String msg = _ex.getMessage() != null ? _ex.getMessage().replace("\"", "'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
