<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Notification" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.util.Calendar" %>
<%
    /* ============================================================
       AJAX POST – Partager (republier) une publication
       Params: idpublication, description (optionnel)
       Retour: { success, idpublication } ou { success:false, error }
       ============================================================ */
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB uEJB = (UserEJB) session.getAttribute("u");
        if (uEJB == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }
        int refuser = uEJB.getUser().getRefuser();
        String userId = String.valueOf(refuser);

        String idpuborigine = request.getParameter("idpublication");
        String description  = request.getParameter("description");
        if (idpuborigine == null || idpuborigine.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Identifiant de publication manquant\"}");
            return;
        }
        idpuborigine = idpuborigine.trim();
        if (description == null) description = "";

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        // Vérifier que la publication originale existe et est active
        Publication[] origPubs = (Publication[]) CGenUtil.rechercher(
            new Publication(), null, null, conn,
            " and idpublication = '" + idpuborigine + "' and etat = 1");
        if (origPubs == null || origPubs.length == 0) {
            out.print("{\"success\":false,\"error\":\"Publication introuvable ou inactive\"}");
            return;
        }
        Publication origPub = origPubs[0];

        // On ne peut pas partager sa propre publication
        if (origPub.getIdutilisateur() == refuser) {
            out.print("{\"success\":false,\"error\":\"Vous ne pouvez pas partager votre propre publication\"}");
            return;
        }

        // Créer la nouvelle publication (partage)
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

        // Notification au propriétaire de la pub originale
        if (origPub.getIdutilisateur() != refuser) {
            String nomSource = Notification.getNomUtilisateur(conn, refuser);
            String lien = "module.jsp?but=accueil.jsp&scrollTo=pub-" + newId;
            Notification.creerEtEnvoyer(conn, userId, origPub.getIdutilisateur(),
                nomSource + " a partage votre publication",
                Notification.TYPE_MENTION, lien);
        }

        conn.commit();
        out.print("{\"success\":true,\"idpublication\":\"" + newId + "\"}");

    } catch (Exception e) {
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception cx) {}
    }
%>
