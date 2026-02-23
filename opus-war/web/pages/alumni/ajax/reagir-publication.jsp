<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publicationreaction" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.Notification" %>
<%@ page import="java.sql.Connection" %>
<%
    // AJAX GET: Toggle reaction sur publication + notification
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        String idpub = request.getParameter("idpublication");
        String idreaction = request.getParameter("idreactiontype");
        if (idpub == null || idreaction == null) {
            out.print("{\"success\":false,\"error\":\"Parametres manquants\"}");
            return;
        }

        String userId = String.valueOf(u.getUser().getRefuser());
        int refuser = u.getUser().getRefuser();
        boolean isNewReaction = false;

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        // --- APJ: Rechercher reaction existante ---
        Publicationreaction[] existing = (Publicationreaction[]) CGenUtil.rechercher(
            new Publicationreaction(), null, null, conn,
            " and idutilisateur = " + userId + " and idpublication = '" + idpub + "'");

        if (existing != null && existing.length > 0) {
            String existingType = existing[0].getIdreactiontype();
            existing[0].deleteToTableWithHisto(userId, conn);

            if (!existingType.equals(idreaction)) {
                Publicationreaction newR = new Publicationreaction();
                newR.setIdreactiontype(idreaction);
                newR.setIdutilisateur(Integer.parseInt(userId));
                newR.setIdpublication(idpub);
                newR.construirePK(conn);
                newR.insertToTableWithHisto(userId, conn);
                isNewReaction = true;
            }
        } else {
            Publicationreaction newR = new Publicationreaction();
            newR.setIdreactiontype(idreaction);
            newR.setIdutilisateur(Integer.parseInt(userId));
            newR.setIdpublication(idpub);
            newR.construirePK(conn);
            newR.insertToTableWithHisto(userId, conn);
            isNewReaction = true;
        }

        // === NOTIFICATION: Notifier le proprietaire de la publication ===
        if (isNewReaction) {
            Publication[] pubs = (Publication[]) CGenUtil.rechercher(
                new Publication(), null, null, conn,
                " and idpublication = '" + idpub + "'");
            if (pubs != null && pubs.length > 0) {
                int pubOwner = pubs[0].getIdutilisateur();
                if (pubOwner != refuser) {
                    // Chercher le libelle de la reaction
                    String reactionLib = "reagir";
                    Reactiontype[] rTypes = (Reactiontype[]) CGenUtil.rechercher(
                        new Reactiontype(), null, null, conn,
                        " and idreactiontype = '" + idreaction + "'");
                    if (rTypes != null && rTypes.length > 0) {
                        reactionLib = rTypes[0].getLibelle();
                    }

                    String nomSource = Notification.getNomUtilisateur(conn, refuser);
                    String lien = "module.jsp?but=alumni/fil-actualite.jsp#pub-" + idpub;
                    Notification.creerEtEnvoyer(conn, userId, pubOwner,
                        nomSource + " a reagit " + reactionLib + " a votre publication",
                        Notification.TYPE_PUB_REACTION, lien);
                }
            }
        }

        conn.commit();
        out.print("{\"success\":true}");

    } catch (Exception e) {
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception cx) {}
    }
%>
