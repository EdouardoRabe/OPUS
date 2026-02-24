<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%
    UserEJB uNet = (UserEJB) session.getAttribute("u");
    MapUtilisateur mapNet = uNet.getUser();
    String ctx = request.getContextPath();
%>

<style>
/* ===== RESEAU PROFESSIONNEL — Styles ===== */
#reseau-container {
    background: radial-gradient(ellipse at 50% 40%, #0d1b2a 0%, #050d14 100%);
    border-radius: 12px;
    position: relative;
    overflow: hidden;
    box-shadow: 0 8px 40px rgba(0,0,0,0.7);
    margin: 0 0 20px 0;
}
#reseau-canvas {
    display: block;
    cursor: default;
}
#reseau-tooltip {
    position: absolute;
    pointer-events: none;
    background: rgba(10,20,35,0.95);
    border: 1px solid rgba(100,180,255,0.4);
    border-radius: 10px;
    padding: 10px 14px;
    color: #e0f0ff;
    font-size: 13px;
    max-width: 220px;
    box-shadow: 0 4px 20px rgba(0,100,200,0.3);
    display: none;
    z-index: 100;
    line-height: 1.6;
    backdrop-filter: blur(4px);
}
#reseau-tooltip .tt-name  { font-weight: 700; font-size: 15px; color: #7dd3fc; }
#reseau-tooltip .tt-score { font-size: 12px; color: #94a3b8; margin-top: 3px; }
#reseau-tooltip .tt-bar   {
    width: 100%; height: 6px; background: #1e3a5f;
    border-radius: 3px; margin: 5px 0;
    overflow: hidden;
}
#reseau-tooltip .tt-bar-fill {
    height: 100%; border-radius: 3px;
    background: linear-gradient(90deg, #3b82f6, #06b6d4);
    transition: width 0.3s;
}
#reseau-tooltip .tt-tags  { font-size: 11px; color: #64748b; margin-top: 4px; }
#reseau-tooltip .tt-tag   {
    display: inline-block;
    background: rgba(59,130,246,0.2);
    border: 1px solid rgba(59,130,246,0.35);
    border-radius: 4px;
    padding: 1px 6px;
    margin: 2px 2px 0 0;
    color: #93c5fd;
}
#reseau-legend {
    position: absolute;
    bottom: 14px;
    left: 16px;
    font-size: 11px;
    color: rgba(180,210,255,0.6);
    line-height: 1.8;
}
#reseau-legend span { color: rgba(180,210,255,0.9); font-weight: 600; }
#reseau-loading {
    position: absolute;
    top: 50%; left: 50%;
    transform: translate(-50%,-50%);
    color: #7dd3fc;
    font-size: 15px;
    letter-spacing: 2px;
}
#reseau-controls {
    display: flex;
    gap: 10px;
    align-items: center;
    margin-bottom: 12px;
    flex-wrap: wrap;
}
#reseau-controls label { color: #7dd3fc; font-size: 13px; }
#reseau-controls input[type=range] {
    accent-color: #3b82f6;
    width: 120px;
}
#seuil-val { color: #f0abfc; font-weight: 700; min-width: 28px; display: inline-block; }
#reseau-zoom-btns {
    position: absolute;
    top: 12px;
    right: 14px;
    display: flex;
    flex-direction: column;
    gap: 5px;
    z-index: 20;
}
#reseau-zoom-btns button {
    width: 32px;
    height: 32px;
    border-radius: 8px;
    border: 1px solid rgba(100,180,255,0.3);
    background: rgba(10,20,40,0.85);
    color: #7dd3fc;
    font-size: 18px;
    line-height: 1;
    cursor: pointer;
    transition: background 0.15s;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0;
}
#reseau-zoom-btns button:hover { background: rgba(30,60,120,0.9); }
#reseau-zoom-btns .btn-reset { font-size: 13px; }
</style>

