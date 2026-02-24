<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Signalementpublication" %>
<%@ page import="java.sql.Connection" %>
<%
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        String idpub = request.getParameter("idpublication");
        String description = request.getParameter("description");
        String[] typesSignalement = request.getParameterValues("typesignalement");

        if (idpub == null || idpub.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"idpublication manquant\"}");
            return;
        }
        if (typesSignalement == null || typesSignalement.length == 0) {
            out.print("{\"success\":false,\"error\":\"Veuillez selectionner au moins un motif\"}");
            return;
        }

        String userId = String.valueOf(u.getUser().getRefuser());
        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        for (int i = 0; i < typesSignalement.length; i++) {
            Signalementpublication sig = new Signalementpublication();
            sig.construirePK(conn);
            sig.setIdpublication(idpub);
            sig.setIdutilisateur(userId);
            sig.setTypesignalement(typesSignalement[i]);
            sig.setDescritpion(description != null ? description : "");
            sig.setDaty(new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()));
            sig.insertToTableWithHisto(userId, conn);
        }

        conn.commit();
        out.print("{\"success\":true}");

    } catch (Exception e) {
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception cx) {}
    }
%>