<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
  <!DOCTYPE html>
  <html lang="fr">

  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>OPUS — Inscription</title>

    <!-- Bootstrap 3.3.7 (du projet) -->
    <link href="${pageContext.request.contextPath}/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />

    <!-- FontAwesome 4.4.0 (du projet) -->
    <link href="${pageContext.request.contextPath}/dist/css/font-awesome-4.4.0/css/font-awesome.min.css"
      rel="stylesheet" type="text/css" />

    <!-- OPUS CUSTOM THEME (local, utilisant les fonts du projet) -->
    <link href="${pageContext.request.contextPath}/assets/css/alumni-theme.css" rel="stylesheet" type="text/css" />
    <!-- OPUS Global Theme -->
    <link href="${pageContext.request.contextPath}/assets/css/opus-theme.css" rel="stylesheet" type="text/css" />

    <!-- SweetAlert (du projet) -->
    <script src="${pageContext.request.contextPath}/dist/js/swal.js"></script>
  </head>

  <body>
    <% String errMsg=(String) session.getAttribute("errorInscription"); if(errMsg !=null){
      session.removeAttribute("errorInscription"); %>
      <script>
        Swal.fire({
          title: "Erreur",
          text: "<%= errMsg.replace("\"", "\\\"") %> ",
        icon: "error",
          confirmButtonText: "OK"
      });
      </script>
      <% } %>
        <div class="login-split">
          <!-- LEFT PANEL (optional, same as login page) -->
          <div class="login-left">
            <div class="login-brand">
              <img class="login-brand-logo" src="${pageContext.request.contextPath}/dist/img/ITU_logo.png"
                alt="ITU logo" />
              <span class="login-brand-text"><span class="brand-itu">ITU</span><span
                  class="brand-alumni">alumni</span></span>
            </div>

            <div class="login-hero-wrap" style="zoom: 1.25;">
              <h1 class="login-hero-title">Votre réseau,<br /><span>votre avenir.</span></h1>
              <p class="login-hero-text">Rejoignez la communauté exclusive des anciens de l'ITUniversity. Échangez avec
                vos pairs, partagez des opportunités qualifiées et propulsez votre carrière vers de nouveaux
                horizons.<br>
                Toute inscription est soumise à validation par les modérateurs.</p>
            </div>
          </div>

          <!-- RIGHT PANEL -->
          <div class="login-right">
            <div
              style="position: absolute; bottom: 2rem; right: 2rem; font-family: var(--font-serif); font-size: 8rem; font-weight: 900; color: rgba(0,0,0,0.03); line-height: 1; pointer-events: none; z-index: 0;">
              OPUS</div>

            <div class="login-card" style="position: relative; z-index: 1; zoom: 1.25;">
              <h2
                style="font-family: var(--font-serif); font-size: 2rem; color: var(--itu-dark); margin-bottom: 0.4rem; font-weight: 700;">
                Créer un compte</h2>
              <p style="color: var(--gray-500); font-size: 0.95rem; margin-bottom: 1.75rem;">Rejoignez la communauté
                OPUS en quelques clics. <br>
                Toute inscription est soumise à validation par les modérateurs.</p>

              <div class="steps-track">
                <div class="step-item active">
                  <div class="step-circle"><span class="glyphicon glyphicon-lock"></span></div>
                  <span class="step-name">Identifiants</span>
                </div>
                <div class="step-line"></div>
                <div class="step-item inactive">
                  <div class="step-circle"></div>
                  <span class="step-name">Profil</span>
                </div>
                <div class="step-line"></div>
                <div class="step-item inactive">
                  <div class="step-circle"></div>
                  <span class="step-name">Validation</span>
                </div>
              </div>

              <!-- REGISTER FORM - STEP 1 -->
              <div id="register-form">
                <form action="detailsInscription.jsp" method="post" autocomplete="off">
                  <div class="form-group">
                    <label class="field-label">Numéro ETU <span style="color:red">*</span></label>
                    <div class="input-icon-wrap">
                      <span class="glyphicon glyphicon-education input-icon"></span>
                      <input type="text" name="etu" class="form-control-custom with-icon" placeholder="Ex: ETU003356"
                        required />
                    </div>
                  </div>
                  <div class="form-group" style="margin-bottom: 0.75rem;">
                    <label class="field-label">Mot de passe <span style="color:red">*</span></label>
                    <div class="input-icon-wrap">
                      <span class="glyphicon glyphicon-lock input-icon"></span>
                      <input type="password" id="pwd" name="password" class="form-control-custom with-icon"
                        placeholder="Min. 8 caractères" required />
                    </div>
                    <div class="info-badge"><i class="fa fa-info-circle"></i> Minimum 8 caractères</div>
                  </div>
                  <div class="form-group" style="margin-bottom: 2rem;">
                    <label class="field-label">Confirmer le mot de passe <span style="color:red">*</span></label>
                    <div class="input-icon-wrap">
                      <span class="glyphicon glyphicon-lock input-icon"></span>
                      <input type="password" id="pwd-confirm" class="form-control-custom with-icon"
                        placeholder="Répétez votre mot de passe" required />
                    </div>
                    <div id="pwd-feedback"></div>
                  </div>
                  <button type="submit" class="btn-login">
                    Continuer <i class="fa fa-arrow-right"></i>
                  </button>
                </form>
                <p style="text-align:center; margin-top:1.25rem; font-size:0.88rem; color:var(--gray-500);">
                  Déjà un compte ?
                  <a href="${pageContext.request.contextPath}/index.jsp"
                    style="color:var(--itu-blue); font-weight:600; text-decoration:none;">Se connecter</a>
                </p>
              </div>
            </div>
          </div>
        </div>

        <script src="${pageContext.request.contextPath}/plugins/jQuery/jQuery-2.1.4.min.js"
          type="text/javascript"></script>
        <!-- Bootstrap 3.3.2 JS -->
        <script src="${pageContext.request.contextPath}/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>

        <script>
          (function () {
            var pwd = document.getElementById('pwd');
            var confirm = document.getElementById('pwd-confirm');
            var feedback = document.getElementById('pwd-feedback');
            var btn = document.querySelector('.btn-login');
            var form = document.querySelector('#register-form form');

            function check() {
              var p = pwd.value;
              var c = confirm.value;
              if (!c) { feedback.innerHTML = ''; return; }
              if (p === c) {
                feedback.innerHTML = '<span class="pwd-match-badge match"><span class="glyphicon glyphicon-ok"></span> Les mots de passe correspondent</span>';
                confirm.style.borderColor = '#16a34a';
              } else {
                feedback.innerHTML = '<span class="pwd-match-badge nomatch"><span class="glyphicon glyphicon-remove"></span> Les mots de passe ne correspondent pas</span>';
                confirm.style.borderColor = '#dc2626';
              }
            }

            if (pwd) pwd.addEventListener('input', check);
            if (confirm) confirm.addEventListener('input', check);

            if (form) {
              form.addEventListener('submit', function (e) {
                if (pwd.value !== confirm.value) {
                  e.preventDefault();
                  confirm.focus();
                  check();
                } else {
                  btn.disabled = true;
                  btn.innerHTML = '<span class="glyphicon glyphicon-refresh" style="animation:spin .8s linear infinite"></span> Chargement…';
                }
              });
            }
          })();
        </script>

        <script src="${pageContext.request.contextPath}/assets/js/timer-flottant.js"></script>
  </body>

  </html>