<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
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

    pr.setNpp(9999);
    String[] colSomme = {};
    pr.creerObjetPage(libEntete, colSomme);

    String lienBase = (String) session.getValue("lien");

    /* Pagination manuelle */
    Historique[] allHistoTotal = (Historique[]) pr.getListe();
    int totalEntries = allHistoTotal.length;
    int npp = 20; // lignes par page
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try { currentPage = Integer.parseInt(pageParam); } catch (Exception e) { currentPage = 1; }
    }
    if (currentPage < 1) currentPage = 1;
    int totalPages = (int) Math.ceil((double) totalEntries / npp);
    if (totalPages < 1) totalPages = 1;
    if (currentPage > totalPages) currentPage = totalPages;
    int startIdx = (currentPage - 1) * npp;
    int endIdx   = Math.min(startIdx + npp, totalEntries);
    java.util.List pageList = new java.util.ArrayList();
    for (int pi = startIdx; pi < endIdx; pi++) {
        pageList.add(allHistoTotal[pi]);
    }
    Historique[] pageItems = (Historique[]) pageList.toArray(new Historique[0]);
%>

<!-- ═══ STYLES ═══ -->
<style>
    .histo-table { width:100%; border-collapse:collapse; font-size:0.875rem; }
    .histo-table thead tr { background:var(--itu-blue,#008BFF); color:#fff; }
    .histo-table thead th { padding:11px 14px; font-weight:600; text-align:left; white-space:nowrap; }
    .histo-table tbody tr { border-bottom:1px solid #f1f5f9; transition:background .15s; }
    .histo-table tbody tr:hover { background:#f0f7ff; }
    .histo-table tbody tr:last-child { border-bottom:none; }
    .histo-table td { padding:10px 14px; vertical-align:middle; color:var(--itu-dark,#1e293b); }
    .histo-table td.td-id { font-family:monospace; font-size:0.8rem; color:#64748b; }
    .histo-table td.td-date { white-space:nowrap; }
    .histo-table td.td-heure { white-space:nowrap; color:#64748b; }
    .histo-table td.td-ref { font-family:monospace; font-size:0.78rem; color:#94a3b8; max-width:140px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    .histo-badge { display:inline-block; padding:3px 10px; border-radius:20px; font-size:0.78rem; font-weight:600; }
    .histo-badge-insert  { background:#d1fae5; color:#065f46; }
    .histo-badge-update  { background:#dbeafe; color:#1e40af; }
    .histo-badge-delete  { background:#fee2e2; color:#991b1b; }
    .histo-badge-login   { background:#fef3c7; color:#92400e; }
    .histo-badge-default { background:#f1f5f9; color:#475569; }
    .mots-cless { display:none !important; }
</style>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <i class="fa fa-history" style="color:var(--itu-blue);font-size:1.1rem;margin-right:10px;"></i>
        Logs Historique
    </h1>
    <div style="display:flex;align-items:center;gap:1rem;">
        <span style="font-size:0.85rem;color:var(--gray-500);">
            <strong style="color:var(--itu-dark);"><%= totalEntries %></strong> entr&eacute;e(s)
        </span>
    </div>
</div>

<!-- ═══ STATS ═══ -->
<div style="display:flex;gap:15px;margin-bottom:20px;">
    <div class="custom-card no-hover" style="flex:1;text-align:center;padding:15px 20px;">
        <div style="font-size:1.8em;font-weight:700;color:var(--itu-blue,#008BFF);"><%= totalEntries %></div>
        <div style="font-size:0.85em;color:#888;">Total entr&eacute;es</div>
    </div>
    <div class="custom-card no-hover" style="flex:1;text-align:center;padding:15px 20px;">
        <div style="font-size:1.8em;font-weight:700;color:#27ae60;"><%= totalPages %></div>
        <div style="font-size:0.85em;color:#888;">Pages</div>
    </div>
    <div class="custom-card no-hover" style="flex:1;text-align:center;padding:15px 20px;">
        <div style="font-size:1.8em;font-weight:700;color:#f59e0b;"><%= npp %></div>
        <div style="font-size:0.85em;color:#888;">Lignes / page</div>
    </div>
    <div class="custom-card no-hover" style="flex:1;text-align:center;padding:15px 20px;">
        <div style="font-size:1.8em;font-weight:700;color:#8b5cf6;"><%= currentPage %></div>
        <div style="font-size:0.85em;color:#888;">Page actuelle</div>
    </div>
</div>

<!-- ═══ RECHERCHE ═══ -->
<div class="custom-card no-hover" style="margin-bottom:20px;padding:1.25rem 1.5rem;">
    <form action="<%= pr.getLien() %>?but=<%= pr.getApres() %>" method="post" name="recherche" id="recherche">
        <%= pr.getFormu().getHtmlEnsemble() %>
    </form>
</div>

<!-- ═══ TABLEAU ═══ -->
<div class="custom-card no-hover" style="padding:0;overflow:hidden;">
    <table class="histo-table">
        <thead>
            <tr>
                <th>#</th>
                <th>ID</th>
                <th>Date</th>
                <th>Heure</th>
                <th>Action</th>
                <th>Objet</th>
                <th>Utilisateur</th>
                <th>R&eacute;f. Objet</th>
            </tr>
        </thead>
        <tbody>
        <%
            if (pageItems.length == 0) {
        %>
            <tr>
                <td colspan="8" style="text-align:center;padding:3rem 1rem;color:var(--gray-500);">
                    <i class="fa fa-history" style="font-size:2rem;margin-bottom:0.8rem;display:block;opacity:.3;"></i>
                    Aucun historique trouv&eacute;.
                </td>
            </tr>
        <%
            }
            for (int i = 0; i < pageItems.length; i++) {
                Historique h = pageItems[i];
                String actionVal  = h.getAction()  != null ? h.getAction()  : "";
                String objetVal   = h.getObjet()   != null ? h.getObjet()   : "";
                String heureVal   = h.getHeure()   != null ? h.getHeure()   : "";
                String refVal     = h.getRefobjet() != null ? h.getRefobjet() : "";
                String dateVal    = h.getDatehistorique() != null ? h.getDatehistorique().toString() : "";
                String idVal      = h.getIdhistorique() != null ? h.getIdhistorique() : "";

                /* Badge couleur selon action */
                String actionLower = actionVal.toLowerCase();
                String badgeClass;
                if (actionLower.contains("insert") || actionLower.contains("creat") || actionLower.contains("ajout")) {
                    badgeClass = "histo-badge-insert";
                } else if (actionLower.contains("update") || actionLower.contains("modif")) {
                    badgeClass = "histo-badge-update";
                } else if (actionLower.contains("delete") || actionLower.contains("supprim")) {
                    badgeClass = "histo-badge-delete";
                } else if (actionLower.contains("login") || actionLower.contains("connect")) {
                    badgeClass = "histo-badge-login";
                } else {
                    badgeClass = "histo-badge-default";
                }
        %>
            <tr>
                <td style="color:#94a3b8;font-size:0.8rem;"><%= startIdx + i + 1 %></td>
                <td class="td-id"><%= idVal %></td>
                <td class="td-date"><%= dateVal %></td>
                <td class="td-heure"><i class="fa fa-clock-o" style="margin-right:4px;opacity:.5;"></i><%= heureVal %></td>
                <td><span class="histo-badge <%= badgeClass %>"><%= actionVal.isEmpty() ? "&mdash;" : actionVal %></span></td>
                <td><%= objetVal.isEmpty() ? "<span style='color:#cbd5e1;'>—</span>" : objetVal %></td>
                <td><%= (h.getIdutilisateur() != null && !h.getIdutilisateur().isEmpty()) ? h.getIdutilisateur() : "<span style='color:#cbd5e1;'>—</span>" %></td>
                <td class="td-ref" title="<%= refVal %>"><%= refVal.isEmpty() ? "<span style='color:#cbd5e1;'>—</span>" : refVal %></td>
            </tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- ═══ PAGINATION ═══ -->
<div style="display:flex;justify-content:center;align-items:center;gap:8px;margin-top:20px;flex-wrap:wrap;">
    <% if (currentPage > 1) { %>
    <a href="<%= lienBase %>?but=dashboard/historique-list.jsp&page=1" class="btn btn-outline-secondary btn-sm" title="Premi&egrave;re page">&laquo;</a>
    <a href="<%= lienBase %>?but=dashboard/historique-list.jsp&page=<%= currentPage - 1 %>" class="btn btn-outline-secondary btn-sm">&lsaquo; Pr&eacute;c</a>
    <% } else { %>
    <span class="btn btn-outline-secondary btn-sm disabled">&laquo;</span>
    <span class="btn btn-outline-secondary btn-sm disabled">&lsaquo; Pr&eacute;c</span>
    <% } %>

    <%
        int pageWindow = 2;
        int pStart = Math.max(1, currentPage - pageWindow);
        int pEnd   = Math.min(totalPages, currentPage + pageWindow);
        if (pStart > 1) {
    %>
    <a href="<%= lienBase %>?but=dashboard/historique-list.jsp&page=1" class="btn btn-outline-secondary btn-sm">1</a>
    <% if (pStart > 2) { %><span style="padding:0 4px;color:#94a3b8;">…</span><% } %>
    <% } %>

    <% for (int p = pStart; p <= pEnd; p++) { %>
        <% if (p == currentPage) { %>
        <span class="btn btn-sm" style="background:var(--itu-blue,#008BFF);color:#fff;border:1px solid var(--itu-blue,#008BFF);"><%= p %></span>
        <% } else { %>
        <a href="<%= lienBase %>?but=dashboard/historique-list.jsp&page=<%= p %>" class="btn btn-outline-secondary btn-sm"><%= p %></a>
        <% } %>
    <% } %>

    <%
        if (pEnd < totalPages) {
            if (pEnd < totalPages - 1) {
    %><span style="padding:0 4px;color:#94a3b8;">…</span><%
            }
    %>
    <a href="<%= lienBase %>?but=dashboard/historique-list.jsp&page=<%= totalPages %>" class="btn btn-outline-secondary btn-sm"><%= totalPages %></a>
    <% } %>

    <span style="padding:0 12px;font-size:0.9em;">
        Page <strong><%= currentPage %></strong> / <strong><%= totalPages %></strong>
        &nbsp;(<%= totalEntries %> entr&eacute;es)
    </span>

    <% if (currentPage < totalPages) { %>
    <a href="<%= lienBase %>?but=dashboard/historique-list.jsp&page=<%= currentPage + 1 %>" class="btn btn-outline-secondary btn-sm">Suiv &rsaquo;</a>
    <a href="<%= lienBase %>?but=dashboard/historique-list.jsp&page=<%= totalPages %>" class="btn btn-outline-secondary btn-sm" title="Derni&egrave;re page">&raquo;</a>
    <% } else { %>
    <span class="btn btn-outline-secondary btn-sm disabled">Suiv &rsaquo;</span>
    <span class="btn btn-outline-secondary btn-sm disabled">&raquo;</span>
    <% } %>
</div>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
