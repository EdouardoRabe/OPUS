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
<!-- Signalement detail styles extracted to external CSS -->
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/pages/detail-signalement.css" />

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
<!-- Shared publication styles now loaded globally via css.jsp -->
