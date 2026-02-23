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
    <link href="${pageContext.request.contextPath}/dist/css/font-awesome-4.4.0/css/font-awesome.min.css" rel="stylesheet" type="text/css" />

    <!-- OPUS CUSTOM THEME (local, utilisant les fonts du projet) -->
    <link href="${pageContext.request.contextPath}/assets/css/alumni-theme.css" rel="stylesheet" type="text/css" />

    <!-- SweetAlert (du projet) -->
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
      <!-- LEFT PANEL (optional, same as login page) -->
      <div class="login-left">
        <div class="login-brand">
          <img class="login-brand-logo" src="${pageContext.request.contextPath}/dist/img/ITU_logo.png" alt="ITU logo" />
          <span class="login-brand-text"><span class="brand-itu">ITU</span><span class="brand-alumni">alumni</span></span>
        </div>

        <div class="login-hero-wrap">
          <h1 class="login-hero-title">Votre réseau,<br /><span>votre avenir.</span></h1>
          <p class="login-hero-text">Rejoignez la communauté exclusive des anciens de l'ITUniversity. Échangez avec vos pairs, partagez des opportunités qualifiées et propulsez votre carrière vers de nouveaux horizons.<br>
          Toute inscription est soumise à validation par les modérateurs.</p>
        </div>
      </div>

      <!-- RIGHT PANEL -->
      <div class="login-right">
        <div style="position: absolute; bottom: 2rem; right: 2rem; font-family: var(--font-serif); font-size: 8rem; font-weight: 900; color: rgba(0,0,0,0.03); line-height: 1; pointer-events: none; z-index: 0;">OPUS</div>

        <div class="login-card" style="position: relative; z-index: 1;">
          <h2 style="font-family: var(--font-serif); font-size: 2rem; color: var(--itu-dark); margin-bottom: 0.4rem; font-weight: 700;">Créer un compte</h2>
          <p style="color: var(--gray-500); font-size: 0.95rem; margin-bottom: 1.75rem;">Rejoignez la communauté OPUS en quelques clics. <br>
          Toute inscription est soumise à validation par les modérateurs.</p>

          <!-- REGISTER FORM - STEP 1 -->
          <div id="register-form" style="display:block;">
            <form action="detailsInscription.jsp" method="post">
              <div class="form-group">
                <label>Numéro ETU <span style="color:red">*</span></label>
                <div class="input-position-relative">
                  <span style="position:absolute;left:14px;top:50%;transform:translateY(-50%);font-size:0.76rem;font-weight:700;letter-spacing:0.08em;color:var(--itu-blue);pointer-events:none;">ETU</span>
                  <input type="text" name="etu" class="form-control-custom" placeholder="Ex: 003356" style="padding-left:52px;" required />
                </div>
              </div>
              <div class="form-group">
                <label>Mot de passe <span style="color:red">*</span></label>
                <input type="password" name="password" class="form-control-custom" placeholder="Min. 8 caractères" required />
              </div>
              <button type="submit" class="btn btn-primary btn-block" style="padding: 0.85rem; font-size: 1rem; font-weight: 700;">
                Continuer <i class="fa fa-arrow-right" style="margin-left: 8px;"></i>
              </button>
              <p style="font-size: 0.78rem; color: var(--gray-500); margin-top: 1rem; text-align: center;">
                <em>Vous serez redirigé pour compléter votre profil</em>
              </p>
            </form>
            <p class="text-center" style="margin-top:1rem;">
              <a href="${pageContext.request.contextPath}/index.jsp">Retour à la connexion</a>
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- jQuery 2.1.4 -->
    <script src="${pageContext.request.contextPath}/plugins/jQuery/jQuery-2.1.4.min.js" type="text/javascript"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="${pageContext.request.contextPath}/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>

    <script src="${pageContext.request.contextPath}/assets/js/timer-flottant.js"></script>
  </body>
</html>