<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publicationenregistrement" %>
<%@ page import="java.sql.Connection" %>
<%
    // AJAX GET : Toggle enregistrement (save/unsave) publication
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        String idpub = request.getParameter("idpublication");
        if (idpub == null || idpub.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"idpublication manquant\"}");
            return;
        }

        String userId = String.valueOf(u.getUser().getRefuser());
        int refuser = u.getUser().getRefuser();

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        // Rechercher enregistrement existant (APJ)
        Publicationenregistrement[] existing = (Publicationenregistrement[]) CGenUtil.rechercher(
            new Publicationenregistrement(), null, null, conn,
            " and idutilisateur = " + userId + " and idpublication = '" + idpub + "'");

        if (existing != null && existing.length > 0) {
            // Deja enregistre -> supprimer (unsave)
            existing[0].deleteToTable(conn);
            conn.commit();
            out.print("{\"success\":true,\"saved\":false}");
        } else {
            // Pas encore enregistre -> inserer (save)
            Publicationenregistrement enr = new Publicationenregistrement();
            enr.setIdpublication(idpub);
            enr.setIdutilisateur(refuser);
            enr.setDaty(new java.sql.Date(System.currentTimeMillis()));
            enr.setHeure(new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date()));
            enr.construirePK(conn);
            enr.insertToTable(conn);
            conn.commit();
            out.print("{\"success\":true,\"saved\":true}");
        }
    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        out.print("{\"success\":false,\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception x) {}
    }
%>