<div class="content-wrapper">
    <section class="content-header">
        <h1>R&eacute;seau Professionnel</h1>
        <small>Visualisation dynamique de compatibilit&eacute;</small>
    </section>
    <section class="content">

        <!-- Controles -->
        <div id="reseau-controls">
            <label>Seuil de connexion :
                <input type="range" id="seuil-slider" min="0" max="80" value="20" step="5"
                       oninput="document.getElementById('seuil-val').textContent=this.value+'%'; appliquerSeuil(parseInt(this.value));">
                <span id="seuil-val">20%</span>
            </label>
            <label style="margin-left:20px;">
                <input type="checkbox" id="chk-labels" checked
                       onchange="afficherLabels=this.checked;">
                Noms
            </label>
            <label style="margin-left:20px;">
                <input type="checkbox" id="chk-float" checked
                       onchange="flotterActif=this.checked;">
                Animation flottante
            </label>
        </div>

        <!-- Canvas -->
        <div id="reseau-container">
            <canvas id="reseau-canvas"></canvas>
            <div id="reseau-tooltip"></div>
            <div id="reseau-loading">Chargement du r&eacute;seau&hellip;</div>
            <div id="reseau-legend">
                <div><span>Taille &amp; distance</span> = score de compatibilit&eacute;</div>
                <div><span>Plus proche du centre</span> = plus compatible</div>
                <div><span>Couleur</span> = parcours / fili&egrave;re</div>
                <div style="margin-top:4px;color:rgba(140,180,220,0.5);font-size:10px;">Molette / pincer pour zoomer &bull; Glisser pour naviguer</div>
            </div>
            <div id="reseau-zoom-btns">
                <button id="btn-zoom-in"  title="Zoom +">+</button>
                <button id="btn-zoom-out" title="Zoom -">&minus;</button>
                <button id="btn-zoom-reset" class="btn-reset" title="R&eacute;initialiser">&#8635;</button>
            </div>
        </div>

    </section>
</div>

