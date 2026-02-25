<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="utilitaire.Utilitaire" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }

        MapUtilisateur mu = u.getUser();
        int refuser = mu.getRefuser();

        String oldPassword   = request.getParameter("oldPassword");
        String newPassword   = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (oldPassword == null || oldPassword.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"L'ancien mot de passe est requis\"}"); return;
        }
        if (newPassword == null || newPassword.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Le nouveau mot de passe est requis\"}"); return;
        }
        if (newPassword.trim().length() < 3) {
            out.print("{\"success\":false,\"error\":\"Le mot de passe doit contenir au moins 3 caracteres\"}"); return;
        }
        if (!newPassword.equals(confirmPassword)) {
            out.print("{\"success\":false,\"error\":\"Les mots de passe ne correspondent pas\"}"); return;
        }

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        // Recuperer les parametres de cryptage et le mot de passe stocke
        int niveau = 0;
        int sens = 0;
        String storedPwd = null;

        PreparedStatement psPC = conn.prepareStatement(
            "SELECT p.niveau, p.croissante, u.pwduser " +
            "FROM paramcrypt p JOIN utilisateur u ON CAST(u.refuser AS varchar) = p.idutilisateur " +
            "WHERE p.idutilisateur = ?"
        );
        psPC.setString(1, String.valueOf(refuser));
        ResultSet rsPC = psPC.executeQuery();
        if (rsPC.next()) {
            niveau = rsPC.getInt("niveau");
            sens = rsPC.getInt("croissante");
            storedPwd = rsPC.getString("pwduser");
        } else {
            rsPC.close(); psPC.close();
            conn.rollback();
            out.print("{\"success\":false,\"error\":\"Parametres de cryptage introuvables\"}"); return;
        }
        rsPC.close(); psPC.close();

        // Verifier l'ancien mot de passe
        String oldPwdCrypt = Utilitaire.cryptWord(oldPassword.trim().toLowerCase(), niveau, sens == 0);
        if (storedPwd == null || !storedPwd.equals(oldPwdCrypt)) {
            conn.rollback();
            out.print("{\"success\":false,\"error\":\"L'ancien mot de passe est incorrect\"}"); return;
        }

        // Crypter le nouveau mot de passe
        String newPwdCrypt = Utilitaire.cryptWord(newPassword.trim().toLowerCase(), niveau, sens == 0);

        // Mettre a jour le mot de passe dans la table utilisateur
        PreparedStatement psUp = conn.prepareStatement(
            "UPDATE utilisateur SET pwduser = ? WHERE refuser = ?"
        );
        psUp.setString(1, newPwdCrypt);
        psUp.setInt(2, refuser);
        int updated = psUp.executeUpdate();
        psUp.close();

        if (updated == 0) {
            conn.rollback();
            out.print("{\"success\":false,\"error\":\"Utilisateur non trouve\"}"); return;
        }

        conn.commit();

        // Mettre a jour le mot de passe en session
        mu.setPwduser(newPwdCrypt);

        out.print("{\"success\":true,\"message\":\"Mot de passe modifie avec succes\"}");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception ignore) {}
        String errMsg = e.getMessage() != null ? e.getMessage().replace("\"","\\\"").replace("\n"," ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + errMsg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>
