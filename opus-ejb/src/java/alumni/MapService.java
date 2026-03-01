package alumni;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour la carte des alumni.
 * Gere sa propre connexion.
 * Retourne un JSON array pur (pas enveloppe dans {success:...}).
 */
public class MapService {

    public static String getAlumni(String contextPath) throws Exception {
        Connection conn = null;
        VProfilLocalisation[] alumniList = null;
        Map specMap = new HashMap();

        try {
            conn = new UtilDB().GetConn();
            alumniList = (VProfilLocalisation[]) CGenUtil.rechercher(
                new VProfilLocalisation(), null, null, conn, " and estactif = 1");

            // Load specialites per profil
            PreparedStatement ps = conn.prepareStatement(
                "SELECT sp.idprofil, s.libelle FROM specialiteprofil sp JOIN specialite s ON s.idspecialite = sp.idspecialite");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String pid = rs.getString("idprofil");
                String lib = rs.getString("libelle");
                List list = (List) specMap.get(pid);
                if (list == null) { list = new ArrayList(); specMap.put(pid, list); }
                list.add(lib);
            }
            rs.close();
            ps.close();
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }

        StringBuilder sb = new StringBuilder("[");
        if (alumniList != null) {
            for (int i = 0; i < alumniList.length; i++) {
                VProfilLocalisation a = alumniList[i];

                String photo = a.getPhotoProfil();
                if (photo == null) photo = "";
                else if (!photo.isEmpty() && !photo.startsWith("http"))
                    photo = contextPath + "/" + photo;

                String initials = "";
                if (a.getNom() != null && !a.getNom().isEmpty())
                    initials += a.getNom().substring(0, 1).toUpperCase();
                if (a.getPrenom() != null && !a.getPrenom().isEmpty())
                    initials += a.getPrenom().substring(0, 1).toUpperCase();
                if (initials.isEmpty()) initials = "U";

                // Specialites JSON array
                List specs = (List) specMap.get(a.getIdprofil());
                StringBuilder specJson = new StringBuilder("[");
                if (specs != null) {
                    for (int si = 0; si < specs.size(); si++) {
                        if (si > 0) specJson.append(",");
                        specJson.append("\"").append(
                            ((String) specs.get(si)).replace("\"", "\\\"")).append("\"");
                    }
                }
                specJson.append("]");

                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"id\":\"").append(a.getIdprofil()).append("\",");
                sb.append("\"n\":\"").append(a.getNom() != null ? a.getNom().replace("\"", "\\\"") : "").append("\",");
                sb.append("\"p\":\"").append(a.getPrenom() != null ? a.getPrenom().replace("\"", "\\\"") : "").append("\",");
                sb.append("\"pos\":[").append(a.getLatitude()).append(",").append(a.getLongitude()).append("],");
                sb.append("\"img\":\"").append(photo).append("\",");
                sb.append("\"init\":\"").append(initials).append("\",");
                sb.append("\"promo\":\"").append(a.getPromotionLib() != null ? a.getPromotionLib().replace("\"", "\\\"") : "").append("\",");
                sb.append("\"promoAnnee\":").append(a.getPromotionAnnee()).append(",");
                sb.append("\"parcours\":\"").append(a.getParcoursLib() != null ? a.getParcoursLib().replace("\"", "\\\"") : "").append("\",");
                sb.append("\"idparcours\":\"").append(a.getIdparcours() != null ? a.getIdparcours() : "").append("\",");
                sb.append("\"specs\":").append(specJson.toString());
                sb.append("}");
            }
        }
        sb.append("]");
        return sb.toString();
    }
}
