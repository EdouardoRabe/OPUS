<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.CGenUtil, alumni.Parcours, alumni.Promotion, alumni.Genre" %>

<%
    // retrieve previous step values (from POST params or session fallback after error)
    String etu = request.getParameter("etu");
    String password = request.getParameter("password");
    if(etu == null || etu.isEmpty()){
        etu = (String) session.getAttribute("reg_etu");
        if(etu != null) session.removeAttribute("reg_etu");
    }
    if(password == null || password.isEmpty()){
        password = (String) session.getAttribute("reg_password");
        if(password != null) session.removeAttribute("reg_password");
    }

    // load parcours list for select
    alumni.Parcours pCriteria = new alumni.Parcours();
    alumni.Parcours[] parcoursList = (alumni.Parcours[]) bean.CGenUtil.rechercher(pCriteria, null, null, "");

    // load genre list (static choices)
    alumni.Genre gCriteria = new alumni.Genre();
    alumni.Genre[] genreList = (alumni.Genre[]) bean.CGenUtil.rechercher(gCriteria, null, null, "");

    // if parcours selected, load promotions for that parcours
    String selectedParcours = request.getParameter("idparcours");
    // keep track of genre selection too
    String selectedGenre = request.getParameter("idgenre");
    // Restaurer les valeurs du formulaire depuis la session (apres erreur)
    String savedEmail = null, savedPrenom = null, savedNom = null, savedDtn = null, savedTel = null, savedPromo = null;
    if(selectedParcours == null || selectedParcours.isEmpty()){
        selectedParcours = (String) session.getAttribute("reg_idparcours");
        if(selectedParcours != null) session.removeAttribute("reg_idparcours");
    }
    if(selectedGenre == null || selectedGenre.isEmpty()){
        selectedGenre = (String) session.getAttribute("reg_idgenre");
        if(selectedGenre != null) session.removeAttribute("reg_idgenre");
    }
    savedEmail = (String) session.getAttribute("reg_email");
    if(savedEmail != null) session.removeAttribute("reg_email");
    savedPrenom = (String) session.getAttribute("reg_prenom");
    if(savedPrenom != null) session.removeAttribute("reg_prenom");
    savedNom = (String) session.getAttribute("reg_nom");
    if(savedNom != null) session.removeAttribute("reg_nom");
    savedDtn = (String) session.getAttribute("reg_dtn");
    if(savedDtn != null) session.removeAttribute("reg_dtn");
    savedTel = (String) session.getAttribute("reg_telephone");
    if(savedTel != null) session.removeAttribute("reg_telephone");
    savedPromo = (String) session.getAttribute("reg_idpromotion");
    if(savedPromo != null) session.removeAttribute("reg_idpromotion");

    // Restaurer le type de role (etu ou alu)
    String selectedTyperole = request.getParameter("typerole");
    if(selectedTyperole == null || selectedTyperole.isEmpty()){
        selectedTyperole = (String) session.getAttribute("reg_typerole");
        if(selectedTyperole != null) session.removeAttribute("reg_typerole");
    }

    alumni.Promotion[] promoList = new alumni.Promotion[0];
    if(selectedParcours != null && !selectedParcours.isEmpty()){
        alumni.Promotion promoCrit = new alumni.Promotion();
        promoCrit.setIdparcours(selectedParcours);
        promoList = (alumni.Promotion[]) bean.CGenUtil.rechercher(promoCrit, null, null, "");
    }
