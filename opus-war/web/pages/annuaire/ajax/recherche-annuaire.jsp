<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="alumni.AnnuaireService" %>
<%
    try {
        String qNom        = request.getParameter("nom");
        String qPromotion  = request.getParameter("promotion");
        String qParcours   = request.getParameter("parcours");
        String qSpecialite = request.getParameter("specialite");
        String qEntreprise = request.getParameter("entreprise");
        String qPoste      = request.getParameter("poste");
        String qAnnee      = request.getParameter("annee");
        String pageParam   = request.getParameter("page");
        String ctx = request.getContextPath();
        out.print(AnnuaireService.rechercher(qNom, qPromotion, qParcours, qSpecialite,
            qEntreprise, qPoste, qAnnee, pageParam, ctx));
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>