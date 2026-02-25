<%@ page pageEncoding="UTF-8" %>
<%@ page import="alumni.VProfilLocalisation" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    String ctx = request.getContextPath();
    VProfilLocalisation[] alumniList = null;
    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();
        alumniList = (VProfilLocalisation[]) CGenUtil.rechercher(new VProfilLocalisation(), null, null, conn, "");
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }

    StringBuilder sb = new StringBuilder("[");
    if (alumniList != null) {
        for (int i = 0; i < alumniList.length; i++) {
            VProfilLocalisation a = alumniList[i];
            
            String photo = a.getPhotoProfil();
            if (photo == null) photo = "";
            else if (!photo.isEmpty() && !photo.startsWith("http")) photo = ctx + "/" + photo;
            
            String initials = "";
            if (a.getNom() != null && !a.getNom().isEmpty()) initials += a.getNom().substring(0,1).toUpperCase();
            if (a.getPrenom() != null && !a.getPrenom().isEmpty()) initials += a.getPrenom().substring(0,1).toUpperCase();
            if (initials.isEmpty()) initials = "U";

            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"id\":\"").append(a.getIdprofil()).append("\",");
            sb.append("\"n\":\"").append(a.getNom() != null ? a.getNom().replace("\"", "\\\"") : "").append("\",");
            sb.append("\"p\":\"").append(a.getPrenom() != null ? a.getPrenom().replace("\"", "\\\"") : "").append("\",");
            sb.append("\"pos\":[").append(a.getLatitude()).append(",").append(a.getLongitude()).append("],");
            sb.append("\"img\":\"").append(photo).append("\",");
            sb.append("\"init\":\"").append(initials).append("\",");
            sb.append("\"promo\":\"").append(a.getPromotionLib() != null ? a.getPromotionLib().replace("\"", "\\\"") : "").append("\",");
            sb.append("\"parcours\":\"").append(a.getParcoursLib() != null ? a.getParcoursLib().replace("\"", "\\\"") : "").append("\"");
            sb.append("}");
        }
    }
    sb.append("]");
    out.print(sb.toString());
%>
