<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Signalementpublicationlib" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.Typepublication" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    user.UserEJB uEjb = (user.UserEJB) session.getValue("u");
    historique.MapUtilisateur mapU = uEjb.getUser();
    int refuserConnecte = mapU.getRefuser();
    String nomConnecte = mapU.getNomuser() != null ? mapU.getNomuser() : "";
    String ctx = request.getContextPath();
    String lienBase = (String) session.getValue("lien");

    // Initiales du connecte
    String[] _partsConn = nomConnecte.trim().split("\\s+");
    String initialConnecte = (_partsConn.length > 0 && _partsConn[0].length() > 0)
            ? String.valueOf(Character.toUpperCase(_partsConn[0].charAt(0))) : "U";
    if (_partsConn.length > 1 && _partsConn[_partsConn.length - 1].length() > 0)
        initialConnecte += Character.toUpperCase(_partsConn[_partsConn.length - 1].charAt(0));

    String roleConnecte = mapU.getIdrole() != null ? mapU.getIdrole() : "";
    boolean isMod = "md".equals(roleConnecte);

    String idsignalement = request.getParameter("idsignalement");

    // --- Action POST : supprimer publication (etat=0) ---
    String actionMsg = null;
    String actionErr = null;
    String actionSup = request.getParameter("action");
    String idpubSup = request.getParameter("idpublication");
    if ("supprimerPublication".equals(actionSup) && idpubSup != null && !idpubSup.isEmpty()) {
        if (!isMod) {
            actionErr = "Vous n'avez pas les droits pour effectuer cette action.";
        } else {
            Connection cSup = null;
            try {
                cSup = new UtilDB().GetConn();
                String reqSup = "UPDATE publication SET etat = 0 WHERE idpublication = '" + idpubSup + "'";
                new Publication().updateToTableDirecte(reqSup, cSup);
                actionMsg = "Publication supprim\u00e9e avec succ\u00e8s.";
            } catch (Exception exSup) {
                actionErr = "Erreur lors de la suppression : " + exSup.getMessage();
            } finally {
                if (cSup != null) try { cSup.close(); } catch (Exception ignored) {}
            }
        }
    }

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        // --- Charger le signalement ---
        Signalementpublicationlib[] sigs = (Signalementpublicationlib[]) CGenUtil.rechercher(
                new Signalementpublicationlib(), null, null, conn,
                " and idsignalement = '" + idsignalement + "'");
        if (sigs == null || sigs.length == 0) {
%>
<div style="max-width:460px;margin:40px auto;text-align:center;padding:40px 30px;background:#fff;border-radius:16px;border:1px solid #e9eef6;box-shadow:0 1px 8px rgba(15,23,42,.08);">
    <div style="width:56px;height:56px;border-radius:14px;background:#fee2e2;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;">
        <i class="fa fa-exclamation-triangle" style="font-size:1.5rem;color:#dc3545;"></i>
    </div>
    <div style="font-size:1rem;font-weight:700;color:#1e293b;margin-bottom:6px;">Signalement introuvable</div>
    <div style="font-size:0.85rem;color:#94a3b8;margin-bottom:20px;">ID : <%= idsignalement %></div>
    <a href="<%= lienBase %>?but=mod/gestion-signalements.jsp"
       style="display:inline-flex;align-items:center;gap:7px;padding:8px 18px;border-radius:8px;background:#dc3545;color:#fff;font-size:0.85rem;font-weight:600;text-decoration:none;">
        <i class="fa fa-arrow-left"></i> Retour &agrave; la liste
    </a>
</div>
<%
            return;
        }
        Signalementpublicationlib sig = sigs[0];

        // --- Photo profil connecte ---
        String _connPhotoUrl = "";
        ProfilLib[] _myProfils = (ProfilLib[]) CGenUtil.rechercher(
                new ProfilLib(), null, null, conn, " and refuser=" + refuserConnecte);
        if (_myProfils != null && _myProfils.length > 0) {
            if (_myProfils[0].getPhotoProfil() != null && !_myProfils[0].getPhotoProfil().trim().isEmpty())
                _connPhotoUrl = ctx + "/" + _myProfils[0].getPhotoProfil().trim();
        }

        // --- Charger la publication liee ---
        Publication[] pubs = (Publication[]) CGenUtil.rechercher(
                new Publication(), null, null, conn,
                " and idpublication = '" + sig.getIdpublication() + "'");

        // --- Charger types de reactions ---
        Reactiontype[] reactTypes = (Reactiontype[]) CGenUtil.rechercher(
                new Reactiontype(), null, null, conn, " order by idreactiontype");
        if (reactTypes == null) reactTypes = new Reactiontype[0];

        // --- Charger types de publication ---
        Typepublication[] typesPub = (Typepublication[]) CGenUtil.rechercher(
                new Typepublication(), null, null, conn, " order by idtypepublication");
        if (typesPub == null) typesPub = new Typepublication[0];

        // --- Charger tous les profils pour lookup ---
        ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(
                new ProfilLib(), null, null, conn, "");
        Map userNames = new HashMap();
        Map userPhotos = new HashMap();
        Map userProfils = new HashMap();
        Map userBanned = new HashMap();
        if (allProfils != null) {
            for (int i = 0; i < allProfils.length; i++) {
                Integer _key = new Integer(allProfils[i].getIdutilisateur());
                userNames.put(_key, allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                if (allProfils[i].getPhotoProfil() != null && !allProfils[i].getPhotoProfil().trim().isEmpty())
                    userPhotos.put(_key, ctx + "/" + allProfils[i].getPhotoProfil().trim());
                if (allProfils[i].getIdprofil() != null)
                    userProfils.put(_key, allProfils[i].getIdprofil());
                if (allProfils[i].getEstactif() == 0)
                    userBanned.put(_key, Boolean.TRUE);
            }
        }
%>

<!-- ═══ STYLES PAGE ═══ -->
<style>
.dsig-page { max-width: 820px; margin: 0 auto; }
.dsig-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 24px;
    flex-wrap: wrap;
    gap: 12px;
}
.dsig-header-left { display: flex; align-items: center; gap: 14px; }
.dsig-flag-icon {
    width: 46px; height: 46px; border-radius: 12px; flex-shrink: 0;
    background: linear-gradient(135deg,#dc3545,#c82333);
    display: flex; align-items: center; justify-content: center;
}
.dsig-flag-icon i { color: #fff; font-size: 1.3rem; }
.dsig-header-title { font-size: 1.15rem; font-weight: 700; color: #1e293b; line-height: 1.2; }
.dsig-header-sub { font-size: 0.8rem; color: #94a3b8; margin-top: 2px; }
.dsig-back-btn {
    display: inline-flex; align-items: center; gap: 7px;
    padding: 7px 16px; border-radius: 8px;
    border: 1px solid #dde3ec; background: #fff;
    font-size: 0.84rem; font-weight: 600; color: #374151;
    text-decoration: none; transition: background .15s, border-color .15s;
}
.dsig-back-btn:hover { background: #f8fafc; border-color: #b0b8c8; color: #111; text-decoration: none; }
/* Flash */
.dsig-flash {
    display: flex; align-items: center; gap: 10px;
    padding: 12px 16px; border-radius: 10px;
    font-size: 0.88rem; font-weight: 500; margin-bottom: 18px;
}
.dsig-flash-ok  { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; }
.dsig-flash-err { background: #fff1f2; border: 1px solid #fecdd3; color: #991b1b; }
/* Info card */
.dsig-info-card {
    background: #fff; border-radius: 14px;
    border: 1px solid #e9eef6;
    box-shadow: 0 1px 6px rgba(15,23,42,.07);
    margin-bottom: 22px; overflow: hidden;
}
.dsig-card-head {
    display: flex; align-items: center; gap: 10px;
    padding: 14px 20px; border-bottom: 1px solid #f1f5f9;
    background: #fafbfc;
}
.dsig-card-head-icon {
    width: 30px; height: 30px; border-radius: 8px;
    background: #fee2e2; color: #dc3545;
    display: flex; align-items: center; justify-content: center; font-size: .9rem;
}
.dsig-card-head-title { font-size: 0.92rem; font-weight: 700; color: #374151; }
.dsig-info-grid {
    display: grid; grid-template-columns: 1fr 1fr;
    gap: 0;
}
@media (max-width: 540px) { .dsig-info-grid { grid-template-columns: 1fr; } }
.dsig-info-row {
    display: flex; flex-direction: column; gap: 3px;
    padding: 14px 20px; border-bottom: 1px solid #f1f5f9;
    border-right: 1px solid #f1f5f9;
}
.dsig-info-row:nth-child(even) { border-right: none; }
.dsig-info-row:nth-last-child(-n+2) { border-bottom: none; }
.dsig-info-label {
    font-size: 0.72rem; font-weight: 700; letter-spacing: .05em;
    text-transform: uppercase; color: #94a3b8;
}
.dsig-info-value { font-size: 0.9rem; font-weight: 500; color: #1e293b; }
.dsig-motif-badge {
    display: inline-block; padding: 3px 11px; border-radius: 10px;
    background: #fee2e2; color: #991b1b; font-size: 0.82em; font-weight: 700;
}
/* Section publication */
.dsig-pub-card {
    background: #fff; border-radius: 14px;
    border: 1px solid #e9eef6;
    box-shadow: 0 1px 6px rgba(15,23,42,.07);
    overflow: hidden; margin-bottom: 22px;
}
.dsig-pub-head {
    display: flex; align-items: center; gap: 10px;
    padding: 14px 20px; border-bottom: 1px solid #f1f5f9;
    background: #fafbfc;
}
.dsig-pub-head-icon {
    width: 30px; height: 30px; border-radius: 8px;
    background: #e0e7ff; color: #4f46e5;
    display: flex; align-items: center; justify-content: center; font-size: .9rem;
}
.dsig-pub-head-title { font-size: 0.92rem; font-weight: 700; color: #374151; }
.dsig-pub-body { padding: 20px; }
.dsig-danger-zone {
    margin-top: 16px; padding: 14px 16px;
    background: #fff1f2; border: 1px solid #fecdd3; border-radius: 10px;
    display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;
}
.dsig-danger-zone-msg { font-size: 0.85rem; color: #991b1b; font-weight: 500; }
.dsig-deleted-notice {
    margin-top: 16px; padding: 12px 16px;
    background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px;
    font-size: 0.85rem; color: #92400e; font-weight: 500;
    display: flex; align-items: center; gap: 8px;
}
.dsig-pub-missing {
    padding: 40px 20px; text-align: center; color: #94a3b8;
}
.dsig-pub-missing i { font-size: 2rem; display: block; margin-bottom: 10px; opacity: .5; }
.dsig-pub-missing p { font-size: 0.9rem; margin: 0; }
</style>

<div class="dsig-page">

<!-- ═══ MESSAGES FLASH ═══ -->
<% if (actionMsg != null) { %>
<div class="dsig-flash dsig-flash-ok">
    <i class="fa fa-check-circle"></i><%= actionMsg %>
</div>
<% } %>
<% if (actionErr != null) { %>
<div class="dsig-flash dsig-flash-err">
    <i class="fa fa-exclamation-triangle"></i><%= actionErr %>
</div>
<% } %>

<!-- ═══ PAGE HEADER ═══ -->
<div class="dsig-header">
    <div class="dsig-header-left">
        <div class="dsig-flag-icon"><i class="fa fa-flag"></i></div>
        <div>
            <div class="dsig-header-title">D&eacute;tail du signalement</div>
            <div class="dsig-header-sub">#<%= sig.getIdsignalement() %> &mdash; <%= sig.getDaty() != null ? sig.getDaty() : "" %></div>
        </div>
    </div>
    <a href="<%= lienBase %>?but=mod/gestion-signalements.jsp" class="dsig-back-btn">
        <i class="fa fa-arrow-left"></i> Retour &agrave; la liste
    </a>
</div>

<!-- ═══ INFORMATIONS DU SIGNALEMENT ═══ -->
<div class="dsig-info-card">
    <div class="dsig-card-head">
        <div class="dsig-card-head-icon"><i class="fa fa-info-circle"></i></div>
        <span class="dsig-card-head-title">Informations du signalement</span>
    </div>
    <div class="dsig-info-grid">
        <div class="dsig-info-row">
            <span class="dsig-info-label">ID</span>
            <span class="dsig-info-value">#<%= sig.getIdsignalement() %></span>
        </div>
        <div class="dsig-info-row">
            <span class="dsig-info-label">Motif</span>
            <span class="dsig-info-value">
                <span class="dsig-motif-badge"><%= sig.getMotiflibelle() != null ? sig.getMotiflibelle() : "&mdash;" %></span>
            </span>
        </div>
        <div class="dsig-info-row">
            <span class="dsig-info-label">Signalant</span>
            <span class="dsig-info-value"><%= sig.getNomsignalant() != null ? sig.getNomsignalant() : "&mdash;" %></span>
        </div>
        <div class="dsig-info-row">
            <span class="dsig-info-label">Signal&eacute;</span>
            <span class="dsig-info-value"><%= sig.getNomsignale() != null ? sig.getNomsignale() : "&mdash;" %></span>
        </div>
        <div class="dsig-info-row">
            <span class="dsig-info-label">Date</span>
            <span class="dsig-info-value">
                <i class="fa fa-calendar" style="margin-right:5px;color:#94a3b8;"></i><%= sig.getDaty() != null ? sig.getDaty() : "&mdash;" %>
                <% if (sig.getHeure() != null && !sig.getHeure().isEmpty()) { %>
                &ensp;<i class="fa fa-clock-o" style="margin-right:3px;color:#94a3b8;"></i><%= sig.getHeure() %>
                <% } %>
            </span>
        </div>
        <div class="dsig-info-row">
            <span class="dsig-info-label">ID Publication</span>
            <span class="dsig-info-value"><%= sig.getIdpublication() != null ? sig.getIdpublication() : "&mdash;" %></span>
        </div>
        <% String descVal = sig.getMotifdesc(); if (descVal != null && !descVal.isEmpty()) { %>
        <div class="dsig-info-row" style="grid-column:1/-1;">
            <span class="dsig-info-label">Description</span>
            <span class="dsig-info-value" style="color:#374151;font-style:italic;"><%= descVal %></span>
        </div>
        <% } %>
    </div>
</div>

<!-- ═══ PUBLICATION SIGNALEE ═══ -->
<div class="dsig-pub-card">
    <div class="dsig-pub-head">
        <div class="dsig-pub-head-icon"><i class="fa fa-newspaper-o"></i></div>
        <span class="dsig-pub-head-title">Publication signal&eacute;e</span>
    </div>
    <div class="dsig-pub-body">
    <% if (pubs == null || pubs.length == 0) { %>
    <div class="dsig-pub-missing">
        <i class="fa fa-ban"></i>
        <p>Cette publication n&apos;existe plus ou a &eacute;t&eacute; supprim&eacute;e.</p>
    </div>
    <% } else {
        request.setAttribute("_pub_pubs", pubs);
        request.setAttribute("_pub_userNames", userNames);
        request.setAttribute("_pub_userPhotos", userPhotos);
        request.setAttribute("_pub_userProfils", userProfils);
        request.setAttribute("_pub_userBanned", userBanned);
        request.setAttribute("_pub_reactTypes", reactTypes);
        request.setAttribute("_pub_typesPub", typesPub);
        request.setAttribute("_pub_refuser", new Integer(refuserConnecte));
        request.setAttribute("_pub_initialConnecte", initialConnecte);
        request.setAttribute("_pub_connPhotoUrl", _connPhotoUrl);
        request.setAttribute("_pub_ctx", ctx);
        request.setAttribute("_pub_conn", conn);
    %>
    <div style="max-width:640px;">
        <jsp:include page="../publication.jsp" />
    </div>
    <% if (isMod && pubs[0].getEtat() != 0) { %>
    <div class="dsig-danger-zone">
        <div class="dsig-danger-zone-msg">
            <i class="fa fa-exclamation-triangle" style="margin-right:6px;"></i>
            Supprimer cette publication ? Cette action est <strong>irr&eacute;versible</strong>.
        </div>
        <form method="post" style="margin:0;" onsubmit="return confirm('\u00cates-vous s\u00fbr de vouloir supprimer cette publication ?');">
            <input type="hidden" name="action" value="supprimerPublication"/>
            <input type="hidden" name="idpublication" value="<%= sig.getIdpublication() %>"/>
            <input type="hidden" name="idsignalement" value="<%= sig.getIdsignalement() %>"/>
            <button type="submit" class="btn btn-danger btn-sm" style="border-radius:8px;white-space:nowrap;">
                <i class="fa fa-trash" style="margin-right:5px;"></i>Supprimer la publication
            </button>
        </form>
    </div>
    <% } else if (isMod && pubs[0].getEtat() == 0) { %>
    <div class="dsig-deleted-notice">
        <i class="fa fa-info-circle"></i> Cette publication a d&eacute;j&agrave; &eacute;t&eacute; supprim&eacute;e.
    </div>
    <% } %>
    <% } %>
    </div>
</div>

</div>

<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<div style="max-width:460px;margin:40px auto;text-align:center;padding:32px 24px;background:#fff1f2;border-radius:14px;border:1px solid #fecdd3;">
    <i class="fa fa-exclamation-triangle" style="color:#dc3545;font-size:1.6rem;margin-bottom:10px;display:block;"></i>
    <div style="font-size:0.9rem;color:#991b1b;font-weight:600;">Erreur : <%= e.getMessage() %></div>
</div>
<%
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>

<!-- ==================== STYLES PUBLICATION (depuis accueil.jsp) ==================== -->
<style>
    :root {
        --fa-bg: #f0f2f5;
        --fa-card-bg: #ffffff;
        --fa-border: #e4e6eb;
        --fa-text: #050505;
        --fa-text-secondary: #65676b;
    }
    /* ---- Avatar ---- */
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
    /* ---- Post card ---- */
    .fa-post-card { background: var(--fa-card-bg); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.12); overflow: hidden; }
    .fa-post-header { display: flex; align-items: flex-start; gap: 10px; padding: 14px 16px 8px; position: relative; }
    .fa-post-meta { flex: 1; min-width: 0; }
    /* ---- Menu 3 points publication ---- */
    .pub-menu { position:absolute; top:10px; right:10px; z-index:10; }
    .pub-menu-btn { background:none; border:none; font-size:18px; line-height:1; padding:4px 6px; cursor:pointer; color:#65676b; border-radius:50%; transition:background .15s,color .15s; }
    .pub-menu-btn:hover { background:#f0f2f5; color:var(--itu-blue,#008BFF); }
    .pub-menu-dropdown { display:none; position:absolute; right:0; top:100%; background:#fff; border:1px solid #dde3ec; border-radius:6px; box-shadow:0 6px 20px rgba(0,0,0,.12); min-width:140px; z-index:100; overflow:hidden; }
    .pub-menu-item { width:100%; padding:8px 12px; text-align:left; border:none; background:transparent; cursor:pointer; font-size:13px; }
    .pub-menu-item:hover { background:#f0f2f5; }
    .fa-post-author { font-weight: 700; font-size: 15px; color: var(--fa-text); }
    .fa-post-with { font-weight: 400; font-size: 14px; color: var(--fa-text-secondary); }
    .fa-post-date { font-size: 12px; color: var(--fa-text-secondary); margin-top: 2px; display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
    .fa-type-badge { display: inline-block; background: #f0f2f5; color: var(--itu-blue,#008BFF); font-size: 11px; font-weight: 600; padding: 2px 8px; border-radius: 10px; }
    .fa-post-body { padding: 4px 16px 12px; }
    .fa-post-text { font-size: 15px; color: var(--fa-text); line-height: 1.5; margin: 0 0 8px; }
    .fa-post-media { margin: 0; }
    .fa-post-img { width: 100%; max-height: 500px; object-fit: cover; display: block; cursor: zoom-in; }
    .fa-post-counters { display: flex; align-items: center; justify-content: space-between; padding: 6px 16px; font-size: 13px; color: var(--fa-text-secondary); min-height: 28px; }
    .fa-counter { display: flex; align-items: center; gap: 4px; }
    .fa-counter--link { cursor: pointer; }
    .fa-counter--link:hover { text-decoration: underline; }
    .fa-post-divider { height: 1px; background: var(--fa-border); margin: 0 16px; }
    /* ---- Barre d'actions ---- */
    .fa-post-actions { display: flex; padding: 4px 8px; gap: 2px; }
    .fa-action-btn {
        flex: 1; display: flex; align-items: center; justify-content: center; gap: 6px;
        padding: 8px 4px; background: none; border: none; border-radius: 8px;
        font-size: 14px; font-weight: 600; color: var(--fa-text-secondary); cursor: pointer; transition: background .15s;
    }
    .fa-action-btn:hover { background: #f0f2f5; color: var(--fa-text); }
    .fa-action-btn--reacted { color: var(--itu-blue,#008BFF); }
    .fa-action-btn--reacted:hover { color: var(--itu-blue,#008BFF); background: #e7f3ff; }
    /* ---- Hover bar reactions ---- */
    .fa-reaction-wrap { flex: 1; position: relative; display: flex; }
    .fa-reaction-bar {
        position: absolute; bottom: calc(100% + 8px); left: 0;
        display: flex; gap: 4px;
        background: #fff; border-radius: 28px; box-shadow: 0 4px 20px rgba(0,0,0,.2);
        padding: 6px 10px; z-index: 100; white-space: nowrap;
        opacity: 0; pointer-events: none;
        transform: scale(.7) translateY(8px); transform-origin: bottom left;
        transition: opacity .18s, transform .18s;
    }
    .fa-reaction-bar--open { opacity: 1 !important; pointer-events: all !important; transform: scale(1) translateY(0) !important; }
    .fa-reaction-item { background: none; border: none; display: flex; flex-direction: column; align-items: center; cursor: pointer; padding: 2px 4px; border-radius: 8px; transition: transform .15s; }
    .fa-reaction-item:hover { transform: scale(1.4) translateY(-6px); }
    .fa-reaction-item--active { filter: drop-shadow(0 0 4px var(--itu-blue,#008BFF)); }
    .fa-reaction-emoji { font-size: 26px; line-height: 1; }
    .fa-reaction-label { font-size: 11px; color: #1c1e21; margin-top: 3px; white-space: nowrap; }
    /* ---- Zone identification ---- */
    .fa-tag-zone { padding: 12px 16px; border-top: 1px solid var(--fa-border); background: #f8f9fb; }
    .fa-tag-zone-title { font-size: 13px; color: var(--fa-text-secondary); margin: 0 0 8px; }
    /* ---- Zone commentaires ---- */
    .fa-comments-zone {
        padding: 4px 12px 12px;
        border-top: 1px solid var(--fa-border);
        display: flex; flex-direction: column; gap: 2px;
    }
    .fa-comment-item { display: flex; flex-direction: column; padding: 4px 0; }
    .fa-comment-item--reply { padding-top: 2px; }
    .fa-replies-area { margin-top: 2px; }
    .fa-replies-toggle {
        display: inline-flex; align-items: center; gap: 5px;
        background: none; border: none;
        color: var(--itu-blue,#008BFF);
        font-size: 13px; font-weight: 600;
        cursor: pointer; padding: 4px 8px;
        border-radius: 6px; margin-left: -4px;
        transition: background .15s; line-height: 1;
    }
    .fa-replies-toggle:hover { background: rgba(0,139,255,.1); }
    .fa-replies-toggle i { font-size: 12px; transition: transform .25s; }
    .fa-replies-toggle--expanded i { transform: rotate(180deg); }
    .fa-replies-wrap {
        overflow: hidden; max-height: 0; padding-left: 12px;
        border-left: 2px solid #e4e6ea; margin-left: 14px; margin-top: 4px;
        transition: max-height .35s ease-out;
    }
    .fa-replies-wrap--open { max-height: 4000px; transition: max-height .45s ease-in; }
    .fa-comment-inner { display: flex; gap: 8px; align-items: flex-start; }
    .fa-comment-content { flex: 1; min-width: 0; }
    .fa-comment-bubble {
        background: #f0f2f5; border-radius: 18px; padding: 8px 12px;
        display: inline-block; max-width: 100%; cursor: default; transition: background .15s;
    }
    .fa-comment-bubble:hover { background: #e4e6ea; }
    .fa-comment-author { font-weight: 600; font-size: 13px; color: #050505; display: block; margin-bottom: 2px; line-height: 1.2; }
    .fa-comment-author:hover { text-decoration: underline; cursor: pointer; }
    .fa-comment-text { font-size: 14px; color: #050505; word-break: break-word; line-height: 1.4; }
    .fa-comment-actions { display: flex; align-items: center; gap: 2px; padding: 3px 4px 0; font-size: 12px; font-weight: 600; color: #65676b; line-height: 1; }
    .fa-comment-actions .fa-dot { color: #65676b; font-weight: 400; opacity: .7; padding: 0 2px; }
    .fa-comment-react-btn {
        background: none; border: none; font-size: 12px; font-weight: 600;
        color: #65676b; cursor: pointer; padding: 3px 5px; border-radius: 4px;
        transition: background .12s, color .12s; line-height: 1; white-space: nowrap;
    }
    .fa-comment-react-btn:hover { background: #f0f2f5; color: #050505; }
    .fa-comment-react-btn--active { color: var(--itu-blue,#008BFF); }
    .fa-comment-react-btn--active:hover { background: #e7f3ff; color: var(--itu-blue,#008BFF); }
    .fa-comment-reply-link {
        font-size: 12px; font-weight: 600; color: #65676b; text-decoration: none;
        padding: 3px 5px; border-radius: 4px; transition: background .12s, color .12s; line-height: 1;
    }
    .fa-comment-reply-link:hover { background: #f0f2f5; color: #050505; text-decoration: none; }
    .fa-comment-input-wrap { display: flex; align-items: center; gap: 8px; margin-top: 8px; }
    .fa-comment-input-box {
        flex: 1; display: flex; align-items: center;
        background: #f0f2f5; border-radius: 20px; padding: 0 6px 0 14px;
        position: relative; border: 1.5px solid transparent; transition: border-color .15s, background .15s;
    }
    .fa-comment-input-box:focus-within { background: #fff; border-color: var(--itu-blue,#008BFF); box-shadow: 0 0 0 3px rgba(0,139,255,.08); }
    .fa-comment-input {
        flex: 1; background: transparent; border: none; outline: none;
        padding: 9px 4px; font-size: 14px; color: #050505; font-family: inherit; min-width: 0;
    }
    .fa-comment-input::placeholder { color: #65676b; }
    .fa-comment-send-btn {
        background: none; border: none; color: var(--itu-blue,#008BFF);
        font-size: 16px; cursor: pointer; padding: 6px; border-radius: 50%;
        transition: background .15s; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .fa-comment-send-btn:hover { background: rgba(0,139,255,.12); }
    /* ---- Etats vides ---- */
    .fa-empty-feed { text-align: center; padding: 48px 20px; color: var(--fa-text-secondary); font-size: 16px; }
    .fa-empty-feed i { font-size: 52px; display: block; margin-bottom: 16px; opacity: .4; }
    /* ---- Inputs / chips ---- */
    .fa-input { width: 100%; padding: 8px 12px; border: 1px solid var(--fa-border); border-radius: 8px; font-size: 14px; outline: none; font-family: inherit; box-sizing: border-box; }
    .fa-input:focus { border-color: var(--itu-blue,#008BFF); }
    .fa-suggestions-list { max-height: 160px; overflow-y: auto; border: 1px solid var(--fa-border); border-top: none; border-radius: 0 0 8px 8px; background: #fff; }
    .fa-chips-row { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
    /* ---- Overlay zoom media ---- */
    .fa-media-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.9); display: flex; align-items: center; justify-content: center; z-index: 9999; cursor: zoom-out; }
    .fa-media-overlay img { max-width: 92vw; max-height: 92vh; border-radius: 4px; object-fit: contain; }
    /* ---- Mention dropdown ---- */
    .mention-dropdown {
        position: absolute; bottom: 45px; left: 0;
        background: #fff; border: 1px solid #ddd; border-radius: 8px;
        box-shadow: 0 4px 16px rgba(0,0,0,.15); z-index: 1000;
        max-height: 200px; overflow-y: auto; width: 280px;
    }
    .mention-dropdown .mention-item { padding: 8px 12px; cursor: pointer; font-size: 13px; border-bottom: 1px solid #f0f2f5; }
    .mention-dropdown .mention-item:hover, .mention-dropdown .mention-item.active { background: #e7f3ff; color: var(--itu-blue,#008BFF); }
    /* ---- Tag chips ---- */
    .tag-chip { display: inline-flex; align-items: center; gap: 4px; background: #e7f3ff; color: var(--itu-blue,#008BFF); padding: 3px 10px; border-radius: 14px; font-size: 12px; }
    .tag-chip .remove-tag { cursor: pointer; font-weight: bold; color: #888; margin-left: 4px; }
    .tag-chip .remove-tag:hover { color: #e00; }
    /* ---- Mention badge ---- */
    .mention-badge { color: var(--itu-blue,#008BFF); font-weight: 600; background: #e7f3ff; padding: 1px 5px; border-radius: 4px; font-size: 13px; }
    /* ---- Btn primary ---- */
    .fa-btn-primary { background: var(--itu-blue,#008BFF); color: #fff; border: none; border-radius: 8px; padding: 8px 16px; font-size: 14px; font-weight: 600; cursor: pointer; }
    .fa-btn-sm { padding: 6px 14px !important; font-size: 13px !important; }
    /* ---- Infinite scroll loader ---- */
    .fa-feed-spinner { display:inline-block; width:32px; height:32px; border:3px solid #e4e6eb; border-top-color:var(--itu-blue,#008BFF); border-radius:50%; animation:feedSpin .7s linear infinite; }
    @keyframes feedSpin { to { transform:rotate(360deg); } }
</style>
