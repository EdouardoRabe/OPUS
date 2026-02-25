<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.ProfilStatut" %>
<%@ page import="alumni.ProfilTypeStatut" %>
<%@ page import="alumni.ExperienceLib" %>
<%@ page import="alumni.Visibilite" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="alumni.Specialiteprofil" %>
<%@ page import="alumni.ReseauSocial" %>
<%@ page import="alumni.ProfilSocialMedia" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%!
    private static String h(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
    }
    private static boolean isPublic(Map champMap, String champ) {
        if (champMap == null) return true;
        Integer st = (Integer) champMap.get(champ);
        if (st == null) return true;
        return st.intValue() == 1;
    }
%>
<%
    /* ==============================
       SESSION & PARAMETRE
       ============================== */
    String _lien = (String) session.getValue("lien");
    if (_lien == null) _lien = "module.jsp";
    String ctx = request.getContextPath();

    UserEJB uEJB = (UserEJB) session.getAttribute("u");
    MapUtilisateur mu = (uEJB != null) ? uEJB.getUser() : null;
    int myRefuser = (mu != null) ? mu.getRefuser() : -1;

    String idprofil = request.getParameter("idprofil");
    if (idprofil == null || idprofil.trim().isEmpty()) {
%>
<div style="text-align:center;padding:60px 20px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#888">
    <h3 style="color:#444">Profil introuvable</h3>
    <p>Aucun identifiant de profil fourni.</p>
    <a href="javascript:void(0)" onclick="window.history.back()" style="color:#0a66c2;cursor:pointer;">← Retour</a>
</div>
<% return; } %>
<%
    idprofil = idprofil.trim();

    ProfilLib profil = null;
    ExperienceLib[] experiences = null;
    ReseauSocial[] allReseaux = null;
    ProfilSocialMedia[] socialMedias = null;
    Map champVis = new HashMap(); // champ -> status
    List specLabels = new ArrayList(); // specialite libelles
    String _erreur = null;
    
    // Statut du profil
    String _statutColor = "#0a66c2"; // couleur par défaut
    String _statutLibelle = "";

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        /* --- Charger le profil --- */
        ProfilLib filtre = new ProfilLib();
        filtre.setIdprofil(idprofil);
        ProfilLib[] res = (ProfilLib[]) CGenUtil.rechercher(filtre, null, null, conn, "");
        if (res != null && res.length > 0) profil = res[0];

        if (profil != null) {
            /* --- Redirect si l'utilisateur est banni --- */
            if (profil.getEstactif() == 0) {
%>
<script>
    alert("Ce profil n'est plus disponible");
    window.location.href = "<%= ctx %>/pages/module.jsp?but=accueil.jsp";
</script>
<%
                return;
            }

            /* --- Redirect si c'est son propre profil --- */
            if (profil.getRefuser() == myRefuser) {
                    %>
                    <script>window.location.href = "<%= _lien %>?but=profil/voir.jsp&idprofil=<%= h(idprofil) %>";</script>
                    <%
                return;
            }

            /* --- Charger Visibilite --- */
            Visibilite vf = new Visibilite();
            vf.setIdprofil(idprofil);
            Visibilite[] vArr = (Visibilite[]) CGenUtil.rechercher(vf, null, null, conn, "");
            if (vArr != null) {
                for (int i = 0; i < vArr.length; i++) {
                    if (vArr[i].getChampvisibilite() != null)
                        champVis.put(vArr[i].getChampvisibilite(), new Integer(vArr[i].getStatus()));
                }
            }

            /* --- Charger Experiences --- */
            if (isPublic(champVis, "experience")) {
                experiences = (ExperienceLib[]) CGenUtil.rechercher(
                    new ExperienceLib(), null, null, conn,
                    " and idutilisateur=" + profil.getRefuser() + " order by debut desc"
                );
            }

            /* --- Charger Specialites si public --- */
            if (isPublic(champVis, "specialite")) {
                Specialiteprofil spf = new Specialiteprofil();
                spf.setIdprofil(idprofil);
                Specialiteprofil[] spArr = (Specialiteprofil[]) CGenUtil.rechercher(spf, null, null, conn, "");
                if (spArr != null) {
                    for (int i = 0; i < spArr.length; i++) {
                        Specialite spec = new Specialite();
                        spec.setIdspecialite(spArr[i].getIdspecialite());
                        Specialite[] sRes = (Specialite[]) CGenUtil.rechercher(spec, null, null, conn, "");
                        if (sRes != null && sRes.length > 0 && sRes[0].getLibelle() != null)
                            specLabels.add(sRes[0].getLibelle());
                    }
                }
            }

            // charger réseaux sociaux si public
            if (isPublic(champVis, "socialmedia")) {
                allReseaux = (ReseauSocial[]) CGenUtil.rechercher(new ReseauSocial(), null, null, conn, " and actif=1 order by priorite desc");
                ProfilSocialMedia smf = new ProfilSocialMedia();
                smf.setIdprofil(idprofil);
                socialMedias = (ProfilSocialMedia[]) CGenUtil.rechercher(smf, null, null, conn, "");
            }
            
            // Charger le statut du profil
            try {
                ProfilStatut psFiltre = new ProfilStatut();
                psFiltre.setIdprofil(idprofil);
                Object[] psRes = CGenUtil.rechercher(psFiltre, null, null, conn, " order by daty desc limit 1");
                if (psRes != null && psRes.length > 0) {
                    ProfilStatut ps = (ProfilStatut) psRes[0];
                    if (ps.getIdprofiltypestatut() != null) {
                        ProfilTypeStatut ptsFiltre = new ProfilTypeStatut();
                        ptsFiltre.setIdprofiltypestatut(ps.getIdprofiltypestatut());
                        Object[] ptsRes = CGenUtil.rechercher(ptsFiltre, null, null, conn, "");
                        if (ptsRes != null && ptsRes.length > 0) {
                            ProfilTypeStatut pts = (ProfilTypeStatut) ptsRes[0];
                            if (pts.getCouleur() != null && !pts.getCouleur().isEmpty()) {
                                _statutColor = pts.getCouleur();
                            }
                            if (pts.getLibelle() != null) {
                                _statutLibelle = pts.getLibelle();
                            }
                        }
                    }
                }
            } catch (Exception estatut) {
                System.err.println("fiche-utilisateur.jsp - erreur chargement statut: " + estatut.getMessage());
            }
        }
    } catch (Exception e) {
        _erreur = e.getMessage();
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }

    if (allReseaux == null) allReseaux = new ReseauSocial[0];
    if (socialMedias == null) socialMedias = new ProfilSocialMedia[0];

    if (profil == null) {
%>
<div style="text-align:center;padding:60px 20px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#888">
    <h3 style="color:#444">Profil introuvable</h3>
    <p>Ce profil n'existe pas ou a &eacute;t&eacute; supprim&eacute;.</p>
    <a href="javascript:void(0)" onclick="window.history.back()" style="color:#0a66c2;cursor:pointer;">&larr; Retour</a>
</div>
<% return; } %>
<%
    /* ==============================
       Extraction des champs selon visibilite
       ============================== */
    boolean vNom       = isPublic(champVis, "nom");
    boolean vPrenom    = isPublic(champVis, "prenom");
    boolean vEmail     = isPublic(champVis, "email");
    boolean vDtn       = isPublic(champVis, "dtn");
    boolean vPromo     = isPublic(champVis, "promotion");
    boolean vParcours  = isPublic(champVis, "parcours");
    boolean vSpec      = isPublic(champVis, "specialite");
    boolean vExp       = isPublic(champVis, "experience");
    boolean vTel       = isPublic(champVis, "telephone");
    boolean vGenre     = isPublic(champVis, "genre");
    boolean vSocial    = isPublic(champVis, "socialmedia");

    String nom       = (vNom && profil.getNom() != null)            ? profil.getNom()            : "";
    String prenom    = (vPrenom && profil.getPrenom() != null)       ? profil.getPrenom()         : "";
    String email     = (vEmail && profil.getEmail() != null)         ? profil.getEmail()          : "";
    String telephone = (vTel && profil.getTelephone() != null)       ? profil.getTelephone()      : "";
    String dtn       = (vDtn && profil.getDtn() != null)             ? profil.getDtn().toString() : "";
    String promoLib  = (vPromo && profil.getPromotionLib() != null)  ? profil.getPromotionLib()   : "";
    int promoAnnee   = vPromo                                        ? profil.getPromotionAnnee() : 0;
    String parcLib   = (vParcours && profil.getParcoursLib() != null)? profil.getParcoursLib()    : "";
    String genreLib  = (vGenre && profil.getGenrelib() != null) ? profil.getGenrelib() : "";
    String genreId   = (vGenre && profil.getIdgenre()  != null) ? profil.getIdgenre()  : "";

    int refuser = profil.getRefuser();
    String loginuser = profil.getLoginuser() != null ? profil.getLoginuser() : "";
    int contribution = profil.getContribution();

    // Display name
    String displayName;
    if (!vNom && !vPrenom) {
        displayName = !loginuser.isEmpty() ? loginuser : "Utilisateur #" + refuser;
    } else {
        displayName = (prenom.isEmpty() ? "" : prenom) + (prenom.isEmpty() || nom.isEmpty() ? "" : " ") + nom;
        if (displayName.trim().isEmpty()) displayName = !loginuser.isEmpty() ? loginuser : "Utilisateur #" + refuser;
    }

    // Photo
    String photoPath = profil.getPhotoProfil() != null ? profil.getPhotoProfil().trim() : "";
    String photoUrl  = !photoPath.isEmpty() ? (ctx + "/" + photoPath) : "";
    String coverPath = profil.getPhotoCouverture() != null ? profil.getPhotoCouverture().trim() : "";
    String coverUrl  = !coverPath.isEmpty() ? (ctx + "/" + coverPath) : "";

    String initials = (
        (prenom.isEmpty() ? (profil.getPrenom() != null ? ""+profil.getPrenom().charAt(0) : "?") : ""+prenom.charAt(0)) +
        (nom.isEmpty()    ? (profil.getNom()    != null ? ""+profil.getNom().charAt(0) : "?") : ""+nom.charAt(0))
    ).toUpperCase();

    // Headline
    String headline = "";
    if (experiences != null && experiences.length > 0) {
        ExperienceLib lastExp = experiences[0];
        String p1 = lastExp.getPostelib() != null ? lastExp.getPostelib() : "";
        String p2 = lastExp.getEntreprise() != null ? lastExp.getEntreprise() : "";
        if (!p1.isEmpty() && !p2.isEmpty()) headline = p1 + " chez " + p2;
        else if (!p1.isEmpty()) headline = p1;
        else if (!p2.isEmpty()) headline = p2;
    }
    if (headline.isEmpty() && !parcLib.isEmpty()) headline = parcLib;
    if (headline.isEmpty()) headline = "Alumni";

    // CV
    String cvPath = profil.getCv() != null ? profil.getCv().trim() : "";
    String cvUrl = !cvPath.isEmpty() ? (ctx + "/" + cvPath) : "";
