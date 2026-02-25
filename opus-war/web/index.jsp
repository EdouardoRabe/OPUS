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
    <!-- OPUS Global Theme -->
    <link href="${pageContext.request.contextPath}/assets/css/opus-theme.css" rel="stylesheet" type="text/css" />

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
          <p style="color: var(--gray-500); font-size: 0.95rem; margin-bottom: 1.5rem;">Accédez à votre espace privilégié OPUS</p>

          <div class="section-divider-label">Connexion</div>

          <!-- LOGIN FORM -->
          <div id="login-form">
            <form action="<%=but%>" method="post">
              <div class="form-group">
                <label class="field-label">Identifiant</label>
                <div class="input-icon-wrap">
                  <span class="glyphicon glyphicon-user input-icon"></span>
                  <input type="text" id="identifiant" name="identifiant" class="form-control-custom with-icon" placeholder="Numéro ETU" value="ETU000001" required />
                </div>
                <div class="info-badge">
                  <i class="fa fa-info-circle"></i> Ex&nbsp;: <strong>ETU003356</strong>
                </div>
              </div>
              <div class="form-group" style="margin-bottom: 2rem;">
                <label class="field-label">Mot de passe</label>
                <div class="input-icon-wrap">
                  <span class="glyphicon glyphicon-lock input-icon"></span>
                  <input type="password" id="passe" name="passe" class="form-control-custom with-icon" placeholder="••••••••" value="test" required />
                  <span class="toggle-password" onclick="togglePasswordVisibility()" title="Afficher/masquer le mot de passe" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);cursor:pointer;color:#999;font-size:16px;z-index:2;">
                    <i class="fa fa-eye" id="eye-icon"></i>
                  </span>
                </div>
              </div>
              <button type="submit" class="btn-login" id="login-btn">
                Se connecter <i class="fa fa-arrow-right"></i>
              </button>
            </form>
            <p style="text-align:center; margin-top:1.25rem; font-size:0.88rem; color:var(--gray-500);">
              Pas encore de compte ?
              <a href="${pageContext.request.contextPath}/pages/inscription.jsp" style="color:var(--itu-blue); font-weight:600; text-decoration:none;">
                Créer un compte
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- jQuery 2.1.4 -->
    <script src="${pageContext.request.contextPath}/plugins/jQuery/jQuery-2.1.4.min.js" type="text/javascript"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="${pageContext.request.contextPath}/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>

    <script>
      // Toggle visibilité du mot de passe
      function togglePasswordVisibility() {
        var passInput = document.getElementById('passe');
        var eyeIcon = document.getElementById('eye-icon');
        if (passInput.type === 'password') {
          passInput.type = 'text';
          eyeIcon.className = 'fa fa-eye-slash';
        } else {
          passInput.type = 'password';
          eyeIcon.className = 'fa fa-eye';
        }
      }

      // Mémoriser le numéro ETU dans localStorage
      (function () {
        // Charger le dernier numéro ETU au chargement de la page
        var lastEtu = localStorage.getItem('lastEtuLogin');
        if (lastEtu) {
          document.getElementById('identifiant').value = lastEtu;
        }

        // Sauvegarder le numéro ETU lors de la soumission du formulaire
        var btn = document.getElementById('login-btn');
        var form = btn ? btn.closest('form') : null;
        if (form) {
          form.addEventListener('submit', function () {
            var etuValue = document.getElementById('identifiant').value.trim();
            if (etuValue) {
              localStorage.setItem('lastEtuLogin', etuValue);
            }
            btn.disabled = true;
            btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Connexion…';
          });
        }
      })();
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

