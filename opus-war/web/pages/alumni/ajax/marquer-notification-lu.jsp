<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%
    // AJAX POST: Marquer une notification comme lue (etat=1)
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        int refuser = u.getUser().getRefuser();
        String idnotif = request.getParameter("idnotification");
        String action = request.getParameter("action");

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        if ("all".equals(action)) {
            // Marquer TOUTES les notifications non lues comme lues (SQL direct)
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE notification SET etat = 1 WHERE idutilisateur = ? AND etat = 0");
            ps.setInt(1, refuser);
            int updated = ps.executeUpdate();
            ps.close();
            conn.commit();
            out.print("{\"success\":true,\"action\":\"all\",\"updated\":" + updated + "}");

        } else if (idnotif != null && !idnotif.trim().isEmpty()) {
            // Marquer UNE notification comme lue (SQL direct)
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE notification SET etat = 1 WHERE idnotification = ? AND idutilisateur = ?");
            ps.setString(1, idnotif.trim());
            ps.setInt(2, refuser);
            int updated = ps.executeUpdate();
            ps.close();
            conn.commit();
            if (updated > 0) {
                out.print("{\"success\":true,\"action\":\"one\",\"id\":\"" + idnotif + "\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"Notification introuvable\"}");
            }
        } else {
            out.print("{\"success\":false,\"error\":\"Parametre manquant\"}");
        }

    } catch (Exception e) {
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception cx) {}
    }
%>
