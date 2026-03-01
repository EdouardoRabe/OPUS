<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Notification" %>
<%@ page import="alumni.Profil" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.Evenement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.sql.PreparedStatement" %>
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
        if (type == null) return "#d0dce7";
        if ("COMMENT".equals(type)) return "#283a97";
        if ("REPLY".equals(type)) return "#b2d235";
        if ("PUB_REACTION".equals(type)) return "#fd3022";
        if ("COMM_REACTION".equals(type)) return "#e46a91";
        if ("MENTION".equals(type)) return "#536ae4";
        if ("IDENTIFICATION".equals(type)) return "#b2d235";
        return "#d0dce7";
    }
%>
<%
    UserEJB uNotif = (UserEJB) session.getAttribute("u");
    MapUtilisateur mapNotif = uNotif.getUser();
    int refuser = mapNotif.getRefuser();
    String nomConnecte = mapNotif.getNomuser() != null ? mapNotif.getNomuser() : "";
    String[] _partsConn = nomConnecte.trim().split("\\s+");
    String initialConnecte = (_partsConn.length > 0 && _partsConn[0].length() > 0)
            ? String.valueOf(Character.toUpperCase(_partsConn[0].charAt(0))) : "U";
    if (_partsConn.length > 1 && _partsConn[_partsConn.length - 1].length() > 0)
        initialConnecte += Character.toUpperCase(_partsConn[_partsConn.length - 1].charAt(0));
    String ctx = request.getContextPath();

    // Action: marquer tout comme lu
    String action = request.getParameter("action");
    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        if ("toutlu".equals(action)) {
            PreparedStatement psMark = conn.prepareStatement(
                "UPDATE notification SET etat = 1 WHERE idutilisateur = ? AND etat = 0");
            psMark.setInt(1, refuser);
            psMark.executeUpdate();
            psMark.close();
            conn.commit();
        }

        String _connPhotoUrl = "";
        String _connCoverUrl = "";
        Evenement[] _upEvents = new Evenement[0];
        ProfilLib[] _myProfils = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, conn, " and refuser=" + refuser);
        if (_myProfils != null && _myProfils.length > 0) {
            if (_myProfils[0].getPhotoProfil() != null && !_myProfils[0].getPhotoProfil().trim().isEmpty())
                _connPhotoUrl = ctx + "/" + _myProfils[0].getPhotoProfil().trim();
            if (_myProfils[0].getPhotoCouverture() != null && !_myProfils[0].getPhotoCouverture().trim().isEmpty())
                _connCoverUrl = ctx + "/" + _myProfils[0].getPhotoCouverture().trim();
        }
        _upEvents = (Evenement[]) CGenUtil.rechercher(new Evenement(), null, null, conn,
            " and datedebut >= CURRENT_DATE order by datedebut asc");
        if (_upEvents == null) _upEvents = new Evenement[0];

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

<!-- Notification styles extracted to external CSS (shared styles loaded globally via css.jsp) -->
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/pages/notifications-page.css" />

