<%@page import="affichage.PageRecherche"%>
<%@ page import="alumni.SpecialiteCpl" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.*" %>
<%@ page import="utilitaire.UtilDB" %>

<% try {
    SpecialiteCpl t = new SpecialiteCpl();
    String listeCrt[] = {"idspecialite", "libelle", "description"};
    String listeInt[] = {};
    String libEntete[] = {"idspecialite", "libelle", "description", "photohtml"};
    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Liste des sp&eacute;cialit&eacute;s");
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("specialite/specialite-list.jsp");
    pr.getFormu().getChamp("idspecialite").setLibelle("Id");
    pr.getFormu().getChamp("libelle").setLibelle("Libell&eacute;");
    pr.getFormu().getChamp("description").setLibelle("Description");
    pr.setNpp(50);
    String[] colSomme = {};
    pr.creerObjetPage(libEntete, colSomme);

    alumni.SpecialiteCpl[] listeAffiche = (alumni.SpecialiteCpl[]) pr.getListe();

    String lienBase = (String) session.getValue("lien");
    String lienTableau[] = {lienBase + "?but=specialite/specialite-fiche.jsp"};
    String colonneLien[] = {"idspecialite"};
    String[] attributLien = {"idspecialite"};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setAttLien(attributLien);
    pr.getTableau().setColonneLien(colonneLien);
    String libEnteteAffiche[] = {"Id", "Libell&eacute;", "Description", "Photo"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);

    /* Icon fallback arrays (cycled by index when no photo available) */
    String[] iconGradients = {
        "background:linear-gradient(135deg,#008BFF,#0056b3)",
        "background:linear-gradient(135deg,#5B23FF,#4a1cd9)",
        "background:linear-gradient(135deg,#ef4444,#dc2626)",
        "background:linear-gradient(135deg,#10b981,#059669)",
        "background:linear-gradient(135deg,#f59e0b,#d97706)",
        "background:linear-gradient(135deg,#8b5cf6,#7c3aed)",
        "background:linear-gradient(135deg,#06b6d4,#0891b2)",
        "background:linear-gradient(135deg,#E4FF30,#d4ef1f)"
    };
    String[] iconClasses = {
        "fa fa-code",
        "fa fa-paint-brush",
        "fa fa-shield",
        "fa fa-mobile",
        "fa fa-rocket",
        "fa fa-server",
        "fa fa-line-chart",
        "fa fa-database"
    };
    /* Last icon has dark text because lime bg is light */
    String[] iconColors = {"color:#fff","color:#fff","color:#fff","color:#fff","color:#fff","color:#fff","color:#fff","color:#362F4F"};
%>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <i class="fa fa-tags" style="color:var(--itu-blue);font-size:1.1rem;margin-right:10px;"></i>
        Sp&eacute;cialit&eacute;s Alumni
    </h1>
    <div style="display:flex;align-items:center;gap:1rem;">
        <span style="font-size:0.85rem;color:var(--gray-500);">
            <strong style="color:var(--itu-dark);"><%= pr.getListe().length %></strong> sp&eacute;cialit&eacute;s affich&eacute;es
        </span>
        <a class="btn btn-primary"
           href="<%= lienBase %>?but=specialite/specialite-saisie.jsp"
           style="display:inline-flex;align-items:center;gap:6px;white-space:nowrap;">
            <i class="fa fa-plus"></i> Ajouter
        </a>
    </div>
</div>

<!-- ═══ SEARCH & FILTER (APJ Standard) ═══ -->
<div class="custom-card no-hover" style="margin-bottom:20px;padding:1.25rem 1.5rem;">
    <form action="<%= pr.getLien() %>?but=<%= pr.getApres() %>" method="post" name="recherche" id="recherche">
        <%= pr.getFormu().getHtmlEnsemble() %>
    </form>
</div>

<%-- ═══ TRI & STATS (REMOVED) ═══ --%>

<!-- ═══ STYLES MENU KEBAB ═══ -->
<style>
.spe-card-menu {
    position: absolute;
    top: 10px;
    right: 12px;
    z-index: 10;
}
.spe-menu-btn {
    background: transparent;
    border: 1px solid #dde3ec;
    border-radius: 6px;
    width: 32px;
    height: 32px;
    cursor: pointer;
    font-size: 1.2rem;
    line-height: 1;
    color: #6b7280;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background .15s, border-color .15s;
    padding: 0;
}
.spe-menu-btn:hover {
    background: #f0f4ff;
    border-color: var(--itu-blue, #008BFF);
    color: var(--itu-blue, #008BFF);
}
.spe-menu-dropdown {
    display: none;
    position: absolute;
    top: calc(100% + 4px);
    right: 0;
    min-width: 160px;
    background: #fff;
    border: 1px solid #dde3ec;
    border-radius: 8px;
    box-shadow: 0 6px 20px rgba(0,0,0,.12);
    overflow: hidden;
    z-index: 100;
}
.spe-menu-dropdown.open {
    display: block;
}
.spe-menu-dropdown a {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 9px 14px;
    font-size: .85rem;
    color: #374151;
    text-decoration: none;
    transition: background .12s;
}
.spe-menu-dropdown a:hover {
    background: #f0f4ff;
    color: var(--itu-blue, #008BFF);
}
</style>

<!-- ═══ SPECIALITES GRID ═══ -->
<div class="specialities-grid">
<%
    for (int i = 0; i < listeAffiche.length; i++) {
        alumni.SpecialiteCpl spe = listeAffiche[i];
        int idx = i % 8;
        String photoHtml = spe.getPhotohtml();
        if (photoHtml != null) photoHtml = photoHtml.replace("__CTX__", request.getContextPath());
        boolean hasPhoto = (photoHtml != null && !photoHtml.trim().isEmpty());
%>
    <div class="custom-card no-hover speciality-card" style="position:relative;">

        <!-- Menu 3 points -->
        <div class="spe-card-menu">
            <button class="spe-menu-btn" onclick="toggleSpeMenu(this, event)" title="Options">&#8942;</button>
            <div class="spe-menu-dropdown" id="spe-dd-<%= i %>">
                <a href="<%= lienBase %>?but=specialite/specialite-fiche.jsp&amp;idspecialite=<%= spe.getIdspecialite() %>">
                    <i class="fa fa-info-circle"></i> Voir d&eacute;tails
                </a>
            </div>
        </div>

        <!-- Icone / Photo -->
        <div class="speciality-icon" style="<%= hasPhoto ? "background:var(--gray-100);" : iconGradients[idx] %>">
            <% if (hasPhoto) { %>
                <%= photoHtml %>
            <% } else { %>
                <i class="<%= iconClasses[idx] %>" style="<%= iconColors[idx] %>"></i>
            <% } %>
        </div>

        <!-- Titre -->
        <h3 class="speciality-title"><%= spe.getLibelle() != null ? spe.getLibelle() : "" %></h3>

        <!-- Description -->
        <p class="speciality-desc">
            <%
                String desc = spe.getDescription();
                if (desc != null && !desc.trim().isEmpty()) {
                    out.print(desc.length() > 80 ? desc.substring(0, 80) + "…" : desc);
                } else {
                    out.print("&mdash;");
                }
            %>
        </p>

        <div style="margin-top:auto; padding-top:15px; border-top:1px solid #f1f5f9;">
            <a href="<%= lienBase %>?but=specialite/specialite-fiche.jsp&amp;idspecialite=<%= spe.getIdspecialite() %>" 
               style="font-size:0.85rem; color:var(--itu-blue); font-weight:600; text-decoration:none;">
                Voir la fiche <i class="fa fa-arrow-right" style="font-size:0.75rem; margin-left:4px;"></i>
            </a>
        </div>

    </div>
<% } %>

<% if (listeAffiche.length == 0) { %>
    <div style="grid-column:1/-1;text-align:center;padding:3rem 1rem;color:var(--gray-500);">
        <i class="fa fa-tags" style="font-size:2.5rem;margin-bottom:1rem;display:block;opacity:.35;"></i>
        Aucune sp&eacute;cialit&eacute; trouv&eacute;e.
    </div>
<% } %>
</div>

<!-- ═══ PAGINATION ═══ -->
<div class="specialite-pagination-wrap">
    <%= pr.getBasPage() %>
</div>

<script>
function toggleSpeMenu(btn, e) {
    e.stopPropagation();
    var dd = btn.nextElementSibling;
    var isOpen = dd.classList.contains('open');
    // close all open menus first
    document.querySelectorAll('.spe-menu-dropdown.open').forEach(function(el) {
        el.classList.remove('open');
    });
    if (!isOpen) dd.classList.add('open');
}
document.addEventListener('click', function() {
    document.querySelectorAll('.spe-menu-dropdown.open').forEach(function(el) {
        el.classList.remove('open');
    });
});
</script>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
