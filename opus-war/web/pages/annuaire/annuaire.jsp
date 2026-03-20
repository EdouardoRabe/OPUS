<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Promotion" %>
<%@ page import="alumni.Parcours" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="alumni.Specialiteprofil" %>
<%@ page import="alumni.Poste" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.ExperienceLib" %>
<%@ page import="alumni.Visibilite" %>
<%@ page import="alumni.ProfilStatut" %>
<%@ page import="alumni.ProfilTypeStatut" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
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
    /** Verifie si un champ est public pour un profil donne */
    private static boolean isPublic(Map visMap, String idprofil, String champ) {
        Map champMap = (Map) visMap.get(idprofil);
        if (champMap == null) return true; // par defaut = public
        Integer st = (Integer) champMap.get(champ);
        if (st == null) return true; // pas de regle = public
        return st.intValue() == 1;
    }
%>
<%
    /* ==============================
       SESSION & UTILISATEUR CONNECTE
       ============================== */
    String _lien = (String) session.getValue("lien");
    if (_lien == null) _lien = "module.jsp";
    String ctx = request.getContextPath();

    UserEJB uEJB = (UserEJB) session.getAttribute("u");
    MapUtilisateur mu = (uEJB != null) ? uEJB.getUser() : null;
    int myRefuser = (mu != null) ? mu.getRefuser() : -1;
    String myIdprofil = "";

    /* ==============================
       PARAMETRES DE RECHERCHE
       ============================== */
    String qSearch     = request.getParameter("q");
    String qPromotion  = request.getParameter("promotion");
    String qParcours   = request.getParameter("parcours");
    String qEntreprise = request.getParameter("entreprise");
    String qPoste      = request.getParameter("poste");
    String qAnnee      = request.getParameter("annee");
    String qGenre      = request.getParameter("genre");
    String pageParam   = request.getParameter("page");

    // Specialites = multi-select → plusieurs valeurs
    String[] qSpecialites = request.getParameterValues("specialite");

    int pageNum  = 1;
    int pageSize = 12;
    try { if (pageParam != null) pageNum = Integer.parseInt(pageParam); } catch (Exception e) {}
    if (pageNum < 1) pageNum = 1;

    boolean hasSearch    = qSearch != null && !qSearch.trim().isEmpty();
    boolean hasPromotion  = qPromotion != null && !qPromotion.trim().isEmpty();
    boolean hasParcours   = qParcours != null && !qParcours.trim().isEmpty();
    boolean hasEntreprise = qEntreprise != null && !qEntreprise.trim().isEmpty();
    boolean hasPoste      = qPoste != null && !qPoste.trim().isEmpty();
    boolean hasAnnee      = qAnnee != null && !qAnnee.trim().isEmpty();
    boolean hasGenre      = qGenre != null && !qGenre.trim().isEmpty();
    boolean hasSpecialite = qSpecialites != null && qSpecialites.length > 0 && !(qSpecialites.length == 1 && qSpecialites[0].isEmpty());
    boolean hasAdvanced   = hasPromotion || hasParcours || hasSpecialite || hasAnnee || hasEntreprise || hasPoste || hasGenre;

    // Set des specialites selectionnees (pour le multi-select)
    Set selectedSpecs = new HashSet();
    if (hasSpecialite) {
        for (int i = 0; i < qSpecialites.length; i++) {
            if (qSpecialites[i] != null && !qSpecialites[i].isEmpty())
                selectedSpecs.add(qSpecialites[i]);
        }
    }
    hasSpecialite = !selectedSpecs.isEmpty();

    /* ==============================
       CHARGEMENT DES DONNEES
       ============================== */
    Promotion[]  promotions   = new Promotion[0];
    Parcours[]   parcoursList = new Parcours[0];
    Specialite[] specialites  = new Specialite[0];
    Poste[]      postes       = new Poste[0];
    List resultList            = new ArrayList();
    int total = 0, totalPages = 1;

    Map expMap   = new HashMap(); // idprofil -> ExperienceLib
    Map specsMap = new HashMap(); // idprofil -> "Spec1|Spec2"
    Map visMap   = new HashMap(); // idprofil -> { champ -> status }
    Map statutMap = new HashMap(); // idprofil -> {libelle, couleur}

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        // Listes de reference
        promotions   = (Promotion[])  CGenUtil.rechercher(new Promotion(),  null, null, conn, " order by annee desc");
        parcoursList = (Parcours[])   CGenUtil.rechercher(new Parcours(),   null, null, conn, " order by libelle");
        specialites  = (Specialite[]) CGenUtil.rechercher(new Specialite(), null, null, conn, " order by libelle");
        postes       = (Poste[])      CGenUtil.rechercher(new Poste(),      null, null, conn, " order by libelle");
        if (promotions == null)   promotions   = new Promotion[0];
        if (parcoursList == null) parcoursList = new Parcours[0];
        if (specialites == null)  specialites  = new Specialite[0];
        if (postes == null)       postes       = new Poste[0];

        // Trouver mon profil
        if (mu != null) {
            ProfilLib filtre = new ProfilLib();
            ProfilLib[] myRes = (ProfilLib[]) CGenUtil.rechercher(filtre, null, null, conn, " and refuser=" + myRefuser);
            if (myRes != null && myRes.length > 0 && myRes[0].getIdprofil() != null)
                myIdprofil = myRes[0].getIdprofil();
        }

        // Requete ProfilLib
        StringBuilder where = new StringBuilder();
        where.append(" and nom IS NOT NULL and estactif = 1");

        if (hasSearch) {
            String safe = qSearch.trim().toLowerCase().replace("'", "''");
            where.append(" and (LOWER(COALESCE(nom,'') || ' ' || COALESCE(prenom,'')) LIKE '%").append(safe).append("%'")
                .append(" or LOWER(COALESCE(prenom,'') || ' ' || COALESCE(nom,'')) LIKE '%").append(safe).append("%'")
                .append(" or LOWER(loginuser) LIKE '%").append(safe).append("%')");
        }
        if (hasPromotion) {
            where.append(" and idpromotion='").append(qPromotion.trim().replace("'","''")).append("'");
        }
        if (hasParcours) {
            where.append(" and idparcours='").append(qParcours.trim().replace("'","''")).append("'");
        }
        if (hasAnnee) {
            try {
                int annee = Integer.parseInt(qAnnee.trim());
                where.append(" and promotionannee=").append(annee);
            } catch (Exception ignored) {}
        }
        if (hasGenre) {
            where.append(" and idgenre='").append(qGenre.trim().replace("'","''")).append("'");
        }
        where.append(" order by (select count(*) from publication pub where pub.idutilisateur = profillib.refuser and pub.idtypepublication = 'TPB000001') desc, nom, prenom");

        ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, conn, where.toString());
        if (allProfils == null) allProfils = new ProfilLib[0];

        // Filtrage entreprise/poste
        boolean needExpFilter = hasEntreprise || hasPoste;
        List filtered = new ArrayList();

        for (int i = 0; i < allProfils.length; i++) {
            ProfilLib p = allProfils[i];
            if (p.getIdprofil() == null) continue;

            if (needExpFilter) {
                ExperienceLib lastExp = null;
                try {
                    ExperienceLib[] exps = (ExperienceLib[]) CGenUtil.rechercher(
                        new ExperienceLib(), null, null, conn,
                        " and idutilisateur=" + p.getRefuser() + " order by debut desc"
                    );
                    if (exps != null && exps.length > 0) lastExp = exps[0];
                } catch (Exception ignored) {}
                if (lastExp == null) continue;

                if (hasEntreprise && (lastExp.getEntreprise() == null ||
                    !lastExp.getEntreprise().toLowerCase().contains(qEntreprise.trim().toLowerCase())))
                    continue;
                if (hasPoste && (lastExp.getPostelib() == null ||
                    !lastExp.getPostelib().toLowerCase().contains(qPoste.trim().toLowerCase())))
                    continue;
                expMap.put(p.getIdprofil(), lastExp);
            }
            filtered.add(p);
        }

        // Filtrage par specialite(s) : le profil doit avoir au moins UNE des specialites selectionnees
        if (hasSpecialite) {
            List specFiltered = new ArrayList();
            for (int i = 0; i < filtered.size(); i++) {
                ProfilLib p = (ProfilLib) filtered.get(i);
                boolean match = false;
                java.util.Iterator it = selectedSpecs.iterator();
                while (it.hasNext() && !match) {
                    String specId = ((String) it.next()).replace("'","''");
                    try {
                        Specialiteprofil sp = new Specialiteprofil();
                        sp.setIdprofil(p.getIdprofil());
                        sp.setIdspecialite(specId);
                        Specialiteprofil[] found = (Specialiteprofil[]) CGenUtil.rechercher(sp, null, null, conn, "");
                        if (found != null && found.length > 0) match = true;
                    } catch (Exception ignored) {}
                }
                if (match) specFiltered.add(p);
            }
            filtered = specFiltered;
        }

        // Pagination
        total = filtered.size();
        totalPages = (int) Math.ceil((double) total / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (pageNum > totalPages) pageNum = totalPages;
        int startIdx = (pageNum - 1) * pageSize;
        int endIdx   = Math.min(startIdx + pageSize, total);
        for (int i = startIdx; i < endIdx; i++) resultList.add(filtered.get(i));

        // Charger visibilite, experiences, specialites pour la page courante
        for (int i = 0; i < resultList.size(); i++) {
            ProfilLib p = (ProfilLib) resultList.get(i);
            String pid = p.getIdprofil();

            // Visibilite
            try {
                Visibilite vf = new Visibilite();
                vf.setIdprofil(pid);
                Visibilite[] vArr = (Visibilite[]) CGenUtil.rechercher(vf, null, null, conn, "");
                if (vArr != null) {
                    Map champMap = new HashMap();
                    for (int v = 0; v < vArr.length; v++) {
                        if (vArr[v].getChampvisibilite() != null)
                            champMap.put(vArr[v].getChampvisibilite(), new Integer(vArr[v].getStatus()));
                    }
                    visMap.put(pid, champMap);
                }
            } catch (Exception ignored) {}

            // Experience
            if (!expMap.containsKey(pid)) {
                try {
                    ExperienceLib[] exps = (ExperienceLib[]) CGenUtil.rechercher(
                        new ExperienceLib(), null, null, conn,
                        " and idutilisateur=" + p.getRefuser() + " order by debut desc"
                    );
                    if (exps != null && exps.length > 0) expMap.put(pid, exps[0]);
                } catch (Exception ignored) {}
            }

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

            // Statut du profil
            try {
                ProfilStatut psFiltre = new ProfilStatut();
                psFiltre.setIdprofil(pid);
                Object[] psRes = CGenUtil.rechercher(psFiltre, null, null, conn, " order by daty desc limit 1");
                if (psRes != null && psRes.length > 0) {
                    ProfilStatut ps = (ProfilStatut) psRes[0];
                    if (ps.getIdprofiltypestatut() != null) {
                        ProfilTypeStatut ptsFiltre = new ProfilTypeStatut();
                        ptsFiltre.setIdprofiltypestatut(ps.getIdprofiltypestatut());
                        Object[] ptsRes = CGenUtil.rechercher(ptsFiltre, null, null, conn, "");
                        if (ptsRes != null && ptsRes.length > 0) {
                            ProfilTypeStatut pts = (ProfilTypeStatut) ptsRes[0];
                            Map stMap = new HashMap();
                            stMap.put("libelle", pts.getLibelle() != null ? pts.getLibelle() : "");
                            stMap.put("couleur", pts.getCouleur() != null ? pts.getCouleur() : "#0a66c2");
                            statutMap.put(pid, stMap);
                        }
                    }
                }
            } catch (Exception ignored) {}
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }

    /* ==============================
       URL BUILDER POUR PAGINATION
       ============================== */
    StringBuilder baseUrl = new StringBuilder("module.jsp?but=annuaire/annuaire.jsp");
    if (hasSearch)     baseUrl.append("&q=").append(ue(qSearch.trim()));
    if (hasPromotion)  baseUrl.append("&promotion=").append(ue(qPromotion.trim()));
    if (hasParcours)   baseUrl.append("&parcours=").append(ue(qParcours.trim()));
    if (hasAnnee)      baseUrl.append("&annee=").append(ue(qAnnee.trim()));
    if (hasEntreprise) baseUrl.append("&entreprise=").append(ue(qEntreprise.trim()));
    if (hasPoste)      baseUrl.append("&poste=").append(ue(qPoste.trim()));
    if (hasGenre)      baseUrl.append("&genre=").append(ue(qGenre.trim()));
    if (hasSpecialite) {
        java.util.Iterator specIt = selectedSpecs.iterator();
        while (specIt.hasNext()) baseUrl.append("&specialite=").append(ue((String) specIt.next()));
    }
    String _baseUrl = baseUrl.toString();

    String[] gradients = {
        "#1E40AF",
        "#0F766E",
        "#059669",
        "#1E3A5F",
        "#0E7490",
        "#334155"
    };
%>

<style>
/* ═══════════════════════════════════════
   ANNUAIRE v3  /ui-ux-pro-max
   ═══════════════════════════════════════ */
.an-container{max-width:1280px;margin:0 auto;padding:0 16px;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;color:#191919;-webkit-font-smoothing:antialiased}

/* Hero */
.an-hero{background:#1E40AF;border-radius:14px;padding:36px 32px 28px;margin-bottom:22px;position:relative;overflow:hidden;box-shadow:0 8px 32px rgba(10,102,194,.22)}
.an-hero::before{content:'';position:absolute;top:-40%;right:-8%;width:360px;height:360px;background:rgba(255,255,255,.06);border-radius:50%;pointer-events:none}
.an-hero::after{content:'';position:absolute;bottom:-30%;left:-4%;width:240px;height:240px;background:rgba(255,255,255,.04);border-radius:50%;pointer-events:none}
.an-hero-content{position:relative;z-index:1}
.an-hero h1{font-size:28px;font-weight:800;color:#fff;margin:0 0 4px;letter-spacing:-.4px}
.an-hero p{color:rgba(255,255,255,.78);font-size:14px;margin:0 0 22px}

/* Search row */
.an-form-row{display:flex;gap:10px;margin-bottom:14px}
.an-search-input{flex:1;padding:13px 16px 13px 44px;border:none;border-radius:10px;font-size:15px;background:rgba(255,255,255,.96);color:#191919;outline:none;transition:box-shadow .2s;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='%23666' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:14px center}
.an-search-input:focus{box-shadow:0 0 0 3px rgba(255,255,255,.35)}
.an-search-input::placeholder{color:#888}
.an-btn-search{padding:13px 32px;background:#fff;color:#0a66c2;border:none;border-radius:10px;font-size:14px;font-weight:700;cursor:pointer;transition:all .2s;white-space:nowrap}
.an-btn-search:hover{background:#eef3fb;transform:translateY(-1px)}

/* Toggle / Filters */
.an-toggle-filters{background:none;border:1px solid rgba(255,255,255,.45);color:#fff;padding:7px 18px;border-radius:20px;font-size:12px;font-weight:600;cursor:pointer;transition:all .2s;display:inline-flex;align-items:center;gap:6px}
.an-toggle-filters:hover{background:rgba(255,255,255,.14)}
.an-toggle-filters.active{background:rgba(255,255,255,.2);border-color:#fff}
.an-filters-panel{display:none;margin-top:16px;background:rgba(255,255,255,.12);border-radius:12px;padding:18px;backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px)}
.an-filters-panel.show{display:block}
.an-filters-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(170px,1fr));gap:12px}
.an-filter-group label{display:block;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:rgba(255,255,255,.68);margin-bottom:5px}
.an-filter-group select,.an-filter-group input[type="text"],.an-filter-group input[type="number"]{width:100%;padding:9px 12px;border:none;border-radius:8px;font-size:13px;background:rgba(255,255,255,.92);color:#191919;outline:none;box-sizing:border-box;transition:box-shadow .15s}
.an-filter-group select:focus,.an-filter-group input:focus{box-shadow:0 0 0 2px rgba(255,255,255,.5)}
/* Multi-select specialite */
.an-filter-group select[multiple]{min-height:90px;padding:4px}
.an-filter-group select[multiple] option{padding:5px 8px;border-radius:4px;margin:1px 0}
.an-filter-group select[multiple] option:checked{background:#0a66c2;color:#fff}

/* Stats */
.an-stats{display:flex;gap:14px;margin-bottom:18px;flex-wrap:wrap}
.an-stat-item{background:#fff;border:1px solid #e0e0e0;border-radius:12px;padding:16px 22px;flex:1;min-width:130px;text-align:center;box-shadow:0 1px 3px rgba(0,0,0,.04)}
.an-stat-num{font-size:26px;font-weight:800;color:#0a66c2;line-height:1.1}
.an-stat-label{font-size:10px;color:#888;text-transform:uppercase;letter-spacing:.6px;font-weight:600;margin-top:2px}

/* Toolbar */
.an-toolbar{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;flex-wrap:wrap;gap:10px}
.an-result-count{font-size:14px;color:#666}
.an-result-count strong{color:#191919;font-weight:700}
.an-active-filters{display:flex;flex-wrap:wrap;gap:6px;align-items:center}
.an-filter-badge{background:#eef3fb;color:#0a66c2;padding:5px 14px;border-radius:16px;font-size:12px;font-weight:600}
.an-btn-clear{background:none;border:none;color:#c62828;font-size:12px;font-weight:600;cursor:pointer;padding:5px 10px;text-decoration:none}
.an-btn-clear:hover{text-decoration:underline}

/* Grid */
.an-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(330px,1fr));gap:18px;margin-bottom:28px}
@media(max-width:720px){.an-grid{grid-template-columns:1fr}.an-form-row{flex-direction:column}}

/* Card */
.an-card{background:#fff;border:1px solid #e0e0e0;border-radius:12px;overflow:hidden;transition:box-shadow .25s ease,transform .25s ease;display:flex;flex-direction:column}
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

/* Pagination */
.an-pagination{display:flex;justify-content:center;align-items:center;gap:5px;margin:28px 0 44px;flex-wrap:wrap}
.an-page-link{min-width:38px;height:38px;border:1px solid #e0e0e0;background:#fff;color:#555;border-radius:10px;font-size:13px;font-weight:600;display:inline-flex;align-items:center;justify-content:center;text-decoration:none;transition:all .2s;padding:0 6px}
.an-page-link:hover{border-color:#0a66c2;color:#0a66c2;text-decoration:none}
.an-page-link.active{background:#0a66c2;color:#fff;border-color:#0a66c2;pointer-events:none}
.an-page-link.disabled{opacity:.35;pointer-events:none}
.an-page-dots{padding:0 4px;color:#aaa;font-size:14px;user-select:none}

/* Empty */
.an-empty{text-align:center;padding:64px 24px;color:#888}
.an-empty-icon{width:72px;height:72px;margin:0 auto 16px;background:#f5f5f5;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:32px;color:#bbb}
.an-empty h3{font-size:18px;color:#444;margin:0 0 6px;font-weight:700}
.an-empty p{font-size:14px;max-width:400px;margin:0 auto;line-height:1.5}
.an-empty a{color:#0a66c2}
</style>

<div class="an-container">

    <!-- HERO + FORM -->
    <form method="get" action="module.jsp" id="anForm">
        <input type="hidden" name="but" value="annuaire/annuaire.jsp">

        <div class="an-hero">
            <div class="an-hero-content">
                <h1><i class="bi bi-book-fill"></i>&nbsp; Annuaire Alumni</h1>
                <p>Retrouvez et connectez-vous avec les anciens de votre promotion</p>

                <div class="an-form-row">
                    <input type="text" name="q" class="an-search-input"
                           placeholder="Rechercher par nom, pr&eacute;nom ou login..."
                           value="<%= h(hasSearch ? qSearch.trim() : "") %>">
                    <button type="submit" class="an-btn-search">
                        <i class="bi bi-search"></i>&nbsp; Rechercher
                    </button>
                </div>

                <button type="button"
                        class="an-toggle-filters<%= hasAdvanced ? " active" : "" %>"
                        onclick="document.getElementById('anFiltersPanel').classList.toggle('show');this.classList.toggle('active');">
                    <i class="bi bi-sliders"></i> Filtres avanc&eacute;s
                    <% if (hasAdvanced) { %><span style="background:#fff;color:#0a66c2;border-radius:50%;width:18px;height:18px;display:inline-flex;align-items:center;justify-content:center;font-size:10px;font-weight:800;margin-left:2px;">!</span><% } %>
                </button>

                <div class="an-filters-panel<%= hasAdvanced ? " show" : "" %>" id="anFiltersPanel">
                    <div class="an-filters-grid">
                        <div class="an-filter-group">
                            <label>Promotion</label>
                            <select name="promotion">
                                <option value="">Toutes</option>
                                <% for (int i = 0; i < promotions.length; i++) {
                                    String sel = (hasPromotion && qPromotion.trim().equals(promotions[i].getIdpromotion())) ? " selected" : "";
                                %>
                                <option value="<%= h(promotions[i].getIdpromotion()) %>"<%= sel %>>
                                    <%= h(promotions[i].getLibelle()) %> (<%= promotions[i].getAnnee() %>)
                                </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="an-filter-group">
                            <label>Parcours</label>
                            <select name="parcours">
                                <option value="">Tous</option>
                                <% for (int i = 0; i < parcoursList.length; i++) {
                                    String sel = (hasParcours && qParcours.trim().equals(parcoursList[i].getIdparcours())) ? " selected" : "";
                                %>
                                <option value="<%= h(parcoursList[i].getIdparcours()) %>"<%= sel %>>
                                    <%= h(parcoursList[i].getLibelle()) %>
                                </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="an-filter-group">
                            <label>Sp&eacute;cialit&eacute;(s)</label>
                            <select name="specialite" multiple size="4">
                                <% for (int i = 0; i < specialites.length; i++) {
                                    String sel = selectedSpecs.contains(specialites[i].getIdspecialite()) ? " selected" : "";
                                %>
                                <option value="<%= h(specialites[i].getIdspecialite()) %>"<%= sel %>>
                                    <%= h(specialites[i].getLibelle()) %>
                                </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="an-filter-group">
                            <label>Genre</label>
                            <select name="genre">
                                <option value="">Tous</option>
                                <option value="GEN000001"<%= (hasGenre && "GEN000001".equals(qGenre.trim())) ? " selected" : "" %>>Homme</option>
                                <option value="GEN000002"<%= (hasGenre && "GEN000002".equals(qGenre.trim())) ? " selected" : "" %>>Femme</option>
                            </select>
                        </div>
                        <div class="an-filter-group">
                            <label>Ann&eacute;e</label>
                            <input type="number" name="annee" placeholder="Ex: 2024" min="1990" max="2030"
                                   value="<%= h(hasAnnee ? qAnnee.trim() : "") %>">
                        </div>
                        <div class="an-filter-group">
                            <label>Entreprise</label>
                            <input type="text" name="entreprise" placeholder="Nom entreprise..."
                                   value="<%= h(hasEntreprise ? qEntreprise.trim() : "") %>">
                        </div>
                        <div class="an-filter-group">
                            <label>Poste</label>
                            <select name="poste">
                                <option value="">Tous</option>
                                <% for (int i = 0; i < postes.length; i++) {
                                    String sel = (hasPoste && qPoste.trim().equals(postes[i].getLibelle())) ? " selected" : "";
                                %>
                                <option value="<%= h(postes[i].getLibelle()) %>"<%= sel %>>
                                    <%= h(postes[i].getLibelle()) %>
                                </option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <!-- STATS -->
    <div class="an-stats">
        <div class="an-stat-item">
            <div class="an-stat-num"><%= total %></div>
            <div class="an-stat-label">Alumni trouv&eacute;s</div>
        </div>
        <div class="an-stat-item">
            <div class="an-stat-num"><%= totalPages %></div>
            <div class="an-stat-label">Pages</div>
        </div>
        <div class="an-stat-item">
            <div class="an-stat-num"><%= pageNum %></div>
            <div class="an-stat-label">Page actuelle</div>
        </div>
    </div>

    <!-- TOOLBAR / BADGES -->
    <div class="an-toolbar">
        <div class="an-result-count">
            <strong><%= total %></strong> alumni trouv&eacute;<%= (total > 1 ? "s" : "") %>
        </div>
        <div class="an-active-filters">
            <% if (hasSearch) { %><span class="an-filter-badge"><i class="bi bi-search"></i> <%= h(qSearch.trim()) %></span><% } %>
            <% if (hasPromotion) {
                String promoLabel = qPromotion.trim();
                for (int i = 0; i < promotions.length; i++) {
                    if (promotions[i].getIdpromotion().equals(qPromotion.trim())) { promoLabel = promotions[i].getLibelle() + " (" + promotions[i].getAnnee() + ")"; break; }
                }
            %><span class="an-filter-badge"><%= h(promoLabel) %></span><% } %>
            <% if (hasParcours) {
                String parcLabel = qParcours.trim();
                for (int i = 0; i < parcoursList.length; i++) {
                    if (parcoursList[i].getIdparcours().equals(qParcours.trim())) { parcLabel = parcoursList[i].getLibelle(); break; }
                }
            %><span class="an-filter-badge"><%= h(parcLabel) %></span><% } %>
            <% if (hasSpecialite) {
                java.util.Iterator badgeIt = selectedSpecs.iterator();
                while (badgeIt.hasNext()) {
                    String sid = (String) badgeIt.next();
                    String sLabel = sid;
                    for (int i = 0; i < specialites.length; i++) {
                        if (specialites[i].getIdspecialite().equals(sid)) { sLabel = specialites[i].getLibelle(); break; }
                    }
            %><span class="an-filter-badge"><%= h(sLabel) %></span><%
                }
            } %>
            <% if (hasGenre) { %><span class="an-filter-badge"><i class="bi <%= "GEN000001".equals(qGenre.trim()) ? "bi-gender-male" : "bi-gender-female" %>"></i> <%= "GEN000001".equals(qGenre.trim()) ? "Homme" : "Femme" %></span><% } %>
            <% if (hasAnnee) { %><span class="an-filter-badge">Ann&eacute;e : <%= h(qAnnee.trim()) %></span><% } %>
            <% if (hasEntreprise) { %><span class="an-filter-badge">Entreprise : <%= h(qEntreprise.trim()) %></span><% } %>
            <% if (hasPoste) { %><span class="an-filter-badge">Poste : <%= h(qPoste.trim()) %></span><% } %>
            <% if (hasSearch || hasAdvanced) { %><a class="an-btn-clear" href="module.jsp?but=annuaire/annuaire.jsp">Effacer tout</a><% } %>
        </div>
    </div>

    <!-- RESULTATS -->
    <% if (resultList.isEmpty()) { %>
        <div class="an-empty">
            <div class="an-empty-icon"><i class="bi bi-search"></i></div>
            <h3>Aucun r&eacute;sultat</h3>
            <p>Essayez de modifier vos crit&egrave;res de recherche ou
            <a href="module.jsp?but=annuaire/annuaire.jsp">affichez tous les alumni</a>.</p>
        </div>
    <% } else { %>
        <div class="an-grid">
        <% for (int idx = 0; idx < resultList.size(); idx++) {
            ProfilLib p   = (ProfilLib) resultList.get(idx);
            String pid       = p.getIdprofil() != null ? p.getIdprofil() : "";
            int    refuser   = p.getRefuser();
            String loginuser = p.getLoginuser() != null ? p.getLoginuser() : "";
            boolean isSelf   = (refuser == myRefuser);

            // Visibilite : afficher seulement les champs publics (ou tout si c'est soi-meme)
            boolean vNom       = isSelf || isPublic(visMap, pid, "nom");
            boolean vPrenom    = isSelf || isPublic(visMap, pid, "prenom");
            boolean vEmail     = isSelf || isPublic(visMap, pid, "email");
            boolean vPromo     = isSelf || isPublic(visMap, pid, "promotion");
            boolean vParcours  = isSelf || isPublic(visMap, pid, "parcours");
            boolean vSpec      = isSelf || isPublic(visMap, pid, "specialite");
            boolean vExp       = isSelf || isPublic(visMap, pid, "experience");
            boolean vTel       = isSelf || isPublic(visMap, pid, "telephone");
            boolean vGenre     = isSelf || isPublic(visMap, pid, "genre");

            String nom       = (vNom && p.getNom() != null) ? p.getNom() : "";
            String prenom    = (vPrenom && p.getPrenom() != null) ? p.getPrenom() : "";
            String emailP    = (vEmail && p.getEmail() != null) ? p.getEmail() : "";
            String telephone = (vTel && p.getTelephone() != null) ? p.getTelephone() : "";
            String promoLib  = (vPromo && p.getPromotionLib() != null) ? p.getPromotionLib() : "";
            int    promoAn   = vPromo ? p.getPromotionAnnee() : 0;
            String parcLib   = (vParcours && p.getParcoursLib() != null) ? p.getParcoursLib() : "";
            String genreLib  = (vGenre && p.getGenrelib() != null) ? p.getGenrelib() : "";
            String genreId   = (vGenre && p.getIdgenre() != null)  ? p.getIdgenre()  : "";
            
            int contribution = p.getContribution();

            // Si nom cache -> afficher loginuser
            String displayName;
            if (!vNom && !vPrenom) {
                displayName = !loginuser.isEmpty() ? loginuser : "Utilisateur #" + refuser;
            } else {
                displayName = (prenom.isEmpty() ? "" : prenom) + (prenom.isEmpty() || nom.isEmpty() ? "" : " ") + nom;
                if (displayName.trim().isEmpty()) displayName = !loginuser.isEmpty() ? loginuser : "Utilisateur #" + refuser;
            }

            // Photo
            String photoPath = p.getPhotoProfil() != null ? p.getPhotoProfil().trim() : "";
            String photoUrl  = !photoPath.isEmpty() ? (ctx + "/" + photoPath) : "";
            String initials = (
                (prenom.isEmpty() ? (p.getPrenom() != null ? ""+p.getPrenom().charAt(0) : "?") : ""+prenom.charAt(0)) +
                (nom.isEmpty() ? (p.getNom() != null ? ""+p.getNom().charAt(0) : "?") : ""+nom.charAt(0))
            ).toUpperCase();

            // Photo de couverture
            String coverPath = p.getPhotoCouverture() != null ? p.getPhotoCouverture().trim() : "";
            String coverUrl  = !coverPath.isEmpty() ? (ctx + "/" + coverPath) : "";

            // Experience
            ExperienceLib exp = vExp ? (ExperienceLib) expMap.get(pid) : null;
            String expPoste      = (exp != null && exp.getPostelib() != null)  ? exp.getPostelib()  : "";
            String expEntreprise = (exp != null && exp.getEntreprise() != null) ? exp.getEntreprise(): "";

            // Headline
            String headline;
            if (!expPoste.isEmpty() && !expEntreprise.isEmpty()) headline = expPoste + " chez " + expEntreprise;
            else if (!expPoste.isEmpty()) headline = expPoste;
            else if (!expEntreprise.isEmpty()) headline = expEntreprise;
            else if (!parcLib.isEmpty()) headline = parcLib;
            else headline = "Alumni";

            // Specialites
            String specsStr = vSpec ? (String) specsMap.get(pid) : null;
            String[] specsArr = (specsStr != null && !specsStr.isEmpty()) ? specsStr.split("\\|") : new String[0];

            String grad = gradients[idx % gradients.length];

            // Lien: si c'est moi → voir.jsp, sinon → fiche-utilisateur.jsp
            String profilLink;
            if (isSelf) {
                profilLink = _lien + "?but=profil/voir.jsp&idprofil=" + ue(pid);
            } else {
                profilLink = _lien + "?but=annuaire/fiche-utilisateur.jsp&idprofil=" + ue(pid);
            }
        %>
            <div class="an-card">
                <div class="an-card-header">
                    <div class="an-card-cover" style="background:<%= grad %>;">
                        <% if (!coverUrl.isEmpty()) { %><img src="<%= h(coverUrl) %>" alt="" style="width:100%;height:100%;object-fit:cover;display:block;"><% } %>
                    </div>
                    <span class="an-card-refuser"><%= h(!loginuser.isEmpty() ? loginuser : "REF " + refuser) %></span>
            <%
                // Couleur et libelle de statut pour l'anneau et le titre
                String _avatarRingColor = "#0a66c2";
                String _avatarStatutLib = "";
                Map _stInfoAvatar = (Map) statutMap.get(pid);
                if (_stInfoAvatar != null) {
                    if (_stInfoAvatar.get("couleur") != null && !((String)_stInfoAvatar.get("couleur")).isEmpty()) {
                        _avatarRingColor = (String) _stInfoAvatar.get("couleur");
                    }
                    if (_stInfoAvatar.get("libelle") != null) {
                        _avatarStatutLib = (String) _stInfoAvatar.get("libelle");
                    }
                }
            %>
                    <div class="an-card-avatar" style="box-shadow:0 0 0 3px <%= _avatarRingColor %>, 0 2px 12px rgba(0,0,0,.18);<%= !photoUrl.isEmpty() ? "background:transparent;" : "" %>" title="<%= h(_avatarStatutLib) %>">
                        <% if (!photoUrl.isEmpty()) { %><img src="<%= h(photoUrl) %>" alt="<%= h(displayName) %>"><% } else { %><%= initials %><% } %>
                    </div>
                </div>
                <div class="an-card-body">
                    <div class="an-card-name"><a href="<%= h(profilLink) %>"><%= h(displayName) %></a></div>
                    <div class="an-card-headline"><%= h(headline) %></div>
                    <div class="an-card-meta">
                        <% if (!genreLib.isEmpty()) { %><span class="an-card-tag" style="background:#f3e8ff;color:#7c3aed;"><i class="bi <%= "GEN000001".equals(genreId) ? "bi-gender-male" : "bi-gender-female" %>"></i> <%= h(genreLib) %></span><% } %>
                         <span class="an-card-tag" style="background:#fff8e1;color:#f57f17;" title="Contribution (publications)"><i class="bi bi-award-fill"></i> <%= contribution %></span>
                        <% if (!promoLib.isEmpty()) { %><span class="an-card-tag promo"><%= h(promoLib) %><%= promoAn > 0 ? " " + promoAn : "" %></span><% } %>
                        <% if (!parcLib.isEmpty()) { %><span class="an-card-tag"><%= h(parcLib) %></span><% } %>
                        <% for (int s = 0; s < specsArr.length && s < 2; s++) { %><span class="an-card-tag spec"><%= h(specsArr[s]) %></span><% } %>
                    </div>
                    <% if (!expPoste.isEmpty() || !expEntreprise.isEmpty()) { %>
                    <div class="an-card-exp">
                        <div class="an-card-exp-icon"><i class="bi bi-briefcase-fill"></i></div>
                        <div class="an-card-exp-text">
                            <% if (!expPoste.isEmpty()) { %><div class="an-card-exp-title"><%= h(expPoste) %></div><% } %>
                            <% if (!expEntreprise.isEmpty()) { %><div class="an-card-exp-company"><%= h(expEntreprise) %></div><% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
                <div class="an-card-footer">
                    <a class="an-btn-profile" href="<%= h(profilLink) %>"><%= isSelf ? "Mon profil" : "Voir le profil" %></a>
                    <div class="an-card-contact">
                        <% if (!emailP.isEmpty()) { %><a href="mailto:<%= h(emailP) %>" title="<%= h(emailP) %>"><i class="bi bi-envelope-fill"></i></a><% } %>
                        <% if (!telephone.isEmpty()) { %><a href="tel:<%= h(telephone) %>" title="<%= h(telephone) %>"><i class="bi bi-telephone-fill"></i></a><% } %>
                    </div>
                </div>
            </div>
        <% } %>
        </div>
    <% } %>

    <!-- PAGINATION -->
    <% if (totalPages > 1) {
        int pStart = Math.max(1, pageNum - 2);
        int pEnd   = Math.min(totalPages, pageNum + 2);
    %>
    <div class="an-pagination">
        <a class="an-page-link<%= (pageNum <= 1 ? " disabled" : "") %>" href="<%= _baseUrl %>&amp;page=<%= pageNum - 1 %>">&laquo;</a>
        <% if (pStart > 1) { %><a class="an-page-link" href="<%= _baseUrl %>&amp;page=1">1</a><% if (pStart > 2) { %><span class="an-page-dots">&hellip;</span><% } } %>
        <% for (int pg = pStart; pg <= pEnd; pg++) { %><a class="an-page-link<%= (pg == pageNum ? " active" : "") %>" href="<%= _baseUrl %>&amp;page=<%= pg %>"><%= pg %></a><% } %>
        <% if (pEnd < totalPages) { %><% if (pEnd < totalPages - 1) { %><span class="an-page-dots">&hellip;</span><% } %><a class="an-page-link" href="<%= _baseUrl %>&amp;page=<%= totalPages %>"><%= totalPages %></a><% } %>
        <a class="an-page-link<%= (pageNum >= totalPages ? " disabled" : "") %>" href="<%= _baseUrl %>&amp;page=<%= pageNum + 1 %>">&raquo;</a>
    </div>
    <% } %>

</div>
