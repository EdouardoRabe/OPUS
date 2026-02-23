<%@page import="affichage.PageRecherche"%>
<%@ page import="alumni.SpecialiteCpl" %>

<% try {
    SpecialiteCpl t = new SpecialiteCpl();
    String listeCrt[] = {"idspecialite", "libelle"};
    String listeInt[] = {};
    String libEntete[] = {"idspecialite", "libelle", "photohtml"};
    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Liste des sp&eacute;cialit&eacute;s");
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("specialite/specialite-list.jsp");
    pr.getFormu().getChamp("idspecialite").setLibelle("Id");
    pr.getFormu().getChamp("libelle").setLibelle("Libell&eacute;");
    pr.setNpp(50);
    String[] colSomme = {};
    pr.creerObjetPage(libEntete, colSomme);

    String lienBase = (String) session.getValue("lien");
    String lienTableau[] = {lienBase + "?but=specialite/specialite-fiche.jsp"};
    String colonneLien[] = {"idspecialite"};
    String[] attributLien = {"idspecialite"};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setAttLien(attributLien);
    pr.getTableau().setColonneLien(colonneLien);
    String libEnteteAffiche[] = {"Id", "Libell&eacute;", "Photo"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1><%= pr.getTitre() %></h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres() %>" method="post">
            <%
                out.println(pr.getFormu().getHtmlEnsemble());
            %>
        </form>
        <%
            String html = pr.getTableau().getHtml();
            html = html.replace("__CTX__", request.getContextPath());
            out.println(html);
            out.println(pr.getBasPage());
        %>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
