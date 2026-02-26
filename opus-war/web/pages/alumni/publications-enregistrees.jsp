<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Publicationenregistrement" %>
<%@ page import="alumni.Typepublication" %>
<%@ page import="alumni.Media" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    UserEJB uEnr = (UserEJB) session.getAttribute("u");
    MapUtilisateur mapEnr = uEnr.getUser();
    int refuserConnecte = mapEnr.getRefuser();
    String ctx = request.getContextPath();
    // Profil connecté — nom, initiales, photos sidebar
    String nomConnecte = mapEnr.getNomuser() != null ? mapEnr.getNomuser() : "";
    String[] _partsConn = nomConnecte.trim().split("\\s+");
    String initialConnecte = (_partsConn.length > 0 && _partsConn[0].length() > 0)
        ? String.valueOf(Character.toUpperCase(_partsConn[0].charAt(0))) : "U";
    if (_partsConn.length > 1 && _partsConn[_partsConn.length-1].length() > 0)
        initialConnecte += Character.toUpperCase(_partsConn[_partsConn.length-1].charAt(0));
    String _connPhotoUrl = "";
    String _connCoverUrl = "";
    try {
        Connection connSide = new UtilDB().GetConn();
        try {
            ProfilLib[] _myProfils = (ProfilLib[]) CGenUtil.rechercher(
                new ProfilLib(), null, null, connSide, " and refuser=" + refuserConnecte);
            if (_myProfils != null && _myProfils.length > 0) {
                if (_myProfils[0].getPhotoProfil() != null && !_myProfils[0].getPhotoProfil().trim().isEmpty())
                    _connPhotoUrl = ctx + "/" + _myProfils[0].getPhotoProfil().trim();
                if (_myProfils[0].getPhotoCouverture() != null && !_myProfils[0].getPhotoCouverture().trim().isEmpty())
                    _connCoverUrl = ctx + "/" + _myProfils[0].getPhotoCouverture().trim();
            }
        } finally { connSide.close(); }
    } catch (Exception _eSide) { /* ignore */ }
%>

