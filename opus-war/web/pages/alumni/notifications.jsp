<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Notification" %>
<%@ page import="alumni.Profil" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%!
    private String calculerEcart(String daty, String heure) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date dateNotif = sdf.parse(daty + " " + (heure != null ? heure : "00:00:00"));
            long diff = System.currentTimeMillis() - dateNotif.getTime();
            long seconds = diff / 1000;
            long minutes = seconds / 60;
            long hours = minutes / 60;
            long days = hours / 24;
            if (days > 30) return (days / 30) + " mois";
            if (days > 0) return days + " jour(s)";
            if (hours > 0) return hours + " h";
            if (minutes > 0) return minutes + " min";
            return "A l'instant";
        } catch (Exception e) { return ""; }
    }

    private String getIconeType(String type) {
        if (type == null) return "bi-bell";
        if ("COMMENT".equals(type)) return "bi-chat-dots-fill";
        if ("REPLY".equals(type)) return "bi-reply-fill";
        if ("PUB_REACTION".equals(type)) return "bi-hand-thumbs-up-fill";
        if ("COMM_REACTION".equals(type)) return "bi-emoji-smile-fill";
        if ("MENTION".equals(type)) return "bi-at";
        if ("IDENTIFICATION".equals(type)) return "bi-tag-fill";
        return "bi-bell";
    }

    private String getIconeColor(String type) {
        if (type == null) return "#666";
        if ("COMMENT".equals(type)) return "#1a73e8";
        if ("REPLY".equals(type)) return "#34a853";
        if ("PUB_REACTION".equals(type)) return "#ea4335";
        if ("COMM_REACTION".equals(type)) return "#fbbc04";
        if ("MENTION".equals(type)) return "#9c27b0";
        if ("IDENTIFICATION".equals(type)) return "#ff6d00";
        return "#666";
    }
%>
<%
    UserEJB uNotif = (UserEJB) session.getAttribute("u");
    MapUtilisateur mapNotif = uNotif.getUser();
    int refuser = mapNotif.getRefuser();
    String ctx = request.getContextPath();

    // Action: marquer tout comme lu
    String action = request.getParameter("action");
    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        if ("toutlu".equals(action)) {
            Notification[] nonLus = (Notification[]) CGenUtil.rechercher(
                new Notification(), null, null, conn,
                " and idutilisateur = " + refuser + " and etat = 0");
            if (nonLus != null) {
                for (int i = 0; i < nonLus.length; i++) {
                    nonLus[i].setEtat(1);
                    nonLus[i].upDateToTable(conn);
                }
            }
            conn.commit();
        }

        // Charger les profils pour noms
        Profil[] allProfils = (Profil[]) CGenUtil.rechercher(new Profil(), null, null, conn, "");
        Map userNames = new HashMap();
        if (allProfils != null) {
            for (int i = 0; i < allProfils.length; i++) {
                userNames.put(String.valueOf(allProfils[i].getIdutilisateur()),
                    allProfils[i].getNom() + " " + allProfils[i].getPrenom());
            }
        }

        // Charger toutes les notifications
        Notification[] notifs = (Notification[]) CGenUtil.rechercher(
            new Notification(), null, null, conn,
            " and idutilisateur = " + refuser + " order by daty desc, heure desc");
        if (notifs == null) notifs = new Notification[0];

        int nbNonLu = 0;
        for (int i = 0; i < notifs.length; i++) {
            if (notifs[i].getEtat() == 0) nbNonLu++;
        }
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="bi bi-bell-fill"></i> Notifications</h1>
    </section>
    <section class="content">

        <!-- En-tete -->
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;">
            <div>
                <span style="font-size:14px;color:#666;">
                    <strong><%= notifs.length %></strong> notification(s)
                    <% if (nbNonLu > 0) { %>
                        &mdash; <span style="color:#e00;font-weight:bold;"><%= nbNonLu %> non lue(s)</span>
                    <% } %>
                </span>
            </div>
            <% if (nbNonLu > 0) { %>
            <a href="<%= ctx %>/pages/module.jsp?but=alumni/notifications.jsp&action=toutlu"
               style="padding:6px 14px;background:#1a73e8;color:#fff;border-radius:6px;text-decoration:none;font-size:13px;">
                <i class="bi bi-check2-all"></i> Tout marquer comme lu
            </a>
            <% } %>
        </div>

        <% if (notifs.length == 0) { %>
            <div style="text-align:center;padding:60px 20px;color:#999;background:#fff;border-radius:10px;border:1px solid #eee;">
                <i class="bi bi-bell-slash" style="font-size:48px;display:block;margin-bottom:15px;"></i>
                <p style="font-size:16px;">Aucune notification pour le moment</p>
            </div>
        <% } else { %>
            <div style="background:#fff;border-radius:10px;border:1px solid #eee;overflow:hidden;">
            <% for (int i = 0; i < notifs.length; i++) {
                Notification n = notifs[i];
                boolean nonLu = (n.getEtat() == 0);
                String bgColor = nonLu ? "#e8f4fd" : "#fff";
                String sourceNom = (String) userNames.get(n.getIdorigine());
                if (sourceNom == null) sourceNom = "";
                String lienNotif = n.getLien();
                String ecart = calculerEcart(n.getDaty() != null ? n.getDaty().toString() : null, n.getHeure());
                String icone = getIconeType(n.getTypenotif());
                String couleur = getIconeColor(n.getTypenotif());
            %>
                <div onclick="<%= lienNotif != null && !lienNotif.isEmpty() ? "window.location.href='" + lienNotif.replace("'", "\\'") + "'" : "" %>"
                     style="display:flex;align-items:flex-start;gap:12px;padding:14px 18px;background:<%= bgColor %>;border-bottom:1px solid #f0f0f0;cursor:<%= lienNotif != null ? "pointer" : "default" %>;transition:background 0.2s;"
                     onmouseover="this.style.background='#f5f5f5'" onmouseout="this.style.background='<%= bgColor %>'">

                    <!-- Icone -->
                    <div style="flex-shrink:0;width:42px;height:42px;background:<%= couleur %>15;border-radius:50%;display:flex;align-items:center;justify-content:center;">
                        <i class="bi <%= icone %>" style="font-size:18px;color:<%= couleur %>;"></i>
                    </div>

                    <!-- Contenu -->
                    <div style="flex:1;min-width:0;">
                        <div style="font-size:14px;line-height:1.5;color:#333;">
                            <%= n.getObjet() != null ? n.getObjet().replace("<", "&lt;").replace(">", "&gt;") : "" %>
                            <% if (nonLu) { %>
                                <span style="width:8px;height:8px;background:#1a73e8;border-radius:50%;display:inline-block;margin-left:6px;"></span>
                            <% } %>
                        </div>
                        <div style="font-size:12px;color:#999;margin-top:3px;">
                            <i class="bi bi-clock"></i> <%= ecart %>
                            <% if (n.getDaty() != null) { %> &mdash; <%= n.getDaty() %><% } %>
                        </div>
                    </div>
                </div>
            <% } %>
            </div>
        <% } %>

    </section>
</div>

<%
    } catch (Exception e) {
        e.printStackTrace();
%>
        <div style="background:#f2dede;padding:15px;border:1px solid #ebccd1;border-radius:6px;">
            <strong>Erreur:</strong> <%= e.getMessage() %>
        </div>
<%
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
