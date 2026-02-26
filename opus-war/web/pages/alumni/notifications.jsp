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

<style>
    :root {
        --fa-bg: #f0f2f5;
        --fa-card-bg: #ffffff;
        --fa-border: #e4e6eb;
        --fa-text: #050505;
        --fa-text-secondary: #65676b;
    }
    .fa-layout {
        display: grid;
        grid-template-columns: 220px minmax(0,1fr) 220px;
        gap: 16px;
        padding: 0;
        align-items: start;
    }
    @media(max-width:1000px) {
        .fa-layout { grid-template-columns: 200px 1fr; }
        .fa-sidebar-right { display: none; }
    }
    @media(max-width:768px) {
        .fa-layout { grid-template-columns: 1fr; }
        .fa-sidebar-left { display: none; }
    }
    .fa-sidebar-right { position: sticky; top: 80px; }
    .fa-sidebar-left {
        position: sticky;
        top: 80px;
        height: calc(100vh - 96px);
        overflow-y: auto;
        overflow-x: hidden;
        overscroll-behavior: contain;
        padding-right: 6px;
        scrollbar-width: thin;
        scrollbar-color: rgba(96, 110, 122, 0.31) transparent;
    }
    .fa-sidebar-left::-webkit-scrollbar { width: 5px; }
    .fa-sidebar-left::-webkit-scrollbar-track {
        background: rgba(0,0,0,.04);
        border-radius: 999px;
        margin: 8px 0;
    }
    .fa-sidebar-left::-webkit-scrollbar-thumb {
        background: linear-gradient(180deg, var(--itu-blue,#008BFF) 0%, var(--itu-violet,#5B23FF) 100%);
        border-radius: 999px;
        border: 1px solid rgba(255,255,255,.6);
        box-shadow: 0 0 4px rgba(0,139,255,.25);
        transition: opacity .2s;
        opacity: .6;
    }
    .fa-sidebar-left::-webkit-scrollbar-thumb:hover {
        opacity: 1;
        box-shadow: 0 0 8px rgba(0,139,255,.45);
    }
    .fa-feed-center { display: flex; flex-direction: column; gap: 12px; min-width: 0; }
    .fa-widget-card {
        background: var(--fa-card-bg);
        border-radius: 12px;
        box-shadow: 0 1px 4px rgba(0,0,0,.12);
        overflow: hidden;
    }
    .fa-widget-header {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 14px 16px 10px;
        border-bottom: 1px solid var(--fa-border);
    }
    .fa-widget-icon { font-size: 16px; color: var(--itu-blue,#008BFF); }
    .fa-widget-title { font-weight: 700; font-size: 15px; color: var(--fa-text); }
    .fa-widget-body { padding: 8px 0; }
    .fa-widget-footer { padding: 8px 16px 12px; border-top: 1px solid var(--fa-border); }
    .fa-widget-link { font-size: 13px; color: var(--itu-blue,#008BFF); text-decoration: none; font-weight: 600; }
    .fa-widget-link:hover { text-decoration: underline; }
    .fa-event-item {
        display: flex;
        align-items: flex-start;
        gap: 10px;
        padding: 8px 16px;
        transition: background .15s;
        cursor: pointer;
    }
    .fa-event-item:hover { background: #f0f2f5; }
    .fa-event-date-badge {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-width: 40px;
        background: #e7f3ff;
        border-radius: 8px;
        padding: 4px 6px;
        flex-shrink: 0;
    }
    .fa-event-day { font-weight: 700; font-size: 16px; color: var(--itu-blue,#008BFF); line-height: 1.1; }
    .fa-event-month { font-size: 10px; color: var(--itu-blue,#008BFF); text-transform: uppercase; font-weight: 600; }
    .fa-event-info { flex: 1; min-width: 0; }
    .fa-event-title { font-size: 13px; font-weight: 600; color: var(--fa-text); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .fa-event-meta { font-size: 11px; color: var(--fa-text-secondary); margin-top: 2px; display: flex; align-items: center; gap: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .fa-avatar {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        font-weight: 700;
        color: #fff;
        flex-shrink: 0;
        user-select: none;
        background: linear-gradient(135deg, var(--itu-dark,#362F4F) 0%, var(--itu-blue,#008BFF) 100%);
    }
    .fa-avatar--lg { width: 72px; height: 72px; font-size: 26px; }
    .fa-avatar--sm { width: 36px; height: 36px; font-size: 13px; }
    .fa-profile-card { background: var(--fa-card-bg); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.12); overflow: hidden; }
    .fa-profile-cover { height: 72px; background: linear-gradient(135deg, var(--itu-dark,#362F4F) 0%, var(--itu-violet,#5B23FF) 100%); }
    .fa-profile-body { padding: 0 16px 16px; }
    .fa-profile-avatar-wrap { margin-top: -36px; margin-bottom: 8px; }
    .fa-profile-name { font-weight: 700; font-size: 16px; color: var(--fa-text); margin-bottom: 12px; }
    .fa-divider { border: none; border-top: 1px solid var(--fa-border); margin: 10px 0; }
    .fa-profile-nav { display: flex; flex-direction: column; gap: 2px; }
    .fa-nav-link {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        border-radius: 8px;
        color: var(--fa-text);
        text-decoration: none;
        font-size: 15px;
        transition: background .15s;
    }
    .fa-nav-link:hover { background: #f0f2f5; color: var(--itu-blue,#008BFF); }
    .fa-nav-link--active { background: #e7f3ff; color: var(--itu-blue,#008BFF); font-weight: 600; }
    .notifications-card { background: #fff; border-radius: 12px; box-shadow: 0 2px 8px rgba(28,30,41,0.06); overflow: hidden; }
    .notifications-header { background: #1c1e29; padding: 22px 24px; }
    .notifications-header h1 { margin: 0; font-size: 20px; display: flex; align-items: center; gap: 10px; color: #fff; }
    .notifications-title-icon { background: #283a97; border-radius: 8px; padding: 6px 10px; display: inline-flex; align-items: center; justify-content: center; }
    .notifications-badge { background: #fd3022; color: #fff; font-size: 12px; font-weight: 700; padding: 2px 8px; border-radius: 20px; margin-left: 4px; }
    .notifications-meta { display: flex; justify-content: space-between; align-items: center; padding: 18px 24px 10px; gap: 12px; font-size: 14px; color: #1c1e29; flex-wrap: wrap; }
    .notifications-unread { color: #fd3022; font-weight: 700; }
    .notifications-mark-all {
        padding: 7px 16px;
        background: #283a97;
        color: #fff;
        border-radius: 8px;
        text-decoration: none;
        font-size: 13px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        box-shadow: 0 2px 6px rgba(40,58,151,0.18);
        transition: background 0.2s;
    }
    .notifications-mark-all:hover { background: #536ae4; }
    .notifications-list { background: #f4f6fb; padding: 0 0 16px; }
    .notifications-empty {
        text-align: center;
        padding: 60px 20px;
        background: #fff;
        border-radius: 12px;
        border: 1px solid #d0dce7;
        margin: 0 16px;
    }
    .notifications-empty span {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 72px;
        height: 72px;
        background: #1c1e29;
        border-radius: 50%;
        margin-bottom: 18px;
        font-size: 36px;
        color: #d0dce7;
    }
    .notifications-list-inner {
        background: #fff;
        border-radius: 12px;
        border: 1px solid #d0dce7;
        margin: 0 16px 16px;
        overflow: hidden;
    }
    .notifications-item {
        display: flex;
        align-items: flex-start;
        gap: 14px;
        padding: 16px 20px;
        border-bottom: 1px solid #e8edf4;
        transition: background 0.2s;
    }
    .notifications-item:hover { background: #f0f3fa; }
    .notifications-list-inner .notifications-item:last-child { border-bottom: none; }
    .notification-icon {
        flex-shrink: 0;
        width: 44px;
        height: 44px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2px solid transparent;
    }
    .notification-details { flex: 1; min-width: 0; }
    .notification-title {
        font-size: 14px;
        line-height: 1.55;
        color: #1c1e29;
        font-weight: 400;
    }
    .notification-title--bold { font-weight: 600; }
    .notification-dot { width: 8px; height: 8px; background: #283a97; border-radius: 50%; display: inline-block; margin-left: 7px; vertical-align: middle; }
    .notification-meta {
        font-size: 12px;
        color: #8a95a3;
        margin-top: 5px;
        display: flex;
        align-items: center;
        gap: 5px;
        flex-wrap: wrap;
    }
    .notification-source {
        margin-left: 2px;
        font-weight: 600;
    }
</style>

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
