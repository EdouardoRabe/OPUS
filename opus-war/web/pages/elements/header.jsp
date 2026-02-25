<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page import="bean.CGenUtil"%>
<%@page import="historique.MapUtilisateur"%>
<%@page import="user.UserEJB"%>
<%@page import="menu.MenuDynamique"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="utilisateur.UserMenu"%>

<!-- Include Alumni TopNav CSS -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/alumni-topnav.css">
<!-- OPUS Global Theme (must be after topnav) -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/opus-theme.css">
<!-- Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<%!
    // Function to convert icon format to Bootstrap Icons
    public String convertToBootstrapIcon(String icon) {
        if (icon == null || icon.isEmpty()) return "bi bi-link-45deg";

        // Si c'est déjà une icône Bootstrap Icons, retourner tel quel
        if (icon.startsWith("bi-") || icon.startsWith("bi ")) {
            if (icon.startsWith("bi-")) {
                return "bi " + icon;
            }
            return icon;
        }

        // Mapping Font Awesome vers Bootstrap Icons
        java.util.Map<String, String> iconMap = new java.util.HashMap<>();

        // Menus principaux
        iconMap.put("fa-home", "bi bi-house-door-fill");
        iconMap.put("fa-users", "bi bi-people-fill");
        iconMap.put("fa-briefcase", "bi bi-briefcase-fill");
        iconMap.put("fa-user-circle", "bi bi-person-circle");
        iconMap.put("fa-cogs", "bi bi-gear-fill");
        iconMap.put("fa-cog", "bi bi-gear-fill");

        // Sous-menus Réseau
        iconMap.put("fa-address-book", "bi bi-book-fill");
        iconMap.put("fa-tags", "bi bi-tags-fill");

        // Sous-menus Carrière
        iconMap.put("fa-list-alt", "bi bi-list-ul");
        iconMap.put("fa-list", "bi bi-list-ul");
        iconMap.put("fa-plus-circle", "bi bi-plus-circle-fill");

        // Sous-menus Profil
        iconMap.put("fa-id-card", "bi bi-person-badge-fill");
        iconMap.put("fa-edit", "bi bi-pencil-square");
        iconMap.put("fa-sign-out", "bi bi-box-arrow-right");
        iconMap.put("fa-user", "bi bi-person-fill");

        // Administration
        iconMap.put("fa-users-cog", "bi bi-people");
        iconMap.put("fa-user-shield", "bi bi-shield-exclamation");

        // Autres icônes communes
        iconMap.put("fa-search", "bi bi-search");
        iconMap.put("fa-bell", "bi bi-bell-fill");
        iconMap.put("fa-envelope", "bi bi-envelope-fill");
        iconMap.put("fa-dashboard", "bi bi-speedometer2");
        iconMap.put("fa-file", "bi bi-file-earmark-fill");
        iconMap.put("fa-folder", "bi bi-folder-fill");
        iconMap.put("fa-calendar", "bi bi-calendar-fill");
        iconMap.put("fa-money", "bi bi-cash-stack");
        iconMap.put("fa-chart", "bi bi-bar-chart-fill");
        iconMap.put("fa-graduation-cap", "bi bi-mortarboard-fill");
        iconMap.put("fa-circle", "bi bi-circle-fill");
        iconMap.put("fa-link", "bi bi-link-45deg");

        // Chercher dans le map
        if (icon.startsWith("fa-") || icon.startsWith("fa ")) {
            String faIcon = icon.replace("fa ", "fa-");
            if (iconMap.containsKey(faIcon)) {
                return iconMap.get(faIcon);
            }
            // Essayer de trouver une correspondance partielle
            for (String key : iconMap.keySet()) {
                if (faIcon.contains(key.replace("fa-", ""))) {
                    return iconMap.get(key);
                }
            }
        }

        // Par défaut, retourner une icône générique
        return "bi bi-link-45deg";
    }
%>

