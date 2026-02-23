<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.ExperienceLib" %>
<%@ page import="alumni.Visibilite" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="alumni.Specialiteprofil" %>
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
    <a href="<%= _lien %>?but=annuaire/annuaire.jsp" style="color:#0a66c2">← Retour &agrave; l'annuaire</a>
</div>
<% return; } %>
<%
    idprofil = idprofil.trim();

    ProfilLib profil = null;
    ExperienceLib[] experiences = null;
    Map champVis = new HashMap(); // champ -> status
    List specLabels = new ArrayList(); // specialite libelles
    String _erreur = null;

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        /* --- Charger le profil --- */
        ProfilLib filtre = new ProfilLib();
        filtre.setIdprofil(idprofil);
        ProfilLib[] res = (ProfilLib[]) CGenUtil.rechercher(filtre, null, null, conn, "");
        if (res != null && res.length > 0) profil = res[0];

        if (profil != null) {
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
        }
    } catch (Exception e) {
        _erreur = e.getMessage();
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }

    if (profil == null) {
%>
<div style="text-align:center;padding:60px 20px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#888">
    <h3 style="color:#444">Profil introuvable</h3>
    <p>Ce profil n'existe pas ou a &eacute;t&eacute; supprim&eacute;.</p>
    <a href="<%= _lien %>?but=annuaire/annuaire.jsp" style="color:#0a66c2">&larr; Retour &agrave; l'annuaire</a>
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

    String nom       = (vNom && profil.getNom() != null)            ? profil.getNom()            : "";
    String prenom    = (vPrenom && profil.getPrenom() != null)       ? profil.getPrenom()         : "";
    String email     = (vEmail && profil.getEmail() != null)         ? profil.getEmail()          : "";
    String telephone = profil.getTelephone() != null                 ? profil.getTelephone()      : "";
    String dtn       = (vDtn && profil.getDtn() != null)             ? profil.getDtn().toString() : "";
    String promoLib  = (vPromo && profil.getPromotionLib() != null)  ? profil.getPromotionLib()   : "";
    int promoAnnee   = vPromo                                        ? profil.getPromotionAnnee() : 0;
    String parcLib   = (vParcours && profil.getParcoursLib() != null)? profil.getParcoursLib()    : "";

    int refuser = profil.getRefuser();
    String loginuser = profil.getLoginuser() != null ? profil.getLoginuser() : "";

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
%>

<style>
/* ═══════════════════════════════════════
   FICHE UTILISATEUR  •  LinkedIn-style
   ═══════════════════════════════════════ */
.fu-wrap{max-width:760px;margin:0 auto 40px;padding:0 16px;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;color:#191919;-webkit-font-smoothing:antialiased}

/* Back link */
.fu-back{display:inline-flex;align-items:center;gap:6px;font-size:13px;font-weight:600;color:#0a66c2;text-decoration:none;margin-bottom:14px;padding:5px 0;transition:color .15s}
.fu-back:hover{color:#004182;text-decoration:none}

/* Card */
.fu-card{background:#fff;border:1px solid #dce0e4;border-radius:10px;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.08)}

/* Cover */
.fu-cover{height:148px;background:linear-gradient(135deg,#003366 0%,#0a66c2 60%,#378fe9 100%);position:relative;overflow:hidden}
.fu-cover img{width:100%;height:100%;object-fit:cover;display:block}
.fu-refuser-badge{position:absolute;top:12px;right:16px;background:rgba(0,0,0,.4);color:#fff;padding:4px 14px;border-radius:12px;font-size:11px;font-weight:700;letter-spacing:.5px;backdrop-filter:blur(4px)}

/* Avatar */
.fu-avatar-wrap{display:inline-block;margin-top:-48px;margin-left:24px;position:relative;z-index:1}
.fu-avatar{width:96px;height:96px;border-radius:50%;border:3.5px solid #fff;box-shadow:0 2px 10px rgba(0,0,0,.18);background:#0a66c2;display:flex;align-items:center;justify-content:center;font-size:32px;font-weight:700;color:#fff;overflow:hidden;line-height:1}
.fu-avatar img{width:100%;height:100%;object-fit:cover;border-radius:50%}

/* Top */
.fu-top{padding:10px 24px 18px;border-bottom:1px solid #eee}
.fu-name{font-size:21px;font-weight:700;line-height:1.25}
.fu-headline{font-size:14px;color:#555;margin-top:3px}
.fu-meta{display:flex;flex-wrap:wrap;gap:16px;margin-top:8px;font-size:13px;color:#666}
.fu-meta a{color:#0a66c2;text-decoration:none;font-weight:500}
.fu-meta a:hover{text-decoration:underline}

/* Section */
.fu-section{padding:18px 24px;border-bottom:1px solid #eee}
.fu-section:last-child{border-bottom:none}
.fu-section h2{font-size:15px;font-weight:700;margin:0 0 14px;display:flex;align-items:center;gap:8px}
.fu-section h2 i{font-size:16px;color:#0a66c2}

/* Tags */
.fu-tags{display:flex;flex-wrap:wrap;gap:8px}
.fu-tag{background:#eef3fb;color:#0a66c2;border-radius:14px;padding:5px 14px;font-size:13px;font-weight:600}
.fu-tag.grey{background:#f0f0f0;color:#555}
.fu-tag.green{background:#e8f5e9;color:#2e7d32}

/* Grid */
.fu-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px 28px}
@media(max-width:520px){.fu-grid{grid-template-columns:1fr}}
.fu-field label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:#888;display:block;margin-bottom:3px}
.fu-field span{font-size:14px}

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
</style>

<div class="fu-wrap">

    <!-- Back link -->
    <a class="fu-back" href="<%= _lien %>?but=annuaire/annuaire.jsp">
        <i class="bi bi-arrow-left"></i> Retour &agrave; l'annuaire
    </a>

    <div class="fu-card">

        <!-- Cover -->
        <div class="fu-cover">
            <% if (!coverUrl.isEmpty()) { %><img src="<%= h(coverUrl) %>" alt="Couverture"><% } %>
            <span class="fu-refuser-badge"><%= h(!loginuser.isEmpty() ? loginuser : "REF " + refuser) %></span>
        </div>

        <!-- Avatar -->
        <div class="fu-avatar-wrap">
            <div class="fu-avatar"<%= !photoUrl.isEmpty() ? " style=\"background:transparent;\"" : "" %>>
                <% if (!photoUrl.isEmpty()) { %><img src="<%= h(photoUrl) %>" alt="<%= h(displayName) %>"><% } else { %><%= initials %><% } %>
            </div>
        </div>

        <!-- Top -->
        <div class="fu-top">
            <div class="fu-name"><%= h(displayName) %></div>
            <div class="fu-headline"><%= h(headline) %></div>
            <div class="fu-meta">
                <% if (!email.isEmpty()) { %><a href="mailto:<%= h(email) %>"><i class="bi bi-envelope-fill"></i>&nbsp;<%= h(email) %></a><% } %>
                <% if (!telephone.isEmpty()) { %><span><i class="bi bi-telephone-fill"></i>&nbsp;<%= h(telephone) %></span><% } %>
            </div>
            <div class="fu-actions">
                <% if (!email.isEmpty()) { %><a class="fu-btn fu-btn-primary" href="mailto:<%= h(email) %>"><i class="bi bi-envelope-fill"></i> Contacter</a><% } %>
                <a class="fu-btn fu-btn-outline" href="<%= _lien %>?but=annuaire/annuaire.jsp"><i class="bi bi-people-fill"></i> Annuaire</a>
            </div>
        </div>

        <!-- Formation -->
        <% if (vPromo || vParcours) { %>
        <div class="fu-section">
            <h2><i class="bi bi-mortarboard-fill"></i> Formation</h2>
            <div class="fu-tags">
                <% if (!promoLib.isEmpty()) { %><span class="fu-tag">&nbsp;<%= h(promoLib) %><%= promoAnnee > 0 ? " (" + promoAnnee + ")" : "" %></span><% } %>
                <% if (!parcLib.isEmpty()) { %><span class="fu-tag grey">&nbsp;<%= h(parcLib) %></span><% } %>
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
                <% if (!telephone.isEmpty()) { %>
                <div class="fu-field"><label>T&eacute;l&eacute;phone</label><span><%= h(telephone) %></span></div>
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

    </div><!-- .fu-card -->

</div>
