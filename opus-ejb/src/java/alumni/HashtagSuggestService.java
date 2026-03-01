package alumni;

import java.sql.Connection;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour l'autocompletion des hashtags (#promotion, #specialite, #parcours).
 * Gere sa propre connexion. Utilise CGenUtil (APJ).
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

            // --- Promotions via APJ ---
            Promotion[] promos = (Promotion[]) CGenUtil.rechercher(
                new Promotion(), null, null, conn,
                " and UPPER(REPLACE(libelle,' ','')) LIKE '%" + q + "%' order by annee desc limit 5");
            if (promos != null) {
                for (int i = 0; i < promos.length; i++) {
                    String tag = "#" + promos[i].getLibelle().toUpperCase().replaceAll("[^A-Z0-9]", "");
                    String label = "Promotion " + promos[i].getLibelle() + " (" + promos[i].getAnnee() + ")";
                    if (!first) json.append(",");
                    first = false;
                    json.append("{\"tag\":\"").append(tag)
                        .append("\",\"label\":\"").append(label.replace("\"", "'"))
                        .append("\",\"type\":\"PROMOTION\",\"idref\":\"").append(promos[i].getIdpromotion()).append("\"}");
                }
            }

            // --- Specialites via APJ ---
            Specialite[] specs = (Specialite[]) CGenUtil.rechercher(
                new Specialite(), null, null, conn,
                " and UPPER(REPLACE(libelle,' ','')) LIKE '%" + q + "%' order by libelle limit 5");
            if (specs != null) {
                for (int i = 0; i < specs.length; i++) {
                    String lib = specs[i].getLibelle();
                    String tag = "#" + lib.toUpperCase().replaceAll("[^A-Z0-9]", "");
                    if (tag.length() > 21) tag = tag.substring(0, 21);
                    if (!first) json.append(",");
                    first = false;
                    json.append("{\"tag\":\"").append(tag)
                        .append("\",\"label\":\"").append(lib.replace("\"", "'").replace("\\", ""))
                        .append("\",\"type\":\"SPECIALITE\",\"idref\":\"").append(specs[i].getIdspecialite()).append("\"}");
                }
            }

            // --- Parcours via APJ ---
            Parcours[] parcs = (Parcours[]) CGenUtil.rechercher(
                new Parcours(), null, null, conn,
                " and UPPER(REPLACE(libelle,' ','')) LIKE '%" + q + "%' order by libelle limit 5");
            if (parcs != null) {
                for (int i = 0; i < parcs.length; i++) {
                    String lib = parcs[i].getLibelle();
                    String tag = "#" + lib.toUpperCase().replaceAll("[^A-Z0-9]", "");
                    if (tag.length() > 21) tag = tag.substring(0, 21);
                    if (!first) json.append(",");
                    first = false;
                    json.append("{\"tag\":\"").append(tag)
                        .append("\",\"label\":\"").append(lib.replace("\"", "'"))
                        .append("\",\"type\":\"PARCOURS\",\"idref\":\"").append(parcs[i].getIdparcours()).append("\"}");
                }
            }

        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
        json.append("]");
        return json.toString();
    }
}