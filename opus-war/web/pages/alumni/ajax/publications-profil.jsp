<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Media" %>
<%@ page import="alumni.Publicationreaction" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="alumni.Typepublication" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%!
    private static String pvEsc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
    }
%>
<%
    /* ============================================================
       AJAX – Publications d'un utilisateur pour la page profil
       Paramètres GET : idutilisateur  OU  idprofil
       Retour : HTML cards (.ppub-card)
       Page :   Paginé/offset via cursor_id  (10 par page)
       ============================================================ */
    UserEJB uEJB = (UserEJB) session.getAttribute("u");
    if (uEJB == null) { out.print("<p style='color:#888'>Connectez-vous pour voir les publications.</p>"); return; }

    String ctx = request.getContextPath();
    int myRefuser = uEJB.getUser().getRefuser();

    String paramIdUser  = request.getParameter("idutilisateur");
    String paramIdProfil = request.getParameter("idprofil");
    String cursorId      = request.getParameter("cursor_id"); // pagination

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        // Résoudre l'idutilisateur depuis idprofil si nécessaire
        int targetUser = -1;
        String targetNom = "";
        String targetPhoto = "";
        if (paramIdUser != null && !paramIdUser.trim().isEmpty()) {
            try { targetUser = Integer.parseInt(paramIdUser.trim()); } catch (NumberFormatException _nfe) {}
        } else if (paramIdProfil != null && !paramIdProfil.trim().isEmpty()) {
            ProfilLib filtre = new ProfilLib();
            filtre.setIdprofil(paramIdProfil.trim());
            ProfilLib[] pArr = (ProfilLib[]) CGenUtil.rechercher(filtre, null, null, conn, "");
            if (pArr != null && pArr.length > 0) {
                targetUser  = pArr[0].getIdutilisateur();
                targetNom   = (pArr[0].getNom() != null ? pArr[0].getNom() : "") + " " + (pArr[0].getPrenom() != null ? pArr[0].getPrenom() : "");
                targetPhoto = pArr[0].getPhotoProfil() != null && !pArr[0].getPhotoProfil().trim().isEmpty()
                    ? ctx + "/" + pArr[0].getPhotoProfil().trim() : "";
            }
        }
        if (targetUser == -1) {
            out.print("<p style='color:#888'>Utilisateur introuvable.</p>");
            return;
        }

        // Charger le profil de l'auteur si nom pas encore résolu
        if (targetNom.trim().isEmpty()) {
            ProfilLib[] authPr = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, conn, " and refuser=" + targetUser);
            if (authPr != null && authPr.length > 0) {
                targetNom   = (authPr[0].getNom() != null ? authPr[0].getNom() : "") + " " + (authPr[0].getPrenom() != null ? authPr[0].getPrenom() : "");
                targetPhoto = authPr[0].getPhotoProfil() != null && !authPr[0].getPhotoProfil().trim().isEmpty()
                    ? ctx + "/" + authPr[0].getPhotoProfil().trim() : "";
            }
        }
        targetNom = targetNom.trim();
        String[] nameParts = targetNom.split("\\s+");
        String initials = nameParts.length > 0 && nameParts[0].length() > 0
            ? String.valueOf(Character.toUpperCase(nameParts[0].charAt(0))) : "U";
        if (nameParts.length > 1) initials += Character.toUpperCase(nameParts[nameParts.length-1].charAt(0));

        // Types de publication (libellés)
        Typepublication[] typesPub = (Typepublication[]) CGenUtil.rechercher(new Typepublication(), null, null, conn, "");
        if (typesPub == null) typesPub = new Typepublication[0];
        Map typeMap = new HashMap();
        for (int t = 0; t < typesPub.length; t++) typeMap.put(typesPub[t].getIdtypepublication(), typesPub[t].getLibelle());

        // Charger les publications (10 dernières, paginées)
        String cursorCond = "";
        if (cursorId != null && !cursorId.trim().isEmpty()) {
            cursorId = cursorId.replaceAll("[^A-Za-z0-9]","");
            cursorCond = " AND idpublication < '" + cursorId + "'";
        }
        String pubSql = "SELECT idpublication FROM publication WHERE idutilisateur=" + targetUser
            + " AND etat=1" + cursorCond + " ORDER BY idpublication DESC LIMIT 10";
        java.util.List pubIds = new java.util.ArrayList();
        java.sql.Statement _st = null; java.sql.ResultSet _rs = null;
        try {
            _st = conn.createStatement(); _rs = _st.executeQuery(pubSql);
            while (_rs.next()) pubIds.add(_rs.getString("idpublication"));
        } finally {
            if (_rs != null) try { _rs.close(); } catch (Exception _x) {}
            if (_st != null) try { _st.close(); } catch (Exception _x) {}
        }

        if (pubIds.isEmpty()) {
            out.print("<p style='color:#aaa;font-size:13px;padding:12px 0;text-align:center;'>Aucune publication.</p>");
            return;
        }

        // Lien profil de l'auteur
        ProfilLib[] ownPL = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, conn, " and refuser=" + targetUser + " and idprofil is not null");
        String authorProfileUrl;
        if (targetUser == myRefuser) {
            authorProfileUrl = ctx + "/pages/module.jsp?but=profil/voir.jsp";
        } else if (ownPL != null && ownPL.length > 0 && ownPL[0].getIdprofil() != null) {
            authorProfileUrl = ctx + "/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp?idprofil=" + ownPL[0].getIdprofil().trim();
        } else {
            authorProfileUrl = "#";
        }

        for (int pi = 0; pi < pubIds.size(); pi++) {
            String idpub = (String) pubIds.get(pi);
            Publication[] pArr = (Publication[]) CGenUtil.rechercher(new Publication(), null, null, conn, " and idpublication='" + idpub + "'");
            if (pArr == null || pArr.length == 0) continue;
            Publication pub = pArr[0];

            String desc = pub.getDescritpion();
            String descSafe = desc != null ? pvEsc(desc).replace("\n","<br>") : "";
            String dateStr  = (pub.getDaty() != null ? pub.getDaty().toString() : "") + " à " + (pub.getHeure() != null ? pub.getHeure() : "");
            String typeLbl  = pub.getIdtypepublication() != null ? (String) typeMap.get(pub.getIdtypepublication()) : "";
            if (typeLbl == null) typeLbl = "";

            // Compteurs
            Publicationreaction[] rArr = (Publicationreaction[]) CGenUtil.rechercher(new Publicationreaction(), null, null, conn, " and idpublication='" + idpub + "'");
            int nbReact = rArr != null ? rArr.length : 0;
            Publicationcommentaire[] cArr = (Publicationcommentaire[]) CGenUtil.rechercher(new Publicationcommentaire(), null, null, conn, " and idpublication='" + idpub + "' and etat=1");
            int nbComm = cArr != null ? cArr.length : 0;

            // Premier média
            Media[] mArr = (Media[]) CGenUtil.rechercher(new Media(), null, null, conn, " and idpublication='" + idpub + "'");
            String firstMedia = "";
            if (mArr != null && mArr.length > 0 && mArr[0].getMediaurl() != null) {
                String mu = mArr[0].getMediaurl();
                firstMedia = mu.startsWith("http") ? mu : ctx + "/UploadDownloadFileServlet?fileName=" + java.net.URLEncoder.encode(mu, "UTF-8");
            }

            // Lien vers le fil d'actu scrollé sur cette pub
            String feedLink = ctx + "/pages/module.jsp?but=alumni/fil-actualite.jsp&scrollTo=pub-" + idpub;
%>
<div class="ppub-card" onclick="window.location.href='<%= feedLink %>'" title="Voir sur le fil d'actualit&eacute;">
    <div class="ppub-header">
        <a href="<%= authorProfileUrl %>" onclick="event.stopPropagation();" style="text-decoration:none;flex-shrink:0;">
            <div class="ppub-avatar" <% if (!targetPhoto.isEmpty()) { %>style="background:transparent;overflow:hidden;"<% } %>>
                <% if (!targetPhoto.isEmpty()) { %><img src="<%= targetPhoto %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= pvEsc(initials) %><% } %>
            </div>
        </a>
        <div class="ppub-meta">
            <a href="<%= authorProfileUrl %>" onclick="event.stopPropagation();" class="ppub-author"><%= pvEsc(targetNom) %></a>
            <div class="ppub-date"><%= pvEsc(dateStr) %><% if (!typeLbl.isEmpty()) { %>&nbsp;<span class="ppub-badge"><%= pvEsc(typeLbl) %></span><% } %></div>
        </div>
    </div>
    <% if (!descSafe.isEmpty()) { %>
    <div class="ppub-text"><%= descSafe %></div>
    <% } %>
    <% if (!firstMedia.isEmpty()) { %>
    <div class="ppub-media-wrap"><img src="<%= firstMedia %>" class="ppub-media-img" alt="" onclick="event.stopPropagation();openMediaZoom(this.src)" onerror="this.style.display='none'"></div>
    <% } %>
    <div class="ppub-counters">
        <% if (nbReact > 0) { %><span class="ppub-counter"><i class="bi bi-hand-thumbs-up-fill"></i>&nbsp;<%= nbReact %></span><% } %>
        <% if (nbComm > 0) { %><span class="ppub-counter"><i class="bi bi-chat-left-text"></i>&nbsp;<%= nbComm %></span><% } %>
        <span class="ppub-view-link">Voir &rarr;</span>
    </div>
</div>
<%
        } // fin for pubs

        // Marqueur pagination
        if (pubIds.size() == 10) {
            String lastId = (String) pubIds.get(pubIds.size()-1);
%>
<div class="ppub-load-more-wrap">
    <button class="ppub-load-more-btn" onclick="ppubLoadMore(this,'<%= paramIdUser != null ? paramIdUser : "" %>','<%= paramIdProfil != null ? paramIdProfil.replace("'","\\'") : "" %>','<%= lastId %>')">
        Voir plus de publications
    </button>
</div>
<%
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.print("<p style='color:red;font-size:13px;'>Erreur chargement publications: " + pvEsc(e.getMessage()) + "</p>");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception cx) {}
    }
%>
