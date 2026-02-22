<%@ page pageEncoding="UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="java.sql.Connection" %>
<%
    // AJAX POST: Ajouter un commentaire ou reponse
    // Utilise ClassMAPTable.construirePK + insertToTableWithHisto (APJ)
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

        if (idpub == null || description == null || description.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Parametres manquants\"}");
            return;
        }

        String userId = String.valueOf(u.getUser().getRefuser());

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
        conn.commit();

        String newId = comm.getIdpublicationcommentaire();
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
