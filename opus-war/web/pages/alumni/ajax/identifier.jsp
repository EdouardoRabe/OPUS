<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Identification" %>
<%@ page import="alumni.Notification" %>
<%@ page import="alumni.Publication" %>
<%@ page import="java.sql.Connection" %>
<%
    // AJAX POST: Identifier (taguer) des utilisateurs dans une publication
    // Params: idpublication, idutilisateurs (comma-separated list of user IDs)
    response.setContentType("application/json; charset=UTF-8");
    request.setCharacterEncoding("UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        String idpub = request.getParameter("idpublication");
        String idsUtilisateurs = request.getParameter("idutilisateurs");

        if (idpub == null || idsUtilisateurs == null || idsUtilisateurs.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Parametres manquants\"}");
            return;
        }

        String userId = String.valueOf(u.getUser().getRefuser());
        String nomSource = Notification.getNomUtilisateur(null, u.getUser().getRefuser());

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        // Recuperer le nom source avec connection
        nomSource = Notification.getNomUtilisateur(conn, u.getUser().getRefuser());

        String[] ids = idsUtilisateurs.split(",");
        int nbIdentifies = 0;

        for (int i = 0; i < ids.length; i++) {
            String idTarget = ids[i].trim();
            if (idTarget.isEmpty()) continue;

            int targetUserId = Integer.parseInt(idTarget);

            // Verifier si deja identifie
            Identification[] existing = (Identification[]) CGenUtil.rechercher(
                new Identification(), null, null, conn,
                " and idutilisateur = " + targetUserId + " and idpublication = '" + idpub + "'");

            if (existing == null || existing.length == 0) {
                // Creer l'identification
                Identification ident = new Identification();
                ident.setIdutilisateur(targetUserId);
                ident.setIdpublication(idpub);
                ident.construirePK(conn);
                ident.insertToTableWithHisto(userId, conn);

                // Creer une notification pour l'utilisateur identifie
                String lien = "module.jsp?but=alumni/accueil.jsp#pub-" + idpub;
                Notification.creerEtEnvoyer(conn, userId, targetUserId,
                    nomSource + " vous a identifie(e) dans une publication",
                    Notification.TYPE_IDENTIFICATION, lien);

                nbIdentifies++;
            }
        }

        conn.commit();
        out.print("{\"success\":true,\"nbIdentifies\":" + nbIdentifies + "}");

    } catch (Exception e) {
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception cx) {}
    }
%>
