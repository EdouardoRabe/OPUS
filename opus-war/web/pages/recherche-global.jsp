<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Typepublication" %>
<%@ page import="alumni.Media" %>
<%@ page import="alumni.Visibilite" %>
<%@ page import="alumni.Publicationreaction" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>
<%!
    private static String h(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
    }
    private static String ue(String s) {
        if (s == null || s.isEmpty()) return "";
        try { return URLEncoder.encode(s, "UTF-8"); } catch (Exception e) { return s; }
    }
    private static boolean isPublic(Map visMap, String idprofil, String champ) {
        Map champMap = (Map) visMap.get(idprofil);
        if (champMap == null) return true;
        Integer st = (Integer) champMap.get(champ);
        if (st == null) return true;
        return st.intValue() == 1;
    }
%>
<%
    /* ── Session ── */
    String _lien = (String) session.getValue("lien");
    if (_lien == null) _lien = "module.jsp";
    String ctx = request.getContextPath();
    UserEJB uEJB = (UserEJB) session.getAttribute("u");
    MapUtilisateur mu = (uEJB != null) ? uEJB.getUser() : null;
    int myRefuser = (mu != null) ? mu.getRefuser() : -1;

    /* ── Paramètres ── */
    String q       = request.getParameter("q");
    String tab     = request.getParameter("tab");      // "all", "personnes", "publications"
    String typePub = request.getParameter("typepub");   // filtre type publication
    String tri     = request.getParameter("tri");       // "pertinence", "date", "nom"
    int    pg      = 1;
    try { pg = Integer.parseInt(request.getParameter("pg")); } catch (Exception e) {}
    if (pg < 1) pg = 1;

    if (q == null)   q = "";
    if (tab == null || tab.isEmpty()) tab = "all";
    if (tri == null || tri.isEmpty()) tri = "pertinence";

    boolean hasQuery = !q.trim().isEmpty();
    String qSafe = q.trim().replace("'", "''").toLowerCase();
    String[] qWords = hasQuery ? qSafe.split("\\s+") : new String[0];

    /* ── Résultats ── */
    List personnes   = new ArrayList();   // ProfilLib[]
    List pubs        = new ArrayList();   // Publication[]
    Map pubAuthors   = new HashMap();     // idpublication -> "Nom Prenom"
    Map pubPhotos    = new HashMap();     // idpublication -> author photo url
    Map pubTypes     = new HashMap();     // idpublication -> type libelle
    Map pubMedias    = new HashMap();     // idpublication -> media url
    Map pubReactCnt  = new HashMap();     // idpublication -> Integer (reaction count)
    Map pubCommCnt   = new HashMap();     // idpublication -> Integer (comment count)
    Typepublication[] typesPub = new Typepublication[0];
    int totalPersonnes = 0;
    int totalPubs = 0;
    int PAGE_SIZE = 12;
    int totalPages = 1;

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        /* ── Types de publication (pour le filtre) ── */
        typesPub = (Typepublication[]) CGenUtil.rechercher(
            new Typepublication(), null, null, conn, " order by libelle");
        if (typesPub == null) typesPub = new Typepublication[0];

        /* ── Lookup noms + photos ── */
        ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(
            new ProfilLib(), null, null, conn, "");
        if (allProfils == null) allProfils = new ProfilLib[0];
        Map userNames  = new HashMap(); // refuser -> "Nom Prenom"
        Map userPhotos = new HashMap(); // refuser -> photo path
        Map userIdprofil = new HashMap(); // refuser -> idprofil (pour check visibilite)
        for (int i = 0; i < allProfils.length; i++) {
            Integer key = new Integer(allProfils[i].getIdutilisateur());
            userNames.put(key, allProfils[i].getNom() + " " + allProfils[i].getPrenom());
            if (allProfils[i].getPhotoProfil() != null && !allProfils[i].getPhotoProfil().trim().isEmpty())
                userPhotos.put(key, allProfils[i].getPhotoProfil().trim());
            if (allProfils[i].getIdprofil() != null)
                userIdprofil.put(key, allProfils[i].getIdprofil());
        }

        /* ── Visibilité ── */
        Visibilite[] allVis = (Visibilite[]) CGenUtil.rechercher(
            new Visibilite(), null, null, conn, "");
        if (allVis == null) allVis = new Visibilite[0];
        Map visMap = new HashMap();
        for (int i = 0; i < allVis.length; i++) {
            String pid = allVis[i].getIdprofil();
            Map champMap = (Map) visMap.get(pid);
            if (champMap == null) { champMap = new HashMap(); visMap.put(pid, champMap); }
            champMap.put(allVis[i].getChampvisibilite(), new Integer(allVis[i].getStatus()));
        }

        if (hasQuery) {

            /* ═══════════════════════════════════════
               RECHERCHE PERSONNES
               ═══════════════════════════════════════ */
            if ("all".equals(tab) || "personnes".equals(tab)) {
                // Construire WHERE multi-mots : chaque mot doit matcher nom OU prenom OU loginuser OU promotionlib OU parcourslib
                StringBuffer where = new StringBuffer();
                for (int w = 0; w < qWords.length; w++) {
                    String word = qWords[w];
                    where.append(" and (LOWER(nom) LIKE '%").append(word).append("%'")
                         .append(" or LOWER(prenom) LIKE '%").append(word).append("%'")
                         .append(" or LOWER(loginuser) LIKE '%").append(word).append("%'")
                         .append(" or LOWER(promotionlib) LIKE '%").append(word).append("%'")
                         .append(" or LOWER(parcourslib) LIKE '%").append(word).append("%')");
                }
                // Tri
                String orderBy = " order by nom asc, prenom asc";
                if ("date".equals(tri)) orderBy = " order by idprofil desc";

                ProfilLib[] resP = (ProfilLib[]) CGenUtil.rechercher(
                    new ProfilLib(), null, null, conn, where.toString() + orderBy);
                if (resP != null) {
                    // Filtrer : seulement les profils visibles (nom public)
                    for (int i = 0; i < resP.length; i++) {
                        if (resP[i].getIdprofil() == null) continue;
                        if (resP[i].getIdutilisateur() == myRefuser || isPublic(visMap, resP[i].getIdprofil(), "nom")) {
                            personnes.add(resP[i]);
                        }
                    }
                }
                totalPersonnes = personnes.size();
            }

            /* ═══════════════════════════════════════
               RECHERCHE PUBLICATIONS
               ═══════════════════════════════════════ */
            if ("all".equals(tab) || "publications".equals(tab)) {
                StringBuffer where = new StringBuffer(" and etat = 1");
                for (int w = 0; w < qWords.length; w++) {
                    where.append(" and LOWER(descritpion) LIKE '%").append(qWords[w]).append("%'");
                }
                if (typePub != null && !typePub.isEmpty()) {
                    where.append(" and idtypepublication = '").append(typePub.replace("'","''")).append("'");
                }
                String orderBy = " order by daty desc, heure desc";
                if ("pertinence".equals(tri)) orderBy = " order by daty desc, heure desc";

                Publication[] resB = (Publication[]) CGenUtil.rechercher(
                    new Publication(), null, null, conn, where.toString() + orderBy);
                if (resB == null) resB = new Publication[0];

                for (int i = 0; i < resB.length; i++) {
                    Publication p = resB[i];
                    // Verifier la visibilite de l'auteur (nom public ou c'est moi)
                    Integer authorKey = new Integer(p.getIdutilisateur());
                    String authorIdprofil = (String) userIdprofil.get(authorKey);
                    if (p.getIdutilisateur() != myRefuser && authorIdprofil != null && !isPublic(visMap, authorIdprofil, "nom")) {
                        continue; // Auteur a un profil prive, on masque sa publication
                    }
                    pubs.add(p);
                    // Auteur
                    String aName = (String) userNames.get(new Integer(p.getIdutilisateur()));
                    pubAuthors.put(p.getIdpublication(), aName != null ? aName : "Utilisateur");
                    String aPhoto = (String) userPhotos.get(new Integer(p.getIdutilisateur()));
                    if (aPhoto != null) pubPhotos.put(p.getIdpublication(), aPhoto);
                    // Type
                    for (int t = 0; t < typesPub.length; t++) {
                        if (typesPub[t].getIdtypepublication().equals(p.getIdtypepublication())) {
                            pubTypes.put(p.getIdpublication(), typesPub[t].getLibelle());
                            break;
                        }
                    }
                    // Media
                    Media[] medias = (Media[]) CGenUtil.rechercher(new Media(), null, null, conn,
                        " and idpublication = '" + p.getIdpublication() + "'");
                    if (medias != null && medias.length > 0 && medias[0].getMediaurl() != null) {
                        pubMedias.put(p.getIdpublication(), medias[0].getMediaurl());
                    }
                    // Reactions count
                    Publicationreaction[] reacts = (Publicationreaction[]) CGenUtil.rechercher(
                        new Publicationreaction(), null, null, conn,
                        " and idpublication = '" + p.getIdpublication() + "'");
                    pubReactCnt.put(p.getIdpublication(), new Integer(reacts != null ? reacts.length : 0));
                    // Comments count
                    Publicationcommentaire[] comms = (Publicationcommentaire[]) CGenUtil.rechercher(
                        new Publicationcommentaire(), null, null, conn,
                        " and idpublication = '" + p.getIdpublication() + "' and etat = 1");
                    pubCommCnt.put(p.getIdpublication(), new Integer(comms != null ? comms.length : 0));
                }
                totalPubs = pubs.size();
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }

    /* ── Pagination ── */
    int totalResults = 0;
    if ("personnes".equals(tab))       totalResults = totalPersonnes;
    else if ("publications".equals(tab)) totalResults = totalPubs;
    else                                 totalResults = totalPersonnes + totalPubs;
    totalPages = (int) Math.ceil((double) totalResults / PAGE_SIZE);
    if (totalPages < 1) totalPages = 1;
    if (pg > totalPages) pg = totalPages;

    // Pagination pour personnes (tab=personnes ou all)
    int pStart = 0, pEnd = 0;
    if ("personnes".equals(tab)) {
        pStart = (pg - 1) * PAGE_SIZE;
        pEnd = Math.min(pStart + PAGE_SIZE, totalPersonnes);
    } else if ("all".equals(tab)) {
        pStart = 0;
        pEnd = Math.min(6, totalPersonnes); // top 6 personnes en mode "all"
    }

    // Pagination pour publications (tab=publications ou all)
    int bStart = 0, bEnd = 0;
    if ("publications".equals(tab)) {
        bStart = (pg - 1) * PAGE_SIZE;
        bEnd = Math.min(bStart + PAGE_SIZE, totalPubs);
    } else if ("all".equals(tab)) {
        bStart = 0;
        bEnd = Math.min(6, totalPubs); // top 6 pubs en mode "all"
    }

    /* ── URL builder ── */
    String baseUrl = _lien + "?but=recherche-global.jsp&q=" + ue(q);
%>

<style>
/* ── Recherche Globale ── */
.rg-wrap { max-width: 900px; margin: 0 auto; padding: 20px 16px 40px; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; color: #1d1d1f; }
.rg-search-box { position: relative; margin-bottom: 20px; }
.rg-search-box input {
    width: 100%; padding: 14px 18px 14px 46px; font-size: 16px; border: 2px solid #e0e0e0;
    border-radius: 12px; background: #fff; box-sizing: border-box; transition: border-color .2s, box-shadow .2s;
    outline: none;
}
.rg-search-box input:focus { border-color: #0a66c2; box-shadow: 0 0 0 3px rgba(10,102,194,.12); }
.rg-search-box i { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); font-size: 18px; color: #999; pointer-events: none; }

/* Tabs */
.rg-tabs { display: flex; gap: 4px; margin-bottom: 20px; border-bottom: 2px solid #eee; padding-bottom: 0; }
.rg-tab {
    padding: 10px 20px; font-size: 14px; font-weight: 600; color: #666; cursor: pointer;
    text-decoration: none; border-bottom: 3px solid transparent; margin-bottom: -2px; transition: all .15s;
    display: inline-flex; align-items: center; gap: 6px;
}
.rg-tab:hover { color: #0a66c2; }
.rg-tab.active { color: #0a66c2; border-bottom-color: #0a66c2; }
.rg-tab .rg-count {
    background: #e8f0fe; color: #0a66c2; font-size: 11px; font-weight: 700;
    padding: 2px 8px; border-radius: 10px;
}

/* Filters bar */
.rg-filters { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 18px; align-items: center; }
.rg-filter-label { font-size: 13px; color: #888; font-weight: 600; }
.rg-filter-select {
    padding: 6px 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px;
    background: #fff; cursor: pointer; outline: none;
}
.rg-filter-select:focus { border-color: #0a66c2; }

/* Section header */
.rg-section { margin-bottom: 28px; }
.rg-section-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; }
.rg-section-title { font-size: 18px; font-weight: 700; display: flex; align-items: center; gap: 8px; }
.rg-section-title i { color: #0a66c2; }
.rg-see-all { font-size: 13px; color: #0a66c2; font-weight: 600; text-decoration: none; }
.rg-see-all:hover { text-decoration: underline; }

/* Personne card */
.rg-persons-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 14px; }
.rg-person {
    display: flex; align-items: center; gap: 14px; padding: 14px 16px;
    background: #fff; border: 1px solid #e8e8e8; border-radius: 12px;
    transition: box-shadow .15s, border-color .15s; text-decoration: none; color: inherit;
}
.rg-person:hover { border-color: #0a66c2; box-shadow: 0 2px 12px rgba(10,102,194,.10); }
.rg-person-avatar {
    width: 48px; height: 48px; border-radius: 50%; background: #0a66c2;
    display: flex; align-items: center; justify-content: center;
    font-size: 16px; font-weight: 700; color: #fff; flex-shrink: 0; overflow: hidden;
}
.rg-person-avatar img { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
.rg-person-info { flex: 1; min-width: 0; }
.rg-person-name { font-size: 14px; font-weight: 700; color: #191919; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.rg-person-meta { font-size: 12px; color: #666; margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.rg-person-badge { font-size: 11px; background: #eef3fb; color: #0a66c2; border-radius: 10px; padding: 2px 8px; font-weight: 600; margin-top: 4px; display: inline-block; }

/* Publication card */
.rg-pubs-list { display: flex; flex-direction: column; gap: 12px; }
.rg-pub {
    background: #fff; border: 1px solid #e8e8e8; border-radius: 12px; padding: 16px 18px;
    transition: box-shadow .15s, border-color .15s;
}
.rg-pub:hover { border-color: #0a66c2; box-shadow: 0 2px 12px rgba(10,102,194,.10); }
.rg-pub-header { display: flex; align-items: center; gap: 12px; margin-bottom: 10px; }
.rg-pub-avatar {
    width: 40px; height: 40px; border-radius: 50%; background: #0a66c2;
    display: flex; align-items: center; justify-content: center;
    font-size: 14px; font-weight: 700; color: #fff; flex-shrink: 0; overflow: hidden;
}
.rg-pub-avatar img { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
.rg-pub-author { font-size: 14px; font-weight: 700; color: #191919; }
.rg-pub-date { font-size: 12px; color: #999; }
.rg-pub-type-badge { font-size: 11px; background: #f0f0f0; color: #555; border-radius: 10px; padding: 2px 8px; font-weight: 600; margin-left: 8px; }
.rg-pub-body { font-size: 14px; color: #333; line-height: 1.55; margin-bottom: 10px; }
.rg-pub-body mark { background: #fff3cd; border-radius: 2px; padding: 0 2px; }
.rg-pub-image { max-width: 100%; max-height: 260px; border-radius: 8px; object-fit: cover; margin-bottom: 10px; }
.rg-pub-footer { display: flex; gap: 16px; font-size: 12px; color: #888; }
.rg-pub-footer i { margin-right: 4px; }

/* Pagination */
.rg-pagination { display: flex; justify-content: center; gap: 6px; margin-top: 24px; }
.rg-page-btn {
    padding: 8px 14px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px;
    font-weight: 600; color: #555; text-decoration: none; transition: all .15s; background: #fff;
}
.rg-page-btn:hover { border-color: #0a66c2; color: #0a66c2; }
.rg-page-btn.active { background: #0a66c2; color: #fff; border-color: #0a66c2; }

/* Empty */
.rg-empty { text-align: center; padding: 60px 20px; color: #aaa; }
.rg-empty i { font-size: 48px; display: block; margin-bottom: 12px; color: #ddd; }
.rg-empty span { font-size: 15px; }

/* Summary */
.rg-summary { font-size: 13px; color: #888; margin-bottom: 16px; }
.rg-summary strong { color: #333; }

@media (max-width: 600px) {
    .rg-persons-grid { grid-template-columns: 1fr; }
    .rg-tabs { overflow-x: auto; }
}
</style>

<div class="rg-wrap">

    <!-- ═══ Barre de recherche ═══ -->
    <form method="GET" action="<%= _lien %>">
        <input type="hidden" name="but" value="recherche-global.jsp">
        <input type="hidden" name="tab" value="<%= h(tab) %>">
        <div class="rg-search-box">
            <i class="bi bi-search"></i>
            <input type="text" name="q" value="<%= h(q) %>" placeholder="Rechercher des personnes, publications..." autofocus>
        </div>
    </form>

    <% if (hasQuery) { %>

    <!-- ═══ Résumé ═══ -->
    <div class="rg-summary">
        <strong><%= totalPersonnes + totalPubs %></strong> r&eacute;sultat<%= (totalPersonnes + totalPubs) > 1 ? "s" : "" %>
        pour &laquo;&nbsp;<strong><%= h(q) %></strong>&nbsp;&raquo;
        &mdash; <strong><%= totalPersonnes %></strong> personne<%= totalPersonnes > 1 ? "s" : "" %>,
        <strong><%= totalPubs %></strong> publication<%= totalPubs > 1 ? "s" : "" %>
    </div>

    <!-- ═══ Tabs ═══ -->
    <div class="rg-tabs">
        <a href="<%= baseUrl %>&tab=all&tri=<%= ue(tri) %>" class="rg-tab<%= "all".equals(tab) ? " active" : "" %>">
            <i class="bi bi-globe2"></i> Tout
            <span class="rg-count"><%= totalPersonnes + totalPubs %></span>
        </a>
        <a href="<%= baseUrl %>&tab=personnes&tri=<%= ue(tri) %>" class="rg-tab<%= "personnes".equals(tab) ? " active" : "" %>">
            <i class="bi bi-people-fill"></i> Personnes
            <span class="rg-count"><%= totalPersonnes %></span>
        </a>
        <a href="<%= baseUrl %>&tab=publications&tri=<%= ue(tri) %>" class="rg-tab<%= "publications".equals(tab) ? " active" : "" %>">
            <i class="bi bi-newspaper"></i> Publications
            <span class="rg-count"><%= totalPubs %></span>
        </a>
    </div>

    <!-- ═══ Filtres ═══ -->
    <form method="GET" action="<%= _lien %>" class="rg-filters">
        <input type="hidden" name="but" value="recherche-global.jsp">
        <input type="hidden" name="q" value="<%= h(q) %>">
        <input type="hidden" name="tab" value="<%= h(tab) %>">
        <span class="rg-filter-label"><i class="bi bi-funnel-fill"></i> Filtrer :</span>
        <select name="tri" class="rg-filter-select" onchange="this.form.submit()">
            <option value="pertinence"<%= "pertinence".equals(tri) ? " selected" : "" %>>Pertinence</option>
            <option value="date"<%= "date".equals(tri) ? " selected" : "" %>>Plus r&eacute;cent</option>
            <option value="nom"<%= "nom".equals(tri) ? " selected" : "" %>>Nom A-Z</option>
        </select>
        <% if ("publications".equals(tab) || "all".equals(tab)) { %>
        <select name="typepub" class="rg-filter-select" onchange="this.form.submit()">
            <option value="">Tous les types</option>
            <% for (int t = 0; t < typesPub.length; t++) { %>
            <option value="<%= typesPub[t].getIdtypepublication() %>"<%= typesPub[t].getIdtypepublication().equals(typePub != null ? typePub : "") ? " selected" : "" %>><%= h(typesPub[t].getLibelle()) %></option>
            <% } %>
        </select>
        <% } %>
    </form>

    <!-- ═══ PERSONNES ═══ -->
    <% if (("all".equals(tab) || "personnes".equals(tab)) && totalPersonnes > 0) { %>
    <div class="rg-section">
        <div class="rg-section-head">
            <div class="rg-section-title"><i class="bi bi-people-fill"></i> Personnes</div>
            <% if ("all".equals(tab) && totalPersonnes > 6) { %>
            <a href="<%= baseUrl %>&tab=personnes&tri=<%= ue(tri) %>" class="rg-see-all">Voir les <%= totalPersonnes %> &rarr;</a>
            <% } %>
        </div>
        <div class="rg-persons-grid">
        <%
            for (int i = pStart; i < pEnd; i++) {
                ProfilLib pp = (ProfilLib) personnes.get(i);
                String pNom    = pp.getNom() != null ? pp.getNom() : "";
                String pPrenom = pp.getPrenom() != null ? pp.getPrenom() : "";
                String pPhoto  = pp.getPhotoProfil() != null && !pp.getPhotoProfil().trim().isEmpty()
                    ? ctx + "/" + pp.getPhotoProfil().trim() : "";
                String pPromo  = pp.getPromotionLib() != null ? pp.getPromotionLib() : "";
                String pParc   = pp.getParcoursLib()  != null ? pp.getParcoursLib()  : "";
                String pGenre  = pp.getGenrelib() != null ? pp.getGenrelib() : "";
                String initials = ((pPrenom.length() > 0 ? pPrenom.substring(0,1) : "") + (pNom.length() > 0 ? pNom.substring(0,1) : "")).toUpperCase();
                String ficheUrl = ctx + "/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp&idprofil=" + pp.getIdprofil();
                boolean isSelf  = (pp.getIdutilisateur() == myRefuser);
                if (isSelf) ficheUrl = ctx + "/pages/module.jsp?but=profil/voir.jsp&currentMenu=MENDYN000009";
        %>
            <a href="<%= ficheUrl %>" class="rg-person">
                <div class="rg-person-avatar">
                    <% if (!pPhoto.isEmpty()) { %><img src="<%= pPhoto %>" alt=""><% } else { %><%= initials %><% } %>
                </div>
                <div class="rg-person-info">
                    <div class="rg-person-name"><%= h(pPrenom + " " + pNom) %></div>
                    <div class="rg-person-meta">
                        <% if (!pParc.isEmpty()) { %><%= h(pParc) %><% } %>
                        <% if (!pPromo.isEmpty()) { %> &middot; <%= h(pPromo) %><% } %>
                    </div>
                    <% if (!pGenre.isEmpty()) { %>
                    <span class="rg-person-badge"><i class="bi <%= pp.getIdgenre() != null && "GEN000001".equals(pp.getIdgenre()) ? "bi-gender-male" : "bi-gender-female" %>"></i> <%= h(pGenre) %></span>
                    <% } %>
                </div>
            </a>
        <% } %>
        </div>
    </div>
    <% } %>

    <!-- ═══ PUBLICATIONS ═══ -->
    <% if (("all".equals(tab) || "publications".equals(tab)) && totalPubs > 0) { %>
    <div class="rg-section">
        <div class="rg-section-head">
            <div class="rg-section-title"><i class="bi bi-newspaper"></i> Publications</div>
            <% if ("all".equals(tab) && totalPubs > 6) { %>
            <a href="<%= baseUrl %>&tab=publications&tri=<%= ue(tri) %>" class="rg-see-all">Voir les <%= totalPubs %> &rarr;</a>
            <% } %>
        </div>
        <div class="rg-pubs-list">
        <%
            for (int i = bStart; i < bEnd; i++) {
                Publication pub = (Publication) pubs.get(i);
                String pid      = pub.getIdpublication();
                String auteur   = (String) pubAuthors.get(pid);
                String aPhoto   = (String) pubPhotos.get(pid);
                String aPhotoUrl = (aPhoto != null) ? ctx + "/" + aPhoto : "";
                String typeLib  = (String) pubTypes.get(pid);
                String mediaUrl = (String) pubMedias.get(pid);
                int reactCnt    = ((Integer) pubReactCnt.get(pid)).intValue();
                int commCnt     = ((Integer) pubCommCnt.get(pid)).intValue();
                String desc     = pub.getDescritpion() != null ? pub.getDescritpion() : "";
                // Highlight search words
                String descHtml = h(desc);
                for (int w = 0; w < qWords.length; w++) {
                    String pattern = "(?i)(" + qWords[w].replace("(","\\(").replace(")","\\)") + ")";
                    descHtml = descHtml.replaceAll(pattern, "<mark>$1</mark>");
                }
                // Tronquer
                if (descHtml.length() > 300) {
                    int cutAt = descHtml.lastIndexOf(' ', 300);
                    if (cutAt < 100) cutAt = 300;
                    descHtml = descHtml.substring(0, cutAt) + "...";
                }
                String dateStr  = pub.getDaty() != null ? pub.getDaty().toString() : "";
                String heureStr = pub.getHeure() != null ? pub.getHeure() : "";
                String pInitials = "";
                if (auteur != null && auteur.length() >= 2) {
                    String[] parts = auteur.split(" ");
                    pInitials = (parts[0].substring(0,1) + (parts.length > 1 ? parts[1].substring(0,1) : "")).toUpperCase();
                }
                String pubLink = ctx + "/pages/module.jsp?but=accueil.jsp&scrollTo=pub-" + pid;
        %>
            <a href="<%= pubLink %>" class="rg-pub" style="text-decoration:none;color:inherit;">
                <div class="rg-pub-header">
                    <div class="rg-pub-avatar">
                        <% if (!aPhotoUrl.isEmpty()) { %><img src="<%= aPhotoUrl %>" alt=""><% } else { %><%= pInitials %><% } %>
                    </div>
                    <div>
                        <div class="rg-pub-author"><%= h(auteur) %>
                            <% if (typeLib != null) { %><span class="rg-pub-type-badge"><%= h(typeLib) %></span><% } %>
                        </div>
                        <div class="rg-pub-date"><i class="bi bi-calendar3"></i> <%= dateStr %> &middot; <%= heureStr %></div>
                    </div>
                </div>
                <div class="rg-pub-body"><%= descHtml %></div>
                <% if (mediaUrl != null && !mediaUrl.isEmpty()) { %>
                <img src="<%= ctx %>/UploadDownloadFileServlet?fname=<%= ue(mediaUrl) %>" alt="" class="rg-pub-image">
                <% } %>
                <div class="rg-pub-footer">
                    <span><i class="bi bi-hand-thumbs-up"></i> <%= reactCnt %> r&eacute;action<%= reactCnt > 1 ? "s" : "" %></span>
                    <span><i class="bi bi-chat-dots"></i> <%= commCnt %> commentaire<%= commCnt > 1 ? "s" : "" %></span>
                </div>
            </a>
        <% } %>
        </div>
    </div>
    <% } %>

    <!-- ═══ Aucun résultat ═══ -->
    <% if (totalPersonnes == 0 && totalPubs == 0) { %>
    <div class="rg-empty">
        <i class="bi bi-search"></i>
        <span>Aucun r&eacute;sultat pour &laquo;&nbsp;<strong><%= h(q) %></strong>&nbsp;&raquo;</span>
        <div style="margin-top:10px;font-size:13px;color:#bbb;">Essayez avec d&apos;autres mots-cl&eacute;s</div>
    </div>
    <% } %>

    <!-- ═══ Pagination ═══ -->
    <% if (!"all".equals(tab) && totalPages > 1) { %>
    <div class="rg-pagination">
        <% if (pg > 1) { %>
        <a href="<%= baseUrl %>&tab=<%= ue(tab) %>&tri=<%= ue(tri) %><%= typePub != null ? "&typepub=" + ue(typePub) : "" %>&pg=<%= pg - 1 %>" class="rg-page-btn">&laquo; Pr&eacute;c</a>
        <% } %>
        <% for (int p = 1; p <= totalPages; p++) { %>
        <a href="<%= baseUrl %>&tab=<%= ue(tab) %>&tri=<%= ue(tri) %><%= typePub != null ? "&typepub=" + ue(typePub) : "" %>&pg=<%= p %>" class="rg-page-btn<%= p == pg ? " active" : "" %>"><%= p %></a>
        <% } %>
        <% if (pg < totalPages) { %>
        <a href="<%= baseUrl %>&tab=<%= ue(tab) %>&tri=<%= ue(tri) %><%= typePub != null ? "&typepub=" + ue(typePub) : "" %>&pg=<%= pg + 1 %>" class="rg-page-btn">Suiv &raquo;</a>
        <% } %>
    </div>
    <% } %>

    <% } else { %>
    <!-- ═══ Pas de recherche ═══ -->
    <div class="rg-empty">
        <i class="bi bi-search"></i>
        <span>Tapez votre recherche pour trouver des personnes et publications</span>
    </div>
    <% } %>

</div>