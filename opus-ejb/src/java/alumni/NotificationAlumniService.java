package alumni;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Map;
import java.util.HashMap;
import java.text.SimpleDateFormat;
import java.util.Date;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour les notifications : marquer lu et charger la liste.
 * Chaque methode gere sa propre connexion.
 */
public class NotificationAlumniService {

    private static String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }

    private static String calculerEcart(String daty, String heure) {
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

    private static String getIconeType(String type) {
        if (type == null) return "bi-bell";
        switch (type) {
            case "COMMENT": return "bi-chat-dots";
            case "REPLY": return "bi-reply";
            case "PUB_REACTION": return "bi-hand-thumbs-up";
            case "COMM_REACTION": return "bi-heart";
            case "MENTION": return "bi-at";
            case "IDENTIFICATION": return "bi-tag";
            default: return "bi-bell";
        }
    }

    /* ======== MARQUER NOTIFICATION(S) COMME LUE(S) ======== */
    public static String marquerLu(int refuser, String idnotification, String action) throws Exception {
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            if ("all".equals(action)) {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE notification SET etat = 1 WHERE idutilisateur = ? AND etat = 0");
                ps.setInt(1, refuser);
                int updated = ps.executeUpdate();
                ps.close();
                conn.commit();
                return "{\"success\":true,\"action\":\"all\",\"updated\":" + updated + "}";
            } else if (idnotification != null && !idnotification.trim().isEmpty()) {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE notification SET etat = 1 WHERE idnotification = ? AND idutilisateur = ?");
                ps.setString(1, idnotification.trim());
                ps.setInt(2, refuser);
                int updated = ps.executeUpdate();
                ps.close();
                conn.commit();
                if (updated > 0)
                    return "{\"success\":true,\"action\":\"one\",\"id\":\"" + idnotification + "\"}";
                else
                    return "{\"success\":false,\"error\":\"Notification introuvable\"}";
            } else {
                return "{\"success\":false,\"error\":\"Parametre manquant\"}";
            }
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception cx) {}
        }
    }

    /* ======== CHARGER NOTIFICATIONS ======== */
    public static String chargerNotifications(int refuser, String limitParam) throws Exception {
        int limit = 20;
        if (limitParam != null) {
            try { limit = Integer.parseInt(limitParam); } catch (Exception e) {}
        }

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            Profil[] allProfils = (Profil[]) CGenUtil.rechercher(
                new Profil(), null, null, conn, "");
            Map userNames = new HashMap();
            if (allProfils != null) {
                for (int i = 0; i < allProfils.length; i++)
                    userNames.put(String.valueOf(allProfils[i].getIdutilisateur()),
                        allProfils[i].getNom() + " " + allProfils[i].getPrenom());
            }

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

            return "{\"success\":true,\"nbNonLu\":" + nbNonLu
                + ",\"total\":" + notifs.length
                + ",\"notifications\":" + sb.toString() + "}";
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
