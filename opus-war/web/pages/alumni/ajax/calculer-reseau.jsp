<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.ReseauService" %>
<%
    try {
        UserEJB uR = (UserEJB) session.getAttribute("u");
        if (uR == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        MapUtilisateur mapR = uR.getUser();
        int refuserConnecte = mapR.getRefuser();
        String nomuser = mapR.getNomuser();
        out.print(ReseauService.calculerReseau(refuserConnecte, nomuser));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"","'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
