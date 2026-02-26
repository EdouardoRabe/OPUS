<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Limiterole" %>
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
        String userId = String.valueOf(u.getUser().getRefuser());

        String idrole = request.getParameter("idrole");
        String maxpubStr = request.getParameter("maxpublicationparjour");

        if (idrole == null || idrole.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"ID role manquant\"}");
            return;
        }
        if (maxpubStr == null || maxpubStr.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Le max publications est obligatoire\"}");
            return;
        }

        int maxpub;
        try {
            maxpub = Integer.parseInt(maxpubStr.trim());
        } catch (NumberFormatException nfe) {
            out.print("{\"success\":false,\"error\":\"Valeur invalide pour max publications\"}");
            return;
        }
        if (maxpub < -1) {
            out.print("{\"success\":false,\"error\":\"La valeur minimale est -1\"}");
            return;
        }

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        Limiterole[] arr = (Limiterole[]) CGenUtil.rechercher(
            new Limiterole(), null, null, conn,
            " and idrole='" + idrole.trim().replace("'","''") + "'"
        );
        if (arr == null || arr.length == 0) {
            out.print("{\"success\":false,\"error\":\"Limite role introuvable\"}");
            return;
        }

        Limiterole lr = arr[0];
        lr.setMaxpublicationparjour(maxpub);
        lr.setMode("modif");
        lr.updateToTableWithHisto(userId, conn);
        conn.commit();

        out.print("{\"success\":true,\"id\":\"" + idrole.trim() + "\"}");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
