<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="bean.ClassMAPTable" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Media" %>
<%@ page import="alumni.Publicationreaction" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.Typepublication" %>
<%@ page import="alumni.Profil" %>
<%@ page import="alumni.Identification" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    UserEJB uFil = (UserEJB) session.getAttribute("u");
    MapUtilisateur mapFil = uFil.getUser();
    int refuserConnecte = mapFil.getRefuser();
    String nomConnecte = mapFil.getNomuser() != null ? mapFil.getNomuser() : "";
    String ctx = request.getContextPath();
    // Initiales du user connecte
    String[] _partsConn = nomConnecte.trim().split("\\s+");
    String initialConnecte = (_partsConn.length > 0 && _partsConn[0].length() > 0)
        ? String.valueOf(Character.toUpperCase(_partsConn[0].charAt(0))) : "U";
    if (_partsConn.length > 1 && _partsConn[_partsConn.length-1].length() > 0)
        initialConnecte += Character.toUpperCase(_partsConn[_partsConn.length-1].charAt(0));

    // Messages flash
    String msgSucces = (String) session.getAttribute("pubSucces");
    if (msgSucces != null) session.removeAttribute("pubSucces");
    String msgErreur = (String) session.getAttribute("pubErreur");
    if (msgErreur != null) session.removeAttribute("pubErreur");

    // --- APJ: Charger les types de publication pour le dropdown ---
    Typepublication[] typesPub = (Typepublication[]) CGenUtil.rechercher(
        new Typepublication(), null, null, " order by idtypepublication");
    if (typesPub == null) typesPub = new Typepublication[0];
%>

