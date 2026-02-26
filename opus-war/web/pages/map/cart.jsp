<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="alumni.Parcours" %>
<%@ page import="alumni.Promotion" %>
<%@ page import="bean.CGenUtil" %>
<%
    String currentContext = request.getContextPath();
    String currentUserName = "Visiteur";
    try {
        UserEJB userEjb = (UserEJB) session.getAttribute("u");
        if (userEjb != null && userEjb.getUser() != null) {
            currentUserName = userEjb.getUser().getLoginuser();
        }
    } catch (Exception e) {
    }

    // Charger les listes pour les filtres
    Specialite[] mapSpecialites = null;
    Parcours[] mapParcours = null;
    Promotion[] mapPromotions = null;
    try {
        mapSpecialites = (Specialite[]) CGenUtil.rechercher(new Specialite(), null, null, " order by libelle");
        mapParcours    = (Parcours[])   CGenUtil.rechercher(new Parcours(), null, null, " order by libelle");
        mapPromotions  = (Promotion[])  CGenUtil.rechercher(new Promotion(), null, null, " order by annee desc");
    } catch (Exception e) { e.printStackTrace(); }
    if (mapSpecialites == null) mapSpecialites = new Specialite[0];
    if (mapParcours == null)    mapParcours    = new Parcours[0];
    if (mapPromotions == null)  mapPromotions  = new Promotion[0];
