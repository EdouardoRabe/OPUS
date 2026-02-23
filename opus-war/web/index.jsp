<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
    String queryString = request.getQueryString();
    String but = "pages/testLogin.jsp";
    if(queryString != null && !queryString.equals("")){
        but += "?" + queryString;
    }
%>
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OPUS — Connexion</title>

    <!-- Bootstrap 3.3.7 (du projet) -->
    <link href="${pageContext.request.contextPath}/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />

    <!-- FontAwesome 4.4.0 (du projet) -->
    <link href="${pageContext.request.contextPath}/dist/css/font-awesome-4.4.0/css/font-awesome.min.css" rel="stylesheet" type="text/css" />

    <!-- OPUS CUSTOM THEME (local, utilisant les fonts du projet) -->
    <link href="${pageContext.request.contextPath}/assets/css/alumni-theme.css" rel="stylesheet" type="text/css" />

    <!-- SweetAlert (du projet) -->
    <script src="${pageContext.request.contextPath}/dist/js/swal.js"></script>
  </head>
  <body>
    <div class="login-split">
      <!-- LEFT PANEL -->
      <div class="login-left">
        <div class="login-brand">
          <img class="login-brand-logo" src="${pageContext.request.contextPath}/dist/img/ITU_logo.png" alt="ITU logo" />
          <span class="login-brand-text"><span class="brand-itu">ITU</span><span class="brand-alumni">alumni</span></span>
        </div>

        <div class="login-hero-wrap">
          <h1 class="login-hero-title">Votre réseau,<br><span>votre avenir.</span></h1>
          <p class="login-hero-text">Rejoignez la communauté exclusive des anciens de l'ITUniversity. Échangez avec vos pairs, partagez des opportunités qualifiées et propulsez votre carrière vers de nouveaux horizons.</p>
        </div>
      </div>

      <!-- RIGHT PANEL -->
      <div class="login-right">
        <div style="position: absolute; bottom: 2rem; right: 2rem; font-family: var(--font-serif); font-size: 8rem; font-weight: 900; color: rgba(0,0,0,0.03); line-height: 1; pointer-events: none; z-index: 0;">OPUS</div>

        <div class="login-card" style="position: relative; z-index: 1;">
          <h2 style="font-family: var(--font-serif); font-size: 2rem; color: var(--itu-dark); margin-bottom: 0.4rem; font-weight: 700;">Bienvenue</h2>
          <p style="color: var(--gray-500); font-size: 0.95rem; margin-bottom: 1.75rem;">Accédez à votre espace privilégié OPUS</p>

          <!-- TABS -->
          <div class="login-tabs">
            <button class="login-tab active" onclick="switchTab('login', event)">Connexion</button>
            <button class="login-tab" onclick="switchTab('register', event)">Inscription</button>
          </div>

          <!-- LOGIN FORM -->
          <div id="login-form">
            <form action="<%=but%>" method="post">
              <div class="form-group">
                <label>Identifiant</label>
                <div class="input-position-relative">
                  <input type="text" name="identifiant" class="form-control-custom" placeholder="E-mail ou numéro ETU" style="padding-right:90px;" required />
                  <span id="login-id-badge" style="background:var(--gray-200); color:var(--gray-500);">EMAIL</span>
                </div>
                <div class="info-badge">
                  <i class="fa fa-info-circle"></i> Utilisez votre <em>e-mail</em> ou <em>identifiant</em> (ex: <strong>ETU003356</strong>)
                </div>
              </div>
              <div class="form-group">
                <label>Mot de passe</label>
                <input type="password" name="passe" class="form-control-custom" placeholder="••••••••" required />
              </div>
              <div class="forgot">Mot de passe oublié ?</div>
              <button type="submit" class="btn btn-primary btn-block" id="login-btn" style="padding: 0.85rem; font-size: 1rem; font-weight: 700;">
                <span id="login-btn-text">Se connecter</span> <i class="fa fa-arrow-right" style="margin-left: 8px;"></i>
              </button>
            </form>
          </div>

          <!-- REGISTER FORM -->
          <div id="register-form" style="display: none;">
            <form action="#" method="post" onsubmit="return false;">
              <div class="row">
                <div class="col-xs-6 form-group">
                  <label>Prénom</label>
                  <input type="text" class="form-control-custom" placeholder="Jean" required />
                </div>
                <div class="col-xs-6 form-group">
                  <label>Nom</label>
                  <input type="text" class="form-control-custom" placeholder="Dupont" required />
                </div>
              </div>
              <div class="form-group">
                <label>E-mail universitaire</label>
                <input type="email" class="form-control-custom" placeholder="jean.dupont@opus.edu" required />
              </div>
              <div class="form-group">
                <label>Numéro ETU</label>
                <div class="input-position-relative">
                  <span style="position:absolute;left:14px;top:50%;transform:translateY(-50%);font-size:0.76rem;font-weight:700;letter-spacing:0.08em;color:var(--itu-blue);pointer-events:none;">ETU</span>
                  <input type="text" class="form-control-custom" placeholder="Ex: 003356" style="padding-left:52px;" required />
                </div>
              </div>
              <div class="form-group">
                <label>Promotion (année)</label>
                <input type="text" class="form-control-custom" placeholder="Ex: 2022" required />
              </div>
              <div class="form-group">
                <label>Mot de passe</label>
                <input type="password" class="form-control-custom" placeholder="Min. 8 caractères" required />
              </div>
              <button type="button" class="btn btn-primary btn-block" style="padding: 0.85rem; font-size: 1rem; font-weight: 700;" onclick="alert('L\'inscription sera intégrée ultérieurement')">
                Créer mon compte <i class="fa fa-arrow-right" style="margin-left: 8px;"></i>
              </button>
              <p style="font-size: 0.78rem; color: var(--gray-500); margin-top: 1rem; text-align: center;">
                <em>L'inscription sera disponible très prochainement</em>
              </p>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- jQuery 2.1.4 -->
    <script src="${pageContext.request.contextPath}/plugins/jQuery/jQuery-2.1.4.min.js" type="text/javascript"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="${pageContext.request.contextPath}/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>

    <script>
      // Fonction pour basculer entre les onglets
      function switchTab(tab, event) {
        if (event) {
          event.preventDefault();
        }

        // Masquer les deux formulaires
        document.getElementById('login-form').style.display = 'none';
        document.getElementById('register-form').style.display = 'none';

        // Désactiver tous les onglets
        document.querySelectorAll('.login-tab').forEach(function (t) {
          t.classList.remove('active');
        });

        // Afficher le formulaire sélectionné
        if (tab === 'login') {
          document.getElementById('login-form').style.display = 'block';
        } else if (tab === 'register') {
          document.getElementById('register-form').style.display = 'block';
        }

        // Activer l'onglet cliqué
        event.target.classList.add('active');
      }

      // Badge de type identifiant
      const loginInput = document.querySelector('input[name="identifiant"]');
      const loginBadge = document.getElementById('login-id-badge');

      if (loginInput) {
        loginInput.addEventListener('input', function () {
          const val = this.value.trim();
          const isETU = /^ETU/i.test(val) || (/^\d/.test(val) && val.length <= 10);
          loginBadge.textContent = isETU ? 'ETU' : 'EMAIL';
          loginBadge.style.background = isETU ? 'rgba(91,35,255,0.12)' : 'var(--gray-200)';
          loginBadge.style.color = isETU ? 'var(--itu-blue)' : 'var(--gray-500)';
        });
      }
    </script>

    <%
        String loginError = (String) session.getAttribute("errorLogin");
        if (loginError != null) {
            session.removeAttribute("errorLogin");
    %>
    <script>
        Swal.fire({
            title: "Oups !",
            text: "<%= loginError.replace("\"", "\\\"") %>",
            icon: "error",
            confirmButtonText: "OK"
        });
    </script>
    <%
        }
    %>

    <script src="${pageContext.request.contextPath}/assets/js/timer-flottant.js"></script>
  </body>
</html>

