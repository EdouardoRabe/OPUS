<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.ExperienceLib" %>
<%@ page import="java.sql.Connection" %>
<%
    UserEJB    uEJB  = (UserEJB) session.getAttribute("u");
    String     _lien = (String) session.getValue("lien");
    ProfilLib      profil = null;
    ExperienceLib[] experiences = null;
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
                " and idutilisateur='" + mu.getRefuser() + "'"
            );
        } catch (Exception e) {
            _erreur = e.getMessage();
            System.err.println("voir.jsp - erreur chargement profil: " + e.getMessage());
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
    }
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
%>
<style>
.pv-card {
  max-width: 760px;
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
  height: 148px;
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
  margin-top: -48px;
  margin-left: 24px;
  position: relative;
  z-index: 1;
}
.pv-avatar {
  width: 96px; height: 96px;
  border-radius: 50%;
  border: 3px solid #fff;
  box-shadow: 0 2px 8px rgba(0,0,0,.18);
  background: #0a66c2;
  display: flex; align-items: center; justify-content: center;
  font-size: 30px; font-weight: 700; color: #fff;
  overflow: hidden;
}
.pv-avatar img { width:100%; height:100%; object-fit:cover; border-radius:50%; }

/* ── Top ── */
.pv-top {
  padding: 10px 24px 18px;
  border-bottom: 1px solid #eee;
}
.pv-name     { font-size: 21px; font-weight: 700; line-height: 1.25; }
.pv-headline { font-size: 14px; color: #555; margin-top: 3px; }
.pv-meta {
  display: flex; flex-wrap: wrap; gap: 16px;
  margin-top: 8px; font-size: 13px; color: #666;
}
.pv-meta a { color: #0a66c2; text-decoration: none; font-weight: 500; }
.pv-meta a:hover { text-decoration: underline; }

/* ── Sections ── */
.pv-section { padding: 18px 24px; border-bottom: 1px solid #eee; }
.pv-section:last-child { border-bottom: none; }
.pv-section h2 { font-size: 15px; font-weight: 700; margin-bottom: 14px; }

/* Tags */
.pv-tags { display: flex; flex-wrap: wrap; gap: 8px; }
.pv-tag {
  background: #eef3fb; color: #0a66c2;
  border-radius: 14px; padding: 5px 14px;
  font-size: 13px; font-weight: 600;
}
.pv-tag.grey { background: #f0f0f0; color: #555; }

/* Info grid */
.pv-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px 28px; }
@media(max-width:520px){ .pv-grid { grid-template-columns: 1fr; } }
.pv-field label {
  font-size: 10px; font-weight: 700; text-transform: uppercase;
  letter-spacing: .6px; color: #888; display: block; margin-bottom: 3px;
}
.pv-field span { font-size: 14px; }
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
        <div class="pv-name"     id="pvName">—</div>
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

  <!-- ── Formation ── -->
  <div class="pv-section">
    <h2>Formation</h2>
    <div class="pv-tags">
      <span class="pv-tag"      id="pvPromoTag">—</span>
      <span class="pv-tag grey" id="pvParcoursTag">—</span>
    </div>
  </div>

  <!-- ── Informations ── -->
  <div class="pv-section">
    <h2>Informations</h2>
    <div class="pv-grid">
      <div class="pv-field"><label>Nom</label>              <span id="fi-nom">—</span></div>
      <div class="pv-field"><label>Prénom</label>           <span id="fi-prenom">—</span></div>
      <div class="pv-field"><label>Date de naissance</label><span id="fi-dtn">—</span></div>
      <div class="pv-field"><label>Téléphone</label>        <span id="fi-tel">—</span></div>
      <div class="pv-field"><label>Email</label>            <span id="fi-email">—</span></div>
      <div class="pv-field"><label>ID Profil</label>        <span id="fi-id">—</span></div>
      <div class="pv-field"><label>Promotion</label>        <span id="fi-promo">—</span></div>
      <div class="pv-field"><label>Parcours</label>         <span id="fi-parcours">—</span></div>
    </div>
  </div>

  <!-- ── Expériences ── -->
  <div class="pv-section">
    <h2>Expériences</h2>
    <div id="pvExperiences"><em style="color:#aaa">Aucune expérience.</em></div>
  </div>

</div>

<script>
(function () {
  <% if (_erreur != null) { %>
  alert("Erreur chargement profil : <%= _erreur.replace("\"", "'").replace("\n", " ") %>");
  <% } %>
  /* ── Données depuis ProfilLib (session) ── */
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
    photoCover   : "<%= _photoCoverUrl %>"
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
  document.getElementById("pvName").textContent     = p.prenom + " " + p.nom;
  document.getElementById("pvHeadline").textContent = p.parcoursLib + "  ·  " + p.promotionLib;
  var em = document.getElementById("pvEmail");
  em.textContent = p.email; em.href = "mailto:" + p.email;
  document.getElementById("pvPhone").textContent    = "📞 " + p.telephone;

  /* Tags */
  document.getElementById("pvPromoTag").textContent    = "🎓 " + p.promotionLib;
  document.getElementById("pvParcoursTag").textContent = "📚 " + p.parcoursLib;

  /* Grille */
  document.getElementById("fi-nom").textContent      = p.nom;
  document.getElementById("fi-prenom").textContent   = p.prenom;
  document.getElementById("fi-dtn").textContent      = p.dtn.split("-").reverse().join("/");
  document.getElementById("fi-tel").textContent      = p.telephone;
  document.getElementById("fi-email").textContent    = p.email;
  document.getElementById("fi-id").textContent       = p.idprofil;
  document.getElementById("fi-promo").textContent    = p.promotionLib + " (" + p.idpromotion + ")";
  document.getElementById("fi-parcours").textContent = p.parcoursLib  + " (" + p.idparcours  + ")";
  /* Expériences */
  var exps = [
    <% if (experiences != null) { for (int experienceIndex = 0; experienceIndex < experiences.length; experienceIndex++) { ExperienceLib ex = experiences[experienceIndex]; %>
    {
      entreprise : "<%= ex.getEntreprise() != null ? ex.getEntreprise().replace("\"","&quot;") : "" %>",
      poste      : "<%= ex.getPostelib()   != null ? ex.getPostelib()  .replace("\"","&quot;") : "" %>",
      debut      : "<%= ex.getDebut()      != null ? ex.getDebut()                            : "" %>",
      fin        : "<%= ex.getFin()        != null ? ex.getFin()                              : "" %>",
      description: "<%= ex.getDescription()!= null ? ex.getDescription().replace("\"","&quot;").replace("\n"," ") : "" %>"
    }<%= experienceIndex < experiences.length - 1 ? "," : "" %>
    <% } } %>
  ];
  (function () {
    var wrap = document.getElementById("pvExperiences");
    if (!exps.length) return;
    wrap.innerHTML = "";
    exps.forEach(function (e) {
      var div = document.createElement("div");
      div.style.cssText = "border-left:3px solid #0a66c2;padding:8px 0 8px 14px;margin-bottom:14px";
      div.innerHTML =
        '<div style="font-weight:700;font-size:14px">' + e.entreprise + '</div>' +
        '<div style="font-size:13px;color:#0a66c2">' + e.poste + '</div>' +
        '<div style="font-size:12px;color:#888;margin:2px 0">' + e.debut + ' → ' + e.fin + '</div>' +
        (e.description ? '<div style="font-size:13px;color:#444;margin-top:4px">' + e.description + '</div>' : '');
      wrap.appendChild(div);
    });
  })();

})();

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
  padding: 28px 28px 20px; width: 90%; max-width: 420px;
  box-shadow: 0 8px 32px rgba(0,0,0,.22);
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
}
.pv-modal h3 { margin: 0 0 18px; font-size: 17px; font-weight: 700; }
.pv-modal label { font-size: 12px; font-weight: 700; text-transform: uppercase;
  letter-spacing: .5px; color: #666; display: block; margin: 12px 0 4px; }
.pv-modal input[type=text] {
  width: 100%; padding: 8px 11px; border: 1px solid #ccc; border-radius: 6px;
  font-size: 14px; box-sizing: border-box;
}
.pv-modal-footer { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
.pv-btn-cancel { background: #f0f0f0; border: none; border-radius: 20px;
  padding: 8px 20px; font-size: 13px; cursor: pointer; }
.pv-btn-save { background: #0a66c2; color: #fff; border: none; border-radius: 20px;
  padding: 8px 20px; font-size: 13px; font-weight: 600; cursor: pointer; }
.pv-btn-save:hover { background: #004182; }
.pv-preview-img { max-width:100%; max-height:160px; margin-top:10px;
  border-radius: 8px; display: none; object-fit: cover; }
</style>

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
