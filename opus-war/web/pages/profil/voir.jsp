<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.ProfilLib" %>
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
%>
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
</style>

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
  <div class="pv-avatar-wrap">
    <div class="pv-avatar" id="pvAvatar"></div>
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
        <div class="pv-name" id="pvName" style="display:flex;align-items:center;gap:10px;"><span id="pvNameText">—</span><span id="pvGenreBadge" style="display:none;font-size:12px;font-weight:600;background:#f3e8ff;color:#7c3aed;border-radius:14px;padding:3px 12px;white-space:nowrap;"><i class="bi" id="pvGenreIcon"></i> <span id="pvGenreText"></span></span></div>
        <div class="pv-headline" id="pvHeadline">—</div>
        <div class="pv-meta">
          <span>📍 Antananarivo, Madagascar</span>
          <a id="pvEmail" href="#">—</a>
          <span id="pvPhone">—</span>
        </div>
      </div>
      <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:4px;">
        <a href="<%= _lien %>?but=profil/profil-modif.jsp&idprofil=<%= _idprofil %>"
           style="padding:6px 16px;background:#0a66c2;color:#fff;border:none;border-radius:20px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-block">
          Modifier le profil
        </a>
        <a href="<%= _lien %>?but=profil/confidentialite.jsp"
           style="padding:6px 16px;background:#fff;color:#0a66c2;border:1px solid #0a66c2;border-radius:20px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-block">
          <i class="fa fa-lock"></i> Confidentialité
        </a>
      </div>
    </div>
  </div>

  <!-- ── Promotion & Parcours ── -->
  <div class="pv-section">
    <h2>Promotion & Parcours</h2>
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

  <!-- ── Informations ── -->
  <div class="pv-section">
    <h2>Informations</h2>
    <div class="pv-grid">
      <div class="pv-field"><label>Nom</label>              <span id="fi-nom">—</span></div>
      <div class="pv-field"><label>Prénom</label>           <span id="fi-prenom">—</span></div>
      <div class="pv-field"><label>Genre</label>             <span id="fi-genre"><i class="bi" id="fi-genre-icon" style="color:#7c3aed;margin-right:4px;"></i><span id="fi-genre-text">—</span></span></div>
      <div class="pv-field"><label>Date de naissance</label><span id="fi-dtn">—</span></div>
      <div class="pv-field"><label>Téléphone</label>        <span id="fi-tel">—</span></div>
      <div class="pv-field"><label>Email</label>            <span id="fi-email">—</span></div>
      <div class="pv-field"><label>ID Profil</label>        <span id="fi-id">—</span></div>
      <div class="pv-field"><label>Promotion</label>        <span id="fi-promo">—</span></div>
      <div class="pv-field"><label>Parcours</label>         <span id="fi-parcours">—</span></div>
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

</div>

<script>
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
    idgenre      : "<%= _idgenre %>"
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
  document.getElementById("pvPhone").textContent    = "📞 " + p.telephone;

  /* Genre badge near name */
  if (p.genreLib) {
    document.getElementById("pvGenreText").textContent = p.genreLib;
    document.getElementById("pvGenreIcon").className = "bi " + (p.idgenre === "GEN000001" ? "bi-gender-male" : "bi-gender-female");
    document.getElementById("pvGenreBadge").style.display = "inline-flex";
  }
  document.getElementById("pvPromoTag").textContent    = "🎓 " + p.promotionLib;
  document.getElementById("pvParcoursTag").textContent = "📚 " + p.parcoursLib;

  /* Grille */
  document.getElementById("fi-nom").textContent      = p.nom;
  document.getElementById("fi-prenom").textContent   = p.prenom;
  document.getElementById("fi-genre-text").textContent = p.genreLib || "—";
  if (p.idgenre) document.getElementById("fi-genre-icon").className = "bi " + (p.idgenre === "GEN000001" ? "bi-gender-male" : "bi-gender-female");
  document.getElementById("fi-dtn").textContent      = p.dtn ? p.dtn.split("-").reverse().join("/") : "";
  document.getElementById("fi-tel").textContent      = p.telephone;
  document.getElementById("fi-email").textContent    = p.email;
  document.getElementById("fi-id").textContent       = p.idprofil;
  document.getElementById("fi-promo").textContent    = p.promotionLib + " (" + p.idpromotion + ")";
  document.getElementById("fi-parcours").textContent = p.parcoursLib  + " (" + p.idparcours  + ")";

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
</script>

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

<!-- Modal : Ajouter Réseau Social -->
<div class="pv-modal-overlay" id="modalAddSocial">
  <div class="pv-modal">
    <h3>Ajouter un réseau social</h3>
    <label>Réseau social *</label>
    <select id="socialSelect">
      <option value="">— Sélectionner —</option>
      <% for (int rsi = 0; rsi < allReseaux.length; rsi++) { %>
      <option value="<%= allReseaux[rsi].getIdReseauSocial() %>"
              data-icone="<%= allReseaux[rsi].getIconeClass() != null ? allReseaux[rsi].getIconeClass() : "" %>"
              data-couleur="<%= allReseaux[rsi].getCouleurHex() != null ? allReseaux[rsi].getCouleurHex() : "" %>">
        <%= allReseaux[rsi].getLibelle() != null ? allReseaux[rsi].getLibelle().replace("<","&lt;") : "" %>
      </option>
      <% } %>
    </select>
    <label>Identifiant / URL *</label>
    <input type="text" id="socialValeur" placeholder="ex: monpseudo ou https://..." style="width:100%;padding:8px 12px;border:1px solid #ddd;border-radius:8px;font-size:14px;">
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
