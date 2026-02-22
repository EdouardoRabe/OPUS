<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="alumni.Publicationreaction" %>
<%
    // AJAX GET: Toggle reaction sur publication via framework APJ
    // - CGenUtil.rechercher pour chercher la reaction existante
    // - u.deleteObject / u.updateObject / u.createObject pour modifier
    
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

        int refuser = u.getUser().getRefuser();

        // --- APJ: Rechercher reaction existante de cet utilisateur sur cette publication ---
        Publicationreaction[] existing = (Publicationreaction[]) CGenUtil.rechercher(
            new Publicationreaction(), null, null,
            " and idutilisateur = " + refuser + " and idpublication = '" + idpub + "'");

        if (existing != null && existing.length > 0) {
            if (existing[0].getIdreactiontype().equals(idreaction)) {
                // Meme type: toggle OFF -> supprimer via APJ
                u.deleteObject(existing[0]);
            } else {
                // Type different: changer via APJ updateObject
                existing[0].setIdreactiontype(idreaction);
                u.updateObject(existing[0]);
            }
        } else {
            // Aucune reaction: creer via APJ (PK auto-generee par construirePK)
            Publicationreaction newR = new Publicationreaction();
            newR.setIdreactiontype(idreaction);
            newR.setIdutilisateur(String.valueOf(refuser));
            newR.setIdpublication(idpub);
            u.createObject(newR);
        }

        out.print("{\"success\":true}");

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