<div class="fa-layout">

    <!-- ===== COLONNE GAUCHE : Profil ===== -->
    <aside class="fa-sidebar-left">
        <div class="fa-profile-card">
            <div class="fa-profile-cover"></div>
            <div class="fa-profile-body">
                <div class="fa-profile-avatar-wrap">
                    <div class="fa-avatar fa-avatar--lg"><%= initialConnecte %></div>
                </div>
                <div class="fa-profile-name"><%= nomConnecte %></div>
                <hr class="fa-divider">
                <nav class="fa-profile-nav">
                    <a href="<%= ctx %>module.jsp?but=profil/voir.jsp" class="fa-nav-link">
                        <i class="bi bi-person-fill"></i> Mon profil
                    </a>
                    <a href="#" class="fa-nav-link fa-nav-link--active">
                        <i class="bi bi-newspaper"></i> Fil d&apos;actualit&eacute;
                    </a>
                    <a href="<%= ctx %>/pages/module.jsp?but=alumni/notifications.jsp" class="fa-nav-link">
                        <i class="bi bi-bell-fill"></i> Notifications
                    </a>
                </nav>
            </div>
        </div>
    </aside>

    <!-- ===== COLONNE CENTRALE : Fil ===== -->
    <main class="fa-feed-center">

        <!-- Flash messages via Swal -->
        <% if (msgSucces != null) { %>
        <script>document.addEventListener('DOMContentLoaded',function(){Swal.fire({toast:true,position:'top-end',icon:'success',title:'<%= msgSucces.replace("'","\\'").replace("<","&lt;") %>',timer:3000,showConfirmButton:false});});</script>
        <% } %>
        <% if (msgErreur != null) { %>
        <script>document.addEventListener('DOMContentLoaded',function(){Swal.fire({icon:'error',title:'Erreur',text:'<%= msgErreur.replace("'","\\'").replace("<","&lt;") %>',confirmButtonColor:'var(--itu-blue)'});});</script>
        <% } %>

        <!-- ===== COMPOSER ===== -->
        <div class="fa-composer-card" id="composer-card">
            <div class="fa-composer-trigger" id="composer-trigger" onclick="openComposer()">
                <div class="fa-avatar fa-avatar--sm"><%= initialConnecte %></div>
                <div class="fa-composer-placeholder">Quoi de neuf&nbsp;?</div>
            </div>
            <div class="fa-composer-quick-actions" id="composer-quick-actions">
                <button class="fa-quick-action-btn" type="button"
                    onclick="openComposer();setTimeout(function(){document.getElementById('composer-img-input').click();},120)">
                    <i class="bi bi-image-fill" style="color:#45bd62;"></i>&nbsp;Photo
                </button>
                <button class="fa-quick-action-btn" type="button"
                    onclick="openComposer();setTimeout(function(){togglePubTag();},120)">
                    <i class="bi bi-tag-fill" style="color:#f7b928;"></i>&nbsp;Identifier
                </button>
            </div>
            <!-- Formulaire complet (masqué par défaut) -->
            <div class="fa-composer-full" id="composer-full" style="display:none;">
                <form method="POST" enctype="multipart/form-data" id="form-pub"
                      action="<%= ctx %>/pages/alumni/ajax/creer-publication.jsp"
                      onsubmit="return validatePubFormSize()">
                    <div class="fa-composer-header">
                        <div class="fa-avatar fa-avatar--md"><%= initialConnecte %></div>
                        <div>
                            <strong><%= nomConnecte %></strong>
                            <select name="idtypepublication" class="fa-type-select">
                                <% for (int t = 0; t < typesPub.length; t++) { %>
                                <option value="<%= typesPub[t].getIdtypepublication() %>"><%= typesPub[t].getLibelle() %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                    <textarea name="description" class="fa-composer-textarea" rows="4"
                              placeholder="Quoi de neuf, <%= nomConnecte %> ?"></textarea>
                    <div id="composer-img-preview" style="display:none;" class="fa-img-preview-wrap">
                        <img id="composer-img-previewImg" src="" class="fa-img-preview" alt="apercu">
                        <button type="button" class="fa-img-remove-btn" onclick="removeComposerImg()"><i class="bi bi-x-lg"></i></button>
                    </div>
                    <!-- Zone identification -->
                    <div class="fa-composer-tags-area">
                        <a href="javascript:void(0)" onclick="togglePubTag()" class="fa-tag-toggle">
                            <i class="bi bi-tag-fill"></i> Identifier des personnes
                        </a>
                        <div id="pub-tag-zone" style="display:none;margin-top:8px;">
                            <input type="text" id="pub-tag-search" placeholder="Rechercher un utilisateur..."
                                   oninput="rechercherPourPubTag()" autocomplete="off" class="fa-input">
                            <div id="pub-tag-suggestions" class="fa-suggestions-list"></div>
                            <div id="pub-tag-selected" class="fa-chips-row"></div>
                        </div>
                        <input type="hidden" name="identifications" id="pub-identifications" value="">
                    </div>
                    <div class="fa-composer-footer">
                        <label class="fa-attach-btn">
                            <i class="bi bi-image"></i>&nbsp;Photo/Vid&eacute;o
                            <input type="file" id="composer-img-input" name="image" accept="image/*" style="display:none;"
                                   onchange="previewComposerImg(this)">
                        </label>
                        <div class="fa-composer-submit-group">
                            <button type="button" class="fa-btn-cancel" onclick="closeComposer()">Annuler</button>
                            <button type="submit" class="fa-btn-publish">Publier</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- ===== PUBLICATIONS ===== -->
        <%
            Connection conn = null;
            try {
                conn = new UtilDB().GetConn();

                // --- APJ: Charger types de reactions ---
                Reactiontype[] reactTypes = (Reactiontype[]) CGenUtil.rechercher(
                    new Reactiontype(), null, null, conn, " order by idreactiontype");
                if (reactTypes == null) reactTypes = new Reactiontype[0];

                // --- APJ: Charger tous les profils pour lookup nom ---
                alumni.Profil[] allProfils = (alumni.Profil[]) CGenUtil.rechercher(
                    new alumni.Profil(), null, null, conn, "");
                Map userNames = new HashMap();
                if (allProfils != null) {
                    for (int i = 0; i < allProfils.length; i++) {
                        userNames.put(new Integer(allProfils[i].getIdutilisateur()), allProfils[i].getNom() + " " + allProfils[i].getPrenom());
                    }
                }

                // --- APJ: Charger les publications actives ---
                Publication[] pubs = (Publication[]) CGenUtil.rechercher(
                    new Publication(), null, null, conn, " and etat = 1 order by daty desc, heure desc");
                if (pubs == null) pubs = new Publication[0];

                if (pubs.length == 0) {
        %>
            <div class="fa-empty-feed">
                <i class="bi bi-newspaper"></i>
                <p>Aucune publication pour le moment.<br>Soyez le premier &agrave; publier&nbsp;!</p>
            </div>
        <%
                }

                for (int p = 0; p < pubs.length; p++) {
                    Publication pub = pubs[p];
                    String idpub = pub.getIdpublication();
                    String auteur = (String) userNames.get(new Integer(pub.getIdutilisateur()));
                    if (auteur == null) auteur = "Utilisateur";

                    // Initiales auteur
                    String[] _partsA = auteur.trim().split("\\s+");
                    String initA = String.valueOf(Character.toUpperCase(_partsA[0].charAt(0)));
                    if (_partsA.length > 1) initA += Character.toUpperCase(_partsA[_partsA.length-1].charAt(0));

                    // --- APJ: Medias ---
                    Media[] medias = (Media[]) CGenUtil.rechercher(
                        new Media(), null, null, conn, " and idpublication = '" + idpub + "'");
                    if (medias == null) medias = new Media[0];

                    // --- APJ: Reactions ---
                    Publicationreaction[] reactions = (Publicationreaction[]) CGenUtil.rechercher(
                        new Publicationreaction(), null, null, conn, " and idpublication = '" + idpub + "'");
                    if (reactions == null) reactions = new Publicationreaction[0];

                    Map reactCounts = new HashMap();
                    int totalReactions = 0;
                    String myReaction = "";
                    for (int r = 0; r < reactions.length; r++) {
                        String type = reactions[r].getIdreactiontype();
                        Integer cnt = (Integer) reactCounts.get(type);
                        reactCounts.put(type, cnt == null ? new Integer(1) : new Integer(cnt.intValue() + 1));
                        totalReactions++;
                        if (reactions[r].getIdutilisateur() == refuserConnecte) myReaction = type;
                    }

                    // --- APJ: Commentaires ---
                    Publicationcommentaire[] comments = (Publicationcommentaire[]) CGenUtil.rechercher(
                        new Publicationcommentaire(), null, null, conn,
                        " and idpublication = '" + idpub + "' and etat = 1");
                    if (comments == null) comments = new Publicationcommentaire[0];
                    int nbComm = comments.length;

                    // --- APJ: Personnes identifiees ---
                    Identification[] identTags = (Identification[]) CGenUtil.rechercher(
                        new Identification(), null, null, conn, " and idpublication = '" + idpub + "'");
                    if (identTags == null) identTags = new Identification[0];
                    String taggedNames = "";
                    if (identTags.length > 0) {
                        StringBuffer sbTags = new StringBuffer();
                        for (int tg = 0; tg < identTags.length; tg++) {
                            String tName = (String) userNames.get(new Integer(identTags[tg].getIdutilisateur()));
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

                    // Libelle type publication
                    String typePubLib = pub.getIdtypepublication() != null ? pub.getIdtypepublication() : "";
                    for (int t = 0; t < typesPub.length; t++) {
                        if (typesPub[t].getIdtypepublication().equals(typePubLib)) { typePubLib = typesPub[t].getLibelle(); break; }
                    }

                    // Libelle de ma reaction active
                    String defaultReactId = reactTypes.length > 0 ? reactTypes[0].getIdreactiontype() : "";
                    String myReactLib = "";
                    for (int rt = 0; rt < reactTypes.length; rt++) {
                        if (reactTypes[rt].getIdreactiontype().equals(myReaction)) { myReactLib = reactTypes[rt].getLibelle(); break; }
                    }
        %>
        <!-- ====== CARD PUBLICATION ====== -->
        <div id="pub-<%= idpub %>" class="fa-post-card">

            <!-- EN-TETE -->
            <div class="fa-post-header" style="position:relative;">
                <div class="fa-avatar fa-avatar--md"><%= initA %></div>
                <div class="fa-post-meta">
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
                <!-- three dots menu -->
                <div class="pub-menu" style="position:absolute;top:12px;right:12px;">
                    <button class="pub-menu-btn" onclick="togglePubMenu(this,event)" title="Plus d'options"><i class="bi bi-three-dots-vertical"></i></button>
                    <div class="pub-menu-dropdown" style="display:none;position:absolute;right:0;top:100%;background:#fff;border:1px solid #dde3ec;border-radius:6px;box-shadow:0 6px 20px rgba(0,0,0,.12);min-width:120px;z-index:100;">
                        <button class="pub-menu-item" onclick="savePublication('<%= idpub %>')" style="width:100%;padding:8px;text-align:left;border:none;background:transparent;cursor:pointer;">
                            <i class="fa fa-bookmark"></i> Sauvegarder
                        </button>
                        <button class="pub-menu-item" onclick="reportPublication('<%= idpub %>')" style="width:100%;padding:8px;text-align:left;border:none;background:transparent;cursor:pointer;"> 
                            <i class="fa fa-flag"></i> Signaler
                        </button>  
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

                <!-- Reaction + barre clic -->
                <div class="fa-reaction-wrap" id="reaction-wrap-<%= idpub %>">
                    <button class="fa-action-btn <%= !myReaction.isEmpty() ? "fa-action-btn--reacted" : "" %>"
                            id="react-btn-<%= idpub %>"
                            onclick="toggleReactionBar('<%= idpub %>', event)">
                        <i class="bi bi-hand-thumbs-up<%= !myReaction.isEmpty() ? "-fill" : "" %>"></i>
                        <span><%= !myReaction.isEmpty() ? myReactLib : "J&apos;aime" %></span>
                    </button>
                    <div class="fa-reaction-bar" id="reaction-bar-<%= idpub %>">
                        <% for (int rt = 0; rt < reactTypes.length; rt++) {
                            String rtId = reactTypes[rt].getIdreactiontype();
                            String rtLib = reactTypes[rt].getLibelle();
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
                    <div class="fa-avatar fa-avatar--sm"><%= initialConnecte %></div>
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
            } finally {
                if (conn != null) try { conn.close(); } catch (Exception ex) {}
            }
        %>

    </main><!-- /fa-feed-center -->

    <!-- ===== COLONNE DROITE (a implementer) ===== -->
    <aside class="fa-sidebar-right">
        <!-- widgets futurs -->
    </aside>

</div><!-- /fa-layout -->

<!-- ==================== STYLES FIL D'ACTUALITE ==================== -->
<!-- Shared feed styles now loaded globally via css.jsp (fa-variables, fa-avatar, fa-feed-layout, fa-post-card, fa-composer) -->

<!-- ==================== JAVASCRIPT ==================== -->
<script>
var CTX = '<%= ctx %>';
var CURRENT_USER_ID = '<%= refuserConnecte %>';

// ========== DONNEES TEMPORAIRES MENTIONS ==========
var mentionData = {}; // { idpub: { suggestions: [], selectedIndex: 0, mentionIds: [], searchStart: -1 } }

function getMentionState(idpub) {
    if (!mentionData[idpub]) {
        mentionData[idpub] = { suggestions: [], selectedIndex: 0, mentionIds: [], searchStart: -1 };
    }
    return mentionData[idpub];
}

// ========== IDENTIFICATION (TAGS) ==========
var tagData = {}; // { idpub: { selectedUsers: [{id, nom}] } }

function getTagState(idpub) {
    if (!tagData[idpub]) tagData[idpub] = { selectedUsers: [] };
    return tagData[idpub];
}

function toggleIdentifier(idpub) {
    var div = document.getElementById('identifier-' + idpub);
    div.style.display = (div.style.display === 'none') ? 'block' : 'none';
}

function rechercherPourTag(idpub) {
    var input = document.getElementById('tag-search-' + idpub);
    var query = input.value.trim();
    var sugDiv = document.getElementById('tag-suggestions-' + idpub);
    if (query.length < 1) { sugDiv.innerHTML = ''; return; }

    fetch(CTX + '/pages/alumni/ajax/rechercher-utilisateurs.jsp?q=' + encodeURIComponent(query))
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (!data.success) return;
        var html = '';
        var state = getTagState(idpub);
        var alreadyIds = state.selectedUsers.map(function(u) { return u.id; });
        data.utilisateurs.forEach(function(u) {
            if (alreadyIds.indexOf(u.id) === -1) {
                html += '<div class="mention-item" style="padding:6px 10px;cursor:pointer;border-bottom:1px solid #f0f0f0;" '
                    + 'onclick="selectTag(\'' + idpub + '\',' + u.id + ',\'' + escAttr(u.nomComplet) + '\')">'
                    + escHtml(u.nomComplet) + '</div>';
            }
        });
        sugDiv.innerHTML = html || '<div style="padding:6px 10px;color:#999;">Aucun resultat</div>';
    });
}

function selectTag(idpub, userId, nomComplet) {
    var state = getTagState(idpub);
    // Eviter les doublons
    for (var i = 0; i < state.selectedUsers.length; i++) {
        if (state.selectedUsers[i].id === userId) return;
    }
    state.selectedUsers.push({ id: userId, nom: nomComplet });
    renderTags(idpub);
    document.getElementById('tag-search-' + idpub).value = '';
    document.getElementById('tag-suggestions-' + idpub).innerHTML = '';
}

function removeTag(idpub, userId) {
    var state = getTagState(idpub);
    state.selectedUsers = state.selectedUsers.filter(function(u) { return u.id !== userId; });
    renderTags(idpub);
}

function renderTags(idpub) {
    var state = getTagState(idpub);
    var container = document.getElementById('tag-selected-' + idpub);
    var html = '';
    state.selectedUsers.forEach(function(u) {
        html += '<span class="tag-chip">' + escHtml(u.nom) 
            + ' <span class="remove-tag" onclick="removeTag(\'' + idpub + '\',' + u.id + ')">&times;</span></span>';
    });
    container.innerHTML = html;
}

function envoyerIdentifications(idpub) {
    var state = getTagState(idpub);
    if (state.selectedUsers.length === 0) { alert('Selectionnez au moins un utilisateur'); return; }
    var ids = state.selectedUsers.map(function(u) { return u.id; }).join(',');

    fetch(CTX + '/pages/alumni/ajax/identifier.jsp', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'idpublication=' + encodeURIComponent(idpub) + '&idutilisateurs=' + encodeURIComponent(ids)
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.success) {
            state.selectedUsers = [];
            renderTags(idpub);
            document.getElementById('identifier-' + idpub).style.display = 'none';
            Swal.fire({ title: 'Identification envoyee', icon: 'success', timer: 1500, showConfirmButton: false });
        } else {
            alert('Erreur: ' + (data.error || 'Inconnue'));
        }
    })
    .catch(function(e) { alert('Erreur reseau: ' + e); });
}

// ========== MENTION (@) DANS LES COMMENTAIRES ==========
function onCommentInput(input, idpub) {
    var val = input.value;
    var cursorPos = input.selectionStart;
    var state = getMentionState(idpub);

    // Chercher le dernier @ avant le curseur
    var textBeforeCursor = val.substring(0, cursorPos);
    var atIdx = textBeforeCursor.lastIndexOf('@');

    if (atIdx >= 0) {
        // Verifier qu'il n'y a pas d'espace juste avant le @ (sauf debut de texte)
        var charBefore = atIdx > 0 ? textBeforeCursor[atIdx - 1] : ' ';
        if (charBefore === ' ' || charBefore === '\t' || atIdx === 0) {
            var searchText = textBeforeCursor.substring(atIdx + 1);
            // Ne pas chercher si le mot contient un espace apres 2 mots (fin de mention)
            if (searchText.length >= 1 && searchText.split(' ').length <= 3) {
                state.searchStart = atIdx;
                rechercherMention(idpub, searchText);
                return;
            }
        }
    }
    
    // Fermer la dropdown si pas de @ valide
    hideMentionDropdown(idpub);
}

function onCommentKeydown(event, idpub) {
    var state = getMentionState(idpub);
    var dropdown = document.getElementById('mention-suggestions-' + idpub);
    if (dropdown.style.display === 'none' || state.suggestions.length === 0) return;

    if (event.key === 'ArrowDown') {
        event.preventDefault();
        state.selectedIndex = Math.min(state.selectedIndex + 1, state.suggestions.length - 1);
        renderMentionDropdown(idpub);
    } else if (event.key === 'ArrowUp') {
        event.preventDefault();
        state.selectedIndex = Math.max(state.selectedIndex - 1, 0);
        renderMentionDropdown(idpub);
    } else if (event.key === 'Enter' || event.key === 'Tab') {
        if (state.suggestions.length > 0) {
            event.preventDefault();
            selectMention(idpub, state.suggestions[state.selectedIndex]);
        }
    } else if (event.key === 'Escape') {
        hideMentionDropdown(idpub);
    }
}

var mentionTimer = null;
function rechercherMention(idpub, query) {
    clearTimeout(mentionTimer);
    mentionTimer = setTimeout(function() {
        fetch(CTX + '/pages/alumni/ajax/rechercher-utilisateurs.jsp?q=' + encodeURIComponent(query))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data.success) return;
            var state = getMentionState(idpub);
            state.suggestions = data.utilisateurs;
            state.selectedIndex = 0;
            if (state.suggestions.length > 0) {
                renderMentionDropdown(idpub);
            } else {
                hideMentionDropdown(idpub);
            }
        });
    }, 200); // Debounce 200ms
}