<%
    String lien = (String) session.getValue("lien");
    UserEJB ue = (UserEJB) session.getValue("u");
    MapUtilisateur map = ue.getUser();
    String currentMenu = request.getParameter("currentMenu");

    // Structure pour stocker les menus parent et leurs sous-menus
    ArrayList<MenuDynamique> menusNiveau0 = new ArrayList<MenuDynamique>();
    Map<String, ArrayList<MenuDynamique>> sousMenusParParent = new HashMap<String, ArrayList<MenuDynamique>>();

    try {
        String refuser = String.valueOf(map.getRefuser());
        String idrole = map.getIdrole();

        // Requete pour les menus autorises pour CE role specifique
        // Un menu est accessible si:
        // 1. interdit=0 ou null (non interdit)
        // 2. idrole correspond au role de l'utilisateur
        // 3. refuser='*' (tous) OU refuser correspond à l'utilisateur specifique
        String whereUserMenu = " AND (interdit=0 OR interdit IS NULL) AND idrole='" + idrole + "' AND (refuser='*' OR refuser='" + refuser + "')";
        UserMenu[] userMenus = (UserMenu[]) CGenUtil.rechercher(new UserMenu(), null, null, whereUserMenu);

        // Collecter les IDs des menus autorises
        java.util.Set<String> menuAutorises = new java.util.HashSet<String>();
        if (userMenus != null) {
            for (UserMenu um : userMenus) {
                if (um.getIdmenu() != null) {
                    menuAutorises.add(um.getIdmenu());
                }
            }
        }

        // Charger tous les menus
        MenuDynamique[] tabMenu = (MenuDynamique[]) CGenUtil.rechercher(new MenuDynamique(), null, null, " ORDER BY niveau, rang ASC");

        if (tabMenu != null && tabMenu.length > 0 && !menuAutorises.isEmpty()) {
            for (MenuDynamique menu : tabMenu) {
                // Filtrer : garder seulement les menus autorises
                if (menuAutorises.contains(menu.getId())) {
                    int niveau = menu.getNiveau();
                    String idPere = menu.getId_pere();

                    if (niveau == 0 || idPere == null || idPere.isEmpty() || "0".equals(idPere)) {
                        // Menu de niveau 0 (parent)
                        menusNiveau0.add(menu);
                    } else {
                        // Sous-menu - l'ajouter sous son parent
                        if (!sousMenusParParent.containsKey(idPere)) {
                            sousMenusParParent.put(idPere, new ArrayList<MenuDynamique>());
                        }
                        sousMenusParParent.get(idPere).add(menu);
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<script>
    function verifEditerTef(et,name){
        if(et<11){
            alert('Impossible d\'editer Tef. '+name+' non visé ');
        }else{
            document.tef.submit();
        }
    }
    function verifLivraisonBC(et){
        if(et<11){
            alert('Impossible d effectuer la livraison du bon de commande');
        }else{
            document.tef.submit();
        }
    }
    function CocherToutCheckBox(ref, name) {
        var form = ref;
        while (form.parentNode && form.nodeName.toLowerCase() != 'form') {
            form = form.parentNode;
        }
        var elements = form.getElementsByTagName('input');
        for (var i = 0; i < elements.length; i++) {
            if (elements[i].type == 'checkbox' && elements[i].name == name) {
                elements[i].checked = ref.checked;
            }
        }
    }
</script>

<!-- ══ TOP NAVBAR (LinkedIn-style) ══ -->
<nav class="alumni-topnav">
  <div class="topnav-main-row">
    <!-- Logo -->
    <a class="topnav-brand" href="<%= lien %>?but=accueil.jsp">
      <div class="topnav-logo">
        <img src="${pageContext.request.contextPath}/dist/img/ITU_logo.png" alt="ITU Logo" style="width: 100%; height: 100%; object-fit: contain;">
      </div>
    </a>

    <!-- Search Bar (Desktop) -->
    <div class="topnav-search-wrap">
      <form action="<%=lien%>" method="GET" style="display: flex; align-items: center; flex: 1;">
        <input value="recherche-global.jsp" name="but" type="hidden">
        <div class="topnav-search-container">
          <i class="bi bi-search"></i>
          <input class="topnav-search" style="heigth: 42px !important;" type="text" name="q" placeholder="Rechercher...">
        </div>
      </form>
    </div>

    <!-- Primary Navigation Links -->
    <div class="topnav-primary-links">
        <%
        // Parcourir les menus de niveau 0
        for (MenuDynamique menuParent : menusNiveau0) {
            if (menuParent == null) continue;

            String menuId = menuParent.getId();
            String libelle = menuParent.getLibelle() != null ? menuParent.getLibelle() : "Menu";
            String icone = menuParent.getIcone() != null ? menuParent.getIcone() : "bi-link-45deg";
            String bsIcon = convertToBootstrapIcon(icone);

            // Verifier si ce menu a des sous-menus
            ArrayList<MenuDynamique> sousMenus = sousMenusParParent.get(menuId);
            boolean hasSousMenus = (sousMenus != null && !sousMenus.isEmpty());

            if (hasSousMenus) {
                // Menu avec sous-menus (dropdown)
        %>
        <div class="topnav-link-group" data-overflow-item="true">
            <button class="topnav-link" type="button" aria-expanded="false" title="<%= libelle %>">
                <i class="<%= bsIcon %>"></i>
                <span class="topnav-link-label">
                    <%= libelle %>
                    <i class="bi bi-chevron-down topnav-link-caret"></i>
                </span>
            </button>
            <div class="topnav-submenu">
                <%
                for (MenuDynamique sousMenu : sousMenus) {
                    if (sousMenu == null) continue;
                    String sousHref = "#";
                    if (sousMenu.getHref() != null && !sousMenu.getHref().isEmpty()) {
                        sousHref = sousMenu.getHref() + "?currentMenu=" + sousMenu.getId();
                    }
                    String sousLibelle = sousMenu.getLibelle() != null ? sousMenu.getLibelle() : "Sous-menu";
                    String sousIcone = sousMenu.getIcone() != null ? sousMenu.getIcone() : "bi-circle-fill";
                    String sousBsIcon = convertToBootstrapIcon(sousIcone);
                %>
                <a class="topnav-sublink" href="<%= sousHref %>" title="<%= sousLibelle %>">
                    <i class="<%= sousBsIcon %>"></i>
                    <%= sousLibelle %>
                </a>
                <%
                }
                %>
            </div>
        </div>
        <%
            } else if (icone != null && icone.contains("bi-bell-fill")) {
                // Menu notification dynamique
        %>
        <div class="topnav-link-group topnav-notif-dropdown" data-overflow-item="true">
          <button class="topnav-link" type="button" id="notif-bell-btn" title="<%= libelle %>" aria-expanded="false" style="position:relative;">
            <i class="<%= bsIcon %>"></i>
            <span class="topnav-link-label"><%= libelle %></span>
            <span id="notif-badge" class="badge" style="display:none;position:absolute;top:12px;right:2px;background:#b2d235;color:#1c1e29;font-size:11px;font-weight:600;padding:2px 6px;border-radius:10px;direction:ltr;unicode-bidi:bidi-override;min-width:18px;text-align:center;box-shadow:0 2px 4px rgba(0,0,0,.2);border:2px solid #fff;transform:rotate(0deg);">0</span>
          </button>
          <div id="notif-dropdown-panel" class="topnav-submenu" style="min-width:400px;max-width:420px;right:0;left:auto;border-radius:12px;box-shadow:0 8px 30px rgba(0,0,0,.18);border:1px solid #e0e0e0;overflow:hidden;">
            <div style="display:flex;justify-content:space-between;align-items:center;padding:14px 18px;background:#fafbfc;border-bottom:1px solid #eee;">
              <h4 style="margin:0;font-size:17px;font-weight:700;color:#1d1d1f;">Notifications</h4>
              <a href="javascript:void(0)" onclick="marquerToutLu()" style="font-size:12px;color:#1a73e8;font-weight:500;text-decoration:none;">Tout marquer comme lu</a>
            </div>
            <div id="notif-list" style="max-height:400px;overflow-y:auto;padding:0;"><div style="text-align:center;padding:28px;color:#999;"><i class="bi bi-arrow-repeat" style="font-size:20px;display:block;margin-bottom:6px;"></i>Chargement...</div></div>
            <div style="text-align:center;padding:10px 18px;border-top:1px solid #eee;background:#fafbfc;">
              <a href="<%=lien%>?but=alumni/notifications.jsp" style="font-size:13px;color:#1a73e8;font-weight:600;text-decoration:none;">Voir toutes les notifications</a>
            </div>
          </div>
        </div>
        <%
            } else {
                // Menu simple sans sous-menus
                String href = "#";
                if (menuParent.getHref() != null && !menuParent.getHref().isEmpty()) {
                    href = menuParent.getHref() + "?currentMenu=" + menuId;
                }
        %>
        <a class="topnav-link" href="<%= href %>" data-overflow-item="true" title="<%= libelle %>">
            <i class="<%= bsIcon %>"></i>
            <span><%= libelle %></span>
        </a>
        <%
            }
        }
        %>
    </div>

    <!-- More Button (Overflow) -->
    <div class="topnav-overflow">
      <button class="topnav-more-btn" type="button" title="Plus d'options" aria-expanded="false">
        <i class="bi bi-three-dots"></i>
        <span>Plus</span>
      </button>
      <div class="topnav-overflow-menu"></div>
    </div>

    <!-- Search Toggle (Mobile) -->
    <button class="topnav-search-toggle" type="button" title="Rechercher">
      <i class="bi bi-search"></i>
    </button>

  </div>

  <!-- Mobile Bottom Navigation -->
  <div class="topnav-mobile-links">
      <%
    // Mobile: afficher les 3 premiers menus de niveau 0
    int mobileCount = 0;
    for (MenuDynamique menuParent : menusNiveau0) {
        if (mobileCount >= 3) break;
        if (menuParent == null) continue;

        String menuIdMobile = menuParent.getId();
        String libelleMobile = menuParent.getLibelle() != null ? menuParent.getLibelle() : "Menu";
        String iconeMobile = menuParent.getIcone() != null ? menuParent.getIcone() : "bi-link-45deg";
        String bsIconMobile = convertToBootstrapIcon(iconeMobile);

        ArrayList<MenuDynamique> sousMenusMobile = sousMenusParParent.get(menuIdMobile);
        boolean hasSousMenusMobile = (sousMenusMobile != null && !sousMenusMobile.isEmpty());

        if (hasSousMenusMobile) {
    %>
    <div class="topnav-link-group">
        <button class="topnav-link" type="button" aria-expanded="false" title="<%= libelleMobile %>">
            <i class="<%= bsIconMobile %>"></i>
        </button>
        <div class="topnav-submenu">
            <%
            for (MenuDynamique sousMenuMobile : sousMenusMobile) {
                if (sousMenuMobile == null) continue;
                String sousHrefMobile = "#";
                if (sousMenuMobile.getHref() != null && !sousMenuMobile.getHref().isEmpty()) {
                    sousHrefMobile = sousMenuMobile.getHref() + "?currentMenu=" + sousMenuMobile.getId();
                }
                String sousLibelleMobile = sousMenuMobile.getLibelle() != null ? sousMenuMobile.getLibelle() : "Sous-menu";
                String sousIconeMobile = sousMenuMobile.getIcone() != null ? sousMenuMobile.getIcone() : "bi-circle-fill";
                String sousBsIconMobile = convertToBootstrapIcon(sousIconeMobile);
            %>
            <a class="topnav-sublink" href="<%= sousHrefMobile %>" title="<%= sousLibelleMobile %>">
                <i class="<%= sousBsIconMobile %>"></i>
                <%= sousLibelleMobile %>
            </a>
            <%
            }
            %>
        </div>
    </div>
    <%
        } else {
            String hrefMobile = "#";
            if (menuParent.getHref() != null && !menuParent.getHref().isEmpty()) {
                hrefMobile = menuParent.getHref() + "?currentMenu=" + menuIdMobile;
            }
    %>
    <a class="topnav-link" href="<%= hrefMobile %>" title="<%= libelleMobile %>">
        <i class="<%= bsIconMobile %>"></i>
    </a>
    <%
        }
        mobileCount++;
    }
    %>

    <a class="topnav-link" href="#" title="Mon profil">
      <i class="bi bi-person-fill"></i>
    </a>
  </div>
</nav>

<!-- Modals -->
<div class="modal fade" id="modalSendMessage" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="message-chat-title"></h4>
            </div>
            <div class="modal-body clearfix">
                <div class="message-chat-content clearfix" id="message-chat-content"></div>
                <br/>
                <form>
                    <textarea id="messagefrom" onkeypress="keypressedsendMessage(this, 1)" class="form-control" rows="3" placeholder="Votre message ici" ></textarea>
                    <br/><br/>
                    <input type="button" class="btn btn-primary pull-right" style="margin-left: 5px;" onclick="keypressedsendMessage(this, 2)" value="Envoyer"/>
                    <input type="reset" class="btn btn-danger pull-right" value="Annuler"/>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalSendMessageTo" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <%
                    MapUtilisateur[] utilisateurs2 = (MapUtilisateur[]) CGenUtil.rechercher(new MapUtilisateur(), null, null, " AND REFUSER <> '" + map.getRefuser() + "'");
                    if (utilisateurs2 != null) {
                      for (MapUtilisateur utilisateur : utilisateurs2) {%>
                <div class="radio">
                    <label>
                        <input type="radio" name="optionsRadios" id="optionsRadios1" value="<%=utilisateur.getRefuser()%>">
                        <%=utilisateur.getNomuser()%>
                    </label>
                </div>
                <%}
                    }
                %>
            </div>
            <div class="modal-body clearfix">
                <form>
                    <textarea id="msgelement" class="form-control" rows="3" placeholder="Votre message ici" ></textarea>
                    <br/><br/>
                    <input type="button" class="btn btn-primary pull-right" style="margin-left: 5px;" onclick="keypressedsendMessage(this, 3)" value="Envoyer"/>
                    <input type="reset" class="btn btn-danger pull-right" value="Annuler"/>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="alarmModal" tabindex="-1" role="dialog" aria-labelledby="alarmModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <form id="alarmForm">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Créer une alarme</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Fermer">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="alarmMessage">Message</label>
                        <input type="text" class="form-control" id="alarmMessage" required>
                    </div>
                    <div class="form-group">
                        <label for="alarmTimestamp">Date & Heure</label>
                        <input type="datetime-local" class="form-control" id="alarmTimestamp" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">Créer</button>
                    <button type="button" class="btn btn-tertiary" data-dismiss="modal">Annuler</button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    // Variables globales pour notification.js
    var id_user_conn = '<%= map.getRefuser() %>';
    var _NOTIF_CTX = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/apjplugins/notification.js" type="text/javascript"></script>
<script src="${pageContext.request.contextPath}/assets/js/alumni-topnav.js" type="text/javascript"></script>
