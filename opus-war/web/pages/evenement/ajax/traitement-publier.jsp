<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Evenement" %>
<%@ page import="alumni.Publication" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Date" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }
        int refuser = u.getUser().getRefuser();
        String userId = String.valueOf(refuser);

        String idevenement = request.getParameter("idevenement");
        if (idevenement == null || idevenement.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Evenement non specifie\"}");
            return;
        }

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        /* Vérifier que l'événement existe */
        Evenement[] evts = (Evenement[]) CGenUtil.rechercher(
            new Evenement(), null, null, conn,
            " and idevenement = '" + idevenement.trim() + "'");
        if (evts == null || evts.length == 0) {
            out.print("{\"success\":false,\"error\":\"Evenement introuvable\"}");
            conn.rollback();
            return;
        }
        Evenement evt = evts[0];

        /* Vérifier qu'une publication n'existe pas déjà pour cet événement */
        Publication[] existing = (Publication[]) CGenUtil.rechercher(
            new Publication(), null, null, conn,
            " and idorigine = '" + idevenement.trim() + "'");
        if (existing != null && existing.length > 0) {
            out.print("{\"success\":false,\"error\":\"Cet evenement a deja ete publie\"}");
            conn.rollback();
            return;
        }

        /* Construire le texte de la publication */
        String desc = evt.getDescription() != null ? evt.getDescription() : "Evenement";
        String debut = evt.getDatedebut() != null ? evt.getDatedebut().toString() : "";
        String fin = evt.getDatefin() != null ? evt.getDatefin().toString() : "";
        StringBuilder texte = new StringBuilder();
        texte.append("\ud83d\udcc5 Evenement : ").append(desc);
        if (!debut.isEmpty()) {
            if (!fin.isEmpty() && !fin.equals(debut)) {
                texte.append("\n\ud83d\uddd3 Du ").append(debut).append(" au ").append(fin);
            } else {
                texte.append("\n\ud83d\uddd3 Le ").append(debut);
            }
        }
        texte.append("\n\nRejoignez-nous ! Consultez le calendrier pour participer.");

        /* Créer la publication (même logique que creer-publication.jsp) */
        Publication pub = new Publication();
        pub.setDescritpion(texte.toString());
        pub.setDaty(new Date(System.currentTimeMillis()));
        String heure = new java.text.SimpleDateFormat("HH:mm").format(new java.util.Date());
        pub.setHeure(heure);
        pub.setEtat(1);
        pub.setIdtypepublication("TPB000003");
        pub.setIdutilisateur(refuser);
        pub.setIdorigine(idevenement.trim());

        pub.construirePK(conn);
        pub.insertToTableWithHisto(userId, conn);
        conn.commit();

        out.print("{\"success\":true,\"id\":\"" + pub.getIdpublication() + "\"}");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
