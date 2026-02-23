<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Notification" %>
<%@ page import="alumni.Profil" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%!
    private String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }

    private String calculerEcart(String daty, String heure) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date dateNotif = sdf.parse(daty + " " + (heure != null ? heure : "00:00:00"));
            long diff = System.currentTimeMillis() - dateNotif.getTime();
            long seconds = diff / 1000;
            long minutes = seconds / 60;
            long hours = minutes / 60;
            long days = hours / 24;

            if (days > 30) return (days / 30) + " mois";
            if (days > 0) return days + " j";
            if (hours > 0) return hours + " h";
            if (minutes > 0) return minutes + " min";
            return "A l'instant";
        } catch (Exception e) {
            return "";
        }
    }

    private String getIconeType(String type) {
        if (type == null) return "bi-bell";
        switch(type) {
            case "COMMENT": return "bi-chat-dots";
            case "REPLY": return "bi-reply";
            case "PUB_REACTION": return "bi-hand-thumbs-up";
            case "COMM_REACTION": return "bi-heart";
            case "MENTION": return "bi-at";
            case "IDENTIFICATION": return "bi-tag";
            default: return "bi-bell";
        }
    }
%>
<%
    // AJAX GET: Charger les notifications de l'utilisateur connecte
    // Params optionnels: limit (nombre max, defaut 20), offset (pagination)
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        int refuser = u.getUser().getRefuser();
        String limitParam = request.getParameter("limit");
        int limit = 20;
        if (limitParam != null) {
            try { limit = Integer.parseInt(limitParam); } catch (Exception e) {}
        }

        Connection conn = new UtilDB().GetConn();
        try {
            // Charger les noms des utilisateurs (sources des notifs)
            Profil[] allProfils = (Profil[]) CGenUtil.rechercher(
                new Profil(), null, null, conn, "");
            Map userNames = new HashMap();
            if (allProfils != null) {
                for (int i = 0; i < allProfils.length; i++) {
                    userNames.put(String.valueOf(allProfils[i].getIdutilisateur()), 
                        allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                }
            }

            // Charger les notifications non lues + recentes
            Notification[] notifs = (Notification[]) CGenUtil.rechercher(
                new Notification(), null, null, conn,
                " and idutilisateur = " + refuser + " order by daty desc, heure desc");
            if (notifs == null) notifs = new Notification[0];

            int nbNonLu = 0;
            StringBuilder sb = new StringBuilder("[");
            int count = 0;
            for (int i = 0; i < notifs.length && count < limit; i++) {
                Notification n = notifs[i];
                if (n.getEtat() == 0) nbNonLu++;

                String sourceNom = (String) userNames.get(n.getIdorigine());
                if (sourceNom == null) sourceNom = "Quelqu'un";

                if (count > 0) sb.append(",");
                sb.append("{");
                sb.append("\"id\":\"").append(ej(n.getIdnotification())).append("\"");
                sb.append(",\"objet\":\"").append(ej(n.getObjet())).append("\"");
                sb.append(",\"type\":\"").append(ej(n.getTypenotif())).append("\"");
                sb.append(",\"icone\":\"").append(getIconeType(n.getTypenotif())).append("\"");
                sb.append(",\"lien\":\"").append(ej(n.getLien())).append("\"");
                sb.append(",\"etat\":").append(n.getEtat());
                sb.append(",\"daty\":\"").append(ej(n.getDaty() != null ? n.getDaty().toString() : "")).append("\"");
                sb.append(",\"heure\":\"").append(ej(n.getHeure())).append("\"");
                sb.append(",\"ecart\":\"").append(calculerEcart(n.getDaty() != null ? n.getDaty().toString() : null, n.getHeure())).append("\"");
                sb.append(",\"source\":\"").append(ej(sourceNom)).append("\"");
                sb.append(",\"idorigine\":\"").append(ej(n.getIdorigine())).append("\"");
                sb.append("}");
                count++;
            }
            sb.append("]");

            out.print("{\"success\":true,\"nbNonLu\":" + nbNonLu 
                + ",\"total\":" + notifs.length 
                + ",\"notifications\":" + sb.toString() + "}");

        } finally {
            if (conn != null) conn.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
