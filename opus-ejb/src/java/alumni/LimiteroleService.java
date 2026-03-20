package alumni;

import java.sql.Connection;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour la gestion des limites de roles.
 * Gere sa propre connexion.
 */
public class LimiteroleService {

    public static String modifier(String userId, String idrole, String maxpubStr) throws Exception {
        if (idrole == null || idrole.trim().isEmpty())
            return "{\"success\":false,\"error\":\"ID role manquant\"}";
        if (maxpubStr == null || maxpubStr.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Le max publications est obligatoire\"}";

        int maxpub;
        try {
            maxpub = Integer.parseInt(maxpubStr.trim());
        } catch (NumberFormatException nfe) {
            return "{\"success\":false,\"error\":\"Valeur invalide pour max publications\"}";
        }
        if (maxpub < -1)
            return "{\"success\":false,\"error\":\"La valeur minimale est -1\"}";

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Limiterole[] arr = (Limiterole[]) CGenUtil.rechercher(
                new Limiterole(), null, null, conn,
                " and idrole='" + idrole.trim().replace("'", "''") + "'");
            if (arr == null || arr.length == 0)
                return "{\"success\":false,\"error\":\"Limite role introuvable\"}";

            Limiterole lr = arr[0];
            lr.setMaxpublicationparjour(maxpub);
            lr.setMode("modif");
            lr.updateToTableWithHisto(userId, conn);
            conn.commit();

            return "{\"success\":true,\"id\":\"" + idrole.trim() + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
