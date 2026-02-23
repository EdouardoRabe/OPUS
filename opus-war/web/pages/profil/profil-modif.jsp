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

        pu.preparerDataFormu();
        id           = pu.getBase().getTuppleID();
        Profil base  = (Profil) pu.getBase();
        idpromotion   = base.getIdpromotion()   != null ? base.getIdpromotion()   : "";
        idparcours    = base.getIdparcours()    != null ? base.getIdparcours()    : "";
        idutilisateur = String.valueOf(base.getIdutilisateur());
        htmlForm = pu.getFormu().getHtmlInsert();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<div class="content-wrapper">
    <div class="row">
        <div class="col-md-3"></div>
        <div class="col-md-6">
            <div class="box-fiche">
                <div class="box">
                    <div class="box-title with-border">
                        <h1 class="box-title">
                            <a href="<%= lien %>?but=<%= apres %>">
                                <i class="fa fa-arrow-circle-left"></i>
                            </a>
                            <%= titre %>
                        </h1>
                    </div>
                    <form action="<%= lien %>?but=apresTarif.jsp" method="post">
                        <%= htmlForm %>

                        <input type="hidden" name="acte"          value="update">
                        <input type="hidden" name="classe"        value="<%= classe %>">
                        <input type="hidden" name="nomtable"      value="<%= nomtable %>">
                        <input type="hidden" name="bute"          value="<%= apres %>">
                        <input type="hidden" name="idprofil"      value="<%= id %>">
                        <input type="hidden" name="idpromotion"   value="<%= idpromotion %>">
                        <input type="hidden" name="idparcours"    value="<%= idparcours %>">
                        <input type="hidden" name="idutilisateur" value="<%= idutilisateur %>">

                        <div class="row">
                            <div class="col-md-11">
                                <button class="btn btn-primary pull-right" type="submit">Enregistrer</button>
                            </div>
                            <br><br>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
