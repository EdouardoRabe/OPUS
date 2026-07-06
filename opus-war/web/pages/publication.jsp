<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Media" %>
<%@ page import="alumni.Publicationreaction" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.Typepublication" %>
<%@ page import="alumni.Identification" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    /* ============================================================
       COMPOSANT PUBLICATION  -  publication.jsp
       ============================================================
       Composant réutilisable : affiche les cartes publication.
       La page appelante DOIT passer ces request attributes :
         _pub_pubs            -> Publication[]
         _pub_userNames       -> Map  (Integer idutilisateur -> String nom)
         _pub_userPhotos      -> Map  (Integer idutilisateur -> String photoUrl)
         _pub_userProfils     -> Map  (Integer idutilisateur -> String idprofil)
         _pub_reactTypes      -> Reactiontype[]
         _pub_typesPub        -> Typepublication[]
         _pub_refuser         -> Integer  (refuser du connecte)
         _pub_initialConnecte -> String
         _pub_connPhotoUrl    -> String
         _pub_ctx             -> String   (context path)
         _pub_pubMedias       -> Map  (String idpub -> Media[])
         _pub_pubReactions    -> Map  (String idpub -> Publicationreaction[])
         _pub_pubComments     -> Map  (String idpub -> Publicationcommentaire[])
         _pub_pubIdents       -> Map  (String idpub -> Identification[])
         _pub_pubSaved        -> Map  (String idpub -> Boolean)
         _pub_origPubs        -> Map  (String origId -> Publication)
         _pub_origMedias      -> Map  (String origId -> Media[])
       ============================================================ */

    Publication[] _pubPubs        = (Publication[]) request.getAttribute("_pub_pubs");
    Map _pubUserNames             = (Map) request.getAttribute("_pub_userNames");
    Map _pubUserPhotos            = (Map) request.getAttribute("_pub_userPhotos");
    Map _pubUserProfils           = (Map) request.getAttribute("_pub_userProfils");
    Map _pubUserBanned            = (Map) request.getAttribute("_pub_userBanned");
    Reactiontype[] _pubReactTypes = (Reactiontype[]) request.getAttribute("_pub_reactTypes");
    Typepublication[] _pubTypesPub = (Typepublication[]) request.getAttribute("_pub_typesPub");
    int _pubRefuser               = ((Integer) request.getAttribute("_pub_refuser")).intValue();
    String _pubInitialConnecte    = (String) request.getAttribute("_pub_initialConnecte");
    String _pubConnPhotoUrl       = (String) request.getAttribute("_pub_connPhotoUrl");
    String _pubCtx                = (String) request.getAttribute("_pub_ctx");
    Map _pubPubMedias             = (Map) request.getAttribute("_pub_pubMedias");
    Map _pubPubReactions          = (Map) request.getAttribute("_pub_pubReactions");
    Map _pubPubComments           = (Map) request.getAttribute("_pub_pubComments");
    Map _pubPubIdents             = (Map) request.getAttribute("_pub_pubIdents");
    Map _pubPubSaved              = (Map) request.getAttribute("_pub_pubSaved");
    Map _pubOrigPubs              = (Map) request.getAttribute("_pub_origPubs");
    Map _pubOrigMedias            = (Map) request.getAttribute("_pub_origMedias");

    // Valeurs par defaut
    if (_pubPubs == null) _pubPubs = new Publication[0];
    if (_pubUserNames == null) _pubUserNames = new HashMap();
    if (_pubUserPhotos == null) _pubUserPhotos = new HashMap();
    if (_pubUserProfils == null) _pubUserProfils = new HashMap();
    if (_pubUserBanned == null) _pubUserBanned = new HashMap();
    if (_pubReactTypes == null) _pubReactTypes = new Reactiontype[0];
    if (_pubTypesPub == null) _pubTypesPub = new Typepublication[0];
    if (_pubInitialConnecte == null) _pubInitialConnecte = "U";
    if (_pubConnPhotoUrl == null) _pubConnPhotoUrl = "";
    if (_pubCtx == null) _pubCtx = request.getContextPath();
    if (_pubPubMedias == null) _pubPubMedias = new HashMap();
    if (_pubPubReactions == null) _pubPubReactions = new HashMap();
    if (_pubPubComments == null) _pubPubComments = new HashMap();
    if (_pubPubIdents == null) _pubPubIdents = new HashMap();
    if (_pubPubSaved == null) _pubPubSaved = new HashMap();
    if (_pubOrigPubs == null) _pubOrigPubs = new HashMap();
    if (_pubOrigMedias == null) _pubOrigMedias = new HashMap();

    // Variables curseur pour infinite scroll
    String _lastId = "";
    String _pubLastScore = "0";
    Object _lsAttr = request.getAttribute("_pub_lastScore");
    if (_lsAttr != null) _pubLastScore = _lsAttr.toString();

    // Mode cartes uniquement (pour charger-feed.jsp / infinite scroll)
    boolean _pubCardsOnly = request.getAttribute("_pub_cardsOnly") != null;

    // Highlight publication modifiee
    String _highlightPub = request.getParameter("highlight");
    if (_highlightPub == null) _highlightPub = "";

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
        // Mise a jour curseur
        _lastId = pub.getIdpublication() != null ? pub.getIdpublication() : _lastId;
        String idpub = pub.getIdpublication();
        String auteur = (String) _pubUserNames.get(new Integer(pub.getIdutilisateur()));
        if (auteur == null) auteur = "Utilisateur";

        // Verification si l'auteur est banni
        boolean _authorBanned = _pubUserBanned.containsKey(new Integer(pub.getIdutilisateur()));
        if (_authorBanned) { auteur = "Utilisateur indisponible"; }

        // Initiales auteur
        String[] _partsA = auteur.trim().split("\\s+");
        String initA = String.valueOf(Character.toUpperCase(_partsA[0].charAt(0)));
        if (_partsA.length > 1) initA += Character.toUpperCase(_partsA[_partsA.length - 1].charAt(0));
        String _authorPhoto = (String) _pubUserPhotos.get(new Integer(pub.getIdutilisateur()));
        if (_authorBanned) { _authorPhoto = null; }

        // --- Enregistrement (saved/bookmark) ---
        boolean _isSaved = _pubPubSaved.containsKey(idpub);

        // --- Medias ---
        Media[] medias = (Media[]) _pubPubMedias.get(idpub);
        if (medias == null) medias = new Media[0];

        // --- Reactions ---
        Publicationreaction[] reactions = (Publicationreaction[]) _pubPubReactions.get(idpub);
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

        // Trier reactions par count decroissant
        java.util.List reactPairs = new java.util.ArrayList();
        for (java.util.Iterator it = reactCounts.entrySet().iterator(); it.hasNext();) {
            java.util.Map.Entry entry = (java.util.Map.Entry) it.next();
            Object[] pair = new Object[2];
            pair[0] = entry.getKey();
            pair[1] = entry.getValue();
            reactPairs.add(pair);
        }
        for (int ri = 0; ri < reactPairs.size(); ri++) {
            for (int rj = ri + 1; rj < reactPairs.size(); rj++) {
                Object[] pairA = (Object[]) reactPairs.get(ri);
                Object[] pairB = (Object[]) reactPairs.get(rj);
                Integer countA = (Integer) pairA[1];
                Integer countB = (Integer) pairB[1];
                if (countB.intValue() > countA.intValue()) {
                    reactPairs.set(ri, pairB);
                    reactPairs.set(rj, pairA);
                }
            }
        }

        // --- Commentaires ---
        Publicationcommentaire[] comments = (Publicationcommentaire[]) _pubPubComments.get(idpub);
        if (comments == null) comments = new Publicationcommentaire[0];
        int nbComm = comments.length;

        // --- Personnes identifiees ---
        Identification[] identTags = (Identification[]) _pubPubIdents.get(idpub);
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

        // Echapper description
        String desc = pub.getDescritpion();
        String descSafe = "";
        if (desc != null) {
            descSafe = desc.replace("&", "&amp;").replace("<", "&lt;")
                    .replace(">", "&gt;").replace("\n", "<br>");
            // Rendre les liens cliquables
            descSafe = descSafe.replaceAll("(https?://[^\\s<]+)", "<a href=\"$1\" target=\"_blank\" rel=\"noopener noreferrer\" style=\"color:#0a66c2;font-weight:500;\" onclick=\"event.stopPropagation();\">$1</a>");
        }

        // ---- Publication partagee : charger la pub originale ----
        boolean isSharedPost = pub.getIdpuborigine() != null && !pub.getIdpuborigine().trim().isEmpty();
        String origDesc = "", origAuteur = "", origDate = "", origMediaUrl = "", origTypePubLib2 = "";
        String origAuteurPhoto = null;
        String origAuteurInitials = "";
        String origProfileUrl = "#";
        boolean origIsVideo = false;
        Media[] origMedias = new Media[0];
        String origIdpuborigine = isSharedPost ? pub.getIdpuborigine().trim() : "";
        if (isSharedPost) {
            Publication orig = (Publication) _pubOrigPubs.get(origIdpuborigine);
            if (orig != null) {
                String od = orig.getDescritpion();
                origDesc = od != null ? od.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\n","<br>") : "";
                origDesc = origDesc.replaceAll("(https?://[^\\s<]+)", "<a href=\"$1\" target=\"_blank\" rel=\"noopener noreferrer\" style=\"color:#0a66c2;font-weight:500;\" onclick=\"event.stopPropagation();\">$1</a>");
                origDate = (orig.getDaty() != null ? orig.getDaty().toString() : "") + " \u00e0 " + (orig.getHeure() != null ? orig.getHeure() : "");
                String origTypePubId2 = orig.getIdtypepublication() != null ? orig.getIdtypepublication() : "";
                origTypePubLib2 = origTypePubId2;
                for (int t2 = 0; t2 < _pubTypesPub.length; t2++) {
                    if (_pubTypesPub[t2].getIdtypepublication().equals(origTypePubId2)) { origTypePubLib2 = _pubTypesPub[t2].getLibelle(); break; }
                }
                String oAuteur = (String) _pubUserNames.get(new Integer(orig.getIdutilisateur()));
                origAuteurPhoto = (String) _pubUserPhotos.get(new Integer(orig.getIdutilisateur()));
                String origAuteurIdprofil = (String) _pubUserProfils.get(new Integer(orig.getIdutilisateur()));
                origAuteur = oAuteur != null ? oAuteur.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;") : "Utilisateur";
                // Initiales de l'auteur original
                String[] _origPartsA = origAuteur.trim().split("\\s+");
                origAuteurInitials = String.valueOf(Character.toUpperCase(_origPartsA[0].charAt(0)));
                if (_origPartsA.length > 1) origAuteurInitials += Character.toUpperCase(_origPartsA[_origPartsA.length - 1].charAt(0));
                // URL profil auteur original
                if (orig.getIdutilisateur() == _pubRefuser) {
                    origProfileUrl = _pubCtx + "/pages/module.jsp?but=profil/voir.jsp";
                } else if (origAuteurIdprofil != null && !origAuteurIdprofil.isEmpty()) {
                    origProfileUrl = _pubCtx + "/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp?idprofil=" + origAuteurIdprofil;
                }
                // Medias de la pub originale (pre-charges par le service)
                origMedias = (Media[]) _pubOrigMedias.get(origIdpuborigine);
                if (origMedias == null) origMedias = new Media[0];
            } else { isSharedPost = false; } // pub originale supprimee
        }

        // Libelle type publication
        String typePubLib = pub.getIdtypepublication() != null ? pub.getIdtypepublication() : "";
        for (int t = 0; t < _pubTypesPub.length; t++) {
            if (_pubTypesPub[t].getIdtypepublication().equals(typePubLib)) { typePubLib = _pubTypesPub[t].getLibelle(); break; }
        }

        // Libelle de ma reaction active
        String defaultReactId = _pubReactTypes.length > 0 ? _pubReactTypes[0].getIdreactiontype() : "";
        String myReactLib = "";
        for (int rt = 0; rt < _pubReactTypes.length; rt++) {
            if (_pubReactTypes[rt].getIdreactiontype().equals(myReaction)) { myReactLib = _pubReactTypes[rt].getLibelle(); break; }
        }

        // URL profil auteur
        String authorIdprofil = (String) _pubUserProfils.get(new Integer(pub.getIdutilisateur()));
        String profileUrl;
        if (_authorBanned) {
            profileUrl = "javascript:void(0)";
        } else if (pub.getIdutilisateur() == _pubRefuser) {
            profileUrl = _pubCtx + "/pages/module.jsp?but=profil/voir.jsp";
        } else {
            profileUrl = authorIdprofil != null && !authorIdprofil.isEmpty()
                ? _pubCtx + "/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp?idprofil=" + authorIdprofil
                : "#";
        }

        // Build media JSON for Facebook-style detail modal
        StringBuffer _mediasJsonSb = new StringBuffer("[");
        for (int _mi = 0; _mi < medias.length; _mi++) {
            if (_mi > 0) _mediasJsonSb.append(",");
            String _miUrl = medias[_mi].getMediaurl();
            if (_miUrl != null && !_miUrl.startsWith("http")) {
                _miUrl = _pubCtx + "/UploadDownloadFileServlet?fileName=" + java.net.URLEncoder.encode(_miUrl, "UTF-8");
            }
            boolean _miVid = "MDT000002".equals(medias[_mi].getIdmediatype());
            _mediasJsonSb.append("{\"url\":\"").append(_miUrl.replace("\\","\\\\").replace("\"","\\\"").replace("'","&#39;")).append("\",\"type\":\"")
                         .append(_miVid ? "video" : "image").append("\"}");
        }
        _mediasJsonSb.append("]");
        String _mediasJson = _mediasJsonSb.toString();
