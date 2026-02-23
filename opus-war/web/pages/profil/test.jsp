<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="java.sql.Connection" %>
<%
    UserEJB u = (UserEJB) session.getAttribute("u");

    if (u == null || u.getUser() == null) {
%>
<p>Session vide — user null</p>
<%
    } else {
        MapUtilisateur mu = u.getUser();
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            ProfilLib filtre = new ProfilLib();
            ProfilLib[] res = (ProfilLib[]) CGenUtil.rechercher(
                filtre,
                null,
                null,
                conn, " and refuser = " + mu.getRefuser()
            );

            ProfilLib p = (res != null && res.length > 0) ? res[0] : null;
%>
<pre>
-- Session --
getTuppleID() = <%= mu.getTuppleID() %>
getRefuser()  = <%= mu.getRefuser() %>
getIdrole()   = <%= mu.getIdrole() %>

-- ProfilLib --
<% if (p != null) { %>
idprofil         = <%= p.getIdprofil() %>
nom              = <%= p.getNom() %>
prenom           = <%= p.getPrenom() %>
email            = <%= p.getEmail() %>
telephone        = <%= p.getTelephone() %>
dtn              = <%= p.getDtn() %>
idpromotion      = <%= p.getIdpromotion() %>
promotion_lib    = <%= p.getPromotionLib() %>
promotion_annee  = <%= p.getPromotionAnnee() %>
idparcours       = <%= p.getIdparcours() %>
parcours_lib     = <%= p.getParcoursLib() %>
photo_profil     = <%= p.getPhotoProfil() %>
photo_couverture = <%= p.getPhotoCouverture() %>
idrole           = <%= p.getIdrole() %>
refuser          = <%= p.getRefuser() %>
estactif         = <%= p.getEstactif() %>
<% } else { %>
Aucun profil trouvé pour refuser=<%= mu.getRefuser() %>
<% } %>
</pre>
<%
        } catch (Exception e) {
%>
<p>Erreur: <%= e.getMessage() %></p>
<%
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
    }
%>