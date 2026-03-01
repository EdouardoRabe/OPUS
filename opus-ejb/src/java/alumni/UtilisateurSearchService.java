package alumni;

import java.sql.Connection;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour la recherche d'utilisateurs (@mention autocomplete).
 * Gere sa propre connexion.
 */
public class UtilisateurSearchService {

    private static String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }

    public static String rechercher(int refuser, String query) throws Exception {
        if (query == null || query.trim().isEmpty())
            return "{\"success\":true,\"utilisateurs\":[]}";

        query = query.trim().toLowerCase();
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            Profil[] profils = (Profil[]) CGenUtil.rechercher(
                new Profil(), null, null, conn,
                " and idutilisateur != " + refuser
                + " and (lower(coalesce(nom,'') || ' ' || coalesce(prenom,'')) like '%" + query.replace("'", "''") + "%'"
                + " or lower(coalesce(prenom,'') || ' ' || coalesce(nom,'')) like '%" + query.replace("'", "''") + "%')");
            if (profils == null) profils = new Profil[0];

            StringBuilder sb = new StringBuilder("[");
            int limit = Math.min(profils.length, 10);
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
            return "{\"success\":true,\"utilisateurs\":" + sb.toString() + "}";
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
