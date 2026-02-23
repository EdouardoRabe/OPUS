<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.ParticipationEvenement" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }
        int refuser = u.getUser().getRefuser();
        String userId = String.valueOf(refuser);

        String idevenement = request.getParameter("idevenement");
        if (idevenement == null || idevenement.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Evenement non specifie\"}");
            return;
        }

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        /* Find the participation record for this user + event */
        ParticipationEvenement critere = new ParticipationEvenement();
        critere.setIdevenement(idevenement.trim());
        critere.setIdutilisateur(refuser);

        ParticipationEvenement[] results = (ParticipationEvenement[]) CGenUtil.rechercher(
            critere, null, null, conn, " and idevenement = '" + idevenement.trim() + "' AND idutilisateur = " + refuser
        );

        if (results == null || results.length == 0) {
            out.print("{\"success\":false,\"error\":\"Participation introuvable\"}");
            conn.rollback();
            return;
        }

        /* Delete the participation */
        ParticipationEvenement toDelete = results[0];
        toDelete.setMode("suppr");
        toDelete.deleteToTable(conn);
        conn.commit();

        out.print("{\"success\":true}");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
