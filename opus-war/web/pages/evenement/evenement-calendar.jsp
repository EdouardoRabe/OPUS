<%@ page import="user.*" %>
<%
    String lien = (String) session.getValue("lien");
    UserEJB u = (UserEJB) session.getAttribute("u");
    int currentUserId = (u != null) ? u.getUser().getRefuser() : 0;
%>

<!-- ═══════════════════════════════════════════════════════════════
     FULLCALENDAR ASSETS (local, already in assets/calendar/)
     ═══════════════════════════════════════════════════════════════ -->
<link  rel="stylesheet" href="${pageContext.request.contextPath}/assets/calendar/fullcalendar.min.css">
<script src="${pageContext.request.contextPath}/assets/calendar/moment.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/calendar/fullcalendar.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/calendar/fr.js"></script>

<!-- ═══════════════════════════════════════════════════════════════
     PAGE HEADER
     ═══════════════════════════════════════════════════════════════ -->
<div class="page-header-top" style="margin-bottom:0;">
    <h1 class="page-title-lg">
        <i class="fa fa-calendar" style="color:var(--itu-blue);font-size:1.15rem;margin-right:10px;"></i>
        Calendrier des &eacute;v&eacute;nements
    </h1>
</div>

<!-- ═══════════════════════════════════════════════════════════════
     STATS STRIP
     ═══════════════════════════════════════════════════════════════ -->
<div class="cal-stats-strip">
    <div class="cal-stat-chip">
        <div class="cal-stat-icon" style="background:#1E40AF;">
            <i class="fa fa-calendar-o"></i>
        </div>
        <div class="cal-stat-text">
            <span class="cal-stat-val" id="statTotal">–</span>
            <span class="cal-stat-label">Total</span>
        </div>
    </div>
    <div class="cal-stat-chip">
        <div class="cal-stat-icon" style="background:#059669;">
            <i class="fa fa-arrow-up"></i>
        </div>
        <div class="cal-stat-text">
            <span class="cal-stat-val" id="statUpcoming">–</span>
            <span class="cal-stat-label">&Agrave; venir</span>
        </div>
    </div>
    <div class="cal-stat-chip">
        <div class="cal-stat-icon" style="background:#64748B;">
            <i class="fa fa-history"></i>
        </div>
        <div class="cal-stat-text">
            <span class="cal-stat-val" id="statPast">–</span>
            <span class="cal-stat-label">Pass&eacute;s</span>
        </div>
    </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════
     MAIN LAYOUT: CALENDAR + SIDE PANEL
     ═══════════════════════════════════════════════════════════════ -->
<div class="cal-layout">

    <!-- ── CALENDAR CARD ── -->
    <div class="cal-main-card custom-card no-hover">
        <div id="fullCalendar"></div>
    </div>

    <!-- ── SIDE PANEL: Upcoming events ── -->
    <div class="cal-side-panel">
        <div class="cal-side-header">
            <i class="fa fa-bolt" style="color:var(--itu-blue);margin-right:6px;"></i>
            Prochains &eacute;v&eacute;nements
        </div>
        <div id="upcomingList" class="cal-upcoming-list">
            <!-- Filled by JS -->
        </div>
    </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════
     EVENT DETAIL MODAL
     ═══════════════════════════════════════════════════════════════ -->
<div id="evtModal" class="evt-modal-overlay" style="display:none;">
    <div class="evt-modal-card">
        <div class="evt-modal-banner" id="evtModalBanner">
            <button class="evt-modal-close" id="evtModalClose" title="Fermer">&times;</button>
            <div class="evt-modal-banner-icon">
                <i class="fa fa-calendar-check-o"></i>
            </div>
        </div>
        <div class="evt-modal-body">
            <h2 id="evtModalTitle" class="evt-modal-title"></h2>
            <div id="evtModalId" class="evt-modal-id"></div>

            <div class="evt-modal-dates">
                <div class="evt-modal-date-item">
                    <div class="evt-modal-date-icon" style="background:rgba(30,64,175,0.08);color:#1E40AF;">
                        <i class="fa fa-play"></i>
                    </div>
                    <div>
                        <div class="evt-modal-date-label">D&eacute;but</div>
                        <div class="evt-modal-date-val" id="evtModalStart">—</div>
                    </div>
                </div>
                <div class="evt-modal-date-item">
                    <div class="evt-modal-date-icon" style="background:rgba(220,38,38,0.08);color:#DC2626;">
                        <i class="fa fa-stop"></i>
                    </div>
                    <div>
                        <div class="evt-modal-date-label">Fin</div>
                        <div class="evt-modal-date-val" id="evtModalEnd">—</div>
                    </div>
                </div>
                <div class="evt-modal-date-item">
                    <div class="evt-modal-date-icon" style="background:rgba(16,185,129,0.08);color:#059669;">
                        <i class="fa fa-clock-o"></i>
                    </div>
                    <div>
                        <div class="evt-modal-date-label">Cr&eacute;&eacute; le</div>
                        <div class="evt-modal-date-val" id="evtModalDaty">—</div>
                    </div>
                </div>
            </div>

            <div class="evt-modal-actions" style="flex-direction:column;gap:0.75rem;">
                <div style="display:flex;align-items:center;gap:8px;font-size:0.85rem;color:var(--gray-600);padding:0.5rem 0;">
                    <i class="fa fa-users" style="color:var(--itu-blue);"></i>
                    <span id="evtModalNbParticipants">0</span> participant(s)
                </div>
                <button id="evtModalParticiper" onclick="participerEvenement()" class="btn btn-primary" style="display:inline-flex;align-items:center;gap:8px;justify-content:center;width:100%;font-weight:600;font-size:0.9rem;padding:0.65rem 1rem;border-radius:10px;cursor:pointer;">
                    <i class="fa fa-check-circle"></i> Participer
                </button>
                <button id="evtModalAnnuler" onclick="annulerParticipation()" class="btn" style="display:none;align-items:center;gap:8px;justify-content:center;width:100%;font-weight:600;font-size:0.9rem;padding:0.65rem 1rem;border-radius:10px;color:#e53e3e;border:1.5px solid #fecaca;background:#fff0f0;cursor:pointer;transition:background .2s;">
                    <i class="fa fa-times-circle"></i> Annuler ma participation
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════
     STYLES — UI/UX PRO MAX
     ═══════════════════════════════════════════════════════════════ -->