<style>
    :root {
        --fa-bg: #f0f2f5;
        --fa-card-bg: #ffffff;
        --fa-border: #e4e6eb;
        --fa-text: #050505;
        --fa-text-secondary: #65676b;
        --itu-blue: #008BFF;
        --itu-dark: #1c1e29;
        --itu-violet: #5B23FF;
    }
    .fa-layout { display: grid; grid-template-columns: 220px minmax(0,1fr); gap: 16px; padding: 0; align-items: start; }
    @media(max-width:768px) { .fa-layout { grid-template-columns: 1fr; } .fa-sidebar-left { display: none; } }
    .fa-sidebar-left {
        position: sticky; top: 80px;
        height: calc(100vh - 96px); overflow-y: auto; overflow-x: hidden;
        overscroll-behavior: contain; padding-right: 6px;
        scrollbar-width: thin; scrollbar-color: rgba(96,110,122,.31) transparent;
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
    .fa-profile-card { background: var(--fa-card-bg); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.12); overflow: hidden; }
    .fa-profile-cover { height: 72px; background: linear-gradient(135deg, var(--itu-dark,#362F4F) 0%, var(--itu-violet,#5B23FF) 100%); }
    .fa-profile-body { padding: 0 16px 16px; }
    .fa-profile-avatar-wrap { margin-top: -36px; margin-bottom: 8px; }
    .fa-avatar {
        display: inline-flex; align-items: center; justify-content: center;
        border-radius: 50%; font-weight: 700; color: #fff; flex-shrink: 0;
        user-select: none;
        background: linear-gradient(135deg, var(--itu-dark,#362F4F) 0%, var(--itu-blue,#008BFF) 100%);
    }
    .fa-avatar--xs { width: 28px; height: 28px; font-size: 10px; }
    .fa-avatar--sm { width: 36px; height: 36px; font-size: 13px; }
    .fa-avatar--md { width: 44px; height: 44px; font-size: 16px; }
    .fa-avatar--lg { width: 72px; height: 72px; font-size: 26px; }
    .fa-profile-name { font-weight: 700; font-size: 16px; color: var(--fa-text); margin-bottom: 12px; }
    .fa-divider { border: none; border-top: 1px solid var(--fa-border); margin: 10px 0; }
    .fa-profile-nav { display: flex; flex-direction: column; gap: 2px; }
    .fa-nav-link { display: flex; align-items: center; gap: 10px; padding: 10px 12px; border-radius: 8px; color: var(--fa-text); text-decoration: none; font-size: 15px; transition: background .15s; }
    .fa-nav-link:hover { background: #f0f2f5; color: var(--itu-blue,#008BFF); }
    .fa-nav-link--active { background: #e7f3ff; color: var(--itu-blue,#008BFF); font-weight: 600; }
    .fa-nav-link i { font-size: 16px; }
</style>
<style>
    /* ===== SAVED PAGE - Facebook-style ===== */
    .saved-container { max-width: unset; margin: 0; padding: 0; }

    .saved-header {
        display: flex; align-items: center; gap: 14px;
        padding: 20px 0 16px 0;
    }
    .saved-header-icon {
        width: 44px; height: 44px; border-radius: 50%;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex; align-items: center; justify-content: center;
        color: #fff; font-size: 20px;
    }
    .saved-header h2 { margin: 0; font-size: 22px; font-weight: 700; color: #1d1d1d; }
    .saved-header .saved-count { font-size: 14px; color: #65676b; font-weight: 400; margin-left: 6px; }

    .saved-back-link {
        display: inline-flex; align-items: center; gap: 6px;
        font-size: 14px; font-weight: 600;
        color: var(--itu-blue, #008BFF); text-decoration: none;
        margin-bottom: 6px;
    }
    .saved-back-link:hover { text-decoration: underline; }

    .saved-label-all {
        font-size: 17px; font-weight: 700; color: #1d1d1d;
        margin: 6px 0 14px 0;
    }

    .saved-list { display: flex; flex-direction: column; gap: 0; }

    /* --- COMPACT CARD --- */
    .saved-card {
        display: flex; align-items: stretch; gap: 0;
        background: #fff; border-radius: 10px;
        box-shadow: 0 1px 3px rgba(0,0,0,.10);
        overflow: hidden; margin-bottom: 12px;
        transition: opacity 0.4s ease, transform 0.4s ease;
    }
    .saved-card:hover { box-shadow: 0 2px 8px rgba(0,0,0,.14); }

    /* Thumbnail */
    .saved-thumb {
        width: 170px; min-height: 140px; flex-shrink: 0;
        background: #e4e6eb; position: relative;
        display: flex; align-items: center; justify-content: center;
        overflow: hidden; cursor: pointer;
    }
    .saved-thumb img {
        width: 100%; height: 100%; object-fit: cover;
    }
    .saved-thumb-placeholder {
        color: #b0b3b8; font-size: 42px;
    }

    /* Content */
    .saved-content {
        flex: 1; padding: 14px 16px; display: flex;
        flex-direction: column; justify-content: space-between;
        min-width: 0;
    }
    .saved-title {
        font-size: 15px; font-weight: 700; color: #1d1d1d;
        margin: 0 0 4px 0;
        display: -webkit-box; -webkit-line-clamp: 2;
        -webkit-box-orient: vertical; overflow: hidden;
        text-overflow: ellipsis; line-height: 1.35;
        cursor: pointer;
    }
    .saved-title:hover { color: var(--itu-blue, #008BFF); }

    .saved-meta {
        font-size: 13px; color: #65676b; margin-bottom: 6px;
    }
    .saved-meta .saved-type-badge {
        background: #e4e6eb; color: #65676b;
        padding: 1px 8px; border-radius: 10px;
        font-size: 12px; font-weight: 500;
    }

    .saved-author {
        display: flex; align-items: center; gap: 8px;
        font-size: 13px; color: #65676b; margin-bottom: 10px;
    }
    .saved-author-avatar {
        width: 24px; height: 24px; border-radius: 50%;
        background: #d8dadf; display: flex; align-items: center;
        justify-content: center; font-size: 11px; font-weight: 700;
        color: #fff; overflow: hidden; flex-shrink: 0;
    }
    .saved-author-avatar img { width: 100%; height: 100%; object-fit: cover; }
    .saved-author strong { color: #1d1d1d; }

    /* Actions row */
    .saved-actions {
        display: flex; align-items: center; gap: 8px; margin-top: auto;
    }
    .saved-btn-unsave {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 7px 16px; border-radius: 8px;
        background: #e4e6eb; color: #1d1d1d;
        border: none; font-size: 13px; font-weight: 600;
        cursor: pointer; transition: background .2s;
    }
    .saved-btn-unsave:hover { background: #d0d2d6; }
    .saved-btn-more {
        width: 34px; height: 34px; border-radius: 50%;
        background: #e4e6eb; border: none; display: flex;
        align-items: center; justify-content: center;
        font-size: 16px; color: #65676b; cursor: pointer;
        transition: background .2s;
    }
    .saved-btn-more:hover { background: #d0d2d6; }

    /* Empty */
    .saved-empty {
        text-align: center; padding: 60px 20px; color: #65676b;
    }
    .saved-empty i { font-size: 52px; margin-bottom: 14px; display: block; color: #c0c0c0; }
    .saved-empty p { font-size: 15px; line-height: 1.5; }

    /* Divider */
    .saved-divider {
        height: 1px; background: #e4e6eb; margin: 0;
    }
</style>

<div class="fa-layout">

    <!-- ===== COLONNE GAUCHE : Profil ===== -->
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
                        <i class="bi bi-newspaper"></i>&nbsp;Fil d&apos;actualit&eacute;
                    </a>
                    <a href="<%= ctx %>/pages/module.jsp?but=alumni/notifications.jsp" class="fa-nav-link">
                        <i class="bi bi-bell-fill"></i>&nbsp;Notifications
                    </a>
                    <a href="<%= ctx %>/pages/module.jsp?but=alumni/publications-enregistrees.jsp" class="fa-nav-link fa-nav-link--active">
                        <i class="bi bi-bookmarks-fill"></i>&nbsp;Enregistrements
                    </a>
                </nav>
            </div>
        </div>
    </aside>

    <!-- ===== CONTENU PRINCIPAL ===== -->
    <main class="fa-feed-center">
<div class="saved-container">

    <%
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            // 1) Charger les enregistrements du user connecte
            Publicationenregistrement[] enrs = (Publicationenregistrement[]) CGenUtil.rechercher(
                    new Publicationenregistrement(), null, null, conn,
                    " and idutilisateur = " + refuserConnecte + " order by daty desc, heure desc");
            if (enrs == null) enrs = new Publicationenregistrement[0];

            // 2) Charger les publications correspondantes (actives) + garder la date d'enregistrement
            List pubList = new ArrayList();
            List enrDateList = new ArrayList();
            for (int i = 0; i < enrs.length; i++) {
                Publication[] pa = (Publication[]) CGenUtil.rechercher(
                        new Publication(), null, null, conn,
                        " and idpublication = '" + enrs[i].getIdpublication() + "' and etat = 1");
                if (pa != null && pa.length > 0) {
                    pubList.add(pa[0]);
                    String enrDate = "";
                    if (enrs[i].getDaty() != null) enrDate = enrs[i].getDaty().toString();
                    if (enrs[i].getHeure() != null && !enrs[i].getHeure().isEmpty()) enrDate += " \u00e0 " + enrs[i].getHeure();
                    enrDateList.add(enrDate);
                }
            }
            Publication[] pubs = (Publication[]) pubList.toArray(new Publication[0]);

            // 3) Types de publication
            Typepublication[] typesPub = (Typepublication[]) CGenUtil.rechercher(
                    new Typepublication(), null, null, " order by idtypepublication");
            if (typesPub == null) typesPub = new Typepublication[0];

            // 4) Profils lookup
            ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(
                    new ProfilLib(), null, null, conn, "");
            Map userNames = new HashMap();
            Map userPhotos = new HashMap();
            if (allProfils != null) {
                for (int i = 0; i < allProfils.length; i++) {
                    Integer _key = new Integer(allProfils[i].getIdutilisateur());
                    userNames.put(_key, allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                    if (allProfils[i].getPhotoProfil() != null && !allProfils[i].getPhotoProfil().trim().isEmpty())
                        userPhotos.put(_key, ctx + "/" + allProfils[i].getPhotoProfil().trim());
                }
            }
    %>

    <div class="saved-header">
        <div class="saved-header-icon"><i class="bi bi-bookmark-fill"></i></div>
        <h2>Enregistrements <span class="saved-count" id="saved-count">(<%= pubs.length %>)</span></h2>
    </div>

    <div class="saved-divider"></div>
    <div class="saved-label-all">Tous</div>

    <div class="saved-list" id="saved-list">
    <% if (pubs.length == 0) { %>
        <div class="saved-empty" id="saved-empty-msg">
            <i class="bi bi-bookmarks"></i>
            <p>Vous n'avez aucune publication enregistr&eacute;e.</p>
        </div>
    <% } %>

    <% for (int p = 0; p < pubs.length; p++) {
            Publication pub = pubs[p];
            String idpub = pub.getIdpublication();
            String enrDate = (String) enrDateList.get(p);

            // Auteur
            String auteur = (String) userNames.get(new Integer(pub.getIdutilisateur()));
            if (auteur == null) auteur = "Utilisateur";
            String authorPhoto = (String) userPhotos.get(new Integer(pub.getIdutilisateur()));

            // Initiales auteur
            String[] _pa = auteur.trim().split("\\s+");
            String initA = String.valueOf(Character.toUpperCase(_pa[0].charAt(0)));
            if (_pa.length > 1) initA += Character.toUpperCase(_pa[_pa.length - 1].charAt(0));

            // Description tronquee comme titre
            String desc = pub.getDescritpion();
            String descTitle = "";
            if (desc != null && !desc.trim().isEmpty()) {
                descTitle = desc.replace("\n", " ").replace("\r", " ").trim();
                if (descTitle.length() > 120) descTitle = descTitle.substring(0, 117) + "...";
                descTitle = descTitle.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
            } else {
                descTitle = "Publication sans texte";
            }

            // Type publication libelle
            String typePubLib = "";
            String typePubId = pub.getIdtypepublication();
            if (typePubId != null) {
                for (int t = 0; t < typesPub.length; t++) {
                    if (typesPub[t].getIdtypepublication().equals(typePubId)) { typePubLib = typesPub[t].getLibelle(); break; }
                }
            }

            // Premier media (thumbnail)
            Media[] medias = (Media[]) CGenUtil.rechercher(
                    new Media(), null, null, conn, " and idpublication = '" + idpub + "'");
            String thumbUrl = "";
            if (medias != null && medias.length > 0 && medias[0].getMediaurl() != null) {
                String mUrl = medias[0].getMediaurl();
                thumbUrl = mUrl.startsWith("http") ? mUrl : ctx + "/UploadDownloadFileServlet?fileName=" + java.net.URLEncoder.encode(mUrl, "UTF-8");
            }
    %>
    <!-- SAVED CARD -->
    <div class="saved-card" id="pub-<%= idpub %>">
        <div class="saved-thumb" onclick="window.location.href='<%= ctx %>/pages/module.jsp?but=accueil.jsp&highlight=<%= idpub %>'">
            <% if (!thumbUrl.isEmpty()) { %>
                <img src="<%= thumbUrl %>" alt="">
            <% } else { %>
                <span class="saved-thumb-placeholder"><i class="bi bi-file-text"></i></span>
            <% } %>
        </div>
        <div class="saved-content">
            <div>
                <p class="saved-title" onclick="window.location.href='<%= ctx %>/pages/module.jsp?but=accueil.jsp&highlight=<%= idpub %>'"><%= descTitle %></p>
                <div class="saved-meta">
                    <% if (!typePubLib.isEmpty()) { %><span class="saved-type-badge"><%= typePubLib %></span> &middot; <% } %>
                    Enregistr&eacute; le <%= enrDate %>
                </div>
                <div class="saved-author">
                    <div class="saved-author-avatar">
                        <% if (authorPhoto != null) { %><img src="<%= authorPhoto %>" alt=""><% } else { %><%= initA %><% } %>
                    </div>
                    Publication de <strong><%= auteur %></strong>
                </div>
            </div>
            <div class="saved-actions">
                <button class="saved-btn-unsave" onclick="unsavePublication('<%= idpub %>')" title="Annuler l'enregistrement">
                    <i class="bi bi-bookmark-fill"></i> Annuler l'enregistrement
                </button>
                <button class="saved-btn-more" onclick="window.location.href='<%= ctx %>/pages/module.jsp?but=accueil.jsp&highlight=<%= idpub %>'" title="Voir la publication">
                    <i class="bi bi-box-arrow-up-right"></i>
                </button>
            </div>
        </div>
    </div>
    <% } // fin for %>
    </div>

    <%
        } catch (Exception e) {
            e.printStackTrace();
    %>
    <div style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:14px;color:#856404;">
        <i class="bi bi-exclamation-triangle-fill"></i>&nbsp;Erreur : <%= e.getMessage() %>
    </div>
    <%
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception _x) {}
        }
    %>
</div>
    </main>
</div>

<script>
    var CTX = '<%= ctx %>';
    function unsavePublication(idpub) {
        fetch(CTX + '/pages/alumni/ajax/save-publication.jsp?idpublication=' + encodeURIComponent(idpub))
        .then(function(r) { return r.json(); }).then(function(d) {
            if (d.success && !d.saved) {
                var card = document.getElementById('pub-' + idpub);
                if (card) {
                    card.style.opacity = '0';
                    card.style.transform = 'scale(0.96)';
                    setTimeout(function() {
                        card.remove();
                        // Update count
                        var cards = document.querySelectorAll('.saved-card');
                        var countEl = document.getElementById('saved-count');
                        if (countEl) countEl.textContent = '(' + cards.length + ')';
                        // Show empty if 0
                        if (cards.length === 0) {
                            var list = document.getElementById('saved-list');
                            if (list) {
                                list.innerHTML = '<div class="saved-empty"><i class="bi bi-bookmarks"></i><p>Vous n\'avez aucune publication enregistr\u00e9e.</p></div>';
                            }
                        }
                    }, 400);
                }
                if (typeof Swal !== 'undefined') Swal.fire({toast:true,position:'top-end',icon:'success',title:'Enregistrement annul\u00e9',timer:1500,showConfirmButton:false});
            } else if (d.success && d.saved) {
                if (typeof Swal !== 'undefined') Swal.fire({toast:true,position:'top-end',icon:'info',title:'Publication enregistr\u00e9e',timer:1500,showConfirmButton:false});
            } else {
                alert('Erreur: ' + (d.error || 'Inconnue'));
            }
        }).catch(function(err) { alert('Erreur r\u00e9seau: ' + err); });
    }
</script>
