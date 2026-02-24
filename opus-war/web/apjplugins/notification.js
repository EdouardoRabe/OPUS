// ============================================================
// NOTIFICATION.JS — Alumni Notification System
// ============================================================
var mesnotifs = [];
var titre = document.title;
var notifDropdownOpen = false;
var notifBellGroup = null;

// ========== CHARGEMENT DES NOTIFICATIONS ==========
function chargerNotifications() {
    var ctx = (typeof _NOTIF_CTX !== 'undefined') ? _NOTIF_CTX : _CONTEXT_PATH;
    $.ajax({
        type: "GET",
        url: ctx + "/pages/alumni/ajax/charger-notifications.jsp",
        dataType: "json",
        success: function(data) {
            if (!data.success) return;
            mesnotifs = data.notifications || [];
            var nbNonLu = data.nbNonLu || 0;

            // Badge
            var badge = document.getElementById('notif-badge');
            if (badge) {
                if (nbNonLu > 0) {
                    badge.textContent = nbNonLu > 99 ? '99+' : nbNonLu;
                    badge.style.display = 'inline-block';
                    document.title = "(" + nbNonLu + ") " + titre;
                } else {
                    badge.style.display = 'none';
                    document.title = titre;
                }
            }

            // Si dropdown ouvert, mettre a jour la liste
            if (notifBellGroup && notifBellGroup.classList.contains('is-open')) {
                renderNotifList();
            }
        },
        error: function(xhr, status, error) {
            console.error("Erreur chargement notifications:", error);
        }
    });
}

function renderNotifList() {
    var listDiv = document.getElementById('notif-list');
    if (!listDiv) return;

    if (mesnotifs.length === 0) {
        listDiv.innerHTML = '<div style="text-align:center;padding:40px 20px;color:#aaa;"><i class="bi bi-bell-slash" style="font-size:36px;display:block;margin-bottom:10px;color:#ccc;"></i><span style="font-size:14px;">Aucune notification</span></div>';
        return;
    }

    var html = '';
    var limit = Math.min(mesnotifs.length, 20);
    for (var i = 0; i < limit; i++) {
        var n = mesnotifs[i];
        var isUnread = (n.etat === 0 || n.etat === '0');
        var bgColor = isUnread ? '#eef4ff' : '#fff';
        var hoverBg = isUnread ? '#e3ecf8' : '#f5f7fa';
        var dotHtml = isUnread ? '<span style="width:8px;height:8px;background:#1a73e8;border-radius:50%;display:inline-block;margin-left:6px;flex-shrink:0;"></span>' : '';
        var lienClick = n.lien ? ' onclick="ouvrirNotif(\'' + escHtmlAttr(n.id) + '\',\'' + escHtmlAttr(n.lien) + '\')"' : '';
        var fontWeight = isUnread ? 'font-weight:600;' : 'font-weight:400;';

        // Couleur d'icone par type
        var iconColor = '#1a73e8';
        var iconBg = '#e8f0fe';
        if (n.type === 'PUB_REACTION' || n.type === 'COMM_REACTION') { iconColor = '#e8453c'; iconBg = '#fce8e6'; }
        else if (n.type === 'COMMENT' || n.type === 'REPLY') { iconColor = '#188038'; iconBg = '#e6f4ea'; }
        else if (n.type === 'MENTION' || n.type === 'IDENTIFICATION') { iconColor = '#a142f4'; iconBg = '#f3e8fd'; }

        html += '<div class="notif-item"' + lienClick + ' style="display:flex;align-items:flex-start;gap:12px;padding:12px 18px;background:' + bgColor + ';cursor:pointer;transition:background 0.15s;border-bottom:1px solid #f0f0f0;' + fontWeight + '" onmouseover="this.style.background=\'' + hoverBg + '\'" onmouseout="this.style.background=\'' + bgColor + '\'">';

        // Icone
        html += '<div style="flex-shrink:0;width:40px;height:40px;background:' + iconBg + ';border-radius:50%;display:flex;align-items:center;justify-content:center;">';
        html += '<i class="bi ' + getNotifIcon(n.type) + '" style="font-size:17px;color:' + iconColor + ';"></i>';
        html += '</div>';

        // Contenu
        html += '<div style="flex:1;min-width:0;">';
        html += '<div style="font-size:13px;line-height:1.45;color:#1d1d1f;display:flex;align-items:center;">';
        html += '<span style="flex:1;">' + escNotifHtml(n.objet) + '</span>' + dotHtml;
        html += '</div>';
        html += '<div style="font-size:11px;color:#8e8e93;margin-top:3px;"><i class="bi bi-clock" style="margin-right:3px;"></i>' + escNotifHtml(n.ecart || n.daty || '') + '</div>';
        html += '</div>';

        html += '</div>';
    }

    listDiv.innerHTML = html;
}

