<%@page import="affichage.PageRecherche"%>
<%@ page import="alumni.Historique" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.*" %>
<%@ page import="utilitaire.UtilDB" %>

<% try {
    Historique t = new Historique();
    String listeCrt[] = {"idhistorique", "datehistorique", "action", "objet", "idutilisateur"};
    String listeInt[] = {};
    String libEntete[] = {"idhistorique", "datehistorique", "heure", "action", "objet", "idutilisateur", "refobjet"};
    
    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Historique des actions");
    pr.setUtilisateur((user.UserEJB) session.getAttribute("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("dashboard/historique-list.jsp");
    
    pr.getFormu().getChamp("idhistorique").setLibelle("ID");
    pr.getFormu().getChamp("datehistorique").setLibelle("Date");
    pr.getFormu().getChamp("action").setLibelle("Action");
    pr.getFormu().getChamp("objet").setLibelle("Objet");
    pr.getFormu().getChamp("idutilisateur").setLibelle("Utilisateur");
    
    pr.setNpp(100);
    String[] colSomme = {};
    pr.creerObjetPage(libEntete, colSomme);
%>

<div class="page-header-top">
    <h1 class="page-title-lg">
        <i class="fa fa-history" style="color:var(--itu-blue);font-size:1.1rem;margin-right:10px;"></i>
        Logs Historique
    </h1>
    <div style="display:flex;align-items:center;gap:1rem;">
        <span style="font-size:0.85rem;color:var(--gray-500);">
            <strong><%= pr.getListe().length %></strong> entr&eacute;es trouv&eacute;es
        </span>
    </div>
</div>

<div class="custom-card no-hover" style="margin-bottom:20px;padding:1.25rem 1.5rem;">
    <form action="<%= pr.getLien() %>?but=<%= pr.getApres() %>" method="post" name="recherche" id="recherche">
        <%= pr.getFormu().getHtmlEnsemble() %>
    </form>
</div>

<div class="custom-card no-hover" style="padding:0; overflow:hidden;">
    <% pr.getTableau().setLibelleAffiche(new String[]{"ID", "Date", "Heure", "Action", "Objet", "User", "Ref Objet"}); %>
    <%= pr.getTableau().getHtml() %>
</div>

<div class="specialite-pagination-wrap">
    <%= pr.getBasPage() %>
</div>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
