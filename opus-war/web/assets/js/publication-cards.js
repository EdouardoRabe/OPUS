/* ============================================================
   publication-cards.js
   Fonctions partagées pour les cartes de publication
   Nécessite: window.CTX et window.CURRENT_USER_ID définis avant chargement
   ============================================================ */

// ========== UTILITAIRES ==========
function escHtml(str) {
    if (!str) return '';
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
function escAttr(str) {
    if (!str) return '';
    return str.replace(/'/g, "\\'").replace(/"/g, '&quot;');
}
function getInitials(name) {
    if (!name) return '?';
    var parts = name.trim().split(/\s+/);
    var ini = parts[0].charAt(0).toUpperCase();
    if (parts.length > 1) ini += parts[parts.length - 1].charAt(0).toUpperCase();
    return ini;
}
function formatMentions(text) {
    if (!text) return '';
    var safe = escHtml(text);
    return safe.replace(/@([A-Za-z\u00C0-\u00FF]+(?: [A-Za-z\u00C0-\u00FF]+){0,2})/g,
        '<span class="mention-badge">@$1</span>');
}
function getReactionEmoji(lib) {
    var l = lib.toLowerCase();
    if (l.indexOf('adore') >= 0 || l.indexOf('love') >= 0) return '\u2764\uFE0F';
    if (l.indexOf('haha') >= 0 || l.indexOf('humour') >= 0) return '\uD83D\uDE02';
    if (l.indexOf('surprise') >= 0 || l.indexOf('wow') >= 0) return '\uD83D\uDE2E';
    if (l.indexOf('triste') >= 0 || l.indexOf('sad') >= 0) return '\uD83D\uDE22';
    if (l.indexOf('grrr') >= 0 || l.indexOf('ang') >= 0) return '\uD83D\uDE20';
    return '\uD83D\uDC4D';
}

// ========== MENU PUBLICATION (3 points) ==========
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
    fetch(CTX + '/pages/alumni/ajax/save-publication.jsp?idpublication=' + encodeURIComponent(idpub))
    .then(function(r){return r.json();}).then(function(d){
        if(d.success) {
            if (typeof Swal !== 'undefined') Swal.fire({toast:true,position:'top-end',icon:'success',title:'Sauvegardée',timer:1500,showConfirmButton:false});
            else alert('Publication sauvegardée');
        } else alert('Erreur sauvegarde');
    });
}
function reportPublication(idpub) {
    window.location.href = CTX + '/pages/module.jsp?but=alumni/signaler-publication.jsp&idpublication=' + encodeURIComponent(idpub);
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
    if (!isOpen) bar.classList.add('fa-reaction-bar--open');
}
function selectReaction(idpub, idreactiontype, event) {
    event.stopPropagation();
    closeAllReactionBars();
    toggleReaction(idpub, idreactiontype);
}
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
                var url = new URL(window.location.href);
                url.searchParams.set('scrollTo', 'pub-' + idpub);
                window.location.href = url.toString();
            } else {
                alert('Erreur reaction: ' + (data.error || 'Inconnue'));
            }
        })
        .catch(function(e) { alert('Erreur reseau (reaction): ' + e); });
}

// ========== REACTION BAR COMMENTAIRE ==========
function toggleCommReactionBar(commId, event) {
    event.stopPropagation();
    var bar = document.getElementById('creact-bar-' + commId);
    var isOpen = bar.classList.contains('fa-reaction-bar--open');
    closeAllReactionBars();
    if (!isOpen) bar.classList.add('fa-reaction-bar--open');
}
function selectCommReaction(commId, idreactiontype, idpub, event) {
    event.stopPropagation();
    closeAllReactionBars();
    toggleReactionComm(commId, idreactiontype, idpub);
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
                chargerCommentaires(idpub, function() {
                    var _el = document.getElementById('comm-' + idcomm);
                    if (_el) _el.scrollIntoView({behavior:'smooth', block:'nearest'});
                });
            } else {
                alert('Erreur reaction commentaire: ' + (data.error || 'Inconnue'));
            }
        })
        .catch(function(e) { alert('Erreur reseau (reaction comm): ' + e); });
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

