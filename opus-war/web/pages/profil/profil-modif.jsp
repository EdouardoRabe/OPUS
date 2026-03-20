<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page import="alumni.Profil" %>
<%
        String lien     = (String) session.getValue("lien");
        String apres    = "profil/voir.jsp";
        String classe   = "alumni.Profil";
        String nomtable = "profil";
        String titre    = "Modifier mon profil";
        String id       = "";
        String htmlForm = "";
        String idpromotion   = "";
        String idparcours    = "";
        String idutilisateur = "";
        String idgenre       = "";
        String _prenom       = "";
        String _nom          = "";
        String _promotionLib = "";
        String _parcoursLib  = "";
        String _fullName     = "Profil OPUS";
        String _avatarInitials = "U";

        try {
                Profil t = new Profil();
                PageUpdate pu = new PageUpdate(t, request, (user.UserEJB) session.getValue("u"));
                pu.setLien(lien);
                pu.setTitre(titre);

                pu.getFormu().getChamp("idprofil").setLibelle("ID");
                pu.getFormu().getChamp("idprofil").setAutre("readonly");
                pu.getFormu().getChamp("email").setLibelle("Email");
                pu.getFormu().getChamp("nom").setLibelle("Nom");
                pu.getFormu().getChamp("prenom").setLibelle("Pr&eacute;nom");
                pu.getFormu().getChamp("dtn").setLibelle("Date de naissance");
                pu.getFormu().getChamp("telephone").setLibelle("T&eacute;l&eacute;phone");
                pu.getFormu().getChamp("idpromotion").setVisible(false);
                pu.getFormu().getChamp("idparcours").setVisible(false);
                pu.getFormu().getChamp("idutilisateur").setVisible(false);
                pu.getFormu().getChamp("idgenre").setVisible(false);

                pu.preparerDataFormu();
                id           = pu.getBase().getTuppleID();
                Profil base  = (Profil) pu.getBase();
                if (base != null) {
                    idpromotion   = base.getIdpromotion()   != null ? base.getIdpromotion()   : "";
                    idparcours    = base.getIdparcours()    != null ? base.getIdparcours()    : "";
                    idutilisateur = String.valueOf(base.getIdutilisateur());
                    idgenre       = base.getIdgenre()       != null ? base.getIdgenre()       : "";
                    _prenom       = base.getPrenom()        != null ? base.getPrenom()        : "";
                    _nom          = base.getNom()           != null ? base.getNom()           : "";
                }
                htmlForm = pu.getFormu().getHtmlInsert();
        } catch (Exception e) {
                e.printStackTrace();
        }

        _fullName = (_prenom + " " + _nom).trim();
        if (_fullName.isEmpty()) _fullName = "Profil OPUS";
        StringBuilder initials = new StringBuilder();
        if (!_prenom.isEmpty()) initials.append(Character.toUpperCase(_prenom.charAt(0)));
        if (!_nom.isEmpty()) initials.append(Character.toUpperCase(_nom.charAt(0)));
        if (initials.length() > 0) _avatarInitials = initials.toString();
%>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" crossorigin="anonymous" referrerpolicy="no-referrer">
<!-- Profile edit styles extracted to external CSS -->
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/pages/profil-edit.css" />
<div class="pv-profile-layout">
    <main class="pvl-main">
        <div class="pv-card">
            <div class="pv-top">
                <div class="profil-edit-heading">
                    <a class="profil-edit-back" href="<%= lien %>?but=<%= apres %>" aria-label="Retour au profil public">
                        <i class="fa fa-arrow-left"></i>
                    </a>
                    <div>
                        <p class="profil-edit-kicker">Profil OPUS</p>
                        <h1 class="profil-edit-title"><%= titre %></h1>
                    </div>
                </div>
            </div>
            <div class="pv-section">
                <div class="pv-section-header">
                    <h2><i class="fa fa-user-pen"></i> Détails du profil</h2>
                    <a class="pv-extra-link" href="<%= lien %>?but=<%= apres %>">
                        <i class="fa fa-eye"></i> Voir le profil
                    </a>
                </div>
                <form class="profil-edit-form" action="<%= lien %>?but=apresTarif.jsp" method="post">
                    <div class="profil-edit-body">
                        <div class="profil-edit-fields">
                            <%= htmlForm %>
                        </div>
                        <div class="profil-edit-hidden" aria-hidden="true">
                            <input type="hidden" name="acte"          value="update">
                            <input type="hidden" name="classe"        value="<%= classe %>">
                            <input type="hidden" name="nomtable"      value="<%= nomtable %>">
                            <input type="hidden" name="bute"          value="<%= apres %>">
                            <input type="hidden" name="idprofil"      value="<%= id %>">
                            <input type="hidden" name="idpromotion"   value="<%= idpromotion %>">
                            <input type="hidden" name="idparcours"    value="<%= idparcours %>">
                            <input type="hidden" name="idutilisateur" value="<%= idutilisateur %>">
                            <input type="hidden" name="idgenre"       value="<%= idgenre %>">
                        </div>
                    </div>
                    <div class="profil-edit-actions">
                        <a class="pv-extra-link" href="<%= lien %>?but=<%= apres %>">
                            <i class="fa fa-arrow-left"></i> Retour
                        </a>
                        <button class="profil-edit-submit" type="submit">Enregistrer</button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>
