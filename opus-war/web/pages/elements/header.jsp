<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page import="bean.CGenUtil"%>
<%@page import="historique.MapUtilisateur"%>
<%@page import="user.UserEJB"%>
<%@page import="menu.MenuDynamique"%>
<%@page import="java.util.ArrayList"%>

<!-- JSP Method Declaration for Icon Conversion -->
<%!
    // Function to convert Font Awesome to Ionicons
    public String convertToIonicon(String faIcon) {
        if (faIcon == null) return "ion ion-link";

        // Map of Font Awesome to Ionicons
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

        // Check if it's a Font Awesome icon
        if (faIcon.startsWith("fa")) {
            for (String key : iconMap.keySet()) {
                if (faIcon.contains(key.replace("fa-", ""))) {
                    return iconMap.get(key);
                }
            }
        }

        // If it looks like Font Awesome, try to convert
        if (faIcon.startsWith("fa-") || faIcon.startsWith("fa ")) {
            String iconName = faIcon.replace("fa-", "").replace("fa ", "");
            // Default mapping
            String ionIcon = "ion ion-" + iconName;
            return ionIcon;
        }

        // Otherwise return as is (probably already ionicon)
        return faIcon;
    }
%>

<%@page import="utilisateur.UserMenu"%>

<%
    String lien = (String) session.getValue("lien");
    UserEJB ue = (UserEJB) session.getValue("u");
    MapUtilisateur map = ue.getUser();
    String currentMenu = request.getParameter("currentMenu");

    // Get menu tree using CGenUtil.rechercher directly (framework pattern)
    ArrayList<ArrayList<MenuDynamique>> arbreMenu = null;
    MenuDynamique[] tabMenu = null;

    try {
        // 1. D'abord charger les menus autorises pour cet utilisateur depuis usermenu
        String refuser = String.valueOf(map.getRefuser());
        String idrole = map.getIdrole();

        // Requete pour les menus autorises (interdit=0 ou null) par refuser='*' ou par role
        String whereUserMenu = " AND (interdit=0 OR interdit IS NULL) AND (refuser='*' OR refuser='" + refuser + "' OR idrole='" + idrole + "')";
        UserMenu[] userMenus = (UserMenu[]) CGenUtil.rechercher(new UserMenu(), null, null, whereUserMenu);

        // 2. Collecter les IDs des menus autorises
        java.util.Set<String> menuAutorises = new java.util.HashSet<String>();
        if (userMenus != null) {
            for (UserMenu um : userMenus) {
                if (um.getIdmenu() != null) {
                    menuAutorises.add(um.getIdmenu());
                }
            }
        }

        // 3. Charger tous les menus
        tabMenu = (MenuDynamique[]) CGenUtil.rechercher(new MenuDynamique(), null, null, " ORDER BY niveau, rang ASC");

        if (tabMenu != null && tabMenu.length > 0) {
            // Organiser les menus par niveau (seulement ceux autorises)
            arbreMenu = new ArrayList<ArrayList<MenuDynamique>>();
            java.util.Map<Integer, ArrayList<MenuDynamique>> menuParNiveau = new java.util.HashMap<Integer, ArrayList<MenuDynamique>>();

            for (MenuDynamique menu : tabMenu) {
                // Filtrer : garder seulement les menus autorises
                if (menuAutorises.isEmpty() || menuAutorises.contains(menu.getId())) {
                    int niveau = menu.getNiveau();
                    if (!menuParNiveau.containsKey(niveau)) {
                        menuParNiveau.put(niveau, new ArrayList<MenuDynamique>());
                    }
                    menuParNiveau.get(niveau).add(menu);
                }
            }

            // Ajouter les niveaux dans l'ordre
            int maxNiveau = 0;
            for (Integer n : menuParNiveau.keySet()) {
                if (n > maxNiveau) maxNiveau = n;
            }
            for (int i = 0; i <= maxNiveau; i++) {
                if (menuParNiveau.containsKey(i)) {
                    arbreMenu.add(menuParNiveau.get(i));
                } else {
                    arbreMenu.add(new ArrayList<MenuDynamique>());
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        arbreMenu = null;
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
        <!-- Dynamic Menu from MenuDynamique (niveau 0 only) -->
        <%
        if (arbreMenu != null && !arbreMenu.isEmpty()) {
          ArrayList<MenuDynamique> menuNiveau0 = arbreMenu.get(0);
          if (menuNiveau0 != null) {
            for (MenuDynamique menu : menuNiveau0) {
              if (menu != null) {
                String href = "#";
                if (menu.getHref() != null && !menu.getHref().isEmpty()) {
                  href = menu.getHref() + "?currentMenu=" + menu.getId();
                }
                String libelle = menu.getLibelle() != null ? menu.getLibelle() : "Menu";
                String icone = menu.getIcone() != null ? menu.getIcone() : "fa-link";
                String ionIcon = convertToIonicon(icone);
      %>
      <a class="topnav-link" href="<%= href %>" data-overflow-item="true" title="<%= libelle %>">
        <i class="<%= ionIcon %>"></i>
        <span><%= libelle %></span>
      </a>
      <%
              }
            }
          }
        }
      %>
    </div>

    <!-- More Button (Overflow) -->
    <div class="topnav-overflow">
      <button class="topnav-more-btn" type="button" title="Plus d'options">
        <i class="ion ion-navicon-round"></i>
        <span>Plus</span>
      </button>
      <div class="topnav-overflow-menu"></div>
    </div>

    <!-- Search Toggle (Mobile) -->
    <button class="topnav-search-toggle" type="button" title="Rechercher">
      <i class="ion ion-search"></i>
    </button>

    <!-- User Profile -->
    <a class="topnav-user-btn" href="#" title="Mon profil">
      <div class="topnav-avatar"><%= map.getNomuser().substring(0, 1).toUpperCase() %></div>
      <span>Moi</span>
    </a>
  </div>

  <!-- Mobile Bottom Navigation -->
  <div class="topnav-mobile-links">
    <a class="topnav-link" href="<%= lien %>?but=accueil.jsp" title="Accueil">
      <i class="ion ion-home"></i>
    </a>

    <!-- Dynamic Menu for Mobile (niveau 0 only - max 4 items) -->
    <%
      if (arbreMenu != null && arbreMenu.size() > 0) {
        ArrayList<MenuDynamique> menuNiveau0 = arbreMenu.get(0);
        if (menuNiveau0 != null) {
          int count = 0;
          for (MenuDynamique menu : menuNiveau0) {
            if (count >= 4) break; // Show max 4 items + home + profile
            if (menu != null) {
              String href = "#";
              if (menu.getHref() != null && !menu.getHref().isEmpty()) {
                href = menu.getHref() + "?currentMenu=" + menu.getId();
              }
              String libelle = menu.getLibelle() != null ? menu.getLibelle() : "Menu";
              String icone = menu.getIcone() != null ? menu.getIcone() : "fa-link";
              String ionIcon = convertToIonicon(icone);
    %>
    <a class="topnav-link" href="<%= href %>" title="<%= libelle %>">
      <i class="<%= ionIcon %>"></i>
    </a>
    <%
              count++;
            }
          }
        }
      }
    %>

    <a class="topnav-link" href="#" title="Mon profil">
      <i class="ion ion-person"></i>
    </a>
  </div>
</nav>

<!-- Modals (kept from original) -->
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

<%--                <!-- Messages: style can be found in dropdown.less-->--%>
<%--                <!--<li class="dropdown messages-menu">--%>
<%--                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" onclick="loadMessageHeader()">--%>
<%--                        <i class="fa fa-envelope-o"></i>--%>
<%--                        <//%if (0 == 0) {%>--%>
<%--                        <span class="label label-success" id="nb-inbox"><//%=0%></span>--%>
<%--                        <//%} else {%>--%>
<%--                        <span class="label label-success" id="nb-inbox"></span>--%>
<%--                        <//%}%>--%>

<%--                    </a>--%>
<%--                    <ul class="dropdown-menu" id="message-listcontent-header">--%>
<%--                        <li class="header">Vous avez <span id="inbox"><//%=0%></span> message(s)--%>
<%--                            <span class="btn btn-default pull-right" style="position: absolute; top: 0; right: 5px;" data-toggle="modal" data-target="#modalSendMessageTo"><i class="fa fa-plus"></i></span></li>--%>
<%--                        <!--                        <a title="Nouveau message">--%>
<%--                                                    <i class="fa fa-plus-square-o"></i>--%>
<%--                                                </a>-->--%>
<%--                        <!--<li>--%>
<%--                            <!-- inner menu: contains the actual data -->--%>
<%--                            <!--<ul class="menu" id="message-list-header">--%>

<%--                            </ul>--%>
<%--                        </li>--%>
<%--                        <li class="footer"><a href="#">Tous les Messages</a></li>--%>
<%--                    </ul>--%>
<%--                </li>-->--%>
<%--                <!-- Notifications: style can be found in dropdown.less -->--%>
<%--                <!--<li class="dropdown notifications-menu">--%>
<%--                    <a href="<//%= lien %>?but=notification/notification-liste.jsp" class="dropdown-toggle">--%>
<%--                        <i class="fa fa-bell-o"></i>--%>
<%--                        <span class="label label-danger"><//% if(0 >0 ) { %> <//%=0%> <//% }%></span>--%>
<%--                    </a>--%>
<%--                    <!--<ul class="dropdown-menu">--%>
<%--                        <li class="header">Vous avez 2 notifications</li>--%>
<%--                        <li>--%>
<%--                            <ul class="menu">--%>
<%--                                <li>--%>
<%--                                    <a href="#">--%>
<%--                                        <i class="fa fa-users text-aqua"></i> 2 nouveaux dossiers--%>
<%--                                    </a>--%>
<%--                                </li>--%>
<%--                                <li>--%>
<%--                                    <a href="#">--%>
<%--                                        <i class="fa fa-users text-aqua"></i> 1 dossier termin&eacute;--%>
<%--                                    </a>--%>
<%--                                </li>--%>
<%--                            </ul>--%>
<%--                        </li>--%>
<%--                        <li class="footer"><a href="#">Tout voir</a></li>--%>
<%--                    </ul>-->--%>
<%--                <!--</li>-->--%>
<%--                <!-- User Account: style can be found in dropdown.less -->--%>
<%--                <li>--%>
<%--                    <a class="btn btn-tertiary btn-small" onclick="showAlarmPopup()"><i class="fa fa-clock-o" style="scale: 1.3; position: relative; top: 2px"></i></a>--%>
<%--                </li>--%>
<%--                        <li style="margin-top: 7%" id="notifrefresh">--%>


<%--                        </li>--%>
<%--                <li class="dropdown user user-menu">--%>
<%--                    <a href="#" class=" btn btn-tertiary btn-small dropdown-toggle" data-toggle="dropdown">--%>
<%--                        <span class="hidden-xs"><%=map.getLoginuser()%></span>--%>
<%--                    </a>--%>
<%--                    <!--<ul class="dropdown-menu">--%>
<%--                        <!-- User image -->--%>
<%--                        <!--<li class="user-header">--%>
<%--                            <p>--%>
<%--                                <//%=map.getLoginuser() + "-" + map.getIdrole()%>--%>
<%--                            </p>--%>
<%--                        </li>--%>
<%--                        <!-- Menu Body -->--%>
<%--                        <!-- Menu Footer-->--%>
<%--                        <!--<li class="user-footer">--%>
<%--                            <div class="pull-left">--%>
<%--                                <a href="<//%=lien%>?but=utilisateur/utilisateur-modif.jsp&id=<//%=map.getRefuser()%>" class="btn btn-default btn-flat">Modifier Profil</a>--%>
<%--                            </div>--%>
<%--                            <div class="pull-right">--%>
<%--                                <a href="deconnexion.jsp" class="btn btn-default btn-flat">D&eacute;connexion</a>--%>
<%--                            </div>--%>
<%--                        </li>--%>
<%--                    </ul>-->--%>
<%--                </li>--%>
<%--                <li>--%>
<%--                     <a class="btn btn-tertiary btn-small"  href="deconnexion.jsp"><i class="fa fa-sign-out"></i> D&eacute;connexion</a>--%>
<%--                </li>--%>
<%--            </ul>--%>
<%--        </div>--%>
    </nav>
</header>
<div class="modal fade" id="modalSendMessage" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="message-chat-title"></h4>
            </div>
            <div class="modal-body clearfix">
                <div class="message-chat-content clearfix" id="message-chat-content">

                </div>
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
                    MapUtilisateur[] utilisateurs = (MapUtilisateur[]) CGenUtil.rechercher(new MapUtilisateur(), null, null, " AND REFUSER <> '" + map.getRefuser() + "'");
                    if (utilisateurs != null) {
                      for (MapUtilisateur utilisateur : utilisateurs) {%>
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
                    <h5 class="modal-title">Cr&eacute;er une alarme</h5>
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
                        <label for="alarmTimestamp">Date &amp; Heure</label>
                        <input type="datetime-local" class="form-control" id="alarmTimestamp" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">Cr&eacute;er</button>
                    <button type="button" class="btn btn-tertiary" data-dismiss="modal">Annuler</button>
                </div>
            </div>
        </form>
    </div>
</div>




<script src="${pageContext.request.contextPath}/apjplugins/notification.js" type="text/javascript"></script>                