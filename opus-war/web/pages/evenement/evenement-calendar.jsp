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
<style>
/* ── STATS STRIP ── */
.cal-stats-strip {
    display: flex;
    gap: 1rem;
    margin: 1rem 0 1.25rem;
    flex-wrap: wrap;
}
.cal-stat-chip {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    background: var(--white);
    border: 1px solid var(--gray-200);
    border-radius: 12px;
    padding: 0.7rem 1.2rem;
    box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    min-width: 130px;
}
.cal-stat-icon {
    width: 38px; height: 38px;
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    color: #fff; font-size: 0.9rem;
}
.cal-stat-text { display: flex; flex-direction: column; }
.cal-stat-val { font-size: 1.25rem; font-weight: 800; color: var(--itu-dark); line-height: 1.2; }
.cal-stat-label { font-size: 0.72rem; color: var(--gray-500); text-transform: uppercase; letter-spacing: 0.06em; font-weight: 600; }

/* ── LAYOUT ── */
.cal-layout {
    display: grid;
    grid-template-columns: 1fr 380px;
    gap: 1.5rem;
    align-items: start;
}
@media (max-width: 960px) {
    .cal-layout { grid-template-columns: 1fr; }
}
.cal-main-card {
    padding: 2rem !important;
    overflow: hidden;
}

/* ── SIDE PANEL ── */
.cal-side-panel {
    background: var(--white);
    border: 1px solid var(--gray-200);
    border-radius: 14px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    overflow: hidden;
}
.cal-side-header {
    padding: 1rem 1.15rem;
    font-size: 0.82rem;
    font-weight: 700;
    color: var(--itu-dark);
    border-bottom: 1px solid var(--gray-100);
    text-transform: uppercase;
    letter-spacing: 0.04em;
}
.cal-upcoming-list {
    max-height: 480px;
    overflow-y: auto;
    padding: 0.5rem 0;
}
.cal-upcoming-item {
    display: flex;
    align-items: flex-start;
    gap: 0.7rem;
    padding: 0.7rem 1.15rem;
    cursor: pointer;
    transition: background .15s;
    border-left: 3px solid transparent;
}
.cal-upcoming-item:hover {
    background: #EFF6FF;
    border-left-color: #1E40AF;
}
.cal-upcoming-dot {
    width: 10px; height: 10px;
    border-radius: 50%;
    margin-top: 5px;
    flex-shrink: 0;
}
.cal-upcoming-info { flex: 1; min-width: 0; }
.cal-upcoming-title {
    font-size: 0.84rem;
    font-weight: 600;
    color: var(--itu-dark);
    line-height: 1.35;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.cal-upcoming-date {
    font-size: 0.72rem;
    color: var(--gray-400);
    margin-top: 2px;
}
.cal-upcoming-empty {
    text-align: center;
    padding: 2rem 1rem;
    color: var(--gray-400);
    font-size: 0.85rem;
}

/* ── FULLCALENDAR OVERRIDES (Pro Max) ── */
#fullCalendar .fc-toolbar {
    margin-bottom: 1.5rem !important;
}
#fullCalendar .fc-toolbar h2 {
    font-size: 1.15rem !important;
    font-weight: 700 !important;
    color: var(--itu-dark) !important;
    text-transform: capitalize;
}
#fullCalendar .fc-button {
    background: var(--white) !important;
    border: 1.5px solid var(--gray-200) !important;
    color: var(--gray-600) !important;
    border-radius: 8px !important;
    padding: 0.4rem 0.85rem !important;
    font-size: 0.82rem !important;
    font-weight: 600 !important;
    text-transform: capitalize !important;
    box-shadow: none !important;
    transition: all .15s ease !important;
    outline: none !important;
}
#fullCalendar .fc-button:hover {
    background: #EFF6FF !important;
    border-color: #3B82F6 !important;
    color: #1E40AF !important;
}
#fullCalendar .fc-button.fc-state-active,
#fullCalendar .fc-state-active {
    background: #1E40AF !important;
    border-color: #1E40AF !important;
    color: #fff !important;
}
#fullCalendar .fc-button-group .fc-button {
    border-radius: 0 !important;
    margin-left: -1px;
}
#fullCalendar .fc-button-group .fc-button:first-child { border-radius: 8px 0 0 8px !important; }
#fullCalendar .fc-button-group .fc-button:last-child  { border-radius: 0 8px 8px 0 !important; }
#fullCalendar .fc-prev-button,
#fullCalendar .fc-next-button {
    border-radius: 8px !important;
    width: 36px;
    padding: 0.4rem 0 !important;
    text-align: center;
}