<script>
(function() {
"use strict";

// -----------------------------------------------------------------------
// MODULE 2 — TRANSFORMATION SCORE → DISTANCE VISUELLE
// score élevé  → proche du centre (distance faible)
// score faible → loin   du centre (distance grande)
// -----------------------------------------------------------------------
var DIST_MIN = 80;   // world-px pour score 100 (très compatible)
var DIST_MAX = 280;  // world-px pour score   0 (peu compatible)

function scoreToRadius(score) {
    return DIST_MIN + (100 - score) / 100 * (DIST_MAX - DIST_MIN);
}

// -----------------------------------------------------------------------
// Couleur déterministe par parcours (HSL)
// -----------------------------------------------------------------------
function hashHue(idp) {
    if (!idp) return 210;
    var h = 0;
    for (var i = 0; i < idp.length; i++) h = idp.charCodeAt(i) + ((h << 5) - h);
    return Math.abs(h) % 360;
}
function parcoursColor(idparcours, alpha) {
    return "hsla(" + hashHue(idparcours) + ",65%,62%," + alpha + ")";
}

// -----------------------------------------------------------------------
// Etat global
// -----------------------------------------------------------------------
var canvas  = document.getElementById("reseau-canvas");
var ctx     = canvas.getContext("2d");
var tooltip = document.getElementById("reseau-tooltip");
var loading = document.getElementById("reseau-loading");
var container = document.getElementById("reseau-container");

var nodes        = [];
var edges        = [];
var nodesById    = {};
var seuilActif   = 20;
var hoveredNode  = null;
var afficherLabels = true;
var flotterActif   = true;
var startTime    = Date.now();
var animFrame    = null;
var pulseT       = 0;

// --- Vue : zoom / pan ---
var viewScale = 1.0;
var panX = 0, panY = 0;
var isPanning = false;
var panStart  = {x: 0, y: 0};
var touches0  = null;

// Taille canvas responsive (les positions sont en espace monde → pas besoin de repositionner)
function resizeCanvas() {
    var w = container.clientWidth;
    var h = Math.max(520, Math.round(w * 0.58));
    canvas.width  = w;
    canvas.height = h;
    container.style.height = h + "px";
}

// -----------------------------------------------------------------------
// MODULE 4 — POSITIONNEMENT RADIAL (espace monde, centre = 0,0)
// Distance = scoreToRadius(score) : plus le score est élevé, plus le nœud
// est PROCHE du centre (0,0).
// -----------------------------------------------------------------------
function positionnerNoeuds() {
    var others = nodes.filter(function(n) { return !n.isSelf; });
    var N = others.length;
    // Trier par score décroissant pour que les nœuds compatibles se regroupent
    others.sort(function(a, b) { return b.score - a.score; });

    others.forEach(function(n, i) {
        var angle = (i / N) * Math.PI * 2 - Math.PI / 2;
        var dist  = scoreToRadius(n.score); // DIST_MIN..DIST_MAX
        n.tx = dist * Math.cos(angle);
        n.ty = dist * Math.sin(angle);
        // Initialiser à la position cible (pas d'entrée hors-écran)
        if (n.x === undefined) { n.x = n.tx; n.y = n.ty; }
    });

    // Nœud self : centre monde (0, 0)
    var self = nodes.find(function(n) { return n.isSelf; });
    if (self) {
        self.tx = 0; self.ty = 0;
        if (self.x === undefined) { self.x = 0; self.y = 0; }
    }
}

// -----------------------------------------------------------------------
// MODULE 3 — GENERATION DES CONNEXIONS (option B: score >= seuil)
// -----------------------------------------------------------------------
function appliquerSeuil(seuil) {
    seuilActif = seuil;
    // edges refilter a chaque frame — pas besoin de reconstruire les listes
}

// -----------------------------------------------------------------------
// MODULE 5 — RENDU CANVAS (boucle d animation)
// -----------------------------------------------------------------------
function render() {
    animFrame = requestAnimationFrame(render);
    pulseT = (Date.now() - startTime) / 1000;

    var W = canvas.width;
    var H = canvas.height;
    if (W === 0 || H === 0) return;

    // Fond dégradé
    var grad = ctx.createRadialGradient(W/2, H*0.4, 0, W/2, H/2, Math.max(W,H)*0.7);
    grad.addColorStop(0, "#0d1b2a");
    grad.addColorStop(1, "#050d14");
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, W, H);

    if (nodes.length === 0) return;

    // Lerp positions (espace monde)
    nodes.forEach(function(n) {
        if (n.tx === undefined) return;
        var lk = n.isSelf ? 0.06 : 0.04;
        n.x += (n.tx - n.x) * lk;
        n.y += (n.ty - n.y) * lk;
        var fx = 0, fy = 0;
        if (flotterActif && !n.isSelf) {
            fx = Math.cos(pulseT * n.floatSpeed + n.floatPhase)           * n.floatAmp;
            fy = Math.sin(pulseT * n.floatSpeed * 0.7 + n.floatPhase*1.3) * n.floatAmp;
        }
        n.dx = n.x + fx;
        n.dy = n.y + fy;
    });

    // Appliquer la transformation vue (pan + zoom)
    ctx.save();
    ctx.translate(W/2 + panX, H/2 + panY);
    ctx.scale(viewScale, viewScale);

    // Cercles guides de compatibilité
    var guideR = [DIST_MIN, (DIST_MIN + DIST_MAX) / 2, DIST_MAX];
    var guideL = ["Tr\u00e8s compatible", "Compatible", "Peu compatible"];
    guideR.forEach(function(r, idx) {
        ctx.save();
        ctx.beginPath();
        ctx.arc(0, 0, r, 0, Math.PI * 2);
        ctx.strokeStyle = "rgba(59,130,246,0.10)";
        ctx.lineWidth = 1 / viewScale;
        ctx.setLineDash([5 / viewScale, 10 / viewScale]);
        ctx.stroke();
        ctx.setLineDash([]);
        if (viewScale > 0.35) {
            ctx.fillStyle = "rgba(100,160,255,0.28)";
            ctx.font = (10 / viewScale) + "px Arial";
            ctx.textAlign = "left";
            ctx.textBaseline = "middle";
            ctx.fillText(guideL[idx], r + 4 / viewScale, 0);
        }
        ctx.restore();
    });

    // --- 1. Arêtes ---
    edges.forEach(function(e) {
        if (e.score < seuilActif) return;
        var nA = nodesById[e.from], nB = nodesById[e.to];
        if (!nA || !nB || nA.dx === undefined || nB.dx === undefined) return;
        var isHov = hoveredNode && (hoveredNode.id === nA.id || hoveredNode.id === nB.id);
        var alpha = Math.max(0.15, Math.min(0.78, 0.15 + e.score / 100 * 0.63));
        if (isHov) alpha = Math.min(0.95, alpha * 3);
        ctx.save();
        ctx.beginPath();
        ctx.moveTo(nA.dx, nA.dy);
        ctx.lineTo(nB.dx, nB.dy);
        ctx.strokeStyle = isHov ? "rgba(125,211,252," + alpha + ")" : "rgba(59,130,246," + alpha + ")";
        ctx.lineWidth = (isHov ? 2.5 : Math.max(0.8, e.score / 100 * 2.0)) / viewScale;
        if (isHov) { ctx.shadowColor = "#7dd3fc"; ctx.shadowBlur = 8; }
        ctx.stroke();
        ctx.restore();
    });

    // --- 2. Nœuds ---
    nodes.forEach(function(n) {
        if (n.dx === undefined) return;
        var x = n.dx, y = n.dy;
        var isHov = (hoveredNode && hoveredNode.id === n.id);

        // Taille proportionnelle au score — gamme élargie pour visibilité
        var baseSize = n.isSelf ? 28 : Math.max(9, 9 + (n.score / 100) * 22);
        var r = baseSize;
        if (isHov) r *= 1.3;

        ctx.save();

        // Halo / glow
        if (n.isSelf) {
            // Anneau pulsant pour le nœud central
            var pulseR = r + 12 + Math.sin(pulseT * 2) * 6;
            ctx.beginPath();
            ctx.arc(x, y, pulseR, 0, Math.PI * 2);
            ctx.strokeStyle = "rgba(125,211,252," + (0.15 + 0.1 * Math.sin(pulseT * 2)) + ")";
            ctx.lineWidth = 2 / viewScale;
            ctx.stroke();

            var pulseR2 = r + 22 + Math.sin(pulseT * 1.3 + 1) * 8;
            ctx.beginPath();
            ctx.arc(x, y, pulseR2, 0, Math.PI * 2);
            ctx.strokeStyle = "rgba(125,211,252," + (0.06 + 0.04 * Math.sin(pulseT * 1.3)) + ")";
            ctx.lineWidth = 1.5 / viewScale;
            ctx.stroke();
        } else if (isHov || n.score >= 60) {
            ctx.shadowColor = parcoursColor(n.idparcours, 0.9);
            ctx.shadowBlur  = isHov ? 22 : 12;
        }

        // Cercle rempli
        ctx.beginPath();
        ctx.arc(x, y, r, 0, Math.PI * 2);
        if (n.isSelf) {
            var g = ctx.createRadialGradient(x - r*0.3, y - r*0.3, 0, x, y, r);
            g.addColorStop(0, "#7dd3fc");
            g.addColorStop(1, "#1d4ed8");
            ctx.fillStyle = g;
        } else {
            var g2 = ctx.createRadialGradient(x - r*0.3, y - r*0.3, 0, x, y, r);
            g2.addColorStop(0, colorLighter(n.idparcours));
            g2.addColorStop(1, parcoursColor(n.idparcours, 1.0));
            ctx.fillStyle = g2;
        }
        ctx.fill();

        // Bordure
        ctx.strokeStyle = n.isSelf
            ? "rgba(125,211,252,0.85)"
            : "rgba(255,255,255," + (isHov ? 0.75 : 0.28) + ")";
        ctx.lineWidth = (n.isSelf ? 2 : (isHov ? 1.8 : 1)) / viewScale;
        ctx.stroke();

        // Badge score
        if (!n.isSelf && r >= 8) {
            ctx.font = "bold " + Math.max(8, Math.round(r * 0.55)) + "px Arial";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillStyle = "rgba(255,255,255,0.92)";
            ctx.fillText(n.score, x, y);
        }
        if (n.isSelf) {
            ctx.font = "bold " + Math.round(r * 0.42) + "px Arial";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillStyle = "#fff";
            ctx.fillText("MOI", x, y);
        }

        ctx.restore();

        // Label (nom) sous le nœud
        if (afficherLabels) {
            ctx.save();
            ctx.font = (isHov ? "bold " : "") + Math.max(9, Math.min(13, 9 + n.score / 20)) + "px Arial";
            ctx.textAlign = "center";
            ctx.textBaseline = "top";
            ctx.fillStyle = isHov ? "#e0f0ff" : (n.isSelf ? "#7dd3fc" : "rgba(180,210,255,0.75)");
            ctx.shadowColor = "#000";
            ctx.shadowBlur  = 4;
            var lbl = n.isSelf
                ? (mapNet_nom || "Vous")
                : (n.prenom ? n.prenom + " " + n.nom.charAt(0) + "." : n.nom);
            ctx.fillText(lbl, x, y + r + 4);
            ctx.restore();
        }
    });

    ctx.restore(); // fin transform vue
}

function colorLighter(idparcours) {
    return "hsla(" + hashHue(idparcours) + ",65%,80%,1)";
}

// -----------------------------------------------------------------------
// Zoom centré sur un point écran
// -----------------------------------------------------------------------
function zoomAt(mx, my, factor) {
    var newScale = Math.max(0.15, Math.min(6, viewScale * factor));
    var rf = newScale / viewScale;
    panX = (mx - canvas.width  / 2) * (1 - rf) + panX * rf;
    panY = (my - canvas.height / 2) * (1 - rf) + panY * rf;
    viewScale = newScale;
}

// -----------------------------------------------------------------------
// HitTest — convertit coords écran → monde avant comparaison
// -----------------------------------------------------------------------
function screenToWorld(mx, my) {
    return {
        x: (mx - canvas.width  / 2 - panX) / viewScale,
        y: (my - canvas.height / 2 - panY) / viewScale
    };
}

function hitTest(mx, my) {
    var w = screenToWorld(mx, my);
    var bestD = Infinity, best = null;
    nodes.forEach(function(n) {
        if (n.dx === undefined) return;
        var r = n.isSelf ? 28 : Math.max(9, 9 + (n.score / 100) * 22);
        var d = Math.sqrt((w.x - n.dx)*(w.x - n.dx) + (w.y - n.dy)*(w.y - n.dy));
        if (d < r + 10 && d < bestD) { bestD = d; best = n; }
    });
    return best;
}

// -----------------------------------------------------------------------
// Pan (drag) + Zoom (molette, boutons)
// -----------------------------------------------------------------------
canvas.style.cursor = "grab";

canvas.addEventListener("mousedown", function(e) {
    if (e.button !== 0) return;
    isPanning = true;
    panStart = {x: e.clientX - panX, y: e.clientY - panY};
    canvas.style.cursor = "grabbing";
    tooltip.style.display = "none";
});

window.addEventListener("mousemove", function(e) {
    if (isPanning) {
        panX = e.clientX - panStart.x;
        panY = e.clientY - panStart.y;
        return;
    }
    var rect = canvas.getBoundingClientRect();
    if (e.clientX < rect.left || e.clientX > rect.right ||
        e.clientY < rect.top  || e.clientY > rect.bottom) return;
    var mx = e.clientX - rect.left;
    var my = e.clientY - rect.top;
    hoveredNode = hitTest(mx, my);
    canvas.style.cursor = hoveredNode ? "pointer" : "grab";
    hoveredNode ? afficherTooltip(hoveredNode, e.clientX, e.clientY) : (tooltip.style.display = "none");
});

window.addEventListener("mouseup", function() {
    if (isPanning) { isPanning = false; canvas.style.cursor = "grab"; }
});

canvas.addEventListener("mouseleave", function() {
    if (!isPanning) { hoveredNode = null; tooltip.style.display = "none"; }
});

// Zoom molette
canvas.addEventListener("wheel", function(e) {
    e.preventDefault();
    var rect = canvas.getBoundingClientRect();
    zoomAt(e.clientX - rect.left, e.clientY - rect.top, e.deltaY < 0 ? 1.12 : (1/1.12));
}, {passive: false});

// Touch : pan + pinch-to-zoom
canvas.addEventListener("touchstart", function(e) {
    if (e.touches.length === 1) {
        isPanning = true;
        panStart = {x: e.touches[0].clientX - panX, y: e.touches[0].clientY - panY};
    } else if (e.touches.length === 2) {
        isPanning = false;
        var dx = e.touches[0].clientX - e.touches[1].clientX;
        var dy = e.touches[0].clientY - e.touches[1].clientY;
        var rect = canvas.getBoundingClientRect();
        touches0 = {
            dist: Math.sqrt(dx*dx + dy*dy), scale: viewScale,
            cx: (e.touches[0].clientX + e.touches[1].clientX)/2 - rect.left,
            cy: (e.touches[0].clientY + e.touches[1].clientY)/2 - rect.top
        };
    }
    e.preventDefault();
}, {passive: false});

canvas.addEventListener("touchmove", function(e) {
    if (e.touches.length === 1 && isPanning) {
        panX = e.touches[0].clientX - panStart.x;
        panY = e.touches[0].clientY - panStart.y;
    } else if (e.touches.length === 2 && touches0) {
        var dx = e.touches[0].clientX - e.touches[1].clientX;
        var dy = e.touches[0].clientY - e.touches[1].clientY;
        var newDist = Math.sqrt(dx*dx + dy*dy);
        var factor  = newDist / touches0.dist;
        zoomAt(touches0.cx, touches0.cy, factor / (viewScale / touches0.scale));
        touches0.dist  = newDist;
        touches0.scale = viewScale;
    }
    e.preventDefault();
}, {passive: false});

canvas.addEventListener("touchend", function() { isPanning = false; touches0 = null; });

// Boutons overlay zoom
document.getElementById("btn-zoom-in").onclick = function() {
    zoomAt(canvas.width/2, canvas.height/2, 1.25);
};
document.getElementById("btn-zoom-out").onclick = function() {
    zoomAt(canvas.width/2, canvas.height/2, 0.80);
};
document.getElementById("btn-zoom-reset").onclick = function() {
    viewScale = 1; panX = 0; panY = 0;
};

function afficherTooltip(n, cx, cy) {
    var contRect = container.getBoundingClientRect();
    var tx = cx - contRect.left + 16;
    var ty = cy - contRect.top  - 20;

    // Eviter sortie droite
    if (tx + 240 > container.clientWidth) tx = cx - contRect.left - 240;
    if (ty < 0) ty = cy - contRect.top + 20;

    var scoreColor = n.score >= 70 ? "#4ade80" : (n.score >= 40 ? "#facc15" : "#f87171");
    var tagsHtml = n.tags && n.tags.length
        ? n.tags.slice(0, 5).map(function(t) {
            return "<span class='tt-tag'>" + escHtml(t) + "</span>";
          }).join("")
        : "<em style='color:#475569'>Pas de tag commun</em>";

    tooltip.innerHTML =
        "<div class='tt-name'>" + escHtml((n.prenom || "") + " " + (n.nom || "")) + "</div>" +
        "<div class='tt-score'>Compatibilit&eacute; : <b style='color:" + scoreColor + "'>" + n.score + "%</b></div>" +
        "<div class='tt-bar'><div class='tt-bar-fill' style='width:" + n.score + "%'></div></div>" +
        "<div class='tt-tags'><b>Tags communs :</b><br>" + tagsHtml + "</div>";

    tooltip.style.left    = tx + "px";
    tooltip.style.top     = ty + "px";
    tooltip.style.display = "block";
}

function escHtml(s) {
    if (!s) return "";
    return s.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;");
}

// Nom de l'utilisateur courant (JSP)
var mapNet_nom = "<%= mapNet.getNomuser() != null ? mapNet.getNomuser().replace("\"","\\\"") : "Moi" %>";

