<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Evenement" %>
<%@ page import="bean.CGenUtil" %>
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
        String userId = String.valueOf(u.getUser().getRefuser());

        String idevenement = request.getParameter("idevenement");
        String description = request.getParameter("description");
        String daty        = request.getParameter("daty");
        String datedebut   = request.getParameter("datedebut");
        String datefin     = request.getParameter("datefin");

        if (idevenement == null || idevenement.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"ID manquant\"}");
            return;
        }
        if (description == null || description.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"La description est obligatoire\"}");
            return;
        }
        if (datedebut == null || datedebut.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"La date de d\\u00e9but est obligatoire\"}");
            return;
        }

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        Evenement[] arr = (Evenement[]) CGenUtil.rechercher(
            new Evenement(), null, null, conn,
            " and idevenement='" + idevenement.trim().replace("'","''") + "'"
        );
        if (arr == null || arr.length == 0) {
            out.print("{\"success\":false,\"error\":\"Evenement introuvable\"}");
            return;
        }

        Evenement evt = arr[0];
        evt.setDescription(description.trim());
        evt.setDaty(daty != null && !daty.trim().isEmpty() ? Date.valueOf(daty.trim()) : evt.getDaty());
        evt.setDatedebut(Date.valueOf(datedebut.trim()));
        evt.setDatefin(datefin != null && !datefin.trim().isEmpty() ? Date.valueOf(datefin.trim()) : null);
        evt.setMode("modif");
        evt.updateToTableWithHisto(userId, conn);
        conn.commit();

        out.print("{\"success\":true,\"id\":\"" + idevenement.trim() + "\"}");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
