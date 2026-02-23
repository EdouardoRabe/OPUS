<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.CGenUtil, alumni.Parcours, alumni.Promotion, alumni.Genre" %>

<%
    // retrieve previous step values
    String etu = request.getParameter("etu");
    String password = request.getParameter("password");

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
    <link href="${pageContext.request.contextPath}/dist/css/font-awesome-4.4.0/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
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
          <p style="color: var(--gray-500); font-size: 0.95rem; margin-bottom: 1.75rem;">Complétez les champs ci-dessous.</p>

          <div id="details-form">
            <form id="detailsForm" action="testRegister.jsp" method="post">
              <input type="hidden" name="etu" value="<%= etu %>" />
              <input type="hidden" name="password" value="<%= password %>" />

              <div class="form-group">
                <label>Parcours <span style="color:red">*</span></label>  
                <select name="idparcours" class="form-control-custom" onchange="reloadWithParcours(this.value)" required>
                    <option value="">-- choisissez --</option>
                    <% for(alumni.Parcours pp : parcoursList){ %>
                        <option value="<%=pp.getIdparcours()%>" <%= pp.getIdparcours().equals(selectedParcours) ? "selected" : "" %>><%=pp.getLibelle()%></option>
                    <% } %>
                </select>
              </div>

              <div class="form-group">
                <label>Promotion <span style="color:red">*</span></label>
                <select name="idpromotion" class="form-control-custom" required <%= (promoList == null || promoList.length==0) ? "disabled" : "" %> >
                    <option value="">-- choisissez un parcours d'abord --</option>
                    <% if(promoList != null && promoList.length > 0) { 
                        for(alumni.Promotion promo : promoList){ %>
                        <option value="<%=promo.getIdpromotion()%>"><%=promo.getLibelle()%></option>
                    <% } } %>
                </select>
              </div>

              <div class="form-group">
                <label>Genre <span style="color:red">*</span></label>
                <select name="idgenre" class="form-control-custom" required>
                    <option value="">-- choisissez --</option>
                    <% for(alumni.Genre g : genreList){ %>
                        <option value="<%=g.getIdgenre()%>" <%= (selectedGenre != null && selectedGenre.equals(g.getIdgenre())) ? "selected" : "" %>><%=g.getLibelle()%></option>
                    <% } %>
                </select>
              </div>

              <div class="form-group">
                <label>E-mail <span style="color:red">*</span></label>
                <input type="email" name="email" class="form-control-custom" placeholder="jean.dupont@opus.edu" required />
              </div>
              <div class="row">
                <div class="col-xs-6 form-group">
                  <label>Prénom <span style="color:red">*</span></label>
                  <input type="text" name="prenom" class="form-control-custom" placeholder="Jean" required />
                </div>
                <div class="col-xs-6 form-group">
                  <label>Nom <span style="color:red">*</span></label>
                  <input type="text" name="nom" class="form-control-custom" placeholder="Dupont" required />
                </div>
              </div>
              <div class="form-group">
                <label>Date de naissance <span style="color:red">*</span></label>
                <input type="date" name="dtn" class="form-control-custom" required />
              </div>
              <div class="form-group">
                <label>Téléphone <span style="color:red">*</span></label>
                <input type="tel" name="telephone" class="form-control-custom" placeholder="06 12 34 56 78" required />
              </div>

              <button type="submit" class="btn btn-primary btn-block" style="padding: 0.85rem; font-size: 1rem; font-weight: 700;">
                Valider l'inscription <i class="fa fa-arrow-right" style="margin-left: 8px;"></i>
              </button>
            </form>
            <p class="text-center" style="margin-top:1rem;">
              <a href="${pageContext.request.contextPath}/index.jsp">Annuler </a>
            </p>
          </div>
        </div>
      </div>
    </div>

    <script src="${pageContext.request.contextPath}/plugins/jQuery/jQuery-2.1.4.min.js" type="text/javascript"></script>

    <script src="${pageContext.request.contextPath}/assets/js/timer-flottant.js"></script>

    <script>
      // when parcours changes, submit the form via POST back to detailsInscription.jsp
      function reloadWithParcours(val) {
        var form = document.getElementById('detailsForm');
        // ensure the selected value is set (already done automatically)
        form.idparcours.value = val;
        // submit to self to reload promotions without exposing password
        form.action = 'detailsInscription.jsp';
        form.submit();
        // restore target for the final registration step
        form.action = 'testRegister.jsp';
      }
    </script>


  </body>
</html>