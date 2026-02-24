<%@ page pageEncoding="UTF-8" contentType="text/plain; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Statement" %>
<%
    // =========================================================
    // AJAX : Marquer une publication comme vue par l'utilisateur
    // Methode : POST
    // Parametre : idpublication
    // Retour    : "ok" ou "err"
    // UPSERT : si deja vue -> nbvue++; sinon -> INSERT
    // =========================================================

    response.setHeader("Cache-Control", "no-store");

    UserEJB uVue = (UserEJB) session.getAttribute("u");
    if (uVue == null) { out.print("err"); return; }

    String idpub = request.getParameter("idpublication");
    if (idpub == null || idpub.trim().isEmpty()) { out.print("err"); return; }

    // Sanitize : idpublication = alphanum uniquement
    idpub = idpub.replaceAll("[^A-Za-z0-9]", "");
    if (idpub.isEmpty()) { out.print("err"); return; }

    int refuser = uVue.getUser().getRefuser();

    Connection conn = null;
    Statement st    = null;
    try {
        conn = new UtilDB().GetConn();
        st   = conn.createStatement();
        // UPSERT PostgreSQL : insere ou incremente nbvue
        st.executeUpdate(
            "INSERT INTO publicationvue (idutilisateur, idpublication, datvue, nbvue)"
            + " VALUES (" + refuser + ", '" + idpub + "', NOW(), 1)"
            + " ON CONFLICT (idutilisateur, idpublication)"
            + " DO UPDATE SET nbvue = publicationvue.nbvue + 1, datvue = NOW()"
        );
        out.print("ok");
    } catch (Exception e) {
        out.print("err");
    } finally {
        if (st   != null) try { st.close();   } catch (Exception _x) {}
        if (conn != null) try { conn.close();  } catch (Exception _x) {}
    }
%>
