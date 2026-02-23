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

<div class="content-wrapper">
    <section class="content-header">
        <h1>Fil d'actualit&eacute;</h1>
    </section>
    <section class="content">

        <% if (msgSucces != null) { %>
            <div style="background:#dff0d8;padding:10px;margin-bottom:10px;border:1px solid #d6e9c6;"><%= msgSucces %></div>
        <% } %>
        <% if (msgErreur != null) { %>
            <div style="background:#f2dede;padding:10px;margin-bottom:10px;border:1px solid #ebccd1;"><%= msgErreur %></div>
        <% } %>

        <!-- ==================== FORMULAIRE NOUVELLE PUBLICATION ==================== -->
        <div style="border:1px solid #ccc;padding:15px;margin-bottom:20px;background:#fafafa;border-radius:8px;">
            <h3>Nouvelle publication</h3>
            <form method="POST" enctype="multipart/form-data" id="form-pub"
                  action="<%= ctx %>/pages/alumni/ajax/creer-publication.jsp">
                <div style="margin-bottom:8px;">
                    <label>Type de publication :</label>
                    <select name="idtypepublication" style="padding:5px;margin-left:5px;">
                        <% for (int t = 0; t < typesPub.length; t++) { %>
                            <option value="<%= typesPub[t].getIdtypepublication() %>"><%= typesPub[t].getLibelle() %></option>
                        <% } %>
                    </select>
                </div>
                <div>
                    <textarea name="description" rows="3" style="width:100%;padding:8px;border-radius:6px;border:1px solid #ccc;"
                              placeholder="Quoi de neuf, <%= nomConnecte %> ?"></textarea>
                </div>
                <div style="margin-top:8px;">
                    <label>Image (optionnel) :</label>
                    <input type="file" name="image" accept="image/*">
                </div>

                <!-- Identifier des personnes (comme Facebook) -->
                <div style="margin-top:10px;">
                    <a href="javascript:void(0)" onclick="togglePubTag()" style="text-decoration:none;color:#337ab7;font-size:13px;">
                        <i class="bi bi-tag-fill"></i> Identifier des personnes
                    </a>
                    <div id="pub-tag-zone" style="display:none;margin-top:8px;padding:10px;background:#f0f4ff;border:1px solid #d0d8f0;border-radius:6px;">
                        <input type="text" id="pub-tag-search" placeholder="Rechercher un utilisateur..."
                               oninput="rechercherPourPubTag()" autocomplete="off"
                               style="width:70%;padding:5px;border:1px solid #ccc;border-radius:4px;">
                        <div id="pub-tag-suggestions" style="max-height:150px;overflow-y:auto;border:1px solid #eee;border-radius:4px;background:#fff;"></div>
                        <div id="pub-tag-selected" style="margin-top:5px;display:flex;flex-wrap:wrap;gap:5px;"></div>
                    </div>
                    <input type="hidden" name="identifications" id="pub-identifications" value="">
                </div>

                <div style="margin-top:10px;">
                    <button type="submit" style="padding:8px 20px;background:#337ab7;color:#fff;border:none;border-radius:6px;cursor:pointer;">Publier</button>
                </div>
            </form>
        </div>

        <!-- ==================== LISTE DES PUBLICATIONS (100% APJ) ==================== -->
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
            <div style="text-align:center;padding:40px;color:#999;">
                <p>Aucune publication pour le moment. Soyez le premier &agrave; publier !</p>
            </div>
        <%
                }

                for (int p = 0; p < pubs.length; p++) {
                    Publication pub = pubs[p];
                    String idpub = pub.getIdpublication();
                    String auteur = (String) userNames.get(new Integer(pub.getIdutilisateur()));
                    if (auteur == null) auteur = "Utilisateur";

                    // --- APJ: Medias de cette publication ---
                    Media[] medias = (Media[]) CGenUtil.rechercher(
                        new Media(), null, null, conn,
                        " and idpublication = '" + idpub + "'");
                    if (medias == null) medias = new Media[0];

                    // --- APJ: Reactions sur cette publication ---
                    Publicationreaction[] reactions = (Publicationreaction[]) CGenUtil.rechercher(
                        new Publicationreaction(), null, null, conn,
                        " and idpublication = '" + idpub + "'");
                    if (reactions == null) reactions = new Publicationreaction[0];

                    // Compter par type + trouver ma reaction
                    Map reactCounts = new HashMap();
                    int totalReactions = 0;
                    String myReaction = "";
                    for (int r = 0; r < reactions.length; r++) {
                        String type = reactions[r].getIdreactiontype();
                        Integer cnt = (Integer) reactCounts.get(type);
                        reactCounts.put(type, cnt == null ? new Integer(1) : new Integer(cnt.intValue() + 1));
                        totalReactions++;
                        if (reactions[r].getIdutilisateur() == refuserConnecte) {
                            myReaction = type;
                        }
                    }

                    // --- APJ: Commentaires de cette publication ---
                    Publicationcommentaire[] comments = (Publicationcommentaire[]) CGenUtil.rechercher(
                        new Publicationcommentaire(), null, null, conn,
                        " and idpublication = '" + idpub + "' and etat = 1");
                    if (comments == null) comments = new Publicationcommentaire[0];
                    int nbComm = comments.length;

                    // --- APJ: Personnes identifiees dans cette publication ---
                    Identification[] identTags = (Identification[]) CGenUtil.rechercher(
                        new Identification(), null, null, conn,
                        " and idpublication = '" + idpub + "'");
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

                    // Echapper description
                    String desc = pub.getDescritpion();
                    String descSafe = "";
                    if (desc != null) {
                        descSafe = desc.replace("&", "&amp;").replace("<", "&lt;")
                                       .replace(">", "&gt;").replace("\n", "<br>");
                    }
        %>
        <!-- ====== PUBLICATION ====== -->
        <div id="pub-<%= idpub %>" style="border:1px solid #ddd;padding:15px;margin-bottom:15px;background:#fff;">
            <!-- En-tete -->
            <div style="margin-bottom:10px;">
                <strong><%= auteur %></strong>
                <% if (!taggedNames.isEmpty()) { %>
                    <span style="color:#555;font-size:13px;"> &mdash; avec
                        <strong style="color:#1a73e8;"><%= taggedNames %></strong>
                    </span>
                <% } %>
                &nbsp;&mdash;&nbsp;
                <small><%= pub.getDaty() %> &agrave; <%= pub.getHeure() != null ? pub.getHeure() : "" %></small>
            </div>

            <!-- Contenu -->
            <div style="margin-bottom:10px;">
                <p><%= descSafe %></p>
                <% for (int m = 0; m < medias.length; m++) {
                    String mUrl = medias[m].getMediaurl();
                    if (mUrl != null && !mUrl.startsWith("http")) {
                        mUrl = ctx + "/UploadDownloadFileServlet?fileName=" + java.net.URLEncoder.encode(mUrl, "UTF-8");
                    }
                %>
                    <div style="margin-top:8px;">
                        <img src="<%= mUrl %>" style="max-width:100%;max-height:400px;border:1px solid #eee;" alt="media">
                    </div>
                <% } %>
            </div>

            <!-- Resume reactions -->
            <div style="color:#666;font-size:12px;margin-bottom:5px;">
                <% if (totalReactions > 0) { %>
                    <%= totalReactions %> r&eacute;action(s)
                <% } %>
            </div>

            <hr style="margin:5px 0;">

            <!-- Boutons reactions -->
            <div id="reactions-<%= idpub %>" style="margin-bottom:8px;">
                <% for (int rt = 0; rt < reactTypes.length; rt++) {
                    String rtId = reactTypes[rt].getIdreactiontype();
                    String rtLib = reactTypes[rt].getLibelle();
                    Integer cntObj = (Integer) reactCounts.get(rtId);
                    int count = cntObj != null ? cntObj.intValue() : 0;
                    boolean isMyReaction = rtId.equals(myReaction);
                    String btnStyle = isMyReaction
                        ? "font-weight:bold;background:#d0e8ff;border:1px solid #80b3e0;padding:3px 8px;margin-right:3px;cursor:pointer;"
                        : "padding:3px 8px;margin-right:3px;cursor:pointer;border:1px solid #ccc;background:#f5f5f5;";
                %>
                <button onclick="toggleReaction('<%= idpub %>', '<%= rtId %>')"
                        style="<%= btnStyle %>">
                    <%= rtLib %><% if (count > 0) { %> (<%= count %>)<% } %>
                </button>
                <% } %>
            </div>

            <!-- Lien commentaires + Identifier -->
            <div style="display:flex;gap:15px;align-items:center;">
                <a href="javascript:void(0)" onclick="toggleCommentaires('<%= idpub %>')" style="text-decoration:none;color:#333;">
                    &#128172; <span id="nb-comm-<%= idpub %>"><%= nbComm %></span> commentaire(s)
                </a>
                <a href="javascript:void(0)" onclick="toggleIdentifier('<%= idpub %>')" style="text-decoration:none;color:#337ab7;font-size:13px;">
                    <i class="bi bi-tag"></i> Identifier
                </a>
            </div>

            <!-- Zone identification (cachee) -->
            <div id="identifier-<%= idpub %>" style="display:none;margin-top:8px;padding:10px;background:#f9f9ff;border:1px solid #e0e0ff;border-radius:6px;">
                <div style="margin-bottom:5px;font-size:13px;color:#555;">Identifier des personnes :</div>
                <input type="text" id="tag-search-<%= idpub %>" placeholder="Rechercher un utilisateur..."
                       oninput="rechercherPourTag('<%= idpub %>')" 
                       style="width:70%;padding:5px;border:1px solid #ccc;border-radius:4px;">
                <div id="tag-suggestions-<%= idpub %>" style="max-height:150px;overflow-y:auto;"></div>
                <div id="tag-selected-<%= idpub %>" style="margin-top:5px;display:flex;flex-wrap:wrap;gap:5px;"></div>
                <button onclick="envoyerIdentifications('<%= idpub %>')" 
                        style="margin-top:8px;padding:5px 15px;background:#337ab7;color:#fff;border:none;border-radius:4px;cursor:pointer;">Valider</button>
            </div>

            <!-- Zone commentaires (cachee) -->
            <div id="commentaires-<%= idpub %>" style="display:none;margin-top:10px;padding-left:15px;border-left:2px solid #eee;">
                <div id="liste-comm-<%= idpub %>"><em>Chargement...</em></div>
                <div style="margin-top:8px;padding-top:8px;border-top:1px solid #eee;position:relative;">
                    <input type="text" id="comm-text-<%= idpub %>" 
                           placeholder="Ecrire un commentaire... (tapez @ pour mentionner)" 
                           style="width:75%;padding:5px;"
                           oninput="onCommentInput(this, '<%= idpub %>')"
                           onkeydown="onCommentKeydown(event, '<%= idpub %>')">
                    <input type="hidden" id="comm-mentions-<%= idpub %>" value="">
                    <div id="mention-suggestions-<%= idpub %>" class="mention-dropdown" style="display:none;"></div>
                    <button onclick="ajouterCommentaire('<%= idpub %>')" style="padding:5px 12px;">Envoyer</button>
                </div>
            </div>
        </div>
        <%
                } // fin for publications
            } catch (Exception e) {
                e.printStackTrace();
        %>
            <div style="background:#f2dede;padding:10px;border:1px solid #ebccd1;">
                Erreur lors du chargement: <%= e.getMessage() %>
            </div>
        <%
            } finally {
                if (conn != null) try { conn.close(); } catch (Exception ex) {}
            }
        %>
    </section>
