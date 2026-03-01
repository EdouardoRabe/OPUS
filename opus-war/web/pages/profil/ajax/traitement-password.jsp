<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.ProfilService" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        MapUtilisateur mu = u.getUser();
        int refuser = mu.getRefuser();

        String oldPassword     = request.getParameter("oldPassword");
        String newPassword     = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        String result = ProfilService.changePassword(refuser, oldPassword, newPassword, confirmPassword);

        // Extraire _pwdCrypt pour mettre a jour la session
        if (result.contains("\"_pwdCrypt\":\"")) {
            int start = result.indexOf("\"_pwdCrypt\":\"") + "\"_pwdCrypt\":\"".length();
            int end = result.indexOf("\"", start);
            if (end > start) {
                String newPwdCrypt = result.substring(start, end);
                mu.setPwduser(newPwdCrypt);
            }
            // Retirer _pwdCrypt du JSON envoye au client
            result = result.replaceAll(",\"_pwdCrypt\":\"[^\"]*\"", "");
        }

        out.print(result);
    } catch (Exception e) {
        e.printStackTrace();
        String msg = (e.getMessage() != null ? e.getMessage().replace("\"","'").replace("\n"," ") : "Erreur inconnue");
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>