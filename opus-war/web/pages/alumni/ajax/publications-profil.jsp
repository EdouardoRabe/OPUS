<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Reactiontype" %>
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
       Retour : HTML cartes complètes via publication.jsp
       Page :   Paginé/offset via cursor_id  (10 par page)
       ============================================================ */
    UserEJB uEJB = (UserEJB) session.getAttribute("u");
    if (uEJB == null) { out.print("<p style='color:#888'>Connectez-vous pour voir les publications.</p>"); return; }

    MapUtilisateur mapPP = uEJB.getUser();
    String ctx = request.getContextPath();
    int myRefuser = mapPP.getRefuser();
    String nomConnecte = mapPP.getNomuser() != null ? mapPP.getNomuser() : "";

    // Initiales connecte
    String[] _partsConn = nomConnecte.trim().split("\\s+");
    String initialConnecte = (_partsConn.length > 0 && _partsConn[0].length() > 0)
            ? String.valueOf(Character.toUpperCase(_partsConn[0].charAt(0))) : "U";
    if (_partsConn.length > 1 && _partsConn[_partsConn.length - 1].length() > 0)
        initialConnecte += Character.toUpperCase(_partsConn[_partsConn.length - 1].charAt(0));

    String paramIdUser  = request.getParameter("idutilisateur");
    String paramIdProfil = request.getParameter("idprofil");
    String cursorId      = request.getParameter("cursor_id");

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        // Résoudre l'idutilisateur depuis idprofil si nécessaire
        int targetUser = -1;
        if (paramIdUser != null && !paramIdUser.trim().isEmpty()) {
            try { targetUser = Integer.parseInt(paramIdUser.trim()); } catch (NumberFormatException _nfe) {}
        } else if (paramIdProfil != null && !paramIdProfil.trim().isEmpty()) {
            ProfilLib filtre = new ProfilLib();
            filtre.setIdprofil(paramIdProfil.trim());
            ProfilLib[] pArr = (ProfilLib[]) CGenUtil.rechercher(filtre, null, null, conn, "");
            if (pArr != null && pArr.length > 0) targetUser = pArr[0].getIdutilisateur();
        }
        if (targetUser == -1) {
            out.print("<p style='color:#888'>Utilisateur introuvable.</p>");
            return;
        }

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

        // Charger toutes les publications
        Publication[] pubs = new Publication[pubIds.size()];
        for (int _i = 0; _i < pubIds.size(); _i++) {
            Publication[] _pa = (Publication[]) CGenUtil.rechercher(new Publication(), null, null, conn, " and idpublication='" + pubIds.get(_i) + "'");
            pubs[_i] = (_pa != null && _pa.length > 0) ? _pa[0] : new Publication();
        }

        // Types de publication
        Typepublication[] typesPub = (Typepublication[]) CGenUtil.rechercher(new Typepublication(), null, null, conn, " order by idtypepublication");
        if (typesPub == null) typesPub = new Typepublication[0];

        // Types de reaction
        Reactiontype[] reactTypes = (Reactiontype[]) CGenUtil.rechercher(new Reactiontype(), null, null, conn, " order by idreactiontype");
        if (reactTypes == null) reactTypes = new Reactiontype[0];

        // Lookup noms + photos de tous les profils
        ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, conn, "");
        Map userNames  = new HashMap();
        Map userPhotos = new HashMap();
        Map userProfils = new HashMap();
        Map userBanned = new HashMap();
        if (allProfils != null) {
            for (int i = 0; i < allProfils.length; i++) {
                Integer _key = new Integer(allProfils[i].getIdutilisateur());
                userNames.put(_key, allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                if (allProfils[i].getPhotoProfil() != null && !allProfils[i].getPhotoProfil().trim().isEmpty())
                    userPhotos.put(_key, ctx + "/" + allProfils[i].getPhotoProfil().trim());
                if (allProfils[i].getIdprofil() != null && !allProfils[i].getIdprofil().trim().isEmpty())
                    userProfils.put(_key, allProfils[i].getIdprofil().trim());
                if (allProfils[i].getEstactif() == 0)
                    userBanned.put(_key, Boolean.TRUE);
            }
        }

        // Photo connecte
        String _connPhotoUrl = "";
        ProfilLib[] _myProfils = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, conn, " and refuser=" + myRefuser);
        if (_myProfils != null && _myProfils.length > 0) {
            if (_myProfils[0].getPhotoProfil() != null && !_myProfils[0].getPhotoProfil().trim().isEmpty())
                _connPhotoUrl = ctx + "/" + _myProfils[0].getPhotoProfil().trim();
        }

        // Passer les donnees au composant publication.jsp
        request.setAttribute("_pub_pubs", pubs);
        request.setAttribute("_pub_userNames", userNames);
        request.setAttribute("_pub_userPhotos", userPhotos);
        request.setAttribute("_pub_userProfils", userProfils);
        request.setAttribute("_pub_userBanned", userBanned);
        request.setAttribute("_pub_reactTypes", reactTypes);
        request.setAttribute("_pub_typesPub", typesPub);
        request.setAttribute("_pub_refuser", new Integer(myRefuser));
        request.setAttribute("_pub_initialConnecte", initialConnecte);
        request.setAttribute("_pub_connPhotoUrl", _connPhotoUrl);
        request.setAttribute("_pub_ctx", ctx);
        request.setAttribute("_pub_conn", conn);
%>
<jsp:include page="../../publication.jsp" />
<%
        // Marqueur pagination
        if (pubIds.size() == 10) {
            String lastId = (String) pubIds.get(pubIds.size()-1);
%>
<div class="ppub-load-more-wrap" style="text-align:center;margin:8px 0 16px;">
    <button class="ppub-load-more-btn" style="background:transparent;border:1.5px solid #0a66c2;color:#0a66c2;border-radius:20px;padding:7px 22px;font-size:13px;font-weight:700;cursor:pointer;" onmouseover="this.style.background='#0a66c2';this.style.color='#fff';" onmouseout="this.style.background='transparent';this.style.color='#0a66c2';" onclick="ppubLoadMore(this,'<%= paramIdUser != null ? paramIdUser : "" %>','<%= paramIdProfil != null ? paramIdProfil.replace("'","\\'") : "" %>','<%= lastId %>')">
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
