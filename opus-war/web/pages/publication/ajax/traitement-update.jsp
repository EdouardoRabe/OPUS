<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Publication" %>
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
        String userId = String.valueOf(u.getUser().getRefuser());
        int refUser = u.getUser().getRefuser();

        String idpublication     = request.getParameter("idpublication");
        String descritpion       = request.getParameter("descritpion");
        String idtypepublication = request.getParameter("idtypepublication");

        if (idpublication == null || idpublication.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"ID publication manquant\"}");
            return;
        }

        // --- Verifier que la publication appartient au user connecte ---
        Connection connCheck = new UtilDB().GetConn();
        Publication existante = new Publication();
        existante.setIdpublication(idpublication.trim());
        existante.remplirDepuisDB(connCheck);
        connCheck.close();

        if (existante.getIdutilisateur() != refUser) {
            out.print("{\"success\":false,\"error\":\"Vous ne pouvez modifier que vos propres publications\"}");
            return;
        }

        // --- Update en base ---
        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        Publication pub = new Publication();
        pub.setIdpublication(idpublication.trim());
        pub.setDescritpion(descritpion != null ? descritpion.trim() : "");
        pub.setIdtypepublication(idtypepublication != null ? idtypepublication.trim() : existante.getIdtypepublication());
        pub.setDaty(existante.getDaty());
        pub.setHeure(existante.getHeure());
        pub.setEtat(existante.getEtat());
        pub.setIdorigine(existante.getIdorigine());
        pub.setIdutilisateur(existante.getIdutilisateur());
        pub.setIdpuborigine(existante.getIdpuborigine());
        pub.setMode("modif");
        pub.updateToTableWithHisto(userId, conn);
        conn.commit();

        out.print("{\"success\":true,\"id\":\"" + idpublication.trim() + "\"}");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
