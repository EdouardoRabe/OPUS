<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Evenement" %>
<%@ page import="alumni.ParticipationEvenement" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("[]"); return; }
        int currentUserId = u.getUser().getRefuser();

        /* Paramètres FullCalendar : start et end (YYYY-MM-DD) */
        String pStart = request.getParameter("start");
        String pEnd   = request.getParameter("end");

        conn = new UtilDB().GetConn();

        /* ── Filtre par plage de dates si fourni ── */
        String filtre = "";
        if (pStart != null && !pStart.trim().isEmpty() && pEnd != null && !pEnd.trim().isEmpty()) {
            filtre = " and datedebut < '" + pEnd.trim() + "' and (datefin >= '" + pStart.trim() + "' or (datefin is null and datedebut >= '" + pStart.trim() + "'))";
        }

        Evenement[] liste = (Evenement[]) CGenUtil.rechercher(new Evenement(), null, null, conn, filtre);

        /* ── Participations de l'utilisateur courant ── */
        java.util.Set myParts = new java.util.HashSet();
        if (currentUserId > 0) {
            ParticipationEvenement[] parts = (ParticipationEvenement[]) CGenUtil.rechercher(
                new ParticipationEvenement(), null, null, conn, " and idutilisateur = " + currentUserId);
            if (parts != null) {
                for (int p = 0; p < parts.length; p++) myParts.add(parts[p].getIdevenement());
            }
        }

        /* ── Compteur participants par événement ── */
        java.util.Map countMap = new java.util.HashMap();
        ParticipationEvenement[] allP = (ParticipationEvenement[]) CGenUtil.rechercher(
            new ParticipationEvenement(), null, null, conn, "");
        if (allP != null) {
            for (int p = 0; p < allP.length; p++) {
                String eid = allP[p].getIdevenement();
                countMap.put(eid, countMap.containsKey(eid) ? new Integer(((Integer)countMap.get(eid)).intValue() + 1) : new Integer(1));
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
            String daty  = e.getDaty()      != null ? e.getDaty().toString()      : "";
            String color = colors[i % colors.length];
            boolean participating = myParts.contains(e.getIdevenement());
            int nbP = countMap.containsKey(e.getIdevenement()) ? ((Integer)countMap.get(e.getIdevenement())).intValue() : 0;

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
        out.print(sb.toString());

    } catch (Exception e) {
        e.printStackTrace();
        out.print("[]");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
