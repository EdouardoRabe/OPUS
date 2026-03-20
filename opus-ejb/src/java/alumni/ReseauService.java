package alumni;

import java.sql.*;
import java.util.*;
import utilitaire.UtilDB;

/**
 * Service pour le calcul du reseau de compatibilite.
 * Gere sa propre connexion.
 */
public class ReseauService {

    private static int calculerScore(
            Set tagsSelf, String idparcoursSelf, String idposteSelf, int anneeSelf,
            Set tagsOther, String idparcoursOther, String idposteOther, int anneeOther) {

        double scoreTags = 0;
        Set union = new HashSet(tagsSelf);
        union.addAll(tagsOther);
        if (!union.isEmpty()) {
            Set inter = new HashSet(tagsSelf);
            inter.retainAll(tagsOther);
            scoreTags = ((double) inter.size() / union.size()) * 50.0;
        }
        double scoreParcours = 0;
        if (idparcoursSelf != null && idparcoursSelf.equals(idparcoursOther)) scoreParcours = 20.0;
        double scorePoste = 0;
        if (idposteSelf != null && idposteSelf.equals(idposteOther)) scorePoste = 15.0;
        double scorePromo = 0;
        if (anneeSelf > 0 && anneeOther > 0) {
            int diff = Math.abs(anneeSelf - anneeOther);
            if      (diff == 0) scorePromo = 15.0;
            else if (diff <= 1) scorePromo = 12.0;
            else if (diff <= 3) scorePromo = 8.0;
            else if (diff <= 5) scorePromo = 3.0;
        }
        return (int) Math.min(100, scoreTags + scoreParcours + scorePoste + scorePromo);
    }