function renderMentionDropdown(idpub) {
    var state = getMentionState(idpub);
    var dropdown = document.getElementById('mention-suggestions-' + idpub);
    var html = '';
    state.suggestions.forEach(function(u, i) {
        var cls = (i === state.selectedIndex) ? 'mention-item active' : 'mention-item';
        html += '<div class="' + cls + '" onmousedown="selectMentionByIndex(\'' + idpub + '\',' + i + ')">'
            + escHtml(u.nomComplet) + '</div>';
    });
    dropdown.innerHTML = html;
    dropdown.style.display = 'block';
}

function hideMentionDropdown(idpub) {
    var dd = document.getElementById('mention-suggestions-' + idpub);
    if (dd) dd.style.display = 'none';
    var state = getMentionState(idpub);
    state.suggestions = [];
    state.searchStart = -1;
}

function selectMentionByIndex(idpub, idx) {
    var state = getMentionState(idpub);
    if (idx >= 0 && idx < state.suggestions.length) {
        selectMention(idpub, state.suggestions[idx]);
    }
}

function selectMention(idpub, user) {
    var input = document.getElementById('comm-text-' + idpub);
    var state = getMentionState(idpub);
    var val = input.value;
    var atIdx = state.searchStart;

    if (atIdx < 0) return;

    // Remplacer @query par @NomComplet
    var before = val.substring(0, atIdx);
    var cursorPos = input.selectionStart;
    var after = val.substring(cursorPos);
    var mention = '@' + user.nomComplet + ' ';
    input.value = before + mention + after;
    input.focus();
    var newPos = before.length + mention.length;
    input.setSelectionRange(newPos, newPos);

    // Ajouter l'ID a la liste des mentions
    if (state.mentionIds.indexOf(user.id) === -1) {
        state.mentionIds.push(user.id);
    }
    // Mettre a jour le champ hidden
    document.getElementById('comm-mentions-' + idpub).value = state.mentionIds.join(',');

    hideMentionDropdown(idpub);
}

