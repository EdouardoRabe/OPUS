<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.ProfilStatut" %>
<%@ page import="alumni.ProfilTypeStatut" %>
<%@ page import="alumni.ExperienceLib" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="alumni.Specialiteprofil" %>
<%@ page import="alumni.Poste" %>
<%@ page import="alumni.ReseauSocial" %>
<%@ page import="alumni.ProfilSocialMedia" %>
<%@ page import="java.sql.Connection" %>
<%
    UserEJB    uEJB  = (UserEJB) session.getAttribute("u");
    String     _lien = (String) session.getValue("lien");
    ProfilLib      profil = null;
    ExperienceLib[] experiences = null;
    Specialiteprofil[] specProfils = null;
    Specialite[] allSpecialites = null;
    Poste[] allPostes = null;
    ReseauSocial[] allReseaux = null;
    ProfilSocialMedia[] socialMedias = null;
    ProfilTypeStatut[] allStatutTypes = null;
    String     _erreur = null;
    if (uEJB != null && uEJB.getUser() != null) {
        MapUtilisateur mu = uEJB.getUser();
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            ProfilLib filtre = new ProfilLib();
            ProfilLib[] res = (ProfilLib[]) CGenUtil.rechercher(
                filtre, null, null, conn, " and refuser='" + mu.getRefuser() + "'"
            );
            if (res != null && res.length > 0) profil = res[0];

            // Chargement des expériences
            experiences = (ExperienceLib[]) CGenUtil.rechercher(
                new ExperienceLib(), null, null, conn,
                " and idutilisateur='" + mu.getRefuser() + "' order by debut desc"
            );

            // Chargement des spécialités du profil
            if (profil != null && profil.getIdprofil() != null) {
                Specialiteprofil spf = new Specialiteprofil();
                spf.setIdprofil(profil.getIdprofil());
                specProfils = (Specialiteprofil[]) CGenUtil.rechercher(spf, null, null, conn, "");
            }

            // Listes de référence
            allSpecialites = (Specialite[]) CGenUtil.rechercher(new Specialite(), null, null, conn, " order by libelle");
            allPostes = (Poste[]) CGenUtil.rechercher(new Poste(), null, null, conn, " order by libelle");
            allStatutTypes = (ProfilTypeStatut[]) CGenUtil.rechercher(new ProfilTypeStatut(), null, null, conn, " order by libelle");

            // Chargement des réseaux sociaux disponibles
            allReseaux = (ReseauSocial[]) CGenUtil.rechercher(new ReseauSocial(), null, null, conn, " and actif=1 order by priorite desc");

            // Chargement des social media du profil
            if (profil != null && profil.getIdprofil() != null) {
                socialMedias = (ProfilSocialMedia[]) CGenUtil.rechercher(
                    new ProfilSocialMedia(), null, null, conn,
                    " and idprofil='" + profil.getIdprofil() + "'"
                );
            }

        } catch (Exception e) {
            _erreur = e.getMessage();
            System.err.println("voir.jsp - erreur chargement profil: " + e.getMessage());
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
    }
    if (experiences == null) experiences = new ExperienceLib[0];
    if (specProfils == null) specProfils = new Specialiteprofil[0];
    if (allSpecialites == null) allSpecialites = new Specialite[0];
    if (allPostes == null) allPostes = new Poste[0];
    if (allReseaux == null) allReseaux = new ReseauSocial[0];
    if (socialMedias == null) socialMedias = new ProfilSocialMedia[0];
    if (allStatutTypes == null) allStatutTypes = new ProfilTypeStatut[0];
    String _idprofil    = profil != null && profil.getIdprofil()       != null ? profil.getIdprofil()       : "";
    String _nom         = profil != null && profil.getNom()            != null ? profil.getNom()            : "";
    String _prenom      = profil != null && profil.getPrenom()         != null ? profil.getPrenom()         : "";
    String _email       = profil != null && profil.getEmail()          != null ? profil.getEmail()          : "";
    String _telephone   = profil != null && profil.getTelephone()      != null ? profil.getTelephone()      : "";
    String _dtn         = profil != null && profil.getDtn()            != null ? profil.getDtn().toString() : "";
    String _idpromotion = profil != null && profil.getIdpromotion()    != null ? profil.getIdpromotion()    : "";
    String _promolib    = profil != null && profil.getPromotionLib()   != null ? profil.getPromotionLib()   : "";
    String _promoannee  = profil != null ? String.valueOf(profil.getPromotionAnnee()) : "";
    String _idparcours  = profil != null && profil.getIdparcours()     != null ? profil.getIdparcours()     : "";
    String _parcourslib = profil != null && profil.getParcoursLib()    != null ? profil.getParcoursLib()    : "";
    String _photo       = profil != null && profil.getPhotoProfil()    != null ? profil.getPhotoProfil()    : "";
    String _photoCover  = profil != null && profil.getPhotoCouverture()!= null ? profil.getPhotoCouverture(): "";
    String _photoUrl      = _photo.isEmpty()      ? "" : request.getContextPath() + "/" + _photo;
    String _photoCoverUrl = _photoCover.isEmpty() ? "" : request.getContextPath() + "/" + _photoCover;
    String _genrelib    = profil != null && profil.getGenrelib()       != null ? profil.getGenrelib()       : "";
    String _idgenre     = profil != null && profil.getIdgenre()        != null ? profil.getIdgenre()        : "";
    int _contribution   = profil != null ? profil.getContribution() : 0;
    
    // Chargement du statut du profil
    String _statutColor = "#0a66c2"; // couleur par défaut
    String _statutLibelle = "";
    try {
        if (profil != null && profil.getIdprofil() != null) {
            ProfilStatut psFiltre = new ProfilStatut();
            psFiltre.setIdprofil(profil.getIdprofil());
            Object[] psRes = CGenUtil.rechercher(psFiltre, null, null, " order by daty desc limit 1");
            if (psRes != null && psRes.length > 0) {
                ProfilStatut ps = (ProfilStatut) psRes[0];
                if (ps.getIdprofiltypestatut() != null) {
                    ProfilTypeStatut ptsFiltre = new ProfilTypeStatut();
                    ptsFiltre.setIdprofiltypestatut(ps.getIdprofiltypestatut());
                    Object[] ptsRes = CGenUtil.rechercher(ptsFiltre, null, null, "");
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
        }
    } catch (Exception e) {
        System.err.println("voir.jsp - erreur chargement statut: " + e.getMessage());
    }
%>
<!-- Font Awesome 6 (all icons: fab, fas, etc.) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" integrity="sha512-iecdLmaskl7CVJkEZSbVkFvwj6GWGcsA3UbVDA46NmCcc9syThH05yu85Z+I6QILv3GVpnwnbaIPN1zcEvGWxQ==" crossorigin="anonymous" referrerpolicy="no-referrer">
<style>
.pv-card {
  max-width: 1200px;
  margin: 20px auto 40px;
  background: #fff;
  border-radius: 10px;
  border: 1px solid #dce0e4;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    color: #191919;
    box-shadow: 0 1px 4px rgba(0,0,0,.08);
}

/* ── Cover ── */
.pv-cover {
  height: 200px;
  background: linear-gradient(135deg, #003366 0%, #0a66c2 60%, #378fe9 100%);
  border-radius: 10px 10px 0 0;
  overflow: hidden;
}
.pv-cover-img { width:100%; height:100%; object-fit:cover; display:block; }

/* ── Edit buttons ── */
.pv-cover-edit {
  position: absolute;
  bottom: 10px; right: 14px;
  background: rgba(255,255,255,.88);
  border: none; border-radius: 50%;
  width: 34px; height: 34px;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 1px 4px rgba(0,0,0,.25);
  transition: background .15s;
}
.pv-cover-edit:hover { background: #fff; }

.pv-edit-btn {
  position: absolute;
  bottom: 2px; right: 2px;
  background: #fff;
  border: none; border-radius: 50%;
  width: 26px; height: 26px;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 1px 4px rgba(0,0,0,.25);
  transition: background .15s;
}
.pv-edit-btn:hover { background: #f0f4ff; }

/* ── Avatar ── */
.pv-avatar-wrap {
  display: inline-block;
  margin-top: -60px;
  margin-left: 32px;
  position: relative;
  z-index: 1;
}
.pv-avatar {
  width: 120px; height: 120px;
  border-radius: 50%;
  border: 4px solid #fff;
  box-shadow: 0 2px 12px rgba(0,0,0,.25);
  background: #0a66c2;
  display: flex; align-items: center; justify-content: center;
  font-size: 40px; font-weight: 700; color: #fff;
  overflow: hidden;
}
.pv-avatar--with-status {
  box-shadow: 0 0 0 3px var(--pv-status-color, #0a66c2), 0 2px 12px rgba(0,0,0,.25);
}
.pv-avatar img { width:100%; height:100%; object-fit:cover; border-radius:50%; }

/* ── Top ── */
.pv-top {
  padding: 16px 32px 24px;
  border-bottom: 1px solid #eee;
}
.pv-name     { font-size: 26px; font-weight: 700; line-height: 1.25; }
.pv-headline { font-size: 15px; color: #555; margin-top: 6px; }
.pv-meta {
  display: flex; flex-wrap: wrap; gap: 20px;
  margin-top: 10px; font-size: 14px; color: #666;
}
.pv-meta a { color: #0a66c2; text-decoration: none; font-weight: 500; }
.pv-meta a:hover { text-decoration: underline; }

/* ── Sections ── */
.pv-section { padding: 24px 32px; border-bottom: 1px solid #eee; }
.pv-section:last-child { border-bottom: none; }
.pv-section h2 { font-size: 16px; font-weight: 700; margin-bottom: 16px; }

/* Tags */
.pv-tags { display: flex; flex-wrap: wrap; gap: 8px; }
.pv-tag {
  background: #eef3fb; color: #0a66c2;
  border-radius: 14px; padding: 5px 14px;
  font-size: 13px; font-weight: 600;
}
.pv-tag.grey { background: #f0f0f0; color: #555; }
.pv-tag.green { background: #e8f5e9; color: #2e7d32; }

/* Info grid */
.pv-grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px 32px; }
@media(max-width:900px){ .pv-grid { grid-template-columns: 1fr 1fr; } }
@media(max-width:520px){ .pv-grid { grid-template-columns: 1fr; } }
.pv-field label {
  font-size: 11px; font-weight: 700; text-transform: uppercase;
  letter-spacing: .6px; color: #888; display: block; margin-bottom: 5px;
}
.pv-field span { font-size: 15px; }

/* Section header */
.pv-section-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 14px;
}
.pv-section-header h2 { margin: 0; font-size: 15px; font-weight: 700; display: flex; align-items: center; gap: 8px; }
.pv-section-header h2 i { font-size: 16px; color: #0a66c2; }

.pv-btn-add {
  background: transparent; color: #0a66c2; border: 1.5px solid #0a66c2;
  border-radius: 20px; padding: 5px 14px; font-size: 12px; font-weight: 700;
  cursor: pointer; transition: all .15s; display: inline-flex; align-items: center; gap: 5px;
}
.pv-btn-add:hover { background: #0a66c2; color: #fff; }

/* Experience item */
.pv-exp-item {
  border-left: 3px solid #0a66c2; padding: 10px 0 10px 16px;
  margin-bottom: 16px; position: relative;
}
.pv-exp-item:last-child { margin-bottom: 0; }
.pv-exp-company { font-weight: 700; font-size: 14px; color: #191919; }
.pv-exp-poste { font-size: 13px; color: #0a66c2; margin-top: 1px; }
.pv-exp-dates { font-size: 12px; color: #888; margin-top: 3px; }
.pv-exp-desc { font-size: 13px; color: #444; margin-top: 5px; line-height: 1.5; }
.pv-exp-actions {
  position: absolute; top: 8px; right: 0;
  display: flex; gap: 4px;
}
.pv-exp-actions button {
  background: #f5f5f5; border: none; border-radius: 50%;
  width: 28px; height: 28px; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  font-size: 13px; color: #666; transition: all .15s;
}
.pv-exp-actions button:hover { background: #eef3fb; color: #0a66c2; }
.pv-exp-actions button.del:hover { background: #ffebee; color: #c62828; }

/* Spec item */
.pv-spec-item {
  display: inline-flex; align-items: center; gap: 8px;
  background: #e8f5e9; color: #2e7d32; border-radius: 20px;
  padding: 6px 10px 6px 14px; font-size: 13px; font-weight: 600;
}
.pv-spec-item .pv-spec-niveau {
  font-size: 10px; background: rgba(0,0,0,.08); border-radius: 10px;
  padding: 2px 8px; font-weight: 700;
}
.pv-spec-item button {
  background: none; border: none; cursor: pointer;
  color: #999; font-size: 14px; padding: 0 2px; transition: color .15s; line-height: 1;
}
.pv-spec-item button:hover { color: #c62828; }

/* ---- Publications du profil ---- */
.ppub-card { background:#fff; border:1px solid #dde3ec; border-radius:12px; padding:16px; margin-bottom:14px; cursor:pointer; transition:box-shadow .15s; }
.ppub-card:hover { box-shadow:0 4px 16px rgba(0,0,0,.10); }
.ppub-header { display:flex; align-items:center; gap:10px; margin-bottom:10px; }
.ppub-avatar { width:38px; height:38px; border-radius:50%; background:#0a66c2; color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:14px; flex-shrink:0; overflow:hidden; }
.ppub-meta { flex:1; min-width:0; }
.ppub-author { font-weight:700; font-size:14px; color:inherit; text-decoration:none; display:block; }
.ppub-author:hover { text-decoration:underline; color:#0a66c2; }
.ppub-date { font-size:12px; color:#888; margin-top:2px; }
.ppub-badge { font-size:11px; background:#eef3fb; color:#0a66c2; padding:2px 8px; border-radius:10px; font-weight:600; margin-left:4px; }
.ppub-text { font-size:14px; line-height:1.5; color:#1c1e21; margin-bottom:8px; max-height:96px; overflow:hidden; text-overflow:ellipsis; word-break:break-word; }
.ppub-media-wrap { margin:6px 0; border-radius:8px; overflow:hidden; max-height:220px; }
.ppub-media-img { width:100%; max-height:220px; object-fit:cover; display:block; }
.ppub-counters { display:flex; align-items:center; gap:14px; font-size:13px; color:#888; margin-top:8px; padding-top:8px; border-top:1px solid #f0f2f5; }
.ppub-counter { display:flex; align-items:center; gap:4px; }
.ppub-view-link { margin-left:auto; font-size:12px; color:#0a66c2; font-weight:600; }
.ppub-load-more-wrap { text-align:center; margin:8px 0 16px; }
.ppub-load-more-btn { background:transparent; border:1.5px solid #0a66c2; color:#0a66c2; border-radius:20px; padding:7px 22px; font-size:13px; font-weight:700; cursor:pointer; }
.ppub-load-more-btn:hover { background:#0a66c2; color:#fff; }
/* Social Media */
.pv-social-grid {
  display: flex; flex-wrap: wrap; gap: 12px;
}
.pv-social-item {
  display: inline-flex; align-items: center; gap: 10px;
  background: #f8f9fa; border: 1px solid #e9ecef;
  border-radius: 12px; padding: 10px 14px;
  font-size: 13px; font-weight: 500;
  transition: all .2s ease;
  text-decoration: none;
  color: #191919;
  position: relative;
}
.pv-social-item:hover {
  border-color: #0a66c2; background: #f0f6ff;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0,0,0,.08);
  text-decoration: none; color: #191919;
}
.pv-social-icon {
  width: 32px; height: 32px;
  border-radius: 8px; display: flex;
  align-items: center; justify-content: center;
  font-size: 16px; color: #fff;
  flex-shrink: 0;
}
.pv-social-info { display: flex; flex-direction: column; min-width: 0; }
.pv-social-name { font-weight: 700; font-size: 12px; color: #666; text-transform: uppercase; letter-spacing: .3px; }
.pv-social-val { font-size: 13px; color: #191919; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 180px; }
.pv-social-del {
  position: absolute; top: -6px; right: -6px;
  width: 20px; height: 20px;
  background: #fff; border: 1px solid #ddd;
  border-radius: 50%; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; color: #999; line-height: 1;
  transition: all .15s; opacity: 0;
}
.pv-social-item:hover .pv-social-del { opacity: 1; }
.pv-social-del:hover { background: #ffebee; border-color: #ef5350; color: #c62828; }
/* ── Fix icône réseau social ── */
.pv-social-icon i {
  font-size: 18px !important;
  line-height: 1;
  display: block;
  text-align: center;
}
/* ════════════════════════════════
   LAYOUT 2 COLONNES
   ════════════════════════════════ */
:root {
  --itu-blue: #008BFF;
  --itu-dark: #362F4F;
  --itu-violet: #5B23FF;
  --pvl-border: #e2e6ea;
  --pvl-card-bg: #fff;
  --pvl-text: #1c1e21;
  --pvl-text-sec: #65676b;
}
.pv-profile-layout {
  display: grid;
  grid-template-columns: 240px 1fr;
  gap: 18px;
  max-width: 1240px;
  margin: 20px auto 40px;
  padding: 0 12px;
  align-items: start;
}
@media(max-width: 900px) { .pv-profile-layout { grid-template-columns: 1fr; } }
.pvl-sidebar { position: sticky; top: 80px; }
.pvl-main { min-width: 0; }
/* Annuler max-width du pv-card (il est maintenant à l'intérieur de pvl-main) */
.pvl-main .pv-card { max-width: unset; margin: 0; }
/* ── Sidebar card ── */
.pvl-profile-card {
  background: var(--pvl-card-bg);
  border-radius: 14px;
  box-shadow: 0 1px 6px rgba(0,0,0,.12);
  overflow: hidden;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
}
.pvl-cover {
  height: 72px;
  background: linear-gradient(135deg, var(--itu-dark,#362F4F) 0%, var(--itu-violet,#5B23FF) 100%);
}
.pvl-cover-img { width:100%; height:100%; object-fit:cover; display:block; }
.pvl-body { padding: 0 16px 16px; }
.pvl-avatar-wrap { margin-top: -36px; margin-bottom: 8px; }
.pvl-avatar {
  width: 72px; height: 72px;
  border-radius: 50%;
  border: 3px solid #fff;
  box-shadow: 0 2px 8px rgba(0,0,0,.20);
  background: var(--itu-blue,#008BFF);
  display: flex; align-items: center; justify-content: center;
  font-size: 26px; font-weight: 700; color: #fff;
  overflow: hidden;
  font-family: inherit;
}
.pvl-avatar img { width:100%; height:100%; object-fit:cover; border-radius:50%; }
.pvl-name { font-weight: 700; font-size: 15px; color: var(--pvl-text); margin-bottom: 4px; line-height: 1.3; }
.pvl-title { font-size: 12px; color: var(--pvl-text-sec); margin-bottom: 12px; line-height: 1.3; }
.pvl-divider { border: none; border-top: 1px solid var(--pvl-border); margin: 8px 0; }
.pvl-nav { display: flex; flex-direction: column; gap: 2px; }
.pvl-nav-link {
  display: flex; align-items: center; gap: 8px;
  padding: 8px 10px;
  border-radius: 8px;
  font-size: 14px; font-weight: 500;
  color: var(--pvl-text);
  text-decoration: none;
  transition: background .15s, color .15s;
}
.pvl-nav-link:hover  { background: #f0f2f5; color: var(--itu-blue,#008BFF); }
.pvl-nav-link--active { background: #e7f3ff; color: var(--itu-blue,#008BFF); font-weight: 700; }
.pvl-nav-link i { font-size: 16px; }
/* ── Design améliorations sections ── */
.pv-section { border-bottom: 1px solid #f0f2f5; }
.pv-section:last-child { border-bottom: none; }
.pv-section-header h2 { font-size: 15px; }
.pv-about-text {
  font-size: 14px; color: #444; line-height: 1.65;
  background: #f8f9fb; border-radius: 10px; padding: 12px 16px;
  border-left: 4px solid var(--itu-blue,#008BFF);
}
.pv-info-icon { color: var(--itu-blue,#008BFF); margin-right: 6px; }
/* Social media bigger */
.pv-social-item { padding: 10px 14px 10px 12px; }
.pv-social-icon { 
  width: 38px; height: 38px; 
  border-radius: 10px; 
  font-size: 20px; 
  flex-shrink: 0; 
  display: flex; 
  align-items: center; 
  justify-content: center;
}
.pv-social-icon i,
.pv-social-icon .fa,
.pv-social-icon .fab,
.pv-social-icon .fas { 
  display: inline-block !important; 
  font-size: 20px !important;
  line-height: 1; 
  color: #fff !important;
  text-align: center;
}
</style>
<!-- ensure brand/free icons render with FA6 even if FA4 also loaded -->
<style>
.fab { font-family: "Font Awesome 6 Brands" !important; }
.fas, .fa { font-family: "Font Awesome 6 Free" !important; font-weight: 900 !important; }
</style>
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/publication-cards.css">

<%
  String _fullName = (_prenom + " " + _nom).trim();
  String[] _pvParts = _fullName.split("\\s+");
  String _pvInitials = "";
  if (_pvParts.length > 0 && _pvParts[0].length() > 0) _pvInitials += Character.toUpperCase(_pvParts[0].charAt(0));
  if (_pvParts.length > 1 && _pvParts[_pvParts.length-1].length() > 0) _pvInitials += Character.toUpperCase(_pvParts[_pvParts.length-1].charAt(0));
  if (_pvInitials.isEmpty()) _pvInitials = "U";
%>

<div class="pv-profile-layout">

  <!-- ═══════ SIDEBAR GAUCHE ═══════ -->
  <aside class="pvl-sidebar">
    <div class="pvl-profile-card">
      <div class="pvl-cover" id="pvlCover">
        <% if (!_photoCoverUrl.isEmpty()) { %><img class="pvl-cover-img" src="<%= _photoCoverUrl %>" alt=""><% } %>
      </div>
      <div class="pvl-body">
        <div class="pvl-avatar-wrap">
          <div class="pvl-avatar" id="pvlAvatar">
            <% if (!_photoUrl.isEmpty()) { %><img src="<%= _photoUrl %>" alt=""><% } else { %><%= _pvInitials %><% } %>
          </div>
        </div>
        <div class="pvl-name"><%= _fullName.isEmpty() ? "—" : _fullName %></div>
        <hr class="pvl-divider">
        <nav class="pvl-nav">
          <a href="<%= _lien %>?but=profil/voir.jsp" class="pvl-nav-link pvl-nav-link--active">
            <i class="bi bi-person-fill"></i> Mon profil
          </a>
          <a href="<%= _lien %>?but=accueil.jsp" class="pvl-nav-link">
            <i class="bi bi-newspaper"></i> Fil d'actualité
          </a>
          <a href="<%= _lien %>?but=alumni/notifications.jsp" class="pvl-nav-link">
            <i class="bi bi-bell-fill"></i> Notifications
          </a>
        </nav>
      </div>
    </div>
  </aside>

  <!-- ═══════ CONTENU PRINCIPAL ═══════ -->
  <main class="pvl-main">
<div class="pv-card">

  <!-- ── Cover ── -->
  <div class="pv-cover" id="pvCover" style="position:relative">
    <button class="pv-cover-edit" title="Modifier la couverture" onclick="pvOpenModal('modalPDC')">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#333" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
        <circle cx="12" cy="13" r="4"/>
      </svg>
    </button>
  </div>

  <!-- ── Avatar ── -->
  <div class="pv-avatar-wrap" style="--pv-status-color: <%= _statutColor %>;">
    <div class="pv-avatar pv-avatar--with-status" id="pvAvatar" title="<%= _statutLibelle %>"></div>
    <button class="pv-edit-btn" title="Modifier la photo de profil" onclick="pvOpenModal('modalPDP')">
      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#0a66c2" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
        <circle cx="12" cy="13" r="4"/>
      </svg>
    </button>
  </div>

  <!-- ── Identité ── -->
  <div class="pv-top">
    <div style="display:flex;justify-content:space-between;align-items:flex-start">
      <div>
        <div class="pv-name" id="pvName" style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
          <span id="pvNameText">—</span>
          <span id="pvGenreBadge" style="display:none;font-size:12px;font-weight:600;background:#f3e8ff;color:#7c3aed;border-radius:14px;padding:3px 12px;white-space:nowrap;"><i class="bi" id="pvGenreIcon"></i> <span id="pvGenreText"></span></span>
          <span id="pvContributionBadge" style="display:inline-flex;align-items:center;gap:4px;font-size:12px;font-weight:600;background:#fff8e1;color:#f57f17;border-radius:14px;padding:3px 12px;white-space:nowrap;" title="Contribution (publications)"><i class="bi bi-award-fill"></i> <span id="pvContributionText">0</span></span>
        </div>
        <div class="pv-headline" id="pvHeadline">—</div>
        <div class="pv-meta">
          <span><i class="bi bi-geo-alt-fill" style="color:#008BFF;margin-right:3px;"></i>Antananarivo, Madagascar</span>
          <a id="pvEmail" href="#">—</a>
          <span id="pvPhone">—</span>
        </div>
      </div>
      <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:4px;">
        <a href="<%= _lien %>?but=profil/profil-modif.jsp&idprofil=<%= _idprofil %>"
           style="padding:6px 16px;background:#0a66c2;color:#fff;border:none;border-radius:20px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-block">
          Modifier le profil
        </a>
        <button onclick="pvShowStatutForm()"
           style="padding:6px 16px;background:#fff;color:#0a66c2;border:1px solid #0a66c2;border-radius:20px;font-size:13px;font-weight:600;cursor:pointer;">
          <i class="bi bi-star-fill"></i> Statut
        </button>
        <a href="<%= _lien %>?but=profil/confidentialite.jsp"
           style="padding:6px 16px;background:#fff;color:#0a66c2;border:1px solid #0a66c2;border-radius:20px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-block">
          <i class="fa fa-lock"></i> Confidentialité
        </a>
      </div>
    </div>
  </div>

  <!-- ── Promotion & Parcours ── -->
  <div class="pv-section">
    <div class="pv-section-header">
      <h2><i class="bi bi-mortarboard-fill"></i> Promotion &amp; Parcours</h2>
    </div>
    <div class="pv-tags">
      <span class="pv-tag"      id="pvPromoTag">—</span>
      <span class="pv-tag grey" id="pvParcoursTag">—</span>
    </div>
  </div>

  <!-- ── Spécialités ── -->
  <div class="pv-section">
    <div class="pv-section-header">
      <h2><i class="bi bi-star-fill"></i> Spécialités</h2>
      <button class="pv-btn-add" onclick="pvOpenModal('modalAddSpec')"><i class="bi bi-plus-lg"></i> Ajouter</button>
    </div>
    <div id="pvSpecialites" style="display:flex;flex-wrap:wrap;gap:8px;">
      <% if (specProfils.length == 0) { %>
        <em style="color:#aaa;font-size:13px">Aucune spécialité renseignée.</em>
      <% } else {
        for (int si = 0; si < specProfils.length; si++) {
          String specLib = "";
          for (int ai = 0; ai < allSpecialites.length; ai++) {
            if (allSpecialites[ai].getIdspecialite() != null
                && allSpecialites[ai].getIdspecialite().equals(specProfils[si].getIdspecialite())) {
              specLib = allSpecialites[ai].getLibelle() != null ? allSpecialites[ai].getLibelle() : "";
              break;
            }
          }
      %>
        <%
          String specPhoto = "";
          for (int api = 0; api < allSpecialites.length; api++) {
            if (allSpecialites[api].getIdspecialite() != null
                && allSpecialites[api].getIdspecialite().equals(specProfils[si].getIdspecialite())
                && allSpecialites[api].getPhoto() != null && !allSpecialites[api].getPhoto().isEmpty()) {
              specPhoto = allSpecialites[api].getPhoto();
              break;
            }
          }
        %>
        <div class="pv-spec-item" id="spec-<%= specProfils[si].getSpecialiteprofil() %>">
          <% if (!specPhoto.isEmpty()) { %><img src="<%= request.getContextPath() + "/" + specPhoto %>" alt="" style="width:22px;height:22px;border-radius:50%;object-fit:cover;"><% } %>
          <span><%= specLib %></span>
          <span class="pv-spec-niveau">Niv. <%= specProfils[si].getNiveau() %></span>
          <button title="Supprimer" onclick="pvDeleteSpec('<%= specProfils[si].getSpecialiteprofil() %>')">×</button>
        </div>
      <% } } %>
    </div>
  </div>

  <!-- ── À propos / Informations ── -->
  <div class="pv-section">
    <div class="pv-section-header">
      <h2><i class="bi bi-person-lines-fill"></i> À propos</h2>
    </div>
    <div class="pv-grid">
      <div class="pv-field">
        <label><i class="bi bi-person-fill pv-info-icon"></i>Nom complet</label>
        <span id="fi-nom">—</span> <span id="fi-prenom"></span>
      </div>
      <div class="pv-field">
        <label><i class="bi bi-gender-ambiguous pv-info-icon"></i>Genre</label>
        <span id="fi-genre" style="display:flex;align-items:center;gap:4px;">
          <i class="bi" id="fi-genre-icon" style="color:#7c3aed;"></i>
          <span id="fi-genre-text">—</span>
        </span>
      </div>
      <div class="pv-field">
        <label><i class="bi bi-calendar-heart pv-info-icon"></i>Date de naissance</label>
        <span id="fi-dtn">—</span>
      </div>
      <div class="pv-field">
        <label><i class="bi bi-telephone-fill pv-info-icon"></i>Téléphone</label>
        <span id="fi-tel">—</span>
      </div>
      <div class="pv-field">
        <label><i class="bi bi-envelope-fill pv-info-icon"></i>Email</label>
        <span id="fi-email">—</span>
      </div>
      <div class="pv-field">
        <label><i class="bi bi-mortarboard-fill pv-info-icon"></i>Promotion</label>
        <span id="fi-promo">—</span>
      </div>
      <div class="pv-field">
        <label><i class="bi bi-book-fill pv-info-icon"></i>Parcours</label>
        <span id="fi-parcours">—</span>
      </div>
      <div class="pv-field">
        <label><i class="bi bi-award-fill pv-info-icon"></i>Contributions</label>
        <span style="display:inline-flex;align-items:center;gap:5px;">
          <span id="fi-contribution" style="font-weight:700;color:#f57f17;">0</span>
          <span style="font-size:12px;color:#888;">publications</span>
        </span>
      </div>
      <div class="pv-field">
        <label><i class="bi bi-fingerprint pv-info-icon"></i>ID Profil</label>
        <span id="fi-id" style="font-family:monospace;font-size:12px;color:#888;">—</span>
      </div>
    </div>
  </div>

  <!-- ── Sécurité ── -->
  <div class="pv-section">
    <div class="pv-section-header">
      <h2><i class="bi bi-shield-lock-fill"></i> Sécurité</h2>
    </div>
    <div style="padding:4px 0;">
      <button class="pv-btn-add" onclick="pvOpenModal('modalPassword')" style="gap:6px;">
        <i class="bi bi-key-fill"></i> Modifier le mot de passe
      </button>
      <p style="font-size:12px;color:#888;margin-top:6px;">Protégez votre compte en modifiant régulièrement votre mot de passe.</p>
    </div>
  </div>

  <!-- ── Réseaux Sociaux ── -->
  <div class="pv-section">
    <div class="pv-section-header">
      <h2><i class="bi bi-globe2"></i> Réseaux Sociaux</h2>
      <button class="pv-btn-add" onclick="pvOpenModal('modalAddSocial')"><i class="bi bi-plus-lg"></i> Ajouter</button>
    </div>
    <div id="pvSocialMedia" class="pv-social-grid">
      <% if (socialMedias.length == 0) { %>
        <em style="color:#aaa;font-size:13px">Aucun réseau social renseigné.</em>
      <% } else {
        for (int smi = 0; smi < socialMedias.length; smi++) {
          ProfilSocialMedia sm = socialMedias[smi];
          // Trouver le réseau correspondant
          String smLibelle = "";
          String smIcone = "bi bi-link-45deg";
          String smCouleur = "#6c757d";
          String smUrlPattern = "";
          for (int ri = 0; ri < allReseaux.length; ri++) {
            if (allReseaux[ri].getIdReseauSocial() != null
                && allReseaux[ri].getIdReseauSocial().equals(sm.getIdReseauSocial())) {
              smLibelle = allReseaux[ri].getLibelle() != null ? allReseaux[ri].getLibelle() : "";
              smIcone = allReseaux[ri].getIconeClass() != null ? allReseaux[ri].getIconeClass() : "bi bi-link-45deg";
              smCouleur = allReseaux[ri].getCouleurHex() != null ? allReseaux[ri].getCouleurHex() : "#6c757d";
              smUrlPattern = allReseaux[ri].getUrlPattern() != null ? allReseaux[ri].getUrlPattern() : "";
              break;
            }
          }
          String smValeur = sm.getValeur() != null ? sm.getValeur() : "";
          String smUrl = smUrlPattern.replace("{value}", smValeur);
          String smIdStr = (sm.getIdProfilSocial() != null ? sm.getIdProfilSocial() : "");
      %>
        <a class="pv-social-item" id="social-<%= smIdStr %>"
           href="<%= smUrl %>" target="_blank" rel="noopener noreferrer"
           title="<%= smLibelle %>: <%= smValeur %>">
          <div class="pv-social-icon" style="background:<%= smCouleur %>">
            <i class="<%= smIcone %>"></i>
          </div>
          <div class="pv-social-info">
            <span class="pv-social-name"><%= smLibelle %></span>
            <span class="pv-social-val"><%= smValeur %></span>
          </div>
          <button class="pv-social-del" type="button" title="Supprimer"
                  onclick="event.preventDefault();event.stopPropagation();pvDeleteSocial('<%= smIdStr %>')">×</button>
        </a>
      <% } } %>
    </div>
  </div>

  <!-- ── Expériences ── -->
  <div class="pv-section">
    <div class="pv-section-header">
      <h2><i class="bi bi-briefcase-fill"></i> Expériences</h2>
      <button class="pv-btn-add" onclick="pvShowExpForm()"><i class="bi bi-plus-lg"></i> Ajouter</button>
    </div>
    <div id="pvExperiences">
      <% if (experiences.length == 0) { %>
        <em style="color:#aaa;font-size:13px">Aucune expérience.</em>
      <% } else {
        for (int ei = 0; ei < experiences.length; ei++) {
          ExperienceLib ex = experiences[ei];
          String eId    = ex.getIdexperience() != null ? ex.getIdexperience() : "";
          String eEnt   = ex.getEntreprise()   != null ? ex.getEntreprise()   : "";
          String ePoste = ex.getPostelib()     != null ? ex.getPostelib()     : "";
          String eDeb   = ex.getDebut()        != null ? ex.getDebut().toString() : "";
          String eFin   = ex.getFin()          != null ? ex.getFin().toString()   : "";
          String eDesc  = ex.getDescription()  != null ? ex.getDescription()  : "";
          String eIdp   = ex.getIdposte()      != null ? ex.getIdposte()      : "";
      %>
        <div class="pv-exp-item" id="exp-<%= eId %>">
          <div class="pv-exp-actions">
            <button title="Modifier" onclick="pvEditExp('<%= eId %>','<%= eEnt.replace("'","\\'") %>','<%= eDeb %>','<%= eFin %>','<%= eDesc.replace("'","\\'").replace("\n","\\n") %>','<%= eIdp %>')"><i class="bi bi-pencil-fill"></i></button>
            <button class="del" title="Supprimer" onclick="pvDeleteExp('<%= eId %>')"><i class="bi bi-trash-fill"></i></button>
          </div>
          <% if (!eEnt.isEmpty()) { %><div class="pv-exp-company"><%= eEnt.replace("<","&lt;") %></div><% } %>
          <% if (!ePoste.isEmpty()) { %><div class="pv-exp-poste"><%= ePoste.replace("<","&lt;") %></div><% } %>
          <div class="pv-exp-dates"><%= eDeb %> → <%= eFin.isEmpty() ? "Actuel" : eFin %></div>
          <% if (!eDesc.isEmpty()) { %><div class="pv-exp-desc"><%= eDesc.replace("<","&lt;").replace("\n","<br>") %></div><% } %>
        </div>
      <% } } %>
    </div>
  </div>

  <!-- ── Publications ── -->
  <div class="pv-section" id="pvPubSection">
    <div class="pv-section-header">
      <h2><i class="bi bi-newspaper"></i> Publications</h2>
    </div>
    <div id="pvPublications"><em style="color:#aaa;font-size:13px;">Chargement...</em></div>
  </div>

</div><!-- /pv-card -->
  </main>
</div><!-- /pv-profile-layout -->

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
    <div class="pub-detail-box">
        <div class="pub-detail-header">
            <h3 class="pub-detail-title">Publication</h3>
            <button class="rdm-close" onclick="closePublicationDetail()">&times;</button>
        </div>
        <div class="pub-detail-body" id="pub-detail-content"></div>
    </div>
</div>

<script>
var CTX = '<%= request.getContextPath() %>';
var CURRENT_USER_ID = '<%= uEJB.getUser().getRefuser() %>';
(function () {
  <% if (_erreur != null) { %>
  alert("Erreur chargement profil : <%= _erreur.replace("\"", "'").replace("\n", " ") %>");
  <% } %>

  var ctx  = "<%= request.getContextPath() %>";
  var p = {
    idprofil     : "<%= _idprofil %>",
    email        : "<%= _email %>",
    nom          : "<%= _nom %>",
    prenom       : "<%= _prenom %>",
    dtn          : "<%= _dtn %>",
    telephone    : "<%= _telephone %>",
    idpromotion  : "<%= _idpromotion %>",
    promotionLib : "<%= _promolib %>",
    idparcours   : "<%= _idparcours %>",
    parcoursLib  : "<%= _parcourslib %>",
    photo        : "<%= _photoUrl %>",
    photoCover   : "<%= _photoCoverUrl %>",
    genreLib     : "<%= _genrelib %>",
    idgenre      : "<%= _idgenre %>",
    contribution : <%= _contribution %>
  };

  /* Cover */
  if (p.photoCover) {
    var ci = document.createElement("img");
    ci.src = p.photoCover; ci.className = "pv-cover-img";
    var cover = document.getElementById("pvCover");
    cover.insertBefore(ci, cover.firstChild);
  }

  /* Avatar */
  var av = document.getElementById("pvAvatar");
  if (p.photo) {
    av.innerHTML = '<img src="' + p.photo + '" alt="">';
  } else {
    av.textContent = (p.prenom.charAt(0) + p.nom.charAt(0)).toUpperCase();
  }

  /* Identité */
  document.getElementById("pvNameText").textContent  = p.prenom + " " + p.nom;
  document.getElementById("pvHeadline").textContent = p.parcoursLib + "  ·  " + p.promotionLib;
  var em = document.getElementById("pvEmail");
  em.textContent = p.email; em.href = "mailto:" + p.email;
  document.getElementById("pvPhone").innerHTML = '<i class="bi bi-telephone-fill" style="color:#008BFF;margin-right:4px;"></i>' + (p.telephone || '—');

  /* Genre badge near name */
  if (p.genreLib) {
    document.getElementById("pvGenreText").textContent = p.genreLib;
    document.getElementById("pvGenreIcon").className = "bi " + (p.idgenre === "GEN000001" ? "bi-gender-male" : "bi-gender-female");
    document.getElementById("pvGenreBadge").style.display = "inline-flex";
  }
  document.getElementById("pvContributionText").textContent = p.contribution;
  document.getElementById("pvPromoTag").innerHTML  = '<i class="bi bi-mortarboard-fill" style="margin-right:5px;"></i>' + (p.promotionLib || '—');
  document.getElementById("pvParcoursTag").innerHTML = '<i class="bi bi-book-fill" style="margin-right:5px;"></i>' + (p.parcoursLib || '—');

  /* À propos / Grille */
  document.getElementById("fi-nom").textContent       = (p.prenom + " " + p.nom).trim() || "—";
  document.getElementById("fi-prenom").textContent    = "";   /* fusionné dans fi-nom */
  document.getElementById("fi-genre-text").textContent = p.genreLib || "—";
  if (p.idgenre) document.getElementById("fi-genre-icon").className = "bi " + (p.idgenre === "GEN000001" ? "bi-gender-male" : "bi-gender-female");
  document.getElementById("fi-dtn").textContent       = p.dtn ? p.dtn.split("-").reverse().join("/") : "—";
  document.getElementById("fi-tel").textContent       = p.telephone || "—";
  document.getElementById("fi-email").textContent     = p.email || "—";
  document.getElementById("fi-id").textContent        = p.idprofil || "—";
  document.getElementById("fi-promo").textContent     = p.promotionLib ? p.promotionLib + (p.idpromotion ? " (" + p.idpromotion + ")" : "") : "—";
  document.getElementById("fi-parcours").textContent  = p.parcoursLib  ? p.parcoursLib  + (p.idparcours  ? " (" + p.idparcours  + ")" : "") : "—";
  var fiContrib = document.getElementById("fi-contribution");
  if (fiContrib) fiContrib.textContent = p.contribution;

})();

/* ════════════════════════════════════════
   EXPERIENCE CRUD
   ════════════════════════════════════════ */
var _expUrl = "<%= request.getContextPath() %>/pages/profil/ajax/traitement-experience.jsp";

function pvShowExpForm(editId, ent, deb, fin, desc, idp) {
  document.getElementById("expFormId").value        = editId || "";
  document.getElementById("expEntreprise").value    = editId ? ent : "";
  document.getElementById("expDebut").value         = editId ? deb : "";
  document.getElementById("expFin").value           = editId ? fin : "";
  document.getElementById("expDescription").value   = editId ? desc.replace(/\\n/g, "\n") : "";
  document.getElementById("expPoste").value         = editId ? idp : "";
  document.getElementById("expModalTitle").textContent = editId ? "Modifier l'expérience" : "Ajouter une expérience";
  pvOpenModal("modalExp");
}

function pvEditExp(id, ent, deb, fin, desc, idp) {
  pvShowExpForm(id, ent, deb, fin, desc, idp);
}

function pvSaveExp() {
  var id   = document.getElementById("expFormId").value;
  var data = new URLSearchParams();
  data.append("action",      id ? "update" : "create");
  if (id) data.append("idexperience", id);
  data.append("entreprise",  document.getElementById("expEntreprise").value);
  data.append("debut",       document.getElementById("expDebut").value);
  data.append("fin",         document.getElementById("expFin").value);
  data.append("description", document.getElementById("expDescription").value);
  data.append("idposte",     document.getElementById("expPoste").value);

  fetch(_expUrl, { method: "POST", body: data,
    headers: {"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8","X-Requested-With":"XMLHttpRequest"}
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) { pvCloseModal("modalExp"); location.reload(); }
    else alert("Erreur : " + d.error);
  })
  .catch(function(e) { alert("Erreur réseau : " + e); });
}

function pvDeleteExp(id) {
  if (!confirm("Supprimer cette expérience ?")) return;
  fetch(_expUrl + "?action=delete&idexperience=" + encodeURIComponent(id), {
    headers: {"X-Requested-With":"XMLHttpRequest"}
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) {
      var el = document.getElementById("exp-" + id);
      if (el) el.remove();
    } else alert("Erreur : " + d.error);
  })
  .catch(function(e) { alert("Erreur réseau : " + e); });
}

/* ════════════════════════════════════════
   SPECIALITE CRUD
   ════════════════════════════════════════ */
var _specUrl = "<%= request.getContextPath() %>/pages/profil/ajax/traitement-specialite.jsp";

function pvAddSpec() {
  var sel    = document.getElementById("specSelect");
  var nivSel = document.getElementById("specNiveau");
  if (!sel.value) { alert("Sélectionnez une spécialité"); return; }

  var data = new URLSearchParams();
  data.append("action", "add");
  data.append("idspecialite", sel.value);
  data.append("niveau", nivSel.value);

  fetch(_specUrl, { method: "POST", body: data,
    headers: {"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8","X-Requested-With":"XMLHttpRequest"}
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) { pvCloseModal("modalAddSpec"); location.reload(); }
    else alert("Erreur : " + d.error);
  })
  .catch(function(e) { alert("Erreur réseau : " + e); });
}

function pvDeleteSpec(spId) {
  if (!confirm("Supprimer cette spécialité ?")) return;
  fetch(_specUrl + "?action=delete&specialiteprofil=" + encodeURIComponent(spId), {
    headers: {"X-Requested-With":"XMLHttpRequest"}
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) {
      var el = document.getElementById("spec-" + spId);
      if (el) el.remove();
    } else alert("Erreur : " + d.error);
  })
  .catch(function(e) { alert("Erreur réseau : " + e); });
}

/* ════════════════════════════════════════
   STATUT CRUD
   ════════════════════════════════════════ */
var _statutUrl = "<%= request.getContextPath() %>/pages/profil/ajax/traitement-profilstatut.jsp";
var _idprofil = "<%= _idprofil %>";
var _idutilisateur = "<%= uEJB.getUser().getRefuser() %>";

function pvShowStatutForm() {
  document.getElementById("statutSelect").value = "";
  pvOpenModal("modalStatut");
}

function pvSaveStatut() {
  var statutId = document.getElementById("statutSelect").value;
  if (!statutId) { alert("Veuillez sélectionner un statut"); return; }

  var data = new URLSearchParams();
  data.append("action", "update");
  data.append("idprofil", _idprofil);
  data.append("idprofiltypestatut", statutId);

  fetch(_statutUrl, { method: "POST", body: data,
    headers: {"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8","X-Requested-With":"XMLHttpRequest"}
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) { pvCloseModal("modalStatut"); location.reload(); }
    else alert("Erreur : " + d.error);
  })
  .catch(function(e) { alert("Erreur réseau : " + e); });
}

/* ════════════════════════════════════════
   SOCIAL MEDIA CRUD
   ════════════════════════════════════════ */
var _socialUrl = "<%= request.getContextPath() %>/pages/profil/ajax/traitement-socialmedia.jsp";

function pvAddSocial() {
  var sel = document.getElementById("socialSelect");
  var val = document.getElementById("socialValeur");
  if (!sel.value) { alert("Sélectionnez un réseau social"); return; }
  if (!val.value.trim()) { alert("Veuillez saisir un identifiant ou URL"); return; }

  var data = new URLSearchParams();
  data.append("action", "add");
  data.append("idreseausocial", sel.value);
  data.append("valeur", val.value.trim());

  fetch(_socialUrl, { method: "POST", body: data,
    headers: {"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8","X-Requested-With":"XMLHttpRequest"}
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) { pvCloseModal("modalAddSocial"); location.reload(); }
    else alert("Erreur : " + d.error);
  })
  .catch(function(e) { alert("Erreur réseau : " + e); });
}

function pvDeleteSocial(smId) {
  if (!confirm("Supprimer ce réseau social ?")) return;
  fetch(_socialUrl + "?action=delete&idprofilsocial=" + encodeURIComponent(smId), {
    headers: {"X-Requested-With":"XMLHttpRequest"}
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) {
      var el = document.getElementById("social-" + smId);
      if (el) el.remove();
      // Si plus de social media, afficher le message vide
      var container = document.getElementById("pvSocialMedia");
      if (container && container.querySelectorAll(".pv-social-item").length === 0) {
        container.innerHTML = '<em style="color:#aaa;font-size:13px">Aucun réseau social renseigné.</em>';
      }
    } else alert("Erreur : " + d.error);
  })
  .catch(function(e) { alert("Erreur réseau : " + e); });
}

/* ── Met à jour le placeholder du champ social selon le réseau sélectionné ── */
function pvUpdateSocialPlaceholder() {
  var sel   = document.getElementById('socialSelect');
  var input = document.getElementById('socialValeur');
  var hint  = document.getElementById('socialUrlHint');
  var hintText = document.getElementById('socialUrlHintText');
  var opt   = sel.options[sel.selectedIndex];

  if (!opt || !opt.value) {
    input.placeholder = 'ex: monpseudo ou https://...';
    hint.style.display = 'none';
    return;
  }

  var pattern = opt.getAttribute('data-urlpattern') || '';
  var label   = opt.textContent.trim();

  if (pattern && pattern.indexOf('{value}') !== -1) {
    var baseUrl = pattern.split('{value}')[0];
    input.placeholder = 'Votre pseudo ' + label + ' (ex: johndoe)';
    hintText.textContent = baseUrl + ' est déjà inclus automatiquement';
    hint.style.display = 'block';
  } else {
    input.placeholder = 'Lien ou identifiant ' + label;
    hint.style.display = 'none';
  }
}

/* ── Helpers modals ── */
function pvOpenModal(id)  { document.getElementById(id).style.display = "flex"; }
function pvCloseModal(id) { document.getElementById(id).style.display = "none"; }

/* ── Aperçu image avant upload ── */
function pvPreview(inputId, previewId) {
  var f = document.getElementById(inputId).files[0];
  if (!f) return;
  var img = document.getElementById(previewId);
  img.src = URL.createObjectURL(f);
  img.style.display = "block";
}

/* ── Upload PDP (type=1) ou PDC (type=0) ── */
function pvUploadPhoto(inputId, typeVal, apresOk) {
  var fi = document.getElementById(inputId);
  if (!fi.files[0]) { alert("Sélectionnez une image."); return; }
  var fd = new FormData();
  fd.append("photo", fi.files[0]);
  fd.append("type",  String(typeVal));
  fetch("<%= request.getContextPath() %>/pages/profil/ajax/traitement-photo.jsp", {
    method: "POST", body: fd
  })
  .then(function(r){ return r.json(); })
  .then(function(d){
    if (d.success) {
      apresOk("<%= request.getContextPath() %>/" + d.image);
      pvCloseModal(typeVal === 1 ? "modalPDP" : "modalPDC");
    } else { alert("Erreur : " + d.error); }
  })
  .catch(function(e){ alert("Erreur réseau : " + e); });
}

/* ── Toggle eye icon on password fields ── */
function pvTogglePwdEye(span) {
  var inp = span.parentElement.querySelector('input');
  var ico = span.querySelector('i');
  if (inp.type === 'password') {
    inp.type = 'text';
    ico.className = 'fa fa-eye-slash';
  } else {
    inp.type = 'password';
    ico.className = 'fa fa-eye';
  }
}

/* ── Changer le mot de passe ── */
function pvChangePassword() {
  var alertBox = document.getElementById('pwdAlert');
  var oldPwd   = document.getElementById('pwdOld').value;
  var newPwd   = document.getElementById('pwdNew').value;
  var confPwd  = document.getElementById('pwdConfirm').value;

  alertBox.style.display = 'none';

  if (!oldPwd || !newPwd || !confPwd) {
    pvPwdAlert('Veuillez remplir tous les champs.', false);
    return;
  }
  if (newPwd.length < 3) {
    pvPwdAlert('Le nouveau mot de passe doit contenir au moins 3 caractères.', false);
    return;
  }
  if (newPwd !== confPwd) {
    pvPwdAlert('Les deux mots de passe ne correspondent pas.', false);
    return;
  }

  var btn = document.getElementById('btnSavePwd');
  btn.disabled = true;
  btn.textContent = 'En cours...';

  var fd = new FormData();
  fd.append('oldPassword', oldPwd);
  fd.append('newPassword', newPwd);
  fd.append('confirmPassword', confPwd);

  fetch('<%= request.getContextPath() %>/pages/profil/ajax/traitement-password.jsp', {
    method: 'POST', body: fd
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) {
      pvPwdAlert(d.message, true);
      document.getElementById('pwdOld').value = '';
      document.getElementById('pwdNew').value = '';
      document.getElementById('pwdConfirm').value = '';
      setTimeout(function() { pvCloseModal('modalPassword'); alertBox.style.display = 'none'; }, 2000);
    } else {
      pvPwdAlert(d.error || 'Erreur inconnue.', false);
    }
  })
  .catch(function(e) {
    pvPwdAlert('Erreur réseau : ' + e, false);
  })
  .finally(function() {
    btn.disabled = false;
    btn.textContent = 'Enregistrer';
  });
}

function pvPwdAlert(msg, isSuccess) {
  var box = document.getElementById('pwdAlert');
  box.style.display = 'block';
  box.textContent = msg;
  if (isSuccess) {
    box.style.background = '#d4edda';
    box.style.color = '#155724';
    box.style.border = '1px solid #c3e6cb';
  } else {
    box.style.background = '#f8d7da';
    box.style.color = '#721c24';
    box.style.border = '1px solid #f5c6cb';
  }
}

// ========== PUBLICATIONS DU PROFIL ==========
function pvLoadPubs(idutilisateur, idprofil, cursorId) {
    var container = document.getElementById('pvPublications');
    if (cursorId === '') {
        container.innerHTML = '<em style="color:#aaa;font-size:13px;">Chargement...</em>';
    }
    var url = CTX + '/pages/alumni/ajax/publications-profil.jsp?'
        + 'idutilisateur=' + encodeURIComponent(idutilisateur)
        + '&idprofil=' + encodeURIComponent(idprofil)
        + (cursorId ? '&cursor_id=' + encodeURIComponent(cursorId) : '');
    fetch(url)
        .then(function(r) { return r.text(); })
        .then(function(html) {
            if (cursorId === '') {
                container.innerHTML = html;
            } else {
                // Supprimer le bouton "voir plus" existant
                var existing = container.querySelector('.ppub-load-more-wrap');
                if (existing) existing.remove();
                var tmp = document.createElement('div');
                tmp.innerHTML = html;
                while (tmp.firstChild) container.appendChild(tmp.firstChild);
            }
        })
        .catch(function(e) { container.innerHTML = '<p style="color:red;font-size:13px;">Erreur: ' + e + '</p>'; });
}
function ppubLoadMore(btn, iduser, idprofil, cursorId) {
    btn.disabled = true; btn.textContent = 'Chargement...';
    var container = document.getElementById('pvPublications');
    var url = CTX + '/pages/alumni/ajax/publications-profil.jsp?'
        + 'idutilisateur=' + encodeURIComponent(iduser)
        + '&idprofil=' + encodeURIComponent(idprofil)
        + '&cursor_id=' + encodeURIComponent(cursorId);
    fetch(url)
        .then(function(r) { return r.text(); })
        .then(function(html) {
            var wrap = btn.closest('.ppub-load-more-wrap');
            if (wrap) wrap.remove();
            var tmp = document.createElement('div'); tmp.innerHTML = html;
            while (tmp.firstChild) container.appendChild(tmp.firstChild);
        })
        .catch(function(e) { btn.disabled = false; btn.textContent = 'Voir plus'; alert('Erreur: ' + e); });
}
// Charger les publications au chargement
document.addEventListener('DOMContentLoaded', function() {
    pvLoadPubs('<%= uEJB.getUser().getRefuser() %>', '<%= _idprofil %>', '');
});
</script>
<script src="<%= request.getContextPath() %>/assets/js/publication-cards.js"></script>

<!-- Modal : Changer le Profil Statut -->
<div class="pv-modal-overlay" id="modalStatut">
  <div class="pv-modal">
    <h3>Modifier le statut</h3>
    <label>Statut</label>
    <select id="statutSelect" style="width:100%;">
      <option value=""  >Sélectionnez un statut...</option>
      <% for (int i = 0; i < allStatutTypes.length; i++) {
          ProfilTypeStatut pts = allStatutTypes[i];
      %>
      <option value="<%= pts.getIdprofiltypestatut() %>"><%= pts.getLibelle() %></option>
      <% } %>
    </select>
    <div class="pv-modal-footer">
      <button class="pv-btn-cancel" onclick="pvCloseModal('modalStatut')">Annuler</button>
      <button class="pv-btn-save" onclick="pvSaveStatut()">Enregistrer</button>
    </div>
  </div>
</div>

<!-- ═══════════════ MODALS ═══════════════ -->
<style>
.pv-modal-overlay {
  display: none; position: fixed; inset: 0;
  background: rgba(0,0,0,.45); z-index: 9999;
  align-items: center; justify-content: center;
}
.pv-modal {
  background: #fff; border-radius: 12px;
  padding: 28px 28px 20px; width: 90%; max-width: 480px;
  box-shadow: 0 8px 32px rgba(0,0,0,.22);
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  max-height: 90vh; overflow-y: auto;
}
.pv-modal h3 { margin: 0 0 18px; font-size: 17px; font-weight: 700; }
.pv-modal label { font-size: 12px; font-weight: 700; text-transform: uppercase;
  letter-spacing: .5px; color: #666; display: block; margin: 12px 0 4px; }
.pv-modal input[type=text],
.pv-modal input[type=date],
.pv-modal select,
.pv-modal textarea {
  width: 100%; padding: 9px 12px; border: 1px solid #ccc; border-radius: 8px;
  font-size: 14px; box-sizing: border-box; font-family: inherit;
}
.pv-modal textarea { min-height: 70px; resize: vertical; }
.pv-modal select { background: #fff; }
.pv-modal-footer { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
.pv-btn-cancel { background: #f0f0f0; border: none; border-radius: 20px;
  padding: 8px 20px; font-size: 13px; cursor: pointer; }
.pv-btn-save { background: #0a66c2; color: #fff; border: none; border-radius: 20px;
  padding: 8px 20px; font-size: 13px; font-weight: 600; cursor: pointer; }
.pv-btn-save:hover { background: #004182; }
.pv-preview-img { max-width:100%; max-height:160px; margin-top:10px;
  border-radius: 8px; display: none; object-fit: cover; }
.pv-form-row { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px; }
@media(max-width:900px){ .pv-form-row { grid-template-columns: 1fr 1fr; } }
@media(max-width:520px){ .pv-form-row { grid-template-columns: 1fr; } }
</style>

<!-- Modal : Ajouter / Modifier Expérience -->
<div class="pv-modal-overlay" id="modalExp">
  <div class="pv-modal">
    <h3 id="expModalTitle">Ajouter une expérience</h3>
    <input type="hidden" id="expFormId">
    <label>Entreprise *</label>
    <input type="text" id="expEntreprise" placeholder="Nom de l'entreprise">
    <label>Poste *</label>
    <select id="expPoste">
      <option value="">— Sélectionner —</option>
      <% for (int pi = 0; pi < allPostes.length; pi++) { %>
      <option value="<%= allPostes[pi].getIdposte() %>"><%= allPostes[pi].getLibelle() != null ? allPostes[pi].getLibelle().replace("<","&lt;") : "" %></option>
      <% } %>
    </select>
    <div class="pv-form-row">
      <div><label>Date début</label><input type="date" id="expDebut"></div>
      <div><label>Date fin</label><input type="date" id="expFin"></div>
    </div>
    <label>Description</label>
    <textarea id="expDescription" placeholder="Décrivez votre rôle..."></textarea>
    <div class="pv-modal-footer">
      <button type="button" class="pv-btn-cancel" onclick="pvCloseModal('modalExp')">Annuler</button>
      <button type="button" class="pv-btn-save" onclick="pvSaveExp()">Enregistrer</button>
    </div>
  </div>
</div>

<!-- Modal : Ajouter Spécialité -->
<div class="pv-modal-overlay" id="modalAddSpec">
  <div class="pv-modal">
    <h3>Ajouter une spécialité</h3>
    <label>Spécialité *</label>
    <select id="specSelect">
      <option value="">— Sélectionner —</option>
      <% for (int spi = 0; spi < allSpecialites.length; spi++) { %>
      <option value="<%= allSpecialites[spi].getIdspecialite() %>"><%= allSpecialites[spi].getLibelle() != null ? allSpecialites[spi].getLibelle().replace("<","&lt;") : "" %></option>
      <% } %>
    </select>
    <label>Niveau (1–5)</label>
    <select id="specNiveau">
      <option value="1">1 — Débutant</option>
      <option value="2">2 — Intermédiaire</option>
      <option value="3" selected>3 — Confirmé</option>
      <option value="4">4 — Avancé</option>
      <option value="5">5 — Expert</option>
    </select>
    <div class="pv-modal-footer">
      <button type="button" class="pv-btn-cancel" onclick="pvCloseModal('modalAddSpec')">Annuler</button>
      <button type="button" class="pv-btn-save" onclick="pvAddSpec()">Ajouter</button>
    </div>
  </div>
</div>

<!-- Modal : Modifier le mot de passe -->
<div class="pv-modal-overlay" id="modalPassword">
  <div class="pv-modal">
    <h3><i class="bi bi-shield-lock"></i> Modifier le mot de passe</h3>

    <div id="pwdAlert" style="display:none;padding:10px 14px;border-radius:8px;margin-bottom:12px;font-size:13px;"></div>

    <label>Ancien mot de passe *</label>
    <div style="position:relative;">
      <input type="password" id="pwdOld" placeholder="Votre mot de passe actuel"
             style="width:100%;padding:8px 38px 8px 12px;border:1px solid #ddd;border-radius:8px;font-size:14px;">
      <span onclick="pvTogglePwdEye(this)" style="position:absolute;right:10px;top:50%;transform:translateY(-50%);cursor:pointer;color:#999;">
        <i class="fa fa-eye"></i>
      </span>
    </div>

    <label style="margin-top:10px;display:block;">Nouveau mot de passe *</label>
    <div style="position:relative;">
      <input type="password" id="pwdNew" placeholder="Au moins 3 caractères"
             style="width:100%;padding:8px 38px 8px 12px;border:1px solid #ddd;border-radius:8px;font-size:14px;">
      <span onclick="pvTogglePwdEye(this)" style="position:absolute;right:10px;top:50%;transform:translateY(-50%);cursor:pointer;color:#999;">
        <i class="fa fa-eye"></i>
      </span>
    </div>

    <label style="margin-top:10px;display:block;">Confirmer le nouveau mot de passe *</label>
    <div style="position:relative;">
      <input type="password" id="pwdConfirm" placeholder="Retapez le nouveau mot de passe"
             style="width:100%;padding:8px 38px 8px 12px;border:1px solid #ddd;border-radius:8px;font-size:14px;">
      <span onclick="pvTogglePwdEye(this)" style="position:absolute;right:10px;top:50%;transform:translateY(-50%);cursor:pointer;color:#999;">
        <i class="fa fa-eye"></i>
      </span>
    </div>

    <div class="pv-modal-footer">
      <button type="button" class="pv-btn-cancel" onclick="pvCloseModal('modalPassword')">Annuler</button>
      <button type="button" class="pv-btn-save" id="btnSavePwd" onclick="pvChangePassword()">Enregistrer</button>
    </div>
  </div>
</div>

<!-- Modal : Ajouter Réseau Social -->
<div class="pv-modal-overlay" id="modalAddSocial">
  <div class="pv-modal">
    <h3>Ajouter un réseau social</h3>
    <label>Réseau social *</label>
    <select id="socialSelect" onchange="pvUpdateSocialPlaceholder()">
      <option value="">— Sélectionner —</option>
      <% for (int rsi = 0; rsi < allReseaux.length; rsi++) { %>
      <option value="<%= allReseaux[rsi].getIdReseauSocial() %>"
              data-icone="<%= allReseaux[rsi].getIconeClass() != null ? allReseaux[rsi].getIconeClass() : "" %>"
              data-couleur="<%= allReseaux[rsi].getCouleurHex() != null ? allReseaux[rsi].getCouleurHex() : "" %>"
              data-urlpattern="<%= allReseaux[rsi].getUrlPattern() != null ? allReseaux[rsi].getUrlPattern().replace("<","&lt;") : "" %>">
        <%= allReseaux[rsi].getLibelle() != null ? allReseaux[rsi].getLibelle().replace("<","&lt;") : "" %>
      </option>
      <% } %>
    </select>
    <label>Identifiant / URL *</label>
    <input type="text" id="socialValeur" placeholder="ex: monpseudo ou https://..." style="width:100%;padding:8px 12px;border:1px solid #ddd;border-radius:8px;font-size:14px;">
    <p id="socialUrlHint" style="display:none;font-size:12px;color:#888;margin:4px 0 0 2px;">
      <i class="bi bi-info-circle"></i> <span id="socialUrlHintText"></span>
    </p>
    <div class="pv-modal-footer">
      <button type="button" class="pv-btn-cancel" onclick="pvCloseModal('modalAddSocial')">Annuler</button>
      <button type="button" class="pv-btn-save" onclick="pvAddSocial()">Ajouter</button>
    </div>
  </div>
</div>

<!-- Modal : Photo de profil (PDP — type=1) -->
<div class="pv-modal-overlay" id="modalPDP">
  <div class="pv-modal">
    <h3>Changer la photo de profil</h3>
    <input type="file" id="filePDP" accept="image/*"
           onchange="pvPreview('filePDP','previewPDP')" style="margin-top:8px">
    <img id="previewPDP" class="pv-preview-img" alt="Aperçu">
    <div class="pv-modal-footer">
      <button type="button" class="pv-btn-cancel" onclick="pvCloseModal('modalPDP')">Annuler</button>
      <button type="button" class="pv-btn-save" onclick="pvUploadPhoto('filePDP', 1, function(img){
        var av = document.getElementById('pvAvatar');
        av.innerHTML = '<img src=&quot;' + img + '&quot; alt=&quot;&quot;>';
      })">Enregistrer</button>
    </div>
  </div>
</div>

<!-- Modal : Photo de couverture (PDC — type=0) -->
<div class="pv-modal-overlay" id="modalPDC">
  <div class="pv-modal">
    <h3>Changer la photo de couverture</h3>
    <input type="file" id="filePDC" accept="image/*"
          onchange="pvPreview('filePDC','previewPDC')" style="margin-top:8px">
    <img id="previewPDC" class="pv-preview-img" alt="Aperçu">
    <div class="pv-modal-footer">
      <button type="button" class="pv-btn-cancel" onclick="pvCloseModal('modalPDC')">Annuler</button>
      <button type="button" class="pv-btn-save" onclick="pvUploadPhoto('filePDC', 0, function(img){
        var cover = document.getElementById('pvCover');
        var ex = cover.querySelector('.pv-cover-img');
        if (ex) { ex.src = img; } else {
          var i = document.createElement('img');
          i.src = img; i.className = 'pv-cover-img';
          cover.insertBefore(i, cover.firstChild);
        }
      })">Enregistrer</button>
    </div>
  </div>
</div>
