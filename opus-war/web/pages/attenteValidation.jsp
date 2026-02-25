<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
  <!DOCTYPE html>
  <html lang="fr">

  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>OPUS — En attente de validation</title>

    <link href="${pageContext.request.contextPath}/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="${pageContext.request.contextPath}/dist/js/font-awesome-4.4.0/css/font-awesome.min.css"
      rel="stylesheet" type="text/css" />
    <link href="${pageContext.request.contextPath}/assets/css/alumni-theme.css" rel="stylesheet" type="text/css" />
    <link href="${pageContext.request.contextPath}/assets/css/opus-theme.css" rel="stylesheet" type="text/css" />
  </head>

  <body>
    <div class="login-split">
      <div class="login-left">
        <div class="login-brand">
          <img class="login-brand-logo" src="${pageContext.request.contextPath}/dist/img/ITU_logo.png" alt="ITU logo" />
          <span class="login-brand-text"><span class="brand-itu">ITU</span><span
              class="brand-alumni">alumni</span></span>
        </div>
        <div class="login-hero-wrap" style="zoom: 1.25;">
          <h1 class="login-hero-title">Presque<br /><span>parmi nous !</span></h1>
          <p class="login-hero-text">Votre compte a été créé avec succès. Il doit maintenant être validé par un
            administrateur pour garantir la qualité de notre réseau.</p>
        </div>
      </div>

      <div class="login-right">
        <div
          style="position: absolute; bottom: 2rem; right: 2rem; font-family: var(--font-serif); font-size: 8rem; font-weight: 900; color: rgba(0,0,0,0.03); line-height: 1; pointer-events: none; z-index: 0;">
          OPUS</div>
        <div class="login-card" style="position: relative; z-index: 1; zoom: 1.25;">

          <div class="steps-track">
            <div class="step-item completed">
              <div class="step-circle"><span class="glyphicon glyphicon-ok"></span></div>
              <span class="step-name">Identifiants</span>
            </div>
            <div class="step-line completed"></div>
            <div class="step-item completed">
              <div class="step-circle"><span class="glyphicon glyphicon-ok"></span></div>
              <span class="step-name">Profil</span>
            </div>
            <div class="step-line completed"></div>
            <div class="step-item active">
              <div class="step-circle"><span class="glyphicon glyphicon-hourglass"></span></div>
              <span class="step-name">Validation</span>
            </div>
          </div>

          <div style="text-align: center; padding: 1rem 0;">
            <div
              style="width: 80px; height: 80px; background: rgba(40, 58, 151, 0.1); color: var(--itu-blue); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 2.5rem; margin: 0 auto 1.5rem;">
              <span class="glyphicon glyphicon-time" style="animation: pulse 2s infinite;"></span>
            </div>
            <h2
              style="font-family: var(--font-serif); font-size: 1.8rem; color: var(--itu-dark); margin-bottom: 1rem; font-weight: 700;">
              Demande envoyée</h2>
            <p style="color: var(--gray-600); font-size: 1rem; line-height: 1.6; margin-bottom: 2rem;">
              Votre profil est en cours de vérification par nos modérateurs. <br>
              La validation peut durer quelques jours.
              Merci de votre patience et à très bientôt sur ITU Alumni !
            </p>

            <a href="${pageContext.request.contextPath}/index.jsp" class="btn-login"
              style="text-decoration: none; display: inline-block;">
              Retour à l'accueil <i class="fa fa-home" style="margin-left: 8px;"></i>
            </a>
          </div>

        </div>
      </div>
    </div>

    <style>
      @keyframes pulse {
        0% {
          transform: scale(1);
          opacity: 1;
        }

        50% {
          transform: scale(1.1);
          opacity: 0.7;
        }

        100% {
          transform: scale(1);
          opacity: 1;
        }
      }
    </style>
  </body>

  </html>