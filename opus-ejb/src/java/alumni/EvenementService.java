package alumni;

import java.sql.Connection;
import java.sql.Date;
import java.util.*;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour le module Evenement.
 * Gere sa propre connexion.
 */
public class EvenementService {

    /* ═══════════════ CHECK PARTICIPATION ═══════════════ */
    public static String checkParticipation(int refuser, String idevenement) throws Exception {
        if (idevenement == null || idevenement.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Evenement non specifie\"}";

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            ParticipationEvenement[] results = (ParticipationEvenement[]) CGenUtil.rechercher(
                new ParticipationEvenement(), null, null, conn,
                " and idevenement = '" + idevenement.trim() + "' AND idutilisateur = " + refuser);
            boolean participe = (results != null && results.length > 0);

            ParticipationEvenement[] all = (ParticipationEvenement[]) CGenUtil.rechercher(
                new ParticipationEvenement(), null, null, conn,
                " and idevenement = '" + idevenement.trim() + "'");
            int totalParticipants = (all != null) ? all.length : 0;

            return "{\"success\":true,\"participe\":" + participe + ",\"total\":" + totalParticipants + "}";
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════ LISTE JSON (FullCalendar) ═══════════════ */
    public static String listeJson(int refuser, String pStart, String pEnd) throws Exception {
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            String filtre = "";
            if (pStart != null && !pStart.trim().isEmpty() && pEnd != null && !pEnd.trim().isEmpty()) {
                filtre = " and datedebut < '" + pEnd.trim() + "' and (datefin >= '" + pStart.trim()
                       + "' or (datefin is null and datedebut >= '" + pStart.trim() + "'))";
            }

            Evenement[] liste = (Evenement[]) CGenUtil.rechercher(new Evenement(), null, null, conn, filtre);
            if (liste == null) liste = new Evenement[0];

            // Participations de l'utilisateur courant
            Set myParts = new HashSet();
            if (refuser > 0) {
                ParticipationEvenement[] parts = (ParticipationEvenement[]) CGenUtil.rechercher(
                    new ParticipationEvenement(), null, null, conn, " and idutilisateur = " + refuser);
                if (parts != null) {
                    for (int p = 0; p < parts.length; p++) myParts.add(parts[p].getIdevenement());
                }
            }

            // Compteur participants par evenement
            Map countMap = new HashMap();
            ParticipationEvenement[] allP = (ParticipationEvenement[]) CGenUtil.rechercher(
                new ParticipationEvenement(), null, null, conn, "");
            if (allP != null) {
                for (int p = 0; p < allP.length; p++) {
                    String eid = allP[p].getIdevenement();
                    countMap.put(eid, countMap.containsKey(eid)
                        ? new Integer(((Integer) countMap.get(eid)).intValue() + 1) : new Integer(1));
                }
            }

            String[] colors = {"#008BFF","#5B23FF","#ef4444","#10b981","#f59e0b","#8b5cf6","#06b6d4","#ec4899"};

            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < liste.length; i++) {
                if (i > 0) sb.append(",");
                Evenement e = liste[i];
                String desc  = e.getDescription() != null ? e.getDescription().replace("\"", "\\\"").replace("\n", " ") : "";
                String debut = e.getDatedebut() != null ? e.getDatedebut().toString() : "";
                String fin   = e.getDatefin()   != null ? e.getDatefin().toString()   : "";
                String daty  = e.getDaty()       != null ? e.getDaty().toString()       : "";
                String color = colors[i % colors.length];
                boolean participating = myParts.contains(e.getIdevenement());
                int nbP = countMap.containsKey(e.getIdevenement())
                    ? ((Integer) countMap.get(e.getIdevenement())).intValue() : 0;

                sb.append("{");
                sb.append("\"id\":\"").append(e.getIdevenement()).append("\",");
                sb.append("\"title\":\"").append(desc).append("\",");
                sb.append("\"start\":\"").append(debut).append("\"");
                if (!fin.isEmpty()) sb.append(",\"end\":\"").append(fin).append("\"");
                sb.append(",\"daty\":\"").append(daty).append("\"");
                sb.append(",\"color\":\"").append(color).append("\"");
                sb.append(",\"allDay\":true");
                sb.append(",\"participating\":").append(participating);
                sb.append(",\"nbParticipants\":").append(nbP);
                sb.append("}");
            }
            sb.append("]");
            return sb.toString();
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════ ANNULER PARTICIPATION ═══════════════ */
    public static String annulerParticipation(int refuser, String idevenement) throws Exception {
        if (idevenement == null || idevenement.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Evenement non specifie\"}";

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            ParticipationEvenement[] results = (ParticipationEvenement[]) CGenUtil.rechercher(
                new ParticipationEvenement(), null, null, conn,
                " and idevenement = '" + idevenement.trim() + "' AND idutilisateur = " + refuser);

            if (results == null || results.length == 0) {
                conn.rollback();
                return "{\"success\":false,\"error\":\"Participation introuvable\"}";
            }

            ParticipationEvenement toDelete = results[0];
            toDelete.setMode("suppr");
            toDelete.deleteToTable(conn);
            conn.commit();
            return "{\"success\":true}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════ INSERT EVENEMENT ═══════════════ */
    public static String insererEvenement(int refuser, String description,
            String daty, String datedebut, String datefin) throws Exception {

        if (description == null || description.trim().isEmpty())
            return "{\"success\":false,\"error\":\"La description est obligatoire\"}";
        if (datedebut == null || datedebut.trim().isEmpty())
            return "{\"success\":false,\"error\":\"La date de d\\u00e9but est obligatoire\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Evenement evt = new Evenement();
            evt.construirePK(conn);
            evt.setDescription(description.trim());
            evt.setDaty(daty != null && !daty.trim().isEmpty()
                ? Date.valueOf(daty.trim()) : new Date(System.currentTimeMillis()));
            evt.setDatedebut(Date.valueOf(datedebut.trim()));
            evt.setDatefin(datefin != null && !datefin.trim().isEmpty()
                ? Date.valueOf(datefin.trim()) : null);
            evt.setIdutilisateur(refuser);
            evt.insertToTableWithHisto(userId, conn);

            // Notifier tous les utilisateurs
            String lienCalendrier = "module.jsp?but=evenement/evenement-calendar.jsp";
            String nomCreateur = Notification.getNomUtilisateur(conn, refuser);
            String objetNotif = nomCreateur + " a créé un nouvel événement : " + description.trim();
            try {
                Profil[] profils = (Profil[]) CGenUtil.rechercher(new Profil(), null, null, conn, "");
                if (profils != null) {
                    for (int i = 0; i < profils.length; i++) {
                        int targetUser = profils[i].getIdutilisateur();
                        if (targetUser != refuser) {
                            Notification.creerEtEnvoyer(conn, userId, targetUser,
                                objetNotif, Notification.TYPE_EVENEMENT, lienCalendrier);
                        }
                    }
                }
            } catch (Exception notifEx) { notifEx.printStackTrace(); }

            conn.commit();
            return "{\"success\":true,\"id\":\"" + evt.getIdevenement() + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════ PARTICIPER ═══════════════ */
    public static String participer(int refuser, String idevenement) throws Exception {
        if (idevenement == null || idevenement.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Evenement non specifie\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            ParticipationEvenement p = new ParticipationEvenement();
            p.construirePK(conn);
            p.setIdevenement(idevenement.trim());
            p.setIdutilisateur(refuser);
            p.setDateparticipation(new Date(System.currentTimeMillis()));
            p.insertToTableWithHisto(userId, conn);
            conn.commit();

            return "{\"success\":true,\"id\":\"" + p.getIdparticipation() + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════ PUBLIER EVENEMENT ═══════════════ */
    public static String publierEvenement(int refuser, String idevenement) throws Exception {
        if (idevenement == null || idevenement.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Evenement non specifie\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            // Verifier que l'evenement existe
            Evenement[] evts = (Evenement[]) CGenUtil.rechercher(
                new Evenement(), null, null, conn,
                " and idevenement = '" + idevenement.trim() + "'");
            if (evts == null || evts.length == 0) {
                conn.rollback();
                return "{\"success\":false,\"error\":\"Evenement introuvable\"}";
            }
            Evenement evt = evts[0];

            // Verifier qu'une publication n'existe pas deja
            Publication[] existing = (Publication[]) CGenUtil.rechercher(
                new Publication(), null, null, conn,
                " and idorigine = '" + idevenement.trim() + "'");
            if (existing != null && existing.length > 0) {
                conn.rollback();
                return "{\"success\":false,\"error\":\"Cet evenement a deja ete publie\"}";
            }

            // Construire le texte
            String desc = evt.getDescription() != null ? evt.getDescription() : "Evenement";
            String debut = evt.getDatedebut() != null ? evt.getDatedebut().toString() : "";
            String fin = evt.getDatefin() != null ? evt.getDatefin().toString() : "";
            StringBuilder texte = new StringBuilder();
            texte.append("\uD83D\uDCC5 Evenement : ").append(desc);
            if (!debut.isEmpty()) {
                if (!fin.isEmpty() && !fin.equals(debut)) {
                    texte.append("\n\uD83D\uDDD3 Du ").append(debut).append(" au ").append(fin);
                } else {
                    texte.append("\n\uD83D\uDDD3 Le ").append(debut);
                }
            }
            texte.append("\n\nRejoignez-nous ! Consultez le calendrier pour participer.");

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

            return "{\"success\":true,\"id\":\"" + pub.getIdpublication() + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════ UPDATE EVENEMENT ═══════════════ */
    public static String updateEvenement(int refuser, String idevenement,
            String description, String daty, String datedebut, String datefin) throws Exception {

        if (idevenement == null || idevenement.trim().isEmpty())
            return "{\"success\":false,\"error\":\"ID manquant\"}";
        if (description == null || description.trim().isEmpty())
            return "{\"success\":false,\"error\":\"La description est obligatoire\"}";
        if (datedebut == null || datedebut.trim().isEmpty())
            return "{\"success\":false,\"error\":\"La date de d\\u00e9but est obligatoire\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Evenement[] arr = (Evenement[]) CGenUtil.rechercher(
                new Evenement(), null, null, conn,
                " and idevenement='" + idevenement.trim().replace("'", "''") + "'");
            if (arr == null || arr.length == 0)
                return "{\"success\":false,\"error\":\"Evenement introuvable\"}";

            Evenement evt = arr[0];
            evt.setDescription(description.trim());
            evt.setDaty(daty != null && !daty.trim().isEmpty()
                ? Date.valueOf(daty.trim()) : evt.getDaty());
            evt.setDatedebut(Date.valueOf(datedebut.trim()));
            evt.setDatefin(datefin != null && !datefin.trim().isEmpty()
                ? Date.valueOf(datefin.trim()) : null);
            evt.setMode("modif");
            evt.updateToTableWithHisto(userId, conn);
            conn.commit();

            return "{\"success\":true,\"id\":\"" + idevenement.trim() + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
