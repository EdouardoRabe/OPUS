<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Media" %>
<%@ page import="alumni.Publicationreaction" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.Typepublication" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.Identification" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    // =========================================================
    // AJAX : Chargement progressif du fil d'actualite (cursor-based)
    // Parametres GET :
    //   cursor_daty  = derniere date vue (YYYY-MM-DD)
    //   cursor_heure = derniere heure vue (HH:MM:SS)
    //   cursor_id    = dernier idpublication vu
    // Retourne du HTML :
    //   1. <div id="feed-meta-new"> avec data-daty, data-heure, data-id, data-has-more
    //   2. Les cartes .fa-post-card suivantes
    // =========================================================

    UserEJB uFeed = (UserEJB) session.getAttribute("u");
    if (uFeed == null) { return; }

    MapUtilisateur mapFeed = uFeed.getUser();
    int refuserConnecte   = mapFeed.getRefuser();
    String nomConnecte    = mapFeed.getNomuser() != null ? mapFeed.getNomuser() : "";
    String ctx            = request.getContextPath();

    // Initiales du user connecte (pour zone commentaires)
    String[] _partsConn = nomConnecte.trim().split("\\s+");
    String initialConnecte = (_partsConn.length > 0 && _partsConn[0].length() > 0)
            ? String.valueOf(Character.toUpperCase(_partsConn[0].charAt(0))) : "U";
    if (_partsConn.length > 1 && _partsConn[_partsConn.length - 1].length() > 0)
        initialConnecte += Character.toUpperCase(_partsConn[_partsConn.length - 1].charAt(0));

    // --- Lecture et sanitisation des parametres curseur ---
    String cursorDaty  = request.getParameter("cursor_daty");
    String cursorHeure = request.getParameter("cursor_heure");
    String cursorId    = request.getParameter("cursor_id");

    if (cursorDaty == null || cursorId == null || cursorId.trim().isEmpty()) {
        return;
    }

    cursorDaty  = cursorDaty.replaceAll("[^0-9\\-]", "");
    cursorHeure = (cursorHeure != null ? cursorHeure.replaceAll("[^0-9:]", "") : "23:59:59");
    if (cursorHeure.isEmpty()) cursorHeure = "23:59:59";
    cursorId    = cursorId.replaceAll("[^A-Za-z0-9]", "");

    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();

        // --- Types de publication ---
        Typepublication[] typesPub = (Typepublication[]) CGenUtil.rechercher(
                new Typepublication(), null, null, conn, " order by idtypepublication");
        if (typesPub == null) typesPub = new Typepublication[0];

        // --- Types de reaction ---
        Reactiontype[] reactTypes = (Reactiontype[]) CGenUtil.rechercher(
                new Reactiontype(), null, null, conn, " order by idreactiontype");
        if (reactTypes == null) reactTypes = new Reactiontype[0];

        // --- Lookup noms + photos de tous les profils ---
        ProfilLib[] allProfils = (ProfilLib[]) CGenUtil.rechercher(
                new ProfilLib(), null, null, conn, "");
        Map userNames  = new HashMap();
        Map userPhotos = new HashMap();
        if (allProfils != null) {
            for (int i = 0; i < allProfils.length; i++) {
                Integer _key = new Integer(allProfils[i].getIdutilisateur());
                userNames.put(_key, allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                if (allProfils[i].getPhotoProfil() != null && !allProfils[i].getPhotoProfil().trim().isEmpty())
                    userPhotos.put(_key, ctx + "/" + allProfils[i].getPhotoProfil().trim());
            }
        }

        // --- Photo de profil du connecte (zone commentaires) ---
        String _connPhotoUrl = "";
        ProfilLib[] _myProfils = (ProfilLib[]) CGenUtil.rechercher(
                new ProfilLib(), null, null, conn, " and refuser=" + refuserConnecte);
        if (_myProfils != null && _myProfils.length > 0) {
            if (_myProfils[0].getPhotoProfil() != null && !_myProfils[0].getPhotoProfil().trim().isEmpty())
                _connPhotoUrl = ctx + "/" + _myProfils[0].getPhotoProfil().trim();
        }

        // --- Requete cursor-based (simple, tri par date) ---
        String whereClause = " and etat = 1"
                + " and (daty < '" + cursorDaty + "'"
                + " OR (daty = '" + cursorDaty + "' AND heure < '" + cursorHeure + "')"
                + " OR (daty = '" + cursorDaty + "' AND heure = '" + cursorHeure + "' AND idpublication < '" + cursorId + "'))"
                + " order by daty desc, heure desc, idpublication desc limit 10";

        Publication[] pubs = (Publication[]) CGenUtil.rechercher(
                new Publication(), null, null, conn, whereClause);
        if (pubs == null) pubs = new Publication[0];

        // --- Curseur suivant ---
        String nextDaty  = "";
        String nextHeure = "";
        String nextId    = "";
        boolean hasMore  = (pubs.length == 10);
        if (pubs.length > 0) {
            Publication lastPub = pubs[pubs.length - 1];
            nextDaty  = lastPub.getDaty()  != null ? lastPub.getDaty().toString() : "";
            nextHeure = lastPub.getHeure() != null ? lastPub.getHeure()           : "";
            nextId    = lastPub.getIdpublication();
        }
%>
<%-- Element meta : contient le prochain curseur, lu par le JS avant injection --%>
<div id="feed-meta-new" style="display:none"
     data-daty="<%= nextDaty %>"
     data-heure="<%= nextHeure %>"
     data-id="<%= nextId %>"
     data-has-more="<%= hasMore %>"></div>
<%
        // --- Rendu de chaque carte publication ---
        for (int p = 0; p < pubs.length; p++) {
            Publication pub = pubs[p];
            String idpub  = pub.getIdpublication();
            String auteur = (String) userNames.get(new Integer(pub.getIdutilisateur()));
            if (auteur == null) auteur = "Utilisateur";

            // Initiales auteur
            String[] _partsA = auteur.trim().split("\\s+");
            String initA = String.valueOf(Character.toUpperCase(_partsA[0].charAt(0)));
            if (_partsA.length > 1) initA += Character.toUpperCase(_partsA[_partsA.length - 1].charAt(0));
            String _authorPhoto = (String) userPhotos.get(new Integer(pub.getIdutilisateur()));

            // Medias
            Media[] medias = (Media[]) CGenUtil.rechercher(
                    new Media(), null, null, conn, " and idpublication = '" + idpub + "'");
            if (medias == null) medias = new Media[0];

            // Reactions
            Publicationreaction[] reactions = (Publicationreaction[]) CGenUtil.rechercher(
                    new Publicationreaction(), null, null, conn, " and idpublication = '" + idpub + "'");
            if (reactions == null) reactions = new Publicationreaction[0];

            Map reactCounts = new HashMap();
            int totalReactions = 0;
            String myReaction  = "";
            for (int r = 0; r < reactions.length; r++) {
                String type    = reactions[r].getIdreactiontype();
                Integer cnt    = (Integer) reactCounts.get(type);
                reactCounts.put(type, cnt == null ? new Integer(1) : new Integer(cnt.intValue() + 1));
                totalReactions++;
                if (reactions[r].getIdutilisateur() == refuserConnecte) myReaction = type;
            }

            // Commentaires (compte seulement)
            Publicationcommentaire[] comments = (Publicationcommentaire[]) CGenUtil.rechercher(
                    new Publicationcommentaire(), null, null, conn,
                    " and idpublication = '" + idpub + "' and etat = 1");
            if (comments == null) comments = new Publicationcommentaire[0];
            int nbComm = comments.length;

            // Identifications / tags
            Identification[] identTags = (Identification[]) CGenUtil.rechercher(
                    new Identification(), null, null, conn, " and idpublication = '" + idpub + "'");
            if (identTags == null) identTags = new Identification[0];
            String taggedNames = "";
            if (identTags.length > 0) {
                StringBuffer sbTags = new StringBuffer();
                for (int tg = 0; tg < identTags.length; tg++) {
                    String tName = (String) userNames.get(new Integer(identTags[tg].getIdutilisateur()));
                    if (tName != null) {
                        if (sbTags.length() > 0) sbTags.append(", ");
                        sbTags.append(tName);
                    }
                }
                if (sbTags.length() > 0) taggedNames = sbTags.toString();
            }

            // Description echappee
            String desc     = pub.getDescritpion();
            String descSafe = "";
            if (desc != null) {
                descSafe = desc.replace("&", "&amp;").replace("<", "&lt;")
                        .replace(">", "&gt;").replace("\n", "<br>");
            }

            // Libelle type publication
            String typePubLib = pub.getIdtypepublication() != null ? pub.getIdtypepublication() : "";
            for (int t = 0; t < typesPub.length; t++) {
                if (typesPub[t].getIdtypepublication().equals(typePubLib)) {
                    typePubLib = typesPub[t].getLibelle();
                    break;
                }
            }

            // Libelle de ma reaction active
            String myReactLib = "";
            for (int rt = 0; rt < reactTypes.length; rt++) {
                if (reactTypes[rt].getIdreactiontype().equals(myReaction)) {
                    myReactLib = reactTypes[rt].getLibelle();
                    break;
                }
            }
%>
<!-- ====== CARD PUBLICATION (chargement progressif) ====== -->
<div id="pub-<%= idpub %>" class="fa-post-card">

    <!-- EN-TETE -->
    <div class="fa-post-header">
        <div class="fa-avatar fa-avatar--md"<%= _authorPhoto != null ? " style=\"background:transparent;\"" : "" %>><% if (_authorPhoto != null) { %><img src="<%= _authorPhoto %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= initA %><% } %></div>
        <div class="fa-post-meta">
            <!-- Menu 3 points -->
            <div class="pub-menu">
                <button class="pub-menu-btn" onclick="togglePubMenu(this,event)" title="Plus d'options"><i class="bi bi-three-dots-vertical"></i></button>
                <div class="pub-menu-dropdown">
                    <button class="pub-menu-item" onclick="savePublication('<%= idpub %>')">
                        <i class="bi bi-bookmark"></i> Enregistrer
                    </button>
                    <button class="pub-menu-item" onclick="reportPublication('<%= idpub %>')">
                        <i class="bi bi-flag"></i> Signaler
                    </button>
                </div>
            </div>
            <div class="fa-post-author">
                <%= auteur %>
                <% if (!taggedNames.isEmpty()) { %>
                <span class="fa-post-with">avec <strong><%= taggedNames %></strong></span>
                <% } %>
            </div>
            <div class="fa-post-date">
                <%= pub.getDaty() %>&nbsp;&agrave;&nbsp;<%= pub.getHeure() != null ? pub.getHeure() : "" %>
                <span class="fa-type-badge"><%= typePubLib %></span>
            </div>
        </div>
    </div>

    <!-- CORPS -->
    <div class="fa-post-body">
        <% if (descSafe != null && !descSafe.isEmpty()) { %>
        <p class="fa-post-text"><%= descSafe %></p>
        <% } %>
        <% for (int m = 0; m < medias.length; m++) {
            String mUrl = medias[m].getMediaurl();
            if (mUrl != null && !mUrl.startsWith("http")) {
                mUrl = ctx + "/UploadDownloadFileServlet?fileName=" + java.net.URLEncoder.encode(mUrl, "UTF-8");
            }
        %>
        <div class="fa-post-media">
            <img src="<%= mUrl %>" class="fa-post-img" alt="media" onclick="openMediaZoom(this.src)">
        </div>
        <% } %>
    </div>

    <!-- COMPTEURS -->
    <div class="fa-post-counters">
        <% if (totalReactions > 0) { %>
        <span class="fa-counter"><i class="bi bi-hand-thumbs-up-fill" style="color:var(--itu-blue,#008BFF);"></i>&nbsp;<%= totalReactions %></span>
        <% } else { %><span></span><% } %>
        <span id="nb-comm-<%= idpub %>" class="fa-counter fa-counter--link"
              onclick="toggleCommentaires('<%= idpub %>')">
            <%= nbComm > 0 ? nbComm + " commentaire" + (nbComm > 1 ? "s" : "") : "" %>
        </span>
    </div>

    <div class="fa-post-divider"></div>

    <!-- BARRE D'ACTIONS -->
    <div class="fa-post-actions">

        <!-- Reaction -->
        <div class="fa-reaction-wrap" id="reaction-wrap-<%= idpub %>">
            <button class="fa-action-btn <%= !myReaction.isEmpty() ? "fa-action-btn--reacted" : "" %>"
                    id="react-btn-<%= idpub %>"
                    onclick="toggleReactionBar('<%= idpub %>', event)">
                <i class="bi bi-hand-thumbs-up<%= !myReaction.isEmpty() ? "-fill" : "" %>"></i>
                <span><%= !myReaction.isEmpty() ? myReactLib : "J&apos;aime" %></span>
            </button>
            <div class="fa-reaction-bar" id="reaction-bar-<%= idpub %>">
                <% for (int rt = 0; rt < reactTypes.length; rt++) {
                    String rtId     = reactTypes[rt].getIdreactiontype();
                    String rtLib    = reactTypes[rt].getLibelle();
                    boolean isMyR   = rtId.equals(myReaction);
                    String rtLibLow = rtLib.toLowerCase();
                    String rtEmoji  = "\uD83D\uDC4D";
                    if (rtLibLow.contains("adore") || rtLibLow.contains("love"))         rtEmoji = "\u2764\uFE0F";
                    else if (rtLibLow.contains("haha") || rtLibLow.contains("humour"))    rtEmoji = "\uD83D\uDE02";
                    else if (rtLibLow.contains("surprise") || rtLibLow.contains("wow"))   rtEmoji = "\uD83D\uDE2E";
                    else if (rtLibLow.contains("triste") || rtLibLow.contains("sad"))     rtEmoji = "\uD83D\uDE22";
                    else if (rtLibLow.contains("grrr") || rtLibLow.contains("ang"))       rtEmoji = "\uD83D\uDE20";
                %>
                <button class="fa-reaction-item <%= isMyR ? "fa-reaction-item--active" : "" %>"
                        onclick="selectReaction('<%= idpub %>', '<%= rtId %>', event)" title="<%= rtLib %>">
                    <span class="fa-reaction-emoji"><%= rtEmoji %></span>
                    <span class="fa-reaction-label"><%= rtLib %></span>
                </button>
                <% } %>
            </div>
        </div>

        <!-- Commenter -->
        <button class="fa-action-btn" onclick="toggleCommentaires('<%= idpub %>')">
            <i class="bi bi-chat-left-text"></i>&nbsp;<span>Commenter</span>
        </button>

        <!-- Identifier -->
        <button class="fa-action-btn" onclick="toggleIdentifier('<%= idpub %>')">
            <i class="bi bi-tag"></i>&nbsp;<span>Identifier</span>
        </button>
    </div>

    <!-- ZONE IDENTIFIER -->
    <div id="identifier-<%= idpub %>" style="display:none;" class="fa-tag-zone">
        <p class="fa-tag-zone-title">Identifier des personnes :</p>
        <input type="text" id="tag-search-<%= idpub %>" placeholder="Rechercher un utilisateur..."
               oninput="rechercherPourTag('<%= idpub %>')" class="fa-input">
        <div id="tag-suggestions-<%= idpub %>" class="fa-suggestions-list"></div>
        <div id="tag-selected-<%= idpub %>" class="fa-chips-row"></div>
        <button onclick="envoyerIdentifications('<%= idpub %>')" class="fa-btn-primary fa-btn-sm" style="margin-top:8px;">Valider</button>
    </div>

    <!-- ZONE COMMENTAIRES -->
    <div id="commentaires-<%= idpub %>" style="display:none;" class="fa-comments-zone">
        <div id="liste-comm-<%= idpub %>"></div>
        <div class="fa-comment-input-wrap">
            <div class="fa-avatar fa-avatar--sm"<%= !_connPhotoUrl.isEmpty() ? " style=\"background:transparent;\"" : "" %>><% if (!_connPhotoUrl.isEmpty()) { %><img src="<%= _connPhotoUrl %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= initialConnecte %><% } %></div>
            <div class="fa-comment-input-box">
                <input type="text" id="comm-text-<%= idpub %>"
                       placeholder="&Eacute;crire un commentaire... (@ pour mentionner)"
                       class="fa-comment-input"
                       oninput="onCommentInput(this, '<%= idpub %>')"
                       onkeydown="onCommentKeydown(event, '<%= idpub %>')">
                <input type="hidden" id="comm-mentions-<%= idpub %>" value="">
                <div id="mention-suggestions-<%= idpub %>" class="mention-dropdown" style="display:none;"></div>
                <button class="fa-comment-send-btn" onclick="ajouterCommentaire('<%= idpub %>')">
                    <i class="bi bi-send-fill"></i>
                </button>
            </div>
        </div>
    </div>

</div><!-- /fa-post-card -->
<%
        } // fin for pubs

    } catch (Exception e) {
        e.printStackTrace();
        // En cas d'erreur : retourner silencieusement (le JS ne recharge rien)
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