// ========== REACTION BAR (clic) ==========
function closeAllReactionBars() {
    document.querySelectorAll('.fa-reaction-bar--open').forEach(function(bar) {
        bar.classList.remove('fa-reaction-bar--open');
    });
}
function toggleReactionBar(idpub, event) {
    event.stopPropagation();
    var bar = document.getElementById('reaction-bar-' + idpub);
    var isOpen = bar.classList.contains('fa-reaction-bar--open');
    closeAllReactionBars();
    if (!isOpen) {
        bar.classList.add('fa-reaction-bar--open');
    }
}
function selectReaction(idpub, idreactiontype, event) {
    event.stopPropagation();
    closeAllReactionBars();
    toggleReaction(idpub, idreactiontype);
}
// Fermer les bars si clic sur espace vide
document.addEventListener('click', function() {
    closeAllReactionBars();
});

// ========== REACTIONS PUBLICATION ==========
function toggleReaction(idpub, idreactiontype) {
    fetch(CTX + '/pages/alumni/ajax/reagir-publication.jsp?idpublication=' + encodeURIComponent(idpub) + '&idreactiontype=' + encodeURIComponent(idreactiontype))
    .then(function(resp) {
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        return resp.text();
    })
    .then(function(body) {
        try { var data = JSON.parse(body); } catch(e) { alert('Erreur serveur (reaction): ' + body.substring(0, 200)); return; }
        if (data.success) {
            location.reload();
        } else {
            alert('Erreur reaction: ' + (data.error || 'Inconnue'));
        }
    })
    .catch(function(e) { alert('Erreur reseau (reaction): ' + e); });
}

// ========== COMMENTAIRES ==========
function toggleCommentaires(idpub) {
    var div = document.getElementById('commentaires-' + idpub);
    if (div.style.display === 'none') {
        div.style.display = 'block';
        chargerCommentaires(idpub);
    } else {
        div.style.display = 'none';
    }
}

