package alumni;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour la recherche dans l'annuaire.
 * Gere sa propre connexion.
 */
public class AnnuaireService {

    private static String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }

    public static String rechercher(String qNom, String qPromotion, String qParcours,
            String qSpecialite, String qEntreprise, String qPoste, String qAnnee,
            String pageParam, String contextPath) throws Exception {

        int pageNum = 1, pageSize = 12;
        if (pageParam != null) {
            try { pageNum = Integer.parseInt(pageParam); } catch (Exception e) {}
        }
        if (pageNum < 1) pageNum = 1;

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            StringBuilder where = new StringBuilder();
            where.append(" and nom IS NOT NULL and estactif = 1");

            if (qNom != null && !qNom.trim().isEmpty()) {
                String safe = qNom.trim().replace("'", "''").toLowerCase();
                where.append(" and (LOWER(COALESCE(nom,'') || ' ' || COALESCE(prenom,'')) LIKE '%").append(safe).append("%'")
                     .append(" OR LOWER(COALESCE(prenom,'') || ' ' || COALESCE(nom,'')) LIKE '%").append(safe).append("%')");
            }
            if (qPromotion != null && !qPromotion.trim().isEmpty())
                where.append(" and idpromotion = '").append(qPromotion.trim().replace("'", "''")).append("'");
            if (qParcours != null && !qParcours.trim().isEmpty())
                where.append(" and idparcours = '").append(qParcours.trim().replace("'", "''")).append("'");
            if (qAnnee != null && !qAnnee.trim().isEmpty()) {
                try { where.append(" and promotionannee = ").append(Integer.parseInt(qAnnee.trim())); } catch (Exception e) {}
            }
            where.append(" order by nom, prenom");

            ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, conn, where.toString());
            if (allProfils == null) allProfils = new ProfilLib[0];

            List filteredList = new ArrayList();
            Map experienceMap = new HashMap();
            boolean needExpFilter = (qEntreprise != null && !qEntreprise.trim().isEmpty())
                                 || (qPoste != null && !qPoste.trim().isEmpty());

            for (int i = 0; i < allProfils.length; i++) {
                ProfilLib p = allProfils[i];
                if (p.getIdprofil() == null) continue;
                try {
                    ExperienceLib[] exps = (ExperienceLib[]) CGenUtil.rechercher(
                        new ExperienceLib(), null, null, conn,
                        " and idutilisateur=" + p.getRefuser() + " order by debut desc");
                    if (exps != null && exps.length > 0) experienceMap.put(p.getIdprofil(), exps[0]);
                } catch (Exception ex) {}

                if (needExpFilter) {
                    ExperienceLib exp = (ExperienceLib) experienceMap.get(p.getIdprofil());
                    if (exp == null) continue;
                    if (qEntreprise != null && !qEntreprise.trim().isEmpty()) {
                        if (exp.getEntreprise() == null || !exp.getEntreprise().toLowerCase().contains(qEntreprise.trim().toLowerCase()))
                            continue;
                    }
                    if (qPoste != null && !qPoste.trim().isEmpty()) {
                        if (exp.getPostelib() == null || !exp.getPostelib().toLowerCase().contains(qPoste.trim().toLowerCase()))
                            continue;
                    }
                }
                filteredList.add(p);
            }

            // Filtre specialite
            if (qSpecialite != null && !qSpecialite.trim().isEmpty()) {
                String specId = qSpecialite.trim().replace("'", "''");
                List specFiltered = new ArrayList();
                for (int i = 0; i < filteredList.size(); i++) {
                    ProfilLib p = (ProfilLib) filteredList.get(i);
                    try {
                        Specialiteprofil sp = new Specialiteprofil();
                        sp.setIdprofil(p.getIdprofil());
                        sp.setIdspecialite(specId);
                        Specialiteprofil[] found = (Specialiteprofil[]) CGenUtil.rechercher(sp, null, null, conn, "");
                        if (found != null && found.length > 0) specFiltered.add(p);
                    } catch (Exception ex) {}
                }
                filteredList = specFiltered;
            }

            int total = filteredList.size();
            int totalPages = (int) Math.ceil((double) total / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (pageNum > totalPages) pageNum = totalPages;
            int start = (pageNum - 1) * pageSize;
            int end = Math.min(start + pageSize, total);

            StringBuilder sb = new StringBuilder("[");
            int count = 0;
            for (int i = start; i < end; i++) {
                ProfilLib p = (ProfilLib) filteredList.get(i);
                String specs = "";
                try {
                    Specialiteprofil spf = new Specialiteprofil();
                    spf.setIdprofil(p.getIdprofil());
                    Specialiteprofil[] spArr = (Specialiteprofil[]) CGenUtil.rechercher(spf, null, null, conn, "");
                    if (spArr != null) {
                        StringBuilder specNames = new StringBuilder();
                        for (int s = 0; s < spArr.length && s < 3; s++) {
                            try {
                                Specialite spec = new Specialite();
                                spec.setIdspecialite(spArr[s].getIdspecialite());
                                Specialite[] specRes = (Specialite[]) CGenUtil.rechercher(spec, null, null, conn, "");
                                if (specRes != null && specRes.length > 0) {
                                    if (specNames.length() > 0) specNames.append(", ");
                                    specNames.append(specRes[0].getLibelle());
                                }
                            } catch (Exception ex) {}
                        }
                        specs = specNames.toString();
                    }
                } catch (Exception ex) {}

                ExperienceLib lastExp = (ExperienceLib) experienceMap.get(p.getIdprofil());
                String expEntreprise = "", expPoste = "";
                if (lastExp != null) {
                    expEntreprise = lastExp.getEntreprise() != null ? lastExp.getEntreprise() : "";
                    expPoste = lastExp.getPostelib() != null ? lastExp.getPostelib() : "";
                }
                String photoUrl = "";
                if (p.getPhotoProfil() != null && !p.getPhotoProfil().isEmpty())
                    photoUrl = contextPath + "/" + p.getPhotoProfil();

                if (count > 0) sb.append(",");
                sb.append("{");
                sb.append("\"idprofil\":\"").append(ej(p.getIdprofil())).append("\"");
                sb.append(",\"nom\":\"").append(ej(p.getNom())).append("\"");
                sb.append(",\"prenom\":\"").append(ej(p.getPrenom())).append("\"");
                sb.append(",\"email\":\"").append(ej(p.getEmail())).append("\"");
                sb.append(",\"telephone\":\"").append(ej(p.getTelephone())).append("\"");
                sb.append(",\"promotion\":\"").append(ej(p.getPromotionLib())).append("\"");
                sb.append(",\"annee\":").append(p.getPromotionAnnee());
                sb.append(",\"parcours\":\"").append(ej(p.getParcoursLib())).append("\"");
                sb.append(",\"photo\":\"").append(ej(photoUrl)).append("\"");
                sb.append(",\"specialites\":\"").append(ej(specs)).append("\"");
                sb.append(",\"entreprise\":\"").append(ej(expEntreprise)).append("\"");
                sb.append(",\"poste\":\"").append(ej(expPoste)).append("\"");
                sb.append(",\"refuser\":").append(p.getRefuser());
                sb.append("}");
                count++;
            }
            sb.append("]");

            return "{\"success\":true,\"total\":" + total
                + ",\"page\":" + pageNum
                + ",\"totalPages\":" + totalPages
                + ",\"resultats\":" + sb.toString() + "}";
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
