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
                      action="<%= ctx %>/pages/alumni/ajax/creer-publication.jsp">
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
            <div class="fa-post-header">
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
<style>
    /* ---- Variables locales ---- */
    :root {
        --fa-bg: #f0f2f5;
        --fa-card-bg: #ffffff;
        --fa-border: #e4e6eb;
        --fa-text: #050505;
        --fa-text-secondary: #65676b;
    }
    /* ---- Layout 3 colonnes ---- */
    .fa-layout {
        display: grid;
        grid-template-columns: 220px minmax(0,1fr) 220px;
        gap: 16px;
        padding: 0;
        align-items: start;
    }
    @media(max-width:1000px) {
        .fa-layout { grid-template-columns: 200px 1fr; }
        .fa-sidebar-right { display: none; }
    }
    @media(max-width:768px) {
        .fa-layout { grid-template-columns: 1fr; }
        .fa-sidebar-left { display: none; }
    }
    .fa-sidebar-left, .fa-sidebar-right { position: sticky; top: 80px; }
    .fa-feed-center { display: flex; flex-direction: column; gap: 12px; min-width: 0; }
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
    /* ---- Carte profil gauche ---- */
    .fa-profile-card { background: var(--fa-card-bg); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.12); overflow: hidden; }
    .fa-profile-cover { height: 72px; background: linear-gradient(135deg, var(--itu-dark,#362F4F) 0%, var(--itu-violet,#5B23FF) 100%); }
    .fa-profile-body { padding: 0 16px 16px; }
    .fa-profile-avatar-wrap { margin-top: -36px; margin-bottom: 8px; }
    .fa-profile-name { font-weight: 700; font-size: 16px; color: var(--fa-text); margin-bottom: 12px; }
    .fa-divider { border: none; border-top: 1px solid var(--fa-border); margin: 10px 0; }
    .fa-profile-nav { display: flex; flex-direction: column; gap: 2px; }
    .fa-nav-link {
        display: flex; align-items: center; gap: 10px;
        padding: 10px 12px; border-radius: 8px;
        color: var(--fa-text); text-decoration: none; font-size: 15px; transition: background .15s;
    }
    .fa-nav-link:hover { background: #f0f2f5; color: var(--itu-blue,#008BFF); }
    .fa-nav-link--active { background: #e7f3ff; color: var(--itu-blue,#008BFF); font-weight: 600; }
    /* ---- Composer ---- */
    .fa-composer-card { background: var(--fa-card-bg); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.12); padding: 12px 16px; }
    .fa-composer-trigger { display: flex; align-items: center; gap: 10px; cursor: pointer; }
    .fa-composer-placeholder {
        flex: 1; background: #f0f2f5; border-radius: 20px;
        padding: 10px 16px; color: var(--fa-text-secondary); font-size: 15px; transition: background .15s;
    }
    .fa-composer-placeholder:hover { background: #e4e6eb; }
    .fa-composer-quick-actions { display: flex; border-top: 1px solid var(--fa-border); margin-top: 10px; padding-top: 8px; }
    .fa-quick-action-btn {
        flex: 1; display: flex; align-items: center; justify-content: center; gap: 6px;
        background: none; border: none; padding: 8px; border-radius: 8px;
        font-size: 14px; font-weight: 600; color: var(--fa-text-secondary); cursor: pointer; transition: background .15s;
    }
    .fa-quick-action-btn:hover { background: #f0f2f5; }
    .fa-composer-full { margin-top: 10px; border-top: 1px solid var(--fa-border); padding-top: 12px; }
    .fa-composer-header { display: flex; align-items: center; gap: 10px; margin-bottom: 12px; }
    .fa-type-select { margin-left: 6px; padding: 3px 8px; border: 1px solid var(--fa-border); border-radius: 6px; font-size: 13px; background: #f0f2f5; }
    .fa-composer-textarea {
        width: 100%; border: none; outline: none; resize: none;
        font-size: 16px; color: var(--fa-text); background: transparent;
        padding: 4px 0; font-family: inherit; min-height: 80px;
    }
    .fa-composer-textarea::placeholder { color: var(--fa-text-secondary); }
    .fa-img-preview-wrap { position: relative; margin: 8px 0; display: inline-block; }
    .fa-img-preview { max-width: 100%; max-height: 300px; border-radius: 8px; display: block; }
    .fa-img-remove-btn {
        position: absolute; top: 6px; right: 6px; background: rgba(0,0,0,.6);
        border: none; color: #fff; border-radius: 50%; width: 28px; height: 28px;
        cursor: pointer; display: flex; align-items: center; justify-content: center;
    }
    .fa-composer-tags-area { margin-top: 8px; }
    .fa-tag-toggle { font-size: 13px; color: var(--itu-blue,#008BFF); text-decoration: none; }
    .fa-tag-toggle:hover { text-decoration: underline; }
    .fa-composer-footer {
        display: flex; align-items: center; justify-content: space-between;
        margin-top: 12px; padding-top: 10px; border-top: 1px solid var(--fa-border); flex-wrap: wrap; gap: 8px;
    }
    .fa-attach-btn {
        display: flex; align-items: center; gap: 6px; padding: 8px 12px; border-radius: 8px;
        font-size: 14px; font-weight: 600; color: var(--fa-text-secondary); cursor: pointer; transition: background .15s;
    }
    .fa-attach-btn:hover { background: #f0f2f5; }
    .fa-composer-submit-group { display: flex; gap: 8px; }
    .fa-btn-cancel { padding: 8px 16px; background: #e4e6eb; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: background .15s; }
    .fa-btn-cancel:hover { background: #d8dadf; }
    .fa-btn-publish { padding: 8px 20px; background: var(--itu-blue,#008BFF); color: #fff; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: background .15s; }
    .fa-btn-publish:hover { background: #0069cc; }
    .fa-btn-primary { background: var(--itu-blue,#008BFF); color: #fff; border: none; border-radius: 8px; padding: 8px 16px; font-size: 14px; font-weight: 600; cursor: pointer; }
    .fa-btn-sm { padding: 6px 14px !important; font-size: 13px !important; }
    /* ---- Post card ---- */
    .fa-post-card { background: var(--fa-card-bg); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.12); overflow: hidden; }
    .fa-post-header { display: flex; align-items: flex-start; gap: 10px; padding: 14px 16px 8px; }
    .fa-post-meta { flex: 1; min-width: 0; }
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
    /* ---- Hover bar réactions ---- */
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
    /* ---- Zone commentaires (Facebook style) ---- */
    .fa-comments-zone {
        padding: 4px 12px 12px;
        border-top: 1px solid var(--fa-border);
        display: flex; flex-direction: column; gap: 2px;
    }
    /* Chaque commentaire */
    .fa-comment-item {
        display: flex; flex-direction: column;
        padding: 4px 0;
    }
    /* Replies nestées dans le parent */
    .fa-comment-item--reply { padding-top: 2px; }
    /* Zone toggle + liste de réponses */
    .fa-replies-area { margin-top: 2px; }
    .fa-replies-toggle {
        display: inline-flex; align-items: center; gap: 5px;
        background: none; border: none;
        color: var(--itu-blue,#008BFF);
        font-size: 13px; font-weight: 600;
        cursor: pointer; padding: 4px 8px;
        border-radius: 6px; margin-left: -4px;
        transition: background .15s;
        line-height: 1;
    }
    .fa-replies-toggle:hover { background: rgba(0,139,255,.1); }
    .fa-replies-toggle i { font-size: 12px; transition: transform .25s; }
    .fa-replies-toggle--expanded i { transform: rotate(180deg); }
    /* Container des réponses : animation max-height */
    .fa-replies-wrap {
        overflow: hidden;
        max-height: 0;
        padding-left: 12px;
        border-left: 2px solid #e4e6ea;
        margin-left: 14px;
        margin-top: 4px;
        transition: max-height .35s ease-out;
    }
    .fa-replies-wrap--open {
        max-height: 4000px;
        transition: max-height .45s ease-in;
    }
    .fa-comment-inner { display: flex; gap: 8px; align-items: flex-start; }
    .fa-comment-content { flex: 1; min-width: 0; }
    /* Bulle */
    .fa-comment-bubble {
        background: #f0f2f5;
        border-radius: 18px;
        padding: 8px 12px;
        display: inline-block;
        max-width: 100%;
        cursor: default;
        transition: background .15s;
    }
    .fa-comment-bubble:hover { background: #e4e6ea; }
    .fa-comment-author {
        font-weight: 600; font-size: 13px;
        color: #050505; display: block;
        margin-bottom: 2px; line-height: 1.2;
    }
    .fa-comment-author:hover { text-decoration: underline; cursor: pointer; }
    .fa-comment-text { font-size: 14px; color: #050505; word-break: break-word; line-height: 1.4; }
    /* Barre d'actions sous la bulle */
    .fa-comment-actions {
        display: flex; align-items: center; gap: 2px;
        padding: 3px 4px 0; font-size: 12px; font-weight: 600;
        color: #65676b; line-height: 1;
    }
    .fa-comment-actions .fa-dot { color: #65676b; font-weight: 400; opacity: .7; padding: 0 2px; }
    .fa-comment-react-btn {
        background: none; border: none;
        font-size: 12px; font-weight: 600;
        color: #65676b; cursor: pointer;
        padding: 3px 5px; border-radius: 4px;
        transition: background .12s, color .12s;
        line-height: 1; white-space: nowrap;
    }
    .fa-comment-react-btn:hover { background: #f0f2f5; color: #050505; }
    .fa-comment-react-btn--active { color: var(--itu-blue,#008BFF); }
    .fa-comment-react-btn--active:hover { background: #e7f3ff; color: var(--itu-blue,#008BFF); }
    .fa-comment-reply-link {
        font-size: 12px; font-weight: 600;
        color: #65676b; text-decoration: none;
        padding: 3px 5px; border-radius: 4px;
        transition: background .12s, color .12s;
        line-height: 1;
    }
    .fa-comment-reply-link:hover { background: #f0f2f5; color: #050505; text-decoration: none; }
    /* Formulaire de saisie (nouveau commentaire & réponse) */
    .fa-comment-input-wrap { display: flex; align-items: center; gap: 8px; margin-top: 8px; }
    .fa-comment-input-box {
        flex: 1; display: flex; align-items: center;
        background: #f0f2f5; border-radius: 20px;
        padding: 0 6px 0 14px; position: relative;
        border: 1.5px solid transparent;
        transition: border-color .15s, background .15s;
    }
    .fa-comment-input-box:focus-within {
        background: #fff;
        border-color: var(--itu-blue,#008BFF);
        box-shadow: 0 0 0 3px rgba(0,139,255,.08);
    }
    .fa-comment-input {
        flex: 1; background: transparent; border: none; outline: none;
        padding: 9px 4px; font-size: 14px;
        color: #050505; font-family: inherit; min-width: 0;
    }
    .fa-comment-input::placeholder { color: #65676b; }
    .fa-comment-send-btn {
        background: none; border: none;
        color: var(--itu-blue,#008BFF);
        font-size: 16px; cursor: pointer;
        padding: 6px; border-radius: 50%;
        transition: background .15s;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .fa-comment-send-btn:hover { background: rgba(0,139,255,.12); }
    /* ---- Etats vides / erreurs ---- */
    .fa-empty-feed { text-align: center; padding: 48px 20px; color: var(--fa-text-secondary); font-size: 16px; }
    .fa-empty-feed i { font-size: 52px; display: block; margin-bottom: 16px; opacity: .4; }
    .fa-error-box { background: #fff3cd; border: 1px solid #ffc107; border-radius: 8px; padding: 12px 16px; color: #856404; display: flex; align-items: center; gap: 8px; font-size: 14px; }
    /* ---- Inputs / chips ---- */
    .fa-input { width: 100%; padding: 8px 12px; border: 1px solid var(--fa-border); border-radius: 8px; font-size: 14px; outline: none; font-family: inherit; box-sizing: border-box; }
    .fa-input:focus { border-color: var(--itu-blue,#008BFF); }
    .fa-suggestions-list { max-height: 160px; overflow-y: auto; border: 1px solid var(--fa-border); border-top: none; border-radius: 0 0 8px 8px; background: #fff; }
    .fa-chips-row { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
    /* ---- Overlay zoom media ---- */
    .fa-media-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.9); display: flex; align-items: center; justify-content: center; z-index: 9999; cursor: zoom-out; }
    .fa-media-overlay img { max-width: 92vw; max-height: 92vh; border-radius: 4px; object-fit: contain; }
    /* ---- Mention dropdown (conservé) ---- */
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
    /* ---- Highlight scroll (notifications) ---- */
    .fa-highlight { background: #fffde7 !important; border-left: 4px solid #f9a825 !important; transition: background 2s !important; }
</style>

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

    // ========== REACTION BAR COMMENTAIRE ==========
    function getReactionEmoji(lib) {
        var l = lib.toLowerCase();
        if (l.indexOf('adore') >= 0 || l.indexOf('love') >= 0) return '\u2764\uFE0F';
        if (l.indexOf('haha') >= 0 || l.indexOf('humour') >= 0) return '\uD83D\uDE02';
        if (l.indexOf('surprise') >= 0 || l.indexOf('wow') >= 0) return '\uD83D\uDE2E';
        if (l.indexOf('triste') >= 0 || l.indexOf('sad') >= 0) return '\uD83D\uDE22';
        if (l.indexOf('grrr') >= 0 || l.indexOf('ang') >= 0) return '\uD83D\uDE20';
        return '\uD83D\uDC4D';
    }
    function toggleCommReactionBar(commId, event) {
        event.stopPropagation();
        var bar = document.getElementById('creact-bar-' + commId);
        var isOpen = bar.classList.contains('fa-reaction-bar--open');
        closeAllReactionBars();
        if (!isOpen) {
            bar.classList.add('fa-reaction-bar--open');
        }
    }
    function selectCommReaction(commId, idreactiontype, idpub, event) {
        event.stopPropagation();
        closeAllReactionBars();
        toggleReactionComm(commId, idreactiontype, idpub);
    }

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
                    html += '<div class="fa-avatar fa-avatar--xs">' + escHtml(initials) + '</div>';
                    html += '<div class="fa-comment-content">';
                    html += '<div class="fa-comment-bubble">';
                    html += '<span class="fa-comment-author">' + escHtml(c.auteur) + '</span>';
                    html += '<span class="fa-comment-text">' + formatMentions(c.description) + '</span>';
                    html += '</div>';

                    // Calcul total reactions + lib de ma reaction
                    var totalCReact = 0;
                    var myCommReactLib = '';
                    for (var jr = 0; jr < rTypes.length; jr++) {
                        totalCReact += (c.reactions[rTypes[jr].id] || 0);
                        if (c.myReaction === rTypes[jr].id) myCommReactLib = rTypes[jr].libelle;
                    }
                    var hasCommReact = (c.myReaction && c.myReaction !== '');

                    // Barre d'actions
                    html += '<div class="fa-comment-actions">';

                    // Reaction wrap (barre popup)
                    html += '<div class="fa-reaction-wrap" id="creact-wrap-' + c.id + '" style="display:inline-flex;position:relative;flex:none;">';
                    html += '<button class="fa-comment-react-btn' + (hasCommReact ? ' fa-comment-react-btn--active' : '') + '" ';
                    html += 'id="creact-btn-' + c.id + '" ';
                    html += 'onclick="toggleCommReactionBar(\'' + c.id + '\', event)">';
                    html += '<i class="bi bi-hand-thumbs-up' + (hasCommReact ? '-fill' : '') + '" style="font-size:11px;margin-right:3px;"></i>';
                    html += hasCommReact ? myCommReactLib : 'J&apos;aime';
                    if (totalCReact > 0) html += ' <span style="font-weight:400;font-size:11px;">(' + totalCReact + ')</span>';
                    html += '</button>';
                    // Barre reaction popup
                    html += '<div class="fa-reaction-bar" id="creact-bar-' + c.id + '">';
                    for (var jr = 0; jr < rTypes.length; jr++) {
                        var rt = rTypes[jr];
                        var isMyCommR = (c.myReaction === rt.id);
                        var rEmoji = getReactionEmoji(rt.libelle);
                        html += '<button class="fa-reaction-item' + (isMyCommR ? ' fa-reaction-item--active' : '') + '" ';
                        html += 'onclick="selectCommReaction(\'' + c.id + '\',\'' + rt.id + '\',\'' + idpub + '\', event)" ';
                        html += 'title="' + escHtml(rt.libelle) + '">';
                        html += '<span class="fa-reaction-emoji">' + rEmoji + '</span>';
                        html += '<span class="fa-reaction-label">' + escHtml(rt.libelle) + '</span>';
                        html += '</button>';
                    }
                    html += '</div>'; // fa-reaction-bar
                    html += '</div>'; // fa-reaction-wrap

                    html += '<span class="fa-dot">&middot;</span>';
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
    function previewComposerImg(input) {
        if (!input.files || !input.files[0]) return;
        var reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('composer-img-previewImg').src = e.target.result;
            document.getElementById('composer-img-preview').style.display = 'block';
        };
        reader.readAsDataURL(input.files[0]);
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
</script>
