<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Profil" %>
<%@ page import="java.sql.Connection" %>
<%!
    private String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
%>
<%
    // AJAX GET: Rechercher des utilisateurs pour @mention autocomplete
    // Param: q (texte de recherche, min 1 caractere)
    // Retourne: liste de {id, nom, prenom, nomComplet}
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        String query = request.getParameter("q");
        if (query == null || query.trim().isEmpty()) {
            out.print("{\"success\":true,\"utilisateurs\":[]}");
            return;
        }

        query = query.trim().toLowerCase();
        int refuser = u.getUser().getRefuser();

        Connection conn = new UtilDB().GetConn();
        try {
            // Recherche par nom ou prenom (ILIKE pour PostgreSQL)
            Profil[] profils = (Profil[]) CGenUtil.rechercher(
                new Profil(), null, null, conn,
                " and idutilisateur != " + refuser 
                + " and (lower(nom) like '%" + query.replace("'", "''") + "%'"
                + " or lower(prenom) like '%" + query.replace("'", "''") + "%')");
            if (profils == null) profils = new Profil[0];

            StringBuilder sb = new StringBuilder("[");
            int limit = Math.min(profils.length, 10); // Max 10 suggestions
            for (int i = 0; i < limit; i++) {
                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"id\":").append(profils[i].getIdutilisateur());
                sb.append(",\"nom\":\"").append(ej(profils[i].getNom())).append("\"");
                sb.append(",\"prenom\":\"").append(ej(profils[i].getPrenom())).append("\"");
                sb.append(",\"nomComplet\":\"").append(ej(profils[i].getNom() + " " + profils[i].getPrenom())).append("\"");
                sb.append("}");
            }
            sb.append("]");

            out.print("{\"success\":true,\"utilisateurs\":" + sb.toString() + "}");

        } finally {
            if (conn != null) conn.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
