package alumni;

import java.sql.Connection;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour les identifications (tags) d'utilisateurs dans les publications.
 * Gere sa propre connexion.
 */
public class IdentificationService {

    public static String identifier(int refuser, String idpublication, String idsUtilisateurs) throws Exception {
        if (idpublication == null || idsUtilisateurs == null || idsUtilisateurs.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Parametres manquants\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            String nomSource = Notification.getNomUtilisateur(conn, refuser);
            String[] ids = idsUtilisateurs.split(",");
            int nbIdentifies = 0;

            for (int i = 0; i < ids.length; i++) {
                String idTarget = ids[i].trim();
                if (idTarget.isEmpty()) continue;
                int targetUserId = Integer.parseInt(idTarget);

                Identification[] existing = (Identification[]) CGenUtil.rechercher(
                    new Identification(), null, null, conn,
                    " and idutilisateur = " + targetUserId + " and idpublication = '" + idpublication + "'");

                if (existing == null || existing.length == 0) {
                    Identification ident = new Identification();
                    ident.setIdutilisateur(targetUserId);
                    ident.setIdpublication(idpublication);
                    ident.construirePK(conn);
                    ident.insertToTableWithHisto(userId, conn);

                    String lien = "module.jsp?but=accueil.jsp#pub-" + idpublication;
                    Notification.creerEtEnvoyer(conn, userId, targetUserId,
                        nomSource + " vous a identifie(e) dans une publication",
                        Notification.TYPE_IDENTIFICATION, lien);
                    nbIdentifies++;
                }
            }

            conn.commit();
            return "{\"success\":true,\"nbIdentifies\":" + nbIdentifies + "}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception cx) {}
        }
    }
}
