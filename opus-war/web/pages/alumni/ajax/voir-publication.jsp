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
<%
    /* ============================================================
       AJAX : Charger UNE publication comme carte complete
       Parametre GET : idpublication
       Retour : HTML (publication.jsp avec tous les attributs)
       ============================================================ */
    UserEJB uVP = (UserEJB) session.getAttribute("u");
    if (uVP == null) { out.print("<p style='color:#888'>Connectez-vous.</p>"); return; }

    MapUtilisateur mapVP = uVP.getUser();
    int refuserConnecte = mapVP.getRefuser();
    String nomConnecte  = mapVP.getNomuser() != null ? mapVP.getNomuser() : "";
    String ctx          = request.getContextPath();

    String idpub = request.getParameter("idpublication");
    if (idpub == null || idpub.trim().isEmpty()) { out.print("<p style='color:#888'>Publication introuvable.</p>"); return; }
    idpub = idpub.replaceAll("[^A-Za-z0-9]", "");

    // Initiales connecte
    String[] _partsConn = nomConnecte.trim().split("\\s+");
    String initialConnecte = (_partsConn.length > 0 && _partsConn[0].length() > 0)
            ? String.valueOf(Character.toUpperCase(_partsConn[0].charAt(0))) : "U";
    if (_partsConn.length > 1 && _partsConn[_partsConn.length - 1].length() > 0)
        initialConnecte += Character.toUpperCase(_partsConn[_partsConn.length - 1].charAt(0));

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        // Charger la publication
        Publication[] pArr = (Publication[]) CGenUtil.rechercher(
            new Publication(), null, null, conn, " and idpublication='" + idpub + "'");
        if (pArr == null || pArr.length == 0) { out.print("<p style='color:#888'>Publication introuvable.</p>"); return; }

        Publication[] pubs = new Publication[]{ pArr[0] };

        // Types de publication
        Typepublication[] typesPub = (Typepublication[]) CGenUtil.rechercher(
            new Typepublication(), null, null, conn, " order by idtypepublication");
        if (typesPub == null) typesPub = new Typepublication[0];

        // Types de reaction
        Reactiontype[] reactTypes = (Reactiontype[]) CGenUtil.rechercher(
            new Reactiontype(), null, null, conn, " order by idreactiontype");
        if (reactTypes == null) reactTypes = new Reactiontype[0];

        // Lookup noms + photos de tous les profils
        ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(
            new ProfilLib(), null, null, conn, "");
        Map userNames  = new HashMap();
        Map userPhotos = new HashMap();
        Map userProfils = new HashMap();
        if (allProfils != null) {
            for (int i = 0; i < allProfils.length; i++) {
                Integer _key = new Integer(allProfils[i].getIdutilisateur());
                userNames.put(_key, allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                if (allProfils[i].getPhotoProfil() != null && !allProfils[i].getPhotoProfil().trim().isEmpty())
                    userPhotos.put(_key, ctx + "/" + allProfils[i].getPhotoProfil().trim());
                if (allProfils[i].getIdprofil() != null && !allProfils[i].getIdprofil().trim().isEmpty())
                    userProfils.put(_key, allProfils[i].getIdprofil().trim());
            }
        }

        // Photo connecte
        String _connPhotoUrl = "";
        ProfilLib[] _myProfils = (ProfilLib[]) CGenUtil.rechercher(
            new ProfilLib(), null, null, conn, " and refuser=" + refuserConnecte);
        if (_myProfils != null && _myProfils.length > 0) {
            if (_myProfils[0].getPhotoProfil() != null && !_myProfils[0].getPhotoProfil().trim().isEmpty())
                _connPhotoUrl = ctx + "/" + _myProfils[0].getPhotoProfil().trim();
        }

        // Passer les donnees au composant publication.jsp
        request.setAttribute("_pub_pubs", pubs);
        request.setAttribute("_pub_userNames", userNames);
        request.setAttribute("_pub_userPhotos", userPhotos);
        request.setAttribute("_pub_userProfils", userProfils);
        request.setAttribute("_pub_reactTypes", reactTypes);
        request.setAttribute("_pub_typesPub", typesPub);
        request.setAttribute("_pub_refuser", new Integer(refuserConnecte));
        request.setAttribute("_pub_initialConnecte", initialConnecte);
        request.setAttribute("_pub_connPhotoUrl", _connPhotoUrl);
        request.setAttribute("_pub_ctx", ctx);
        request.setAttribute("_pub_conn", conn);
%>
<jsp:include page="../../publication.jsp" />
<%
    } catch (Exception e) {
        e.printStackTrace();
        out.print("<p style='color:red;font-size:13px;'>Erreur: " + e.getMessage() + "</p>");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception cx) {}
    }
%>