function getNotifIcon(type) {
    if (!type) return 'bi-bell';
    switch (type) {
        case 'COMMENT': return 'bi-chat-dots-fill';
        case 'REPLY': return 'bi-reply-fill';
        case 'PUB_REACTION': return 'bi-hand-thumbs-up-fill';
        case 'COMM_REACTION': return 'bi-emoji-smile-fill';
        case 'MENTION': return 'bi-at';
        case 'IDENTIFICATION': return 'bi-tag-fill';
        default: return 'bi-bell';
    }
}

function ouvrirNotif(idnotif, lien) {
    // Marquer comme lu puis naviguer
    var ctx = (typeof _NOTIF_CTX !== 'undefined') ? _NOTIF_CTX : _CONTEXT_PATH;
    $.ajax({
        type: "POST",
        url: ctx + "/pages/alumni/ajax/marquer-notification-lu.jsp",
        data: { idnotification: idnotif },
        complete: function() {
            if (lien) window.location.href = lien;
        }
    });
}

function voirToutesNotifs() {
    if (notifBellGroup) {
        notifBellGroup.classList.remove('is-open');
        var bellBtn = document.getElementById('notif-bell-btn');
        if (bellBtn) bellBtn.setAttribute('aria-expanded', 'false');
    }
    var ctx = (typeof _NOTIF_CTX !== 'undefined') ? _NOTIF_CTX : _CONTEXT_PATH;
    window.location.href = ctx + '/pages/module.jsp?but=alumni/notifications.jsp';
}

function marquerToutLu() {
    var ctx = (typeof _NOTIF_CTX !== 'undefined') ? _NOTIF_CTX : _CONTEXT_PATH;
    $.ajax({
        type: "POST",
        url: ctx + "/pages/alumni/ajax/marquer-notification-lu.jsp",
        data: { action: 'all' },
        success: function(data) {
            chargerNotifications();
        }
    });
}

// ========== TOGGLE DROPDOWN ==========
$(document).ready(function() {
    var bellBtn = document.getElementById('notif-bell-btn');
    var panel = document.getElementById('notif-dropdown-panel');

    if (bellBtn && panel) {
        notifBellGroup = bellBtn.closest('.topnav-link-group');

        bellBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            if (!notifBellGroup) return;
            var willOpen = !notifBellGroup.classList.contains('is-open');
            // Fermer les autres groupes ouverts
            document.querySelectorAll('.topnav-link-group.is-open').forEach(function(g) {
                if (g !== notifBellGroup) {
                    g.classList.remove('is-open');
                    var t = g.querySelector('.topnav-link');
                    if (t) t.setAttribute('aria-expanded', 'false');
                }
            });
            if (willOpen) {
                notifBellGroup.classList.add('is-open');
                bellBtn.setAttribute('aria-expanded', 'true');
                renderNotifList();
            } else {
                notifBellGroup.classList.remove('is-open');
                bellBtn.setAttribute('aria-expanded', 'false');
            }
        });

        // Fermer en cliquant dehors
        document.addEventListener('click', function(e) {
            if (notifBellGroup && notifBellGroup.classList.contains('is-open')
                    && !panel.contains(e.target) && e.target !== bellBtn) {
                notifBellGroup.classList.remove('is-open');
                bellBtn.setAttribute('aria-expanded', 'false');
            }
        });

        // Empecher la fermeture en cliquant dans le panel
        panel.addEventListener('click', function(e) {
            e.stopPropagation();
        });
    }
});

// ========== CHARGEMENT INITIAL ==========
chargerNotifications();

// ========== ALARME (code existant conserve) ==========
function showAlarmPopup() {
    $('#alarmModal').modal('show');
}

