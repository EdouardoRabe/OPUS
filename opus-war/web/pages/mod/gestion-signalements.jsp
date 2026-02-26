<%@page import="affichage.PageRecherche"%>
<%@ page import="alumni.Signalementpublicationlib" %>

<% try {
    user.UserEJB uEjb = (user.UserEJB) session.getValue("u");

    Signalementpublicationlib t = new Signalementpublicationlib();
    String listeCrt[] = {"nomsignalant", "nomsignale", "motiflibelle", "daty"};
    String listeInt[] = {};
    String libEntete[] = {"idsignalement", "nomsignalant", "nomsignale", "motiflibelle", "motifdesc", "daty", "heure", "idpublication"};
    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Gestion des signalements");
    pr.setUtilisateur(uEjb);
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("mod/gestion-signalements.jsp");
    pr.getFormu().getChamp("nomsignalant").setLibelle("Signalant");
    pr.getFormu().getChamp("nomsignale").setLibelle("Signal&eacute;");
    pr.getFormu().getChamp("motiflibelle").setLibelle("Motif");
    pr.getFormu().getChamp("daty").setLibelle("Date");
    pr.setNpp(1000);
    String[] colSomme = {};
    pr.creerObjetPage(libEntete, colSomme);

    String lienBase = (String) session.getValue("lien");

    /* Stats sur tous les signalements */
    Signalementpublicationlib[] allSigTotal = (Signalementpublicationlib[]) pr.getListe();
    int totalSig = allSigTotal.length;

    /* Pagination manuelle */
    int npp = 12;
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try { currentPage = Integer.parseInt(pageParam); } catch (Exception ex) { currentPage = 1; }
    }
    if (currentPage < 1) currentPage = 1;
    int totalPages = (int) Math.ceil((double) totalSig / npp);
    if (totalPages < 1) totalPages = 1;
    if (currentPage > totalPages) currentPage = totalPages;

    int startIdx = (currentPage - 1) * npp;
    int endIdx = Math.min(startIdx + npp, totalSig);
    java.util.List pageList = new java.util.ArrayList();
    for (int pi = startIdx; pi < endIdx; pi++) {
        pageList.add(allSigTotal[pi]);
    }
    Signalementpublicationlib[] allSig = (Signalementpublicationlib[]) pageList.toArray(new Signalementpublicationlib[0]);
%>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <i class="fa fa-flag" style="color:#dc3545;font-size:1.1rem;margin-right:10px;"></i>
        Gestion des signalements
    </h1>
    <div style="display:flex;align-items:center;gap:1rem;">
        <span style="font-size:0.85rem;color:var(--gray-500);">
            <strong style="color:var(--itu-dark);"><%= totalSig %></strong> signalement(s)
        </span>
    </div>
</div>

<!-- ═══ STATS CARDS ═══ -->
<div style="display:flex;gap:15px;margin-bottom:20px;">
    <div class="custom-card no-hover" style="flex:1;text-align:center;padding:15px 20px;">
        <div style="font-size:1.8em;font-weight:700;color:#dc3545;"><%= totalSig %></div>
        <div style="font-size:0.85em;color:#888;">Total signalements</div>
    </div>
</div>

<!-- ═══ SEARCH & FILTER (APJ Standard) ═══ -->
<div class="custom-card no-hover" style="margin-bottom:20px;padding:1.25rem 1.5rem;">
    <form action="<%= pr.getLien() %>?but=<%= pr.getApres() %>" method="post" name="recherche" id="recherche">
        <%= pr.getFormu().getHtmlEnsemble() %>
    </form>
</div>

