<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.ParticipationEvenement" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Date" %>
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

        ParticipationEvenement p = new ParticipationEvenement();
        p.construirePK(conn);
        p.setIdevenement(idevenement.trim());
        p.setIdutilisateur(refuser);
        p.setDateparticipation(new Date(System.currentTimeMillis()));
        p.insertToTableWithHisto(userId, conn);
        conn.commit();

        out.print("{\"success\":true,\"id\":\"" + p.getIdparticipation() + "\"}");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