%>

<style>
/* ═══════════════════════════════════════
   FICHE UTILISATEUR  •  LinkedIn-style
   ═══════════════════════════════════════ */
.fu-wrap{max-width:1200px;margin:0 auto 40px;padding:0 16px;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;color:#191919;-webkit-font-smoothing:antialiased}

/* Back link */
.fu-back{display:inline-flex;align-items:center;gap:6px;font-size:13px;font-weight:600;color:#0a66c2;text-decoration:none;margin-bottom:14px;padding:5px 0;transition:color .15s}
.fu-back:hover{color:#004182;text-decoration:none}

/* Card */
.fu-card{background:#fff;border:1px solid #dce0e4;border-radius:10px;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.08)}

/* Cover */
.fu-cover{height:200px;background:linear-gradient(135deg,#003366 0%,#0a66c2 60%,#378fe9 100%);position:relative;overflow:hidden}
.fu-cover img{width:100%;height:100%;object-fit:cover;display:block}
.fu-refuser-badge{position:absolute;top:12px;right:16px;background:rgba(0,0,0,.4);color:#fff;padding:4px 14px;border-radius:12px;font-size:11px;font-weight:700;letter-spacing:.5px;backdrop-filter:blur(4px)}

/* Avatar */
.fu-avatar-wrap{display:inline-block;margin-top:-60px;margin-left:32px;position:relative;z-index:1}
.fu-avatar{width:120px;height:120px;border-radius:50%;border:4px solid #fff;box-shadow:0 2px 12px rgba(0,0,0,.25);background:#0a66c2;display:flex;align-items:center;justify-content:center;font-size:40px;font-weight:700;color:#fff;overflow:hidden;line-height:1}
.fu-avatar--with-status{box-shadow:0 0 0 3px var(--fu-status-color, #0a66c2), 0 2px 12px rgba(0,0,0,.25)}
.fu-avatar img{width:100%;height:100%;object-fit:cover;border-radius:50%}

/* Top */
.fu-top{padding:16px 32px 24px;border-bottom:1px solid #eee}
.fu-name{font-size:26px;font-weight:700;line-height:1.25}
.fu-headline{font-size:15px;color:#555;margin-top:6px}
.fu-meta{display:flex;flex-wrap:wrap;gap:20px;margin-top:10px;font-size:14px;color:#666}
.fu-meta a{color:#0a66c2;text-decoration:none;font-weight:500}
.fu-meta a:hover{text-decoration:underline}

/* Section */
.fu-section{padding:24px 32px;border-bottom:1px solid #eee}
.fu-section:last-child{border-bottom:none}
.fu-section h2{font-size:16px;font-weight:700;margin:0 0 16px;display:flex;align-items:center;gap:8px}
.fu-section h2 i{font-size:16px;color:#0a66c2}

/* Tags */
.fu-tags{display:flex;flex-wrap:wrap;gap:8px}
.fu-tag{background:#eef3fb;color:#0a66c2;border-radius:14px;padding:5px 14px;font-size:13px;font-weight:600}
.fu-tag.grey{background:#f0f0f0;color:#555}
.fu-tag.green{background:#e8f5e9;color:#2e7d32}

/* Grid */
.fu-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:20px 32px}
@media(max-width:900px){.fu-grid{grid-template-columns:1fr 1fr}}
@media(max-width:520px){.fu-grid{grid-template-columns:1fr}}
.fu-field label{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:#888;display:block;margin-bottom:5px}
.fu-field span{font-size:15px}

/* Experience */
.fu-exp-item{border-left:3px solid #0a66c2;padding:10px 0 10px 16px;margin-bottom:16px}
.fu-exp-item:last-child{margin-bottom:0}
.fu-exp-company{font-weight:700;font-size:14px;color:#191919}
.fu-exp-poste{font-size:13px;color:#0a66c2;margin-top:1px}
.fu-exp-dates{font-size:12px;color:#888;margin-top:3px}
.fu-exp-desc{font-size:13px;color:#444;margin-top:5px;line-height:1.5}

/* Private notice */
.fu-private{color:#999;font-style:italic;font-size:13px;display:flex;align-items:center;gap:6px}
.fu-private i{font-size:14px}

/* Buttons */
.fu-actions{display:flex;gap:10px;flex-wrap:wrap;margin-top:12px}
.fu-btn{padding:7px 22px;border-radius:22px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;gap:6px;transition:all .15s;border:none}
.fu-btn-primary{background:#0a66c2;color:#fff}
.fu-btn-primary:hover{background:#004182;color:#fff;text-decoration:none}
.fu-btn-outline{background:transparent;color:#0a66c2;border:1.5px solid #0a66c2}
.fu-btn-outline:hover{background:#eef3fb;color:#0a66c2;text-decoration:none}
/* ---- Publications du profil ---- */
.ppub-card { background:#fff; border:1px solid #dde3ec; border-radius:12px; padding:14px; margin-bottom:12px; cursor:pointer; transition:box-shadow .15s; }
.ppub-card:hover { box-shadow:0 4px 14px rgba(0,0,0,.10); }
.ppub-header { display:flex; align-items:center; gap:10px; margin-bottom:8px; }
.ppub-avatar { width:36px; height:36px; border-radius:50%; background:#0a66c2; color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:13px; flex-shrink:0; overflow:hidden; }
.ppub-meta { flex:1; min-width:0; }
.ppub-author { font-weight:700; font-size:13px; color:inherit; text-decoration:none; display:block; }
.ppub-date { font-size:12px; color:#888; margin-top:2px; }
.ppub-badge { font-size:11px; background:#eef3fb; color:#0a66c2; padding:2px 8px; border-radius:10px; font-weight:600; margin-left:4px; }
.ppub-text { font-size:13px; line-height:1.5; color:#1c1e21; margin-bottom:6px; max-height:96px; overflow:hidden; word-break:break-word; }
.ppub-media-wrap { margin:4px 0; border-radius:8px; overflow:hidden; max-height:200px; }
.ppub-media-img { width:100%; max-height:200px; object-fit:cover; display:block; }
.ppub-counters { display:flex; align-items:center; gap:12px; font-size:12px; color:#888; margin-top:6px; padding-top:6px; border-top:1px solid #f0f2f5; }
.ppub-counter { display:flex; align-items:center; gap:4px; }
.ppub-view-link { margin-left:auto; font-size:12px; color:#0a66c2; font-weight:600; }
.ppub-load-more-wrap { text-align:center; margin:6px 0 12px; }
.ppub-load-more-btn { background:transparent; border:1.5px solid #0a66c2; color:#0a66c2; border-radius:20px; padding:6px 20px; font-size:13px; font-weight:700; cursor:pointer; }
.ppub-load-more-btn:hover { background:#0a66c2; color:#fff; }
</style>
<link rel="stylesheet" href="<%= ctx %>/assets/css/publication-cards.css">

<div class="fu-wrap">

    <!-- Back link -->
    <a class="fu-back" href="javascript:void(0)" onclick="window.history.back()">
        <i class="bi bi-arrow-left"></i> Retour
    </a>

    <div class="fu-card">

        <!-- Cover -->
        <div class="fu-cover">
            <% if (!coverUrl.isEmpty()) { %><img src="<%= h(coverUrl) %>" alt="Couverture"><% } %>
            <span class="fu-refuser-badge"><%= h(!loginuser.isEmpty() ? loginuser : "REF " + refuser) %></span>
        </div>

        <!-- Avatar -->
        <div class="fu-avatar-wrap" style="--fu-status-color: <%= _statutColor %>;">
            <div class="fu-avatar fu-avatar--with-status"<%= !photoUrl.isEmpty() ? " style=\"background:transparent;\"" : "" %> title="<%= _statutLibelle %>">
                <% if (!photoUrl.isEmpty()) { %><img src="<%= h(photoUrl) %>" alt="<%= h(displayName) %>"><% } else { %><%= initials %><% } %>
            </div>
        </div>

        <!-- Top -->
        <div class="fu-top">
            <div class="fu-name" style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
                <%= h(displayName) %>
                <% if (!genreLib.isEmpty()) { %><span style="display:inline-flex;align-items:center;gap:4px;font-size:12px;font-weight:600;background:#f3e8ff;color:#7c3aed;border-radius:14px;padding:3px 12px;white-space:nowrap;"><i class="bi <%= "GEN000001".equals(genreId) ? "bi-gender-male" : "bi-gender-female" %>"></i>&nbsp;<%= h(genreLib) %></span><% } %>
                <span style="display:inline-flex;align-items:center;gap:4px;font-size:12px;font-weight:600;background:#fff8e1;color:#f57f17;border-radius:14px;padding:3px 12px;white-space:nowrap;" title="Contribution (publications)"><i class="bi bi-award-fill"></i>&nbsp;<%= contribution %></span>
            </div>
            <div class="fu-headline"><%= h(headline) %></div>
            <div class="fu-meta">
                <% if (!email.isEmpty()) { %><a href="mailto:<%= h(email) %>"><i class="bi bi-envelope-fill"></i>&nbsp;<%= h(email) %></a><% } %>
                <% if (!telephone.isEmpty()) { %><span><i class="bi bi-telephone-fill"></i>&nbsp;<%= h(telephone) %></span><% } %>
            </div>
            <div class="fu-actions">
                <% if (!email.isEmpty()) { %><a class="fu-btn fu-btn-primary" href="mailto:<%= h(email) %>"><i class="bi bi-envelope-fill"></i> Contacter</a><% } %>
                <a class="fu-btn fu-btn-outline" href="<%= _lien %>?but=annuaire/annuaire.jsp"><i class="bi bi-people-fill"></i> Annuaire</a>
                <button class="fu-btn fu-btn-outline" onclick="fuCopyProfileLink()"><i class="bi bi-link-45deg"></i> Copier le lien</button>
            </div>
        </div>

        <!-- Promotion & Parcours -->
        <% if (vPromo || vParcours) { %>
        <div class="fu-section">
            <h2><i class="bi bi-mortarboard-fill"></i> Promotion & Parcours</h2>
            <div class="fu-tags">
                <% if (!promoLib.isEmpty()) { %><span class="fu-tag">🎓&nbsp;<%= h(promoLib) %><%= promoAnnee > 0 ? " (" + promoAnnee + ")" : "" %></span><% } %>
                <% if (!parcLib.isEmpty()) { %><span class="fu-tag grey">📚&nbsp;<%= h(parcLib) %></span><% } %>
            </div>
        </div>
        <% } %>

        <!-- Specialites -->
        <% if (vSpec && !specLabels.isEmpty()) { %>
        <div class="fu-section">
            <h2><i class="bi bi-star-fill"></i> Sp&eacute;cialit&eacute;s</h2>
            <div class="fu-tags">
                <% for (int i = 0; i < specLabels.size(); i++) { %>
                <span class="fu-tag green"><%= h((String) specLabels.get(i)) %></span>
                <% } %>
            </div>
        </div>
        <% } %>

        <!-- Reseaux Sociaux -->
        <% if (vSocial) { %>
        <div class="fu-section">
            <h2><i class="bi bi-globe2"></i> R&eacute;seaux sociaux</h2>
            <div class="fu-tags">
                <% if (socialMedias == null || socialMedias.length == 0) { %>
                    <span style="color:#aaa;font-size:13px">Aucun r&eacute;seau social renseign&eacute;.</span>
                <% } else {
                    for (int ii = 0; ii < socialMedias.length; ii++) {
                        ProfilSocialMedia sm = socialMedias[ii];
                        String lib = "";
                        for (int ri = 0; ri < allReseaux.length; ri++) {
                            if (allReseaux[ri].getIdReseauSocial() != null &&
                                allReseaux[ri].getIdReseauSocial().equals(sm.getIdReseauSocial())) {
                                lib = allReseaux[ri].getLibelle() != null ? allReseaux[ri].getLibelle() : "";
                                break;
                            }
                        }
                %>
                    <span class="fu-tag grey"><%= h(lib + ": " + (sm.getValeur()!=null?sm.getValeur():"")) %></span>
                <% } } %>
            </div>
        </div>
        <% } %>

        <!-- Informations -->
        <div class="fu-section">
            <h2><i class="bi bi-person-vcard-fill"></i> Informations</h2>
            <div class="fu-grid">
                <% if (vNom) { %>
                <div class="fu-field"><label>Nom</label><span><%= h(nom.isEmpty() ? "—" : nom) %></span></div>
                <% } %>
                <% if (vPrenom) { %>
                <div class="fu-field"><label>Pr&eacute;nom</label><span><%= h(prenom.isEmpty() ? "—" : prenom) %></span></div>
                <% } %>
                <% if (vDtn) { %>
                <div class="fu-field"><label>Date de naissance</label><span><%
                    if (!dtn.isEmpty()) {
                        String[] parts = dtn.split("-");
                        if (parts.length == 3) out.print(parts[2] + "/" + parts[1] + "/" + parts[0]);
                        else out.print(h(dtn));
                    } else out.print("—");
                %></span></div>
                <% } %>
                <% if (vEmail) { %>
                <div class="fu-field"><label>Email</label><span><%= h(email.isEmpty() ? "—" : email) %></span></div>
                <% } %>
                <% if (vTel && !telephone.isEmpty()) { %>
                <div class="fu-field"><label>T&eacute;l&eacute;phone</label><span><%= h(telephone) %></span></div>
                <% } %>
                <% if (!genreLib.isEmpty()) { %>
                <div class="fu-field"><label>Genre</label><span><i class="bi <%= "GEN000001".equals(genreId) ? "bi-gender-male" : "bi-gender-female" %>" style="color:#7c3aed;margin-right:4px;"></i><%= h(genreLib) %></span></div>
                <% } %>
                <% if (vPromo && !promoLib.isEmpty()) { %>
                <div class="fu-field"><label>Promotion</label><span><%= h(promoLib) %><%= promoAnnee > 0 ? " (" + promoAnnee + ")" : "" %></span></div>
                <% } %>
                <% if (vParcours && !parcLib.isEmpty()) { %>
                <div class="fu-field"><label>Parcours</label><span><%= h(parcLib) %></span></div>
                <% } %>
            </div>
            <%
                // Champs privés : on affiche un avis discret
                int privCount = 0;
                if (!vNom) privCount++;
                if (!vPrenom) privCount++;
                if (!vDtn) privCount++;
                if (!vEmail) privCount++;
                if (!vPromo) privCount++;
                if (!vParcours) privCount++;
                if (!vTel) privCount++;
                if (privCount > 0) {
            %>
            <div class="fu-private" style="margin-top:14px">
                <i class="bi bi-lock-fill"></i>
                Certaines informations sont priv&eacute;es (<%= privCount %> champ<%= privCount > 1 ? "s" : "" %> masqu&eacute;<%= privCount > 1 ? "s" : "" %>)
            </div>
            <% } %>
        </div>

        <!-- Experiences -->
        <div class="fu-section">
            <h2><i class="bi bi-briefcase-fill"></i> Exp&eacute;riences</h2>
            <% if (!vExp) { %>
                <div class="fu-private"><i class="bi bi-lock-fill"></i> Les exp&eacute;riences sont priv&eacute;es</div>
            <% } else if (experiences == null || experiences.length == 0) { %>
                <p style="color:#aaa;font-size:13px;margin:0">Aucune exp&eacute;rience renseign&eacute;e.</p>
            <% } else {
                for (int i = 0; i < experiences.length; i++) {
                    ExperienceLib ex = experiences[i];
                    String exPoste      = ex.getPostelib() != null   ? ex.getPostelib()   : "";
                    String exEntreprise = ex.getEntreprise() != null  ? ex.getEntreprise() : "";
                    String exDebut      = ex.getDebut() != null       ? ex.getDebut().toString() : "";
                    String exFin        = ex.getFin() != null         ? ex.getFin().toString()   : "Actuel";
                    String exDesc       = ex.getDescription() != null ? ex.getDescription() : "";
            %>
                <div class="fu-exp-item">
                    <% if (!exEntreprise.isEmpty()) { %><div class="fu-exp-company"><%= h(exEntreprise) %></div><% } %>
                    <% if (!exPoste.isEmpty()) { %><div class="fu-exp-poste"><%= h(exPoste) %></div><% } %>
                    <div class="fu-exp-dates"><%= h(exDebut) %> &rarr; <%= h(exFin) %></div>
                    <% if (!exDesc.isEmpty()) { %><div class="fu-exp-desc"><%= h(exDesc) %></div><% } %>
                </div>
            <% } } %>
        </div>

        <!-- CV -->
        <% if (!cvUrl.isEmpty()) { %>
        <div class="fu-section">
            <h2><i class="bi bi-file-earmark-text-fill"></i> Curriculum Vitae</h2>
            <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
                <a href="<%= h(cvUrl) %>" target="_blank" class="fu-btn fu-btn-primary" download>
                    <i class="bi bi-download"></i> T&eacute;l&eacute;charger le CV
                </a>
                <a href="<%= h(cvUrl) %>" target="_blank" class="fu-btn fu-btn-outline">
                    <i class="bi bi-eye"></i> Voir le CV
                </a>
            </div>
        </div>
        <% } %>

        <!-- Publications -->
        <div class="fu-section" id="fuPubSection" style="border-top:1px solid #dce0e4;margin-top:6px;">
            <h2><i class="bi bi-newspaper"></i> Publications</h2>
            <div id="fuPublications"><em style="color:#aaa;font-size:13px;">Chargement...</em></div>
        </div>

    </div><!-- .fu-card -->

</div>

<!-- ==================== MODALES PUBLICATIONS ==================== -->
<div id="react-detail-modal">
    <div class="react-detail-box">
        <div id="react-detail-content"></div>
    </div>
</div>
<div id="share-modal">
    <div class="share-box">
        <div class="share-header">
            <h3 class="share-title">Partager la publication</h3>
            <button class="rdm-close" onclick="closeShareModal()">&times;</button>
        </div>
        <div class="share-body">
            <textarea id="share-description" class="share-textarea" placeholder="Dites quelque chose... (optionnel)"></textarea>
            <div class="share-original" id="share-original-preview">
                <div class="share-orig-author" id="share-orig-author"></div>
                <div class="share-orig-date" id="share-orig-date"></div>
                <div class="share-orig-text" id="share-orig-text"></div>
            </div>
        </div>
        <div class="share-footer">
            <button class="share-cancel-btn" onclick="closeShareModal()">Annuler</button>
            <button class="share-submit-btn" id="share-submit-btn" onclick="submitShare()">Partager</button>
        </div>
    </div>
</div>
<div id="pub-detail-modal">
    <div class="pub-fb-box" id="pub-fb-box">
        <button class="pub-fb-close" onclick="closePublicationDetail()">&times;</button>
        <div class="pub-fb-media" id="pub-fb-media">
            <div class="pub-fb-media-content" id="pub-fb-media-content"></div>
            <button class="pub-fb-nav pub-fb-nav-prev" id="pub-fb-prev" onclick="pubFbNavPrev()"><i class="bi bi-chevron-left"></i></button>
            <button class="pub-fb-nav pub-fb-nav-next" id="pub-fb-next" onclick="pubFbNavNext()"><i class="bi bi-chevron-right"></i></button>
            <div class="pub-fb-media-counter" id="pub-fb-counter"></div>
        </div>
        <div class="pub-fb-details" id="pub-fb-details">
            <div style="text-align:center;padding:40px;"><div class="fa-feed-spinner"></div></div>
        </div>
    </div>
</div>

<script>
var CTX = '<%= ctx %>';
var CURRENT_USER_ID = '<%= myRefuser %>';

/* ── Copier le lien du profil ── */
function fuCopyProfileLink() {
    var url = window.location.origin + '<%= request.getContextPath() %>/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp?idprofil=' + encodeURIComponent('<%= h(idprofil) %>');
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(url).then(function() {
            if (typeof Swal !== 'undefined') Swal.fire({toast:true,position:'top-end',icon:'success',title:'Lien du profil copi\u00e9 !',timer:2000,showConfirmButton:false});
            else alert('Lien copi\u00e9 !');
        }).catch(function() { _fuFallbackCopy(url); });
    } else { _fuFallbackCopy(url); }
}
function _fuFallbackCopy(txt) {
    var ta = document.createElement('textarea');
    ta.value = txt; ta.style.position = 'fixed'; ta.style.left = '-9999px';
    document.body.appendChild(ta); ta.select();
    try { document.execCommand('copy'); alert('Lien du profil copi\u00e9 !'); } catch(e) { alert('Impossible de copier'); }
    document.body.removeChild(ta);
}

(function() {
    var ctx = '<%= request.getContextPath() %>';
    var fuIdprofil = '<%= h(idprofil) %>';
    var fuIduser   = '<%= profil != null ? profil.getRefuser() : -1 %>';

    function fuLoadPubs(iduser, idprofil, cursorId) {
        var container = document.getElementById('fuPublications');
        if (!cursorId) container.innerHTML = '<em style="color:#aaa;font-size:13px;">Chargement...</em>';
        var url = ctx + '/pages/alumni/ajax/publications-profil.jsp?idutilisateur=' + encodeURIComponent(iduser)
            + '&idprofil=' + encodeURIComponent(idprofil)
            + (cursorId ? '&cursor_id=' + encodeURIComponent(cursorId) : '');
        fetch(url)
            .then(function(r) { return r.text(); })
            .then(function(html) {
                if (!cursorId) { container.innerHTML = html; }
                else {
                    var ex = container.querySelector('.ppub-load-more-wrap');
                    if (ex) ex.remove();
                    var tmp = document.createElement('div'); tmp.innerHTML = html;
                    while (tmp.firstChild) container.appendChild(tmp.firstChild);
                }
            })
            .catch(function(e) { container.innerHTML = '<p style="color:red;font-size:13px;">Erreur: ' + e + '</p>'; });
    }

    window.ppubLoadMore = function(btn, iduser, idprofil, cursorId) {
        btn.disabled = true; btn.textContent = 'Chargement...';
        fuLoadPubs(iduser, idprofil, cursorId);
    };

    document.addEventListener('DOMContentLoaded', function() {
        fuLoadPubs(fuIduser, fuIdprofil, '');
    });
})();
</script>
<script src="<%= ctx %>/assets/js/publication-cards.js"></script>
