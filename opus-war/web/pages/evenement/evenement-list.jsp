<%@page import="affichage.PageRecherche"%>
<%@ page import="alumni.Evenement" %>

<% try {
    Evenement t = new Evenement();
    String listeCrt[] = {"description"};
    String listeInt[] = {};
    String libEntete[] = {"idevenement", "description", "datedebut", "datefin", "daty"};
    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Liste des &eacute;v&eacute;nements");
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("evenement/evenement-list.jsp");
    pr.getFormu().getChamp("description").setLibelle("Description");
    pr.setNpp(50);
    String[] colSomme = {};
    pr.creerObjetPage(libEntete, colSomme);

    String lienBase = (String) session.getValue("lien");
    String lienTableau[] = {lienBase + "?but=evenement/evenement-fiche.jsp"};
    String colonneLien[] = {"idevenement"};
    String[] attributLien = {"idevenement"};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setAttLien(attributLien);
    pr.getTableau().setColonneLien(colonneLien);
    String libEnteteAffiche[] = {"Id", "Description", "Date d&eacute;but", "Date fin", "Date cr&eacute;ation"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);

    /* Color palette for event cards */
    String[] cardGradients = {
        "#1E40AF",
        "#0F766E",
        "#059669",
        "#1E3A5F",
        "#0E7490",
        "#166534",
        "#334155",
        "#1D4ED8"
    };
    String[] cardIcons = {
        "fa fa-calendar-check-o",
        "fa fa-users",
        "fa fa-graduation-cap",
        "fa fa-trophy",
        "fa fa-bullhorn",
        "fa fa-star",
        "fa fa-handshake-o",
        "fa fa-lightbulb-o"
    };
%>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <i class="fa fa-calendar" style="color:var(--itu-blue);font-size:1.1rem;margin-right:10px;"></i>
        &Eacute;v&eacute;nements Alumni
    </h1>
    <div style="display:flex;align-items:center;gap:1rem;">
        <span style="font-size:0.85rem;color:var(--gray-500);">
            <strong style="color:var(--itu-dark);"><%= pr.getListe().length %></strong> &eacute;v&eacute;nement(s)
        </span>
        <a class="btn btn-primary"
           href="<%= lienBase %>?but=evenement/evenement-saisie.jsp"
           style="display:inline-flex;align-items:center;gap:6px;white-space:nowrap;">
            <i class="fa fa-plus"></i> Ajouter
        </a>
    </div>
</div>

<!-- ═══ SEARCH & FILTER ═══ -->
<div class="custom-card no-hover" style="margin-bottom:20px;padding:1.25rem 1.5rem;">
    <form action="<%= pr.getLien() %>?but=<%= pr.getApres() %>" method="post">
        <div style="display:flex;gap:0.75rem;flex-wrap:wrap;align-items:center;">
            <input class="form-control-custom"
                   type="text"
                   name="description"
                   value="<%= pr.getFormu().getChamp("description").getValeur() != null ? pr.getFormu().getChamp("description").getValeur() : "" %>"
                   placeholder="Rechercher un &eacute;v&eacute;nement..."
                   style="flex:1;min-width:200px;">
            <button class="btn btn-primary" type="submit" style="padding-left:1.5rem;padding-right:1.5rem;">
                <i class="fa fa-search" style="margin-right:6px;"></i>Chercher
            </button>
        </div>
    </form>
</div>

<!-- ═══ STYLES ═══ -->
<style>
.evt-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 1.25rem;
    margin-top: 0.5rem;
}
.evt-card {
    background: var(--white);
    border: 1px solid var(--gray-200);
    border-radius: 14px;
    overflow: hidden;
    box-shadow: 0 2px 10px rgba(0,0,0,0.06);
    transition: transform 0.2s, box-shadow 0.2s;
    position: relative;
}
.evt-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(0,0,0,0.10);
}
.evt-card-banner {
    height: 80px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
}
.evt-card-banner i {
    font-size: 2rem;
    color: rgba(255,255,255,0.85);
}
.evt-card-body {
    padding: 1.1rem 1.25rem 1.25rem;
}
.evt-card-title {
    font-size: 1rem;
    font-weight: 700;
    color: var(--itu-dark);
    margin: 0 0 0.5rem;
    line-height: 1.35;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
.evt-card-dates {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    margin-bottom: 0.75rem;
}
.evt-date-badge {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    font-size: 0.78rem;
    color: var(--gray-600);
    background: var(--gray-100);
    padding: 0.25rem 0.65rem;
    border-radius: 20px;
}
.evt-date-badge i {
    font-size: 0.72rem;
    color: var(--itu-blue);
}
.evt-card-id {
    font-size: 0.72rem;
    color: var(--gray-400);
    margin-bottom: 0.6rem;
}
.evt-card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 0.75rem;
    border-top: 1px solid var(--gray-100);
}
.evt-card-menu {
    position: absolute;
    top: 8px;
    right: 10px;
    z-index: 10;
}
.evt-menu-btn {
    background: rgba(255,255,255,0.25);
    border: 1px solid rgba(255,255,255,0.4);
    border-radius: 6px;
    width: 30px;
    height: 30px;
    cursor: pointer;
    font-size: 1.1rem;
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background .15s;
    padding: 0;
}
.evt-menu-btn:hover {
    background: rgba(255,255,255,0.45);
}
.evt-menu-dropdown {
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
.evt-menu-dropdown.open {
    display: block;
}
.evt-menu-dropdown a {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 9px 14px;
    font-size: .85rem;
    color: #374151;
    text-decoration: none;
    transition: background .12s;
}
.evt-menu-dropdown a:hover {
    background: #f0f4ff;
    color: var(--itu-blue);
}
</style>

<!-- ═══ EVENTS GRID ═══ -->
<div class="evt-grid">
<%
    alumni.Evenement[] liste = (alumni.Evenement[]) pr.getListe();
    for (int i = 0; i < liste.length; i++) {
        alumni.Evenement evt = liste[i];
        int idx = i % 8;
        String desc = evt.getDescription() != null ? evt.getDescription() : "";
        String debut = evt.getDatedebut() != null ? evt.getDatedebut().toString() : "";
        String fin   = evt.getDatefin()   != null ? evt.getDatefin().toString()   : "";
        String creation = evt.getDaty()   != null ? evt.getDaty().toString()       : "";
        String evtId = evt.getIdevenement() != null ? evt.getIdevenement() : "";
        String descTrunc = desc.length() > 100 ? desc.substring(0, 100) + "\u2026" : desc;
%>
    <div class="evt-card">
        <!-- Banner -->
        <div class="evt-card-banner" style="background:<%= cardGradients[idx] %>;">
            <i class="<%= cardIcons[idx] %>"></i>
            <!-- Menu kebab -->
            <div class="evt-card-menu">
                <button class="evt-menu-btn" onclick="toggleEvtMenu(this, event)" title="Options">&#8942;</button>
                <div class="evt-menu-dropdown">
                    <a href="<%= lienBase %>?but=evenement/evenement-fiche.jsp&amp;idevenement=<%= evtId %>">
                        <i class="fa fa-eye"></i> Voir d&eacute;tails
                    </a>
                    <a href="<%= lienBase %>?but=evenement/evenement-modif.jsp&amp;idevenement=<%= evtId %>">
                        <i class="fa fa-pencil"></i> Modifier
                    </a>
                    <a href="<%= lienBase %>?but=apresTarif.jsp&amp;id=<%= evtId %>&amp;acte=delete&amp;bute=evenement/evenement-list.jsp&amp;classe=alumni.Evenement&amp;nomtable=evenement"
                       onclick="return confirm('\u00cates-vous s\u00fbr de vouloir supprimer cet \u00e9v\u00e9nement ?');"
                       style="color:#e53e3e;">
                        <i class="fa fa-trash"></i> Supprimer
                    </a>
                </div>
            </div>
        </div>

        <!-- Body -->
        <div class="evt-card-body">
            <div class="evt-card-id"><i class="fa fa-hashtag" style="margin-right:3px;"></i><%= evtId %></div>
            <h3 class="evt-card-title"><%= descTrunc.isEmpty() ? "&mdash;" : descTrunc %></h3>

            <div class="evt-card-dates">
                <% if (!debut.isEmpty()) { %>
                <span class="evt-date-badge"><i class="fa fa-play"></i> <%= debut %></span>
                <% } %>
                <% if (!fin.isEmpty()) { %>
                <span class="evt-date-badge"><i class="fa fa-stop"></i> <%= fin %></span>
                <% } %>
            </div>

            <div class="evt-card-footer">
                <% if (!creation.isEmpty()) { %>
                <span style="font-size:0.75rem;color:var(--gray-400);">
                    <i class="fa fa-clock-o" style="margin-right:3px;"></i>Cr&eacute;&eacute; le <%= creation %>
                </span>
                <% } else { %>
                <span></span>
                <% } %>
                <a href="<%= lienBase %>?but=evenement/evenement-fiche.jsp&amp;idevenement=<%= evtId %>"
                   style="font-size:0.82rem;font-weight:600;color:var(--itu-blue);text-decoration:none;">
                    Voir <i class="fa fa-arrow-right" style="margin-left:4px;font-size:0.7rem;"></i>
                </a>
            </div>
        </div>
    </div>
<% } %>

<% if (liste.length == 0) { %>
    <div style="grid-column:1/-1;text-align:center;padding:3rem 1rem;color:var(--gray-500);">
        <i class="fa fa-calendar-o" style="font-size:2.5rem;margin-bottom:1rem;display:block;opacity:.35;"></i>
        Aucun &eacute;v&eacute;nement trouv&eacute;.
        <div style="margin-top:1rem;">
            <a class="btn btn-primary" href="<%= lienBase %>?but=evenement/evenement-saisie.jsp"
               style="display:inline-flex;align-items:center;gap:6px;">
                <i class="fa fa-plus"></i> Cr&eacute;er un &eacute;v&eacute;nement
            </a>
        </div>
    </div>
<% } %>
</div>

<!-- ═══ PAGINATION ═══ -->
<div style="margin-top:1.5rem;display:flex;justify-content:center;">
    <%= pr.getBasPage() %>
</div>

<script>
function toggleEvtMenu(btn, e) {
    e.stopPropagation();
    var dd = btn.nextElementSibling;
    var isOpen = dd.classList.contains('open');
    document.querySelectorAll('.evt-menu-dropdown.open').forEach(function(el) {
        el.classList.remove('open');
    });
    if (!isOpen) dd.classList.add('open');
}
document.addEventListener('click', function() {
    document.querySelectorAll('.evt-menu-dropdown.open').forEach(function(el) {
        el.classList.remove('open');
    });
});
</script>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
