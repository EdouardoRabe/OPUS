<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Commentairereaction" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.Notification" %>
<%@ page import="java.sql.Connection" %>
<%
    // AJAX GET: Toggle reaction sur commentaire + notification
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        String idcomm = request.getParameter("idcommentaire");
        String idreaction = request.getParameter("idreactiontype");
        if (idcomm == null || idreaction == null) {
            out.print("{\"success\":false,\"error\":\"Parametres manquants\"}");
            return;
        }

        String userId = String.valueOf(u.getUser().getRefuser());
        int refuser = u.getUser().getRefuser();
        boolean isNewReaction = false;

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        // --- APJ: Rechercher reaction existante ---
        Commentairereaction[] existing = (Commentairereaction[]) CGenUtil.rechercher(
            new Commentairereaction(), null, null, conn,
            " and idutilisateur = " + userId + " and idpublicationcommentaire = '" + idcomm + "'");

        if (existing != null && existing.length > 0) {
            String existingType = existing[0].getIdreactiontype();
            existing[0].deleteToTableWithHisto(userId, conn);

            if (!existingType.equals(idreaction)) {
                Commentairereaction newR = new Commentairereaction();
                newR.setIdutilisateur(Integer.parseInt(userId));
                newR.setIdpublicationcommentaire(idcomm);
                newR.setIdreactiontype(idreaction);
                newR.construirePK(conn);
                newR.insertToTableWithHisto(userId, conn);
                isNewReaction = true;
            }
        } else {
            Commentairereaction newR = new Commentairereaction();
            newR.setIdutilisateur(Integer.parseInt(userId));
            newR.setIdpublicationcommentaire(idcomm);
            newR.setIdreactiontype(idreaction);
            newR.construirePK(conn);
            newR.insertToTableWithHisto(userId, conn);
            isNewReaction = true;
        }

        // === NOTIFICATION: Notifier l'auteur du commentaire ===
        if (isNewReaction) {
            Publicationcommentaire[] comms = (Publicationcommentaire[]) CGenUtil.rechercher(
                new Publicationcommentaire(), null, null, conn,
                " and idpublicationcommentaire = '" + idcomm + "'");
            if (comms != null && comms.length > 0) {
                int commOwner = comms[0].getIdutilisateur();
                if (commOwner != refuser) {
                    String reactionLib = "reagir";
                    Reactiontype[] rTypes = (Reactiontype[]) CGenUtil.rechercher(
                        new Reactiontype(), null, null, conn,
                        " and idreactiontype = '" + idreaction + "'");
                    if (rTypes != null && rTypes.length > 0) {
                        reactionLib = rTypes[0].getLibelle();
                    }

                    String nomSource = Notification.getNomUtilisateur(conn, refuser);
                    String lien = "module.jsp?but=alumni/fil-actualite.jsp&opub=" + comms[0].getIdpublication() + "&scrollTo=comm-" + idcomm;
                    Notification.creerEtEnvoyer(conn, userId, commOwner,
                        nomSource + " a reagit " + reactionLib + " a votre commentaire",
                        Notification.TYPE_COMM_REACTION, lien);
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