function chargerCommentaires(idpub, _callback) {
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

            function renderComment(c, depth) {
                var initials = getInitials(c.auteur);
                var replyClass = depth > 0 ? ' fa-comment-item--reply' : '';
                var html = '';
                html += '<div id="comm-' + c.id + '" class="fa-comment-item' + replyClass + '">';
                html += '<div class="fa-comment-inner">';
                var profileUrl;
                if (c.idutilisateur === data.refuser) {
                    profileUrl = CTX + '/pages/module.jsp?but=profil/voir.jsp';
                } else {
                    profileUrl = (c.idprofil && c.idprofil !== '')
                        ? CTX + '/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp?idprofil=' + encodeURIComponent(c.idprofil)
                        : '#';
                }
                if (profileUrl !== '#' && c.photo) {
                    html += '<a href="' + profileUrl + '" style="text-decoration:none;cursor:pointer;">';
                    html += '<div class="fa-avatar fa-avatar--xs" style="background:transparent;cursor:pointer;"><img src="' + CTX + '/' + escHtml(c.photo) + '" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;cursor:pointer;"></div>';
                    html += '</a>';
                } else if (c.photo) {
                    html += '<div class="fa-avatar fa-avatar--xs" style="background:transparent;"><img src="' + CTX + '/' + escHtml(c.photo) + '" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"></div>';
                } else if (profileUrl !== '#') {
                    html += '<a href="' + profileUrl + '" style="text-decoration:none;cursor:pointer;">';
                    html += '<div class="fa-avatar fa-avatar--xs" style="cursor:pointer;">' + escHtml(initials) + '</div>';
                    html += '</a>';
                } else {
                    html += '<div class="fa-avatar fa-avatar--xs">' + escHtml(initials) + '</div>';
                }
                html += '<div class="fa-comment-content">';
                html += '<div class="fa-comment-bubble">';
                if (profileUrl !== '#') {
                    html += '<a href="' + profileUrl + '" style="text-decoration:none;color:inherit;cursor:pointer;">';
                    html += '<span class="fa-comment-author" style="cursor:pointer;">' + escHtml(c.auteur) + '</span>';
                    html += '</a>';
                } else {
                    html += '<span class="fa-comment-author">' + escHtml(c.auteur) + '</span>';
                }
                html += '<span class="fa-comment-text">' + formatMentions(c.description) + '</span>';
                html += '</div>';

                var totalCReact = 0;
                var myCommReactLib = '';
                for (var jr = 0; jr < c.reactions.length; jr++) {
                    totalCReact += c.reactions[jr].count || 0;
                    if (c.myReaction === c.reactions[jr].id) myCommReactLib = c.reactions[jr].libelle;
                }
                var hasCommReact = (c.myReaction && c.myReaction !== '');

                html += '<div class="fa-comment-actions">';
                if (c.reactions.length > 0) {
                    html += '<div style="display:flex;gap:4px;align-items:center;margin-bottom:4px;flex-wrap:wrap;">';
                    for (var jreact = 0; jreact < c.reactions.length; jreact++) {
                        var reactItem = c.reactions[jreact];
                        html += '<span class="fa-counter" title="' + escHtml(reactItem.libelle) + '">';
                        html += reactItem.emoji + '&nbsp;' + reactItem.count;
                        html += '</span>';
                    }
                    html += '</div>';
                }
                html += '<div class="fa-reaction-wrap" id="creact-wrap-' + c.id + '" style="display:inline-flex;position:relative;flex:none;">';
                html += '<button class="fa-comment-react-btn' + (hasCommReact ? ' fa-comment-react-btn--active' : '') + '" ';
                html += 'id="creact-btn-' + c.id + '" ';
                html += 'onclick="toggleCommReactionBar(\'' + c.id + '\', event)">';
                html += '<i class="bi bi-hand-thumbs-up' + (hasCommReact ? '-fill' : '') + '" style="font-size:11px;margin-right:3px;"></i>';
                html += hasCommReact ? myCommReactLib : 'J&apos;aime';
                html += '</button>';
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
                html += '</div>';
                html += '</div>';
                html += '<span class="fa-dot">&middot;</span>';
                html += '<a href="javascript:void(0)" class="fa-comment-reply-link" ';
                html += 'onclick="montrerReponse(\'' + c.id + '\',\'' + idpub + '\',\'' + escAttr(c.auteur) + '\',\'' + c.idutilisateur + '\')">';
                html += 'R&eacute;pondre</a>';
                html += '</div>';

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

                if (c.children.length > 0) {
                    var n = c.children.length;
                    html += '<div class="fa-replies-area">';
                    html += '<button id="replies-btn-' + c.id + '" class="fa-replies-toggle" data-count="' + n + '" onclick="toggleReplies(\'' + c.id + '\')">';
                    html += '<i class="bi bi-chevron-down"></i> Voir ' + n + ' r\u00e9ponse' + (n > 1 ? 's' : '');
                    html += '</button>';
                    html += '<div id="replies-' + c.id + '" class="fa-replies-wrap">';
                    for (var k = 0; k < c.children.length; k++) {
                        html += renderComment(c.children[k], depth + 1);
                    }
                    html += '</div>';
                    html += '</div>';
                }

                html += '</div>';
                html += '</div>';
                html += '</div>';
                return html;
            }

            var html = '';
            for (var i = 0; i < topLevel.length; i++) {
                html += renderComment(topLevel[i], 0);
            }
            listeDiv.innerHTML = html;
            if (_callback) setTimeout(_callback, 60);
        })
        .catch(function(e) { listeDiv.innerHTML = '<span style="color:red;">Erreur: ' + e + '</span>'; });
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
                chargerCommentaires(idpub, function() {
                    var _liste = document.getElementById('liste-comm-' + idpub);
                    if (_liste && _liste.lastElementChild)
                        _liste.lastElementChild.scrollIntoView({behavior:'smooth', block:'nearest'});
                });
                var nbSpan = document.getElementById('nb-comm-' + idpub);
                if (nbSpan) nbSpan.textContent = parseInt(nbSpan.textContent) + 1;
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

