<%--
    Document   : security-access
    Description: Vérifie que l'utilisateur a le droit d'accéder à la page demandée
    Created on : 2026-02-23
--%>
<%@page import="bean.CGenUtil"%>
<%@page import="user.UserEJB"%>
<%@page import="historique.MapUtilisateur"%>
<%@page import="menu.MenuDynamique"%>
<%@page import="utilisateur.UserMenu"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Set"%>

<%
    // Récupérer la page demandée
    String pageDemandee = request.getParameter("but");

    // Si pas de page demandée, pas de vérification nécessaire
    if (pageDemandee != null && !pageDemandee.isEmpty()) {

        // Récupérer l'utilisateur connecté
        UserEJB ue = (UserEJB) session.getValue("u");
        if (ue != null) {
            MapUtilisateur map = ue.getUser();
            String idrole = map.getIdrole();
            String refuser = String.valueOf(map.getRefuser());

            // Liste des pages qui nécessitent une vérification d'accès
            // (pages d'administration, modération, etc.)
            Set<String> pagesProtegees = new HashSet<String>();
            pagesProtegees.add("mod/gestion-utilisateurs.jsp");
            pagesProtegees.add("mod/gestion-signalements.jsp");
            pagesProtegees.add("admin/");
            pagesProtegees.add("mod/");
            pagesProtegees.add("dashboard/");
            pagesProtegees.add("specialite/");
            pagesProtegees.add("menu/");
            pagesProtegees.add("evenement/evenement-saisie.jsp");
            pagesProtegees.add("evenement/evenement-list.jsp");
            pagesProtegees.add("evenement/evenement-modif.jsp");
            pagesProtegees.add("evenement/evenement-fiche.jsp");
            pagesProtegees.add("limiterole/");

            // Vérifier si la page demandée est protégée
            boolean pageProtegee = false;
            for (String pageProtegeePattern : pagesProtegees) {
                if (pageDemandee.startsWith(pageProtegeePattern) || pageDemandee.contains(pageProtegeePattern)) {
                    pageProtegee = true;
                    break;
                }
            }

            // Si la page est protégée, vérifier les droits
            if (pageProtegee) {
                boolean accesAutorise = false;

                try {
                    // Chercher dans MENUDYNAMIQUE la page demandée
                    String whereMenu = " AND href LIKE '%" + pageDemandee + "%'";
                    MenuDynamique[] menus = (MenuDynamique[]) CGenUtil.rechercher(new MenuDynamique(), null, null, whereMenu);

                    if (menus != null && menus.length > 0) {
                        // Récupérer l'ID du menu
                        String idMenu = menus[0].getId();

                        // Vérifier si l'utilisateur a accès à ce menu via USERMENU
                        String whereUserMenu = " AND idmenu='" + idMenu + "' AND idrole='" + idrole + "' AND (interdit=0 OR interdit IS NULL) AND (refuser='*' OR refuser='" + refuser + "')";
                        UserMenu[] userMenus = (UserMenu[]) CGenUtil.rechercher(new UserMenu(), null, null, whereUserMenu);

                        if (userMenus != null && userMenus.length > 0) {
                            accesAutorise = true;
                        }
                    } else {
                        // Si la page n'est pas dans MENUDYNAMIQUE,
                        // vérifier si c'est une page admin/mod et si l'utilisateur a le bon rôle
                        if (pageDemandee.startsWith("mod/") || pageDemandee.contains("/mod/")) {
                            // Seuls les modérateurs (md) peuvent accéder aux pages mod/
                            accesAutorise = "md".equals(idrole) || "admin".equals(idrole) || "dg".equals(idrole);  
                        } else if (pageDemandee.startsWith("admin/") || pageDemandee.contains("/admin/")) {
                            // Seuls les admins peuvent accéder aux pages admin/
                            accesAutorise = "admin".equals(idrole) || "dg".equals(idrole);
                        } else if (pageDemandee.startsWith("dashboard/") || pageDemandee.contains("/dashboard/")) {
                            // Seuls les modérateurs/admins peuvent accéder au dashboard
                            accesAutorise = "md".equals(idrole) || "admin".equals(idrole) || "dg".equals(idrole);
                        } else if (pageDemandee.startsWith("specialite/") || pageDemandee.contains("/specialite/")) {
                            // Seuls les modérateurs/admins peuvent gérer les spécialités
                            accesAutorise = "md".equals(idrole) || "admin".equals(idrole) || "dg".equals(idrole);
                        } else if (pageDemandee.startsWith("menu/") || pageDemandee.contains("/menu/")) {
                            // Seuls les admins peuvent gérer les menus dynamiques
                            accesAutorise = "admin".equals(idrole) || "dg".equals(idrole);
                        } else if (pageDemandee.startsWith("evenement/") || pageDemandee.contains("/evenement/")) {
                            // Seuls les modérateurs/admins peuvent gérer les événements (saisie, list, modif, fiche)
                            accesAutorise = "md".equals(idrole) || "admin".equals(idrole) || "dg".equals(idrole);
                        } else if (pageDemandee.startsWith("limiterole/") || pageDemandee.contains("/limiterole/")) {
                            // Seuls les modérateurs peuvent gérer les limites de publication par rôle
                            accesAutorise = "md".equals(idrole);
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    accesAutorise = false;
                }

                // Si l'accès n'est pas autorisé, rediriger vers la page d'accueil
                if (!accesAutorise) {
%>
<script language="JavaScript">
    alert("Accès refusé. Vous n'avez pas les droits nécessaires pour accéder à cette page.");
    document.location.replace("${pageContext.request.contextPath}/pages/module.jsp?but=accueil.jsp");
</script>
<%
                    return; // Arrêter l'exécution de la page
                }
            }
        }
    }
%>

