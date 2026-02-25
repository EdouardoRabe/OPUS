<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Publication" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    request.setCharacterEncoding("UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }
        int refUser = u.getUser().getRefuser();

        String idpublication = request.getParameter("idpublication");
        if (idpublication == null || idpublication.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"ID publication manquant\"}");
            return;
        }

        // Verifier que la publication appartient au user connecte
        Publication critere = new Publication();
        critere.setIdpublication(idpublication.trim());
        Publication[] found = (Publication[]) CGenUtil.rechercher(critere, null, null, "");
        if (found == null || found.length == 0) {
            out.print("{\"success\":false,\"error\":\"Publication introuvable\"}");
            return;
        }
        Publication existante = found[0];

        if (existante.getIdutilisateur() != refUser) {
            out.print("{\"success\":false,\"error\":\"Vous ne pouvez supprimer que vos propres publications\"}");
            return;
        }

        // Supprimer = mettre etat a 0
        conn = new UtilDB().GetConn();
        String reqSup = "UPDATE publication SET etat = 0 WHERE idpublication = '" + idpublication.trim() + "'";
        new Publication().updateToTableDirecte(reqSup, conn);

        out.print("{\"success\":true,\"id\":\"" + idpublication.trim() + "\"}");

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