// Agrandir / aplatir les réponses d'un commentaire
function toggleReplies(commId) {
    var wrap = document.getElementById('replies-' + commId);
    var btn  = document.getElementById('replies-btn-' + commId);
    if (!wrap || !btn) return;
    var isOpen = wrap.classList.contains('fa-replies-wrap--open');
    if (isOpen) {
        wrap.classList.remove('fa-replies-wrap--open');
        btn.classList.remove('fa-replies-toggle--expanded');
        var n = btn.getAttribute('data-count');
        btn.innerHTML = '<i class="bi bi-chevron-down"></i> Voir ' + n + ' réponse' + (n > 1 ? 's' : '');
    } else {
        wrap.classList.add('fa-replies-wrap--open');
        btn.classList.add('fa-replies-toggle--expanded');
        btn.innerHTML = '<i class="bi bi-chevron-up"></i> Masquer les réponses';
    }
}

// Agrandir / aplatir les réponses d'un commentaire
function toggleReplies(commId) {
    var wrap = document.getElementById('replies-' + commId);
    var btn  = document.getElementById('replies-btn-' + commId);
    if (!wrap || !btn) return;
    var isOpen = wrap.classList.contains('fa-replies-wrap--open');
    if (isOpen) {
        wrap.classList.remove('fa-replies-wrap--open');
        btn.classList.remove('fa-replies-toggle--expanded');
        var n = btn.getAttribute('data-count');
        btn.innerHTML = '<i class="bi bi-chevron-down"></i> Voir ' + n + ' r\u00e9ponse' + (n > 1 ? 's' : '');
    } else {
        wrap.classList.add('fa-replies-wrap--open');
        btn.classList.add('fa-replies-toggle--expanded');
        btn.innerHTML = '<i class="bi bi-chevron-up"></i> Masquer les r\u00e9ponses';
    }
}

function chargerCommentaires(idpub) {
    var listeDiv = document.getElementById('liste-comm-' + idpub);
    listeDiv.innerHTML = '<em>Chargement...</em>';

    fetch(CTX + '/pages/alumni/ajax/charger-commentaires.jsp?idpublication=' + encodeURIComponent(idpub))
    .then(function(resp) {
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        return resp.text();
    })
    .then(function(body) {
        try { var data = JSON.parse(body); } catch(e) { listeDiv.innerHTML = '<span style="color:red;">Erreur parse JSON: ' + body.substring(0, 200) + '</span>'; return; }
        if (!data.success) {
            listeDiv.innerHTML = '<span style="color:red;">' + (data.error || 'Erreur') + '</span>';
            return;
        }
        var comms = data.commentaires;
        var rTypes = data.reactionTypes;

        if (comms.length === 0) {
            listeDiv.innerHTML = '<p style="color:#999;"><em>Aucun commentaire</em></p>';
            return;
        }

        // Construire un arbre: regrouper les enfants sous leur parent
        var commMap = {};
        var topLevel = [];
        for (var i = 0; i < comms.length; i++) {
            comms[i].children = [];
            commMap[comms[i].id] = comms[i];
        }
        for (var i = 0; i < comms.length; i++) {
            var c = comms[i];
            if (c.idparent && c.idparent !== '' && commMap[c.idparent]) {
                commMap[c.idparent].children.push(c);
            } else {
                topLevel.push(c);
            }
        }

        // Rendu recursif
        function renderComment(c, depth) {
            var initials = getInitials(c.auteur);
            var replyClass = depth > 0 ? ' fa-comment-item--reply' : '';
            var html = '';
            html += '<div id="comm-' + c.id + '" class="fa-comment-item' + replyClass + '">';
            html += '<div class="fa-comment-inner">';
            if (c.banned) {
                html += '<div class="fa-avatar fa-avatar--xs" style="background:#ccc;color:#888;cursor:default;"><i class="bi bi-person-slash" style="font-size:0.8em;"></i></div>';
                html += '<div class="fa-comment-content">';
                html += '<div class="fa-comment-bubble">';
                html += '<span class="fa-comment-author" style="color:#888;cursor:default;"><i class="bi bi-person-slash"></i> ' + escHtml(c.auteur) + '</span>';
            } else {
            html += '<div class="fa-avatar fa-avatar--xs">' + escHtml(initials) + '</div>';
            html += '<div class="fa-comment-content">';
            html += '<div class="fa-comment-bubble">';
            html += '<span class="fa-comment-author">' + escHtml(c.auteur) + '</span>';
            }
            html += '<span class="fa-comment-text">' + formatMentions(c.description) + '</span>';
            html += '</div>';

            // Barre d'actions
            html += '<div class="fa-comment-actions">';
            for (var j = 0; j < rTypes.length; j++) {
                var rt = rTypes[j];
                var cnt = c.reactions[rt.id] || 0;
                var activeClass = (c.myReaction === rt.id) ? ' fa-comment-react-btn--active' : '';
                html += '<button class="fa-comment-react-btn' + activeClass + '" ';
                html += 'onclick="toggleReactionComm(\'' + c.id + '\',\'' + rt.id + '\',\'' + idpub + '\')">';
                html += rt.libelle;
                if (cnt > 0) html += ' <span style="font-weight:400;font-size:11px;">(' + cnt + ')</span>';
                html += '</button>';
                html += '<span class="fa-dot">&middot;</span>';
            }
            html += '<a href="javascript:void(0)" class="fa-comment-reply-link" ';
            html += 'onclick="montrerReponse(\'' + c.id + '\',\'' + idpub + '\',\'' + escAttr(c.auteur) + '\',\'' + c.idutilisateur + '\')">';
            html += 'R&eacute;pondre</a>';
            html += '</div>';

            // Formulaire de réponse
            html += '<div id="reponse-form-' + c.id + '" style="display:none;">';
            html += '<div class="fa-comment-input-wrap">';
            html += '<div class="fa-comment-input-box">';
            html += '<input type="text" id="reponse-text-' + c.id + '" class="fa-comment-input" placeholder="R\u00e9pondre\u2026 (@ pour mentionner)"';
            html += ' oninput="onReplyInput(this,\'' + c.id + '\',\'' + idpub + '\')"';
            html += ' onkeydown="onReplyKeydown(event,\'' + c.id + '\',\'' + idpub + '\')">';
            html += '<input type="hidden" id="reponse-mentions-' + c.id + '" value="">';
            html += '<div id="mention-reply-' + c.id + '" class="mention-dropdown" style="display:none;"></div>';
            html += '<button class="fa-comment-send-btn" onclick="ajouterReponse(\'' + idpub + '\',\'' + c.id + '\')"><i class="bi bi-send-fill"></i></button>';
            html += '</div>';
            html += '</div>';
            html += '</div>';

            // Zone réponses collapsible
            if (c.children.length > 0) {
                var n = c.children.length;
                html += '<div class="fa-replies-area">';
                html += '<button id="replies-btn-' + c.id + '" class="fa-replies-toggle" data-count="' + n + '" onclick="toggleReplies(\'' + c.id + '\')">'
                html += '<i class="bi bi-chevron-down"></i> Voir ' + n + ' réponse' + (n > 1 ? 's' : '');
                html += '</button>';
                html += '<div id="replies-' + c.id + '" class="fa-replies-wrap">';
                for (var k = 0; k < c.children.length; k++) {
                    html += renderComment(c.children[k], depth + 1);
                }
                html += '</div>'; // fa-replies-wrap
                html += '</div>'; // fa-replies-area
            }

            html += '</div>'; // fa-comment-content
            html += '</div>'; // fa-comment-inner
            html += '</div>'; // fa-comment-item

            return html;
        }

        var html = '';
        for (var i = 0; i < topLevel.length; i++) {
            html += renderComment(topLevel[i], 0);
        }

        listeDiv.innerHTML = html;
    })
    .catch(function(e) { listeDiv.innerHTML = '<span style="color:red;">Erreur: ' + e + '</span>'; });
}

