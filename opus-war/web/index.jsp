<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page import="utilitaireAcade.UtilitaireAcade"%>
<%
    String queryString = request.getQueryString();
    String but = "pages/testLogin.jsp";
    if(queryString != null && !queryString.equals("")){
        but += "?" + queryString;
    }
%>
<!DOCTYPE html>
  <html>
    <head>
      <meta charset="UTF-8">
      <title>OPUS - Identification</title>

<%--      <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/img/logo.png">--%>

        <!-- Tell the browser to be responsive to screen width -->
      <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
      <!-- Bootstrap 3.3.4 -->
<%--      <link href="${pageContext.request.contextPath}/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />--%>
      <!-- Font Awesome Icons -->
<%--      <link href="${pageContext.request.contextPath}/dist/js/font-awesome-4.4.0/css/font-awesome.min.css" rel="stylesheet" type="text/css" />--%>
      <!-- Theme style -->
<%--      <link href="${pageContext.request.contextPath}/dist/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />--%>
        <link href="${pageContext.request.contextPath}/assets/css/refontlogin.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/api-global-style.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/refontSidebar.css" rel="stylesheet">
<%--        <link href="${pageContext.request.contextPath}/dist/css/stylecustom.css" rel="stylesheet">--%>
        <!-- iCheck -->
<%--      <link href="${pageContext.request.contextPath}/plugins/iCheck/square/blue.css" rel="stylesheet" type="text/css" />--%>
<%--      <link href="${pageContext.request.contextPath}/dist/css/swal.css" rel="stylesheet" type="text/css" />--%>

      <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
      <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
      <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
          <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
      <![endif]-->
        <script src="${pageContext.request.contextPath}/dist/js/swal.js"></script>
    <body>
    <div class="page">
        <div class="frame">
            <section class="panel-left">
                <header class="brand">
<%--                    <img class="logo"--%>
<%--                         src="${pageContext.request.contextPath}/assets/img/logo.jpeg"--%>
<%--                         alt="Logo">--%>
                </header>
                <!-- <img class="logo" src="${pageContext.request.contextPath}/assets/img/Logo-Async-Footer.png" alt="Logo Async"> -->
                <main class="card">
                    <h1>Connexion</h1>
                    <p class="subtitle">Accédez à vos outils de gestion</p>

                    <form class="form" action="<%=but%>" method="post">
                        <label class="field">
                            <span class="label">Identifiant</span>
                            <span class="input-wrap">
                                <span class="icon" aria-hidden="true">
                                    <!-- user icon -->
                                    <svg viewBox="0 0 24 24" width="18" height="18"
                                         fill="currentColor">
                                        <path
                                                d="M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5zm0 2c-5.33 0-8 2.67-8 6a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1c0-3.33-2.67-6-8-6z" />
                                    </svg>
                                </span>
                                <input type="text" name="identifiant"
                                       placeholder="Entrer vos identifiant" required />
                            </span>
                        </label>

                        <label class="field">
                            <span class="label">Mot de passe</span>
                            <span class="input-wrap">
                                <span class="icon" aria-hidden="true">
                                    <!-- lock icon -->
                                    <svg viewBox="0 0 24 24" width="18" height="18"
                                         fill="currentColor">
                                        <path
                                                d="M17 10h-1V7a4 4 0 0 0-8 0v3H7a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-7a2 2 0 0 0-2-2zm-6 0V7a3 3 0 0 1 6 0v3z" />
                                    </svg>
                                </span>
                                <input type="password" name="passe"
                                       placeholder="Entrer votre mot de passe" required />
                                <span class="toggle-eye"
                                      title="Afficher le mot de passe" aria-hidden="true" onclick="showMDP()" >
                                    <svg viewBox="0 0 24 24" width="18" height="18"
                                         fill="currentColor">
                                        <path
                                                d="M12 5C7 5 2.73 8.11 1 12c1.73 3.89 6 7 11 7s9.27-3.11 11-7c-1.73-3.89-6-7-11-7zm0 12a5 5 0 1 1 5-5 5 5 0 0 1-5 5zm0-8a3 3 0 1 0 3 3 3 3 0 0 0-3-3z" />
                                    </svg>
                                </span>
                            </span>
                        </label>

                        <button class="btn-primary" id="login-btn" type="submit">
                            <span id="login-btn-text">Se connecter</span>
                        </button>
                    </form>
                </main>

                <footer class="footer">
