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
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.Evenement" %>
<%@ page import="alumni.Identification" %>
<%@ page import="alumni.Limiterole" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="alumni.FeedHtmlService" %>
<%@ page import="alumni.Promotion" %>
<%@ page import="alumni.Parcours" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
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

    // --- Charger specialites et promotions (hashtag / filtre / visibilite) ---
    Specialite[] allSpecialites = (Specialite[]) CGenUtil.rechercher(new Specialite(), null, null, " order by libelle");
    if (allSpecialites == null) allSpecialites = new Specialite[0];
    Promotion[] allPromotions = (Promotion[]) CGenUtil.rechercher(new Promotion(), null, null, " order by annee desc");
    if (allPromotions == null) allPromotions = new Promotion[0];
    Parcours[] allParcours = (Parcours[]) CGenUtil.rechercher(new Parcours(), null, null, " order by libelle");
    if (allParcours == null) allParcours = new Parcours[0];

    // Charger photo profil/couverture du connecte + 3 evenements a venir + limite pub
    String _connPhotoUrl = "";
    String _connCoverUrl = "";
    Evenement[] _upEvents = new Evenement[0];
    int _maxPubParJour = -1; // -1 = pas de limite
    int _pubRestantes = -1;  // -1 = illimite
    boolean _aUneLimite = false;
    {
        Connection _c = null;
        try {
            _c = new UtilDB().GetConn();
            ProfilLib[] _myProfils = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, _c, " and refuser=" + refuserConnecte);
            if (_myProfils != null && _myProfils.length > 0) {
                if (_myProfils[0].getPhotoProfil() != null && !_myProfils[0].getPhotoProfil().trim().isEmpty())
                    _connPhotoUrl = ctx + "/" + _myProfils[0].getPhotoProfil().trim();
                if (_myProfils[0].getPhotoCouverture() != null && !_myProfils[0].getPhotoCouverture().trim().isEmpty())
                    _connCoverUrl = ctx + "/" + _myProfils[0].getPhotoCouverture().trim();
            }
            _upEvents = (Evenement[]) CGenUtil.rechercher(new Evenement(), null, null, _c, " and datedebut >= CURRENT_DATE order by datedebut asc");
            if (_upEvents == null) _upEvents = new Evenement[0];

            // --- Limite de publication par role ---
            _maxPubParJour = Limiterole.getMaxParJour(_c, mapFil.getIdrole());
            _aUneLimite = (_maxPubParJour >= 0);
            _pubRestantes = Limiterole.publicationsRestantes(_c, mapFil.getIdrole(), refuserConnecte);
        } catch (Exception _e) { _e.printStackTrace(); }
        finally { if (_c != null) try { _c.close(); } catch (Exception _x) {} }
    }
    boolean _peutPublier = (_maxPubParJour < 0) || (_pubRestantes > 0);
%>

<!-- Styles extracted to external CSS files -->
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/pages/accueil-page.css" />

