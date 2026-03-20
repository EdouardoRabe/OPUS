package alumni;

import java.sql.Connection;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour l'administration des publications (delete/update).
 * Note: utilise CGenUtil.rechercher(critere, null, null, "") SANS connexion
 * pour la verification de propriete, conformement au code original.
 * Gere sa propre connexion pour les operations d'ecriture.
 */
public class PublicationAdminService {

    /**
     * Supprimer (desactiver) une publication en mettant etat = 0.
     * Verifie d'abord que la publication appartient a l'utilisateur.
     */
    public static String supprimer(int refuser, String idpublication) throws Exception {
        if (idpublication == null || idpublication.trim().isEmpty())
            return "{\"success\":false,\"error\":\"ID publication manquant\"}";

        // Verification de propriete SANS connexion (pattern original)
        Publication critere = new Publication();
        critere.setIdpublication(idpublication.trim());
        Publication[] found = (Publication[]) CGenUtil.rechercher(critere, null, null, "");
        if (found == null || found.length == 0)
            return "{\"success\":false,\"error\":\"Publication introuvable\"}";

        Publication existante = found[0];
        if (existante.getIdutilisateur() != refuser)
            return "{\"success\":false,\"error\":\"Vous ne pouvez supprimer que vos propres publications\"}";

        // Mise a jour avec connexion
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            String reqSup = "UPDATE publication SET etat = 0 WHERE idpublication = '" + idpublication.trim() + "'";
            new Publication().updateToTableDirecte(reqSup, conn);
            return "{\"success\":true,\"id\":\"" + idpublication.trim() + "\"}";
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /**
     * Mettre a jour une publication (description, type).
     * Verifie d'abord que la publication appartient a l'utilisateur.
     */
    public static String modifier(int refuser, String userId, String idpublication,
            String descritpion, String idtypepublication) throws Exception {

        if (idpublication == null || idpublication.trim().isEmpty())
            return "{\"success\":false,\"error\":\"ID publication manquant\"}";

        // Verification de propriete SANS connexion (pattern original)
        Publication critere = new Publication();
        critere.setIdpublication(idpublication.trim());
        Publication[] found = (Publication[]) CGenUtil.rechercher(critere, null, null, "");
        if (found == null || found.length == 0)
            return "{\"success\":false,\"error\":\"Publication introuvable\"}";

        Publication existante = found[0];
        if (existante.getIdutilisateur() != refuser)
            return "{\"success\":false,\"error\":\"Vous ne pouvez modifier que vos propres publications\"}";

        // Update avec connexion
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Publication pub = new Publication();
            pub.setIdpublication(idpublication.trim());
            pub.setDescritpion(descritpion != null ? descritpion.trim() : "");
            pub.setIdtypepublication(idtypepublication != null
                ? idtypepublication.trim() : existante.getIdtypepublication());
            pub.setDaty(existante.getDaty());
            pub.setHeure(existante.getHeure());
            pub.setEtat(existante.getEtat());
            pub.setIdorigine(existante.getIdorigine());
            pub.setIdutilisateur(existante.getIdutilisateur());
            pub.setIdpuborigine(existante.getIdpuborigine());
            pub.setMode("modif");
            pub.updateToTableWithHisto(userId, conn);
            conn.commit();

            return "{\"success\":true,\"id\":\"" + idpublication.trim() + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
