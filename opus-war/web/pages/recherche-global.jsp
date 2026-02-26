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
<%@ page import="java.util.Base64" %>
<%@ page import="alumni.ExperienceLib" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="alumni.Specialiteprofil" %>
<%@ page import="alumni.Promotion" %>
<%@ page import="alumni.Parcours" %>
<%@ page import="alumni.Poste" %>
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

    String[] gradients = {
        "linear-gradient(135deg,#003366 0%,#0a66c2 60%,#378fe9 100%)",
        "linear-gradient(135deg,#1a237e 0%,#283593 60%,#5c6bc0 100%)",
        "linear-gradient(135deg,#004d40 0%,#00695c 60%,#26a69a 100%)",
        "linear-gradient(135deg,#4a148c 0%,#6a1b9a 60%,#ab47bc 100%)",
        "linear-gradient(135deg,#880e4f 0%,#ad1457 60%,#ec407a 100%)",
        "linear-gradient(135deg,#e65100 0%,#ef6c00 60%,#ffa726 100%)"
    };

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        /* ── Types de publication (pour le filtre) ── */
        typesPub = (Typepublication[]) CGenUtil.rechercher(
            new Typepublication(), null, null, conn, " order by libelle");
        if (typesPub == null) typesPub = new Typepublication[0];

        /* ── Lookup noms + photos ── */
        ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(
            new ProfilLib(), null, null, conn, " and estactif = 1");
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
            {
                // Construire WHERE : support nom complet (concatenation)
                StringBuilder where = new StringBuilder(" and estactif = 1");
                String safeOrig = q.trim().replace("'", "''").toLowerCase();
                where.append(" and (LOWER(COALESCE(nom,'') || ' ' || COALESCE(prenom,'')) LIKE '%").append(safeOrig).append("%'")
                     .append(" or LOWER(COALESCE(prenom,'') || ' ' || COALESCE(nom,'')) LIKE '%").append(safeOrig).append("%'")
                     .append(" or LOWER(loginuser) LIKE '%").append(safeOrig).append("%'")
                     .append(" or LOWER(promotionlib) LIKE '%").append(safeOrig).append("%'")
                     .append(" or LOWER(parcourslib) LIKE '%").append(safeOrig).append("%')");
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
            {
                StringBuffer where = new StringBuffer(" and etat = 1 and idutilisateur in (select refuser from utilisateur where estactif = 1)");
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
                    pubCommCnt.put(p.getIdpublication(), new Integer(0)); // Sera rempli par la suite pour la page courante
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
    if ("publications".equals(tab) || "all".equals(tab)) {
        bStart = "publications".equals(tab) ? (pg - 1) * PAGE_SIZE : 0;
        bEnd = "publications".equals(tab) ? Math.min(bStart + PAGE_SIZE, totalPubs) : Math.min(6, totalPubs);
    }

    // Données additionnelles pour les publications de la page courante
    if (!pubs.isEmpty()) {
        try {
            conn = new UtilDB().GetConn();
            for (int i = bStart; i < bEnd; i++) {
                Publication p = (Publication) pubs.get(i);
                String idpub = p.getIdpublication();
                // Media
                Media[] ms = (Media[]) CGenUtil.rechercher(new Media(), null, null, conn, " and idpublication = '" + idpub + "'");
                if (ms != null && ms.length > 0 && ms[0].getMediaurl() != null) pubMedias.put(idpub, ms[0].getMediaurl());
                // Reactions
                Publicationreaction[] rs = (Publicationreaction[]) CGenUtil.rechercher(new Publicationreaction(), null, null, conn, " and idpublication = '" + idpub + "'");
                pubReactCnt.put(idpub, new Integer(rs != null ? rs.length : 0));
                // Comments
                Publicationcommentaire[] cs = (Publicationcommentaire[]) CGenUtil.rechercher(new Publicationcommentaire(), null, null, conn, " and idpublication = '" + idpub + "' and etat = 1");
                pubCommCnt.put(idpub, new Integer(cs != null ? cs.length : 0));
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conn != null) try { conn.close(); } catch (Exception ignore) {} }
    }

    // Données additionnelles pour les cards personnes de la page courante
    Map expMap   = new HashMap(); // idprofil -> ExperienceLib
    Map specsMap = new HashMap(); // idprofil -> "Spec1|Spec2"
    if (!personnes.isEmpty()) {
        try {
            conn = new UtilDB().GetConn();
            for (int i = pStart; i < pEnd; i++) {
                ProfilLib p = (ProfilLib) personnes.get(i);
                String pid = p.getIdprofil();
                // Experience
                try {
                    ExperienceLib[] exps = (ExperienceLib[]) CGenUtil.rechercher(
                        new ExperienceLib(), null, null, conn,
                        " and idutilisateur=" + p.getRefuser() + " order by debut desc"
                    );
                    if (exps != null && exps.length > 0) expMap.put(pid, exps[0]);
                } catch (Exception ignored) {}
                // Specialites
                try {
                    Specialiteprofil spf = new Specialiteprofil();
                    spf.setIdprofil(pid);
                    Specialiteprofil[] spArr = (Specialiteprofil[]) CGenUtil.rechercher(spf, null, null, conn, "");
                    if (spArr != null && spArr.length > 0) {
                        StringBuilder sb = new StringBuilder();
                        for (int s = 0; s < spArr.length && s < 3; s++) {
                            Specialite spec = new Specialite();
                            spec.setIdspecialite(spArr[s].getIdspecialite());
                            Specialite[] specRes = (Specialite[]) CGenUtil.rechercher(spec, null, null, conn, "");
                            if (specRes != null && specRes.length > 0) {
                                if (sb.length() > 0) sb.append("|");
                                sb.append(specRes[0].getLibelle());
                            }
                        }
                        specsMap.put(pid, sb.toString());
                    }
                } catch (Exception ignored) {}
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conn != null) try { conn.close(); } catch (Exception ignore) {} }
    }

    /* ── URL builder ── */
    String baseUrl = _lien + "?but=recherche-global.jsp&q=" + ue(q);
%>

<style>
/* ── Recherche Globale ── */
:root {
    --fa-bg: #f0f2f5;
    --fa-card-bg: #ffffff;
    --fa-border: #e4e6eb;
    --fa-text: #050505;
    --fa-text-secondary: #65676b;
    --itu-blue: #008BFF;
}
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
/* Card Annuaire Integration */
.rg-persons-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(330px, 1fr)); gap: 18px; }
.an-card{background:#fff;border:1px solid #e0e0e0;border-radius:12px;overflow:hidden;transition:box-shadow .25s ease,transform .25s ease;display:flex;flex-direction:column;text-decoration:none;color:inherit;}
.an-card:hover{box-shadow:0 6px 24px rgba(0,0,0,.12);transform:translateY(-3px)}
.an-card-header{position:relative;flex-shrink:0}
.an-card-cover{height:72px;overflow:hidden}
.an-card-avatar{position:absolute;left:20px;bottom:-30px;width:64px;height:64px;border-radius:50%;border:3.5px solid #fff;background:#0a66c2;display:flex;align-items:center;justify-content:center;font-size:21px;font-weight:700;color:#fff;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,.18);z-index:2;line-height:1;letter-spacing:1px}
.an-card-avatar img{width:100%;height:100%;object-fit:cover;display:block;border-radius:50%}
.an-card-refuser{position:absolute;top:8px;right:12px;background:rgba(0,0,0,.45);color:#fff;padding:3px 10px;border-radius:10px;font-size:10px;font-weight:700;letter-spacing:.5px;backdrop-filter:blur(4px)}
.an-card-body{padding:38px 20px 14px;flex:1}
.an-card-name{font-size:16px;font-weight:700;color:#191919;margin-bottom:2px;line-height:1.3}
.an-card-name a{color:inherit;text-decoration:none}
.an-card-name a:hover{color:#0a66c2}
.an-card-headline{font-size:13px;color:#666;margin-bottom:10px;line-height:1.45;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
.an-card-meta{display:flex;flex-wrap:wrap;gap:5px;margin-bottom:10px}
.an-card-tag{background:#f0f0f0;color:#555;padding:3px 11px;border-radius:12px;font-size:11px;font-weight:600;white-space:nowrap}
.an-card-tag.promo{background:#eef3fb;color:#0a66c2}
.an-card-tag.spec{background:#e8f5e9;color:#2e7d32}
.an-card-tag.hidden-field{background:#fff3e0;color:#e65100;font-style:italic}
.an-card-exp{border-top:1px solid #f0f0f0;padding-top:10px;margin-top:4px;display:flex;align-items:flex-start;gap:8px}
.an-card-exp-icon{flex-shrink:0;width:28px;height:28px;border-radius:6px;background:#f5f5f5;display:flex;align-items:center;justify-content:center;font-size:13px;color:#888;margin-top:1px}
.an-card-exp-text{flex:1;min-width:0}
.an-card-exp-title{font-size:12px;font-weight:600;color:#333;line-height:1.3;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.an-card-exp-company{font-size:11px;color:#888;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.an-card-footer{padding:11px 20px;border-top:1px solid #f0f0f0;display:flex;justify-content:space-between;align-items:center}
.an-btn-profile{padding:7px 20px;background:transparent;color:#0a66c2;border:1.5px solid #0a66c2;border-radius:22px;font-size:12px;font-weight:700;cursor:pointer;transition:all .2s;text-decoration:none;display:inline-block}
.an-btn-profile:hover{background:#0a66c2;color:#fff;text-decoration:none}
.an-card-contact{display:flex;gap:6px}
.an-card-contact a{width:32px;height:32px;border-radius:50%;background:#f5f5f5;display:flex;align-items:center;justify-content:center;color:#555;text-decoration:none;font-size:14px;transition:all .2s}
.an-card-contact a:hover{background:#eef3fb;color:#0a66c2}

/* Publication card (Standardized with publication.jsp) */
.rg-pubs-list { display: flex; flex-direction: column; gap: 16px; }
.fa-avatar { display: inline-flex; align-items: center; justify-content: center; border-radius: 50%; font-weight: 700; color: #fff; flex-shrink: 0; background: linear-gradient(135deg, #362F4F 0%, #008BFF 100%); overflow: hidden; }
.fa-avatar--sm { width: 36px; height: 36px; font-size: 13px; }
.fa-avatar--md { width: 44px; height: 44px; font-size: 16px; }

.fa-post-card { background: var(--fa-card-bg); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.12); overflow: hidden; border: 1px solid var(--fa-border); }
.fa-post-header { display: flex; align-items: flex-start; gap: 10px; padding: 14px 16px 8px; position: relative; text-align: left; }
.fa-post-meta { flex: 1; min-width: 0; }
.fa-post-author { font-weight: 700; font-size: 15px; color: var(--fa-text); }
.fa-post-date { font-size: 12px; color: var(--fa-text-secondary); margin-top: 2px; display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
.fa-type-badge { display: inline-block; background: #f0f2f5; color: var(--itu-blue); font-size: 11px; font-weight: 600; padding: 2px 8px; border-radius: 10px; }
.fa-post-body { padding: 4px 16px 12px; text-align: left; }
.fa-post-text { font-size: 15px; color: var(--fa-text); line-height: 1.5; margin: 0 0 8px; }
.fa-post-img { width: 100%; max-height: 500px; object-fit: cover; display: block; border-radius: 8px; margin-top: 8px; }
.fa-post-counters { display: flex; align-items: center; justify-content: space-between; padding: 6px 16px; font-size: 13px; color: var(--fa-text-secondary); min-height: 28px; }
.fa-counter { display: flex; align-items: center; gap: 4px; }
.fa-post-divider { height: 1px; background: var(--fa-border); margin: 0 16px; }
.fa-post-actions { display: flex; padding: 4px 8px; gap: 2px; }
.fa-action-btn { flex: 1; display: flex; align-items: center; justify-content: center; gap: 6px; padding: 8px 4px; background: none; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; color: var(--fa-text-secondary); cursor: pointer; transition: background .15s; text-decoration: none; }
.fa-action-btn:hover { background: #f0f2f5; color: var(--fa-text); }

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
                String pid      = pp.getIdprofil();
                String pNom     = pp.getNom() != null ? pp.getNom() : "";
                String pPrenom  = pp.getPrenom() != null ? pp.getPrenom() : "";
                String pPhoto   = pp.getPhotoProfil() != null && !pp.getPhotoProfil().trim().isEmpty()
                    ? ctx + "/" + pp.getPhotoProfil().trim() : "";
                String pPromo   = pp.getPromotionLib() != null ? pp.getPromotionLib() : "";
                int pPromoAn    = pp.getPromotionAnnee();
                String pParc    = pp.getParcoursLib()  != null ? pp.getParcoursLib()  : "";
                String pGenre   = pp.getGenrelib() != null ? pp.getGenrelib() : "";
                String gId      = pp.getIdgenre() != null ? pp.getIdgenre() : "";
                String initials = ((pPrenom.length() > 0 ? pPrenom.substring(0,1) : "") + (pNom.length() > 0 ? pNom.substring(0,1) : "")).toUpperCase();
                String ficheUrl = ctx + "/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp&idprofil=" + pid;
                boolean isSelf  = (pp.getIdutilisateur() == myRefuser);
                if (isSelf) ficheUrl = ctx + "/pages/module.jsp?but=profil/voir.jsp&currentMenu=MENDYN000009";
                
                int contrib = 0; try { contrib = pp.getContribution(); } catch(Exception e){}
                
                ExperienceLib exp = (ExperienceLib) expMap.get(pid);
                String expP = "";
                String expE = "";
                if (exp != null) {
                    expP = exp.getPostelib() != null ? exp.getPostelib() : "";
                    expE = exp.getEntreprise() != null ? exp.getEntreprise() : "";
                }
                
                String headline = "";
                if (!expP.isEmpty() && !expE.isEmpty()) headline = expP + " chez " + expE;
                else if (!expP.isEmpty()) headline = expP;
                else if (!expE.isEmpty()) headline = expE;
                else if (!pParc.isEmpty()) headline = pParc;
                else headline = "Alumni";

                String specsStr = (String) specsMap.get(pid);
                String[] specsArr = (specsStr != null && !specsStr.isEmpty()) ? specsStr.split("\\|") : new String[0];
                String grad = gradients[i % gradients.length];
        %>
            <div class="an-card">
                <div class="an-card-header">
                    <div class="an-card-cover" style="background:<%= grad %>;"></div>
                    <span class="an-card-refuser"><%= h(pp.getLoginuser() != null && !pp.getLoginuser().isEmpty() ? pp.getLoginuser() : "REF " + pp.getRefuser()) %></span>
                    <div class="an-card-avatar"<%= !pPhoto.isEmpty() ? " style=\"background:transparent;\"" : "" %>>
                        <% if (!pPhoto.isEmpty()) { %><img src="<%= pPhoto %>" alt="<%= h(pPrenom + " " + pNom) %>"><% } else { %><%= initials %><% } %>
                    </div>
                </div>
                <div class="an-card-body">
                    <div class="an-card-name"><a href="<%= ficheUrl %>"><%= h(pPrenom + " " + pNom) %></a></div>
                    <div class="an-card-headline"><%= h(headline) %></div>
                    <div class="an-card-meta">
                        <% if (!pGenre.isEmpty()) { %><span class="an-card-tag" style="background:#f3e8ff;color:#7c3aed;"><i class="bi <%= "GEN000001".equals(gId) ? "bi-gender-male" : "bi-gender-female" %>"></i> <%= h(pGenre) %></span><% } %>
                        <span class="an-card-tag" style="background:#fff8e1;color:#f57f17;" title="Contribution (publications)"><i class="bi bi-award-fill"></i> <%= contrib %></span>
                        <% if (!pPromo.isEmpty()) { %><span class="an-card-tag promo"><%= h(pPromo) %><%= pPromoAn > 0 ? " " + pPromoAn : "" %></span><% } %>
                        <% if (!pParc.isEmpty()) { %><span class="an-card-tag"><%= h(pParc) %></span><% } %>
                        <% for (int s = 0; s < specsArr.length && s < 2; s++) { %><span class="an-card-tag spec"><%= h(specsArr[s]) %></span><% } %>
                    </div>
                    <% if (!expP.isEmpty() || !expE.isEmpty()) { %>
                    <div class="an-card-exp">
                        <div class="an-card-exp-icon"><i class="bi bi-briefcase-fill"></i></div>
                        <div class="an-card-exp-text">
                            <% if (!expP.isEmpty()) { %><div class="an-card-exp-title"><%= h(expP) %></div><% } %>
                            <% if (!expE.isEmpty()) { %><div class="an-card-exp-company"><%= h(expE) %></div><% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
                <div class="an-card-footer">
                    <a class="an-btn-profile" href="<%= ficheUrl %>"><%= isSelf ? "Mon profil" : "Voir le profil" %></a>
                    <div class="an-card-contact">
                        <% if (pp.getEmail() != null && !pp.getEmail().isEmpty()) { %><a href="mailto:<%= h(pp.getEmail()) %>" title="<%= h(pp.getEmail()) %>"><i class="bi bi-envelope-fill"></i></a><% } %>
                        <% if (pp.getTelephone() != null && !pp.getTelephone().isEmpty()) { %><a href="tel:<%= h(pp.getTelephone()) %>" title="<%= h(pp.getTelephone()) %>"><i class="bi bi-telephone-fill"></i></a><% } %>
                    </div>
                </div>
            </div>
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
            <div class="fa-post-card">
                <div class="fa-post-header">
                    <div class="fa-avatar fa-avatar--md" style="<%= !aPhotoUrl.isEmpty() ? "background:transparent;" : "" %>">
                        <% if (!aPhotoUrl.isEmpty()) { %><img src="<%= aPhotoUrl %>" alt="" style="width:100%;height:100%;object-fit:cover;"><% } else { %><%= pInitials %><% } %>
                    </div>
                    <div class="fa-post-meta">
                        <div class="fa-post-author"><%= h(auteur) %></div>
                        <div class="fa-post-date">
                            <%= dateStr %> &middot; <%= heureStr %>
                            <% if (typeLib != null) { %><span class="fa-type-badge"><%= h(typeLib) %></span><% } %>
                        </div>
                    </div>
                </div>
                <div class="fa-post-body">
                    <div class="fa-post-text"><%= descHtml %></div>
                    <% if (mediaUrl != null && !mediaUrl.isEmpty()) { %>
                    <img src="<%= ctx %>/UploadDownloadFileServlet?fname=<%= ue(mediaUrl) %>" alt="" class="fa-post-img">
                    <% } %>
                </div>
                <div class="fa-post-counters">
                    <span class="fa-counter"><i class="bi bi-hand-thumbs-up"></i> <%= reactCnt %></span>
                    <span class="fa-counter"><%= commCnt %> commentaire<%= commCnt > 1 ? "s" : "" %></span>
                </div>
                <div class="fa-post-divider"></div>
                <div class="fa-post-actions">
                    <a href="<%= pubLink %>" class="fa-action-btn">
                        <i class="bi bi-eye"></i> Voir
                    </a>
                    <a href="<%= pubLink %>" class="fa-action-btn">
                        <i class="bi bi-chat-left-text"></i> Commenter
                    </a>
                </div>
            </div>
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