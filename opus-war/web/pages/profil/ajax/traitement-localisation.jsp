<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Profilemplacement" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }

        int    refuser = u.getUser().getRefuser();
        String userId  = String.valueOf(refuser);

        String action = request.getParameter("action");
        if (action == null) { out.print("{\"success\":false,\"error\":\"Action manquante\"}"); return; }

        String idprofil = request.getParameter("idprofil");
        String latitude = request.getParameter("latitude");
        String longitude = request.getParameter("longitude");

        if (idprofil == null || latitude == null || longitude == null) {
            out.print("{\"success\":false,\"error\":\"Donnees manquantes\"}"); return;
        }

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        if ("create".equals(action)) {
            Profilemplacement emp = new Profilemplacement();
            emp.construirePK(conn);
            emp.setIdprofil(idprofil);
            emp.setLatitude(Double.parseDouble(latitude));
            emp.setLongitude(Double.parseDouble(longitude));
            emp.insertToTableWithHisto(userId, conn);
            
            conn.commit();
            out.print("{\"success\":true}");

        } else if ("update".equals(action)) {
            String id = request.getParameter("id");
            if (id == null) { out.print("{\"success\":false,\"error\":\"ID emplacement manquant\"}"); return; }

            Profilemplacement emp = new Profilemplacement();
            emp.setId(id);
            emp.setIdprofil(idprofil);
            emp.setLatitude(Double.parseDouble(latitude));
            emp.setLongitude(Double.parseDouble(longitude));
            emp.setMode("modif");
            emp.updateToTableWithHisto(userId, conn);

            conn.commit();
            out.print("{\"success\":true}");
        } else {
            out.print("{\"success\":false,\"error\":\"Action inconnue\"}");
        }

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = (e.getMessage() != null ? e.getMessage().replace("\"","'").replace("\n"," ") : "Erreur inconnue");
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