</div>

<!-- ==================== STYLES MENTION / IDENTIFICATION ==================== -->
<style>
.mention-dropdown {
    position: absolute; bottom: 45px; left: 0;
    background: #fff; border: 1px solid #ddd; border-radius: 6px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15); z-index: 1000;
    max-height: 200px; overflow-y: auto; width: 280px;
}
.mention-dropdown .mention-item {
    padding: 8px 12px; cursor: pointer; font-size: 13px;
    border-bottom: 1px solid #f0f0f0;
}
.mention-dropdown .mention-item:hover, .mention-dropdown .mention-item.active {
    background: #e8f0fe; color: #1a73e8;
}
.tag-chip {
    display: inline-flex; align-items: center; gap: 4px;
    background: #e8f0fe; color: #1a73e8; padding: 3px 8px;
    border-radius: 12px; font-size: 12px;
}
.tag-chip .remove-tag {
    cursor: pointer; font-weight: bold; color: #999; margin-left: 4px;
}
.tag-chip .remove-tag:hover { color: #e00; }
.mention-badge {
    color: #1a73e8; font-weight: bold; background: #e8f0fe;
    padding: 1px 4px; border-radius: 3px; font-size: 12px;
}
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
            var indent = Math.min(depth, 5) * 25; // max 5 niveaux d'indentation
            var html = '';
            html += '<div id="comm-' + c.id + '" style="padding:8px 0;border-bottom:1px solid #f0f0f0;margin-left:' + indent + 'px;">';
            if (depth > 0) html += '<small style="color:#999;">&#8627; r&eacute;ponse</small> ';
            html += '<strong>' + escHtml(c.auteur) + '</strong>: ' + formatMentions(c.description);

            // Reactions
            html += ' <span style="font-size:11px;">';
            for (var j = 0; j < rTypes.length; j++) {
                var rt = rTypes[j];
                var cnt = c.reactions[rt.id] || 0;
                var bold = (c.myReaction === rt.id) ? 'font-weight:bold;background:#d0e8ff;' : '';
                html += ' <button style="font-size:10px;padding:1px 5px;cursor:pointer;' + bold + '" ';
                html += 'onclick="toggleReactionComm(\'' + c.id + '\',\'' + rt.id + '\',\'' + idpub + '\')">';
                html += rt.libelle;
                if (cnt > 0) html += '(' + cnt + ')';
                html += '</button>';
            }
            html += '</span>';

            // Bouton repondre - sur TOUS les commentaires (pas juste top-level)
            html += ' <a href="javascript:void(0)" onclick="montrerReponse(\'' + c.id + '\',\'' + idpub + '\',\'' + escAttr(c.auteur) + '\',\'' + c.idutilisateur + '\')" style="font-size:11px;color:#337ab7;">R&eacute;pondre</a>';
            html += '<div id="reponse-form-' + c.id + '" style="display:none;margin-top:5px;margin-left:15px;position:relative;">';
            html += '<input type="text" id="reponse-text-' + c.id + '" placeholder="Votre r&eacute;ponse... (tapez @ pour mentionner)" style="width:60%;padding:4px;"'
                + ' oninput="onReplyInput(this,\'' + c.id + '\',\'' + idpub + '\')"'
                + ' onkeydown="onReplyKeydown(event,\'' + c.id + '\',\'' + idpub + '\')">';
            html += '<input type="hidden" id="reponse-mentions-' + c.id + '" value="">';
            html += '<div id="mention-reply-' + c.id + '" class="mention-dropdown" style="display:none;"></div>';
            html += ' <button onclick="ajouterReponse(\'' + idpub + '\',\'' + c.id + '\')" style="padding:4px 10px;">Envoyer</button>';
            html += '</div>';

            html += '</div>';

            // Rendu recursif des enfants
            for (var k = 0; k < c.children.length; k++) {
                html += renderComment(c.children[k], depth + 1);
            }
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
</script>
