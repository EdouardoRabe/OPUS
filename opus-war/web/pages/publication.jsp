<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Media" %>
<%@ page import="alumni.Publicationreaction" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.Typepublication" %>
<%@ page import="alumni.Identification" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    /* ============================================================
       COMPOSANT PUBLICATION  –  publication.jsp
       Composant réutilisable pour afficher le fil de publications.

       La page appelante DOIT définir ces request attributes :
         _pub_pubs           → Publication[]    (publications à afficher)
         _pub_userNames      → Map              (Integer idutilisateur → String nom)
         _pub_userPhotos     → Map              (Integer idutilisateur → String photoUrl)
         _pub_reactTypes     → Reactiontype[]   (types de réactions)
         _pub_typesPub       → Typepublication[] (types de publication)
         _pub_refuser        → Integer          (refuser du connecté)
         _pub_initialConnecte→ String           (initiales du connecté)
         _pub_connPhotoUrl   → String           (photo profil du connecté)
         _pub_ctx            → String           (context path)
         _pub_conn           → Connection       (connexion DB – pas fermée ici)

       Exemple :
         request.setAttribute("_pub_pubs", pubs);
         ...
         <jsp:include page="publication.jsp" />
       ============================================================ */

    // --- Récupérer les données passées par la page appelante ---
    Publication[] _pubPubs   = (Publication[]) request.getAttribute("_pub_pubs");
    Map _pubUserNames        = (Map) request.getAttribute("_pub_userNames");
    Map _pubUserPhotos       = (Map) request.getAttribute("_pub_userPhotos");
    Reactiontype[] _pubReactTypes = (Reactiontype[]) request.getAttribute("_pub_reactTypes");
    Typepublication[] _pubTypesPub = (Typepublication[]) request.getAttribute("_pub_typesPub");
    int _pubRefuser          = ((Integer) request.getAttribute("_pub_refuser")).intValue();
    String _pubInitialConnecte = (String) request.getAttribute("_pub_initialConnecte");
    String _pubConnPhotoUrl  = (String) request.getAttribute("_pub_connPhotoUrl");
    String _pubCtx           = (String) request.getAttribute("_pub_ctx");
    Connection _pubConn      = (Connection) request.getAttribute("_pub_conn");

    // Sécurité : valeurs par défaut si null
    if (_pubPubs == null) _pubPubs = new Publication[0];
    if (_pubUserNames == null) _pubUserNames = new HashMap();
    if (_pubUserPhotos == null) _pubUserPhotos = new HashMap();
    if (_pubReactTypes == null) _pubReactTypes = new Reactiontype[0];
    if (_pubTypesPub == null) _pubTypesPub = new Typepublication[0];
    if (_pubInitialConnecte == null) _pubInitialConnecte = "U";
    if (_pubConnPhotoUrl == null) _pubConnPhotoUrl = "";
    if (_pubCtx == null) _pubCtx = request.getContextPath();

    try {

        if (_pubPubs.length == 0) {
%>
<div class="fa-empty-feed">
    <i class="bi bi-newspaper"></i>
    <p>Aucune publication pour le moment.<br>Soyez le premier &agrave; publier&nbsp;!</p>
</div>
<%
        }

        for (int p = 0; p < _pubPubs.length; p++) {
            Publication pub = _pubPubs[p];
            String idpub = pub.getIdpublication();
            String auteur = (String) _pubUserNames.get(new Integer(pub.getIdutilisateur()));
            if (auteur == null) auteur = "Utilisateur";

            // Initiales auteur
            String[] _partsA = auteur.trim().split("\\s+");
            String initA = String.valueOf(Character.toUpperCase(_partsA[0].charAt(0)));
            if (_partsA.length > 1) initA += Character.toUpperCase(_partsA[_partsA.length - 1].charAt(0));
            String _authorPhoto = (String) _pubUserPhotos.get(new Integer(pub.getIdutilisateur()));

            // --- Médias ---
            Media[] medias = (Media[]) CGenUtil.rechercher(
                    new Media(), null, null, _pubConn, " and idpublication = '" + idpub + "'");
            if (medias == null) medias = new Media[0];

            // --- Réactions ---
            Publicationreaction[] reactions = (Publicationreaction[]) CGenUtil.rechercher(
                    new Publicationreaction(), null, null, _pubConn, " and idpublication = '" + idpub + "'");
            if (reactions == null) reactions = new Publicationreaction[0];

            Map reactCounts = new HashMap();
            int totalReactions = 0;
            String myReaction = "";
            for (int r = 0; r < reactions.length; r++) {
                String type = reactions[r].getIdreactiontype();
                Integer cnt = (Integer) reactCounts.get(type);
                reactCounts.put(type, cnt == null ? new Integer(1) : new Integer(cnt.intValue() + 1));
                totalReactions++;
                if (reactions[r].getIdutilisateur() == _pubRefuser) myReaction = type;
            }

            // --- Commentaires ---
            Publicationcommentaire[] comments = (Publicationcommentaire[]) CGenUtil.rechercher(
                    new Publicationcommentaire(), null, null, _pubConn,
                    " and idpublication = '" + idpub + "' and etat = 1");
            if (comments == null) comments = new Publicationcommentaire[0];
            int nbComm = comments.length;

            // --- Personnes identifiées ---
            Identification[] identTags = (Identification[]) CGenUtil.rechercher(
                    new Identification(), null, null, _pubConn, " and idpublication = '" + idpub + "'");
            if (identTags == null) identTags = new Identification[0];
            String taggedNames = "";
            if (identTags.length > 0) {
                StringBuffer sbTags = new StringBuffer();
                for (int tg = 0; tg < identTags.length; tg++) {
                    String tName = (String) _pubUserNames.get(new Integer(identTags[tg].getIdutilisateur()));
                    if (tName != null) { if (sbTags.length() > 0) sbTags.append(", "); sbTags.append(tName); }
                }
                if (sbTags.length() > 0) taggedNames = sbTags.toString();
            }

            // Échapper description
            String desc = pub.getDescritpion();
            String descSafe = "";
            if (desc != null) {
                descSafe = desc.replace("&", "&amp;").replace("<", "&lt;")
                        .replace(">", "&gt;").replace("\n", "<br>");
            }

            // Libellé type publication
            String typePubLib = pub.getIdtypepublication() != null ? pub.getIdtypepublication() : "";
            for (int t = 0; t < _pubTypesPub.length; t++) {
                if (_pubTypesPub[t].getIdtypepublication().equals(typePubLib)) { typePubLib = _pubTypesPub[t].getLibelle(); break; }
            }

            // Libellé réaction active du user
            String defaultReactId = _pubReactTypes.length > 0 ? _pubReactTypes[0].getIdreactiontype() : "";
            String myReactLib = "";
            for (int rt = 0; rt < _pubReactTypes.length; rt++) {
                if (_pubReactTypes[rt].getIdreactiontype().equals(myReaction)) { myReactLib = _pubReactTypes[rt].getLibelle(); break; }
            }
%>
<!-- ====== CARD PUBLICATION ====== -->
<div id="pub-<%= idpub %>" class="fa-post-card">

    <!-- EN-TÊTE -->
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
                mUrl = _pubCtx + "/UploadDownloadFileServlet?fileName=" + java.net.URLEncoder.encode(mUrl, "UTF-8");
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

        <!-- Réaction + barre clic -->
        <div class="fa-reaction-wrap" id="reaction-wrap-<%= idpub %>">
            <button class="fa-action-btn <%= !myReaction.isEmpty() ? "fa-action-btn--reacted" : "" %>"
                    id="react-btn-<%= idpub %>"
                    onclick="toggleReactionBar('<%= idpub %>', event)">
                <i class="bi bi-hand-thumbs-up<%= !myReaction.isEmpty() ? "-fill" : "" %>"></i>
                <span><%= !myReaction.isEmpty() ? myReactLib : "J&apos;aime" %></span>
            </button>
            <div class="fa-reaction-bar" id="reaction-bar-<%= idpub %>">
                <% for (int rt = 0; rt < _pubReactTypes.length; rt++) {
                    String rtId = _pubReactTypes[rt].getIdreactiontype();
                    String rtLib = _pubReactTypes[rt].getLibelle();
                    boolean isMyR = rtId.equals(myReaction);
                    String rtLibLow = rtLib.toLowerCase();
                    String rtEmoji = "\uD83D\uDC4D";
                    if (rtLibLow.contains("adore") || rtLibLow.contains("love")) rtEmoji = "\u2764\uFE0F";
                    else if (rtLibLow.contains("haha") || rtLibLow.contains("humour")) rtEmoji = "\uD83D\uDE02";
                    else if (rtLibLow.contains("surprise") || rtLibLow.contains("wow")) rtEmoji = "\uD83D\uDE2E";
                    else if (rtLibLow.contains("triste") || rtLibLow.contains("sad")) rtEmoji = "\uD83D\uDE22";
                    else if (rtLibLow.contains("grrr") || rtLibLow.contains("ang")) rtEmoji = "\uD83D\uDE20";
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
            <div class="fa-avatar fa-avatar--sm"<%= !_pubConnPhotoUrl.isEmpty() ? " style=\"background:transparent;\"" : "" %>><% if (!_pubConnPhotoUrl.isEmpty()) { %><img src="<%= _pubConnPhotoUrl %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= _pubInitialConnecte %><% } %></div>
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
        } // fin for publications
    } catch (Exception e) {
        e.printStackTrace();
%>
<div class="fa-error-box">
    <i class="bi bi-exclamation-triangle-fill"></i>&nbsp;Erreur lors du chargement&nbsp;: <%= e.getMessage() %>
</div>
<%
    }
%>