%>
<!-- ====== CARD PUBLICATION ====== -->
<div id="pub-<%= idpub %>" class="fa-post-card<%= idpub.equals(_highlightPub) ? " pub-highlight" : "" %>"
     data-medias='<%= _mediasJson %>'
     onclick="onPubCardClick(event,'<%= idpub %>')">

    <!-- EN-TETE -->
    <div class="fa-post-header">
        <% if (_authorBanned) { %>
        <div class="fa-avatar fa-avatar--md" style="cursor:default;background:#ccc;color:#888;"><i class="bi bi-person-slash" style="font-size:1.2em;"></i></div>
        <% } else { %>
        <a href="<%= profileUrl %>" style="text-decoration:none;cursor:pointer;">
            <div class="fa-avatar fa-avatar--md" style="<%= _authorPhoto != null ? "background:transparent;" : "" %>cursor:pointer;"><% if (_authorPhoto != null) { %><img src="<%= _authorPhoto %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= initA %><% } %></div>
        </a>
        <% } %>
        <div class="fa-post-meta">
            <!-- Menu 3 points -->
            <div class="pub-menu">
                <button class="pub-menu-btn" onclick="togglePubMenu(this,event)" title="Plus d'options"><i class="bi bi-three-dots-vertical"></i></button>
                <div class="pub-menu-dropdown">
                    <button class="pub-menu-item" id="save-btn-<%= idpub %>" onclick="savePublication('<%= idpub %>')">
                        <i class="bi bi-bookmark<%= _isSaved ? "-fill" : "" %>"></i> <%= _isSaved ? "Annuler l'enregistrement" : "Enregistrer" %>
                    </button>
                    <button class="pub-menu-item" onclick="event.stopPropagation();copyPublicationLink('<%= idpub %>')">
                        <i class="bi bi-link-45deg"></i> Copier le lien
                    </button>
                    <% if (pub.getIdutilisateur() == _pubRefuser) { %>
                    <button class="pub-menu-item" onclick="window.location.href='module.jsp?but=publication/publication-modif.jsp&idpublication=<%= idpub %>&from=' + encodeURIComponent(new URLSearchParams(window.location.search).get('but') || 'accueil.jsp')">
                        <i class="bi bi-pencil"></i> Modifier
                    </button>
                    <button class="pub-menu-item" onclick="deletePublication('<%= idpub %>')">
                        <i class="bi bi-trash"></i> Supprimer
                    </button>
                    <% } else { %>
                    <button class="pub-menu-item" onclick="reportPublication('<%= idpub %>')">
                        <i class="bi bi-flag"></i> Signaler
                    </button>
                    <% } %>
                </div>
            </div>
            <div class="fa-post-author">
                <% if (_authorBanned) { %>
                <strong style="color:#888;cursor:default;"><i class="bi bi-person-slash"></i> <%= auteur %></strong>
                <% } else { %>
                <a href="<%= profileUrl %>" style="text-decoration:none;color:inherit;cursor:pointer;">
                    <strong style="cursor:pointer;"><%= auteur %></strong>
                </a>
                <% } %>
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
        <% if (medias.length > 0) {
            int showCount = medias.length > 4 ? 4 : medias.length;
            int extraCount = medias.length - 4;
        %>
        <div class="fa-media-grid grid-<%= medias.length >= 4 ? 4 : medias.length %>">
        <% for (int m = 0; m < showCount; m++) {
            String mUrl = medias[m].getMediaurl();
            if (mUrl != null && !mUrl.startsWith("http")) {
                mUrl = _pubCtx + "/UploadDownloadFileServlet?fileName=" + java.net.URLEncoder.encode(mUrl, "UTF-8");
            }
            boolean isVideo = "MDT000002".equals(medias[m].getIdmediatype());
        %>
            <div class="fa-media-grid-item" onclick="event.stopPropagation();openPublicationDetail('<%= idpub %>',<%= m %>)">
                <% if (isVideo) { %>
                <video src="<%= mUrl %>" preload="metadata" muted></video>
                <span class="fa-media-video-badge"><i class="bi bi-play-fill"></i> Vid&eacute;o</span>
                <% } else { %>
                <img src="<%= mUrl %>" alt="media">
                <% } %>
                <% if (m == 3 && extraCount > 0) { %><div class="fa-media-grid-overlay">+<%= extraCount %></div><% } %>
            </div>
        <% } %>
        </div>
        <% } %>

        <% if (isSharedPost) { %>
        <!-- Publication originale embarquee — style Facebook -->
        <div class="fa-shared-embed fa-shared-embed--clickable" onclick="openPublicationDetail('<%= origIdpuborigine %>')" title="Voir la publication originale">
            <!-- En-tete avec avatar comme une vraie pub -->
            <div class="fa-shared-embed-header-full">
                <a href="<%= origProfileUrl %>" onclick="event.stopPropagation();" style="text-decoration:none;">
                    <div class="fa-avatar fa-avatar--sm" style="<%= origAuteurPhoto != null ? "background:transparent;" : "" %>">
                        <% if (origAuteurPhoto != null) { %><img src="<%= origAuteurPhoto %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;">
                        <% } else { %><%= origAuteurInitials %><% } %>
                    </div>
                </a>
                <div class="fa-shared-embed-meta">
                    <a href="<%= origProfileUrl %>" onclick="event.stopPropagation();" style="text-decoration:none;color:inherit;">
                        <strong class="fa-shared-embed-author"><%= origAuteur %></strong>
                    </a>
                    <div class="fa-shared-embed-date-line">
                        <span class="fa-shared-embed-date"><%= origDate %></span>
                        <% if (!origTypePubLib2.isEmpty()) { %><span class="fa-type-badge"><%= origTypePubLib2 %></span><% } %>
                    </div>
                </div>
            </div>
            <!-- Texte de la pub originale -->
            <% if (!origDesc.isEmpty()) { %><div class="fa-shared-embed-text"><%= origDesc %></div><% } %>
            <!-- Medias de la pub originale (grille comme une pub normale) -->
            <% if (origMedias.length > 0) {
                int origShowCount = origMedias.length > 4 ? 4 : origMedias.length;
                int origExtraCount = origMedias.length - 4;
            %>
            <div class="fa-media-grid grid-<%= origMedias.length >= 4 ? 4 : origMedias.length %>" style="margin-top:8px;">
            <% for (int om = 0; om < origShowCount; om++) {
                String omUrl = origMedias[om].getMediaurl();
                if (omUrl != null && !omUrl.startsWith("http")) {
                    omUrl = _pubCtx + "/UploadDownloadFileServlet?fileName=" + java.net.URLEncoder.encode(omUrl, "UTF-8");
                }
                boolean omIsVideo = "MDT000002".equals(origMedias[om].getIdmediatype());
            %>
                <div class="fa-media-grid-item" onclick="event.stopPropagation();<%= omIsVideo ? "openVideoZoom('" + omUrl.replace("'","\\\\'") + "')" : "openMediaZoom('" + omUrl.replace("'","\\\\'") + "')" %>">
                    <% if (omIsVideo) { %>
                    <video src="<%= omUrl %>" preload="metadata" muted></video>
                    <span class="fa-media-video-badge"><i class="bi bi-play-fill"></i> Vid&eacute;o</span>
                    <% } else { %>
                    <img src="<%= omUrl %>" alt="media">
                    <% } %>
                    <% if (om == 3 && origExtraCount > 0) { %><div class="fa-media-grid-overlay">+<%= origExtraCount %></div><% } %>
                </div>
            <% } %>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <!-- COMPTEURS -->
    <div class="fa-post-counters">
        <% if (reactPairs.size() > 0) { %>
            <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;cursor:pointer;" title="Voir les r&eacute;actions" onclick="openReactionDetails('<%= idpub %>')">
                <% for (int rpi = 0; rpi < reactPairs.size(); rpi++) {
                    Object[] pair = (Object[]) reactPairs.get(rpi);
                    String rtId = (String) pair[0];
                    Integer rtCount = (Integer) pair[1];
                    String rtEmoji = "\uD83D\uDC4D";
                    String rtLib = "";
                    for (int rt = 0; rt < _pubReactTypes.length; rt++) {
                        if (_pubReactTypes[rt].getIdreactiontype().equals(rtId)) {
                            rtLib = _pubReactTypes[rt].getLibelle();
                            String rtLibLow = rtLib.toLowerCase();
                            if (rtLibLow.contains("adore") || rtLibLow.contains("love")) rtEmoji = "\u2764\uFE0F";
                            else if (rtLibLow.contains("haha") || rtLibLow.contains("humour")) rtEmoji = "\uD83D\uDE02";
                            else if (rtLibLow.contains("surprise") || rtLibLow.contains("wow")) rtEmoji = "\uD83D\uDE2E";
                            else if (rtLibLow.contains("triste") || rtLibLow.contains("sad")) rtEmoji = "\uD83D\uDE22";
                            else if (rtLibLow.contains("grrr") || rtLibLow.contains("ang")) rtEmoji = "\uD83D\uDE20";
                            break;
                        }
                    }
                %>
                <span class="fa-counter" title="<%= rtLib %>"><%= rtEmoji %>&nbsp;<%= rtCount %></span>
                <% } %>
            </div>
        <% } else { %><span></span><% } %>
        <span id="nb-comm-<%= idpub %>" class="fa-counter fa-counter--link"
              onclick="toggleCommentaires('<%= idpub %>')">
            <%= nbComm > 0 ? nbComm + " commentaire" + (nbComm > 1 ? "s" : "") : "" %>
        </span>
    </div>

    <div class="fa-post-divider"></div>

    <!-- BARRE D'ACTIONS -->
    <div class="fa-post-actions">

        <!-- Reaction + barre clic -->
        <div class="fa-reaction-wrap" id="reaction-wrap-<%= idpub %>">
            <button class="fa-action-btn <%= !myReaction.isEmpty() ? "fa-action-btn--reacted" : "" %>"
                    id="react-btn-<%= idpub %>"
                    data-react-main="1" data-idpub="<%= idpub %>"
                    data-myreaction="<%= myReaction %>" data-default="<%= defaultReactId %>"
                    onclick="quickReact('<%= idpub %>', event)">
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

        <!-- Identifier (seulement pour l'auteur) -->
        <% if (pub.getIdutilisateur() == _pubRefuser) { %>
        <button class="fa-action-btn" onclick="toggleIdentifier('<%= idpub %>')">
            <i class="bi bi-tag"></i>&nbsp;<span>Identifier</span>
        </button>
        <% } %>

        <!-- Partager (seulement pour les pubs d'autres personnes, pas un partage deja) -->
        <% if (pub.getIdutilisateur() != _pubRefuser && !isSharedPost) { %>
        <%  String _shareAuteurEsc = auteur.replace("'","\\'").replace("\"","\\\"");
            // Utiliser desc (texte brut) au lieu de descSafe (qui contient du HTML <a>)
            String _shareTexteEsc = "";
            if (desc != null && !desc.isEmpty()) {
                _shareTexteEsc = desc
                    .replace("\\", "\\\\")
                    .replace("'", "\\'")
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\n", " ")
                    .replace("\r", "");
                // Limiter la longueur pour eviter les problemes
                if (_shareTexteEsc.length() > 200) {
                    _shareTexteEsc = _shareTexteEsc.substring(0, 200) + "...";
                }
            }
        %>
        <button class="fa-action-btn" onclick="openShareModal('<%= idpub %>','<%= _shareAuteurEsc %>','<%= pub.getDaty() %>&nbsp;&agrave;&nbsp;<%= pub.getHeure() != null ? pub.getHeure() : "" %>','<%= _shareTexteEsc %>')">
            <i class="bi bi-share"></i>&nbsp;<span>Partager</span>
        </button>
        <% } %>
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

    // --- Infinite scroll : curseur + sentinel (seulement en mode complet) ---
    if (!_pubCardsOnly) {
    boolean _hasMore = (_pubPubs.length == 10);
%>
<span id="feed-cursor" style="display:none"
      data-score="<%= _pubLastScore %>"
      data-id="<%= _lastId %>"
      data-has-more="<%= _hasMore %>"></span>
<div id="feed-sentinel" style="height:4px;margin:4px 0;"></div>
<div id="feed-loader" style="display:none;text-align:center;padding:20px;">
    <div class="fa-feed-spinner"></div>
</div>

<% if (!_highlightPub.isEmpty()) { %>
<script>
(function() {
    var el = document.getElementById("pub-<%= _highlightPub %>");
    if (el) {
        setTimeout(function() {
            el.scrollIntoView({ behavior: "smooth", block: "center" });
        }, 300);
    }
})();
</script>
<% } %>

<script>
function deletePublication(idpub) {
    if (!confirm('\u00cates-vous s\u00fbr de vouloir supprimer cette publication ? Cette action est irr\u00e9versible.')) return;
    fetch('<%= _pubCtx %>/pages/publication/ajax/traitement-delete.jsp?idpublication=' + encodeURIComponent(idpub))
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.success) {
            var card = document.getElementById('pub-' + idpub);
            if (card) {
                card.style.transition = 'opacity 0.4s, transform 0.4s';
                card.style.opacity = '0';
                card.style.transform = 'scale(0.95)';
                setTimeout(function() { card.remove(); }, 400);
            }
        } else {
            alert('Erreur : ' + data.error);
        }
    })
    .catch(function(err) { alert('Erreur r\u00e9seau : ' + err); });
}
</script>
<%
    } // fin if !_pubCardsOnly
%>