%>
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>OPUS — Compléter l'inscription</title>

    <link href="${pageContext.request.contextPath}/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="${pageContext.request.contextPath}/dist/js/font-awesome-4.4.0/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="${pageContext.request.contextPath}/assets/css/alumni-theme.css" rel="stylesheet" type="text/css" />
    <script src="${pageContext.request.contextPath}/dist/js/swal.js"></script>
  </head>
  <body>
    <% String errMsg = (String) session.getAttribute("errorInscription");
       if(errMsg != null){
           session.removeAttribute("errorInscription"); %>
    <script>
      Swal.fire({
        title: "Erreur",
        text: "<%= errMsg.replace("\"","\\\"") %>",
        icon: "error",
        confirmButtonText: "OK"
      });
    </script>
    <% } %>
    <div class="login-split">
      <div class="login-left">
        <div class="login-brand">
          <img class="login-brand-logo" src="${pageContext.request.contextPath}/dist/img/ITU_logo.png" alt="ITU logo" />
          <span class="login-brand-text"><span class="brand-itu">ITU</span><span class="brand-alumni">alumni</span></span>
        </div>
        <div class="login-hero-wrap">
          <h1 class="login-hero-title">Votre réseau,<br /><span>votre avenir.</span></h1>
          <p class="login-hero-text">Merci d’avoir commencé votre inscription.<br />Complétez les informations pour finaliser votre profil.</p>
        </div>
      </div>

      <div class="login-right">
        <div style="position: absolute; bottom: 2rem; right: 2rem; font-family: var(--font-serif); font-size: 8rem; font-weight: 900; color: rgba(0,0,0,0.03); line-height: 1; pointer-events: none; z-index: 0;">OPUS</div>
        <div class="login-card" style="position: relative; z-index: 1;">
          <h2 style="font-family: var(--font-serif); font-size: 2rem; color: var(--itu-dark); margin-bottom: 0.4rem; font-weight: 700;">Finaliser l'inscription</h2>
          <p style="color: var(--gray-500); font-size: 0.95rem; margin-bottom: 1.5rem;">Complétez les champs ci-dessous.</p>

          <div class="steps-track">
            <div class="step-item completed">
              <div class="step-circle"><span class="glyphicon glyphicon-ok"></span></div>
              <span class="step-name">Identifiants</span>
            </div>
            <div class="step-line completed"></div>
            <div class="step-item active">
              <div class="step-circle"><span class="glyphicon glyphicon-user"></span></div>
              <span class="step-name">Profil</span>
            </div>
            <div class="step-line"></div>
            <div class="step-item inactive">
              <div class="step-circle"></div>
              <span class="step-name">Validation</span>
            </div>
          </div>

          <div id="details-form">
            <form id="detailsForm" action="testRegister.jsp" method="post">
              <input type="hidden" name="etu" value="<%= etu %>" />
              <input type="hidden" name="password" value="<%= password %>" />

              <!-- Type de compte (Étudiant ou Alumni) -->
              <div class="form-group">
                <label class="field-label">Type de compte <span style="color:red">*</span></label>
                <div class="input-icon-wrap">
                  <span class="glyphicon glyphicon-briefcase input-icon"></span>
                  <select name="typerole" class="form-control-custom with-icon" required>
                    <option value="etu" <%= (selectedTyperole == null || "etu".equals(selectedTyperole)) ? "selected" : "" %>>Étudiant</option>
                    <option value="alu" <%= "alu".equals(selectedTyperole) ? "selected" : "" %>>Alumni</option>
                  </select>
                </div>
              </div>

              <!-- Parcours + Promotion sur une ligne -->
              <div class="row">
                <div class="col-xs-7 form-group">
                  <label class="field-label">Parcours <span style="color:red">*</span></label>
                  <div class="input-icon-wrap">
                    <span class="glyphicon glyphicon-book input-icon"></span>
                    <select name="idparcours" class="form-control-custom with-icon" onchange="reloadWithParcours(this.value)" required>
                      <option value="">-- choisissez --</option>
                      <% for(alumni.Parcours pp : parcoursList){ %>
                        <option value="<%=pp.getIdparcours()%>" <%= pp.getIdparcours().equals(selectedParcours) ? "selected" : "" %>><%=pp.getLibelle()%></option>
                      <% } %>
                    </select>
                  </div>
                </div>
                <div class="col-xs-5 form-group" style="position:relative;">
                  <label class="field-label">Promotion <span style="color:red">*</span></label>
                  <input type="hidden" name="idpromotion" id="hdnPromotion" value="<%= savedPromo != null ? savedPromo : "" %>" />
                  <div class="input-icon-wrap">
                    <span class="glyphicon glyphicon-calendar input-icon"></span>
                    <input type="text" id="promoSearchInput" class="form-control-custom with-icon"
                           placeholder="<%= (promoList == null || promoList.length == 0) ? "parcours d'abord" : "Rechercher..." %>"
                           <%= (promoList == null || promoList.length == 0) ? "disabled" : "" %>
                           autocomplete="off" />
                  </div>
                  <div id="promoDropdown" style="display:none;position:absolute;z-index:9999;width:100%;background:#fff;border:1px solid #ddd;border-top:none;border-radius:0 0 4px 4px;max-height:180px;overflow-y:auto;box-shadow:0 4px 10px rgba(0,0,0,0.1);"></div>
                </div>
              </div>

              <!-- Prénom + Nom -->
              <div class="row">
                <div class="col-xs-6 form-group">
                  <label class="field-label">Prénom <span style="color:red">*</span></label>
                  <div class="input-icon-wrap">
                    <span class="glyphicon glyphicon-user input-icon"></span>
                    <input type="text" name="prenom" class="form-control-custom with-icon" placeholder="Jean" value="<%= savedPrenom != null ? savedPrenom : "Jean" %>" required />
                  </div>
                </div>
                <div class="col-xs-6 form-group">
                  <label class="field-label">Nom <span style="color:red">*</span></label>
                  <div class="input-icon-wrap">
                    <span class="glyphicon glyphicon-user input-icon"></span>
                    <input type="text" name="nom" class="form-control-custom with-icon" placeholder="Dupont" value="<%= savedNom != null ? savedNom : "Dupont" %>" required />
                  </div>
                </div>
              </div>

              <!-- E-mail -->
              <div class="form-group">
                <label class="field-label">E-mail <span style="color:red">*</span></label>
                <div class="input-icon-wrap">
                  <span class="glyphicon glyphicon-envelope input-icon"></span>
                  <input type="email" name="email" class="form-control-custom with-icon" placeholder="jean.dupont@opus.edu" value="<%= savedEmail != null ? savedEmail : "jean.dupont@opus.edu" %>" required />
                </div>
              </div>

              <!-- Date de naissance + Genre sur une ligne -->
              <div class="row">
                <div class="col-xs-7 form-group">
                  <label class="field-label">Date de naissance <span style="color:red">*</span></label>
                  <div class="input-icon-wrap">
                    <span class="glyphicon glyphicon-gift input-icon"></span>
                    <input type="date" name="dtn" class="form-control-custom with-icon" value="<%= savedDtn != null ? savedDtn : "2000-01-15" %>" required />
                  </div>
                </div>
                <div class="col-xs-5 form-group">
                  <label class="field-label">Genre <span style="color:red">*</span></label>
                  <div class="input-icon-wrap">
                    <span class="glyphicon glyphicon-asterisk input-icon"></span>
                    <select name="idgenre" class="form-control-custom with-icon" required>
                      <option value="">--</option>
                      <% for(alumni.Genre g : genreList){ %>
                        <option value="<%=g.getIdgenre()%>" <%= (selectedGenre != null && selectedGenre.equals(g.getIdgenre())) ? "selected" : "" %>><%=g.getLibelle()%></option>
                      <% } %>
                    </select>
                  </div>
                </div>
              </div>

              <!-- Téléphone -->
              <div class="form-group" style="margin-bottom: 2rem;">
                <label class="field-label">Téléphone <span style="color:red">*</span></label>
                <div class="input-icon-wrap">
                  <span class="glyphicon glyphicon-phone input-icon"></span>
                  <input type="tel" name="telephone" class="form-control-custom with-icon" placeholder="06 12 34 56 78" value="<%= savedTel != null ? savedTel : "034 12 345 67" %>" required />
                </div>
              </div>

              <button type="submit" class="btn-login">
                Valider l'inscription <i class="fa fa-arrow-right"></i>
              </button>
            </form>
            <p style="text-align:center; margin-top:1.25rem; font-size:0.88rem; color:var(--gray-500);">
              <a href="${pageContext.request.contextPath}/index.jsp" style="color:var(--gray-500); text-decoration:none;">Annuler et retourner à la connexion</a>
            </p>
          </div>
        </div>
      </div>
    </div>

    <script src="${pageContext.request.contextPath}/plugins/jQuery/jQuery-2.1.4.min.js" type="text/javascript"></script>

    <script src="${pageContext.request.contextPath}/assets/js/timer-flottant.js"></script>

    <style>
      .promo-option {
        padding: 8px 12px;
        cursor: pointer;
        font-size: 0.9rem;
        color: #333;
      }
      .promo-option:hover, .promo-option.active {
        background: #f0f4ff;
        color: var(--itu-primary, #0a66c2);
      }
      .promo-option-empty {
        padding: 8px 12px;
        font-size: 0.85rem;
        color: #999;
        font-style: italic;
      }
    </style>

    <script>
      function reloadWithParcours(val) {
        var form = document.getElementById('detailsForm');
        form.idparcours.value = val;
        form.action = 'detailsInscription.jsp';
        form.submit();
      }

      (function() {
        var promos = [
          <% if(promoList != null) { for(int i = 0; i < promoList.length; i++) { %>
          {id:"<%=promoList[i].getIdpromotion()%>",lib:"<%=promoList[i].getLibelle()%>"}<%=i < promoList.length - 1 ? "," : ""%>
          <% } } %>
        ];

        var input    = document.getElementById('promoSearchInput');
        var hidden   = document.getElementById('hdnPromotion');
        var dropdown = document.getElementById('promoDropdown');

        if (!input || promos.length === 0) return;

        // pre-fill display if a promo is already selected (error restore)
        <% if(savedPromo != null && !savedPromo.isEmpty()) { %>
        for (var k = 0; k < promos.length; k++) {
          if (promos[k].id === "<%=savedPromo%>") { input.value = promos[k].lib; break; }
        }
        <% } %>

        var activeIdx = -1;

        function renderList(q) {
          q = (q || '').trim().toLowerCase();
          if (!q) {
            dropdown.style.display = 'none';
            return;
          }
          var items = promos.filter(function(p) {
            return p.lib.toLowerCase().indexOf(q) !== -1;
          });
          if (items.length === 0) {
            dropdown.innerHTML = '<div class="promo-option-empty">Aucun résultat</div>';
          } else {
            dropdown.innerHTML = items.map(function(p) {
              return '<div class="promo-option" data-id="' + p.id + '" data-lib="' + p.lib + '">' + p.lib + '</div>';
            }).join('');
            dropdown.querySelectorAll('.promo-option').forEach(function(el) {
              el.addEventListener('mousedown', function(e) {
                e.preventDefault();
                selectPromo(this.getAttribute('data-id'), this.getAttribute('data-lib'));
              });
            });
          }
          activeIdx = -1;
          dropdown.style.display = 'block';
        }

        function selectPromo(id, lib) {
          input.value  = lib;
          hidden.value = id;
          dropdown.style.display = 'none';
        }

        input.addEventListener('input', function() {
          hidden.value = '';
          renderList(this.value);
        });

        input.addEventListener('keydown', function(e) {
          var opts = dropdown.querySelectorAll('.promo-option[data-id]');
          if (e.key === 'ArrowDown') {
            e.preventDefault();
            activeIdx = Math.min(activeIdx + 1, opts.length - 1);
          } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            activeIdx = Math.max(activeIdx - 1, 0);
          } else if (e.key === 'Enter' && activeIdx >= 0) {
            e.preventDefault();
            selectPromo(opts[activeIdx].getAttribute('data-id'), opts[activeIdx].getAttribute('data-lib'));
            return;
          } else if (e.key === 'Escape') {
            dropdown.style.display = 'none';
            return;
          }
          opts.forEach(function(o, i) {
            o.classList.toggle('active', i === activeIdx);
          });
          if (activeIdx >= 0) opts[activeIdx].scrollIntoView({block:'nearest'});
        });

        document.addEventListener('click', function(e) {
          if (e.target !== input && !dropdown.contains(e.target)) {
            dropdown.style.display = 'none';
            if (input.value && !hidden.value) input.value = '';
          }
        });

        // block submit if no promotion selected
        document.getElementById('detailsForm').addEventListener('submit', function(e) {
          if (!hidden.value) {
            e.preventDefault();
            input.focus();
            input.style.borderColor = '#e74c3c';
            setTimeout(function() { input.style.borderColor = ''; }, 2000);
            Swal.fire({title:'Promotion requise', text:'Veuillez sélectionner une promotion.', icon:'warning', confirmButtonText:'OK'});
          }
        });
      })();
    </script>


  </body>
</html>