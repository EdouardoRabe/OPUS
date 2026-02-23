<%@page import="affichage.PageRecherche"%>
<%@ page import="alumni.SpecialiteCpl" %>

<% try {
    SpecialiteCpl t = new SpecialiteCpl();
    String listeCrt[] = {"idspecialite", "libelle"};
    String listeInt[] = {};
    String libEntete[] = {"idspecialite", "libelle", "description", "photohtml"};
    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Liste des sp&eacute;cialit&eacute;s");
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("specialite/specialite-list.jsp");
    pr.getFormu().getChamp("idspecialite").setLibelle("Id");
    pr.getFormu().getChamp("libelle").setLibelle("Libell&eacute;");
    pr.setNpp(50);
    String[] colSomme = {};
    pr.creerObjetPage(libEntete, colSomme);

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
    <span style="font-size:0.85rem;color:var(--gray-500);">
        <strong style="color:var(--itu-dark);"><%= pr.getListe().length %></strong> sp&eacute;cialit&eacute;s affich&eacute;es
    </span>
</div>

<!-- ═══ SEARCH & FILTER ═══ -->
<div class="custom-card no-hover" style="margin-bottom:20px;padding:1.25rem 1.5rem;">
    <form action="<%= pr.getLien() %>?but=<%= pr.getApres() %>" method="post">
        <div class="specialite-search-row">
            <input class="form-control-custom"
                   type="text"
                   name="libelle"
                   value="<%= pr.getFormu().getChamp("libelle").getValeur() != null ? pr.getFormu().getChamp("libelle").getValeur() : "" %>"
                   placeholder="Rechercher une sp&eacute;cialit&eacute;..."
                   style="flex:1;">
            <button class="btn btn-primary" type="submit" style="padding-left:1.5rem;padding-right:1.5rem;">
                <i class="fa fa-search" style="margin-right:6px;"></i>Chercher
            </button>
        </div>
        <div class="specialite-filter-row">
            <!-- Filters statiques — à connecter quand les colonnes DB seront disponibles -->
            <select class="form-control-custom" style="width:auto;min-width:175px;" disabled title="Filtre domaine (non disponible)">
                <option>Tous les domaines</option>
            </select>
            <select class="form-control-custom" style="width:auto;min-width:175px;" disabled title="Filtre niveau (non disponible)">
                <option>Tous les niveaux</option>
            </select>
        </div>
    </form>
</div>

<!-- ═══ SPECIALITES GRID ═══ -->
<div class="specialities-grid">
<%
    alumni.SpecialiteCpl[] liste = (alumni.SpecialiteCpl[]) pr.getListe();
    for (int i = 0; i < liste.length; i++) {
        alumni.SpecialiteCpl spe = liste[i];
        int idx = i % 8;
        String photoHtml = spe.getPhotohtml();
        if (photoHtml != null) photoHtml = photoHtml.replace("__CTX__", request.getContextPath());
        boolean hasPhoto = (photoHtml != null && !photoHtml.trim().isEmpty());
%>
    <div class="speciality-card">

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

        <!-- Meta (alumni count + level) -->
        <div class="speciality-meta">
            <span class="speciality-count"><strong>&mdash;</strong> alumni</span>
            <span class="speciality-level">Tous niveaux</span>
        </div>

        <!-- Bouton Voir profils -->
        <a class="btn btn-outline-primary btn-speciality"
           href="<%= lienBase %>?but=specialite/specialite-fiche.jsp&amp;idspecialite=<%= spe.getIdspecialite() %>">
            <i class="fa fa-eye" style="margin-right:5px;"></i>Voir profils
        </a>

    </div>
<% } %>

<% if (liste.length == 0) { %>
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

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