// Calculer les initiales depuis un nom complet
function getInitials(name) {
    if (!name) return '?';
    var parts = name.trim().split(/\s+/);
    var ini = parts[0].charAt(0).toUpperCase();
    if (parts.length > 1) ini += parts[parts.length - 1].charAt(0).toUpperCase();
    return ini;
}

// Formatter les @mentions dans le texte du commentaire
function formatMentions(text) {
    if (!text) return '';
    var safe = escHtml(text);
    // Remplacer @NomPrenom par un badge colore
    return safe.replace(/@([A-Za-zÀ-ÿ]+(?: [A-Za-zÀ-ÿ]+){0,2})/g, 
        '<span class="mention-badge">@$1</span>');
}

function ajouterCommentaire(idpub) {
    var input = document.getElementById('comm-text-' + idpub);
    var val = input.value.trim();
    if (!val) return;

    var state = getMentionState(idpub);
    var mentions = state.mentionIds.join(',');

    fetch(CTX + '/pages/alumni/ajax/commenter.jsp', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'idpublication=' + encodeURIComponent(idpub) 
            + '&description=' + encodeURIComponent(val)
            + '&mentions=' + encodeURIComponent(mentions)
    })
    .then(function(resp) {
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        return resp.text();
    })
    .then(function(body) {
        try { var data = JSON.parse(body); } catch(e) { alert('Erreur serveur (commentaire): ' + body.substring(0, 200)); return; }
        if (data.success) {
            input.value = '';
            state.mentionIds = [];
            document.getElementById('comm-mentions-' + idpub).value = '';
            chargerCommentaires(idpub);
            var nbSpan = document.getElementById('nb-comm-' + idpub);
            nbSpan.textContent = parseInt(nbSpan.textContent) + 1;
        } else {
            alert('Erreur commentaire: ' + (data.error || 'Inconnue'));
        }
    })
    .catch(function(e) { alert('Erreur reseau (commentaire): ' + e); });
}

function montrerReponse(idcomm, idpub, auteurNom, auteurId) {
    var div = document.getElementById('reponse-form-' + idcomm);
    var wasHidden = (div.style.display === 'none');
    div.style.display = wasHidden ? 'block' : 'none';

    if (wasHidden && auteurNom && auteurId && String(auteurId) !== String(CURRENT_USER_ID)) {
        var input = document.getElementById('reponse-text-' + idcomm);
        if (input && !input.value) {
            input.value = '@' + auteurNom + ' ';
            var state = getReplyMentionState(idcomm);
            var uid = parseInt(auteurId);
            if (state.mentionIds.indexOf(uid) === -1) {
                state.mentionIds.push(uid);
            }
            document.getElementById('reponse-mentions-' + idcomm).value = state.mentionIds.join(',');
            input.focus();
            input.setSelectionRange(input.value.length, input.value.length);
        }
    }
}

// Mention dans les reponses - reutilise le meme mecanisme
var replyMentionData = {};
function getReplyMentionState(idcomm) {
    if (!replyMentionData[idcomm]) {
        replyMentionData[idcomm] = { suggestions: [], selectedIndex: 0, mentionIds: [], searchStart: -1 };
    }
    return replyMentionData[idcomm];
}

function onReplyInput(input, idcomm, idpub) {
    var val = input.value;
    var cursorPos = input.selectionStart;
    var state = getReplyMentionState(idcomm);
    var textBeforeCursor = val.substring(0, cursorPos);
    var atIdx = textBeforeCursor.lastIndexOf('@');

    if (atIdx >= 0) {
        var charBefore = atIdx > 0 ? textBeforeCursor[atIdx - 1] : ' ';
        if (charBefore === ' ' || charBefore === '\t' || atIdx === 0) {
            var searchText = textBeforeCursor.substring(atIdx + 1);
            if (searchText.length >= 1 && searchText.split(' ').length <= 3) {
                state.searchStart = atIdx;
                rechercherMentionReply(idcomm, searchText);
                return;
            }
        }
    }
    document.getElementById('mention-reply-' + idcomm).style.display = 'none';
    state.suggestions = [];
}

function onReplyKeydown(event, idcomm, idpub) {
    var state = getReplyMentionState(idcomm);
    var dropdown = document.getElementById('mention-reply-' + idcomm);
    if (dropdown.style.display === 'none' || state.suggestions.length === 0) return;

    if (event.key === 'ArrowDown') { event.preventDefault(); state.selectedIndex = Math.min(state.selectedIndex + 1, state.suggestions.length - 1); renderReplyMentionDropdown(idcomm); }
    else if (event.key === 'ArrowUp') { event.preventDefault(); state.selectedIndex = Math.max(state.selectedIndex - 1, 0); renderReplyMentionDropdown(idcomm); }
    else if (event.key === 'Enter' || event.key === 'Tab') { if (state.suggestions.length > 0) { event.preventDefault(); selectReplyMention(idcomm, state.suggestions[state.selectedIndex]); } }
    else if (event.key === 'Escape') { dropdown.style.display = 'none'; state.suggestions = []; }
}

