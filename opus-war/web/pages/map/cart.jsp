<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
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

%>
<!-- CSS remains static -->
<link rel="stylesheet" href="elements/libs/leaflet.css">
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css">
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
<style>
    @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');
    :root { --primary: #0a66c2; --card-bg: #ffffff; --text-main: #0f172a; --text-muted: #64748b; }
    .opus-full-container { font-family: 'Plus Jakarta Sans', sans-serif; padding: 10px; width: 100%; box-sizing: border-box; }
    .main-map-card { background: var(--card-bg); border-radius: 20px; box-shadow: 0 10px 40px rgba(0,0,0,0.08); border: 1px solid #e2e8f0; overflow: hidden; display: flex; flex-direction: column; width: 100%; min-height: 600px; }
    .map-nav { padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #f1f5f9; background: #fff; flex-shrink: 0; }
    .user-pill { display: flex; align-items: center; gap: 10px; padding: 6px 12px; background: #f8fafc; border-radius: 12px; border: 1px solid #e2e8f0; }
    .filter-section { padding: 12px 30px; background: #fafbfc; display: flex; align-items: center; gap: 20px; border-bottom: 1px solid #f1f5f9; flex-wrap: wrap; flex-shrink: 0; }
    .view-modes { display: flex; background: #e2e8f0; padding: 3px; border-radius: 8px; }
    .mode-btn { padding: 6px 14px; border-radius: 6px; border: none; background: transparent; font-size: 11px; font-weight: 700; cursor: pointer; color: #64748b; transition: all 0.2s; }
    .mode-btn.active { background: white; color: var(--primary); box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
    .chip { padding: 6px 14px; border-radius: 20px; background: white; border: 1px solid #cbd5e1; font-size: 11px; font-weight: 600; cursor: pointer; transition: 0.2s; }
    .chip.active { border-color: var(--primary); color: var(--primary); background: #f0f7ff; }
    .map-body { position: relative; width: 100%; flex-grow: 1; height: 550px; }
    #map { width: 100%; height: 100%; z-index: 1; }
    .alumni-marker-icon { border-radius: 50%; border: 2px solid white; box-shadow: 0 4px 12px rgba(0,0,0,0.15); object-fit: cover; background: #fff; }
    .alumni-initials { width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; font-size: 13px; border: 2px solid white; }
    .alumni-tooltip { background: white; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 10px 15px rgba(0,0,0,0.1); padding: 8px 12px; }
</style>
<div class="opus-full-container" id="opusMapContainer">
    <div class="main-map-card">
        <div class="map-nav">
            <div style="display:flex; align-items:center; gap:12px;">
                <div style="width:40px; height:40px; background:var(--primary); border-radius:10px; display:flex; align-items:center; justify-content:center; color:white;"><i class="bi bi-geo-alt-fill"></i></div>
                <div><h2 style="margin:0; font-size:18px; font-weight:800;">Alumni Map Explorer</h2><span style="font-size:11px; color:#888;">Retrouvez la communauté IT University </span></div>
            </div>
            <div class="user-pill">
                <div class="alumni-initials" style="width:30px; height:30px; font-size:11px; background-color:var(--primary);"><%
    if(currentUserName != null && currentUserName.length() > 0) out.print(currentUserName.substring(0,1).toUpperCase());
    else out.print("U");

%></div>
                <span style="font-size:12px; font-weight:700;"><% out.print(currentUserName); %></span>
            </div>
        </div>
        <div class="filter-section">
            <div class="view-modes">
                <button class="mode-btn active" id="btn-cluster" onclick="switchMode('cluster')">Regrouper</button>
                <button class="mode-btn" id="btn-individual" onclick="switchMode('individual')">Un par un</button>
            </div>
            <div class="filter-chips">
                <button class="chip active" onclick="goto('Monde', [10, 20], 2, this)">Monde</button>
                <button class="chip" onclick="goto('Africa', [8.78, 34.5], 3, this)">Afrique</button>
                <button class="chip" onclick="goto('Americas', [18.28, -77.33], 3, this)">Amériques</button>
                <button class="chip" onclick="goto('Asia', [34.04, 100.61], 3, this)">Asie</button>
                <button class="chip" onclick="goto('Europe', [54.52, 15.25], 4, this)">Europe</button>
                <button class="chip" onclick="goto('Oceania', [-25.27, 133.77], 4, this)">Océanie</button>
                <button class="chip" onclick="goto('Mada', [-18.766, 46.869], 6, this)">Madagascar</button>
                <button class="chip" onclick="goto('Tana', [-18.879, 47.507], 12, this)">Tana</button>
            </div>
        </div>
        <div class="map-body"><div id="map"></div></div>
    </div>
</div>
<!-- Using relative paths to avoid JSP Expression Language contamination -->
<script src="elements/libs/leaflet-src.js"></script>
<script src="https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js"></script>
<script>
    (function() {
        var map, clusterLayer, individualLayer;
        var colors = ['#0a66c2', '#059669', '#7c3aed', '#db2777', '#ea580c', '#2563eb'];
        function getAvatarColor(str) { 
            var hash = 0; 
            if(!str) return colors[0]; 
            for(var i=0; i<str.length; i++) {
                hash = str.charCodeAt(i) + ((hash << 5) - hash);
            }
            return colors[Math.abs(hash) % colors.length]; 
        }
        function initMap(data) {
            if (typeof L === 'undefined') return;
            map = L.map('map', { zoomControl: false }).setView([-18.879, 47.507], 6);
            L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', { maxZoom: 19 }).addTo(map);
            L.control.zoom({ position: 'bottomright' }).addTo(map);
            individualLayer = L.layerGroup();
            clusterLayer = (typeof L.markerClusterGroup !== 'undefined') ? L.markerClusterGroup() : L.layerGroup();
            data.forEach(function(a) {
                var c = getAvatarColor(a.id);
                var h = a.img ? '<img src="' + a.img + '" class="alumni-marker-icon" style="width:32px;height:32px;">' : '<div class="alumni-initials" style="background:' + c + '">' + a.init + '</div>';
                var icon = L.divIcon({ html: h, className: '', iconSize: [32, 32] });
                var marker = L.marker(a.pos, { icon: icon }).bindTooltip('<b>' + a.p + ' ' + a.n + '</b>', { sticky: true, className: 'alumni-tooltip' });
                marker.on('click', function() { window.location.href = 'module.jsp?but=annuaire/fiche-utilisateur.jsp&idprofil=' + a.id; });
                individualLayer.addLayer(marker); clusterLayer.addLayer(marker);
            });
            map.addLayer(clusterLayer);
        }
        window.switchMode = function(m) {
            document.getElementById('btn-cluster').classList.toggle('active', m === 'cluster');
            document.getElementById('btn-individual').classList.toggle('active', m === 'individual');
            if (m === 'cluster') { map.removeLayer(individualLayer); map.addLayer(clusterLayer); }
            else { map.removeLayer(clusterLayer); map.addLayer(individualLayer); }
        };
        window.goto = function(n, c, z, b) { map.flyTo(c, z); document.querySelectorAll('.chip').forEach(function(x){x.classList.remove('active');}); b.classList.add('active'); };
        // Use a clean relative path for AJAX too
        fetch('map/ajax/get-alumni.jsp').then(function(r){return r.json();}).then(initMap).catch(function(e){console.error(e);});
    })();
</script>