// ========== MENTIONS DANS LES COMMENTAIRES ==========
var mentionData = {};
function getMentionState(idpub) {
    if (!mentionData[idpub]) {
        mentionData[idpub] = { suggestions: [], selectedIndex: 0, mentionIds: [], searchStart: -1 };
    }
    return mentionData[idpub];
}

function onCommentInput(input, idpub) {
    var val = input.value;
    var cursorPos = input.selectionStart;
    var state = getMentionState(idpub);
    var textBeforeCursor = val.substring(0, cursorPos);
    var atIdx = textBeforeCursor.lastIndexOf('@');

    if (atIdx >= 0) {
        var charBefore = atIdx > 0 ? textBeforeCursor[atIdx - 1] : ' ';
        if (charBefore === ' ' || charBefore === '\t' || atIdx === 0) {
            var searchText = textBeforeCursor.substring(atIdx + 1);
            if (searchText.length >= 1 && searchText.split(' ').length <= 3) {
                state.searchStart = atIdx;
                rechercherMention(idpub, searchText);
                return;
            }
        }
    }
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
    }, 200);
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

    var before = val.substring(0, atIdx);
    var cursorPos = input.selectionStart;
    var after = val.substring(cursorPos);
    var mention = '@' + user.nomComplet + ' ';
    input.value = before + mention + after;
    input.focus();
    var newPos = before.length + mention.length;
    input.setSelectionRange(newPos, newPos);

    if (state.mentionIds.indexOf(user.id) === -1) {
        state.mentionIds.push(user.id);
    }
    document.getElementById('comm-mentions-' + idpub).value = state.mentionIds.join(',');
    hideMentionDropdown(idpub);
}

