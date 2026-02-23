<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Notification" %>
<%@ page import="alumni.Mention" %>
<%@ page import="alumni.Profil" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%
    // AJAX POST: Ajouter un commentaire ou reponse + notifications + mentions
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        String idpub = request.getParameter("idpublication");
        String description = request.getParameter("description");
        String idparent = request.getParameter("idparent");
        // mentions format: "userId1,userId2,..." envoyé par le frontend
        String mentionsParam = request.getParameter("mentions");

        if (idpub == null || description == null || description.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Parametres manquants\"}");
            return;
        }

        String userId = String.valueOf(u.getUser().getRefuser());
        int refuser = u.getUser().getRefuser();

        // --- APJ: Construire l'entite Publicationcommentaire ---
        Publicationcommentaire comm = new Publicationcommentaire();
        comm.setDescription(description.trim());
        comm.setEtat(1);
        comm.setIdutilisateur(Integer.parseInt(userId));
        comm.setIdpublication(idpub);

        // Si c'est une reponse a un commentaire
        if (idparent != null && !idparent.trim().isEmpty()) {
            comm.setIdpublicationcommentaire_1(idparent.trim());
        }

        // --- APJ: Generer PK et inserer avec connection manuelle ---
        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        comm.construirePK(conn);
        comm.insertToTableWithHisto(userId, conn);

        String newId = comm.getIdpublicationcommentaire();
        String lien = "module.jsp?but=alumni/fil-actualite.jsp&opub=" + idpub + "&scrollTo=comm-" + newId;
        String nomSource = Notification.getNomUtilisateur(conn, refuser);

        // === NOTIFICATIONS ===
        Set notifiedUsers = new HashSet(); // Eviter les doublons de notification

        if (idparent != null && !idparent.trim().isEmpty()) {
            // --- REPLY: Notifier l'auteur du commentaire parent ---
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

        // --- COMMENT: Notifier le proprietaire de la publication ---
        Publication[] pubs = (Publication[]) CGenUtil.rechercher(
            new Publication(), null, null, conn,
            " and idpublication = '" + idpub + "'");
        if (pubs != null && pubs.length > 0) {
            int pubOwner = pubs[0].getIdutilisateur();
            if (pubOwner != refuser && !notifiedUsers.contains(new Integer(pubOwner))) {
                String typeNotif = (idparent != null && !idparent.trim().isEmpty()) 
                    ? Notification.TYPE_REPLY : Notification.TYPE_COMMENT;
                Notification.creerEtEnvoyer(conn, userId, pubOwner,
                    nomSource + " a commente votre publication",
                    Notification.TYPE_COMMENT, lien);
                notifiedUsers.add(new Integer(pubOwner));
            }
        }

        // --- MENTIONS: Traiter les @mentions ---
        if (mentionsParam != null && !mentionsParam.trim().isEmpty()) {
            String[] mentionIds = mentionsParam.split(",");
            for (int m = 0; m < mentionIds.length; m++) {
                String mid = mentionIds[m].trim();
                if (mid.isEmpty()) continue;
                try {
                    int mentionUserId = Integer.parseInt(mid);
                    // Creer l'entree Mention
                    Mention mention = new Mention();
                    mention.setIdutilisateur(mentionUserId);
                    mention.setIdpublicationcommentaire(newId);
                    mention.construirePK(conn);
                    mention.insertToTableWithHisto(userId, conn);

                    // Notification si pas deja notifie
                    if (mentionUserId != refuser && !notifiedUsers.contains(new Integer(mentionUserId))) {
                        Notification.creerEtEnvoyer(conn, userId, mentionUserId,
                            nomSource + " vous a mentionne(e) dans un commentaire",
                            Notification.TYPE_MENTION, lien);
                        notifiedUsers.add(new Integer(mentionUserId));
                    }
                } catch (NumberFormatException nfe) {
                    // Ignorer les IDs invalides
                }
            }
        }

        conn.commit();
        out.print("{\"success\":true,\"id\":\"" + (newId != null ? newId : "") + "\"}");

    } catch (Exception e) {
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception cx) {}
    }
%>
