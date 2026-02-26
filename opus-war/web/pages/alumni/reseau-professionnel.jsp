<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%
    UserEJB uNet = (UserEJB) session.getAttribute("u");
    MapUtilisateur mapNet = uNet.getUser();
    String ctx = request.getContextPath();
%>

<style>
/* ===== RESEAU PROFESSIONNEL — Styles UI/UX Pro Max ===== */
.rp-page-wrapper {
    width: 100%;
    padding: 0;
}
.rp-page-title {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 24px;
    padding: 20px 24px;
    background: #fff;
    border-radius: 14px;
    border: 1px solid var(--fa-border, #e4e6eb);
    box-shadow: 0 1px 4px rgba(0,0,0,.06);
}
.rp-page-title-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    background: linear-gradient(135deg, var(--itu-blue, #283a97) 0%, var(--itu-violet, #536ae4) 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    font-size: 22px;
    flex-shrink: 0;
    box-shadow: 0 4px 12px rgba(40,58,151,0.25);
}
.rp-page-title-text h1 {
    font-size: 1.5rem;
    font-weight: 800;
    color: #1c1e29;
    margin: 0 0 4px;
    letter-spacing: -0.3px;
}
.rp-page-title-text p {
    font-size: 0.9rem;
    color: #536ae4;
    font-weight: 500;
    margin: 0;
}
.rp-content {
    padding: 0;
}
/* Override parent container width for this page */
.alumni-page-wide:has(.rp-page-wrapper) {
    max-width: 1400px;
}
#reseau-container {
    background: radial-gradient(ellipse at 50% 40%, #1c1e29 0%, #1c1e21 100%);
    border-radius: 16px;
    position: relative;
    overflow: hidden;
    box-shadow: 0 20px 60px rgba(0,0,0,0.3), inset 0 1px 0 rgba(255,255,255,0.1);
    margin: 0;
    border: 1px solid rgba(40,58,151,0.12);
    transition: box-shadow 0.3s ease, border-color 0.3s ease;
}
#reseau-container:hover {
    box-shadow: 0 25px 70px rgba(40,58,151,0.15), inset 0 1px 0 rgba(255,255,255,0.1);
    border-color: rgba(40,58,151,0.2);
}
#reseau-canvas {
    display: block;
    cursor: default;
    width: 100%;
    height: 100%;
}
#reseau-tooltip {
    position: absolute;
    pointer-events: none;
    background: rgba(28,30,41,0.98);
    border: 1.5px solid rgba(40,58,151,0.5);
    border-radius: 14px;
    padding: 14px 18px;
    color: #d0dce7;
    font-size: 13px;
    max-width: 240px;
    box-shadow: 0 12px 40px rgba(40,58,151,0.4), inset 0 1px 0 rgba(255,255,255,0.1);
    display: none;
    z-index: 100;
    line-height: 1.6;
    backdrop-filter: blur(8px);
    animation: tooltipFadeIn 0.2s ease;
}
@keyframes tooltipFadeIn {
    from { opacity: 0; transform: translateY(-4px); }
    to { opacity: 1; transform: translateY(0); }
}
#reseau-tooltip .tt-name  { font-weight: 800; font-size: 16px; color: #b2d235; margin-bottom: 6px; }
#reseau-tooltip .tt-score { font-size: 13px; color: #d0dce7; margin-top: 6px; margin-bottom: 8px; }
#reseau-tooltip .tt-bar   {
    width: 100%; height: 8px; background: #1c1e29;
    border-radius: 4px; margin: 8px 0;
    overflow: hidden;
    box-shadow: inset 0 1px 2px rgba(0,0,0,0.5);
}
#reseau-tooltip .tt-bar-fill {
    height: 100%; border-radius: 4px;
    background: linear-gradient(90deg, #283a97, #536ae4);
    transition: width 0.4s ease;
    box-shadow: 0 0 10px rgba(40,58,151,0.6);
}
#reseau-tooltip .tt-tags  { font-size: 12px; color: #d0dce7; margin-top: 8px; }
#reseau-tooltip .tt-tag   {
    display: inline-block;
    background: rgba(40,58,151,0.25);
    border: 1px solid rgba(83,106,228,0.5);
    border-radius: 6px;
    padding: 3px 8px;
    margin: 3px 4px 0 0;
    color: #536ae4;
    font-weight: 500;
    transition: all 0.2s ease;
}
#reseau-tooltip .tt-tag:hover {
    background: rgba(40,58,151,0.4);
    border-color: rgba(83,106,228,0.7);
}
#reseau-legend {
    position: absolute;
    bottom: 18px;
    left: 22px;
    font-size: 12px;
    color: rgba(208,220,231,0.65);
    line-height: 1.9;
    background: rgba(28,30,41,0.5);
    padding: 12px 16px;
    border-radius: 10px;
    border: 1px solid rgba(40,58,151,0.15);
    backdrop-filter: blur(4px);
}
#reseau-legend span { color: rgba(208,220,231,0.95); font-weight: 700; }
#reseau-loading {
    position: absolute;
    top: 50%; left: 50%;
    transform: translate(-50%,-50%);
    color: #b2d235;
    font-size: 16px;
    letter-spacing: 2px;
    font-weight: 600;
}
/* ===== VARIABLES GLOBALES (cohérence avec voir.jsp) ===== */
:root {
    --itu-blue: #283a97;
    --itu-dark: #1c1e29;
    --itu-violet: #536ae4;
    --itu-lime: #b2d235;
    --itu-rose: #e46a91;
    --itu-rouge: #fd3022;
    --pvl-border: #d0dce7;
    --pvl-card-bg: #fff;
    --pvl-text: #1c1e21;
    --pvl-text-sec: #65676b;
    --fa-card-bg: #ffffff;
    --fa-border: #d0dce7;
    --fa-text: #1c1e21;
}

