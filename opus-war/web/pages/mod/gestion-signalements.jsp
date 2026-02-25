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
    pr.setNpp(50);
    String[] colSomme = {};
    pr.creerObjetPage(libEntete, colSomme);

    String lienBase = (String) session.getValue("lien");

    /* Configurer le tableau APJ */
    String libEnteteAffiche[] = {"ID", "Signalant", "Signal&eacute;", "Motif", "Description", "Date", "Heure", "Publication"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);

    // Lien APJ sur la colonne idsignalement vers detail-signalement.jsp
    String lienTableau[] = {lienBase + "?but=mod/detail-signalement.jsp"};
    String colonneLien[] = {"idsignalement"};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setColonneLien(colonneLien);

    Signalementpublicationlib[] allSig = (Signalementpublicationlib[]) pr.getListe();
%>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <i class="fa fa-flag" style="color:#dc3545;font-size:1.1rem;margin-right:10px;"></i>
        Gestion des signalements
    </h1>
    <div style="display:flex;align-items:center;gap:1rem;">
        <span style="font-size:0.85rem;color:var(--gray-500);">
            <strong style="color:var(--itu-dark);"><%= allSig.length %></strong> signalement(s)
        </span>
    </div>
</div>

<!-- ═══ STATS CARDS ═══ -->
<div style="display:flex;gap:15px;margin-bottom:20px;">
    <div class="custom-card no-hover" style="flex:1;text-align:center;padding:15px 20px;">
        <div style="font-size:1.8em;font-weight:700;color:#dc3545;"><%= allSig.length %></div>
        <div style="font-size:0.85em;color:#888;">Total signalements</div>
    </div>
</div>

<!-- ═══ SEARCH & FILTER (APJ Standard) ═══ -->
<div class="custom-card no-hover" style="margin-bottom:20px;padding:1.25rem 1.5rem;">
    <form action="<%= pr.getLien() %>?but=<%= pr.getApres() %>" method="post" name="recherche" id="recherche">
        <%= pr.getFormu().getHtmlEnsemble() %>
    </form>
</div>

<!-- ═══ TABLE SIGNALEMENTS (APJ Standard) ═══ -->
<div class="custom-card no-hover" style="padding:0;overflow:hidden;">
    <%= pr.getTableau().getHtml() %>
</div>

<!-- ═══ PAGINATION ═══ -->
<div class="specialite-pagination-wrap" style="margin-top:15px;">
    <%= pr.getBasPage() %>
</div>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