// ========== MENTIONS DANS LES REPONSES ==========
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
                chargerCommentaires(idpub, function() {
                    var _el = document.getElementById('comm-' + idparent);
                    if (_el) _el.scrollIntoView({behavior:'smooth', block:'nearest'});
                });
                var nbSpan = document.getElementById('nb-comm-' + idpub);
                if (nbSpan) nbSpan.textContent = parseInt(nbSpan.textContent) + 1;
            } else {
                alert('Erreur reponse: ' + (data.error || 'Inconnue'));
            }
        })
        .catch(function(e) { alert('Erreur reseau (reponse): ' + e); });
}

// ========== IDENTIFICATION (TAGS) ==========
var tagData = {};
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
                if (typeof Swal !== 'undefined') Swal.fire({ title: 'Identification envoyee', icon: 'success', timer: 1500, showConfirmButton: false });
                else alert('Identification envoyee');
            } else {
                alert('Erreur: ' + (data.error || 'Inconnue'));
            }
        })
        .catch(function(e) { alert('Erreur reseau: ' + e); });
}

// ========== PARTAGE PUBLICATION ==========
var _shareIdPub = null;
function openShareModal(idpub, auteur, datepub, texte) {
    _shareIdPub = idpub;
    document.getElementById('share-description').value = '';
    document.getElementById('share-orig-author').textContent = auteur || '';
    document.getElementById('share-orig-date').textContent = datepub || '';
    document.getElementById('share-orig-text').textContent = texte || '';
    document.getElementById('share-submit-btn').disabled = false;
    document.getElementById('share-modal').style.display = 'flex';
    document.getElementById('share-description').focus();
}
function closeShareModal() {
    document.getElementById('share-modal').style.display = 'none';
    _shareIdPub = null;
}
function submitShare() {
    if (!_shareIdPub) return;
    var btn = document.getElementById('share-submit-btn');
    var desc = document.getElementById('share-description').value.trim();
    btn.disabled = true;
    fetch(CTX + '/pages/alumni/ajax/partager-publication.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'idpublication=' + encodeURIComponent(_shareIdPub)
            + '&description=' + encodeURIComponent(desc)
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.success) {
            closeShareModal();
            var url = new URL(window.location.href);
            url.searchParams.set('scrollTo', 'pub-' + data.idpublication);
            window.location.href = url.toString();
        } else {
            btn.disabled = false;
            alert('Erreur lors du partage: ' + (data.error || 'Inconnue'));
        }
    })
    .catch(function(e) { btn.disabled = false; alert('Erreur réseau: ' + e); });
}
document.addEventListener('click', function(e) {
    var sm = document.getElementById('share-modal');
    if (sm && e.target === sm) closeShareModal();
    var pdm = document.getElementById('pub-detail-modal');
    if (pdm && e.target === pdm) closePublicationDetail();
});

// ========== DETAIL PUBLICATION (clic sur partage embarque) ==========
function openPublicationDetail(idpub) {
    if (!idpub) return;
    var modal = document.getElementById('pub-detail-modal');
    var content = document.getElementById('pub-detail-content');
    content.innerHTML = '<div style="text-align:center;padding:40px;"><div class="fa-feed-spinner"></div></div>';
    modal.style.display = 'flex';
    fetch(CTX + '/pages/alumni/ajax/voir-publication.jsp?idpublication=' + encodeURIComponent(idpub))
        .then(function(r) { return r.text(); })
        .then(function(html) {
            content.innerHTML = html;
        })
        .catch(function(e) {
            content.innerHTML = '<p style="color:red;padding:20px;text-align:center;">Erreur: ' + e + '</p>';
        });
}
function closePublicationDetail() {
    var modal = document.getElementById('pub-detail-modal');
    if (modal) {
        modal.style.display = 'none';
        document.getElementById('pub-detail-content').innerHTML = '';
    }
}

