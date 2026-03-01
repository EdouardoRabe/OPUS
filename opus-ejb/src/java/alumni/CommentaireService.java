package alumni;

import java.sql.Connection;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour les commentaires : ajouter un commentaire et charger les commentaires.
 * Chaque methode gere sa propre connexion.
 */
public class CommentaireService {

    private static String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }

    /* ======== COMMENTER (+ mentions + notifications) ======== */
    public static String commenter(int refuser, String idpublication, String description,
                                   String idparent, String mentionsParam) throws Exception {
        if (idpublication == null || description == null || description.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Parametres manquants\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Publicationcommentaire comm = new Publicationcommentaire();
            comm.setDescription(description.trim());
            comm.setEtat(1);
            comm.setIdutilisateur(Integer.parseInt(userId));
            comm.setIdpublication(idpublication);
            if (idparent != null && !idparent.trim().isEmpty())
                comm.setIdpublicationcommentaire_1(idparent.trim());

            comm.construirePK(conn);
            comm.insertToTableWithHisto(userId, conn);

            String newId = comm.getIdpublicationcommentaire();
            String lien = "module.jsp?but=accueil.jsp&opub=" + idpublication + "&scrollTo=comm-" + newId;
            String nomSource = Notification.getNomUtilisateur(conn, refuser);

            Set notifiedUsers = new HashSet();

            // REPLY notification
            if (idparent != null && !idparent.trim().isEmpty()) {
                Publicationcommentaire[] parents = (Publicationcommentaire[]) CGenUtil.rechercher(
                    new Publicationcommentaire(), null, null, conn,
                    " and idpublicationcommentaire = '" + idparent.trim() + "'");
                if (parents != null && parents.length > 0) {
                    int parentAuteur = parents[0].getIdutilisateur();
                    if (parentAuteur != refuser) {
                        Notification.creerEtEnvoyer(conn, userId, parentAuteur,
                            nomSource + " a repondu a votre commentaire",
                            Notification.TYPE_REPLY, lien);
                        notifiedUsers.add(new Integer(parentAuteur));
                    }
                }
            }

            // COMMENT notification to pub owner
            Publication[] pubs = (Publication[]) CGenUtil.rechercher(
                new Publication(), null, null, conn,
                " and idpublication = '" + idpublication + "'");
            if (pubs != null && pubs.length > 0) {
                int pubOwner = pubs[0].getIdutilisateur();
                if (pubOwner != refuser && !notifiedUsers.contains(new Integer(pubOwner))) {
                    Notification.creerEtEnvoyer(conn, userId, pubOwner,
                        nomSource + " a commente votre publication",
                        Notification.TYPE_COMMENT, lien);
                    notifiedUsers.add(new Integer(pubOwner));
                }
            }

            // MENTION notifications
            if (mentionsParam != null && !mentionsParam.trim().isEmpty()) {
                String[] mentionIds = mentionsParam.split(",");
                for (int m = 0; m < mentionIds.length; m++) {
                    String mid = mentionIds[m].trim();
                    if (mid.isEmpty()) continue;
                    try {
                        int mentionUserId = Integer.parseInt(mid);
                        Mention mention = new Mention();
                        mention.setIdutilisateur(mentionUserId);
                        mention.setIdpublicationcommentaire(newId);
                        mention.construirePK(conn);
                        mention.insertToTableWithHisto(userId, conn);

                        if (mentionUserId != refuser && !notifiedUsers.contains(new Integer(mentionUserId))) {
                            Notification.creerEtEnvoyer(conn, userId, mentionUserId,
                                nomSource + " vous a mentionne(e) dans un commentaire",
                                Notification.TYPE_MENTION, lien);
                            notifiedUsers.add(new Integer(mentionUserId));
                        }
                    } catch (NumberFormatException nfe) { /* ignorer */ }
                }
            }

            conn.commit();
            return "{\"success\":true,\"id\":\"" + (newId != null ? newId : "") + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception cx) {}
        }
    }

    /* ======== CHARGER COMMENTAIRES ======== */
    public static String chargerCommentaires(int refuser, String idpublication) throws Exception {
        if (idpublication == null)
            return "{\"success\":false,\"error\":\"Parametre idpublication manquant\"}";

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            // Types de reaction
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

            // Tous les profils
            ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(
                new ProfilLib(), null, null, conn, "");
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

            // Commentaires
            Publicationcommentaire[] comms = (Publicationcommentaire[]) CGenUtil.rechercher(
                new Publicationcommentaire(), null, null, conn,
                " and idpublication = '" + idpublication + "' and etat = 1 order by idpublicationcommentaire");
            if (comms == null) comms = new Publicationcommentaire[0];

            StringBuilder sbComm = new StringBuilder("[");
            for (int i = 0; i < comms.length; i++) {
                Publicationcommentaire c = comms[i];
                String idcomm = c.getIdpublicationcommentaire();
                String auteur = (String) userNames.get(new Integer(c.getIdutilisateur()));
                if (auteur == null) auteur = "Utilisateur";
                boolean commAuteurBanni = userBanned.containsKey(new Integer(c.getIdutilisateur()));
                if (commAuteurBanni) auteur = "Utilisateur indisponible";

                // Reactions sur ce commentaire
                Commentairereaction[] cReacts = (Commentairereaction[]) CGenUtil.rechercher(
                    new Commentairereaction(), null, null, conn,
                    " and idpublicationcommentaire = '" + idcomm + "'");
                if (cReacts == null) cReacts = new Commentairereaction[0];

                Map reactMap = new HashMap();
                String myReaction = "";
                for (int r = 0; r < cReacts.length; r++) {
                    String type = cReacts[r].getIdreactiontype();
                    Integer cnt = (Integer) reactMap.get(type);
                    reactMap.put(type, cnt == null ? new Integer(1) : new Integer(cnt.intValue() + 1));
                    if (cReacts[r].getIdutilisateur() == refuser) myReaction = type;
                }

                // Trier par count decroissant
                java.util.List reactPairs = new java.util.ArrayList();
                for (java.util.Iterator rit = reactMap.entrySet().iterator(); rit.hasNext();) {
                    Map.Entry entry = (Map.Entry) rit.next();
                    Object[] pair = new Object[2];
                    pair[0] = entry.getKey();
                    pair[1] = entry.getValue();
                    reactPairs.add(pair);
                }
                for (int ri = 0; ri < reactPairs.size(); ri++) {
                    for (int rj = ri + 1; rj < reactPairs.size(); rj++) {
                        Object[] pairA = (Object[]) reactPairs.get(ri);
                        Object[] pairB = (Object[]) reactPairs.get(rj);
                        if (((Integer) pairB[1]).intValue() > ((Integer) pairA[1]).intValue()) {
                            reactPairs.set(ri, pairB);
                            reactPairs.set(rj, pairA);
                        }
                    }
                }

                StringBuilder sbReact = new StringBuilder("[");
                boolean firstR = true;
                for (int rpi = 0; rpi < reactPairs.size(); rpi++) {
                    Object[] pair = (Object[]) reactPairs.get(rpi);
                    String rtId = (String) pair[0];
                    Integer rtCount = (Integer) pair[1];
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

            return "{\"success\":true,\"refuser\":" + refuser + ",\"reactionTypes\":" + sbRT.toString()
                + ",\"commentaires\":" + sbComm.toString() + "}";
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
