<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="alumni.Commentairereaction" %>
<%
    // AJAX GET: Toggle reaction sur commentaire via framework APJ
    // Meme logique que reagir-publication: CGenUtil + u.deleteObject/updateObject/createObject
    
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

        int refuser = u.getUser().getRefuser();

        // --- APJ: Rechercher reaction existante ---
        Commentairereaction[] existing = (Commentairereaction[]) CGenUtil.rechercher(
            new Commentairereaction(), null, null,
            " and idutilisateur = " + refuser + " and idpublicationcommentaire = '" + idcomm + "'");

        if (existing != null && existing.length > 0) {
            if (existing[0].getIdreactiontype().equals(idreaction)) {
                // Toggle OFF: supprimer via APJ
                u.deleteObject(existing[0]);
            } else {
                // Changer type: update via APJ
                existing[0].setIdreactiontype(idreaction);
                u.updateObject(existing[0]);
            }
        } else {
            // Nouvelle reaction: creer via APJ (PK auto-generee)
            Commentairereaction newR = new Commentairereaction();
            newR.setIdutilisateur(String.valueOf(refuser));
            newR.setIdpublicationcommentaire(idcomm);
            newR.setIdreactiontype(idreaction);
            u.createObject(newR);
        }

        out.print("{\"success\":true}");

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