<%--                    <img class="logo"--%>
<%--                         src="${pageContext.request.contextPath}/assets/img/Logo-Async-Footer.png"--%>
<%--                         alt="Logo Async">--%>
<%--                    <span class="by">by BICI</span>--%>
                </footer>
            </section>

            <!-- Right / Illustration -->
            <aside class="panel-right" aria-hidden="true">
                <div class="image">
                </div>
            </aside>
        </div>

      <!-- jQuery 2.1.4 -->
      <script src="${pageContext.request.contextPath}/plugins/jQuery/jQuery-2.1.4.min.js" type="text/javascript"></script>
      <!-- Bootstrap 3.3.2 JS -->
      <script src="${pageContext.request.contextPath}/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
      <!-- iCheck -->
      <script src="${pageContext.request.contextPath}/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
      <script>
        $(function () {
          $('input').iCheck({
            checkboxClass: 'icheckbox_square-blue',
            radioClass: 'iradio_square-blue',
            increaseArea: '20%' // optional
          });
        });

        function showMDP() {
            var d = document.getElementsByName("passe")[0];
            var icon = document.getElementsByClassName("toggle-eye")[0]; // <-- on cible le premier élément

            if (d.type === "password") {
                d.type = "text";
                icon.innerHTML = `
            <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
                <path d="M12 5C7 5 2.73 8.11 1 12c1.73 3.89 6 7 11 7s9.27-3.11 11-7c-1.73-3.89-6-7-11-7zM12 15a3 3 0 0 0 0-6 3 3 0 0 0 0 6z"></path>
            </svg>`;
                return;
            }
            if (d.type === "text") {
                d.type = "password";
                icon.innerHTML = `
            <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
                <path d="M12 5C7 5 2.73 8.11 1 12c1.73 3.89 6 7 11 7s9.27-3.11 11-7c-1.73-3.89-6-7-11-7zm0 12a5 5 0 1 1 5-5 5 5 0 0 1-5 5zm0-8a3 3 0 1 0 3 3 3 3 0 0 0-3-3z"></path>
            </svg>`;
                return;
            }
        }

      </script>

      <%
          String loginError = (String) session.getAttribute("errorLogin");
          if (loginError != null) {
              session.removeAttribute("errorLogin");
      %>
      <script>
          Swal.fire({
              title: "Ouupss !",
              text: "<%= loginError.replace("\"", "\\\"") %>",
              icon: "error",
              confirmButtonText: "OK"
          });
      </script>
      <%
          }
      %>

        <!-- Div flottant global amélioré -->
<%--        <div id="mon-div-flottant" style="--%>
<%--            position: fixed;--%>
<%--            bottom: 20px;--%>
<%--            right: 20px;--%>
<%--            width: 250px;--%>
<%--            background-color: #fff;--%>
<%--            border: 1px solid #ddd;--%>
<%--            border-radius: 8px;--%>
<%--            box-shadow: 0 4px 15px rgba(0,0,0,0.3);--%>
<%--            z-index: 9999;--%>
<%--            font-family: 'Open Sans', sans-serif;">--%>
<%--            <div id="drag-handle" style="--%>
<%--                padding: 10px;--%>
<%--                background-color: #007bff;--%>
<%--                color: white;--%>
<%--                border-radius: 8px 8px 0 0;--%>
<%--                cursor: move;--%>
<%--                font-weight: bold;--%>
<%--                display: flex;--%>
<%--                justify-content: space-between;--%>
<%--                align-items: center;">--%>
<%--                <!-- ce framework ne supporte pas les emojis et les accents comme â. Par exemple pour é, on utilise &eacute; fait le pour taches-->--%>
<%--                <span> &#128190; Tâches en cours</span>--%>
<%--                <button onclick="$('#timer-content').toggle()" style="background:none; border:none; color:white; cursor:pointer; font-weight: bold;">_</button>--%>
<%--            </div>--%>
<%--            <div id="timer-content" style="padding: 0; max-height: 300px; overflow-y: auto;">--%>
<%--                <ul id="timer-list" style="list-style: none; padding: 0; margin: 0;">--%>
<%--                    <li style="color: #666; font-style: italic; text-align: center; font-size: 12px; padding: 10px;">Chargement...</li>--%>
<%--                </ul>--%>
<%--            </div>--%>
<%--        </div>--%>
        <script src="${pageContext.request.contextPath}/assets/js/timer-flottant.js"></script>
    </body>
  </html>