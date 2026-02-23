<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Commentairereaction" %>
<%@ page import="java.sql.Connection" %>
<%
    // AJAX GET: Toggle reaction sur commentaire
    // Logique identique a reagir-publication:
    //   - Clic type X, pas de reaction => INSERT
    //   - Clic type X, reaction existante = X => DELETE (toggle off)
    //   - Clic type X, reaction existante = Y => DELETE ancien + INSERT nouveau
    // Utilise ClassMAPTable methods (APJ) avec connection manuelle

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

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        // --- APJ: Rechercher reaction existante ---
        Commentairereaction[] existing = (Commentairereaction[]) CGenUtil.rechercher(
            new Commentairereaction(), null, null, conn,
            " and idutilisateur = " + userId + " and idpublicationcommentaire = '" + idcomm + "'");

        if (existing != null && existing.length > 0) {
            String existingType = existing[0].getIdreactiontype();
            // Toujours supprimer l'ancien
            existing[0].deleteToTableWithHisto(userId, conn);

            if (!existingType.equals(idreaction)) {
                // Type different: creer le nouveau
                Commentairereaction newR = new Commentairereaction();
                newR.setIdutilisateur(Integer.parseInt(userId));
                newR.setIdpublicationcommentaire(idcomm);
                newR.setIdreactiontype(idreaction);
                newR.construirePK(conn);
                newR.insertToTableWithHisto(userId, conn);
            }
        } else {
            // Aucune reaction: creer
            Commentairereaction newR = new Commentairereaction();
            newR.setIdutilisateur(Integer.parseInt(userId));
            newR.setIdpublicationcommentaire(idcomm);
            newR.setIdreactiontype(idreaction);
            newR.construirePK(conn);
            newR.insertToTableWithHisto(userId, conn);
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
