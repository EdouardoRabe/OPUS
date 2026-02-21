<%-- 
    Document   : menu-liste
    Created on : 30 d�c. 2015, 15:03:23
    Author     : Jetta
--%>
<%@page import="menu.MenuDynamique"%>
<%@page import="affichage.PageRecherche"%>
<% 
    MenuDynamique lv = new MenuDynamique(); 
    // lv.setNomTable("PRET_DEMANDE_INFO");
    String listeCrt[] = {"id", "libelle", "id_pere"};
    String listeInt[] = {"rang","niveau"};
    String libEntete[] = {"id", "libelle", "icone", "href",  "rang", "niveau", "id_pere"};
    PageRecherche pr = new PageRecherche(lv, request, listeCrt, listeInt, 3, libEntete, 7);
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.getFormu().getChamp("id_pere").setLibelle("Pere");
    pr.getFormu().getChamp("libelle").setLibelle("Entete");
     pr.setApres("menu/menu-liste.jsp");
    String[] colSomme = null;
    pr.creerObjetPage(libEntete, colSomme);%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>Liste des menu</h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=menu/menu-liste.jsp" method="post" name="prestation" id="prestation">
            <% out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <%  String lienTableau[] = {pr.getLien() + "?but=menu/menu-fiche.jsp"};
            String colonneLien[] = {"id"};
            pr.getTableau().setLien(lienTableau);
            pr.getTableau().setColonneLien(colonneLien);
            out.println(pr.getTableauRecap().getHtml());%>
        <br>
        <%
            String libEnteteAffiche[] = {"id", "Entete", "icone", "Lien cible",  "rang", "niveau", "Pere"};
            pr.getTableau().setLibelleAffiche(libEnteteAffiche);
            out.println(pr.getTableau().getHtml());
            out.println(pr.getBasPage());

        %>
    </section>
</div>