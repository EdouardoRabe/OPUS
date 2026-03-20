<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.ProfilService" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    request.setCharacterEncoding("UTF-8");

    String contextPath = request.getContextPath();
    boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

    if (isAjax) {
        response.setContentType("application/json; charset=UTF-8");
    }

    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            if (isAjax) {
                out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            } else {
                response.sendRedirect(contextPath + "/pages/module.jsp?but=profil/confidentialite.jsp&erreur=Non+connecte");
            }
            return;
        }
        int    refuser = u.getUser().getRefuser();
        String idprofil = request.getParameter("idprofil");

        // Construire la map des status
        String[] champs = {"nom", "prenom", "dtn", "experience", "specialite", "promotion", "email", "parcours", "telephone", "genre", "socialmedia", "localisation"};
        Map statusMap = new HashMap();
        for (int i = 0; i < champs.length; i++) {
            String statusParam = request.getParameter("status_" + champs[i]);
            int status = (statusParam != null && !statusParam.trim().isEmpty()) ? 1 : 0;
            statusMap.put(champs[i], new Integer(status));
        }

        String result = ProfilService.updateConfidentialite(refuser, idprofil, statusMap);

        if (isAjax) {
            out.print(result);
        } else {
            if (result.contains("\"success\":true")) {
                response.sendRedirect(contextPath + "/pages/module.jsp?but=profil/confidentialite.jsp&msg=Parametres+enregistres");
            } else {
                response.sendRedirect(contextPath + "/pages/module.jsp?but=profil/confidentialite.jsp&erreur=Erreur+lors+de+la+sauvegarde");
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getClass().getName() + ": " + (e.getMessage() != null
            ? e.getMessage().replace("\"", "'").replace("\n", " ")
            : "Erreur inconnue");

        if (isAjax) {
            out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
        } else {
            response.sendRedirect(contextPath + "/pages/module.jsp?but=profil/confidentialite.jsp&erreur=" + java.net.URLEncoder.encode(msg, "UTF-8"));
        }
    }
%>