    private static String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "").replace("\t", "");
    }

    public static String calculerReseau(int refuser, String nomuser) throws Exception {
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            // 1. Profil self
            String idprofilSelf = null, idpromotionSelf = null, idparcoursSelf = null;
            int anneeSelf = 0;
            String nomSelf = nomuser != null ? nomuser : "Moi";
            String prenomSelf = "";

            PreparedStatement psSelf = conn.prepareStatement(
                "SELECT p.idprofil, p.idpromotion, p.idparcours, p.nom, p.prenom, pr.annee "
                + "FROM profil p JOIN promotion pr ON p.idpromotion = pr.idpromotion WHERE p.idutilisateur = ?");
            psSelf.setInt(1, refuser);
            ResultSet rsSelf = psSelf.executeQuery();
            if (rsSelf.next()) {
                idprofilSelf = rsSelf.getString("idprofil");
                idpromotionSelf = rsSelf.getString("idpromotion");
                idparcoursSelf = rsSelf.getString("idparcours");
                anneeSelf = rsSelf.getInt("annee");
                nomSelf = rsSelf.getString("nom");
                prenomSelf = rsSelf.getString("prenom");
            }
            rsSelf.close(); psSelf.close();

            // 2. Tags self
            Set tagsSelf = new HashSet();
            if (idprofilSelf != null) {
                PreparedStatement psT = conn.prepareStatement(
                    "SELECT idspecialite FROM specialiteprofil WHERE idprofil = ? AND etat = 1");
                psT.setString(1, idprofilSelf);
                ResultSet rsT = psT.executeQuery();
                while (rsT.next()) tagsSelf.add(rsT.getString("idspecialite"));
                rsT.close(); psT.close();
            }

            // 3. Poste self
            String idposteSelf = null;
            if (idprofilSelf != null) {
                PreparedStatement psP = conn.prepareStatement(
                    "SELECT idposte FROM experience WHERE idprofil = ? AND etat = 1 ORDER BY fin DESC LIMIT 1");
                psP.setString(1, idprofilSelf);
                ResultSet rsP = psP.executeQuery();
                if (rsP.next()) idposteSelf = rsP.getString("idposte");
                rsP.close(); psP.close();
            }

            // 4. Autres profils (max 20)
            PreparedStatement psOthers = conn.prepareStatement(
                "SELECT p.idprofil, p.nom, p.prenom, p.idpromotion, p.idparcours, "
                + "p.idutilisateur, pr.annee FROM profil p "
                + "JOIN promotion pr ON p.idpromotion = pr.idpromotion WHERE p.idutilisateur != ? LIMIT 20");
            psOthers.setInt(1, refuser);
            ResultSet rsOthers = psOthers.executeQuery();

            List oProfil = new ArrayList(), oNom = new ArrayList(), oPrenom = new ArrayList();
            List oPromotion = new ArrayList(), oParcours = new ArrayList();
            List oUser = new ArrayList(), oAnnee = new ArrayList();

            while (rsOthers.next()) {
                oProfil.add(rsOthers.getString("idprofil"));
                oNom.add(rsOthers.getString("nom"));
                oPrenom.add(rsOthers.getString("prenom"));
                oPromotion.add(rsOthers.getString("idpromotion"));
                oParcours.add(rsOthers.getString("idparcours"));
                oUser.add(new Integer(rsOthers.getInt("idutilisateur")));
                oAnnee.add(new Integer(rsOthers.getInt("annee")));
            }
            rsOthers.close(); psOthers.close();

            // 5. Tags batch
            Map tagsMap = new HashMap();
            if (!oProfil.isEmpty()) {
                StringBuilder inBuf = new StringBuilder();
                for (int i = 0; i < oProfil.size(); i++) {
                    if (i > 0) inBuf.append(",");
                    inBuf.append("'").append(((String) oProfil.get(i)).replace("'", "''")).append("'");
                }
                Statement st = conn.createStatement();
                ResultSet rsT = st.executeQuery(
                    "SELECT idprofil, idspecialite FROM specialiteprofil WHERE etat = 1 AND idprofil IN (" + inBuf + ")");
                while (rsT.next()) {
                    String pid = rsT.getString("idprofil");
                    if (!tagsMap.containsKey(pid)) tagsMap.put(pid, new HashSet());
                    ((Set) tagsMap.get(pid)).add(rsT.getString("idspecialite"));
                }
                rsT.close(); st.close();
            }

            // 6. Postes batch
            Map posteMap = new HashMap();
            if (!oProfil.isEmpty()) {
                StringBuilder inBuf = new StringBuilder();
                for (int i = 0; i < oProfil.size(); i++) {
                    if (i > 0) inBuf.append(",");
                    inBuf.append("'").append(((String) oProfil.get(i)).replace("'", "''")).append("'");
                }
                Statement st = conn.createStatement();
                ResultSet rsP = st.executeQuery(
                    "SELECT DISTINCT ON (idprofil) idprofil, idposte FROM experience "
                    + "WHERE etat = 1 AND idprofil IN (" + inBuf + ") ORDER BY idprofil, fin DESC");
                while (rsP.next()) posteMap.put(rsP.getString("idprofil"), rsP.getString("idposte"));
                rsP.close(); st.close();
            }

            // 7. Libelles specialites
            Map specLib = new HashMap();
            {
                Statement st = conn.createStatement();
                ResultSet rsS = st.executeQuery("SELECT idspecialite, libelle FROM specialite");
                while (rsS.next()) specLib.put(rsS.getString("idspecialite"), rsS.getString("libelle"));
                rsS.close(); st.close();
            }

            // 8. Calcul scores
            final int[] scores = new int[oProfil.size()];
            for (int i = 0; i < oProfil.size(); i++) {
                Set tagsOther = tagsMap.containsKey(oProfil.get(i)) ? (Set) tagsMap.get(oProfil.get(i)) : new HashSet();
                String idposteOther = (String) posteMap.get(oProfil.get(i));
                scores[i] = calculerScore(
                    tagsSelf, idparcoursSelf, idposteSelf, anneeSelf,
                    tagsOther, (String) oParcours.get(i), idposteOther, ((Integer) oAnnee.get(i)).intValue());
            }

            Integer[] idx = new Integer[oProfil.size()];
            for (int i = 0; i < idx.length; i++) idx[i] = new Integer(i);
            Arrays.sort(idx, new Comparator() {
                public int compare(Object a, Object b) {
                    return scores[((Integer) b).intValue()] - scores[((Integer) a).intValue()];
                }
            });

            // 9. JSON
            StringBuilder jNodes = new StringBuilder();
            StringBuilder jEdges = new StringBuilder();

            jNodes.append("{\"id\":").append(refuser);
            jNodes.append(",\"idprofil\":\"").append(ej(idprofilSelf != null ? idprofilSelf : "")).append("\"");
            jNodes.append(",\"nom\":\"").append(ej(nomSelf)).append("\"");
            jNodes.append(",\"prenom\":\"").append(ej(prenomSelf)).append("\"");
            jNodes.append(",\"idparcours\":\"").append(ej(idparcoursSelf != null ? idparcoursSelf : "")).append("\"");
            jNodes.append(",\"score\":100,\"isSelf\":true,\"tags\":[");
            boolean ft = true;
            Iterator itTags = tagsSelf.iterator();
            while (itTags.hasNext()) {
                String t = (String) itTags.next();
                if (!ft) jNodes.append(",");
                jNodes.append("\"").append(ej(specLib.containsKey(t) ? (String) specLib.get(t) : t)).append("\"");
                ft = false;
            }
            jNodes.append("]}");

            int edgeIdx = 0;
            for (int ki = 0; ki < idx.length; ki++) {
                int i = idx[ki].intValue();
                String pid = (String) oProfil.get(i);
                int score = scores[i];
                String pidParc = (String) oParcours.get(i);
                int idU = ((Integer) oUser.get(i)).intValue();

                Set tagsOther = tagsMap.containsKey(pid) ? (Set) tagsMap.get(pid) : new HashSet();
                Set inter = new HashSet(tagsSelf);
                inter.retainAll(tagsOther);

                List commonLibs = new ArrayList();
                Iterator itInter = inter.iterator();
                while (itInter.hasNext()) {
                    String t = (String) itInter.next();
                    commonLibs.add(specLib.containsKey(t) ? specLib.get(t) : t);
                }

                jNodes.append(",{\"id\":").append(idU);
                jNodes.append(",\"idprofil\":\"").append(ej(pid)).append("\"");
                jNodes.append(",\"nom\":\"").append(ej((String) oNom.get(i))).append("\"");
                jNodes.append(",\"prenom\":\"").append(ej((String) oPrenom.get(i))).append("\"");
                jNodes.append(",\"idparcours\":\"").append(ej(pidParc != null ? pidParc : "")).append("\"");
                jNodes.append(",\"score\":").append(score);
                jNodes.append(",\"isSelf\":false,\"tags\":[");
                for (int ti = 0; ti < commonLibs.size(); ti++) {
                    if (ti > 0) jNodes.append(",");
                    jNodes.append("\"").append(ej((String) commonLibs.get(ti))).append("\"");
                }
                jNodes.append("]}");

                if (score >= 20 || !inter.isEmpty()) {
                    if (edgeIdx > 0) jEdges.append(",");
                    jEdges.append("{\"from\":").append(refuser)
                          .append(",\"to\":").append(idU)
                          .append(",\"score\":").append(score).append("}");
                    edgeIdx++;
                }
            }

            return "{\"success\":true,\"selfId\":" + refuser
                + ",\"nodes\":[" + jNodes + "],\"edges\":[" + jEdges + "]}";
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