/* ===== LAYOUT GRILLE 2 COLONNES ===== */
.rp-layout {
    display: grid;
    grid-template-columns: 1fr 300px;
    gap: 22px;
    align-items: start;
}
@media (max-width: 1000px) {
    .rp-layout { grid-template-columns: 1fr; }
    .rp-controls-col { position: static !important; }
}
.rp-canvas-col { min-width: 0; }
.rp-controls-col {
    position: sticky;
    top: 80px;
}

/* ===== PANEL CONTROLS — CARD BLANCHE (style voir.jsp) ===== */
.rp-ctrl-panel {
    background: #fff;
    border-radius: 14px;
    border: 1px solid var(--pvl-border, #dce0e4);
    box-shadow: 0 1px 4px rgba(0,0,0,.10), 0 4px 20px rgba(40,58,151,0.06);
    overflow: hidden;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
}
.rp-ctrl-header {
    padding: 15px 20px;
    border-bottom: 1px solid var(--fa-border, #e4e6eb);
    display: flex;
    align-items: center;
    gap: 10px;
    background: linear-gradient(135deg, #f8faff 0%, #eef5ff 100%);
}
.rp-ctrl-header h3 {
    margin: 0;
    font-size: 14px;
    font-weight: 700;
    color: var(--pvl-text, #1c1e21);
    letter-spacing: -0.2px;
}
.rp-ctrl-header-icon {
    width: 30px;
    height: 30px;
    border-radius: 8px;
    background: linear-gradient(135deg, var(--itu-blue,#008BFF) 0%, var(--itu-violet,#5B23FF) 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    font-size: 14px;
    flex-shrink: 0;
}
.rp-ctrl-body {
    padding: 18px 20px;
    display: flex;
    flex-direction: column;
    gap: 18px;
}
.rp-ctrl-label {
    font-size: 11px;
    font-weight: 700;
    color: var(--pvl-text-sec, #65676b);
    text-transform: uppercase;
    letter-spacing: 0.6px;
    margin-bottom: 10px;
    display: flex;
    align-items: center;
    gap: 6px;
}
.rp-ctrl-label i { color: var(--itu-blue,#008BFF); font-size: 13px; }
.rp-ctrl-divider {
    border: none;
    border-top: 1px solid var(--fa-border, #e4e6eb);
    margin: 0;
}
.rp-slider-row {
    display: flex;
    align-items: center;
    gap: 10px;
}
.rp-slider-row input[type=range] {
    flex: 1;
    accent-color: var(--itu-blue,#008BFF);
    height: 5px;
    border-radius: 3px;
    cursor: pointer;
}
.rp-seuil-val {
    min-width: 40px;
    text-align: right;
    font-size: 15px;
    font-weight: 800;
    color: var(--itu-blue,#008BFF);
}
.rp-check-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 13px;
    background: #f7f9fc;
    border-radius: 10px;
    border: 1px solid var(--fa-border,#e4e6eb);
    cursor: pointer;
    transition: background .15s, border-color .15s;
}
.rp-check-row:hover { background: #eaecf8; border-color: rgba(40,58,151,0.3); }
.rp-check-row label {
    font-size: 13px;
    font-weight: 500;
    color: var(--pvl-text, #1c1e21);
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    flex: 1;
}
.rp-check-row label i { color: var(--itu-blue,#008BFF); font-size: 14px; }
.rp-check-row input[type=checkbox] {
    width: 17px;
    height: 17px;
    accent-color: var(--itu-blue,#008BFF);
    cursor: pointer;
    flex-shrink: 0;
}
.rp-zoom-btns {
    display: flex;
    gap: 8px;
}
.rp-zoom-btn {
    flex: 1;
    padding: 9px 0;
    border-radius: 10px;
    border: 1.5px solid var(--pvl-border,#dce0e4);
    background: #fff;
    color: var(--pvl-text,#1c1e21);
    font-size: 17px;
    font-weight: 700;
    cursor: pointer;
    transition: all .15s;
    line-height: 1;
}
.rp-zoom-btn:hover {
    background: #f0f7ff;
    border-color: var(--itu-blue,#008BFF);
    color: var(--itu-blue,#008BFF);
    transform: translateY(-1px);
}
.rp-zoom-btn--reset { font-size: 13px; color: var(--itu-blue,#008BFF); }
.rp-legend-item {
    display: flex;
    align-items: center;
    gap: 9px;
    font-size: 12.5px;
    color: #4a5568;
    line-height: 1.4;
}
.rp-legend-dot {
    width: 11px;
    height: 11px;
    border-radius: 50%;
    flex-shrink: 0;
}
/* Cacher le seuil-val inline (remplacé par .rp-seuil-val) */
#seuil-val { display: none; }
#reseau-zoom-btns {
    position: absolute;
    top: 18px;
    right: 18px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    z-index: 20;
}
#reseau-zoom-btns button {
    width: 38px;
    height: 38px;
    border-radius: 10px;
    border: 1.5px solid rgba(40,58,151,0.35);
    background: rgba(28,30,41,0.75);
    color: #b2d235;
    font-size: 18px;
    line-height: 1;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0;
    font-weight: 700;
    backdrop-filter: blur(4px);
    box-shadow: 0 4px 16px rgba(40,58,151,0.15);
}
#reseau-zoom-btns button:hover {
    background: rgba(40,58,151,0.2);
    border-color: rgba(83,106,228,0.6);
    color: #d0dce7;
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(40,58,151,0.3);
}
#reseau-zoom-btns button:active {
    transform: translateY(0);
}
#reseau-zoom-btns .btn-reset {
    font-size: 14px;
    font-weight: 700;
}
</style>

<div class="rp-page-wrapper">
    <div class="rp-page-title">
        <div class="rp-page-title-icon">
            <i class="bi bi-diagram-3-fill"></i>
        </div>
        <div class="rp-page-title-text">
            <h1>R&eacute;seau Professionnel</h1>
            <p>Visualisation dynamique de compatibilit&eacute; avec vos pairs</p>
        </div>
    </div>
    <section class="rp-content">
        <div class="rp-layout">

            <!-- ═══════ COLONNE GAUCHE : Canvas réseau ═══════ -->
            <div class="rp-canvas-col">
                <div id="reseau-container">
                    <canvas id="reseau-canvas"></canvas>
                    <div id="reseau-tooltip"></div>
                    <div id="reseau-loading">Chargement du r&eacute;seau&hellip;</div>
                    <div id="reseau-legend">
                        <div><span>Taille &amp; distance</span> = score de compatibilit&eacute;</div>
                        <div><span>Plus proche du centre</span> = plus compatible</div>
                        <div><span>Couleur</span> = parcours / fili&egrave;re</div>
                        <div style="margin-top:4px;color:rgba(208,220,231,0.5);font-size:10px;">Molette / pincer pour zoomer &bull; Glisser pour naviguer &bull; Cliquer sur un profil pour le consulter</div>
                    </div>
                    <div id="reseau-zoom-btns">
                        <button id="btn-zoom-in"  title="Zoom +">+</button>
                        <button id="btn-zoom-out" title="Zoom -">&minus;</button>
                        <button id="btn-zoom-reset" class="btn-reset" title="R&eacute;initialiser">&#8635;</button>
                    </div>
                </div>
            </div>

            <!-- ═══════ COLONNE DROITE : Panneau de contrôles ═══════ -->
            <aside class="rp-controls-col">
                <div class="rp-ctrl-panel">

                    <!-- En-tête card -->
                    <div class="rp-ctrl-header">
                        <div class="rp-ctrl-header-icon">
                            <i class="bi bi-sliders"></i>
                        </div>
                        <h3>Filtres &amp; Affichage</h3>
                    </div>

                    <div class="rp-ctrl-body">

                        <!-- ── Seuil de connexion ── -->
                        <div class="rp-ctrl-section">
                            <div class="rp-ctrl-label">
                                <i class="bi bi-bar-chart-fill"></i>
                                Seuil de connexion
                            </div>
                            <div class="rp-slider-row">
                                <input type="range" id="seuil-slider" min="0" max="80" value="20" step="5"
                                       oninput="document.getElementById('seuil-val-display').textContent=this.value+'%'; appliquerSeuil(parseInt(this.value));">
                                <span id="seuil-val-display" class="rp-seuil-val">20%</span>
                                <span id="seuil-val" style="display:none;">20%</span>
                            </div>
                            <div style="margin-top:7px;font-size:11px;color:#94a3b8;line-height:1.4;">N'affiche que les connexions dont le score d&eacute;passe ce seuil.</div>
                        </div>

                        <hr class="rp-ctrl-divider">

                        <!-- ── Affichage ── -->
                        <div class="rp-ctrl-section">
                            <div class="rp-ctrl-label">
                                <i class="bi bi-eye-fill"></i>
                                Affichage
                            </div>
                            <div style="display:flex;flex-direction:column;gap:8px;">
                                <div class="rp-check-row">
                                    <label for="chk-labels">
                                        <i class="bi bi-person-badge-fill"></i>
                                        Afficher les noms
                                    </label>
                                    <input type="checkbox" id="chk-labels" checked
                                           onchange="setAfficherLabels(this.checked);">
                                </div>
                                <div class="rp-check-row">
                                    <label for="chk-float">
                                        <i class="bi bi-stars"></i>
                                        Animation flottante
                                    </label>
                                    <input type="checkbox" id="chk-float" checked
                                           onchange="setFlotterActif(this.checked);">
                                </div>
                            </div>
                        </div>

                        <hr class="rp-ctrl-divider">

                        <!-- ── Zoom ── -->
                        <div class="rp-ctrl-section">
                            <div class="rp-ctrl-label">
                                <i class="bi bi-search"></i>
                                Zoom
                            </div>
                            <div class="rp-zoom-btns">
                                <button class="rp-zoom-btn" onclick="document.getElementById('btn-zoom-in').click()" title="Zoom +">+</button>
                                <button class="rp-zoom-btn" onclick="document.getElementById('btn-zoom-out').click()" title="Zoom -">&minus;</button>
                                <button class="rp-zoom-btn rp-zoom-btn--reset" onclick="document.getElementById('btn-zoom-reset').click()" title="R&eacute;initialiser">&#8635; Reset</button>
                            </div>
                        </div>

                        <hr class="rp-ctrl-divider">

                        <!-- ── Légende ── -->
                        <div class="rp-ctrl-section">
                            <div class="rp-ctrl-label">
                                <i class="bi bi-info-circle-fill"></i>
                                L&eacute;gende
                            </div>
                            <div style="display:flex;flex-direction:column;gap:8px;">
                                <div class="rp-legend-item">
                                    <span class="rp-legend-dot" style="background:linear-gradient(135deg,#b2d235,#283a97);"></span>
                                    <span>Taille &amp; distance = score de compatibilit&eacute;</span>
                                </div>
                                <div class="rp-legend-item">
                                    <span class="rp-legend-dot" style="background:linear-gradient(135deg,#536ae4,#283a97);"></span>
                                    <span>Couleur = parcours / fili&egrave;re</span>
                                </div>
                                <div class="rp-legend-item">
                                    <i class="bi bi-arrows-move" style="color:var(--itu-blue,#008BFF);flex-shrink:0;font-size:13px;"></i>
                                    <span>Glisser pour naviguer</span>
                                </div>
                                <div class="rp-legend-item">
                                    <i class="bi bi-zoom-in" style="color:var(--itu-blue,#008BFF);flex-shrink:0;font-size:13px;"></i>
                                    <span>Molette / pincer pour zoomer</span>
                                </div>
                            </div>
                        </div>

                    </div><!-- /.rp-ctrl-body -->
                </div><!-- /.rp-ctrl-panel -->
            </aside><!-- /.rp-controls-col -->

        </div><!-- /.rp-layout -->
    </section>
</div><!-- /.rp-page-wrapper -->

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
    grad.addColorStop(0, "#1c1e29");
    grad.addColorStop(1, "#1c1e21");
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
        ctx.strokeStyle = "rgba(40,58,151,0.10)";
        ctx.lineWidth = 1 / viewScale;
        ctx.setLineDash([5 / viewScale, 10 / viewScale]);
        ctx.stroke();
        ctx.setLineDash([]);
        if (viewScale > 0.35) {
            ctx.fillStyle = "rgba(83,106,228,0.28)";
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
        // Masquer l'arête si l'un des nœuds est filtré par le seuil
        if (!nA.isSelf && nA.score < seuilActif) return;
        if (!nB.isSelf && nB.score < seuilActif) return;
        var isHov = hoveredNode && (hoveredNode.id === nA.id || hoveredNode.id === nB.id);
        var alpha = Math.max(0.15, Math.min(0.78, 0.15 + e.score / 100 * 0.63));
        if (isHov) alpha = Math.min(0.95, alpha * 3);
        ctx.save();
        ctx.beginPath();
        ctx.moveTo(nA.dx, nA.dy);
        ctx.lineTo(nB.dx, nB.dy);
        ctx.strokeStyle = isHov ? "rgba(178,210,53," + alpha + ")" : "rgba(40,58,151," + alpha + ")";
        ctx.lineWidth = (isHov ? 2.5 : Math.max(0.8, e.score / 100 * 2.0)) / viewScale;
        if (isHov) { ctx.shadowColor = "#b2d235"; ctx.shadowBlur = 8; }
        ctx.stroke();
        ctx.restore();
    });

    // --- 2. Nœuds ---
    nodes.forEach(function(n) {
        if (n.dx === undefined) return;
        // Masquer les nœuds dont le score est en dessous du seuil (sauf self)
        if (!n.isSelf && n.score < seuilActif) return;
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
            ctx.strokeStyle = "rgba(178,210,53," + (0.15 + 0.1 * Math.sin(pulseT * 2)) + ")";
            ctx.lineWidth = 2 / viewScale;
            ctx.stroke();

            var pulseR2 = r + 22 + Math.sin(pulseT * 1.3 + 1) * 8;
            ctx.beginPath();
            ctx.arc(x, y, pulseR2, 0, Math.PI * 2);
            ctx.strokeStyle = "rgba(178,210,53," + (0.06 + 0.04 * Math.sin(pulseT * 1.3)) + ")";
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
            g.addColorStop(0, "#b2d235");
            g.addColorStop(1, "#283a97");
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
            ? "rgba(178,210,53,0.85)"
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
            ctx.fillStyle = isHov ? "#d0dce7" : (n.isSelf ? "#b2d235" : "rgba(208,220,231,0.75)");
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
        // Ignorer les nœuds filtrés par le seuil
        if (!n.isSelf && n.score < seuilActif) return;
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

// --- Click-to-profile: track drag distance to distinguish click from pan ---
var dragStartPos = null;
var DRAG_THRESHOLD = 5; // px — below this threshold, treat as click

canvas.addEventListener("mousedown", function(e) {
    if (e.button !== 0) return;
    isPanning = true;
    panStart = {x: e.clientX - panX, y: e.clientY - panY};
    dragStartPos = {x: e.clientX, y: e.clientY};
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

window.addEventListener("mouseup", function(e) {
    if (isPanning) {
        isPanning = false;
        canvas.style.cursor = "grab";
        // Detect click (not drag) on a node → navigate to profile
        if (dragStartPos) {
            var dxDrag = e.clientX - dragStartPos.x;
            var dyDrag = e.clientY - dragStartPos.y;
            if (Math.sqrt(dxDrag * dxDrag + dyDrag * dyDrag) < DRAG_THRESHOLD) {
                var rect = canvas.getBoundingClientRect();
                var clickedNode = hitTest(e.clientX - rect.left, e.clientY - rect.top);
                if (clickedNode && !clickedNode.isSelf && clickedNode.idprofil) {
                    window.location.href = "<%= ctx %>/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp&idprofil=" + encodeURIComponent(clickedNode.idprofil);
                } else if (clickedNode && clickedNode.isSelf) {
                    window.location.href = "<%= ctx %>/pages/module.jsp?but=profil/voir.jsp&currentMenu=MENDYN000009";
                }
            }
            dragStartPos = null;
        }
    }
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
        dragStartPos = {x: e.touches[0].clientX, y: e.touches[0].clientY};
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

canvas.addEventListener("touchend", function(e) {
    if (isPanning && dragStartPos && e.changedTouches.length === 1) {
        var touch = e.changedTouches[0];
        var dxT = touch.clientX - dragStartPos.x;
        var dyT = touch.clientY - dragStartPos.y;
        if (Math.sqrt(dxT * dxT + dyT * dyT) < DRAG_THRESHOLD) {
            var rect = canvas.getBoundingClientRect();
            var tappedNode = hitTest(touch.clientX - rect.left, touch.clientY - rect.top);
            if (tappedNode && !tappedNode.isSelf && tappedNode.idprofil) {
                window.location.href = "<%= ctx %>/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp&idprofil=" + encodeURIComponent(tappedNode.idprofil);
            } else if (tappedNode && tappedNode.isSelf) {
                window.location.href = "<%= ctx %>/pages/module.jsp?but=profil/voir.jsp&currentMenu=MENDYN000009";
            }
        }
    }
    isPanning = false;
    touches0 = null;
    dragStartPos = null;
});

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

    var scoreColor = n.score >= 70 ? "#b2d235" : (n.score >= 40 ? "#facc15" : "#fd3022");
    var tagsHtml = n.tags && n.tags.length
        ? n.tags.slice(0, 5).map(function(t) {
            return "<span class='tt-tag'>" + escHtml(t) + "</span>";
          }).join("")
        : "<em style='color:#475569'>Pas de tag commun</em>";

    tooltip.innerHTML =
        "<div class='tt-name'>" + escHtml((n.prenom || "") + " " + (n.nom || "")) + "</div>" +
        "<div class='tt-score'>Compatibilit&eacute; : <b style='color:" + scoreColor + "'>" + n.score + "%</b></div>" +
        "<div class='tt-bar'><div class='tt-bar-fill' style='width:" + n.score + "%'></div></div>" +
        "<div class='tt-tags'><b>Tags communs :</b><br>" + tagsHtml + "</div>" +
        (!n.isSelf ? "<div style='margin-top:10px;text-align:center;font-size:12px;color:#536ae4;font-weight:600;'><i class='bi bi-box-arrow-up-right' style='margin-right:4px;'></i>Cliquer pour voir le profil</div>" : "");

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
            idprofil:  n.idprofil || "",
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
window.setAfficherLabels = function(v) { afficherLabels = v; };
window.setFlotterActif   = function(v) { flotterActif = v; };

resizeCanvas();
window.addEventListener("resize", resizeCanvas);

// Démarrer la boucle de rendu
render();

// Charger les données
chargerReseau();

})();
</script>
