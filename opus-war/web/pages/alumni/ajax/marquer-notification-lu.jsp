<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Notification" %>
<%@ page import="java.sql.Connection" %>
<%
    // AJAX POST: Marquer une notification comme lue (etat=1)
    // Param: idnotification (optionnel) ou "all" pour tout marquer comme lu
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        String userId = String.valueOf(u.getUser().getRefuser());
        String idnotif = request.getParameter("idnotification");
        String action = request.getParameter("action");

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        if ("all".equals(action)) {
            // Marquer TOUTES les notifications non lues comme lues
            Notification[] notifs = (Notification[]) CGenUtil.rechercher(
                new Notification(), null, null, conn,
                " and idutilisateur = " + userId + " and etat = 0");
            if (notifs != null) {
                for (int i = 0; i < notifs.length; i++) {
                    notifs[i].setEtat(1);
                    notifs[i].upDateToTable(conn);
                }
            }
            conn.commit();
            out.print("{\"success\":true,\"action\":\"all\"}");

        } else if (idnotif != null && !idnotif.trim().isEmpty()) {
            // Marquer UNE notification comme lue
            Notification[] notifs = (Notification[]) CGenUtil.rechercher(
                new Notification(), null, null, conn,
                " and idnotification = '" + idnotif + "' and idutilisateur = " + userId);
            if (notifs != null && notifs.length > 0) {
                notifs[0].setEtat(1);
                notifs[0].upDateToTable(conn);
                conn.commit();
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
