package alumni;

import java.sql.Connection;
import bean.CGenUtil;
import utilitaire.UtilDB;
import java.util.Map;
import java.util.HashMap;

/**
 * Service pour les reactions sur publications et commentaires.
 * Chaque methode gere sa propre connexion.
 */
public class ReactionService {

    /* ---------- helpers JSON ---------- */
    private static String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
    private static String emojiFor(String lib) {
        if (lib == null) return "\uD83D\uDC4D";
        String l = lib.toLowerCase();
        if (l.contains("adore") || l.contains("love"))   return "\u2764\uFE0F";
        if (l.contains("haha") || l.contains("humour"))  return "\uD83D\uDE02";
        if (l.contains("surprise") || l.contains("wow")) return "\uD83D\uDE2E";
        if (l.contains("triste") || l.contains("sad"))   return "\uD83D\uDE22";
        if (l.contains("grrr") || l.contains("ang"))     return "\uD83D\uDE20";
        return "\uD83D\uDC4D";
    }

    /* ======== REAGIR PUBLICATION ======== */
    public static String reagirPublication(int refuser, String idpublication, String idreactiontype) throws Exception {
        if (idpublication == null || idreactiontype == null)
            return "{\"success\":false,\"error\":\"Parametres manquants\"}";

        String userId = String.valueOf(refuser);
        boolean isNewReaction = false;
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Publicationreaction[] existing = (Publicationreaction[]) CGenUtil.rechercher(
                new Publicationreaction(), null, null, conn,
                " and idutilisateur = " + userId + " and idpublication = '" + idpublication + "'");

            if (existing != null && existing.length > 0) {
                String existingType = existing[0].getIdreactiontype();
                existing[0].deleteToTableWithHisto(userId, conn);
                if (!existingType.equals(idreactiontype)) {
                    Publicationreaction newR = new Publicationreaction();
                    newR.setIdreactiontype(idreactiontype);
                    newR.setIdutilisateur(Integer.parseInt(userId));
                    newR.setIdpublication(idpublication);
                    newR.construirePK(conn);
                    newR.insertToTableWithHisto(userId, conn);
                    isNewReaction = true;
                }
            } else {
                Publicationreaction newR = new Publicationreaction();
                newR.setIdreactiontype(idreactiontype);
                newR.setIdutilisateur(Integer.parseInt(userId));
                newR.setIdpublication(idpublication);
                newR.construirePK(conn);
                newR.insertToTableWithHisto(userId, conn);
                isNewReaction = true;
            }

            if (isNewReaction) {
                Publication[] pubs = (Publication[]) CGenUtil.rechercher(
                    new Publication(), null, null, conn,
                    " and idpublication = '" + idpublication + "'");
                if (pubs != null && pubs.length > 0) {
                    int pubOwner = pubs[0].getIdutilisateur();
                    if (pubOwner != refuser) {
                        String reactionLib = "reagir";
                        Reactiontype[] rTypes = (Reactiontype[]) CGenUtil.rechercher(
                            new Reactiontype(), null, null, conn,
                            " and idreactiontype = '" + idreactiontype + "'");
                        if (rTypes != null && rTypes.length > 0)
                            reactionLib = rTypes[0].getLibelle();
                        String nomSource = Notification.getNomUtilisateur(conn, refuser);
                        String lien = "module.jsp?but=accueil.jsp&scrollTo=pub-" + idpublication;
                        Notification.creerEtEnvoyer(conn, userId, pubOwner,
                            nomSource + " a reagit " + reactionLib + " a votre publication",
                            Notification.TYPE_PUB_REACTION, lien);
                    }
                }
            }

            conn.commit();
            return "{\"success\":true}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception cx) {}
        }
    }

    /* ======== REAGIR COMMENTAIRE ======== */
    public static String reagirCommentaire(int refuser, String idcommentaire, String idreactiontype) throws Exception {
        if (idcommentaire == null || idreactiontype == null)
            return "{\"success\":false,\"error\":\"Parametres manquants\"}";

        String userId = String.valueOf(refuser);
        boolean isNewReaction = false;
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Commentairereaction[] existing = (Commentairereaction[]) CGenUtil.rechercher(
                new Commentairereaction(), null, null, conn,
                " and idutilisateur = " + userId + " and idpublicationcommentaire = '" + idcommentaire + "'");

            if (existing != null && existing.length > 0) {
                String existingType = existing[0].getIdreactiontype();
                existing[0].deleteToTableWithHisto(userId, conn);
                if (!existingType.equals(idreactiontype)) {
                    Commentairereaction newR = new Commentairereaction();
                    newR.setIdutilisateur(Integer.parseInt(userId));
                    newR.setIdpublicationcommentaire(idcommentaire);
                    newR.setIdreactiontype(idreactiontype);
                    newR.construirePK(conn);
                    newR.insertToTableWithHisto(userId, conn);
                    isNewReaction = true;
                }
            } else {
                Commentairereaction newR = new Commentairereaction();
                newR.setIdutilisateur(Integer.parseInt(userId));
                newR.setIdpublicationcommentaire(idcommentaire);
                newR.setIdreactiontype(idreactiontype);
                newR.construirePK(conn);
                newR.insertToTableWithHisto(userId, conn);
                isNewReaction = true;
            }

            if (isNewReaction) {
                Publicationcommentaire[] comms = (Publicationcommentaire[]) CGenUtil.rechercher(
                    new Publicationcommentaire(), null, null, conn,
                    " and idpublicationcommentaire = '" + idcommentaire + "'");
                if (comms != null && comms.length > 0) {
                    int commOwner = comms[0].getIdutilisateur();
                    if (commOwner != refuser) {
                        String reactionLib = "reagir";
                        Reactiontype[] rTypes = (Reactiontype[]) CGenUtil.rechercher(
                            new Reactiontype(), null, null, conn,
                            " and idreactiontype = '" + idreactiontype + "'");
                        if (rTypes != null && rTypes.length > 0)
                            reactionLib = rTypes[0].getLibelle();
                        String nomSource = Notification.getNomUtilisateur(conn, refuser);
                        String lien = "module.jsp?but=accueil.jsp&opub=" + comms[0].getIdpublication() + "&scrollTo=comm-" + idcommentaire;
                        Notification.creerEtEnvoyer(conn, userId, commOwner,
                            nomSource + " a reagit " + reactionLib + " a votre commentaire",
                            Notification.TYPE_COMM_REACTION, lien);
                    }
                }
            }

            conn.commit();
            return "{\"success\":true}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception cx) {}
        }
    }

    /* ======== DETAIL REACTIONS D'UNE PUBLICATION ======== */
    public static String detailReactions(int refuser, String idpublication, String contextPath) throws Exception {
        if (idpublication == null || idpublication.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Parametre manquant\"}";
        String _idpub = idpublication.replaceAll("[^A-Za-z0-9]", "");

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            Reactiontype[] _rTypes = (Reactiontype[]) CGenUtil.rechercher(
                new Reactiontype(), null, null, conn, " order by idreactiontype");
            if (_rTypes == null) _rTypes = new Reactiontype[0];

            Publicationreaction[] _reacts = (Publicationreaction[]) CGenUtil.rechercher(
                new Publicationreaction(), null, null, conn, " and idpublication='" + _idpub + "'");
            if (_reacts == null) _reacts = new Publicationreaction[0];

            ProfilLib[] _profs = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, conn, "");
            Map _profMap = new HashMap();
            if (_profs != null) {
                for (int _i = 0; _i < _profs.length; _i++)
                    _profMap.put(new Integer(_profs[_i].getIdutilisateur()), _profs[_i]);
            }

            StringBuilder _sb = new StringBuilder();
            _sb.append("{\"success\":true,\"myId\":").append(refuser)
               .append(",\"total\":").append(_reacts.length).append(",\"reactions\":[");
            boolean _ftType = true;
            for (int _rt = 0; _rt < _rTypes.length; _rt++) {
                String _rtId = _rTypes[_rt].getIdreactiontype();
                String _rtLib = _rTypes[_rt].getLibelle();
                String _emoji = emojiFor(_rtLib);

                java.util.List _users = new java.util.ArrayList();
                for (int _r = 0; _r < _reacts.length; _r++) {
                    if (_rtId.equals(_reacts[_r].getIdreactiontype())) {
                        ProfilLib _p = (ProfilLib) _profMap.get(new Integer(_reacts[_r].getIdutilisateur()));
                        if (_p != null) _users.add(_p);
                    }
                }
                if (_users.isEmpty()) continue;

                if (!_ftType) _sb.append(",");
                _ftType = false;
                _sb.append("{\"id\":\"").append(ej(_rtId)).append("\"")
                   .append(",\"libelle\":\"").append(ej(_rtLib)).append("\"")
                   .append(",\"emoji\":\"").append(ej(_emoji)).append("\"")
                   .append(",\"count\":").append(_users.size())
                   .append(",\"users\":[");
                for (int _u = 0; _u < _users.size(); _u++) {
                    ProfilLib _p = (ProfilLib) _users.get(_u);
                    if (_u > 0) _sb.append(",");
                    String _nom = ej(_p.getNom() + " " + _p.getPrenom());
                    String _photo = (_p.getPhotoProfil() != null && !_p.getPhotoProfil().trim().isEmpty())
                        ? ej(contextPath + "/" + _p.getPhotoProfil().trim()) : "";
                    String _idprofil = _p.getIdprofil() != null ? ej(_p.getIdprofil()) : "";
                    _sb.append("{\"idutilisateur\":").append(_p.getIdutilisateur())
                       .append(",\"nom\":\"").append(_nom).append("\"")
                       .append(",\"photo\":\"").append(_photo).append("\"")
                       .append(",\"idprofil\":\"").append(_idprofil).append("\"}");
                }
                _sb.append("]}");
            }
            _sb.append("]}");
            return _sb.toString();
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception _e) {}
        }
    }
}
