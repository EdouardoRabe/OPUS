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

<%!
    // Function to convert Font Awesome to Ionicons
    public String convertToIonicon(String faIcon) {
        if (faIcon == null) return "ion ion-link";

        java.util.Map<String, String> iconMap = new java.util.HashMap<>();
        iconMap.put("fa-users", "ion ion-people");
        iconMap.put("fa-briefcase", "ion ion-briefcase");
        iconMap.put("fa-comment-dots", "ion ion-chatboxes");
        iconMap.put("fa-bell", "ion ion-alert");
        iconMap.put("fa-home", "ion ion-home");
        iconMap.put("fa-user", "ion ion-person");
        iconMap.put("fa-search", "ion ion-search");
        iconMap.put("fa-ellipsis-h", "ion ion-navicon-round");
        iconMap.put("fa-graduation-cap", "ion ion-university");
        iconMap.put("fa-cog", "ion ion-gear-a");
        iconMap.put("fa-cogs", "ion ion-gear-b");
        iconMap.put("fa-file", "ion ion-document");
        iconMap.put("fa-folder", "ion ion-folder");
        iconMap.put("fa-list", "ion ion-navicon");
        iconMap.put("fa-dashboard", "ion ion-speedometer");
        iconMap.put("fa-chart", "ion ion-stats-bars");
        iconMap.put("fa-money", "ion ion-cash");
        iconMap.put("fa-calendar", "ion ion-calendar");
        iconMap.put("fa-sign-out", "ion ion-log-out");

        if (faIcon.startsWith("fa")) {
            for (String key : iconMap.keySet()) {
                if (faIcon.contains(key.replace("fa-", ""))) {
                    return iconMap.get(key);
                }
            }
        }

        if (faIcon.startsWith("fa-") || faIcon.startsWith("fa ")) {
            String iconName = faIcon.replace("fa-", "").replace("fa ", "");
            return "ion ion-" + iconName;
        }

        return faIcon;
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
          <i class="ion ion-search"></i>
          <input class="topnav-search" type="text" name="remarque" placeholder="Rechercher...">
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
            String icone = menuParent.getIcone() != null ? menuParent.getIcone() : "fa-link";
            String ionIcon = convertToIonicon(icone);

            // Verifier si ce menu a des sous-menus
            ArrayList<MenuDynamique> sousMenus = sousMenusParParent.get(menuId);
            boolean hasSousMenus = (sousMenus != null && !sousMenus.isEmpty());

            if (hasSousMenus) {
                // Menu avec sous-menus (dropdown)
        %>
        <div class="topnav-link-group" data-overflow-item="true">
            <button class="topnav-link" type="button" aria-expanded="false" title="<%= libelle %>">
                <i class="<%= ionIcon %>"></i>
                <span class="topnav-link-label">
                    <%= libelle %>
                    <i class="ion ion-chevron-down topnav-link-caret"></i>
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
                    String sousIcone = sousMenu.getIcone() != null ? sousMenu.getIcone() : "fa-circle";
                    String sousIonIcon = convertToIonicon(sousIcone);
                %>
                <a class="topnav-sublink" href="<%= sousHref %>" title="<%= sousLibelle %>">
                    <i class="<%= sousIonIcon %>"></i>
                    <%= sousLibelle %>
                </a>
                <%
                }
                %>
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
            <i class="<%= ionIcon %>"></i>
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
        <i class="ion ion-navicon-round"></i>
        <span>Plus</span>
      </button>
      <div class="topnav-overflow-menu"></div>
    </div>

    <!-- Search Toggle (Mobile) -->
    <button class="topnav-search-toggle" type="button" title="Rechercher">
      <i class="ion ion-search"></i>
    </button>

    <!-- User Profile Dropdown -->
    <div class="topnav-user-dropdown">
      <button class="topnav-user-btn" type="button" title="Mon profil" aria-expanded="false">
        <div class="topnav-avatar"><%= map.getNomuser().substring(0, 1).toUpperCase() %></div>
        <span>Moi</span>
      </button>
      <div class="topnav-user-menu">
        <a class="topnav-user-menu-item" href="<%=lien%>?but=utilisateur/utilisateur-modif.jsp&id=<%=map.getRefuser()%>">
          <i class="ion ion-person"></i>
          Modifier Profil
        </a>
        <div class="topnav-user-menu-divider"></div>
        <a class="topnav-user-menu-item" href="deconnexion.jsp">
          <i class="ion ion-log-out"></i>
          Déconnexion
        </a>
      </div>
    </div>
  </div>

  <!-- Mobile Bottom Navigation -->
  <div class="topnav-mobile-links">
      <%
    // Mobile: afficher les 3 premiers menus de niveau 0
    int mobileCount = 0;
    for (MenuDynamique menuParent : menusNiveau0) {
        if (mobileCount >= 3) break;
        if (menuParent == null) continue;

        String menuId = menuParent.getId();
        String libelle = menuParent.getLibelle() != null ? menuParent.getLibelle() : "Menu";
        String icone = menuParent.getIcone() != null ? menuParent.getIcone() : "fa-link";
        String ionIcon = convertToIonicon(icone);

        ArrayList<MenuDynamique> sousMenus = sousMenusParParent.get(menuId);
        boolean hasSousMenus = (sousMenus != null && !sousMenus.isEmpty());

        if (hasSousMenus) {
    %>
    <div class="topnav-link-group">
        <button class="topnav-link" type="button" aria-expanded="false" title="<%= libelle %>">
            <i class="<%= ionIcon %>"></i>
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
                String sousIcone = sousMenu.getIcone() != null ? sousMenu.getIcone() : "fa-circle";
                String sousIonIcon = convertToIonicon(sousIcone);
            %>
            <a class="topnav-sublink" href="<%= sousHref %>" title="<%= sousLibelle %>">
                <i class="<%= sousIonIcon %>"></i>
                <%= sousLibelle %>
            </a>
            <%
            }
            %>
        </div>
    </div>
    <%
        } else {
            String href = "#";
            if (menuParent.getHref() != null && !menuParent.getHref().isEmpty()) {
                href = menuParent.getHref() + "?currentMenu=" + menuId;
            }
    %>
    <a class="topnav-link" href="<%= href %>" title="<%= libelle %>">
        <i class="<%= ionIcon %>"></i>
    </a>
    <%
        }
        mobileCount++;
    }
    %>

    <a class="topnav-link" href="#" title="Mon profil">
      <i class="ion ion-person"></i>
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

<script src="${pageContext.request.contextPath}/apjplugins/notification.js" type="text/javascript"></script>
<script src="${pageContext.request.contextPath}/assets/js/alumni-topnav.js" type="text/javascript"></script>
