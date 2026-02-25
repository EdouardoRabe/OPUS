<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.ExperienceLib" %>
<%@ page import="alumni.Specialiteprofil" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%!
    private String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
%>
<%
    // Parametres de recherche
    String qNom        = request.getParameter("nom");
    String qPromotion  = request.getParameter("promotion");
    String qParcours   = request.getParameter("parcours");
    String qSpecialite = request.getParameter("specialite");
    String qEntreprise = request.getParameter("entreprise");
    String qPoste      = request.getParameter("poste");
    String qAnnee      = request.getParameter("annee");
    String pageParam   = request.getParameter("page");

    int pageNum  = 1;
    int pageSize = 12;
    if (pageParam != null) {
        try { pageNum = Integer.parseInt(pageParam); } catch (Exception e) {}
    }
    if (pageNum < 1) pageNum = 1;

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        // Construction du filtre SQL sur la vue profillib
        StringBuilder where = new StringBuilder();
        where.append(" and nom IS NOT NULL and estactif = 1"); // exclure les utilisateurs sans profil ou inactifs

        if (qNom != null && !qNom.trim().isEmpty()) {
            String safe = qNom.trim().replace("'", "''").toLowerCase();
            where.append(" and (LOWER(nom) LIKE '%").append(safe).append("%'")
                 .append(" OR LOWER(prenom) LIKE '%").append(safe).append("%')");
        }

        if (qPromotion != null && !qPromotion.trim().isEmpty()) {
            String safe = qPromotion.trim().replace("'", "''");
            where.append(" and idpromotion = '").append(safe).append("'");
        }

        if (qParcours != null && !qParcours.trim().isEmpty()) {
            String safe = qParcours.trim().replace("'", "''");
            where.append(" and idparcours = '").append(safe).append("'");
        }

        if (qAnnee != null && !qAnnee.trim().isEmpty()) {
            try {
                int annee = Integer.parseInt(qAnnee.trim());
                where.append(" and promotionannee = ").append(annee);
            } catch (Exception e) {}
        }

        where.append(" order by nom, prenom");

        // Recherche des profils
        ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(
            new ProfilLib(), null, null, conn, where.toString()
        );
        if (allProfils == null) allProfils = new ProfilLib[0];

        // Filtrage supplementaire par entreprise/poste (via experiences)
        List filteredList = new ArrayList();
        
        // Si filtre entreprise ou poste, on charge les experiences
        Map experienceMap = new HashMap(); // idprofil -> derniereExperience
        boolean needExpFilter = (qEntreprise != null && !qEntreprise.trim().isEmpty())
                             || (qPoste != null && !qPoste.trim().isEmpty());

        for (int i = 0; i < allProfils.length; i++) {
            ProfilLib p = allProfils[i];
            if (p.getIdprofil() == null) continue;

            // Charger la derniere experience de ce profil
            try {
                ExperienceLib[] exps = (ExperienceLib[]) CGenUtil.rechercher(
                    new ExperienceLib(), null, null, conn,
                    " and idutilisateur=" + p.getRefuser() + " order by debut desc"
                );
                if (exps != null && exps.length > 0) {
                    experienceMap.put(p.getIdprofil(), exps[0]);
                }
            } catch (Exception ex) {}

            if (needExpFilter) {
                ExperienceLib exp = (ExperienceLib) experienceMap.get(p.getIdprofil());
                if (exp == null) continue;

                if (qEntreprise != null && !qEntreprise.trim().isEmpty()) {
                    if (exp.getEntreprise() == null || 
                        !exp.getEntreprise().toLowerCase().contains(qEntreprise.trim().toLowerCase())) {
                        continue;
                    }
                }
                if (qPoste != null && !qPoste.trim().isEmpty()) {
                    if (exp.getPostelib() == null || 
                        !exp.getPostelib().toLowerCase().contains(qPoste.trim().toLowerCase())) {
                        continue;
                    }
                }
            }

            filteredList.add(p);
        }

        // Filtrage par specialite
        if (qSpecialite != null && !qSpecialite.trim().isEmpty()) {
            String specId = qSpecialite.trim().replace("'", "''");
            List specFiltered = new ArrayList();
            for (int i = 0; i < filteredList.size(); i++) {
                ProfilLib p = (ProfilLib) filteredList.get(i);
                try {
                    Specialiteprofil sp = new Specialiteprofil();
                    sp.setIdprofil(p.getIdprofil());
                    sp.setIdspecialite(specId);
                    Specialiteprofil[] found = (Specialiteprofil[]) CGenUtil.rechercher(
                        sp, null, null, conn, ""
                    );
                    if (found != null && found.length > 0) {
                        specFiltered.add(p);
                    }
                } catch (Exception ex) {}
            }
            filteredList = specFiltered;
        }

        // Pagination
        int total = filteredList.size();
        int totalPages = (int) Math.ceil((double) total / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (pageNum > totalPages) pageNum = totalPages;
        int start = (pageNum - 1) * pageSize;
        int end = Math.min(start + pageSize, total);

        // Charger les specialites pour chaque profil de la page
        Map specialiteMap = new HashMap(); // idprofil -> "Spec1, Spec2"

        // Construction JSON
        String ctx = request.getContextPath();
        StringBuilder sb = new StringBuilder("[");
        int count = 0;
        for (int i = start; i < end; i++) {
            ProfilLib p = (ProfilLib) filteredList.get(i);

            // Charger specialites
            String specs = "";
            try {
                Specialiteprofil spf = new Specialiteprofil();
                spf.setIdprofil(p.getIdprofil());
                Specialiteprofil[] spArr = (Specialiteprofil[]) CGenUtil.rechercher(
                    spf, null, null, conn, ""
                );
                if (spArr != null) {
                    StringBuilder specNames = new StringBuilder();
                    for (int s = 0; s < spArr.length && s < 3; s++) {
                        try {
                            Specialite spec = new Specialite();
                            spec.setIdspecialite(spArr[s].getIdspecialite());
                            Specialite[] specRes = (Specialite[]) CGenUtil.rechercher(
                                spec, null, null, conn, ""
                            );
                            if (specRes != null && specRes.length > 0) {
                                if (specNames.length() > 0) specNames.append(", ");
                                specNames.append(specRes[0].getLibelle());
                            }
                        } catch (Exception ex) {}
                    }
                    specs = specNames.toString();
                }
            } catch (Exception ex) {}

            // Derniere experience
            ExperienceLib lastExp = (ExperienceLib) experienceMap.get(p.getIdprofil());
            String expEntreprise = "";
            String expPoste = "";
            if (lastExp != null) {
                expEntreprise = lastExp.getEntreprise() != null ? lastExp.getEntreprise() : "";
                expPoste = lastExp.getPostelib() != null ? lastExp.getPostelib() : "";
            }

            // Photo URL
            String photoUrl = "";
            if (p.getPhotoProfil() != null && !p.getPhotoProfil().isEmpty()) {
                photoUrl = ctx + "/" + p.getPhotoProfil();
            }

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

        out.print("{\"success\":true,\"total\":" + total 
            + ",\"page\":" + pageNum 
            + ",\"totalPages\":" + totalPages 
            + ",\"resultats\":" + sb.toString() + "}");

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>