<!-- Calendar styles extracted to external CSS -->
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/pages/evenement-calendar.css" />

<!-- ═══════════════════════════════════════════════════════════════
     SCRIPT — Initialize FullCalendar & Side Panel & Modal
     ═══════════════════════════════════════════════════════════════ -->
<script>
(function($) {
    var LIEN   = '<%= lien %>';
    var CTX    = '<%= request.getContextPath() %>';
    var EVENTS = [];          /* cache local mis à jour à chaque fetch */
    var ALL_EVENTS = [];      /* tous les événements chargés au total (pour side panel & stats) */
    var currentEventId = null;

    /* ── Utility: format date string for display ── */
    function fmtDate(str) {
        if (!str) return '\u2014';
        var d = moment(str);
        return d.isValid() ? d.format('DD MMM YYYY') : str;
    }

    /* ── Mise à jour du side panel Prochains événements ── */
    function updateSidePanel() {
        var todayStr = moment().format('YYYY-MM-DD');
        var upcoming = ALL_EVENTS
            .filter(function(e) { return e.start >= todayStr; })
            .sort(function(a, b) { return a.start < b.start ? -1 : 1; })
            .slice(0, 8);

        var $list = $('#upcomingList');
        if (upcoming.length === 0) {
            $list.html('<div class="cal-upcoming-empty"><i class="fa fa-calendar-o" style="font-size:1.5rem;display:block;margin-bottom:0.5rem;opacity:.4;"></i>Aucun événement à venir</div>');
        } else {
            var html = '';
            upcoming.forEach(function(evt) {
                html += '<div class="cal-upcoming-item" data-id="' + evt.id + '">'
                      + '<div class="cal-upcoming-dot" style="background:#3B82F6;"></div>'
                      + '<div class="cal-upcoming-info">'
                      + '<div class="cal-upcoming-title">' + evt.title + '</div>'
                      + '<div class="cal-upcoming-date"><i class="fa fa-calendar-o" style="margin-right:4px;"></i>' + fmtDate(evt.start)
                      + (evt.end ? ' → ' + fmtDate(evt.end) : '') + '</div>'
                      + '</div></div>';
            });
            $list.html(html);
        }
    }

    /* ── Mise à jour des stats ── */
    function updateStats() {
        var todayStr = moment().format('YYYY-MM-DD');
        var total = ALL_EVENTS.length;
        var up = 0, past = 0;
        ALL_EVENTS.forEach(function(e) {
            if (e.start >= todayStr) up++; else past++;
        });
        $('#statTotal').text(total);
        $('#statUpcoming').text(up);
        $('#statPast').text(past);
    }

    /* ── Merge events into ALL_EVENTS (deduplicate by id) ── */
    function mergeEvents(newEvents) {
        newEvents.forEach(function(ne) {
            var found = false;
            for (var i = 0; i < ALL_EVENTS.length; i++) {
                if (ALL_EVENTS[i].id === ne.id) {
                    ALL_EVENTS[i] = ne;
                    found = true;
                    break;
                }
            }
            if (!found) ALL_EVENTS.push(ne);
        });
    }

    /* ── Init FullCalendar avec chargement AJAX ── */
    $('#fullCalendar').fullCalendar({
        lang: 'fr',
        header: {
            left:   'prev,next today',
            center: 'title',
            right:  'month,agendaWeek,agendaDay'
        },
        buttonText: {
            today: "Aujourd'hui",
            month: 'Mois',
            week:  'Semaine',
            day:   'Jour'
        },
        editable: false,
        eventLimit: 3,
        fixedWeekCount: false,
        height: 'auto',
        lazyFetching: true,
        events: function(start, end, timezone, callback) {
            $.ajax({
                url: CTX + '/pages/evenement/ajax/liste-json.jsp',
                data: {
                    start: start.format('YYYY-MM-DD'),
                    end:   end.format('YYYY-MM-DD')
                },
                dataType: 'json',
                success: function(data) {
                    EVENTS = data || [];
                    mergeEvents(EVENTS);
                    updateStats();
                    updateSidePanel();
                    callback(EVENTS);
                },
                error: function() {
                    callback([]);
                }
            });
        },
        eventClick: function(evt) {
            openModal(evt);
        },
        eventRender: function(event, element) {
            element.attr('title', event.title);
        }
    });

    /* Click on upcoming item → open modal */
    $('#upcomingList').on('click', '.cal-upcoming-item', function() {
        var id = $(this).data('id');
        var evt = null;
        for (var i = 0; i < ALL_EVENTS.length; i++) {
            if (ALL_EVENTS[i].id === id) { evt = ALL_EVENTS[i]; break; }
        }
        if (evt) openModal(evt);
    });

    /* ── Event Detail Modal ── */
    var $modal = $('#evtModal');

    function openModal(evt) {
        currentEventId = evt.id || '';
        $('#evtModalTitle').text(evt.title || '\u2014');
        $('#evtModalId').html('<i class="fa fa-hashtag" style="margin-right:3px;"></i>' + (evt.id || ''));
        $('#evtModalStart').text(fmtDate(evt.start ? (evt.start.format ? evt.start.format('YYYY-MM-DD') : evt.start) : null));
        $('#evtModalEnd').text(fmtDate(evt.end ? (evt.end.format ? evt.end.format('YYYY-MM-DD') : evt.end) : null));
        $('#evtModalDaty').text(fmtDate(evt.daty || null));

        /* Afficher l'état de participation */
        $('#evtModalNbParticipants').text(evt.nbParticipants || 0);
        if (evt.participating) {
            $('#evtModalParticiper').hide();
            $('#evtModalAnnuler').css('display', 'inline-flex');
        } else {
            $('#evtModalParticiper').show();
            $('#evtModalAnnuler').hide();
        }

        if (evt.color) {
            $('#evtModalBanner').css('background', '#1E40AF');
        }
        $modal.fadeIn(200);
    }

    /* ── Helper: find event in ALL_EVENTS by id ── */
    function findEvent(id) {
        for (var i = 0; i < ALL_EVENTS.length; i++) {
            if (ALL_EVENTS[i].id === id) return ALL_EVENTS[i];
        }
        return null;
    }

    /* ── Participer ── */
    window.participerEvenement = function() {
        if (!currentEventId) return;
        var $btn = $('#evtModalParticiper');
        $btn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> En cours...');

        fetch(CTX + '/pages/evenement/ajax/traitement-participer.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'idevenement=' + encodeURIComponent(currentEventId)
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                var evt = findEvent(currentEventId);
                if (evt) {
                    evt.participating = true;
                    evt.nbParticipants = (evt.nbParticipants || 0) + 1;
                    $('#evtModalNbParticipants').text(evt.nbParticipants);
                }
                $btn.hide();
                $('#evtModalAnnuler').css('display', 'inline-flex');
            } else {
                alert(data.error || 'Erreur lors de la participation');
            }
            $btn.prop('disabled', false).html('<i class="fa fa-check-circle"></i> Participer');
        })
        .catch(function() {
            alert('Erreur de connexion');
            $btn.prop('disabled', false).html('<i class="fa fa-check-circle"></i> Participer');
        });
    };

    /* ── Annuler participation ── */
    window.annulerParticipation = function() {
        if (!currentEventId) return;
        if (!confirm('\u00cates-vous s\u00fbr de vouloir annuler votre participation ?')) return;

        var $btn = $('#evtModalAnnuler');
        $btn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> En cours...');

        fetch(CTX + '/pages/evenement/ajax/traitement-annuler.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'idevenement=' + encodeURIComponent(currentEventId)
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                var evt = findEvent(currentEventId);
                if (evt) {
                    evt.participating = false;
                    evt.nbParticipants = Math.max(0, (evt.nbParticipants || 1) - 1);
                    $('#evtModalNbParticipants').text(evt.nbParticipants);
                }
                $btn.hide();
                $('#evtModalParticiper').show();
            } else {
                alert(data.error || "Erreur lors de l'annulation");
            }
            $btn.prop('disabled', false).html('<i class="fa fa-times-circle"></i> Annuler ma participation');
        })
        .catch(function() {
            alert('Erreur de connexion');
            $btn.prop('disabled', false).html('<i class="fa fa-times-circle"></i> Annuler ma participation');
        });
    };

    $('#evtModalClose').on('click', function() { $modal.fadeOut(150); });
    $modal.on('click', function(e) { if (e.target === this) $modal.fadeOut(150); });

    /* Simple color lightener */
    function adjustColor(hex, amt) {
        hex = hex.replace('#', '');
        var r = Math.min(255, parseInt(hex.substring(0,2), 16) + amt);
        var g = Math.min(255, parseInt(hex.substring(2,4), 16) + amt);
        var b = Math.min(255, parseInt(hex.substring(4,6), 16) + amt);
        return '#' + ((1<<24)+(r<<16)+(g<<8)+b).toString(16).slice(1);
    }

})(jQuery);
</script>
