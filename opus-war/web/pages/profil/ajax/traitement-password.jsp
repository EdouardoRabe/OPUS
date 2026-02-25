<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="user.UserEJBClient" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="historique.ParamCrypt" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="utilitaireAcade.Utilitaire" %>
<%@ page import="java.sql.Connection" %>
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

        // Verifier l'ancien mot de passe via testLogin
        try {
            UserEJB uTest = UserEJBClient.lookupUserEJBBeanLocal();
            uTest.testLogin(mu.getLoginuser(), oldPassword.trim());
        } catch (Exception loginEx) {
            out.print("{\"success\":false,\"error\":\"L'ancien mot de passe est incorrect\"}"); return;
        }

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        // Recuperer les parametres de cryptage existants
        ParamCrypt[] pcs = (ParamCrypt[]) CGenUtil.rechercher(
            new ParamCrypt(), null, null, conn,
            " and idutilisateur='" + String.valueOf(refuser).replace("'","''") + "'"
        );

        int niveau;
        int sens;
        if (pcs != null && pcs.length > 0) {
            niveau = pcs[0].getNiveau();
            sens = pcs[0].getCroissante();
        } else {
            // Generer de nouveaux parametres si aucun n'existe
            niveau = (int) Math.round(Math.random() * 10.0);
            sens = (int) Math.round(Math.random());
            if (niveau == 0) niveau = -5;
        }

        // Crypter le nouveau mot de passe
        String newPwdCrypt = Utilitaire.cryptWord(newPassword.trim().toLowerCase(), niveau, sens == 0);

        // Mettre a jour le mot de passe dans la table utilisateur
        java.sql.PreparedStatement ps = conn.prepareStatement(
            "UPDATE utilisateur SET pwduser = ? WHERE refuser = ?"
        );
        ps.setString(1, newPwdCrypt);
        ps.setInt(2, refuser);
        int updated = ps.executeUpdate();
        ps.close();

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
        System.err.println("traitement-password.jsp - erreur: " + e.getMessage());
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>
