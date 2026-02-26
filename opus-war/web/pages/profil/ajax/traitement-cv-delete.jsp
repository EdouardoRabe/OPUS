<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Profil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.io.File" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecté\"}");
            return;
        }
        int refuser = u.getUser().getRefuser();
        String userId = String.valueOf(refuser);

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        Profil profil = Profil.findByRefUser(refuser, conn);
        if (profil == null) {
            out.print("{\"success\":false,\"error\":\"Profil introuvable\"}");
            return;
        }

        // Supprimer le fichier physique si existant
        String oldCv = profil.getCv();
        if (oldCv != null && !oldCv.isEmpty()) {
            String cvPath = System.getProperty("jboss.server.base.dir")
                    + "/deployments/opus.war/" + oldCv;
            File f = new File(cvPath);
            if (f.exists()) f.delete();
        }

        // Mettre à jour le profil (cv = null)
        profil.setCv(null);
        profil.updateToTableWithHisto(userId, conn);
        conn.commit();

        out.print("{\"success\":true}");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"","'").replace("\n"," ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
