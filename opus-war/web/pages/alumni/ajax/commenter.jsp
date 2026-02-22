<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%
    // AJAX POST: Ajouter un commentaire ou reponse via framework APJ
    // u.createObject genere la PK automatiquement via construirePK
    request.setCharacterEncoding("UTF-8");

    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        String idpub = request.getParameter("idpublication");
        String description = request.getParameter("description");
        String idparent = request.getParameter("idparent"); // null = top-level, sinon = reponse

        if (idpub == null || description == null || description.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Parametres manquants\"}");
            return;
        }

        int refuser = u.getUser().getRefuser();

        // --- APJ: Construire l'entite Publicationcommentaire ---
        Publicationcommentaire comm = new Publicationcommentaire();
        comm.setDescription(description.trim());
        comm.setEtat(1);
        comm.setIdutilisateur(String.valueOf(refuser));
        comm.setIdpublication(idpub);

        // Si c'est une reponse a un commentaire
        if (idparent != null && !idparent.trim().isEmpty()) {
            comm.setIdpublicationcommentaire_1(idparent.trim());
        }

        // --- APJ: createObject genere PK ("PCM" + get_seq_publicationcommentaire) ---
        bean.ClassMAPTable created = (bean.ClassMAPTable) u.createObject(comm);

        String newId = created != null ? created.getTuppleID() : "";
        out.print("{\"success\":true,\"id\":\"" + newId + "\"}");

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