<div class="fa-layout">
    <aside class="fa-sidebar-left">
        <div class="fa-profile-card">
            <div class="fa-profile-cover"<%= !_connCoverUrl.isEmpty() ? " style=\"background:none;\"" : "" %>><% if (!_connCoverUrl.isEmpty()) { %><img src="<%= _connCoverUrl %>" alt="" style="width:100%;height:100%;object-fit:cover;display:block;"><% } %></div>
            <div class="fa-profile-body">
                <div class="fa-profile-avatar-wrap">
                    <div class="fa-avatar fa-avatar--lg"<%= !_connPhotoUrl.isEmpty() ? " style=\"background:transparent;\"" : "" %>><% if (!_connPhotoUrl.isEmpty()) { %><img src="<%= _connPhotoUrl %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= initialConnecte %><% } %></div>
                </div>
                <div class="fa-profile-name"><%= nomConnecte %></div>
                <hr class="fa-divider">
                <nav class="fa-profile-nav">
                    <a href="<%= ctx %>/pages/module.jsp?but=profil/voir.jsp&currentMenu=MENDYN000009" class="fa-nav-link">
                        <i class="bi bi-person-fill"></i>&nbsp;Mon profil
                    </a>
                    <a href="<%= ctx %>/pages/module.jsp?but=accueil.jsp" class="fa-nav-link">
                        <i class="bi bi-newspaper"></i>&nbsp;Fil d'actualité
                    </a>
                    <a href="<%= ctx %>/pages/module.jsp?but=alumni/notifications.jsp" class="fa-nav-link fa-nav-link--active">
                        <i class="bi bi-bell-fill"></i>&nbsp;Notifications
                    </a>
                    <a href="<%= ctx %>/pages/module.jsp?but=alumni/publications-enregistrees.jsp" class="fa-nav-link">
                        <i class="bi bi-bookmarks-fill"></i>&nbsp;Enregistrements
                    </a>
                </nav>
            </div>
        </div>
    </aside>

    <main class="fa-feed-center">
        <div class="notifications-card">
            <div class="notifications-header">
                <h1>
                    <span class="notifications-title-icon">
                        <i class="bi bi-bell-fill" style="color:#b2d235;"></i>
                    </span>
                    Notifications
                    <% if (nbNonLu > 0) { %>
                        <span class="notifications-badge"><%= nbNonLu %></span>
                    <% } %>
                </h1>
            </div>
            <div class="notifications-meta">
                <span>
                    <strong><%= notifs.length %></strong> notification(s)
                    <% if (nbNonLu > 0) { %>
                        &mdash; <span class="notifications-unread"><%= nbNonLu %> non lue(s)</span>
                    <% } %>
                </span>
                <% if (nbNonLu > 0) { %>
                    <a href="<%= ctx %>/pages/module.jsp?but=alumni/notifications.jsp&action=toutlu" class="notifications-mark-all">
                        <i class="bi bi-check2-all"></i>&nbsp;Tout marquer comme lu
                    </a>
                <% } %>
            </div>
            <div class="notifications-list">
                <% if (notifs.length == 0) { %>
                    <div class="notifications-empty">
                        <span><i class="bi bi-bell-slash"></i></span>
                        <p style="font-size:16px;color:#1c1e29;font-weight:600;margin:0;">Aucune notification pour le moment</p>
                        <p style="font-size:13px;color:#8a95a3;margin-top:6px;">Vous serez notifié(e) ici lors d'interactions.</p>
                    </div>
                <% } else { %>
                    <div class="notifications-list-inner">
                        <% for (int i = 0; i < notifs.length; i++) {
                            Notification n = notifs[i];
                            boolean nonLu = (n.getEtat() == 0);
                            String bgColor = nonLu ? "#eef1fb" : "#fff";
                            String sourceNom = (String) userNames.get(n.getIdorigine());
                            if (sourceNom == null) sourceNom = "";
                            String lienNotif = n.getLien();
                            String ecart = calculerEcart(n.getDaty() != null ? n.getDaty().toString() : null, n.getHeure());
                            String icone = getIconeType(n.getTypenotif());
                            String couleur = getIconeColor(n.getTypenotif());
                            String objetSafe = n.getObjet() != null ? n.getObjet().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") : "";
                            String sourceSafe = sourceNom.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
                        %>
                        <div class="notifications-item"
                             onclick="<%= lienNotif != null && !lienNotif.isEmpty() ? "marquerEtNaviguer('" + n.getIdnotification().replace("'", "\\'") + "','" + lienNotif.replace("'", "\\'") + "')" : "" %>"
                             style="background:<%= bgColor %>;<%= nonLu ? "border-left:3px solid #283a97;" : "border-left:3px solid transparent;" %>cursor:<%= lienNotif != null ? "pointer" : "default" %>;">
                            <div class="notification-icon"
                                 style="background:<%= couleur %>22;border-color:<%= couleur %>33;">
                                <i class="bi <%= icone %>" style="font-size:20px;color:<%= couleur %>;"></i>
                            </div>
                            <div class="notification-details">
                                <div class="notification-title<%= nonLu ? " notification-title--bold" : "" %>">
                                    <%= objetSafe %>
                                    <% if (nonLu) { %>
                                        <span class="notification-dot"></span>
                                    <% } %>
                                </div>
                                <div class="notification-meta">
                                    <i class="bi bi-clock" style="color:#536ae4;"></i>
                                    <span><%= ecart %></span>
                                    <% if (n.getDaty() != null) { %>
                                        <span style="color:#d0dce7;">&bull;</span>
                                        <span><%= n.getDaty() %></span>
                                    <% } %>
                                    <% if (!sourceSafe.isEmpty()) { %>
                                        <span class="notification-source">&middot; <%= sourceSafe %></span>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </div>
    </main>

    <aside class="fa-sidebar-right">
        <div class="fa-widget-card" id="widget-evenements">
            <div class="fa-widget-header">
                <i class="bi bi-calendar-event-fill fa-widget-icon"></i>
                <span class="fa-widget-title">Événements à venir</span>
            </div>
            <div class="fa-widget-body">
                <%
                    String[] _moisCourt = {"jan","fév","mar","avr","mai","jun","jul","aoû","sep","oct","nov","déc"};
                    int _evtMax = Math.min(_upEvents.length, 3);
                    if (_evtMax == 0) {
                %>
                <div style="padding:16px;text-align:center;color:#999;font-size:13px;">Aucun événement à venir</div>
                <% } else {
                    for (int _ei = 0; _ei < _evtMax; _ei++) {
                        Evenement _ev = _upEvents[_ei];
                        String _evDesc = _ev.getDescription() != null ? _ev.getDescription() : "Événement";
                        String _evDescSafe = _evDesc.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
                        if (_evDescSafe.length() > 40) _evDescSafe = _evDescSafe.substring(0, 40) + "...";
                        String _evDay = "--"; String _evMon = "---";
                        if (_ev.getDatedebut() != null) {
                            Calendar _cal = Calendar.getInstance();
                            _cal.setTime(_ev.getDatedebut());
                            _evDay = String.valueOf(_cal.get(Calendar.DAY_OF_MONTH));
                            _evMon = _moisCourt[_cal.get(Calendar.MONTH)];
                        }
                %>
                <div class="fa-event-item">
                    <div class="fa-event-date-badge">
                        <span class="fa-event-day"><%= _evDay %></span>
                        <span class="fa-event-month"><%= _evMon %></span>
                    </div>
                    <div class="fa-event-info">
                        <div class="fa-event-title"><%= _evDescSafe %></div>
                        <div class="fa-event-meta"><i class="bi bi-calendar-event"></i>&nbsp;<%= _ev.getDatedebut() %></div>
                    </div>
                </div>
                <% } } %>
            </div>
            <div class="fa-widget-footer">
                <a href="<%= ctx %>/pages/module.jsp?but=evenement/evenement-calendar.jsp" class="fa-widget-link">Voir tous les événements →</a>
            </div>
        </div>
    </aside>

</div>

<script>
function marquerEtNaviguer(idnotif, lien) {
    var ctx = '<%= request.getContextPath() %>';
    $.ajax({
        type: 'POST',
        url: ctx + '/pages/alumni/ajax/marquer-notification-lu.jsp',
        data: { idnotification: idnotif },
        complete: function() {
            if (lien) window.location.href = lien;
        }
    });
}
</script>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
        <div style="background:#fff0ef;padding:15px;border:1px solid #fd3022;border-radius:8px;color:#1c1e29;">
            <strong style="color:#fd3022;"><i class="bi bi-exclamation-triangle-fill"></i> Erreur :</strong> <%= e.getMessage() %>
        </div>
<%
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
