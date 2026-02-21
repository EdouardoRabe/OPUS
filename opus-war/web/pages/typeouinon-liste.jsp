<%@page import="user.UserEJB"%>
<%@page import="affichage.PageRecherche"%>
<%@page import="affichage.Liste"%>
<%@page import="bean.*"%>
<%@ page import="utils.TypeOuiNon" %>

<%
    try {
        TypeOuiNon tc = new TypeOuiNon();
        UserEJB u = (user.UserEJB) session.getValue("u");

        String listeCrt[] = {"val", "desce"};
        String listeInt[] = {};
        String libEntete[] = {"id", "val", "desce"};
        String libEnteteAffiche[] = {"ID", "Val", "Dese"};

        PageRecherche pr = new PageRecherche(tc, request, listeCrt, listeInt, 3, libEntete, libEntete.length);


        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setLien((String) session.getValue("lien"));
        pr.setApres("typeouinon-liste.jsp");

        String[] colSomme = null;
        pr.creerObjetPage(libEntete, colSomme);
%>
<script>
    function changerDesignation() {
        document.prestation.submit();
    }
</script>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Liste des Types OUI / NON</h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=typeouinon-liste.jsp" method="post" name="prestation" id="prestation">
            <%
                out.println(pr.getFormu().getHtmlEnsemble());
            %>
            <div class="col-md-offset-5">
                <div class="form-group">
                </div>
            </div>

        </form>
        <%  String lienTableau[] = {pr.getLien() + "?but=typeouinon-fiche.jsp"};
            String colonneLien[] = {"id"};
            pr.getTableau().setLien(lienTableau);
            pr.getTableau().setColonneLien(colonneLien);
            out.println(pr.getTableauRecap().getHtml());%>
        <br>
        <%
            pr.getTableau().setLibelleAffiche(libEnteteAffiche);
            out.println(pr.getTableau().getHtml());
            out.println(pr.getBasPage());
        %>
    </section>
</div>
<%    } catch (Exception e) {
    e.printStackTrace();
%>
<script language="JavaScript">
    alert('<%=e.getMessage()%>');
    history.back();
</script>
<% }%>
