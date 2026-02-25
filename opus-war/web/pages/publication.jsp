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
         _pub_conn            -> Connection (pas fermee ici)
       ============================================================ */

    Publication[] _pubPubs        = (Publication[]) request.getAttribute("_pub_pubs");
    Map _pubUserNames             = (Map) request.getAttribute("_pub_userNames");
    Map _pubUserPhotos            = (Map) request.getAttribute("_pub_userPhotos");
    Map _pubUserProfils           = (Map) request.getAttribute("_pub_userProfils");
    Reactiontype[] _pubReactTypes = (Reactiontype[]) request.getAttribute("_pub_reactTypes");
    Typepublication[] _pubTypesPub = (Typepublication[]) request.getAttribute("_pub_typesPub");
    int _pubRefuser               = ((Integer) request.getAttribute("_pub_refuser")).intValue();
    String _pubInitialConnecte    = (String) request.getAttribute("_pub_initialConnecte");
    String _pubConnPhotoUrl       = (String) request.getAttribute("_pub_connPhotoUrl");
    String _pubCtx                = (String) request.getAttribute("_pub_ctx");
    Connection _pubConn           = (Connection) request.getAttribute("_pub_conn");

    // Valeurs par defaut
    if (_pubPubs == null) _pubPubs = new Publication[0];
    if (_pubUserNames == null) _pubUserNames = new HashMap();
    if (_pubUserPhotos == null) _pubUserPhotos = new HashMap();
    if (_pubUserProfils == null) _pubUserProfils = new HashMap();
    if (_pubReactTypes == null) _pubReactTypes = new Reactiontype[0];
    if (_pubTypesPub == null) _pubTypesPub = new Typepublication[0];
    if (_pubInitialConnecte == null) _pubInitialConnecte = "U";
    if (_pubConnPhotoUrl == null) _pubConnPhotoUrl = "";
    if (_pubCtx == null) _pubCtx = request.getContextPath();

    // Variables curseur pour infinite scroll
    String _lastId = "";
    String _pubLastScore = "0";
    Object _lsAttr = request.getAttribute("_pub_lastScore");
    if (_lsAttr != null) _pubLastScore = _lsAttr.toString();

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

        // Initiales auteur
        String[] _partsA = auteur.trim().split("\\s+");
        String initA = String.valueOf(Character.toUpperCase(_partsA[0].charAt(0)));
        if (_partsA.length > 1) initA += Character.toUpperCase(_partsA[_partsA.length - 1].charAt(0));
        String _authorPhoto = (String) _pubUserPhotos.get(new Integer(pub.getIdutilisateur()));

        // --- Medias ---
        Media[] medias = (Media[]) CGenUtil.rechercher(
                new Media(), null, null, _pubConn, " and idpublication = '" + idpub + "'");
        if (medias == null) medias = new Media[0];

        // --- Reactions ---
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
        Publicationcommentaire[] comments = (Publicationcommentaire[]) CGenUtil.rechercher(
                new Publicationcommentaire(), null, null, _pubConn,
                " and idpublication = '" + idpub + "' and etat = 1");
        if (comments == null) comments = new Publicationcommentaire[0];
        int nbComm = comments.length;

        // --- Personnes identifiees ---
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

        // Echapper description
        String desc = pub.getDescritpion();
        String descSafe = "";
        if (desc != null) {
            descSafe = desc.replace("&", "&amp;").replace("<", "&lt;")
                    .replace(">", "&gt;").replace("\n", "<br>");
        }

        // ---- Publication partagee : charger la pub originale ----
        boolean isSharedPost = pub.getIdpuborigine() != null && !pub.getIdpuborigine().trim().isEmpty();
        String origDesc = "", origAuteur = "", origDate = "", origMediaUrl = "", origTypePubLib2 = "";
        String origIdpuborigine = isSharedPost ? pub.getIdpuborigine().trim() : "";
        if (isSharedPost) {
            Publication[] origPubs = (Publication[]) CGenUtil.rechercher(
                new Publication(), null, null, _pubConn, " and idpublication = '" + origIdpuborigine + "'");
            if (origPubs != null && origPubs.length > 0) {
                Publication orig = origPubs[0];
                String od = orig.getDescritpion();
                origDesc = od != null ? od.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\n","<br>") : "";
                origDate = (orig.getDaty() != null ? orig.getDaty().toString() : "") + " \u00e0 " + (orig.getHeure() != null ? orig.getHeure() : "");
                String origTypePubId2 = orig.getIdtypepublication() != null ? orig.getIdtypepublication() : "";
                origTypePubLib2 = origTypePubId2;
                for (int t2 = 0; t2 < _pubTypesPub.length; t2++) {
                    if (_pubTypesPub[t2].getIdtypepublication().equals(origTypePubId2)) { origTypePubLib2 = _pubTypesPub[t2].getLibelle(); break; }
                }
                String oAuteur = (String) _pubUserNames.get(new Integer(orig.getIdutilisateur()));
                if (oAuteur == null) {
                    alumni.ProfilLib[] op2 = (alumni.ProfilLib[]) CGenUtil.rechercher(
                        new alumni.ProfilLib(), null, null, _pubConn, " and refuser = " + orig.getIdutilisateur());
                    if (op2 != null && op2.length > 0) { oAuteur = (op2[0].getNom() != null ? op2[0].getNom() : "") + (op2[0].getPrenom() != null ? " " + op2[0].getPrenom() : ""); }
                }
                origAuteur = oAuteur != null ? oAuteur.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;") : "Utilisateur";
                Media[] om2 = (Media[]) CGenUtil.rechercher(new Media(), null, null, _pubConn, " and idpublication = '" + origIdpuborigine + "'");
                if (om2 != null && om2.length > 0 && om2[0].getMediaurl() != null) {
                    String omu = om2[0].getMediaurl();
                    origMediaUrl = omu.startsWith("http") ? omu : _pubCtx + "/UploadDownloadFileServlet?fileName=" + java.net.URLEncoder.encode(omu, "UTF-8");
                }
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
        if (pub.getIdutilisateur() == _pubRefuser) {
            profileUrl = _pubCtx + "/pages/module.jsp?but=profil/voir.jsp";
        } else {
            profileUrl = authorIdprofil != null && !authorIdprofil.isEmpty()
                ? _pubCtx + "/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp?idprofil=" + authorIdprofil
                : "#";
        }
%>
<!-- ====== CARD PUBLICATION ====== -->
<div id="pub-<%= idpub %>" class="fa-post-card<%= idpub.equals(_highlightPub) ? " pub-highlight" : "" %>">

    <!-- EN-TETE -->
    <div class="fa-post-header">
        <a href="<%= profileUrl %>" style="text-decoration:none;cursor:pointer;">
            <div class="fa-avatar fa-avatar--md" style="<%= _authorPhoto != null ? "background:transparent;" : "" %>cursor:pointer;"><% if (_authorPhoto != null) { %><img src="<%= _authorPhoto %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= initA %><% } %></div>
        </a>
        <div class="fa-post-meta">
            <!-- Menu 3 points -->
            <div class="pub-menu">
                <button class="pub-menu-btn" onclick="togglePubMenu(this,event)" title="Plus d'options"><i class="bi bi-three-dots-vertical"></i></button>
                <div class="pub-menu-dropdown">
                    <button class="pub-menu-item" onclick="savePublication('<%= idpub %>')">
                        <i class="bi bi-bookmark"></i> Enregistrer
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
                <a href="<%= profileUrl %>" style="text-decoration:none;color:inherit;cursor:pointer;">
                    <strong style="cursor:pointer;"><%= auteur %></strong>
                </a>
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

        <% if (isSharedPost) { %>
        <!-- Publication originale embarquee — cliquable pour voir en detail -->
        <div class="fa-shared-embed fa-shared-embed--clickable" onclick="openPublicationDetail('<%= origIdpuborigine %>')" title="Voir la publication originale">
            <div class="fa-shared-embed-header">
                <span class="fa-shared-embed-author"><%= origAuteur %></span>
                <span class="fa-shared-embed-date">&nbsp;&middot;&nbsp;<%= origDate %></span>
                <% if (!origTypePubLib2.isEmpty()) { %><span class="fa-type-badge"><%= origTypePubLib2 %></span><% } %>
            </div>
            <% if (!origDesc.isEmpty()) { %><div class="fa-shared-embed-text"><%= origDesc %></div><% } %>
            <% if (!origMediaUrl.isEmpty()) { %><img src="<%= origMediaUrl %>" alt="" onclick="event.stopPropagation();openMediaZoom(this.src)"><% } %>
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

        <!-- Identifier (seulement pour l'auteur) -->
        <% if (pub.getIdutilisateur() == _pubRefuser) { %>
        <button class="fa-action-btn" onclick="toggleIdentifier('<%= idpub %>')">
            <i class="bi bi-tag"></i>&nbsp;<span>Identifier</span>
        </button>
        <% } %>

        <!-- Partager (seulement pour les pubs d'autres personnes, pas un partage deja) -->
        <% if (pub.getIdutilisateur() != _pubRefuser && !isSharedPost) { %>
        <%  String _shareAuteurEsc = auteur.replace("'","\\'").replace("\"","\\\"");
            String _shareTexteEsc  = descSafe.isEmpty() ? "" : descSafe.replace("<br>"," ").replace("'","\\'").replace("\"","\\\""); %>
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

    // --- Infinite scroll : curseur + sentinel ---
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