function rechercherMentionReply(idcomm, query) {
    fetch(CTX + '/pages/alumni/ajax/rechercher-utilisateurs.jsp?q=' + encodeURIComponent(query))
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (!data.success) return;
        var state = getReplyMentionState(idcomm);
        state.suggestions = data.utilisateurs;
        state.selectedIndex = 0;
        if (state.suggestions.length > 0) renderReplyMentionDropdown(idcomm);
        else document.getElementById('mention-reply-' + idcomm).style.display = 'none';
    });
}

function renderReplyMentionDropdown(idcomm) {
    var state = getReplyMentionState(idcomm);
    var dropdown = document.getElementById('mention-reply-' + idcomm);
    var html = '';
    state.suggestions.forEach(function(u, i) {
        var cls = (i === state.selectedIndex) ? 'mention-item active' : 'mention-item';
        html += '<div class="' + cls + '" onmousedown="selectReplyMentionByIndex(\'' + idcomm + '\',' + i + ')">'
            + escHtml(u.nomComplet) + '</div>';
    });
    dropdown.innerHTML = html;
    dropdown.style.display = 'block';
}

function selectReplyMentionByIndex(idcomm, idx) {
    var state = getReplyMentionState(idcomm);
    if (idx >= 0 && idx < state.suggestions.length) {
        selectReplyMention(idcomm, state.suggestions[idx]);
    }
}

function selectReplyMention(idcomm, user) {
    var input = document.getElementById('reponse-text-' + idcomm);
    var state = getReplyMentionState(idcomm);
    var val = input.value;
    var atIdx = state.searchStart;
    if (atIdx < 0) return;

    var before = val.substring(0, atIdx);
    var cursorPos = input.selectionStart;
    var after = val.substring(cursorPos);
    var mention = '@' + user.nomComplet + ' ';
    input.value = before + mention + after;
    input.focus();
    var newPos = before.length + mention.length;
    input.setSelectionRange(newPos, newPos);

    if (state.mentionIds.indexOf(user.id) === -1) state.mentionIds.push(user.id);
    document.getElementById('reponse-mentions-' + idcomm).value = state.mentionIds.join(',');

    document.getElementById('mention-reply-' + idcomm).style.display = 'none';
    state.suggestions = [];
}

function ajouterReponse(idpub, idparent) {
    var input = document.getElementById('reponse-text-' + idparent);
    var val = input.value.trim();
    if (!val) return;

    var state = getReplyMentionState(idparent);
    var mentions = state.mentionIds.join(',');

    fetch(CTX + '/pages/alumni/ajax/commenter.jsp', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'idpublication=' + encodeURIComponent(idpub)
            + '&description=' + encodeURIComponent(val)
            + '&idparent=' + encodeURIComponent(idparent)
            + '&mentions=' + encodeURIComponent(mentions)
    })
    .then(function(resp) {
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        return resp.text();
    })
    .then(function(body) {
        try { var data = JSON.parse(body); } catch(e) { alert('Erreur serveur (reponse): ' + body.substring(0, 200)); return; }
        if (data.success) {
            input.value = '';
            state.mentionIds = [];
            chargerCommentaires(idpub);
            var nbSpan = document.getElementById('nb-comm-' + idpub);
            nbSpan.textContent = parseInt(nbSpan.textContent) + 1;
        } else {
            alert('Erreur reponse: ' + (data.error || 'Inconnue'));
        }
    })
    .catch(function(e) { alert('Erreur reseau (reponse): ' + e); });
}

// ========== REACTIONS COMMENTAIRE ==========
function toggleReactionComm(idcomm, idreactiontype, idpub) {
    fetch(CTX + '/pages/alumni/ajax/reagir-commentaire.jsp?idcommentaire=' + encodeURIComponent(idcomm) + '&idreactiontype=' + encodeURIComponent(idreactiontype))
    .then(function(resp) {
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        return resp.text();
    })
    .then(function(body) {
        try { var data = JSON.parse(body); } catch(e) { alert('Erreur serveur (reaction comm): ' + body.substring(0, 200)); return; }
        if (data.success) {
            chargerCommentaires(idpub);
        } else {
            alert('Erreur reaction commentaire: ' + (data.error || 'Inconnue'));
        }
    })
    .catch(function(e) { alert('Erreur reseau (reaction comm): ' + e); });
}

function escHtml(str) {
    if (!str) return '';
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

function escAttr(str) {
    if (!str) return '';
    return str.replace(/'/g, "\\'").replace(/"/g, '&quot;');
}

// ========== IDENTIFICATION DANS LE FORMULAIRE DE PUBLICATION ==========
var pubTagUsers = []; // [{id, nom}]

function togglePubTag() {
    var zone = document.getElementById('pub-tag-zone');
    zone.style.display = (zone.style.display === 'none') ? 'block' : 'none';
}

function rechercherPourPubTag() {
    var input = document.getElementById('pub-tag-search');
    var query = input.value.trim();
    var sugDiv = document.getElementById('pub-tag-suggestions');
    if (query.length < 1) { sugDiv.innerHTML = ''; return; }

    fetch(CTX + '/pages/alumni/ajax/rechercher-utilisateurs.jsp?q=' + encodeURIComponent(query))
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (!data.success) return;
        var html = '';
        var alreadyIds = pubTagUsers.map(function(u) { return u.id; });
        data.utilisateurs.forEach(function(u) {
            if (alreadyIds.indexOf(u.id) === -1) {
                html += '<div class="mention-item" style="padding:6px 10px;cursor:pointer;border-bottom:1px solid #f0f0f0;" '
                    + 'onclick="selectPubTag(' + u.id + ',\'' + escAttr(u.nomComplet) + '\')">'
                    + escHtml(u.nomComplet) + '</div>';
            }
        });
        sugDiv.innerHTML = html || '<div style="padding:6px 10px;color:#999;">Aucun resultat</div>';
    });
}

function selectPubTag(userId, nomComplet) {
    for (var i = 0; i < pubTagUsers.length; i++) {
        if (pubTagUsers[i].id === userId) return;
    }
    pubTagUsers.push({ id: userId, nom: nomComplet });
    renderPubTags();
    document.getElementById('pub-tag-search').value = '';
    document.getElementById('pub-tag-suggestions').innerHTML = '';
}

function removePubTag(userId) {
    pubTagUsers = pubTagUsers.filter(function(u) { return u.id !== userId; });
    renderPubTags();
}