/* Table heads */
#fullCalendar th {
    font-size: 0.72rem !important;
    font-weight: 700 !important;
    text-transform: uppercase !important;
    letter-spacing: 0.06em !important;
    color: var(--gray-500) !important;
    padding: 0.6rem 0 !important;
    border-color: var(--gray-100) !important;
    background: transparent !important;
}
#fullCalendar td {
    border-color: var(--gray-100) !important;
}
#fullCalendar .fc-today {
    background: rgba(30,64,175,0.04) !important;
}
#fullCalendar .fc-day-number {
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--gray-600);
    padding: 6px 8px !important;
}
#fullCalendar .fc-today .fc-day-number {
    background: #1E40AF;
    color: #fff;
    border-radius: 50%;
    width: 28px;
    height: 28px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    line-height: 1;
}
#fullCalendar .fc-other-month .fc-day-number {
    color: var(--gray-300);
}

/* Events */
#fullCalendar .fc-event {
    border: none !important;
    border-radius: 6px !important;
    padding: 2px 7px !important;
    font-size: 0.76rem !important;
    font-weight: 600 !important;
    cursor: pointer !important;
    transition: transform .12s, box-shadow .12s !important;
    margin-bottom: 2px !important;
    line-height: 1.5 !important;
    background: #1E40AF !important;
    color: #fff !important;
}
#fullCalendar .fc-event-inner {
    background: transparent !important;
    color: #fff !important;
}
#fullCalendar .fc-event.fc-bg {
    background: rgba(30,64,175,0.06) !important;
}
#fullCalendar .fc-event:hover {
    transform: translateY(-1px);
    box-shadow: 0 3px 12px rgba(30,64,175,0.25);
}
#fullCalendar .fc-day-grid-event .fc-content {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

/* Week / Day views */
#fullCalendar .fc-time-grid .fc-event {
    border-radius: 8px !important;
    padding: 4px 8px !important;
}
#fullCalendar .fc-unthemed .fc-divider,
#fullCalendar .fc-unthemed .fc-popover .fc-header {
    background: var(--gray-50, #f9fafb);
}

/* ── EVENT MODAL ── */
.evt-modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.45);
    backdrop-filter: blur(4px);
    z-index: 9999;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 1.5rem;
    animation: evtFadeIn .2s ease;
}
@keyframes evtFadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}
.evt-modal-card {
    background: var(--white);
    border-radius: 18px;
    width: 100%;
    max-width: 460px;
    box-shadow: 0 20px 60px rgba(0,0,0,0.2);
    overflow: hidden;
    animation: evtSlideUp .25s ease;
}
@keyframes evtSlideUp {
    from { opacity: 0; transform: translateY(30px) scale(0.97); }
    to   { opacity: 1; transform: translateY(0) scale(1); }
}
.evt-modal-banner {
    height: 90px;
    background: #1E40AF;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
}
.evt-modal-banner-icon {
    width: 50px; height: 50px;
    background: rgba(255,255,255,0.2);
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.3rem; color: #fff;
}
.evt-modal-close {
    position: absolute;
    top: 10px; right: 14px;
    background: rgba(255,255,255,0.2);
    border: none;
    color: #fff;
    font-size: 1.5rem;
    width: 34px; height: 34px;
    border-radius: 50%;
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: background .15s;
    line-height: 1;
}
.evt-modal-close:hover { background: rgba(255,255,255,0.4); }
.evt-modal-body { padding: 1.5rem 1.75rem 1.75rem; }
.evt-modal-title {
    font-size: 1.15rem;
    font-weight: 700;
    color: var(--itu-dark);
    margin: 0 0 0.25rem;
    line-height: 1.35;
}
.evt-modal-id {
    font-size: 0.72rem;
    color: var(--gray-400);
    margin-bottom: 1.25rem;
}
.evt-modal-dates {
    display: flex;
    flex-direction: column;
    gap: 0.65rem;
    margin-bottom: 1.5rem;
}
.evt-modal-date-item {
    display: flex;
    align-items: center;
    gap: 0.75rem;
}
.evt-modal-date-icon {
    width: 36px; height: 36px;
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    font-size: 0.8rem;
    flex-shrink: 0;
}
.evt-modal-date-label {
    font-size: 0.68rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--gray-400);
}
.evt-modal-date-val {
    font-size: 0.9rem;
    font-weight: 600;
    color: var(--itu-dark);
}
.evt-modal-actions {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
}
.evt-modal-actions .btn {
    font-size: 0.85rem;
    padding: 0.55rem 1rem;
}
</style>

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
