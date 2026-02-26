<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%!
    // -----------------------------------------------------------------------
    // MODULE 1 : CALCUL DE COMPATIBILITE
    // -----------------------------------------------------------------------
    // Ponderation : tags=50, parcours=20, poste=15, promotion=15
    // Score borne 0-100

    private int calculerScore(
            Set<String> tagsSelf,   String idparcoursSelf, String idposteSelf, int anneeSelf,
            Set<String> tagsOther,  String idparcoursOther, String idposteOther, int anneeOther) {

        // --- critere 1 : tags / specialites (Jaccard * 50) ---
        double scoreTags = 0;
        Set<String> union = new HashSet<String>(tagsSelf);
        union.addAll(tagsOther);
        if (!union.isEmpty()) {
            Set<String> inter = new HashSet<String>(tagsSelf);
            inter.retainAll(tagsOther);
            scoreTags = ((double) inter.size() / union.size()) * 50.0;
        }

        // --- critere 2 : parcours / secteur (meme = 20) ---
        double scoreParcours = 0;
        if (idparcoursSelf != null && idparcoursSelf.equals(idparcoursOther)) {
            scoreParcours = 20.0;
        }

        // --- critere 3 : poste / role (meme = 15) ---
        double scorePoste = 0;
        if (idposteSelf != null && idposteSelf.equals(idposteOther)) {
            scorePoste = 15.0;
        }

        // --- critere 4 : promotion / annee (ecart faible = plus de points) ---
        double scorePromo = 0;
        if (anneeSelf > 0 && anneeOther > 0) {
            int diff = Math.abs(anneeSelf - anneeOther);
            if      (diff == 0) scorePromo = 15.0;
            else if (diff <= 1) scorePromo = 12.0;
            else if (diff <= 3) scorePromo = 8.0;
            else if (diff <= 5) scorePromo = 3.0;
        }

        int total = (int) Math.min(100, scoreTags + scoreParcours + scorePoste + scorePromo);
        return total;
    }

    private String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "").replace("\t", "");
    }