// ========== MODALE DETAIL REACTIONS ==========
function openReactionDetails(idpub) {
    var modal   = document.getElementById('react-detail-modal');
    var content = document.getElementById('react-detail-content');
    modal.style.display = 'flex';
    content.innerHTML = '<div style="text-align:center;padding:40px;"><div class="fa-feed-spinner"></div></div>';
    fetch(CTX + '/pages/alumni/ajax/detail-reactions.jsp?idpublication=' + encodeURIComponent(idpub))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data.success) { content.innerHTML = '<p style="color:red;padding:20px;">' + escHtml(data.error || 'Erreur') + '</p>'; return; }
            if (!data.reactions || data.reactions.length === 0) {
                content.innerHTML = '<p style="text-align:center;color:#888;padding:30px;">Aucune r\u00e9action</p>';
                return;
            }
            var html = '<div class="rdm-header">';
            html += '<h3 class="rdm-title">R\u00e9actions</h3>';
            html += '<button class="rdm-close" onclick="closeReactionDetails()">&times;</button>';
            html += '</div>';
            html += '<div class="rdm-tabs">';
            html += '<button class="rdm-tab rdm-tab--active" onclick="rdmShowTab(this,\'all\')">Tout&nbsp;<span class="rdm-tab-count">' + data.total + '</span></button>';
            for (var i = 0; i < data.reactions.length; i++) {
                var rt = data.reactions[i];
                html += '<button class="rdm-tab" onclick="rdmShowTab(this,\'' + rt.id + '\')">'
                      + rt.emoji + '&nbsp;<span class="rdm-tab-count">' + rt.count + '</span></button>';
            }
            html += '</div>';
            html += '<div class="rdm-panel" id="rdm-panel-all">';
            for (var i = 0; i < data.reactions.length; i++) {
                for (var j = 0; j < data.reactions[i].users.length; j++)
                    html += rdmUserRow(data.reactions[i].users[j], data.reactions[i].emoji, data.myId);
            }
            html += '</div>';
            for (var i = 0; i < data.reactions.length; i++) {
                var rt = data.reactions[i];
                html += '<div class="rdm-panel rdm-panel--hidden" id="rdm-panel-' + rt.id + '">';
                for (var j = 0; j < rt.users.length; j++)
                    html += rdmUserRow(rt.users[j], rt.emoji, data.myId);
                html += '</div>';
            }
            content.innerHTML = html;
        })
        .catch(function(e) { content.innerHTML = '<p style="color:red;padding:20px;">Erreur r\u00e9seau: ' + e + '</p>'; });
}
function rdmUserRow(u, emoji, myId) {
    var profileUrl;
    if (String(u.idutilisateur) === String(myId)) {
        profileUrl = CTX + '/pages/module.jsp?but=profil/voir.jsp';
    } else if (u.idprofil) {
        profileUrl = CTX + '/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp?idprofil=' + encodeURIComponent(u.idprofil);
    } else {
        profileUrl = null;
    }
    var initials = getInitials(u.nom);
    var wrap = profileUrl ? '<a href="' + profileUrl + '" class="rdm-user-row">' : '<div class="rdm-user-row">';
    var wrapEnd = profileUrl ? '</a>' : '</div>';
    var avatarInner = u.photo
        ? '<img src="' + escHtml(u.photo) + '" alt="" style="width:100%;height:100%;object-fit:cover;">'
        : escHtml(initials);
    return wrap
        + '<div class="rdm-avatar">' + avatarInner + '</div>'
        + '<div class="rdm-user-name">' + escHtml(u.nom) + '</div>'
        + '<span class="rdm-reaction-emoji">' + emoji + '</span>'
        + wrapEnd;
}
function rdmShowTab(btn, panelId) {
    var modal = document.getElementById('react-detail-modal');
    modal.querySelectorAll('.rdm-tab').forEach(function(t) { t.classList.remove('rdm-tab--active'); });
    btn.classList.add('rdm-tab--active');
    modal.querySelectorAll('.rdm-panel').forEach(function(p) { p.classList.add('rdm-panel--hidden'); });
    var panel = document.getElementById('rdm-panel-' + panelId);
    if (panel) panel.classList.remove('rdm-panel--hidden');
}
function closeReactionDetails() {
    document.getElementById('react-detail-modal').style.display = 'none';
}
document.addEventListener('click', function(e) {
    var modal = document.getElementById('react-detail-modal');
    if (modal && e.target === modal) closeReactionDetails();
});
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') { closeReactionDetails(); closeShareModal(); closePublicationDetail(); }
});