function renderPubTags() {
    var container = document.getElementById('pub-tag-selected');
    var html = '';
    pubTagUsers.forEach(function(u) {
        html += '<span class="tag-chip">' + escHtml(u.nom) 
            + ' <span class="remove-tag" onclick="removePubTag(' + u.id + ')">&times;</span></span>';
    });
    container.innerHTML = html;
    // Mettre a jour le champ hidden
    document.getElementById('pub-identifications').value = pubTagUsers.map(function(u) { return u.id; }).join(',');
}

// ========== SCROLL TO ANCHOR (pour les notifications) ==========
$(document).ready(function() {
    // Lire les parametres d'URL
    var urlParams = new URLSearchParams(window.location.search);
    var scrollTo = urlParams.get('scrollTo');
    if (!scrollTo) return;

    if (scrollTo.startsWith('comm-')) {
        // Notification de type commentaire: ouvrir la bonne publication
        var opub = urlParams.get('opub');
        if (opub) {
            var commDiv = document.getElementById('commentaires-' + opub);
            if (commDiv) {
                commDiv.style.display = 'block';
                chargerCommentaires(opub);
            }
        } else {
            // Fallback: ouvrir toutes les publications
            var pubDivs = document.querySelectorAll('[id^="pub-"]');
            pubDivs.forEach(function(div) {
                var pubId = div.id.replace('pub-', '');
                var cd = document.getElementById('commentaires-' + pubId);
                if (cd && cd.style.display === 'none') {
                    cd.style.display = 'block';
                    chargerCommentaires(pubId);
                }
            });
        }
        // Attendre le chargement AJAX puis scroller
        var attempts = 0;
        var scrollInterval = setInterval(function() {
            attempts++;
            var el = document.getElementById(scrollTo);
            if (el) {
                clearInterval(scrollInterval);
                el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                el.style.background = '#fff9c4';
                el.style.borderLeft = '4px solid #f9a825';
                el.style.transition = 'background 2s';
                setTimeout(function() { el.style.background = ''; el.style.borderLeft = ''; }, 4000);
            }
            if (attempts > 20) clearInterval(scrollInterval); // max 10 secondes
        }, 500);
    } else if (scrollTo.startsWith('pub-')) {
        // Notification de type publication
        setTimeout(function() {
            var el = document.getElementById(scrollTo);
            if (el) {
                el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                el.style.background = '#fff9c4';
                el.style.borderLeft = '4px solid #f9a825';
                el.style.transition = 'background 2s';
                setTimeout(function() { el.style.background = ''; el.style.borderLeft = ''; }, 4000);
            }
        }, 300);
    }
});

// ========== COMPOSER UI ==========
function openComposer() {
    document.getElementById('composer-trigger').style.display = 'none';
    document.getElementById('composer-quick-actions').style.display = 'none';
    document.getElementById('composer-full').style.display = 'block';
    var ta = document.querySelector('#composer-full textarea[name="description"]');
    if (ta) setTimeout(function(){ ta.focus(); }, 50);
}
function closeComposer() {
    document.getElementById('composer-trigger').style.display = 'flex';
    document.getElementById('composer-quick-actions').style.display = 'flex';
    document.getElementById('composer-full').style.display = 'none';
    removeComposerImg();
    var ta = document.querySelector('#composer-full textarea[name="description"]');
    if (ta) ta.value = '';
}
var _MAX_FILE_SIZE = 50 * 1024 * 1024; // 50 Mo
function previewComposerImg(input) {
    if (!input.files || !input.files[0]) return;
    var f = input.files[0];
    if (f.size > _MAX_FILE_SIZE) {
        var sizeMB = (f.size / (1024 * 1024)).toFixed(1);
        Swal.fire({icon:'error', title:'Fichier trop volumineux',
            text:f.name + ' (' + sizeMB + ' Mo) d\u00e9passe la limite de 50 Mo.',
            confirmButtonColor:'#1877f2'});
        input.value = '';
        return;
    }
    var reader = new FileReader();
    reader.onload = function(e) {
        document.getElementById('composer-img-previewImg').src = e.target.result;
        document.getElementById('composer-img-preview').style.display = 'block';
    };
    reader.readAsDataURL(input.files[0]);
}
function validatePubFormSize() {
    var inp = document.getElementById('composer-img-input');
    if (inp && inp.files) {
        for (var i = 0; i < inp.files.length; i++) {
            if (inp.files[i].size > _MAX_FILE_SIZE) {
                Swal.fire({icon:'error', title:'Fichier trop volumineux',
                    text:inp.files[i].name + ' d\u00e9passe la limite de 50 Mo.',
                    confirmButtonColor:'#1877f2'});
                return false;
            }
        }
    }
    return true;
}
function removeComposerImg() {
    var inp = document.getElementById('composer-img-input');
    if (inp) inp.value = '';
    document.getElementById('composer-img-preview').style.display = 'none';
    document.getElementById('composer-img-previewImg').src = '';
}
// ========== MEDIA ZOOM ==========
function openMediaZoom(src) {
    var overlay = document.createElement('div');
    overlay.className = 'fa-media-overlay';
    var img = document.createElement('img');
    img.src = src;
    overlay.appendChild(img);
    overlay.addEventListener('click', function(){ document.body.removeChild(overlay); });
    document.addEventListener('keydown', function esc(e){ if(e.key==='Escape'){ document.body.removeChild(overlay); document.removeEventListener('keydown',esc); } });
    document.body.appendChild(overlay);
}

// ===== publication menu =====
function togglePubMenu(btn, e) {
    e.stopPropagation();
    var dd = btn.nextElementSibling;
    var open = dd.style.display === 'block';
    document.querySelectorAll('.pub-menu-dropdown').forEach(function(el){ el.style.display='none'; });
    if (!open) dd.style.display='block';
}
document.addEventListener('click', function(){
    document.querySelectorAll('.pub-menu-dropdown').forEach(function(el){ el.style.display='none'; });
});

function savePublication(idpub) {
    // placeholder: send request to save
    fetch(CTX + '/pages/alumni/ajax/save-publication.jsp?idpublication=' + encodeURIComponent(idpub))
    .then(r=>r.json()).then(d=>{ if(d.success) Swal.fire({toast:true,position:'top-end',icon:'success',title:'Sauvegardée',timer:1500,showConfirmButton:false}); else alert('Erreur sauvegarde'); });
}

function reportPublication(idpub) {
    window.location.href = CTX + '/pages/module.jsp?but=alumni/signaler-publication.jsp&idpublication=' + encodeURIComponent(idpub);
}
</script>
