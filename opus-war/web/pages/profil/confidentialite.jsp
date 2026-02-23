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

<div class="content-wrapper">
    <div class="row">
        <div class="col-md-3"></div>
        <div class="col-md-6">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">
                        <a href="<%= lien %>?but=profil/voir.jsp">
                            <i class="fa fa-arrow-circle-left"></i>
                        </a>
                        Confidentialite du profil
                    </h3>
                </div>
                
                <% if (!erreur.isEmpty()) { %>
                <div class="alert alert-danger"><%= erreur %></div>
                <% } %>
                
                <% if (!message.isEmpty()) { %>
                <div class="alert alert-success"><%= message %></div>
                <% } %>
                
                <form action="<%= request.getContextPath() %>/pages/profil/ajax/traitement-confidentialite.jsp" method="post">
                    <input type="hidden" name="idprofil" value="<%= idprofil %>">
                    
                    <div class="box-body">
                        <p>Choisissez les informations visibles par les autres membres (1=Public, 0=Prive)</p>
                        
                        <div class="form-group">
                            <label>Nom</label>
                            <select name="status_nom" class="form-control">
                                <option value="1" <%= visNom == 1 ? "selected" : "" %>>Public</option>
                                <option value="0" <%= visNom == 0 ? "selected" : "" %>>Prive</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Prenom</label>
                            <select name="status_prenom" class="form-control">
                                <option value="1" <%= visPrenom == 1 ? "selected" : "" %>>Public</option>
                                <option value="0" <%= visPrenom == 0 ? "selected" : "" %>>Prive</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Date de naissance</label>
                            <select name="status_dtn" class="form-control">
                                <option value="1" <%= visDtn == 1 ? "selected" : "" %>>Public</option>
                                <option value="0" <%= visDtn == 0 ? "selected" : "" %>>Prive</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Experiences</label>
                            <select name="status_experience" class="form-control">
                                <option value="1" <%= visExperience == 1 ? "selected" : "" %>>Public</option>
                                <option value="0" <%= visExperience == 0 ? "selected" : "" %>>Prive</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Specialites</label>
                            <select name="status_specialite" class="form-control">
                                <option value="1" <%= visSpecialite == 1 ? "selected" : "" %>>Public</option>
                                <option value="0" <%= visSpecialite == 0 ? "selected" : "" %>>Prive</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Promotion</label>
                            <select name="status_promotion" class="form-control">
                                <option value="1" <%= visPromotion == 1 ? "selected" : "" %>>Public</option>
                                <option value="0" <%= visPromotion == 0 ? "selected" : "" %>>Prive</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Email</label>
                            <select name="status_email" class="form-control">
                                <option value="1" <%= visEmail == 1 ? "selected" : "" %>>Public</option>
                                <option value="0" <%= visEmail == 0 ? "selected" : "" %>>Prive</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Parcours</label>
                            <select name="status_parcours" class="form-control">
                                <option value="1" <%= visParcours == 1 ? "selected" : "" %>>Public</option>
                                <option value="0" <%= visParcours == 0 ? "selected" : "" %>>Prive</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="box-footer">
                        <a href="<%= lien %>?but=profil/voir.jsp" class="btn btn-default">Annuler</a>
                        <button type="submit" class="btn btn-primary pull-right">Enregistrer</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
