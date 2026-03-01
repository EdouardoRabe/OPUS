package alumni;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import utilitaire.UtilDB;

/**
 * Service pour l'autocompletion des hashtags (#promotion, #specialite, #parcours).
 * Gere sa propre connexion.
 */
public class HashtagSuggestService {

    public static String suggest(String query) throws Exception {
        if (query == null || query.trim().isEmpty()) return "[]";
        String q = query.trim().toUpperCase().replaceAll("[^A-Z0-9]", "");
        if (q.isEmpty()) return "[]";

        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            // --- Promotions ---
            PreparedStatement ps = conn.prepareStatement(
                "SELECT idpromotion, libelle, annee FROM promotion "
                + "WHERE UPPER(REPLACE(libelle,' ','')) LIKE ? ORDER BY annee DESC LIMIT 5");
            ps.setString(1, "%" + q + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String tag = "#" + rs.getString("libelle").toUpperCase().replaceAll("[^A-Z0-9]", "");
                String label = "Promotion " + rs.getString("libelle") + " (" + rs.getInt("annee") + ")";
                String idref = rs.getString("idpromotion");
                if (!first) json.append(",");
                first = false;
                json.append("{\"tag\":\"").append(tag)
                    .append("\",\"label\":\"").append(label.replace("\"", "'"))
                    .append("\",\"type\":\"PROMOTION\",\"idref\":\"").append(idref).append("\"}");
            }
            rs.close(); ps.close();

            // --- Specialites ---
            ps = conn.prepareStatement(
                "SELECT idspecialite, libelle FROM specialite "
                + "WHERE UPPER(REPLACE(libelle,' ','')) LIKE ? ORDER BY libelle LIMIT 5");
            ps.setString(1, "%" + q + "%");
            rs = ps.executeQuery();
            while (rs.next()) {
                String lib = rs.getString("libelle");
                String tag = "#" + lib.toUpperCase().replaceAll("[^A-Z0-9]", "");
                if (tag.length() > 21) tag = tag.substring(0, 21);
                String idref = rs.getString("idspecialite");
                if (!first) json.append(",");
                first = false;
                json.append("{\"tag\":\"").append(tag)
                    .append("\",\"label\":\"").append(lib.replace("\"", "'").replace("\\", ""))
                    .append("\",\"type\":\"SPECIALITE\",\"idref\":\"").append(idref).append("\"}");
            }
            rs.close(); ps.close();

            // --- Parcours ---
            ps = conn.prepareStatement(
                "SELECT idparcours, libelle FROM parcours "
                + "WHERE UPPER(REPLACE(libelle,' ','')) LIKE ? ORDER BY libelle LIMIT 5");
            ps.setString(1, "%" + q + "%");
            rs = ps.executeQuery();
            while (rs.next()) {
                String lib = rs.getString("libelle");
                String tag = "#" + lib.toUpperCase().replaceAll("[^A-Z0-9]", "");
                if (tag.length() > 21) tag = tag.substring(0, 21);
                String idref = rs.getString("idparcours");
                if (!first) json.append(",");
                first = false;
                json.append("{\"tag\":\"").append(tag)
                    .append("\",\"label\":\"").append(lib.replace("\"", "'"))
                    .append("\",\"type\":\"PARCOURS\",\"idref\":\"").append(idref).append("\"}");
            }
            rs.close(); ps.close();

        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
        json.append("]");
        return json.toString();
    }
}