// -----------------------------------------------------------------------
// Chargement des donnees (fetch AJAX)
// -----------------------------------------------------------------------
function chargerReseau() {
    loading.style.display = "block";
    var url = "<%= ctx %>/pages/alumni/ajax/calculer-reseau.jsp";
    var xhr = new XMLHttpRequest();
    xhr.open("GET", url, true);
    xhr.onload = function() {
        loading.style.display = "none";
        if (xhr.status !== 200) {
            loading.textContent = "Erreur HTTP " + xhr.status;
            loading.style.display = "block";
            return;
        }
        var data;
        try { data = JSON.parse(xhr.responseText); }
        catch(ex) {
            loading.textContent = "Erreur de parsing JSON";
            loading.style.display = "block";
            return;
        }
        if (!data.success) {
            loading.textContent = "Erreur : " + (data.error || "inconnue");
            loading.style.display = "block";
            return;
        }
        initialiserReseau(data);
    };
    xhr.onerror = function() {
        loading.textContent = "Erreur reseau";
        loading.style.display = "block";
    };
    xhr.send();
}

// -----------------------------------------------------------------------
// Initialiser les noeuds apres reception JSON
// -----------------------------------------------------------------------
function initialiserReseau(data) {
    nodes    = [];
    edges    = [];
    nodesById = {};

    data.nodes.forEach(function(n) {
        var node = {
            id:        n.id,
            nom:       n.nom,
            prenom:    n.prenom,
            idparcours:n.idparcours,
            score:     n.score,
            isSelf:    n.isSelf,
            tags:      n.tags || [],
            // physique
            x: undefined, y: undefined,
            tx: undefined, ty: undefined,
            dx: undefined, dy: undefined,
            // animation flottante — MODULE 5
            floatPhase: Math.random() * Math.PI * 2,
            floatSpeed: 0.25 + Math.random() * 0.3,
            floatAmp:   n.isSelf ? 0 : (3 + Math.random() * 5)
        };
        nodes.push(node);
        nodesById[n.id] = node;
    });

    // Construire la liste d edges en referant aux noeuds par id
    data.edges.forEach(function(e) {
        edges.push({ from: e.from, to: e.to, score: e.score });
    });

    positionnerNoeuds();

    if (!animFrame) render();  // demarrer boucle si pas encore active
}

// -----------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------
window.appliquerSeuil = function(s) { seuilActif = s; };

resizeCanvas();
window.addEventListener("resize", resizeCanvas);

// Démarrer la boucle de rendu
render();

// Charger les données
chargerReseau();

})();
</script>
