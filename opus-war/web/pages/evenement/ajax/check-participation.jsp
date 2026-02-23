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

        String idevenement = request.getParameter("idevenement");
        if (idevenement == null || idevenement.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Evenement non specifie\"}");
            return;
        }

        conn = new UtilDB().GetConn();

        ParticipationEvenement critere = new ParticipationEvenement();
        ParticipationEvenement[] results = (ParticipationEvenement[]) CGenUtil.rechercher(
            critere, null, null, conn,
            " and idevenement = '" + idevenement.trim() + "' AND idutilisateur = " + refuser
        );

        boolean participe = (results != null && results.length > 0);

        /* Also count total participants for this event */
        ParticipationEvenement critere2 = new ParticipationEvenement();
        ParticipationEvenement[] all = (ParticipationEvenement[]) CGenUtil.rechercher(
            critere2, null, null, conn,
            " and idevenement = '" + idevenement.trim() + "'"
        );
        int totalParticipants = (all != null) ? all.length : 0;

        out.print("{\"success\":true,\"participe\":" + participe + ",\"total\":" + totalParticipants + "}");

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