%>
<!-- CSS remains static -->
<link rel="stylesheet" href="elements/libs/leaflet.css">
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css">
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
<style>
    @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');
    :root { --primary: #0a66c2; --primary-dark: #004182; --card-bg: #ffffff; --text-main: #0f172a; --text-muted: #64748b; --sidebar-w: 340px; --border: #e2e8f0; --bg-subtle: #f8fafc; }

    .opus-full-container {
        font-family: 'Plus Jakarta Sans', sans-serif;
        width: 100%; height: calc(100vh - 60px);
        display: flex; box-sizing: border-box;
        position: relative; overflow: hidden;
    }

    /* ===== LEFT: MAP ===== */
    .map-area {
        flex: 1; position: relative; height: 100%;
    }
    #map { width: 100%; height: 100%; z-index: 1; }

    /* Floating map overlay badge */
    .map-overlay-badge {
        position: absolute; top: 16px; left: 16px; z-index: 1000;
        display: flex; align-items: center; gap: 10px;
        background: rgba(255,255,255,0.92); backdrop-filter: blur(12px);
        padding: 10px 18px; border-radius: 14px;
        box-shadow: 0 4px 24px rgba(0,0,0,0.10);
        border: 1px solid rgba(226,232,240,0.6);
    }
    .map-overlay-badge .badge-icon {
        width: 36px; height: 36px; background: linear-gradient(135deg, var(--primary), var(--primary-dark));
        border-radius: 10px; display: flex; align-items: center; justify-content: center; color: white; font-size: 16px;
    }
    .map-overlay-badge h2 { margin: 0; font-size: 15px; font-weight: 800; color: var(--text-main); }
    .map-overlay-badge span { font-size: 11px; color: var(--text-muted); font-weight: 500; }

    /* Floating quick-nav chips */
    .map-quick-nav {
        position: absolute; bottom: 20px; left: 50%; transform: translateX(-50%); z-index: 1000;
        display: flex; gap: 6px; padding: 6px;
        background: rgba(255,255,255,0.92); backdrop-filter: blur(12px);
        border-radius: 14px; box-shadow: 0 4px 20px rgba(0,0,0,0.10);
        border: 1px solid rgba(226,232,240,0.5);
    }
    .chip {
        padding: 7px 16px; border-radius: 10px; background: transparent;
        border: none; font-size: 11px; font-weight: 700; cursor: pointer;
        color: var(--text-muted); transition: all 0.2s; white-space: nowrap;
    }
    .chip:hover { background: #f1f5f9; color: var(--text-main); }
    .chip.active { background: var(--primary); color: white; box-shadow: 0 2px 8px rgba(10,102,194,0.3); }

    /* ===== RIGHT: SIDEBAR ===== */
    .map-sidebar {
        width: var(--sidebar-w); height: 100%; background: var(--card-bg);
        border-left: 1px solid var(--border);
        display: flex; flex-direction: column;
        box-shadow: -4px 0 24px rgba(0,0,0,0.04);
        overflow-y: auto; flex-shrink: 0;
    }

    /* Sidebar header */
    .sidebar-header {
        padding: 22px 22px 18px; border-bottom: 1px solid var(--border);
        display: flex; justify-content: space-between; align-items: center;
    }
    .sidebar-header h3 { margin: 0; font-size: 14px; font-weight: 800; color: var(--text-main); }
    .user-pill {
        display: flex; align-items: center; gap: 8px;
        padding: 5px 10px 5px 5px; background: var(--bg-subtle);
        border-radius: 10px; border: 1px solid var(--border);
    }
    .user-pill span { font-size: 11px; font-weight: 700; color: var(--text-main); }

    /* Sidebar section */
    .sidebar-section {
        padding: 18px 22px; border-bottom: 1px solid #f1f5f9;
    }
    .sidebar-section-title {
        font-size: 10px; font-weight: 800; text-transform: uppercase;
        letter-spacing: 1.2px; color: var(--text-muted); margin-bottom: 14px;
        display: flex; align-items: center; gap: 6px;
    }
    .sidebar-section-title i { font-size: 13px; }

    /* Filter groups */
    .mf-group { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; }
    .mf-group:last-child { margin-bottom: 0; }
    .mf-label { font-size: 11px; font-weight: 700; color: var(--text-main); display: flex; align-items: center; gap: 5px; }
    .mf-label i { color: var(--primary); font-size: 13px; }
    .mf-select {
        font-family: inherit; font-size: 12px; font-weight: 600; padding: 10px 32px 10px 12px;
        border: 1.5px solid var(--border); border-radius: 10px; background: var(--bg-subtle); color: var(--text-main);
        cursor: pointer; outline: none; transition: all .2s; width: 100%;
        appearance: none; -webkit-appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%2364748b'/%3E%3C/svg%3E");
        background-repeat: no-repeat; background-position: right 12px center; background-size: 10px 6px;
    }
    .mf-select:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(10,102,194,0.08); }
    .mf-input {
        font-family: inherit; font-size: 12px; font-weight: 600; padding: 10px 12px;
        border: 1.5px solid var(--border); border-radius: 10px; background: var(--bg-subtle); color: var(--text-main);
        outline: none; width: 100%; box-sizing: border-box; transition: all .2s;
    }
    .mf-input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(10,102,194,0.08); }
    .mf-input::placeholder { color: #94a3b8; font-weight: 500; }

    /* Toggle / checkbox */
    .mf-check { display: flex; align-items: center; gap: 8px; cursor: pointer; padding: 10px 0; }
    .mf-check input { accent-color: var(--primary); width: 16px; height: 16px; cursor: pointer; }
    .mf-check span { font-size: 12px; font-weight: 600; color: var(--text-main); }

    /* Buttons */
    .mf-btn-reset {
        width: 100%; padding: 10px; border-radius: 10px; border: 1.5px solid var(--border); background: white;
        font-size: 12px; font-weight: 700; color: var(--text-muted); cursor: pointer; transition: all .2s;
        display: flex; align-items: center; justify-content: center; gap: 6px;
    }
    .mf-btn-reset:hover { border-color: #ef4444; color: #ef4444; background: #fef2f2; }

    /* Count badge */
    .mf-count-bar {
        padding: 14px 22px; background: linear-gradient(135deg, var(--primary), var(--primary-dark));
        display: flex; align-items: center; justify-content: space-between;
    }
    .mf-count-bar span { color: rgba(255,255,255,0.8); font-size: 12px; font-weight: 600; }
    .mf-badge {
        display: inline-flex; align-items: center; justify-content: center; min-width: 28px; height: 28px;
        border-radius: 8px; background: rgba(255,255,255,0.2); color: white; font-size: 14px; font-weight: 800;
        padding: 0 8px; backdrop-filter: blur(4px);
    }

    /* View mode */
    .view-modes { display: flex; background: #f1f5f9; padding: 4px; border-radius: 10px; width: 100%; }
    .mode-btn {
        flex: 1; padding: 9px 0; border-radius: 8px; border: none; background: transparent;
        font-size: 11px; font-weight: 700; cursor: pointer; color: var(--text-muted); transition: all 0.2s;
        display: flex; align-items: center; justify-content: center; gap: 5px;
    }
    .mode-btn.active { background: white; color: var(--primary); box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
    .mode-btn i { font-size: 13px; }

    /* Marker styles */
    .alumni-marker-icon { border-radius: 50%; border: 2px solid white; box-shadow: 0 4px 12px rgba(0,0,0,0.15); object-fit: cover; background: #fff; }
    .alumni-initials { width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; font-size: 13px; border: 2px solid white; }
    .alumni-tooltip { background: white; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 10px 15px rgba(0,0,0,0.1); padding: 8px 12px; }

    /* Sidebar toggle button (for mobile) */
    .sidebar-toggle {
        display: none; position: absolute; top: 16px; right: 16px; z-index: 1001;
        width: 40px; height: 40px; border-radius: 10px; border: none;
        background: rgba(255,255,255,0.92); backdrop-filter: blur(12px);
        box-shadow: 0 4px 16px rgba(0,0,0,0.10); cursor: pointer;
        font-size: 18px; color: var(--text-main);
        display: flex; align-items: center; justify-content: center;
    }

    /* Responsive */
    @media (max-width: 900px) {
        .opus-full-container { flex-direction: column; height: auto; }
        .map-area { height: 50vh; min-height: 350px; }
        .map-sidebar { width: 100%; height: auto; border-left: none; border-top: 1px solid var(--border); }
    }
</style>
<div class="opus-full-container" id="opusMapContainer">
    <!-- LEFT: CARTE PLEIN ECRAN -->
    <div class="map-area">
        <div id="map"></div>

        <!-- Badge flottant en haut a gauche -->
        <div class="map-overlay-badge">
            <div class="badge-icon"><i class="bi bi-geo-alt-fill"></i></div>
            <div>
                <h2>Alumni Map Explorer</h2>
                <span>Communaut&eacute; IT University</span>
            </div>
        </div>

        <!-- Navigation rapide en bas -->
        <div class="map-quick-nav">
            <button class="chip active" onclick="goto('Monde', [10, 20], 2, this)">Monde</button>
            <button class="chip" onclick="goto('Africa', [8.78, 34.5], 3, this)">Afrique</button>
            <button class="chip" onclick="goto('Americas', [18.28, -77.33], 3, this)">Am&eacute;riques</button>
            <button class="chip" onclick="goto('Asia', [34.04, 100.61], 3, this)">Asie</button>
            <button class="chip" onclick="goto('Europe', [54.52, 15.25], 4, this)">Europe</button>
            <button class="chip" onclick="goto('Oceania', [-25.27, 133.77], 4, this)">Oc&eacute;anie</button>
            <button class="chip" onclick="goto('Mada', [-18.766, 46.869], 6, this)">Madagascar</button>
            <button class="chip" onclick="goto('Tana', [-18.879, 47.507], 12, this)">Tana</button>
        </div>
    </div>

    <!-- RIGHT: PANNEAU PARAMETRAGE -->
    <div class="map-sidebar">
        <!-- Compteur alumni -->
        <div class="mf-count-bar">
            <span><i class="bi bi-people-fill"></i>&nbsp; Alumni affich&eacute;s</span>
            <span class="mf-badge" id="mf-count" title="Nombre de personnes affich&eacute;es">0</span>
        </div>

        <!-- En-tete sidebar -->
        <div class="sidebar-header">
            <h3><i class="bi bi-sliders" style="color:var(--primary); margin-right:6px;"></i>Param&egrave;tres</h3>
            <div class="user-pill">
                <div class="alumni-initials" style="width:26px; height:26px; font-size:10px; background: linear-gradient(135deg, var(--primary), var(--primary-dark));"><%
    if(currentUserName != null && currentUserName.length() > 0) out.print(currentUserName.substring(0,1).toUpperCase());
    else out.print("U");
%></div>
                <span><% out.print(currentUserName); %></span>
            </div>
        </div>

        <!-- Section: Mode d'affichage -->
        <div class="sidebar-section">
            <div class="sidebar-section-title"><i class="bi bi-eye"></i> Mode d'affichage</div>
            <div class="view-modes">
                <button class="mode-btn active" id="btn-cluster" onclick="switchMode('cluster')"><i class="bi bi-diagram-3"></i> Regrouper</button>
                <button class="mode-btn" id="btn-individual" onclick="switchMode('individual')"><i class="bi bi-pin-map"></i> Un par un</button>
            </div>
        </div>

        <!-- Section: Filtres -->
        <div class="sidebar-section" id="mapFilterRow">
            <div class="sidebar-section-title"><i class="bi bi-funnel"></i> Filtres</div>

            <div class="mf-group">
                <label class="mf-label"><i class="bi bi-mortarboard"></i> Sp&eacute;cialit&eacute;</label>
                <select class="mf-select" id="mf-spec" onchange="applyMapFilters()">
                    <option value="">Toutes les sp&eacute;cialit&eacute;s</option>
                    <% for (int si = 0; si < mapSpecialites.length; si++) { %>
                    <option value="<%= mapSpecialites[si].getLibelle() %>"><%= mapSpecialites[si].getLibelle() %></option>
                    <% } %>
                </select>
            </div>

            <div class="mf-group">
                <label class="mf-label"><i class="bi bi-signpost-2"></i> Parcours</label>
                <select class="mf-select" id="mf-parc" onchange="applyMapFilters()">
                    <option value="">Tous les parcours</option>
                    <% for (int pi = 0; pi < mapParcours.length; pi++) { %>
                    <option value="<%= mapParcours[pi].getLibelle() %>"><%= mapParcours[pi].getLibelle() %></option>
                    <% } %>
                </select>
            </div>

            <div class="mf-group">
                <label class="mf-label"><i class="bi bi-calendar-event"></i> Promotion</label>
                <input type="text" class="mf-input" id="mf-promo" placeholder="ex: 2023 ou 2023+ ou 2023-" maxlength="6"
                       oninput="applyMapFilters()" title="Entrez une ann&eacute;e. Ajoutez + pour &ge; ou - pour &le;">
            </div>

            <label class="mf-check">
                <input type="checkbox" id="mf-lier" onchange="applyMapFilters()">
                <span>Combiner les crit&egrave;res (ET)</span>
            </label>
        </div>

        <!-- Section: Actions -->
        <div class="sidebar-section">
            <button class="mf-btn-reset" onclick="resetMapFilters()" title="R&eacute;initialiser les filtres">
                <i class="bi bi-arrow-counterclockwise"></i> R&eacute;initialiser les filtres
            </button>
        </div>
    </div>
</div>
<!-- Using relative paths to avoid JSP Expression Language contamination -->
<script src="elements/libs/leaflet-src.js"></script>
<script src="https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js"></script>
<script>
    (function() {
        var map, clusterLayer, individualLayer;
        var allData = [];   // full alumni array from AJAX
        var allMarkers = []; // parallel array of L.Marker
        var currentMode = 'cluster';
        var colors = ['#0a66c2', '#059669', '#7c3aed', '#db2777', '#ea580c', '#2563eb'];

        function getAvatarColor(str) {
            var hash = 0;
            if(!str) return colors[0];
            for(var i=0; i<str.length; i++) {
                hash = str.charCodeAt(i) + ((hash << 5) - hash);
            }
            return colors[Math.abs(hash) % colors.length];
        }

        function createMarker(a) {
            var c = getAvatarColor(a.id);
            var h = a.img
                ? '<img src="' + a.img + '" class="alumni-marker-icon" style="width:32px;height:32px;">'
                : '<div class="alumni-initials" style="background:' + c + '">' + a.init + '</div>';
            var icon = L.divIcon({ html: h, className: '', iconSize: [32, 32] });
            var ttHtml = '<b>' + a.p + ' ' + a.n + '</b>';
            if (a.parcours) ttHtml += '<br><span style="font-size:11px;color:#64748b;">' + a.parcours + '</span>';
            if (a.promo)    ttHtml += '<br><span style="font-size:11px;color:#64748b;">' + a.promo + '</span>';
            var marker = L.marker(a.pos, { icon: icon }).bindTooltip(ttHtml, { sticky: true, className: 'alumni-tooltip' });
            marker.on('click', function() { window.location.href = 'module.jsp?but=annuaire/fiche-utilisateur.jsp&idprofil=' + a.id; });
            return marker;
        }

        function initMap(data) {
            if (typeof L === 'undefined') return;
            allData = data;
            map = L.map('map', { zoomControl: false }).setView([-18.879, 47.507], 6);
            L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', { maxZoom: 19 }).addTo(map);
            L.control.zoom({ position: 'bottomright' }).addTo(map);

            individualLayer = L.layerGroup();
            clusterLayer = (typeof L.markerClusterGroup !== 'undefined') ? L.markerClusterGroup() : L.layerGroup();

            data.forEach(function(a) {
                var marker = createMarker(a);
                allMarkers.push(marker);
                individualLayer.addLayer(marker);
                clusterLayer.addLayer(marker);
            });
            map.addLayer(clusterLayer);
            document.getElementById('mf-count').textContent = data.length;
        }

        // ============ FILTER LOGIC ============
        function parsePromoFilter(val) {
            if (!val) return null;
            val = val.trim();
            var dir = null;
            if (val.endsWith('+')) { dir = 'gte'; val = val.slice(0,-1); }
            else if (val.endsWith('-')) { dir = 'lte'; val = val.slice(0,-1); }
            var y = parseInt(val);
            if (isNaN(y)) return null;
            return { year: y, dir: dir };
        }

        function matchesFilter(a, specVal, parcVal, promoObj, lier) {
            var results = [];

            if (specVal) {
                var ok = false;
                if (a.specs && a.specs.length > 0) {
                    for (var si = 0; si < a.specs.length; si++) {
                        if (a.specs[si] === specVal) { ok = true; break; }
                    }
                }
                results.push(ok);
            }

            if (parcVal) {
                results.push(a.parcours === parcVal);
            }

            if (promoObj) {
                var pa = a.promoAnnee || 0;
                if (promoObj.dir === 'gte') results.push(pa >= promoObj.year);
                else if (promoObj.dir === 'lte') results.push(pa <= promoObj.year);
                else results.push(pa === promoObj.year);
            }

            if (results.length === 0) return true;
            if (lier) {
                // AND: all must be true
                for (var ri = 0; ri < results.length; ri++) { if (!results[ri]) return false; }
                return true;
            } else {
                // OR: at least one true
                for (var ri = 0; ri < results.length; ri++) { if (results[ri]) return true; }
                return false;
            }
        }

        window.applyMapFilters = function() {
            var specVal  = document.getElementById('mf-spec').value;
            var parcVal  = document.getElementById('mf-parc').value;
            var promoVal = document.getElementById('mf-promo').value;
            var lier     = document.getElementById('mf-lier').checked;
            var promoObj = parsePromoFilter(promoVal);
            var hasFilter = specVal || parcVal || promoObj;

            // Remove all current markers
            clusterLayer.clearLayers();
            individualLayer.clearLayers();

            var count = 0;
            for (var i = 0; i < allData.length; i++) {
                if (!hasFilter || matchesFilter(allData[i], specVal, parcVal, promoObj, lier)) {
                    clusterLayer.addLayer(allMarkers[i]);
                    individualLayer.addLayer(allMarkers[i]);
                    count++;
                }
            }
            document.getElementById('mf-count').textContent = count;
        };

        window.resetMapFilters = function() {
            document.getElementById('mf-spec').value = '';
            document.getElementById('mf-parc').value = '';
            document.getElementById('mf-promo').value = '';
            document.getElementById('mf-lier').checked = false;
            applyMapFilters();
        };

        window.switchMode = function(m) {
            currentMode = m;
            document.getElementById('btn-cluster').classList.toggle('active', m === 'cluster');
            document.getElementById('btn-individual').classList.toggle('active', m === 'individual');
            if (m === 'cluster') { map.removeLayer(individualLayer); map.addLayer(clusterLayer); }
            else { map.removeLayer(clusterLayer); map.addLayer(individualLayer); }
        };

        window.goto = function(n, c, z, b) {
            map.flyTo(c, z);
            document.querySelectorAll('.chip').forEach(function(x){ x.classList.remove('active'); });
            b.classList.add('active');
        };

        // Use a clean relative path for AJAX too
        fetch('map/ajax/get-alumni.jsp').then(function(r){return r.json();}).then(initMap).catch(function(e){console.error(e);});
    })();
</script>
