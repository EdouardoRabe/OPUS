<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Profil" %>
<%@ page import="alumni.Visibilite" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%
    UserEJB uEJB = (UserEJB) session.getAttribute("u");
    String lien = (String) session.getValue("lien");
    String idprofil = "";
    String erreur = request.getParameter("erreur");
    String message = request.getParameter("msg");
    if (erreur == null) erreur = "";
    if (message == null) message = "";

    int visNom = 1;
    int visPrenom = 1;
    int visDtn = 1;
    int visExperience = 1;
    int visSpecialite = 1;
    int visPromotion = 1;
    int visEmail = 1;
    int visParcours = 1;
    int visTelephone = 1;
    int visGenre = 1;
    int visSocialMedia = 1;
    int visLocalisation = 1;
    
    if (uEJB != null && uEJB.getUser() != null) {
        int refuser = uEJB.getUser().getRefuser();
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            Profil profil = Profil.findByRefUser(refuser, conn);
            if (profil != null) {
                idprofil = profil.getIdprofil();
                Visibilite[] rows = (Visibilite[]) CGenUtil.rechercher(
                    new Visibilite(), null, null, conn,
                    " and idprofil='" + idprofil + "'"
                );
                if (rows != null) {
                    for (int i = 0; i < rows.length; i++) {
                        Visibilite v = rows[i];
                        String ch = v.getChampvisibilite();
                        if (ch == null) continue;
                        int st = v.getStatus();
                        if ("nom".equals(ch)) visNom = st;
                        else if ("prenom".equals(ch)) visPrenom = st;
                        else if ("dtn".equals(ch)) visDtn = st;
                        else if ("experience".equals(ch)) visExperience = st;
                        else if ("specialite".equals(ch)) visSpecialite = st;
                        else if ("promotion".equals(ch)) visPromotion = st;
                        else if ("email".equals(ch)) visEmail = st;
                        else if ("parcours".equals(ch)) visParcours = st;
                        else if ("telephone".equals(ch)) visTelephone = st;
                        else if ("genre".equals(ch)) visGenre = st;
                        else if ("socialmedia".equals(ch)) visSocialMedia = st;
                        else if ("localisation".equals(ch)) visLocalisation = st;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            erreur = e.getClass().getName() + ": " + e.getMessage();
            System.err.println("confidentialite.jsp ERROR: " + erreur);
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ex) {}
        }
    }
%>

<% if (!erreur.isEmpty()) { %>
<script>
alert("ERREUR: <%= erreur.replace("\"", "'").replace("\n", " ").replace("\r", "") %>");
</script>
<% } %>

<style>
.cf-wrap {
  max-width: 620px; margin: 24px auto 40px;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  color: #191919;
}
.cf-card {
  background: #fff; border-radius: 12px;
  border: 1px solid #dce0e4;
  box-shadow: 0 1px 4px rgba(0,0,0,.08);
  overflow: hidden;
}
.cf-header {
  background: linear-gradient(135deg, #003366 0%, #0a66c2 60%, #378fe9 100%);
  padding: 24px 28px 20px;
  color: #fff;
  display: flex; align-items: center; gap: 14px;
}
.cf-header i { font-size: 28px; opacity: .9; }
.cf-header-text h2 { margin: 0; font-size: 19px; font-weight: 700; }
.cf-header-text p { margin: 4px 0 0; font-size: 13px; opacity: .85; }

.cf-alerts { padding: 0 24px; }
.cf-alert {
  margin-top: 16px; padding: 10px 16px;
  border-radius: 8px; font-size: 13px; font-weight: 500;
}
.cf-alert.err  { background: #ffebee; color: #c62828; border: 1px solid #ffcdd2; }
.cf-alert.ok   { background: #e8f5e9; color: #2e7d32; border: 1px solid #c8e6c9; }

.cf-body { padding: 20px 28px 8px; }
.cf-hint {
  font-size: 13px; color: #666;
  margin-bottom: 20px; line-height: 1.5;
  padding: 12px 16px; background: #f8f9fa;
  border-radius: 8px; border-left: 3px solid #0a66c2;
}

.cf-item {
  display: flex; align-items: center; justify-content: space-between;
  padding: 14px 0; border-bottom: 1px solid #f0f0f0;
}
.cf-item:last-child { border-bottom: none; }
.cf-item-left { display: flex; align-items: center; gap: 12px; }
.cf-item-icon {
  width: 36px; height: 36px; border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
  font-size: 16px; flex-shrink: 0;
}
.cf-item-icon.blue   { background: #e3f2fd; color: #0a66c2; }
.cf-item-icon.green  { background: #e8f5e9; color: #2e7d32; }
.cf-item-icon.orange { background: #fff3e0; color: #e65100; }
.cf-item-icon.purple { background: #f3e5f5; color: #7b1fa2; }
.cf-item-icon.red    { background: #fce4ec; color: #c62828; }
.cf-item-icon.teal   { background: #e0f2f1; color: #00695c; }
.cf-item-label { font-size: 14px; font-weight: 600; }
.cf-item-desc  { font-size: 11px; color: #888; margin-top: 1px; }

/* Toggle switch */
.cf-toggle { position: relative; display: inline-block; width: 48px; height: 26px; flex-shrink: 0; }
.cf-toggle input { opacity: 0; width: 0; height: 0; }
.cf-toggle .slider {
  position: absolute; cursor: pointer; inset: 0;
  background: #ccc; border-radius: 26px; transition: .25s;
}
.cf-toggle .slider:before {
  content: ""; position: absolute;
  height: 20px; width: 20px; left: 3px; bottom: 3px;
  background: #fff; border-radius: 50%; transition: .25s;
  box-shadow: 0 1px 3px rgba(0,0,0,.2);
}
.cf-toggle input:checked + .slider { background: #0a66c2; }
.cf-toggle input:checked + .slider:before { transform: translateX(22px); }

.cf-footer {
  padding: 16px 28px 24px;
  display: flex; justify-content: space-between; align-items: center;
  border-top: 1px solid #eee;
}
.cf-btn {
  padding: 9px 24px; border-radius: 22px; font-size: 13px;
  font-weight: 600; cursor: pointer; border: none; transition: all .15s;
  text-decoration: none; display: inline-flex; align-items: center; gap: 6px;
}
.cf-btn-back { background: #f0f0f0; color: #555; }
.cf-btn-back:hover { background: #e0e0e0; color: #333; }
.cf-btn-save { background: #0a66c2; color: #fff; }
.cf-btn-save:hover { background: #004182; }
</style>

<div class="cf-wrap">
  <div class="cf-card">
    <div class="cf-header">
      <i class="bi bi-shield-lock-fill"></i>
      <div class="cf-header-text">
        <h2>Confidentialit&eacute; du profil</h2>
        <p>G&eacute;rez la visibilit&eacute; de vos informations personnelles</p>
      </div>
    </div>

    <div class="cf-alerts">
      <% if (!erreur.isEmpty()) { %><div class="cf-alert err"><i class="bi bi-exclamation-triangle-fill"></i> <%= erreur %></div><% } %>
      <% if (!message.isEmpty()) { %><div class="cf-alert ok"><i class="bi bi-check-circle-fill"></i> <%= message %></div><% } %>
    </div>

    <form action="<%= request.getContextPath() %>/pages/profil/ajax/traitement-confidentialite.jsp" method="post">
      <input type="hidden" name="idprofil" value="<%= idprofil %>">

      <div class="cf-body">
        <div class="cf-hint">
          <i class="bi bi-info-circle-fill"></i>
          Activez ou d&eacute;sactivez la visibilit&eacute; de chaque champ. Les champs d&eacute;sactiv&eacute;s seront masqu&eacute;s dans l'annuaire et votre fiche publique.
        </div>

        <!-- Nom -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon blue"><i class="bi bi-person-fill"></i></div>
            <div><div class="cf-item-label">Nom</div><div class="cf-item-desc">Votre nom de famille</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_nom" value="1" <%= visNom == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>

        <!-- Prenom -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon blue"><i class="bi bi-person-badge-fill"></i></div>
            <div><div class="cf-item-label">Pr&eacute;nom</div><div class="cf-item-desc">Votre pr&eacute;nom</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_prenom" value="1" <%= visPrenom == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>

        <!-- Date de naissance -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon orange"><i class="bi bi-calendar-heart-fill"></i></div>
            <div><div class="cf-item-label">Date de naissance</div><div class="cf-item-desc">Votre date de naissance</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_dtn" value="1" <%= visDtn == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>

        <!-- Email -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon purple"><i class="bi bi-envelope-fill"></i></div>
            <div><div class="cf-item-label">Email</div><div class="cf-item-desc">Votre adresse email</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_email" value="1" <%= visEmail == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>

        <!-- Telephone -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon teal"><i class="bi bi-telephone-fill"></i></div>
            <div><div class="cf-item-label">T&eacute;l&eacute;phone</div><div class="cf-item-desc">Votre num&eacute;ro de t&eacute;l&eacute;phone</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_telephone" value="1" <%= visTelephone == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>

        <!-- Genre -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon purple"><i class="bi bi-gender-ambiguous"></i></div>
            <div><div class="cf-item-label">Genre</div><div class="cf-item-desc">Votre genre (homme / femme)</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_genre" value="1" <%= visGenre == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>

        <!-- Promotion -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon green"><i class="bi bi-mortarboard-fill"></i></div>
            <div><div class="cf-item-label">Promotion</div><div class="cf-item-desc">Votre promotion et ann&eacute;e</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_promotion" value="1" <%= visPromotion == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>

        <!-- Parcours -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon green"><i class="bi bi-book-fill"></i></div>
            <div><div class="cf-item-label">Parcours</div><div class="cf-item-desc">Votre parcours acad&eacute;mique</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_parcours" value="1" <%= visParcours == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>

        <!-- Specialites -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon red"><i class="bi bi-star-fill"></i></div>
            <div><div class="cf-item-label">Sp&eacute;cialit&eacute;s</div><div class="cf-item-desc">Vos comp&eacute;tences et sp&eacute;cialit&eacute;s</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_specialite" value="1" <%= visSpecialite == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>

        <!-- Experiences -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon orange"><i class="bi bi-briefcase-fill"></i></div>
            <div><div class="cf-item-label">Exp&eacute;riences</div><div class="cf-item-desc">Vos exp&eacute;riences professionnelles</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_experience" value="1" <%= visExperience == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>

        <!-- Reseaux Sociaux -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon blue"><i class="bi bi-globe2"></i></div>
            <div><div class="cf-item-label">R&eacute;seaux sociaux</div><div class="cf-item-desc">Vos comptes sur les r&eacute;seaux sociaux</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_socialmedia" value="1" <%= visSocialMedia == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>

        <!-- Localisation Map -->
        <div class="cf-item">
          <div class="cf-item-left">
            <div class="cf-item-icon red"><i class="bi bi-geo-alt-fill"></i></div>
            <div><div class="cf-item-label">Localisation (Carte)</div><div class="cf-item-desc">Afficher votre position sur la carte interactive</div></div>
          </div>
          <label class="cf-toggle"><input type="checkbox" name="status_localisation" value="1" <%= visLocalisation == 1 ? "checked" : "" %>><span class="slider"></span></label>
        </div>
      </div>

      <div class="cf-footer">
        <a href="<%= lien %>?but=profil/voir.jsp" class="cf-btn cf-btn-back"><i class="bi bi-arrow-left"></i> Retour</a>
        <button type="submit" class="cf-btn cf-btn-save"><i class="bi bi-check-lg"></i> Enregistrer</button>
      </div>
    </form>
  </div>
</div>
