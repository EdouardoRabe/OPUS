<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
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

        String nom      = request.getParameter("nom");
        String prenom   = request.getParameter("prenom");
        String telephone= request.getParameter("telephone");

        if (nom == null || nom.trim().isEmpty() || prenom == null || prenom.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Nom et prénom obligatoires\"}");
            return;
        }

        // nomuser = "nom prenom" dans la table utilisateur
        String nomuser = nom.trim() + " " + prenom.trim();

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        PreparedStatement ps = conn.prepareStatement(
            "UPDATE utilisateur SET nomuser=?, teluser=? WHERE refuser=?"
        );
        ps.setString(1, nomuser);
        ps.setString(2, telephone != null ? telephone.trim() : "");
        ps.setInt   (3, refuser);
        ps.executeUpdate();
        ps.close();

        conn.commit();
        out.print("{\"success\":true}");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"","'").replace("\n"," ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