$(document).ready(function () {
    $('#alarmForm').submit(function (e) {
        e.preventDefault();

        var message = $('#alarmMessage').val();
        var timestamp = $('#alarmTimestamp').val();

        var selectedDate = new Date(timestamp);
        var now = new Date();

        if (isNaN(selectedDate.getTime())) {
            Swal.fire({ title: "Date invalide", html: "<p>Veuillez entrer une date valide.</p>", icon: "warning", confirmButtonText: "OK" });
            return;
        }

        if (selectedDate <= now) {
            Swal.fire({ title: "Date pass&eacute;e", html: "<p>Veuillez choisir une date et une heure futures.</p>", icon: "warning", confirmButtonText: "OK" });
            return;
        }

        $.ajax({
            url: '/opus/alarm',
            method: 'POST',
            contentType: 'application/x-www-form-urlencoded',
            data: { message: message, dh: timestamp },
            success: function (response) {
                if (response.status === 'success') {
                    $('#alarmModal').modal('hide');
                    $('#alarmForm')[0].reset();
                    Swal.fire({
                        title: "Alarme enregistr&eacute;e !",
                        html: "<p><strong>Message&nbsp;:</strong> " + message + "</p><p><strong>Date &amp; Heure&nbsp;:</strong> " + new Date(timestamp).toLocaleString() + "</p>",
                        icon: "success", confirmButtonText: "OK"
                    });
                } else {
                    Swal.fire({ title: "Erreur", html: "<p>" + response.message + "</p>", icon: "error", confirmButtonText: "OK" });
                }
            },
            error: function (xhr, status, error) {
                console.error('Erreur alarme', error);
                Swal.fire({ title: "Erreur", html: "<p>" + (xhr.responseText || 'Erreur inconnue') + "</p>", icon: "error", confirmButtonText: "OK" });
            }
        });
    });
});

// ========== WEBSOCKET NOTIFICATIONS ==========
var loc = window.location;
var protocol = (loc.protocol === "https:") ? "wss://" : "ws://";
var _ctxPath = (typeof _NOTIF_CTX !== 'undefined') ? _NOTIF_CTX : ((typeof _CONTEXT_PATH !== 'undefined') ? _CONTEXT_PATH : '/opus');

var ws_notif_url = protocol + loc.host + _ctxPath + "/ws/notifications";
var ws_notif = new WebSocket(ws_notif_url);

ws_notif.onopen = function() {
    console.log("WS Notifications connecte");
    // Enregistrer l'utilisateur pour recevoir les notifications ciblees
    if (typeof id_user_conn !== 'undefined' && id_user_conn) {
        ws_notif.send("register:" + id_user_conn);
    }
};
ws_notif.onerror = function(e) { console.error("WS Notifications erreur", e); };

ws_notif.onmessage = function(event) {
    var message = event.data;

    // Recharger les notifications depuis le serveur
    chargerNotifications();

    // Notification navigateur
    try {
        var data = JSON.parse(message);
        var notifBody = data.objet || data.message || "Nouvelle notification";

        if (Notification.permission === "granted") {
            new Notification("OPUS Alumni", { body: notifBody, icon: _ctxPath + "/dist/img/ITU_logo.png" });
        } else if (Notification.permission !== "denied") {
            Notification.requestPermission().then(function(permission) {
                if (permission === "granted") {
                    new Notification("OPUS Alumni", { body: notifBody, icon: _ctxPath + "/dist/img/ITU_logo.png" });
                }
            });
        }
    } catch (e) {
        console.log("WS notif parse error:", e);
    }
};

// ========== WEBSOCKET ALARM ==========
var wsAlarmUrl = protocol + loc.host + _ctxPath + "/ws/alarm";
var ws_alarm = new WebSocket(wsAlarmUrl);

ws_alarm.onopen = function() { console.log("WS Alarm connecte"); };
ws_alarm.onerror = function(e) { console.error("WS Alarm erreur", e); };

ws_alarm.onmessage = function(event) {
    try {
        var data = JSON.parse(event.data);
        if (typeof id_user_conn !== 'undefined' && data.refUser === id_user_conn) {
            var showNotif = function() {
                new Notification("Il est temps !", { body: data.message });
            };

            if (Notification.permission === "granted") {
                showNotif();
            } else if (Notification.permission !== "denied") {
                Notification.requestPermission().then(function(p) { if (p === "granted") showNotif(); });
            }

            var oldTitle = document.title;
            var blinkInterval = setInterval(function() {
                document.title = document.title === "[ALERTE]" ? oldTitle : "[ALERTE]";
            }, 1000);

            window.addEventListener('focus', function() {
                clearInterval(blinkInterval);
                document.title = oldTitle;
            });

            Swal.fire({ title: "Il est temps !", html: "<strong>" + data.message + "</strong>", icon: "info", confirmButtonText: "OK" });
        }
    } catch(e) {
        console.log("WS alarm error:", e);
    }
};

// ========== UTILITAIRES ==========
function escNotifHtml(str) {
    if (!str) return '';
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
function escHtmlAttr(str) {
    if (!str) return '';
    return str.replace(/'/g, "\\'").replace(/"/g, '&quot;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
