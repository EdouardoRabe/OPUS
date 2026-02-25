<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="alumni.ProfilStatut" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="utilitaire.UtilDB" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");
    String result = "{\"success\":false,\"error\":\"Erreur inconnue\"}";
    
    Connection conn = null;
    try {
        UserEJB uEJB = (UserEJB) session.getAttribute("u");
        if (uEJB == null || uEJB.getUser() == null) {
            result = "{\"success\":false,\"error\":\"Non authentifié\"}";
        } else {
            String action = request.getParameter("action");
            
            if ("update".equals(action)) {
                String idprofil = request.getParameter("idprofil");
                String idprofiltypestatut = request.getParameter("idprofiltypestatut");
                
                if (idprofil == null || idprofil.trim().isEmpty()) {
                    result = "{\"success\":false,\"error\":\"Profil invalide\"}";
                } else if (idprofiltypestatut == null || idprofiltypestatut.trim().isEmpty()) {
                    result = "{\"success\":false,\"error\":\"Statut invalide\"}";
                } else {
                    conn = new UtilDB().GetConn();
                    conn.setAutoCommit(false);
                    
                    try {
                        String userId = String.valueOf(uEJB.getUser().getRefuser());
                        
                        // Créer un nouveau ProfilStatut avec la séquence
                        ProfilStatut ps = new ProfilStatut();
                        ps.construirePK(conn);
                        ps.setIdprofil(idprofil.trim());
                        ps.setIdprofiltypestatut(idprofiltypestatut.trim());
                        ps.setDaty(new Timestamp(System.currentTimeMillis()));
                        
                        // Sauvegarder
                        ps.insertToTableWithHisto(userId, conn);
                        conn.commit();
                        
                        result = "{\"success\":true,\"message\":\"Statut mis à jour\"}";
                    } catch (Exception e) {
                        conn.rollback();
                        result = "{\"success\":false,\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}";
                        e.printStackTrace();
                    }
                }
            } else {
                result = "{\"success\":false,\"error\":\"Action non supportée\"}";
            }
        }
    } catch (Exception e) {
        result = "{\"success\":false,\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}";
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
    
    out.print(result);
%>
