<%@page import="menu.MenuDynamique"%>
<%@page import="java.util.ArrayList"%>
<%@page import="utilisateur.UserMenu"%>
<%@page import="bean.CGenUtil"%>
<%@page import="user.UserEJB"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.ResourceBundle"%>
<%@page import="historique.MapUtilisateur"%>

<%
    HttpSession sess = request.getSession();
    String lang = "fr"; 
    if(sess.getAttribute("lang")!=null){
        lang = String.valueOf(sess.getAttribute("lang"));
    }
    ResourceBundle RB = ResourceBundle.getBundle("text", new Locale(lang));

    if (request.getParameter("currentMenu") != null && !request.getParameter("currentMenu").equals("")) {
        session.setAttribute("currentMenu", request.getParameter("currentMenu"));
    }
    String currentMenu = (String) request.getSession().getAttribute("currentMenu");
    UserEJB u = (UserEJB) session.getAttribute("u");
    MapUtilisateur map = u.getUser();

    ArrayList<ArrayList<MenuDynamique>> arbre = null;
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
            arbre = new ArrayList<ArrayList<MenuDynamique>>();
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
                    arbre.add(menuParNiveau.get(i));
                } else {
                    arbre.add(new ArrayList<MenuDynamique>());
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        arbre = null;
    }
%>

<%
    String lien = (String) session.getValue("lien");
%>

<aside class="main-sidebar">
    <section class="sidebar">
        <!-- sidebar menu: style can be found in alumni-navbar-module.css -->
        <ul class="sidebar-menu" id="menuslider">
            <%=MenuDynamique.renderMenu(arbre, currentMenu, tabMenu)%>
        </ul>
    </section>
</aside>
