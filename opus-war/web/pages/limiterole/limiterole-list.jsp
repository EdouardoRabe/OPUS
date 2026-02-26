<%@page import="affichage.PageRecherche"%>
<%@ page import="alumni.Limiterole" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="utilitaire.UtilDB" %>

<% try {
    Limiterole t = new Limiterole();
    String listeCrt[] = {"idrole"};
    String listeInt[] = {};
    String libEntete[] = {"idrole", "maxpublicationparjour"};
    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Limites de publication par r&ocirc;le");
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("limiterole/limiterole-list.jsp");
    pr.getFormu().getChamp("idrole").setLibelle("R&ocirc;le");
    pr.setNpp(50);
    String[] colSomme = {};
    pr.creerObjetPage(libEntete, colSomme);

    Object[] rawList = pr.getListe();
    alumni.Limiterole[] allItems;
    if (rawList != null) {
        allItems = new alumni.Limiterole[rawList.length];
        for (int x = 0; x < rawList.length; x++) allItems[x] = (alumni.Limiterole) rawList[x];
    } else {
        allItems = new alumni.Limiterole[0];
    }
    int totalItems = allItems.length;

    String lienBase = (String) session.getValue("lien");
    String lienTableau[] = {lienBase + "?but=limiterole/limiterole-modif.jsp"};
    String colonneLien[] = {"idrole"};
    String[] attributLien = {"idrole"};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setAttLien(attributLien);
    pr.getTableau().setColonneLien(colonneLien);
    String libEnteteAffiche[] = {"R&ocirc;le", "Max publications / jour"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);
%>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <i class="fa fa-sliders" style="color:var(--itu-blue);font-size:1.1rem;margin-right:10px;"></i>
        Limites de publication par r&ocirc;le
    </h1>
    <div style="display:flex;align-items:center;gap:1rem;">
        <span style="font-size:0.85rem;color:var(--gray-500);">
            <strong style="color:var(--itu-dark);"><%= totalItems %></strong> r&egrave;gle(s)
        </span>
    </div>
</div>

<!-- ═══ SEARCH & FILTER ═══ -->
<div class="custom-card no-hover" style="margin-bottom:20px;padding:1.25rem 1.5rem;">
    <form action="<%= pr.getLien() %>?but=<%= pr.getApres() %>" method="post">
        <div style="display:flex;gap:0.75rem;flex-wrap:wrap;align-items:center;">
            <input class="form-control-custom"
                   type="text"
                   name="idrole"
                   value="<%= pr.getFormu().getChamp("idrole").getValeur() != null ? pr.getFormu().getChamp("idrole").getValeur() : "" %>"
                   placeholder="Rechercher par r&ocirc;le (ex: alu, etu, md)..."
                   style="flex:1;min-width:200px;">
            <button class="btn btn-primary" type="submit" style="padding-left:1.5rem;padding-right:1.5rem;">
                <i class="fa fa-search" style="margin-right:6px;"></i>Chercher
            </button>
        </div>
    </form>
</div>

<!-- ═══ STYLES ═══ -->
<style>
.lr-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1.25rem;
    margin-top: 0.5rem;
}
.lr-card {
    background: var(--white);
    border: 1px solid var(--gray-200);
    border-radius: 14px;
    overflow: hidden;
    box-shadow: 0 2px 10px rgba(0,0,0,0.06);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    position: relative;
}
.lr-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 20px rgba(0,0,0,0.10);
}
.lr-card-header {
    padding: 1.25rem 1.5rem;
    display: flex;
    align-items: center;
    gap: 1rem;
}
.lr-icon {
    width: 48px; height: 48px;
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.3rem; color: #fff;
    flex-shrink: 0;
}
.lr-card-body {
    padding: 0 1.5rem 1.25rem;
}
.lr-role-name {
    font-size: 1.05rem;
    font-weight: 700;
    color: var(--itu-dark);
    text-transform: uppercase;
    letter-spacing: 0.03em;
}
.lr-limit-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 0.4rem 0.85rem;
    border-radius: 20px;
    font-size: 0.82rem;
    font-weight: 600;
}
.lr-limit-badge.blocked {
    background: #fef2f2;
    color: #dc2626;
    border: 1px solid #fecaca;
}
.lr-limit-badge.limited {
    background: #fffbeb;
    color: #d97706;
    border: 1px solid #fde68a;
}
.lr-limit-badge.unlimited {
    background: #f0fdf4;
    color: #16a34a;
    border: 1px solid #bbf7d0;
}
.lr-card-actions {
    padding: 0.75rem 1.5rem;
    border-top: 1px solid var(--gray-100);
    display: flex;
    justify-content: flex-end;
}
</style>

<!-- ═══ CARDS GRID ═══ -->
<div class="lr-grid">
<%
    String[] cardColors = {"#1E40AF", "#0F766E", "#059669", "#8B5CF6", "#0E7490", "#D97706"};
    String[] cardIcons  = {"fa fa-shield", "fa fa-graduation-cap", "fa fa-user-md", "fa fa-users", "fa fa-star", "fa fa-key"};

    for (int i = 0; i < allItems.length; i++) {
        alumni.Limiterole lr = allItems[i];
        String role = lr.getIdrole() != null ? lr.getIdrole() : "";
        int maxPub = lr.getMaxpublicationparjour();
        String bgColor = cardColors[i % cardColors.length];
        String iconClass = cardIcons[i % cardIcons.length];

        String badgeClass, badgeText, badgeIcon;
        if (maxPub == 0) {
            badgeClass = "blocked";
            badgeText = "Interdit de publier";
            badgeIcon = "fa fa-ban";
        } else if (maxPub < 0) {
            badgeClass = "unlimited";
            badgeText = "Illimit&eacute;";
            badgeIcon = "fa fa-infinity";
        } else {
            badgeClass = "limited";
            badgeText = maxPub + " publication(s) / jour";
            badgeIcon = "fa fa-tachometer";
        }
%>
    <div class="lr-card">
        <div class="lr-card-header">
            <div class="lr-icon" style="background:<%= bgColor %>;">
                <i class="<%= iconClass %>"></i>
            </div>
            <div>
                <div class="lr-role-name"><%= role %></div>
                <span class="lr-limit-badge <%= badgeClass %>">
                    <i class="<%= badgeIcon %>"></i> <%= badgeText %>
                </span>
            </div>
        </div>
        <div class="lr-card-actions">
            <a href="<%= lienBase %>?but=limiterole/limiterole-modif.jsp&idrole=<%= role %>"
               class="btn btn-ghost" style="font-size:0.82rem;display:inline-flex;align-items:center;gap:5px;">
                <i class="fa fa-pencil"></i> Modifier
            </a>
        </div>
    </div>
<%  } %>
</div>

<% if (totalItems == 0) { %>
<div class="custom-card no-hover" style="text-align:center;padding:3rem;">
    <i class="fa fa-inbox" style="font-size:2.5rem;color:var(--gray-300);"></i>
    <p style="margin-top:1rem;color:var(--gray-500);font-size:0.92rem;">Aucune r&egrave;gle de limite trouv&eacute;e.</p>
</div>
<% } %>

<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='custom-card no-hover' style='color:#dc2626;padding:1.5rem;'>Erreur : " + e.getMessage() + "</div>");
} %>