<div class="fa-layout">

    <!-- ===== COLONNE GAUCHE : Profil ===== -->
    <aside class="fa-sidebar-left">
        <div class="fa-profile-card">
            <div class="fa-profile-cover"<%= !_connCoverUrl.isEmpty() ? " style=\"background:none;\"" : "" %>><% if (!_connCoverUrl.isEmpty()) { %><img src="<%= _connCoverUrl %>" alt="" style="width:100%;height:100%;object-fit:cover;display:block;"><% } %></div>
            <div class="fa-profile-body">
                <div class="fa-profile-avatar-wrap">
                    <div class="fa-avatar fa-avatar--lg"<%= !_connPhotoUrl.isEmpty() ? " style=\"background:transparent;\"" : "" %>><% if (!_connPhotoUrl.isEmpty()) { %><img src="<%= _connPhotoUrl %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= initialConnecte %><% } %></div>
                </div>
                <div class="fa-profile-name"><%= nomConnecte %></div>
                <hr class="fa-divider">
                <nav class="fa-profile-nav">
                    <a href="<%= ctx %>/pages/module.jsp?but=profil/voir.jsp&currentMenu=MENDYN000009" class="fa-nav-link">
                        <i class="bi bi-person-fill"></i> Mon profil
                    </a>
                    <a href="#" class="fa-nav-link fa-nav-link--active">
                        <i class="bi bi-newspaper"></i> Fil d&apos;actualit&eacute;
                    </a>
                    <a href="<%= ctx %>/pages/module.jsp?but=alumni/notifications.jsp" class="fa-nav-link">
                        <i class="bi bi-bell-fill"></i> Notifications
                    </a>
                    <a href="<%= ctx %>/pages/module.jsp?but=alumni/publications-enregistrees.jsp" class="fa-nav-link">
                        <i class="bi bi-bookmarks-fill"></i> Enregistrements
                    </a>
                </nav>
            </div>
        </div>

        <!-- ===== PANNEAU FILTRE ===== -->
        <div class="fa-filter-panel">
            <div class="fa-filter-panel-header">
                <span class="fa-filter-panel-title">
                    <i class="bi bi-sliders fa-widget-icon"></i> Filtres
                </span>
                <button type="button" class="fa-filter-reset-icon" id="filter-reset-icon-btn" title="Réinitialiser et actualiser" onclick="reinitialiserFiltreEtActualiser()" style="">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
            </div>
            <div class="fa-filter-panel-body">
                <!-- Spécialité -->
                <div class="fa-filter-group">
                    <label class="fa-filter-group-label"><i class="bi bi-mortarboard-fill"></i>&nbsp;Sp&eacute;cialit&eacute;</label>
                    <div class="fa-filter-dropdown">
                        <div class="fa-filter-dropdown-trigger" id="filter-spec-trigger" onclick="toggleFilterDropdown('spec')">
                            <span id="filter-spec-label">S&eacute;lectionner...</span>
                            <i class="bi bi-chevron-down fa-filter-dropdown-icon"></i>
                        </div>
                        <div class="fa-filter-dropdown-menu" id="filter-spec-menu">
                            <% for (int _fi=0;_fi<allSpecialites.length;_fi++){%>
                            <div class="fa-filter-dropdown-item" onclick="selectFilterOption('spec','<%= allSpecialites[_fi].getLibelle().replace("'","\\'") %>')" data-value="<%= allSpecialites[_fi].getLibelle() %>"><%= allSpecialites[_fi].getLibelle() %></div>
                            <% } %>
                        </div>
                        <input type="hidden" id="filter-spec-input" value="">
                    </div>
                </div>
                <!-- Parcours -->
                <div class="fa-filter-group">
                    <label class="fa-filter-group-label"><i class="bi bi-diagram-3-fill"></i>&nbsp;Parcours</label>
                    <div class="fa-filter-dropdown">
                        <div class="fa-filter-dropdown-trigger" id="filter-parc-trigger" onclick="toggleFilterDropdown('parc')">
                            <span id="filter-parc-label">S&eacute;lectionner...</span>
                            <i class="bi bi-chevron-down fa-filter-dropdown-icon"></i>
                        </div>
                        <div class="fa-filter-dropdown-menu" id="filter-parc-menu">
                            <% for (int _fi=0;_fi<allParcours.length;_fi++){%>
                            <div class="fa-filter-dropdown-item" onclick="selectFilterOption('parc','<%= allParcours[_fi].getLibelle().replace("'","\\'") %>')" data-value="<%= allParcours[_fi].getLibelle() %>"><%= allParcours[_fi].getLibelle() %></div>
                            <% } %>
                        </div>
                        <input type="hidden" id="filter-parc-input" value="">
                    </div>
                </div>
                <!-- Promotion -->
                <div class="fa-filter-group">
                    <label class="fa-filter-group-label"><i class="bi bi-calendar-fill"></i>&nbsp;Promotion</label>
                    <input id="filter-promo-input" class="fa-filter-group-input" placeholder="ex: 2023+" maxlength="6" autocomplete="off" >
                </div>
                <!-- Type de publication : liste single-select -->
                <div class="fa-filter-group">
                    <div class="fa-filter-group-label"><i class="bi bi-tag-fill"></i>&nbsp;Type de publication</div>
                    <div class="fa-typepub-list" id="typepub-list">
                        <% for (int _fi=0;_fi<typesPub.length;_fi++){%>
                        <div class="fa-typepub-item" onclick="selectTypePub(this,'<%= typesPub[_fi].getLibelle().replace("'","\\'") %>')" data-libelle="<%= typesPub[_fi].getLibelle() %>">
                            <span class="fa-typepub-dot"></span>
                            <%= typesPub[_fi].getLibelle() %>
                        </div>
                        <% } %>
                    </div>
                    <input type="hidden" id="filter-typepub-input" value="">
                </div>
                <!-- Lier critères -->
                <label class="fa-filter-lier-row" title="Relier les crit&egrave;res (ET)">
                    <input type="checkbox" id="filter-lier">&nbsp;Lier les crit&egrave;res
                </label>
            </div>
            <div class="fa-filter-panel-footer">
                <button type="button" class="fa-filter-btn-apply" onclick="appliquerFiltre()">
                    <i class="bi bi-funnel-fill"></i>&nbsp;Appliquer
                </button>
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
        <% if (_maxPubParJour != 0) { %>
        <div class="fa-composer-card" id="composer-card"<%= (!_peutPublier) ? " style=\"opacity:0.5;pointer-events:none;\"" : "" %>>
            <div class="fa-composer-trigger" id="composer-trigger" onclick="openComposer()">
                <div class="fa-avatar fa-avatar--sm"<%= !_connPhotoUrl.isEmpty() ? " style=\"background:transparent;\"" : "" %>><% if (!_connPhotoUrl.isEmpty()) { %><img src="<%= _connPhotoUrl %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= initialConnecte %><% } %></div>
                <div class="fa-composer-placeholder">Quoi de neuf&nbsp;?<% if (_aUneLimite && _maxPubParJour > 0) { %> (<%= _pubRestantes %>/<%= _maxPubParJour %> restante<%= _pubRestantes > 1 ? "s" : "" %>)<% } %></div>
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
                      action="<%= ctx %>/pages/alumni/ajax/creer-publication.jsp"
                      onsubmit="return validatePubFormSize()">
                    <div class="fa-composer-header">
                        <div class="fa-avatar fa-avatar--md"<%= !_connPhotoUrl.isEmpty() ? " style=\"background:transparent;\"" : "" %>><% if (!_connPhotoUrl.isEmpty()) { %><img src="<%= _connPhotoUrl %>" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"><% } else { %><%= initialConnecte %><% } %></div>
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
                        <div id="composer-media-grid" class="fa-media-preview-grid count-0"></div>
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
                    <!-- Zone visibilite -->
                    <div class="fa-vis-section" id="vis-section">
                        <div class="fa-vis-header" onclick="toggleVisSection()">
                            <i class="bi bi-globe2" id="vis-icon"></i>
                            <span id="vis-summary">Visible par tous</span>
                            <i class="bi bi-chevron-down" id="vis-chevron" style="margin-left:auto;font-size:12px;"></i>
                        </div>
                        <!-- Datalists visibilite -->
                        <datalist id="dl-vis-spec"><% for(int _vi=0;_vi<allSpecialites.length;_vi++){%><option value="<%= allSpecialites[_vi].getLibelle() %>"><% } %></datalist>
                        <datalist id="dl-vis-parc"><% for(int _vi=0;_vi<allParcours.length;_vi++){%><option value="<%= allParcours[_vi].getLibelle() %>"><% } %></datalist>
                        <div class="fa-vis-body" id="vis-body" style="display:none;">
                            <div class="fa-vis-group">
                                <div class="fa-vis-label">Sp&eacute;cialit&eacute;s</div>
                                <div class="fa-vis-tag-row">
                                    <input list="dl-vis-spec" id="vis-spec-input" class="fa-vis-tag-input" placeholder="Ajouter une sp&eacute;cialit&eacute;..." autocomplete="off" oninput="" onkeydown="onVisTagKey(event,'spec')">
                                    <button type="button" class="fa-vis-tag-add" onclick="addVisTagFromInput('spec')"><i class="bi bi-plus"></i></button>
                                </div>
                                <div class="fa-vis-chips" id="vis-spec-chips"></div>
                            </div>
                            <div class="fa-vis-group">
                                <div class="fa-vis-label">Parcours</div>
                                <div class="fa-vis-tag-row">
                                    <input list="dl-vis-parc" id="vis-parc-input" class="fa-vis-tag-input" placeholder="Ajouter un parcours..." autocomplete="off" onkeydown="onVisTagKey(event,'parc')">
                                    <button type="button" class="fa-vis-tag-add" onclick="addVisTagFromInput('parc')"><i class="bi bi-plus"></i></button>
                                </div>
                                <div class="fa-vis-chips" id="vis-parc-chips"></div>
                            </div>
                            <div class="fa-vis-group">
                                <div class="fa-vis-label">Promotion (ann&eacute;e)</div>
                                <div class="fa-vis-tag-row" style="position:relative;">
                                    <input id="vis-promo-input" class="fa-vis-tag-input" placeholder="ex: 2023 &rarr; 2023+ ou 2023-" maxlength="5" autocomplete="off"
                                           oninput="onVisPromoInput()" onkeydown="onVisPromoKey(event)">
                                    <button type="button" class="fa-vis-tag-add" onclick="addVisPromoFromInput()"><i class="bi bi-plus"></i></button>
                                    <div class="fa-vis-promo-dd" id="vis-promo-dd" style="display:none;"></div>
                                </div>
                                <div class="fa-vis-chips" id="vis-promo-chips"></div>
                            </div>
                            <div class="fa-vis-group" id="vis-lier-group">
                                <label style="font-size:13px;display:flex;align-items:center;gap:6px;cursor:pointer;">
                                    <input type="checkbox" id="vis-lier-check" onchange="updateVisHidden()">
                                    Lier les crit&egrave;res (ET : toutes les conditions requises)
                                </label>
                            </div>
                            <input type="hidden" name="vis_spec" id="vis-spec-hidden" value="">
                            <input type="hidden" name="vis_parc" id="vis-parc-hidden" value="">
                            <input type="hidden" name="vis_promo_annee" id="vis-promo-annee-hidden" value="">
                            <input type="hidden" name="vis_lier" id="vis-lier-hidden" value="OR">
                        </div>
                    </div>
                    <div class="fa-composer-footer">
                        <label class="fa-attach-btn">
                            <i class="bi bi-image"></i>&nbsp;Photo/Vid&eacute;o
                            <input type="file" id="composer-img-input" name="media" accept="image/*,video/mp4" multiple style="display:none;"
                                   onchange="previewComposerMedia(this)">
                        </label>
                        <div class="fa-composer-submit-group">
                            <button type="button" class="fa-btn-cancel" onclick="closeComposer()">Annuler</button>
                            <button type="submit" class="fa-btn-publish">Publier</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <% } %>

        <!-- ===== PUBLICATIONS (composant réutilisable) ===== -->
        <%
            try {
                // Appel du service (gere sa propre connexion, pre-charge medias/reactions/etc.)
                Map data = FeedHtmlService.chargerFeed(refuserConnecte,
                        nomConnecte != null ? nomConnecte : "", ctx,
                        Integer.MAX_VALUE, "ZZZZZZZZZZZZZZZZZZZ",
                        "", "", "", "", "");

                Publication[] pubs = (Publication[]) data.get("pubs");
                String _lastScore = "0";
                Integer _nextScoreObj = (Integer) data.get("nextScore");
                if (_nextScoreObj != null) _lastScore = _nextScoreObj.toString();

                // Passer les donnees au composant via request attributes
                request.setAttribute("_pub_lastScore", _lastScore);
                request.setAttribute("_pub_pubs", pubs);
                request.setAttribute("_pub_userNames", data.get("userNames"));
                request.setAttribute("_pub_userPhotos", data.get("userPhotos"));
                request.setAttribute("_pub_userProfils", data.get("userProfils"));
                request.setAttribute("_pub_userBanned", data.get("userBanned"));
                request.setAttribute("_pub_reactTypes", data.get("reactTypes"));
                request.setAttribute("_pub_typesPub", data.get("typesPub"));
                request.setAttribute("_pub_refuser", new Integer(refuserConnecte));
                request.setAttribute("_pub_initialConnecte", initialConnecte);
                request.setAttribute("_pub_connPhotoUrl", _connPhotoUrl);
                request.setAttribute("_pub_ctx", ctx);
                // Donnees pre-chargees par publication
                request.setAttribute("_pub_pubMedias", data.get("pubMedias"));
                request.setAttribute("_pub_pubReactions", data.get("pubReactions"));
                request.setAttribute("_pub_pubComments", data.get("pubComments"));
                request.setAttribute("_pub_pubIdents", data.get("pubIdentifications"));
                request.setAttribute("_pub_pubSaved", data.get("pubSaved"));
                request.setAttribute("_pub_origPubs", data.get("origPubs"));
                request.setAttribute("_pub_origMedias", data.get("origMedias"));
        %>
        <jsp:include page="publication.jsp" />
        <%
        } catch (Exception e) {
            e.printStackTrace();
        %>
        <div class="fa-error-box">
            <i class="bi bi-exclamation-triangle-fill"></i>&nbsp;Erreur publications&nbsp;: <%= e.getMessage() %>
        </div>
        <%
            }
        %>

    </main><!-- /fa-feed-center -->

    <!-- ===== COLONNE DROITE : Événements à venir ===== -->
    <aside class="fa-sidebar-right">

        <!-- Widget : Événements à venir -->
        <div class="fa-widget-card" id="widget-evenements">
            <div class="fa-widget-header">
                <i class="bi bi-calendar-event-fill fa-widget-icon"></i>
                <span class="fa-widget-title">&Eacute;v&eacute;nements &agrave; venir</span>
            </div>
            <div class="fa-widget-body" id="evenements-list">
                <%
                    String[] _moisCourt = {"jan","f\u00E9v","mar","avr","mai","jun","jul","ao\u00FB","sep","oct","nov","d\u00E9c"};
                    int _evtMax = Math.min(_upEvents.length, 3);
                    if (_evtMax == 0) {
                %>
                <div style="padding:16px;text-align:center;color:#999;font-size:13px;">Aucun &eacute;v&eacute;nement &agrave; venir</div>
                <% } else {
                    for (int _ei = 0; _ei < _evtMax; _ei++) {
                        Evenement _ev = _upEvents[_ei];
                        String _evDesc = _ev.getDescription() != null ? _ev.getDescription() : "\u00C9v\u00E9nement";
                        String _evDescSafe = _evDesc.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
                        if (_evDescSafe.length() > 40) _evDescSafe = _evDescSafe.substring(0, 40) + "...";
                        String _evDay = "--"; String _evMon = "---";
                        if (_ev.getDatedebut() != null) {
                            java.util.Calendar _cal = java.util.Calendar.getInstance();
                            _cal.setTime(_ev.getDatedebut());
                            _evDay = String.valueOf(_cal.get(java.util.Calendar.DAY_OF_MONTH));
                            _evMon = _moisCourt[_cal.get(java.util.Calendar.MONTH)];
                        }
                %>
                <div class="fa-event-item">
                    <div class="fa-event-date-badge">
                        <span class="fa-event-day"><%= _evDay %></span>
                        <span class="fa-event-month"><%= _evMon %></span>
                    </div>
                    <div class="fa-event-info">
                        <div class="fa-event-title"><%= _evDescSafe %></div>
                        <div class="fa-event-meta"><i class="bi bi-calendar-event"></i>&nbsp;<%= _ev.getDatedebut() %></div>
                    </div>
                </div>
                <% } } %>
            </div>
            <div class="fa-widget-footer">
                <a href="<%= ctx %>/pages/module.jsp?but=evenement/evenement-calendar.jsp" class="fa-widget-link">Voir tous les &eacute;v&eacute;nements &rarr;</a>
            </div>
        </div>

    </aside>

</div><!-- /fa-layout -->

<!-- ==================== MODALE REACTIONS ==================== -->
<div id="react-detail-modal">
    <div class="react-detail-box">
        <div id="react-detail-content"></div>
    </div>
</div>

<!-- ==================== MODALE PARTAGE ==================== -->
<div id="share-modal">
    <div class="share-box">
        <div class="share-header">
            <h3 class="share-title">Partager la publication</h3>
            <button class="rdm-close" onclick="closeShareModal()">&times;</button>
        </div>
        <div class="share-body">
            <textarea id="share-description" class="share-textarea" placeholder="Dites quelque chose... (optionnel)"></textarea>
            <div class="share-original" id="share-original-preview">
                <div class="share-orig-author" id="share-orig-author"></div>
                <div class="share-orig-date" id="share-orig-date"></div>
                <div class="share-orig-text" id="share-orig-text"></div>
            </div>
        </div>
        <div class="share-footer">
            <button class="share-cancel-btn" onclick="closeShareModal()">Annuler</button>
            <button class="share-submit-btn" id="share-submit-btn" onclick="submitShare()"><i class="bi bi-send-fill"></i>&nbsp;Partager</button>
        </div>
    </div>
</div>

<!-- ==================== MODALE DETAIL PUBLICATION (Facebook-style) ==================== -->
<div id="pub-detail-modal">
    <div class="pub-fb-box" id="pub-fb-box">
        <button class="pub-fb-close" onclick="closePublicationDetail()">&times;</button>
        <div class="pub-fb-media" id="pub-fb-media">
            <div class="pub-fb-media-content" id="pub-fb-media-content"></div>
            <button class="pub-fb-nav pub-fb-nav-prev" id="pub-fb-prev" onclick="pubFbNavPrev()"><i class="bi bi-chevron-left"></i></button>
            <button class="pub-fb-nav pub-fb-nav-next" id="pub-fb-next" onclick="pubFbNavNext()"><i class="bi bi-chevron-right"></i></button>
            <div class="pub-fb-media-counter" id="pub-fb-counter"></div>
        </div>
        <div class="pub-fb-details" id="pub-fb-details">
            <div style="text-align:center;padding:40px;"><div class="fa-feed-spinner"></div></div>
        </div>
    </div>
</div>

<!-- ==================== JAVASCRIPT ==================== -->
<script>
    var CTX = '<%= ctx %>';
    var CURRENT_USER_ID = '<%= refuserConnecte %>';
    var CONN_PHOTO = '<%= _connPhotoUrl %>';
    // ---- Maps libelle -> idref pour les filtres ----
    var _SPEC_MAP = {<% for(int _mi=0;_mi<allSpecialites.length;_mi++){if(_mi>0)out.print(","); out.print("\"" + allSpecialites[_mi].getLibelle().replace("\\","\\\\").replace("\"","\\\"") + "\":\"" + allSpecialites[_mi].getIdspecialite() + "\""); } %>};
    var _PARC_MAP = {<% for(int _mi=0;_mi<allParcours.length;_mi++){if(_mi>0)out.print(","); out.print("\"" + allParcours[_mi].getLibelle().replace("\\","\\\\").replace("\"","\\\"") + "\":\"" + allParcours[_mi].getIdparcours() + "\""); } %>};
    var _TYPEPUB_MAP = {<% for(int _mi=0;_mi<typesPub.length;_mi++){if(_mi>0)out.print(","); out.print("\"" + typesPub[_mi].getLibelle().replace("\\","\\\\").replace("\"","\\\"") + "\":\"" + typesPub[_mi].getIdtypepublication() + "\""); } %>};

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

    // ========== RAFRAICHIR CARTE PUBLICATION (sans recharger la page) ==========
    function _refreshPublicationCard(idpub) {
        fetch(CTX + '/pages/alumni/ajax/voir-publication.jsp?idpublication=' + encodeURIComponent(idpub))
            .then(function(r) { return r.text(); })
            .then(function(html) {
                var card = document.getElementById('pub-' + idpub);
                if (!card) return;
                var commDiv = document.getElementById('commentaires-' + idpub);
                var wasCommOpen = commDiv && commDiv.style.display !== 'none';
                var isInModal = !!card.closest('#pub-fb-details');
                var temp = document.createElement('div');
                temp.innerHTML = html;
                var newCard = temp.querySelector('.fa-post-card');
                if (!newCard) return;
                card.parentNode.replaceChild(newCard, card);
                if (wasCommOpen) {
                    var nc = document.getElementById('commentaires-' + idpub);
                    if (nc) { nc.style.display = 'block'; chargerCommentaires(idpub); }
                }
                if (isInModal) {
                    var mg = newCard.querySelector('.fa-media-grid');
                    if (mg) mg.style.display = 'none';
                    newCard.removeAttribute('onclick');
                    newCard.style.cursor = 'default';
                }
            })
            .catch(function(e) { console.error('Erreur refresh card:', e); });
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
                    _refreshPublicationCard(idpub);
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

                    if (c.banned) {
                        // Utilisateur banni — avatar generique, pas de lien
                        html += '<div class="fa-avatar fa-avatar--xs" style="background:#ccc;color:#888;cursor:default;"><i class="bi bi-person-slash" style="font-size:0.8em;"></i></div>';
                        html += '<div class="fa-comment-content">';
                        html += '<div class="fa-comment-bubble">';
                        html += '<span class="fa-comment-author" style="color:#888;cursor:default;"><i class="bi bi-person-slash"></i> ' + escHtml(c.auteur) + '</span>';
                        html += '<span class="fa-comment-text">' + formatMentions(c.description) + '</span>';
                        html += '</div>';
                    } else {
                    var profileUrl;
                    if (c.idutilisateur === data.refuser) {
                        // C'est mon commentaire, aller vers mon profil
                        profileUrl = CTX + '/pages/module.jsp?but=profil/voir.jsp';
                    } else {
                        // C'est le commentaire d'un autre utilisateur
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
                    } // fin else (non banni)

                    // Calcul total reactions + lib de ma reaction (c.reactions est maintenant un tableau trié)
                    var totalCReact = 0;
                    var myCommReactLib = '';
                    for (var jr = 0; jr < c.reactions.length; jr++) {
                        totalCReact += c.reactions[jr].count || 0;
                        if (c.myReaction === c.reactions[jr].id) myCommReactLib = c.reactions[jr].libelle;
                    }
                    var hasCommReact = (c.myReaction && c.myReaction !== '');

                    // Barre d'actions
                    html += '<div class="fa-comment-actions">';

                    // Afficher les reactions avec emojis (triées par count)
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

                    // Reaction wrap (barre popup)

                    html += '<div class="fa-reaction-wrap" id="creact-wrap-' + c.id + '" style="display:inline-flex;position:relative;flex:none;">';
                    html += '<button class="fa-comment-react-btn' + (hasCommReact ? ' fa-comment-react-btn--active' : '') + '" ';
                    html += 'id="creact-btn-' + c.id + '" ';
                    html += 'onclick="toggleCommReactionBar(\'' + c.id + '\', event)">';
                    html += '<i class="bi bi-hand-thumbs-up' + (hasCommReact ? '-fill' : '') + '" style="font-size:11px;margin-right:3px;"></i>';
                    html += hasCommReact ? myCommReactLib : 'J&apos;aime';
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
                if (_callback) setTimeout(_callback, 60);
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
                    chargerCommentaires(idpub, function() {
                        var _liste = document.getElementById('liste-comm-' + idpub);
                        if (_liste && _liste.lastElementChild)
                            _liste.lastElementChild.scrollIntoView({behavior:'smooth', block:'nearest'});
                    });
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
                    chargerCommentaires(idpub, function() {
                        var _el = document.getElementById('comm-' + idparent);
                        if (_el) _el.scrollIntoView({behavior:'smooth', block:'nearest'});
                    });
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
            // Publication ciblée (like, notification...) — on tente en boucle
            // pour couvrir le cas où la publication est chargée en lazy
            var _pubAttempts = 0;
            var _pubInterval = setInterval(function() {
                _pubAttempts++;
                var el = document.getElementById(scrollTo);
                if (el) {
                    clearInterval(_pubInterval);
                    el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    el.style.background = '#fffde7';
                    el.style.borderLeft = '4px solid #f9a825';
                    el.style.transition = 'background 0.3s';
                    setTimeout(function() { el.style.background = ''; el.style.borderLeft = ''; }, 4000);
                }
                // Après 5 tentatives (~2.5s), déclencher le chargement suivant
                if (_pubAttempts === 5) {
                    var sentinel = document.getElementById('feed-sentinel');
                    if (sentinel) sentinel.scrollIntoView();
                }
                if (_pubAttempts > 20) clearInterval(_pubInterval);
            }, 500);
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
    // ========== COMPOSER MULTI-MEDIA PREVIEW ==========
    var _composerFiles = []; // {file, url, type}
    var _MAX_FILE_SIZE = 50 * 1024 * 1024; // 50 Mo
    function previewComposerMedia(input) {
        if (!input.files || input.files.length === 0) return;
        var rejected = [];
        for (var i = 0; i < input.files.length; i++) {
            var f = input.files[i];
            if (f.size > _MAX_FILE_SIZE) {
                var sizeMB = (f.size / (1024 * 1024)).toFixed(1);
                rejected.push(f.name + ' (' + sizeMB + ' Mo)');
                continue;
            }
            var isVideo = f.type && f.type.startsWith('video/');
            _composerFiles.push({file: f, url: URL.createObjectURL(f), type: isVideo ? 'video' : 'image'});
        }
        if (rejected.length > 0) {
            Swal.fire({icon:'error', title:'Fichier trop volumineux',
                html:'La taille maximale autoris\u00e9e est de 50 Mo.<br>' + rejected.join('<br>'),
                confirmButtonColor:'#1877f2'});
        }
        renderComposerMediaGrid();
        syncComposerFileInput();
    }
    function renderComposerMediaGrid() {
        var grid = document.getElementById('composer-media-grid');
        var wrap = document.getElementById('composer-img-preview');
        grid.innerHTML = '';
        grid.className = 'fa-media-preview-grid count-' + _composerFiles.length;
        if (_composerFiles.length === 0) { wrap.style.display = 'none'; return; }
        wrap.style.display = 'block';
        for (var i = 0; i < _composerFiles.length; i++) {
            var item = document.createElement('div');
            item.className = 'fa-media-preview-item';
            if (_composerFiles[i].type === 'video') {
                var vid = document.createElement('video');
                vid.src = _composerFiles[i].url;
                vid.muted = true;
                vid.preload = 'metadata';
                item.appendChild(vid);
                var badge = document.createElement('span');
                badge.className = 'fa-media-preview-video-badge';
                badge.innerHTML = '<i class="bi bi-play-fill"></i> Vid\u00e9o';
                item.appendChild(badge);
            } else {
                var img = document.createElement('img');
                img.src = _composerFiles[i].url;
                item.appendChild(img);
            }
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'fa-media-preview-remove';
            btn.innerHTML = '<i class="bi bi-x-lg"></i>';
            btn.setAttribute('data-idx', i);
            btn.onclick = function(){ removeComposerMediaItem(parseInt(this.getAttribute('data-idx'))); };
            item.appendChild(btn);
            grid.appendChild(item);
        }
    }
    function removeComposerMediaItem(idx) {
        if (idx >= 0 && idx < _composerFiles.length) {
            URL.revokeObjectURL(_composerFiles[idx].url);
            _composerFiles.splice(idx, 1);
        }
        renderComposerMediaGrid();
        syncComposerFileInput();
    }
    function syncComposerFileInput() {
        // Rebuild the file input using DataTransfer
        var inp = document.getElementById('composer-img-input');
        var dt = new DataTransfer();
        for (var i = 0; i < _composerFiles.length; i++) {
            dt.items.add(_composerFiles[i].file);
        }
        inp.files = dt.files;
    }
    function removeComposerImg() {
        for (var i = 0; i < _composerFiles.length; i++) URL.revokeObjectURL(_composerFiles[i].url);
        _composerFiles = [];
        var inp = document.getElementById('composer-img-input');
        if (inp) inp.value = '';
        document.getElementById('composer-img-preview').style.display = 'none';
        document.getElementById('composer-media-grid').innerHTML = '';
    }
    // ========== VALIDATION TAILLE FICHIER ==========
    function validatePubFormSize() {
        var totalSize = 0;
        for (var i = 0; i < _composerFiles.length; i++) {
            if (_composerFiles[i].file.size > _MAX_FILE_SIZE) {
                Swal.fire({icon:'error', title:'Fichier trop volumineux',
                    text:_composerFiles[i].file.name + ' d\u00e9passe la limite de 50 Mo.',
                    confirmButtonColor:'#1877f2'});
                return false;
            }
            totalSize += _composerFiles[i].file.size;
        }
        if (totalSize > _MAX_FILE_SIZE) {
            Swal.fire({icon:'error', title:'Fichiers trop volumineux',
                text:'La taille totale (' + (totalSize / (1024*1024)).toFixed(1) + ' Mo) d\u00e9passe la limite de 50 Mo.',
                confirmButtonColor:'#1877f2'});
            return false;
        }
        return true;
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
                var btn = document.getElementById('save-btn-' + idpub);
                if (btn) {
                    if (d.saved) {
                        btn.innerHTML = '<i class="bi bi-bookmark-fill"></i> Annuler l\'enregistrement';
                    } else {
                        btn.innerHTML = '<i class="bi bi-bookmark"></i> Enregistrer';
                    }
                }
                Swal.fire({toast:true,position:'top-end',icon:'success',title: d.saved ? 'Publication enregistr\u00e9e' : 'Enregistrement annul\u00e9',timer:1500,showConfirmButton:false});
            } else alert('Erreur: ' + (d.error || 'Inconnue'));
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
    function openVideoZoom(src) {
        var overlay = document.createElement('div');
        overlay.className = 'fa-media-overlay';
        overlay.style.cursor = 'default';
        var vid = document.createElement('video');
        vid.src = src; vid.controls = true; vid.autoplay = true;
        vid.style.maxWidth = '92vw'; vid.style.maxHeight = '92vh'; vid.style.borderRadius = '4px';
        vid.addEventListener('click', function(e){ e.stopPropagation(); });
        overlay.appendChild(vid);
        overlay.addEventListener('click', function(){ vid.pause(); document.body.removeChild(overlay); });
        document.addEventListener('keydown', function esc(e){ if(e.key==='Escape'){ vid.pause(); document.body.removeChild(overlay); document.removeEventListener('keydown',esc); } });
        document.body.appendChild(overlay);
    }

    // ========== INFINITE SCROLL (score-based + filtre) ==========
    (function() {
        var loading  = false;
        var cursor   = document.getElementById('feed-cursor');
        var sentinel = document.getElementById('feed-sentinel');
        var loader   = document.getElementById('feed-loader');
        var feed     = document.querySelector('.fa-feed-center');
        if (!cursor || !sentinel || !feed) return;

        function doFetch(score, id) {
            loading = true;
            loader.style.display = 'block';
            var fs  = cursor.getAttribute('data-filter-spec')    || '';
            var fpa = cursor.getAttribute('data-filter-parc')   || '';
            var fp  = cursor.getAttribute('data-filter-promo')  || '';
            var ft  = cursor.getAttribute('data-filter-typepub')|| '';
            var fl  = cursor.getAttribute('data-filter-lier')   || '';
            var url = CTX + '/pages/alumni/ajax/charger-feed.jsp'
                + '?cursor_score='    + encodeURIComponent(score)
                + '&cursor_id='       + encodeURIComponent(id)
                + '&filter_spec='     + encodeURIComponent(fs)
                + '&filter_parc='     + encodeURIComponent(fpa)
                + '&filter_promo='    + encodeURIComponent(fp)
                + '&filter_typepub='  + encodeURIComponent(ft)
                + '&filter_lier='     + encodeURIComponent(fl);
            fetch(url)
                .then(function(r) { return r.text(); })
                .then(function(html) {
                    loader.style.display = 'none';
                    loading = false;
                    var tmp = document.createElement('div');
                    tmp.innerHTML = html;
                    var meta = tmp.querySelector('#feed-meta-new');
                    if (meta) {
                        cursor.setAttribute('data-score',    meta.getAttribute('data-score')    || '0');
                        cursor.setAttribute('data-id',       meta.getAttribute('data-id')       || '');
                        cursor.setAttribute('data-has-more', meta.getAttribute('data-has-more') || 'false');
                        meta.parentNode.removeChild(meta);
                    } else {
                        cursor.setAttribute('data-has-more', 'false');
                    }
                    var cards = tmp.querySelectorAll('.fa-post-card');
                    if (cards.length === 0) cursor.setAttribute('data-has-more', 'false');
                    cards.forEach(function(card) { feed.insertBefore(card, sentinel); });
                    observeViewCards(feed);
                    if (cursor.getAttribute('data-has-more') !== 'true') {
                        observer.disconnect();
                        sentinel.style.display = 'none';
                        var endMsg = document.createElement('div');
                        endMsg.className = 'fa-feed-end';
                        endMsg.textContent = '\u2014 Vous avez tout vu \u2014';
                        feed.insertBefore(endMsg, loader);
                    }
                })
                .catch(function(e) {
                    loader.style.display = 'none';
                    loading = false;
                    console.error('Feed load error:', e);
                });
        }

        var observer = new IntersectionObserver(function(entries) {
            if (!entries[0].isIntersecting || loading) return;
            if (cursor.getAttribute('data-has-more') !== 'true') { observer.disconnect(); return; }
            var score = cursor.getAttribute('data-score');
            var id    = cursor.getAttribute('data-id');
            if (!id) return;
            doFetch(score, id);
        }, { rootMargin: '300px' });
        observer.observe(sentinel);

        // Expose pour le filtre
        window.triggerFeedLoad = function() {
            if (!loading && cursor.getAttribute('data-has-more') === 'true') {
                doFetch(cursor.getAttribute('data-score'), cursor.getAttribute('data-id'));
            }
        };

        // --- Suivi des vues ---
        var vued = {};
        function observeViewCards(container) {
            var vueObs = new IntersectionObserver(function(entries) {
                entries.forEach(function(e) {
                    if (!e.isIntersecting) return;
                    var pid = e.target.id ? e.target.id.replace('pub-', '') : null;
                    if (!pid || vued[pid]) return;
                    vued[pid] = true;
                    vueObs.unobserve(e.target);
                    fetch(CTX + '/pages/alumni/ajax/marquer-vue.jsp', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: 'idpublication=' + encodeURIComponent(pid)
                    });
                });
            }, {threshold: 0.5});
            (container || document).querySelectorAll('.fa-post-card:not([data-vue-ok])').forEach(function(c) {
                c.setAttribute('data-vue-ok', '1');
                vueObs.observe(c);
            });
        }
        window.observeViewCards = observeViewCards;
        observeViewCards();
    })();

    // ========== FILTRE DU FIL ==========
    function _resolveFilterId(inputId, map) {
        var txt = document.getElementById(inputId).value.trim();
        if (!txt) return '';
        return map[txt] || '';
    }
    // Dropdowns modernes pour spec et parc
    function toggleFilterDropdown(type) {
        var menu = document.getElementById('filter-' + type + '-menu');
        var trigger = document.getElementById('filter-' + type + '-trigger');
        var isActive = menu.classList.contains('active');
        // Fermer tous les autres dropdowns
        document.querySelectorAll('.fa-filter-dropdown-menu.active').forEach(function(m) {
            if (m !== menu) { m.classList.remove('active'); m.previousElementSibling.classList.remove('active'); }
        });
        if (isActive) {
            menu.classList.remove('active');
            trigger.classList.remove('active');
        } else {
            menu.classList.add('active');
            trigger.classList.add('active');
        }
    }
    function selectFilterOption(type, val) {
        var input = document.getElementById('filter-' + type + '-input');
        var label = document.getElementById('filter-' + type + '-label');
        var menu = document.getElementById('filter-' + type + '-menu');
        var trigger = document.getElementById('filter-' + type + '-trigger');
        input.value = val;
        label.textContent = val;
        menu.querySelectorAll('.fa-filter-dropdown-item').forEach(function(i){ i.classList.remove('selected'); });
        var selectedItem = menu.querySelector('[data-value="' + val.replace(/"/g,'&quot;') + '"]');
        if (selectedItem) selectedItem.classList.add('selected');
        menu.classList.remove('active');
        trigger.classList.remove('active');
    }
    // Fermer les dropdowns au clic en dehors
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.fa-filter-dropdown')) {
            document.querySelectorAll('.fa-filter-dropdown-menu.active').forEach(function(m) {
                m.classList.remove('active');
                m.previousElementSibling.classList.remove('active');
            });
        }
    });
    // Single-select pour le type de publication
    function selectTypePub(el, libelle) {
        var input = document.getElementById('filter-typepub-input');
        var items = document.querySelectorAll('.fa-typepub-item');
        if (input.value === libelle) {
            // Déselectionner
            el.classList.remove('active');
            input.value = '';
        } else {
            items.forEach(function(i){ i.classList.remove('active'); });
            el.classList.add('active');
            input.value = libelle;
        }
    }
    function appliquerFiltre() {
        var spec    = _resolveFilterId('filter-spec-input',    _SPEC_MAP);
        var parc    = _resolveFilterId('filter-parc-input',    _PARC_MAP);
        var typepub = _resolveFilterId('filter-typepub-input', _TYPEPUB_MAP);
        // Promo: accepte format 'yyyy+' ou 'yyyy-' directement
        var promoRaw = document.getElementById('filter-promo-input').value.trim();
        var promo = /^\d{4}[+-]$/.test(promoRaw) ? promoRaw : '';
        var lier  = document.getElementById('filter-lier').checked ? '1' : '';
        var cursor  = document.getElementById('feed-cursor');
        var feed    = document.querySelector('.fa-feed-center');
        var sentinel= document.getElementById('feed-sentinel');
        if (!cursor || !feed) return;
        cursor.setAttribute('data-filter-spec',    spec);
        cursor.setAttribute('data-filter-parc',    parc);
        cursor.setAttribute('data-filter-promo',   promo);
        cursor.setAttribute('data-filter-typepub', typepub);
        cursor.setAttribute('data-filter-lier',    lier);
        cursor.setAttribute('data-score',    '9999999');
        cursor.setAttribute('data-id',       'ZZZZZZZZZZZZZZZZZZZ');
        cursor.setAttribute('data-has-more', 'true');
        feed.querySelectorAll('.fa-post-card, .fa-feed-end').forEach(function(el){ el.remove(); });
        if (sentinel) sentinel.style.display = 'block';
        document.getElementById('filter-reset-icon-btn').style.display = (spec||parc||promo||typepub) ? 'flex' : 'none';
        if (window.triggerFeedLoad) window.triggerFeedLoad();
    }
    function reinitialiserFiltre() {
        ['filter-spec-input','filter-parc-input','filter-promo-input'].forEach(function(id){
            document.getElementById(id).value = '';
        });
        // Réinitialiser les labels des dropdowns custom
        document.getElementById('filter-spec-label').textContent = 'Sélectionner...';
        document.getElementById('filter-parc-label').textContent = 'Sélectionner...';
        // Enlever les classes selected
        document.querySelectorAll('.fa-filter-dropdown-item.selected').forEach(function(i){ i.classList.remove('selected'); });
        // Vider la sélection de type de publication
        document.getElementById('filter-typepub-input').value = '';
        document.querySelectorAll('.fa-typepub-item').forEach(function(i){ i.classList.remove('active'); });
        document.getElementById('filter-lier').checked = false;
        appliquerFiltre();
    }
    function reinitialiserFiltreEtActualiser() {
        reinitialiserFiltre();
        setTimeout(function() { location.reload(); }, 300);
    }

    // ========== VISIBILITE FORM ==========
    // Etat des tags de visibilite
    var _visTags = { spec: [], parc: [], promo: null }; // spec/parc: [{id,label}], promo: 'yyyy+' ou 'yyyy-' ou null

    function toggleVisSection() {
        var body = document.getElementById('vis-body');
        var chev = document.getElementById('vis-chevron');
        var open = body.style.display !== 'none';
        body.style.display = open ? 'none' : 'block';
        chev.className = open ? 'bi bi-chevron-down' : 'bi bi-chevron-up';
    }

    // Ajouter un tag spec ou parc via le bouton +
    function addVisTagFromInput(type) {
        var inputId = 'vis-' + type + '-input';
        var mapObj  = (type === 'spec') ? _SPEC_MAP : _PARC_MAP;
        var inp = document.getElementById(inputId);
        var txt = inp.value.trim();
        if (!txt) return;
        var id  = mapObj[txt];
        if (!id) return; // doit correspondre exactement
        var arr = _visTags[type];
        if (arr.find(function(t){ return t.id===id; })) { inp.value=''; return; }
        arr.push({id:id, label:txt});
        inp.value = '';
        renderVisTags(type);
        updateVisHidden();
    }
    function onVisTagKey(e, type) {
        if (e.key === 'Enter') { e.preventDefault(); addVisTagFromInput(type); }
    }
    function removeVisTag(type, id) {
        _visTags[type] = _visTags[type].filter(function(t){ return t.id!==id; });
        renderVisTags(type);
        updateVisHidden();
    }
    function renderVisTags(type) {
        var container = document.getElementById('vis-' + type + '-chips');
        container.innerHTML = '';
        _visTags[type].forEach(function(t) {
            var chip = document.createElement('span');
            chip.className = 'fa-vis-chip';
            chip.innerHTML = escHtml(t.label) + '<button type="button" class="fa-vis-chip-del" onclick="removeVisTag(\'' + type + '\',\'' + t.id + '\')">\u00d7</button>';
            container.appendChild(chip);
        });
    }

    // Promo: input annee (ex: 2023) -> suggestions 2023+ / 2023-
    function onVisPromoInput() {
        var inp = document.getElementById('vis-promo-input');
        var dd  = document.getElementById('vis-promo-dd');
        var val = inp.value.trim();
        if (/^\d{4}$/.test(val)) {
            dd.innerHTML = '<div class="fa-vis-promo-dd-item" onmousedown="selectVisPromo(\'' + val + '+\')">'
                + val + '+ <small style="color:#888">('+val+' et ann&eacute;es plus r&eacute;centes)</small></div>'
                + '<div class="fa-vis-promo-dd-item" onmousedown="selectVisPromo(\'' + val + '-\')">'
                + val + '- <small style="color:#888">('+val+' et ann&eacute;es plus anciennes)</small></div>';
            dd.style.display = 'block';
        } else {
            dd.style.display = 'none';
        }
    }
    function onVisPromoKey(e) {
        if (e.key === 'Enter') { e.preventDefault(); addVisPromoFromInput(); }
        if (e.key === 'Escape') document.getElementById('vis-promo-dd').style.display='none';
    }
    function selectVisPromo(expr) {
        document.getElementById('vis-promo-dd').style.display='none';
        document.getElementById('vis-promo-input').value = expr;
        addVisPromoFromInput();
    }
    function addVisPromoFromInput() {
        var val = document.getElementById('vis-promo-input').value.trim();
        if (!/^\d{4}[+-]$/.test(val)) return;
        _visTags.promo = val;
        document.getElementById('vis-promo-input').value = '';
        document.getElementById('vis-promo-dd').style.display='none';
        renderVisPromo();
        updateVisHidden();
    }
    function removeVisPromo() {
        _visTags.promo = null;
        renderVisPromo();
        updateVisHidden();
    }
    function renderVisPromo() {
        var container = document.getElementById('vis-promo-chips');
        container.innerHTML = '';
        if (_visTags.promo) {
            var chip = document.createElement('span');
            chip.className = 'fa-vis-chip';
            chip.innerHTML = escHtml(_visTags.promo) + '<button type="button" class="fa-vis-chip-del" onclick="removeVisPromo()">\u00d7</button>';
            container.appendChild(chip);
        }
    }

    function updateVisHidden() {
        // Lier
        var lierChk = document.getElementById('vis-lier-check');
        var lier = (lierChk && lierChk.checked) ? 'AND' : 'OR';
        document.getElementById('vis-lier-hidden').value = lier;
        // Spec
        document.getElementById('vis-spec-hidden').value = _visTags.spec.map(function(t){return t.id;}).join(',');
        // Parc
        document.getElementById('vis-parc-hidden').value = _visTags.parc.map(function(t){return t.id;}).join(',');
        // Promo
        document.getElementById('vis-promo-annee-hidden').value = _visTags.promo || '';
        // Resume dans l'entete
        var hasSpec  = _visTags.spec.length > 0;
        var hasParc  = _visTags.parc.length > 0;
        var hasPromo = !!_visTags.promo;
        var icon = document.getElementById('vis-icon');
        var summ = document.getElementById('vis-summary');
        if (!hasSpec && !hasParc && !hasPromo) {
            if (icon) icon.className = 'bi bi-globe2';
            if (summ) summ.textContent = 'Visible par tous';
        } else {
            var parts = [];
            _visTags.spec.forEach(function(t){ parts.push(t.label); });
            _visTags.parc.forEach(function(t){ parts.push(t.label); });
            if (_visTags.promo) parts.push('Promo ' + _visTags.promo);
            if (icon) icon.className = 'bi bi-lock-fill';
            if (summ) summ.textContent = parts.join(lier === 'AND' ? ' ET ' : ' OU ');
        }
    }

    // Fermer le dropdown promo si clic ailleurs
    document.addEventListener('click', function(e){
        var dd = document.getElementById('vis-promo-dd');
        if (dd && !dd.contains(e.target) && e.target.id !== 'vis-promo-input') dd.style.display='none';
    });

    // ========== HASHTAG AUTOCOMPLETE ==========
    function setupHashtagAutocomplete(ta) {
        var dd = document.createElement('div');
        dd.className = 'fa-hashtag-dd';
        var wrap = ta.parentNode;
        if (getComputedStyle(wrap).position === 'static') wrap.style.position = 'relative';
        wrap.appendChild(dd);
        var _lq = null, _tm = null;
        ta.addEventListener('input', function() {
            clearTimeout(_tm);
            _tm = setTimeout(function() {
                var pos = ta.selectionStart;
                var m = ta.value.substring(0, pos).match(/#([A-Za-z0-9]{1,})$/);
                if (!m) { dd.style.display = 'none'; return; }
                var q = m[1];
                if (q === _lq) return;
                _lq = q;
                fetch(CTX + '/pages/alumni/ajax/hashtag-suggest.jsp?q=' + encodeURIComponent(q))
                    .then(function(r){ return r.json(); })
                    .then(function(items) {
                        if (!items || !items.length) { dd.style.display = 'none'; return; }
                        dd.innerHTML = '';
                        items.forEach(function(it) {
                            var d = document.createElement('div');
                            d.className = 'fa-hashtag-item';
                            d.innerHTML = '<strong>' + it.tag + '</strong>&nbsp;<span style="color:#888;font-size:12px;">' + escHtml(it.label) + '</span>';
                            d.addEventListener('mousedown', function(e) {
                                e.preventDefault();
                                var p = ta.selectionStart;
                                var bef = ta.value.substring(0, p).replace(/#([A-Za-z0-9]*)$/, it.tag + ' ');
                                ta.value = bef + ta.value.substring(p);
                                ta.selectionStart = ta.selectionEnd = bef.length;
                                dd.style.display = 'none';
                                _lq = null;
                                ta.focus();
                            });
                            dd.appendChild(d);
                        });
                        dd.style.display = 'block';
                    }).catch(function(){}); 
            }, 220);
        });
        ta.addEventListener('blur', function(){ setTimeout(function(){ dd.style.display='none'; }, 180); });
        ta.addEventListener('keydown', function(e){ if(e.key==='Escape') dd.style.display='none'; });
    }
    document.addEventListener('DOMContentLoaded', function() {
        var ta = document.querySelector('.fa-composer-textarea');
        if (ta) setupHashtagAutocomplete(ta);
    });

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
                // Tabs
                html += '<div class="rdm-tabs">';
                html += '<button class="rdm-tab rdm-tab--active" onclick="rdmShowTab(this,\'all\')">Tout&nbsp;<span class="rdm-tab-count">' + data.total + '</span></button>';
                for (var i = 0; i < data.reactions.length; i++) {
                    var rt = data.reactions[i];
                    html += '<button class="rdm-tab" onclick="rdmShowTab(this,\'' + rt.id + '\')">'
                          + rt.emoji + '&nbsp;<span class="rdm-tab-count">' + rt.count + '</span></button>';
                }
                html += '</div>';
                // Panel "Tout"
                html += '<div class="rdm-panel" id="rdm-panel-all">';
                for (var i = 0; i < data.reactions.length; i++) {
                    for (var j = 0; j < data.reactions[i].users.length; j++)
                        html += rdmUserRow(data.reactions[i].users[j], data.reactions[i].emoji, data.myId);
                }
                html += '</div>';
                // Panels par type
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
    // Fermer la modale en cliquant sur le fond
    document.addEventListener('click', function(e) {
        var modal = document.getElementById('react-detail-modal');
        if (modal && e.target === modal) closeReactionDetails();
    });
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') { closeReactionDetails(); closeShareModal(); closePublicationDetail(); }
        if (document.getElementById('pub-detail-modal').style.display === 'flex') {
            if (e.key === 'ArrowLeft') { e.preventDefault(); pubFbNavPrev(); }
            if (e.key === 'ArrowRight') { e.preventDefault(); pubFbNavNext(); }
        }
    });

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
                if (typeof Swal !== 'undefined') Swal.fire({toast:true,position:'top-end',icon:'success',title:'Publication partag\u00e9e !',timer:2500,showConfirmButton:false});
                else alert('Publication partagée !');
            } else {
                btn.disabled = false;
                alert('Erreur lors du partage: ' + (data.error || 'Inconnue'));
            }
        })
        .catch(function(e) { btn.disabled = false; alert('Erreur réseau: ' + e); });
    }
    // Fermer modale partage en cliquant le fond
    document.addEventListener('click', function(e) {
        var sm = document.getElementById('share-modal');
        if (sm && e.target === sm) closeShareModal();
        var pdm = document.getElementById('pub-detail-modal');
        if (pdm && e.target === pdm) closePublicationDetail();
    });

    // ========== DETAIL PUBLICATION (Facebook-style modal) ==========
    var _pubFbMedias = [];
    var _pubFbIndex = 0;
    var _pubFbCurrentId = null; // track which pub is open for ID restoration

    function onPubCardClick(e, idpub) {
        // Ignore clicks on interactive elements inside the card
        if (e.target.closest('button, a, input, textarea, select, .fa-post-actions, .fa-comments-zone, .pub-menu, .fa-reaction-bar, .fa-tag-zone, .fa-shared-embed, .fa-media-grid-item, .fa-post-counters')) return;
        openPublicationDetail(idpub);
    }

    // Temporarily neutralize IDs on the feed card to prevent duplicate-ID conflicts
    function _neutralizeFeedCardIds(idpub) {
        var feedCard = document.getElementById('pub-' + idpub);
        if (!feedCard) return;
        // Don't neutralize if it's inside the modal
        if (feedCard.closest('#pub-fb-details')) return;
        var els = feedCard.querySelectorAll('[id]');
        for (var i = 0; i < els.length; i++) {
            els[i].setAttribute('data-feed-id', els[i].id);
            els[i].id = '_feed_' + els[i].id;
        }
        feedCard.setAttribute('data-feed-id', feedCard.id);
        feedCard.id = '_feed_' + feedCard.id;
    }

    // Restore IDs on the feed card
    function _restoreFeedCardIds() {
        var els = document.querySelectorAll('[data-feed-id]');
        for (var i = 0; i < els.length; i++) {
            els[i].id = els[i].getAttribute('data-feed-id');
            els[i].removeAttribute('data-feed-id');
        }
    }

    function openPublicationDetail(idpub, mediaIdx) {
        if (!idpub) return;

        // If modal is already open for another pub, close cleanly first
        if (_pubFbCurrentId) {
            _restoreFeedCardIds();
            document.getElementById('pub-fb-details').innerHTML = '';
            var mc = document.getElementById('pub-fb-media-content');
            if (mc) { mc.querySelectorAll('video').forEach(function(v){v.pause();}); mc.innerHTML = ''; }
        }

        var modal = document.getElementById('pub-detail-modal');
        var box   = document.getElementById('pub-fb-box');
        var details = document.getElementById('pub-fb-details');
        _pubFbCurrentId = idpub;

        // Get media data from the card in the feed (BEFORE neutralizing IDs)
        _pubFbMedias = [];
        var feedCard = document.getElementById('pub-' + idpub);
        if (feedCard && !feedCard.closest('#pub-fb-details')) {
            try { _pubFbMedias = JSON.parse(feedCard.getAttribute('data-medias') || '[]'); } catch(ex){}
        }

        // Neutralize feed card IDs so getElementById will target the modal card
        _neutralizeFeedCardIds(idpub);

        // Setup layout
        if (_pubFbMedias.length > 0) {
            box.classList.remove('pub-fb-box--no-media');
            _pubFbIndex = (typeof mediaIdx === 'number' && mediaIdx >= 0 && mediaIdx < _pubFbMedias.length) ? mediaIdx : 0;
            renderPubFbMedia();
        } else {
            box.classList.add('pub-fb-box--no-media');
        }

        // Show modal with spinner
        details.innerHTML = '<div style="text-align:center;padding:40px;"><div class="fa-feed-spinner"></div></div>';
        modal.style.display = 'flex';

        // Load publication card via AJAX
        fetch(CTX + '/pages/alumni/ajax/voir-publication.jsp?idpublication=' + encodeURIComponent(idpub))
            .then(function(r) { return r.text(); })
            .then(function(html) {
                details.innerHTML = html;

                // Find the loaded card
                var loadedCard = details.querySelector('.fa-post-card');

                // If we had no media from feed card, try from the loaded card
                if (_pubFbMedias.length === 0 && loadedCard) {
                    try { _pubFbMedias = JSON.parse(loadedCard.getAttribute('data-medias') || '[]'); } catch(ex){}
                    if (_pubFbMedias.length > 0) {
                        box.classList.remove('pub-fb-box--no-media');
                        _pubFbIndex = (typeof mediaIdx === 'number' && mediaIdx >= 0 && mediaIdx < _pubFbMedias.length) ? mediaIdx : 0;
                        renderPubFbMedia();
                    }
                }

                // Hide the media grid in the detail card (shown on the left side)
                if (_pubFbMedias.length > 0) {
                    var mg = details.querySelector('.fa-media-grid');
                    if (mg) mg.style.display = 'none';
                }

                // Remove card-level onclick to prevent nested modal
                if (loadedCard) {
                    loadedCard.removeAttribute('onclick');
                    loadedCard.style.cursor = 'default';
                }

                // Auto-open comments section
                if (loadedCard) {
                    var pid = loadedCard.id ? loadedCard.id.replace('pub-','') : idpub;
                    var commDiv = document.getElementById('commentaires-' + pid);
                    if (commDiv && commDiv.style.display === 'none') {
                        commDiv.style.display = 'block';
                        if (typeof chargerCommentaires === 'function') chargerCommentaires(pid);
                    }
                }
            })
            .catch(function(e) {
                details.innerHTML = '<p style="color:red;padding:20px;text-align:center;">Erreur: ' + e + '</p>';
            });
    }

    function renderPubFbMedia() {
        var content = document.getElementById('pub-fb-media-content');
        var counter = document.getElementById('pub-fb-counter');
        var prevBtn = document.getElementById('pub-fb-prev');
        var nextBtn = document.getElementById('pub-fb-next');
        if (!_pubFbMedias.length) return;
        var m = _pubFbMedias[_pubFbIndex];
        if (m.type === 'video') {
            content.innerHTML = '<video src="' + escHtml(m.url) + '" controls autoplay style="max-width:100%;max-height:100%;object-fit:contain;border-radius:4px;"></video>';
        } else {
            content.innerHTML = '<img src="' + escHtml(m.url) + '" alt="Media">';
        }
        if (_pubFbMedias.length > 1) {
            counter.textContent = (_pubFbIndex + 1) + ' / ' + _pubFbMedias.length;
            counter.style.display = 'block';
        } else { counter.style.display = 'none'; }
        prevBtn.classList.toggle('pub-fb-nav--visible', _pubFbIndex > 0);
        nextBtn.classList.toggle('pub-fb-nav--visible', _pubFbIndex < _pubFbMedias.length - 1);
    }

    function pubFbNavPrev() { if (_pubFbIndex > 0) { _pubFbIndex--; renderPubFbMedia(); } }
    function pubFbNavNext() { if (_pubFbIndex < _pubFbMedias.length - 1) { _pubFbIndex++; renderPubFbMedia(); } }

    function closePublicationDetail() {
        var modal = document.getElementById('pub-detail-modal');
        modal.style.display = 'none';
        var mc = document.getElementById('pub-fb-media-content');
        if (mc) {
            var vids = mc.querySelectorAll('video');
            for (var vi = 0; vi < vids.length; vi++) vids[vi].pause();
            mc.innerHTML = '';
        }
        document.getElementById('pub-fb-details').innerHTML = '';
        // Restore feed card IDs that were neutralized
        _restoreFeedCardIds();
        _pubFbCurrentId = null;
    }

    // ========== COPIER LIEN PUBLICATION / PROFIL ==========
    function copyPublicationLink(idpub) {
        var url = window.location.origin + CTX + '/pages/module.jsp?but=accueil.jsp&highlight=' + encodeURIComponent(idpub);
        _doCopyText(url, 'Lien de la publication copi\u00e9 !');
    }
    function copyProfileLink(idprofil) {
        var url = window.location.origin + CTX + '/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp?idprofil=' + encodeURIComponent(idprofil);
        _doCopyText(url, 'Lien du profil copi\u00e9 !');
    }
    function _doCopyText(txt, msg) {
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(txt).then(function() {
                Swal.fire({toast:true,position:'top-end',icon:'success',title:msg,timer:2000,showConfirmButton:false});
            }).catch(function() { _fallbackCopy(txt, msg); });
        } else { _fallbackCopy(txt, msg); }
    }
    function _fallbackCopy(txt, msg) {
        var ta = document.createElement('textarea');
        ta.value = txt; ta.style.position = 'fixed'; ta.style.left = '-9999px';
        document.body.appendChild(ta); ta.select();
        try { document.execCommand('copy'); Swal.fire({toast:true,position:'top-end',icon:'success',title:msg,timer:2000,showConfirmButton:false}); }
        catch(e) { Swal.fire({toast:true,position:'top-end',icon:'error',title:'Impossible de copier',timer:2000,showConfirmButton:false}); }
        document.body.removeChild(ta);
    }
</script>
