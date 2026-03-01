package alumni;

import java.sql.Connection;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour l'administration des specialites.
 * Les operations DB seulement (le multipart parsing reste dans le JSP).
 * Gere sa propre connexion.
 */
public class SpecialiteAdminService {

    /**
     * Inserer une nouvelle specialite.
     * @param userId  String id de l'utilisateur connecte
     * @param libelle libelle de la specialite
     * @param description description
     * @param photoPath chemin relatif de la photo (deja sauvegardee sur disque)
     */
    public static String inserer(String userId, String libelle, String description,
            String photoPath) throws Exception {

        if (libelle == null || libelle.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Le libell\\u00e9 est obligatoire\"}";

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Specialite spe = new Specialite();
            spe.setLibelle(libelle.trim());
            spe.setDescription(description != null ? description.trim() : "");
            spe.setPhoto(photoPath != null ? photoPath : "");
            spe.construirePK(conn);
            spe.insertToTableWithHisto(userId, conn);
            conn.commit();

            return "{\"success\":true,\"id\":\"" + spe.getIdspecialite() + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /**
     * Mettre a jour une specialite existante.
     * @param userId  String id de l'utilisateur connecte
     * @param idspecialite ID de la specialite
     * @param libelle nouveau libelle
     * @param description nouvelle description
     * @param photoPath chemin relatif de la photo (nouvelle ou ancienne)
     */
    public static String modifier(String userId, String idspecialite, String libelle,
            String description, String photoPath) throws Exception {

        if (idspecialite == null || idspecialite.trim().isEmpty())
            return "{\"success\":false,\"error\":\"ID manquant\"}";
        if (libelle == null || libelle.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Le libell\\u00e9 est obligatoire\"}";

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Specialite spe = new Specialite();
            spe.setIdspecialite(idspecialite.trim());
            spe.setLibelle(libelle.trim());
            spe.setDescription(description != null ? description.trim() : "");
            spe.setPhoto(photoPath != null ? photoPath : "");
            spe.setMode("modif");
            spe.updateToTableWithHisto(userId, conn);
            conn.commit();

            return "{\"success\":true,\"id\":\"" + idspecialite.trim() + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
