<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="alumni.Commentairereaction" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.Profil" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%!
    // Echapper pour JSON
    private String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
%>
<%
    // AJAX GET: Charger les commentaires d'une publication (100% APJ)
    // Utilise CGenUtil.rechercher pour TOUT: commentaires, reactions, noms utilisateurs

    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        String idpub = request.getParameter("idpublication");
        if (idpub == null) {
            out.print("{\"success\":false,\"error\":\"Parametre idpublication manquant\"}");
            return;
        }

        int refuser = u.getUser().getRefuser();
        Connection conn = new UtilDB().GetConn();

        try {
            // --- APJ: Types de reaction ---
            Reactiontype[] rTypes = (Reactiontype[]) CGenUtil.rechercher(
                new Reactiontype(), null, null, conn, " order by idreactiontype");
            if (rTypes == null) rTypes = new Reactiontype[0];

            StringBuilder sbRT = new StringBuilder("[");
            for (int i = 0; i < rTypes.length; i++) {
                if (i > 0) sbRT.append(",");
                sbRT.append("{\"id\":\"").append(ej(rTypes[i].getIdreactiontype())).append("\"");
                sbRT.append(",\"libelle\":\"").append(ej(rTypes[i].getLibelle())).append("\"}");
            }
            sbRT.append("]");

            // --- APJ: Tous les profils pour lookup noms + photos ---
            alumni.ProfilLib[] allProfils = (alumni.ProfilLib[]) CGenUtil.rechercher(
                new alumni.ProfilLib(), null, null, conn, "");
            Map userNames = new HashMap();
            Map userPhotos = new HashMap();
            Map userProfils = new HashMap();
            Map userBanned = new HashMap();
            if (allProfils != null) {
                for (int i = 0; i < allProfils.length; i++) {
                    Integer _key = new Integer(allProfils[i].getIdutilisateur());
                    userNames.put(_key, allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                    if (allProfils[i].getPhotoProfil() != null && !allProfils[i].getPhotoProfil().trim().isEmpty())
                        userPhotos.put(_key, allProfils[i].getPhotoProfil().trim());
                    if (allProfils[i].getIdprofil() != null)
                        userProfils.put(_key, allProfils[i].getIdprofil());
                    if (allProfils[i].getEstactif() == 0)
                        userBanned.put(_key, Boolean.TRUE);
                }
            }

            // --- APJ: Commentaires de cette publication ---
            Publicationcommentaire[] comms = (Publicationcommentaire[]) CGenUtil.rechercher(
                new Publicationcommentaire(), null, null, conn,
                " and idpublication = '" + idpub + "' and etat = 1 order by idpublicationcommentaire");
            if (comms == null) comms = new Publicationcommentaire[0];

            StringBuilder sbComm = new StringBuilder("[");
            for (int i = 0; i < comms.length; i++) {
                Publicationcommentaire c = comms[i];
                String idcomm = c.getIdpublicationcommentaire();
                String auteur = (String) userNames.get(new Integer(c.getIdutilisateur()));
                if (auteur == null) auteur = "Utilisateur";
                boolean commAuteurBanni = userBanned.containsKey(new Integer(c.getIdutilisateur()));
                if (commAuteurBanni) auteur = "Utilisateur indisponible";

                // --- APJ: Reactions sur ce commentaire ---
                Commentairereaction[] cReacts = (Commentairereaction[]) CGenUtil.rechercher(
                    new Commentairereaction(), null, null, conn,
                    " and idpublicationcommentaire = '" + idcomm + "'");
                if (cReacts == null) cReacts = new Commentairereaction[0];

                // Compter par type + ma reaction
                Map reactMap = new HashMap();
                String myReaction = "";
                for (int r = 0; r < cReacts.length; r++) {
                    String type = cReacts[r].getIdreactiontype();
                    Integer cnt = (Integer) reactMap.get(type);
                    reactMap.put(type, cnt == null ? new Integer(1) : new Integer(cnt.intValue() + 1));
                    if (cReacts[r].getIdutilisateur() == refuser) {
                        myReaction = type;
                    }
                }

                // Créer une liste de paires (id, count) et trier par count décroissant
                java.util.List reactPairs = new java.util.ArrayList();
                for (java.util.Iterator rit = reactMap.entrySet().iterator(); rit.hasNext();) {
                    Map.Entry entry = (Map.Entry) rit.next();
                    Object[] pair = new Object[2];
                    pair[0] = entry.getKey(); // rtId (String)
                    pair[1] = entry.getValue(); // count (Integer)
                    reactPairs.add(pair);
                }
                // Tri à bulles : trier par count décroissant
                for (int ri = 0; ri < reactPairs.size(); ri++) {
                    for (int rj = ri + 1; rj < reactPairs.size(); rj++) {
                        Object[] pairA = (Object[]) reactPairs.get(ri);
                        Object[] pairB = (Object[]) reactPairs.get(rj);
                        Integer countA = (Integer) pairA[1];
                        Integer countB = (Integer) pairB[1];
                        if (countB.intValue() > countA.intValue()) {
                            reactPairs.set(ri, pairB);
                            reactPairs.set(rj, pairA);
                        }
                    }
                }

                // Construire le JSON des reactions avec emojis, trié par count décroissant
                StringBuilder sbReact = new StringBuilder("[");
                boolean firstR = true;
                for (int rpi = 0; rpi < reactPairs.size(); rpi++) {
                    Object[] pair = (Object[]) reactPairs.get(rpi);
                    String rtId = (String) pair[0];
                    Integer rtCount = (Integer) pair[1];
                    
                    // Récupérer l'emoji du type de réaction
                    String rtEmoji = "\uD83D\uDC4D";
                    String rtLib = "";
                    for (int rt = 0; rt < rTypes.length; rt++) {
                        if (rTypes[rt].getIdreactiontype().equals(rtId)) {
                            rtLib = rTypes[rt].getLibelle();
                            String rtLibLow = rtLib.toLowerCase();
                            if (rtLibLow.contains("adore") || rtLibLow.contains("love")) rtEmoji = "\u2764\uFE0F";
                            else if (rtLibLow.contains("haha") || rtLibLow.contains("humour")) rtEmoji = "\uD83D\uDE02";
                            else if (rtLibLow.contains("surprise") || rtLibLow.contains("wow")) rtEmoji = "\uD83D\uDE2E";
                            else if (rtLibLow.contains("triste") || rtLibLow.contains("sad")) rtEmoji = "\uD83D\uDE22";
                            else if (rtLibLow.contains("grrr") || rtLibLow.contains("ang")) rtEmoji = "\uD83D\uDE20";
                            break;
                        }
                    }
                    
                    if (!firstR) sbReact.append(",");
                    sbReact.append("{\"id\":\"").append(ej(rtId)).append("\"");
                    sbReact.append(",\"emoji\":\"").append(rtEmoji).append("\"");
                    sbReact.append(",\"libelle\":\"").append(ej(rtLib)).append("\"");
                    sbReact.append(",\"count\":").append(rtCount.intValue());
                    sbReact.append("}");
                    firstR = false;
                }
                sbReact.append("]");

                // JSON du commentaire
                if (i > 0) sbComm.append(",");
                sbComm.append("{");
                sbComm.append("\"id\":\"").append(ej(idcomm)).append("\"");
                sbComm.append(",\"description\":\"").append(ej(c.getDescription())).append("\"");
                sbComm.append(",\"auteur\":\"").append(ej(auteur)).append("\"");
                sbComm.append(",\"idutilisateur\":").append(c.getIdutilisateur());
                String _photoPath = commAuteurBanni ? null : (String) userPhotos.get(new Integer(c.getIdutilisateur()));
                sbComm.append(",\"photo\":\"").append(_photoPath != null ? ej(_photoPath) : "").append("\"");
                String _idprofilAuteur = commAuteurBanni ? null : (String) userProfils.get(new Integer(c.getIdutilisateur()));
                sbComm.append(",\"idprofil\":\"").append(_idprofilAuteur != null ? ej(_idprofilAuteur) : "").append("\"");
                String parent = c.getIdpublicationcommentaire_1();
                sbComm.append(",\"idparent\":\"").append(parent != null ? ej(parent) : "").append("\"");
                sbComm.append(",\"reactions\":").append(sbReact.toString());
                sbComm.append(",\"myReaction\":\"").append(ej(myReaction)).append("\"");
                sbComm.append(",\"banned\":").append(commAuteurBanni ? "true" : "false");
                sbComm.append("}");
            }
            sbComm.append("]");

            out.print("{\"success\":true,\"refuser\":" + refuser + ",\"reactionTypes\":" + sbRT.toString()
                + ",\"commentaires\":" + sbComm.toString() + "}");

        } finally {
            if (conn != null) conn.close();
        }

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
