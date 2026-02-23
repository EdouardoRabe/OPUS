<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="alumni.Commentairereaction" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.Profil" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%!
    // Echapper pour JSON
    private String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
%>
<%
    // AJAX GET: Charger les commentaires d'une publication (100% APJ)
    // Utilise CGenUtil.rechercher pour TOUT: commentaires, reactions, noms utilisateurs

    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }

        String idpub = request.getParameter("idpublication");
        if (idpub == null) {
            out.print("{\"success\":false,\"error\":\"Parametre idpublication manquant\"}");
            return;
        }

        int refuser = u.getUser().getRefuser();
        Connection conn = new UtilDB().GetConn();

        try {
            // --- APJ: Types de reaction ---
            Reactiontype[] rTypes = (Reactiontype[]) CGenUtil.rechercher(
                new Reactiontype(), null, null, conn, " order by idreactiontype");
            if (rTypes == null) rTypes = new Reactiontype[0];

            StringBuilder sbRT = new StringBuilder("[");
            for (int i = 0; i < rTypes.length; i++) {
                if (i > 0) sbRT.append(",");
                sbRT.append("{\"id\":\"").append(ej(rTypes[i].getIdreactiontype())).append("\"");
                sbRT.append(",\"libelle\":\"").append(ej(rTypes[i].getLibelle())).append("\"}");
            }
            sbRT.append("]");

            // --- APJ: Tous les profils pour lookup noms ---
            alumni.Profil[] allProfils = (alumni.Profil[]) CGenUtil.rechercher(
                new alumni.Profil(), null, null, conn, "");
            Map userNames = new HashMap();
            if (allProfils != null) {
                for (int i = 0; i < allProfils.length; i++) {
                    userNames.put(new Integer(allProfils[i].getIdutilisateur()), allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                }
            }

            // --- APJ: Commentaires de cette publication ---
            Publicationcommentaire[] comms = (Publicationcommentaire[]) CGenUtil.rechercher(
                new Publicationcommentaire(), null, null, conn,
                " and idpublication = '" + idpub + "' and etat = 1 order by idpublicationcommentaire");
            if (comms == null) comms = new Publicationcommentaire[0];

            StringBuilder sbComm = new StringBuilder("[");
            for (int i = 0; i < comms.length; i++) {
                Publicationcommentaire c = comms[i];
                String idcomm = c.getIdpublicationcommentaire();
                String auteur = (String) userNames.get(new Integer(c.getIdutilisateur()));
                if (auteur == null) auteur = "Utilisateur";

                // --- APJ: Reactions sur ce commentaire ---
                Commentairereaction[] cReacts = (Commentairereaction[]) CGenUtil.rechercher(
                    new Commentairereaction(), null, null, conn,
                    " and idpublicationcommentaire = '" + idcomm + "'");
                if (cReacts == null) cReacts = new Commentairereaction[0];

                // Compter par type + ma reaction
                Map reactMap = new HashMap();
                String myReaction = "";
                for (int r = 0; r < cReacts.length; r++) {
                    String type = cReacts[r].getIdreactiontype();
                    Integer cnt = (Integer) reactMap.get(type);
                    reactMap.put(type, cnt == null ? new Integer(1) : new Integer(cnt.intValue() + 1));
                    if (cReacts[r].getIdutilisateur() == refuser) {
                        myReaction = type;
                    }
                }

                // Construire le JSON des reactions
                StringBuilder sbReact = new StringBuilder("{");
                boolean firstR = true;
                java.util.Iterator it = reactMap.entrySet().iterator();
                while (it.hasNext()) {
                    Map.Entry entry = (Map.Entry) it.next();
                    if (!firstR) sbReact.append(",");
                    sbReact.append("\"").append(ej((String) entry.getKey())).append("\":");
                    sbReact.append(((Integer) entry.getValue()).intValue());
                    firstR = false;
                }
                sbReact.append("}");

                // JSON du commentaire
                if (i > 0) sbComm.append(",");
                sbComm.append("{");
                sbComm.append("\"id\":\"").append(ej(idcomm)).append("\"");
                sbComm.append(",\"description\":\"").append(ej(c.getDescription())).append("\"");
                sbComm.append(",\"auteur\":\"").append(ej(auteur)).append("\"");
                String parent = c.getIdpublicationcommentaire_1();
                sbComm.append(",\"idparent\":\"").append(parent != null ? ej(parent) : "").append("\"");
                sbComm.append(",\"reactions\":").append(sbReact.toString());
                sbComm.append(",\"myReaction\":\"").append(ej(myReaction)).append("\"");
                sbComm.append("}");
            }
            sbComm.append("]");

            out.print("{\"success\":true,\"reactionTypes\":" + sbRT.toString()
                + ",\"commentaires\":" + sbComm.toString() + "}");

        } finally {
            if (conn != null) conn.close();
        }

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