<!-- ═══ STYLES MENU KEBAB ═══ -->
<style>
.sig-card-menu {
    position: absolute;
    top: 10px;
    right: 12px;
    z-index: 10;
}
.sig-menu-btn {
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
.sig-menu-btn:hover {
    background: #fff1f2;
    border-color: #dc3545;
    color: #dc3545;
}
.sig-menu-dropdown {
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
.sig-menu-dropdown.open { display: block; }
.sig-menu-dropdown a {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 9px 14px;
    font-size: .85rem;
    color: #374151;
    text-decoration: none;
    transition: background .12s;
}
.sig-menu-dropdown a:hover {
    background: #fff1f2;
    color: #dc3545;
}
.mots-cless { display: none !important; }
.sig-badge {
    display: inline-block;
    padding: 2px 9px;
    border-radius: 10px;
    font-size: 0.74em;
    font-weight: 600;
}
.sig-badge-motif { background: #fee2e2; color: #991b1b; }
.sig-badge-id    { background: #f1f5f9; color: #64748b; font-weight: 500; }
.sig-info-row {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 0.82em;
    color: #6b7280;
    margin-bottom: 5px;
}
.sig-info-row .fa { width: 14px; text-align: center; opacity: .65; flex-shrink: 0; }
.sig-info-row strong { color: #374151; }
</style>

<!-- ═══ SIGNALEMENTS GRID ═══ -->
<div class="specialities-grid">
<%
    String[] flagGradients = {
        "background:linear-gradient(135deg,#dc3545,#c82333)",
        "background:linear-gradient(135deg,#e67e22,#d35400)",
        "background:linear-gradient(135deg,#8b5cf6,#7c3aed)",
        "background:linear-gradient(135deg,#ef4444,#dc2626)",
        "background:linear-gradient(135deg,#f59e0b,#d97706)",
        "background:linear-gradient(135deg,#10b981,#059669)",
        "background:linear-gradient(135deg,#3b82f6,#2563eb)",
        "background:linear-gradient(135deg,#6366f1,#4f46e5)"
    };
    for (int i = 0; i < allSig.length; i++) {
        Signalementpublicationlib s = allSig[i];
        String signalant = s.getNomsignalant() != null ? s.getNomsignalant() : "&mdash;";
        String signale   = s.getNomsignale()   != null ? s.getNomsignale()   : "&mdash;";
        String motif     = s.getMotiflibelle() != null ? s.getMotiflibelle() : "&mdash;";
        String descSig   = s.getMotifdesc()    != null ? s.getMotifdesc()    : "";
        String daty      = s.getDaty()         != null ? s.getDaty()         : "";
        String heure     = s.getHeure()        != null ? s.getHeure()        : "";
        String idpub     = s.getIdpublication() != null ? s.getIdpublication() : "&mdash;";
        String idSig     = s.getIdsignalement() != null ? s.getIdsignalement() : "?";
%>
    <div class="custom-card no-hover speciality-card" style="position:relative;">

        <!-- Menu 3 points -->
        <div class="sig-card-menu">
            <button class="sig-menu-btn" onclick="toggleSigMenu(this, event)" title="Options">&#8942;</button>
            <div class="sig-menu-dropdown">
                <a href="<%= lienBase %>?but=mod/detail-signalement.jsp&amp;idsignalement=<%= idSig %>">
                    <i class="fa fa-eye"></i> Voir le d&eacute;tail
                </a>
            </div>
        </div>

        <!-- Icône -->
        <div class="speciality-icon" style="<%= flagGradients[i % flagGradients.length] %>">
            <i class="fa fa-flag" style="font-size:1.4rem;color:#fff;"></i>
        </div>

        <!-- ID -->
        <div style="margin-bottom:8px;">
            <span class="sig-badge sig-badge-id">#<%= idSig %></span>
        </div>

        <!-- Signalant (titre) -->
        <h3 class="speciality-title"><%= signalant %></h3>

        <!-- Infos -->
        <div style="margin-bottom:10px;">
            <div class="sig-info-row">
                <i class="fa fa-exclamation-triangle" style="color:#dc3545;"></i>
                <span>Signal&eacute;&nbsp;: <strong><%= signale %></strong></span>
            </div>
            <div class="sig-info-row" style="margin-top:4px;">
                <span class="sig-badge sig-badge-motif"><%= motif %></span>
            </div>
            <% if (!descSig.isEmpty()) { %>
            <p class="speciality-desc" style="font-style:italic;margin-top:6px;margin-bottom:0;" title="<%= descSig %>">
                &ldquo;<%= descSig.length() > 70 ? descSig.substring(0, 70) + "…" : descSig %>&rdquo;
            </p>
            <% } %>
        </div>

        <!-- Date / Publication -->
        <div>
            <% if (!daty.isEmpty()) { %>
            <div class="sig-info-row">
                <i class="fa fa-calendar"></i>
                <span><%= daty %><% if (!heure.isEmpty()) { %>&ensp;<i class="fa fa-clock-o"></i>&ensp;<%= heure %><% } %></span>
            </div>
            <% } %>
            <div class="sig-info-row">
                <i class="fa fa-file-text-o"></i>
                <span>Publication&nbsp;: <strong><%= idpub %></strong></span>
            </div>
        </div>

        <!-- Footer lien -->
        <div style="margin-top:auto;padding-top:14px;border-top:1px solid #f1f5f9;">
            <a href="<%= lienBase %>?but=mod/detail-signalement.jsp&amp;idsignalement=<%= idSig %>"
               style="font-size:0.85rem;color:#dc3545;font-weight:600;text-decoration:none;">
                Voir le d&eacute;tail <i class="fa fa-arrow-right" style="font-size:0.75rem;margin-left:4px;"></i>
            </a>
        </div>

    </div>
<% } %>

<% if (allSig.length == 0) { %>
    <div style="grid-column:1/-1;text-align:center;padding:3rem 1rem;color:var(--gray-500);">
        <i class="fa fa-flag" style="font-size:2.5rem;margin-bottom:1rem;display:block;opacity:.35;color:#dc3545;"></i>
        Aucun signalement trouv&eacute;.
    </div>
<% } %>
</div>

<!-- ═══ PAGINATION ═══ -->
<div style="display:flex;justify-content:center;align-items:center;gap:8px;margin-top:20px;flex-wrap:wrap;">
    <% if (currentPage > 1) { %>
    <a href="<%= lienBase %>?but=mod/gestion-signalements.jsp&page=1" class="btn btn-outline-secondary btn-sm" title="Premi&egrave;re page">&laquo;</a>
    <a href="<%= lienBase %>?but=mod/gestion-signalements.jsp&page=<%= currentPage - 1 %>" class="btn btn-outline-secondary btn-sm">&lsaquo; Pr&eacute;c</a>
    <% } else { %>
    <span class="btn btn-outline-secondary btn-sm disabled">&laquo;</span>
    <span class="btn btn-outline-secondary btn-sm disabled">&lsaquo; Pr&eacute;c</span>
    <% } %>

    <span style="padding:0 12px;font-size:0.9em;">
        Page <strong><%= currentPage %></strong> / <strong><%= totalPages %></strong>
        &nbsp;(<%= totalSig %> signalements)
    </span>

    <% if (currentPage < totalPages) { %>
    <a href="<%= lienBase %>?but=mod/gestion-signalements.jsp&page=<%= currentPage + 1 %>" class="btn btn-outline-secondary btn-sm">Suiv &rsaquo;</a>
    <a href="<%= lienBase %>?but=mod/gestion-signalements.jsp&page=<%= totalPages %>" class="btn btn-outline-secondary btn-sm" title="Derni&egrave;re page">&raquo;</a>
    <% } else { %>
    <span class="btn btn-outline-secondary btn-sm disabled">Suiv &rsaquo;</span>
    <span class="btn btn-outline-secondary btn-sm disabled">&raquo;</span>
    <% } %>
</div>

<script>
function toggleSigMenu(btn, e) {
    e.stopPropagation();
    var dd = btn.nextElementSibling;
    var isOpen = dd.classList.contains('open');
    document.querySelectorAll('.sig-menu-dropdown.open').forEach(function(el) {
        el.classList.remove('open');
    });
    if (!isOpen) dd.classList.add('open');
}
document.addEventListener('click', function() {
    document.querySelectorAll('.sig-menu-dropdown.open').forEach(function(el) {
        el.classList.remove('open');
    });
});
</script>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
