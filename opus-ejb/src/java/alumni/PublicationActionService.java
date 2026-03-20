package alumni;

import java.sql.Connection;
import java.sql.Statement;
import java.sql.Date;
import java.util.Calendar;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour les actions simples sur publications :
 * marquer-vue, save/unsave, report, partager.
 * Chaque methode gère sa propre connexion.
 */
public class PublicationActionService {

    /* ======== MARQUER VUE ======== */
    public static String marquerVue(int refuser, String idpublication) throws Exception {
        if (idpublication == null || idpublication.trim().isEmpty()) return "err";
        String idpub = idpublication.replaceAll("[^A-Za-z0-9]", "");
        if (idpub.isEmpty()) return "err";

        Connection conn = null;
        Statement st = null;
        try {
            conn = new UtilDB().GetConn();
            st = conn.createStatement();
            st.executeUpdate(
                "INSERT INTO publicationvue (idutilisateur, idpublication, datvue, nbvue)"
                + " VALUES (" + refuser + ", '" + idpub + "', NOW(), 1)"
                + " ON CONFLICT (idutilisateur, idpublication)"
                + " DO UPDATE SET nbvue = publicationvue.nbvue + 1, datvue = NOW()");
            return "ok";
        } catch (Exception e) {
            return "err";
        } finally {
            if (st != null) try { st.close(); } catch (Exception _x) {}
            if (conn != null) try { conn.close(); } catch (Exception _x) {}
        }
    }

    /* ======== TOGGLE SAVE / UNSAVE ======== */
    public static String toggleSave(int refuser, String idpublication) throws Exception {
        if (idpublication == null || idpublication.trim().isEmpty())
            return "{\"success\":false,\"error\":\"idpublication manquant\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Publicationenregistrement[] existing = (Publicationenregistrement[]) CGenUtil.rechercher(
                new Publicationenregistrement(), null, null, conn,
                " and idutilisateur = " + userId + " and idpublication = '" + idpublication + "'");

            if (existing != null && existing.length > 0) {
                existing[0].deleteToTable(conn);
                conn.commit();
                return "{\"success\":true,\"saved\":false}";
            } else {
                Publicationenregistrement enr = new Publicationenregistrement();
                enr.setIdpublication(idpublication);
                enr.setIdutilisateur(refuser);
                enr.setDaty(new java.sql.Date(System.currentTimeMillis()));
                enr.setHeure(new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date()));
                enr.construirePK(conn);
                enr.insertToTable(conn);
                conn.commit();
                return "{\"success\":true,\"saved\":true}";
            }
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ======== REPORT PUBLICATION ======== */
    public static String reportPublication(int refuser, String idpublication, String description, String[] typesSignalement) throws Exception {
        if (idpublication == null || idpublication.trim().isEmpty())
            return "{\"success\":false,\"error\":\"idpublication manquant\"}";
        if (typesSignalement == null || typesSignalement.length == 0)
            return "{\"success\":false,\"error\":\"Veuillez selectionner au moins un motif\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            for (int i = 0; i < typesSignalement.length; i++) {
                String type = typesSignalement[i];
                if (type == null || type.trim().isEmpty()) continue;
                Signalementpublication sig = new Signalementpublication();
                sig.construirePK(conn);
                sig.setIdpublication(idpublication);
                sig.setIdutilisateur(userId);
                sig.setTypesignalement(type);
                sig.setDescritpion(description != null ? description : "");
                sig.setDaty(new java.sql.Date(System.currentTimeMillis()));
                sig.setHeure(new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date()));
                sig.insertToTableWithHisto(userId, conn);
            }

            conn.commit();
            return "{\"success\":true,\"redirect\":true}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception cx) {}
        }
    }

    /* ======== PARTAGER PUBLICATION ======== */
    public static String partagerPublication(int refuser, String idpuborigine, String description) throws Exception {
        if (idpuborigine == null || idpuborigine.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Identifiant de publication manquant\"}";

        idpuborigine = idpuborigine.trim();
        if (description == null) description = "";
        String userId = String.valueOf(refuser);

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Publication[] origPubs = (Publication[]) CGenUtil.rechercher(
                new Publication(), null, null, conn,
                " and idpublication = '" + idpuborigine + "' and etat = 1");
            if (origPubs == null || origPubs.length == 0)
                return "{\"success\":false,\"error\":\"Publication introuvable ou inactive\"}";

            Publication origPub = origPubs[0];
            if (origPub.getIdutilisateur() == refuser)
                return "{\"success\":false,\"error\":\"Vous ne pouvez pas partager votre propre publication\"}";

            Publication partage = new Publication();
            partage.setIdutilisateur(refuser);
            partage.setDescritpion(description.trim().isEmpty() ? null : description.trim());
            partage.setIdtypepublication(origPub.getIdtypepublication());
            partage.setIdorigine(null);
            partage.setIdpuborigine(idpuborigine);
            partage.setEtat(1);
            Calendar cal = Calendar.getInstance();
            partage.setDaty(new Date(cal.getTimeInMillis()));
            String heure = String.format("%02d:%02d", cal.get(Calendar.HOUR_OF_DAY), cal.get(Calendar.MINUTE));
            partage.setHeure(heure);
            partage.construirePK(conn);
            partage.insertToTableWithHisto(userId, conn);
            String newId = partage.getIdpublication();

            if (origPub.getIdutilisateur() != refuser) {
                String nomSource = Notification.getNomUtilisateur(conn, refuser);
                String lien = "module.jsp?but=accueil.jsp&scrollTo=pub-" + newId;
                Notification.creerEtEnvoyer(conn, userId, origPub.getIdutilisateur(),
                    nomSource + " a partage votre publication",
                    Notification.TYPE_MENTION, lien);
            }

            conn.commit();
            return "{\"success\":true,\"idpublication\":\"" + newId + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception cx) {}
        }
    }
}
