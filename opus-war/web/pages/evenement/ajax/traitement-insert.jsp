<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Evenement" %>
<%@ page import="alumni.Notification" %>
<%@ page import="alumni.Profil" %>
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

        String description = request.getParameter("description");
        String daty        = request.getParameter("daty");
        String datedebut   = request.getParameter("datedebut");
        String datefin     = request.getParameter("datefin");

        if (description == null || description.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"La description est obligatoire\"}");
            return;
        }
        if (datedebut == null || datedebut.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"La date de d\\u00e9but est obligatoire\"}");
            return;
        }

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        Evenement evt = new Evenement();
        evt.construirePK(conn);
        evt.setDescription(description.trim());
        evt.setDaty(daty != null && !daty.trim().isEmpty() ? Date.valueOf(daty.trim()) : new Date(System.currentTimeMillis()));
        evt.setDatedebut(Date.valueOf(datedebut.trim()));
        evt.setDatefin(datefin != null && !datefin.trim().isEmpty() ? Date.valueOf(datefin.trim()) : null);
        evt.setIdutilisateur(refuser);
        evt.insertToTableWithHisto(userId, conn);

        /* ── Notifier tous les utilisateurs ── */
        String lienCalendrier = "module.jsp?but=evenement/evenement-calendar.jsp";
        String nomCreateur = Notification.getNomUtilisateur(conn, refuser);
        String objetNotif = nomCreateur + " a cr\u00e9\u00e9 un nouvel \u00e9v\u00e9nement : " + description.trim();
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
        } catch (Exception notifEx) {
            notifEx.printStackTrace();
        }

        conn.commit();

        out.print("{\"success\":true,\"id\":\"" + evt.getIdevenement() + "\"}");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