%>
<%
    try {
        UserEJB uR = (UserEJB) session.getAttribute("u");
        if (uR == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }
        MapUtilisateur mapR = uR.getUser();
        int refuserConnecte = mapR.getRefuser();

        Connection conn = new UtilDB().GetConn();
        try {

            // ================================================================
            // 1. Profil de l'utilisateur connecte
            // ================================================================
            String idprofilSelf = null;
            String idpromotionSelf = null;
            String idparcoursSelf = null;
            int    anneeSelf      = 0;
            String nomSelf        = mapR.getNomuser() != null ? mapR.getNomuser() : "Moi";
            String prenomSelf     = "";

            PreparedStatement psSelf = conn.prepareStatement(
                "SELECT p.idprofil, p.idpromotion, p.idparcours, p.nom, p.prenom, pr.annee " +
                "FROM profil p " +
                "JOIN promotion pr ON p.idpromotion = pr.idpromotion " +
                "WHERE p.idutilisateur = ?");
            psSelf.setInt(1, refuserConnecte);
            ResultSet rsSelf = psSelf.executeQuery();
            if (rsSelf.next()) {
                idprofilSelf    = rsSelf.getString("idprofil");
                idpromotionSelf = rsSelf.getString("idpromotion");
                idparcoursSelf  = rsSelf.getString("idparcours");
                anneeSelf       = rsSelf.getInt("annee");
                nomSelf         = rsSelf.getString("nom");
                prenomSelf      = rsSelf.getString("prenom");
            }
            rsSelf.close(); psSelf.close();

            // ================================================================
            // 2. Tags (specialites actives) de l'utilisateur connecte
            // ================================================================
            Set<String> tagsSelf = new HashSet<String>();
            if (idprofilSelf != null) {
                PreparedStatement psT = conn.prepareStatement(
                    "SELECT idspecialite FROM specialiteprofil WHERE idprofil = ? AND etat = 1");
                psT.setString(1, idprofilSelf);
                ResultSet rsT = psT.executeQuery();
                while (rsT.next()) tagsSelf.add(rsT.getString("idspecialite"));
                rsT.close(); psT.close();
            }

            // ================================================================
            // 3. Dernier poste de l'utilisateur connecte
            // ================================================================
            String idposteSelf = null;
            if (idprofilSelf != null) {
                PreparedStatement psP = conn.prepareStatement(
                    "SELECT idposte FROM experience " +
                    "WHERE idprofil = ? AND etat = 1 " +
                    "ORDER BY fin DESC LIMIT 1");
                psP.setString(1, idprofilSelf);
                ResultSet rsP = psP.executeQuery();
                if (rsP.next()) idposteSelf = rsP.getString("idposte");
                rsP.close(); psP.close();
            }

            // ================================================================
            // 4. Charger les autres profils (max 20 — MODULE 6 : limite perf)
            // ================================================================
            PreparedStatement psOthers = conn.prepareStatement(
                "SELECT p.idprofil, p.nom, p.prenom, p.idpromotion, p.idparcours, " +
                "       p.idutilisateur, pr.annee " +
                "FROM profil p " +
                "JOIN promotion pr ON p.idpromotion = pr.idpromotion " +
                "WHERE p.idutilisateur != ? " +
                "LIMIT 20");
            psOthers.setInt(1, refuserConnecte);
            ResultSet rsOthers = psOthers.executeQuery();

            // Stocker les infos dans des listes paralleles pour traitement
            List<String>  oProfil     = new ArrayList<String>();
            List<String>  oNom        = new ArrayList<String>();
            List<String>  oPrenom     = new ArrayList<String>();
            List<String>  oPromotion  = new ArrayList<String>();
            List<String>  oParcours   = new ArrayList<String>();
            List<Integer> oUser       = new ArrayList<Integer>();
            List<Integer> oAnnee      = new ArrayList<Integer>();

            while (rsOthers.next()) {
                oProfil    .add(rsOthers.getString("idprofil"));
                oNom       .add(rsOthers.getString("nom"));
                oPrenom    .add(rsOthers.getString("prenom"));
                oPromotion .add(rsOthers.getString("idpromotion"));
                oParcours  .add(rsOthers.getString("idparcours"));
                oUser      .add(rsOthers.getInt("idutilisateur"));
                oAnnee     .add(rsOthers.getInt("annee"));
            }
            rsOthers.close(); psOthers.close();

            // ================================================================
            // 5. Charger en batch les tags de tous les autres profils
            // ================================================================
            Map<String, Set<String>> tagsMap = new HashMap<String, Set<String>>();
            if (!oProfil.isEmpty()) {
                StringBuilder inBuf = new StringBuilder();
                for (int i = 0; i < oProfil.size(); i++) {
                    if (i > 0) inBuf.append(",");
                    inBuf.append("'").append(oProfil.get(i).replace("'", "''")).append("'");
                }
                Statement st = conn.createStatement();
                ResultSet rsT = st.executeQuery(
                    "SELECT idprofil, idspecialite FROM specialiteprofil " +
                    "WHERE etat = 1 AND idprofil IN (" + inBuf + ")");
                while (rsT.next()) {
                    String pid = rsT.getString("idprofil");
                    if (!tagsMap.containsKey(pid)) tagsMap.put(pid, new HashSet<String>());
                    tagsMap.get(pid).add(rsT.getString("idspecialite"));
                }
                rsT.close(); st.close();
            }

            // ================================================================
            // 6. Charger en batch le poste le plus recent par profil
            // ================================================================
            Map<String, String> posteMap = new HashMap<String, String>();
            if (!oProfil.isEmpty()) {
                StringBuilder inBuf = new StringBuilder();
                for (int i = 0; i < oProfil.size(); i++) {
                    if (i > 0) inBuf.append(",");
                    inBuf.append("'").append(oProfil.get(i).replace("'", "''")).append("'");
                }
                Statement st = conn.createStatement();
                // DISTINCT ON = PostgreSQL : 1 ligne par profil ordonnee par fin DESC
                ResultSet rsP = st.executeQuery(
                    "SELECT DISTINCT ON (idprofil) idprofil, idposte " +
                    "FROM experience " +
                    "WHERE etat = 1 AND idprofil IN (" + inBuf + ") " +
                    "ORDER BY idprofil, fin DESC");
                while (rsP.next()) posteMap.put(rsP.getString("idprofil"), rsP.getString("idposte"));
                rsP.close(); st.close();
            }

            // ================================================================
            // 7. Charger les libelles de specialites (pour tooltip)
            // ================================================================
            Map<String, String> specLib = new HashMap<String, String>();
            {
                Statement st = conn.createStatement();
                ResultSet rsS = st.executeQuery("SELECT idspecialite, libelle FROM specialite");
                while (rsS.next()) specLib.put(rsS.getString("idspecialite"), rsS.getString("libelle"));
                rsS.close(); st.close();
            }

            // ================================================================
            // 8. Calcul des scores — MODULE 1
            //    Tri des 20 plus compatibles — MODULE 6
            // ================================================================

            // Paires (score, index) tries par score desc
            int[] scores = new int[oProfil.size()];
            for (int i = 0; i < oProfil.size(); i++) {
                Set<String> tagsOther  = tagsMap.containsKey(oProfil.get(i)) ? tagsMap.get(oProfil.get(i)) : new HashSet<String>();
                String idposteOther    = posteMap.get(oProfil.get(i));
                scores[i] = calculerScore(
                    tagsSelf,  idparcoursSelf, idposteSelf, anneeSelf,
                    tagsOther, oParcours.get(i), idposteOther, oAnnee.get(i));
            }

            // Trier indices par score decroissant
            Integer[] idx = new Integer[oProfil.size()];
            for (int i = 0; i < idx.length; i++) idx[i] = i;
            Arrays.sort(idx, new Comparator<Integer>() {
                @Override public int compare(Integer a, Integer b) { return scores[b] - scores[a]; }
            });

            // ================================================================
            // 9. Construire la reponse JSON
            // ================================================================
            StringBuilder jNodes = new StringBuilder();
            StringBuilder jEdges = new StringBuilder();

            // --- Noeud self ---
            jNodes.append("{");
            jNodes.append("\"id\":").append(refuserConnecte);
            jNodes.append(",\"idprofil\":\"").append(ej(idprofilSelf != null ? idprofilSelf : "")).append("\"");
            jNodes.append(",\"nom\":\"").append(ej(nomSelf)).append("\"");
            jNodes.append(",\"prenom\":\"").append(ej(prenomSelf)).append("\"");
            jNodes.append(",\"idparcours\":\"").append(ej(idparcoursSelf != null ? idparcoursSelf : "")).append("\"");
            jNodes.append(",\"score\":100");
            jNodes.append(",\"isSelf\":true");
            jNodes.append(",\"tags\":[");
            boolean ft = true;
            for (String t : tagsSelf) {
                if (!ft) jNodes.append(",");
                jNodes.append("\"").append(ej(specLib.containsKey(t) ? specLib.get(t) : t)).append("\"");
                ft = false;
            }
            jNodes.append("]}");

            int edgeIdx = 0;
            for (int ki = 0; ki < idx.length; ki++) {
                int i = idx[ki];
                String pid       = oProfil.get(i);
                int    score     = scores[i];
                String pidParc   = oParcours.get(i);
                int    idU       = oUser.get(i);

                // Tags communs pour le tooltip
                Set<String> tagsOther = tagsMap.containsKey(pid) ? tagsMap.get(pid) : new HashSet<String>();
                Set<String> inter = new HashSet<String>(tagsSelf);
                inter.retainAll(tagsOther);

                List<String> commonLibs = new ArrayList<String>();
                for (String t : inter) {
                    commonLibs.add(specLib.containsKey(t) ? specLib.get(t) : t);
                }

                jNodes.append(",{");
                jNodes.append("\"id\":").append(idU);
                jNodes.append(",\"idprofil\":\"").append(ej(pid)).append("\"");
                jNodes.append(",\"nom\":\"").append(ej(oNom.get(i))).append("\"");
                jNodes.append(",\"prenom\":\"").append(ej(oPrenom.get(i))).append("\"");
                jNodes.append(",\"idparcours\":\"").append(ej(pidParc != null ? pidParc : "")).append("\"");
                jNodes.append(",\"score\":").append(score);
                jNodes.append(",\"isSelf\":false");
                jNodes.append(",\"tags\":[");
                for (int ti = 0; ti < commonLibs.size(); ti++) {
                    if (ti > 0) jNodes.append(",");
                    jNodes.append("\"").append(ej(commonLibs.get(ti))).append("\"");
                }
                jNodes.append("]}");

                // Edge si score >= 20 ou tag en commun (Option B/A hybride — MODULE 3)
                if (score >= 20 || !inter.isEmpty()) {
                    if (edgeIdx > 0) jEdges.append(",");
                    jEdges.append("{\"from\":").append(refuserConnecte)
                          .append(",\"to\":").append(idU)
                          .append(",\"score\":").append(score).append("}");
                    edgeIdx++;
                }
            }

            out.print("{\"success\":true"
                    + ",\"selfId\":"  + refuserConnecte
                    + ",\"nodes\":["  + jNodes + "]"
                    + ",\"edges\":["  + jEdges + "]}");

        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"","'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
