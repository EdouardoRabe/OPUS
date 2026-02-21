<%-- 
    Document   : menu-saisie
    Created on : 5 janv. 2016, 10:38:22
    Author     : user
--%>
<%@page import="menu.MenuDynamique"%>
<%@page import="bean.CGenUtil"%>
<%@page import="affichage.Liste"%>
<%@page import="bean.TypeObjet"%>
<%@page import="affichage.PageInsert"%>
<%
    try{
        String autreparsley = "data-parsley-range='[8, 40]' required";
        MenuDynamique a = new MenuDynamique();
        PageInsert pi = new PageInsert(a, request,(user.UserEJB) session.getValue("u"));
        pi.setLien((String) session.getValue("lien"));
        pi.getFormu().getChamp("libelle").setLibelle("Libelle");
        pi.getFormu().getChamp("icone").setLibelle("Icone");
        pi.getFormu().getChamp("href").setLibelle("Lien (href)");
        pi.getFormu().getChamp("rang").setLibelle("Rang");
        pi.getFormu().getChamp("niveau").setLibelle("Niveau");
        pi.getFormu().getChamp("id_pere").setLibelle("Menu p�re");
        pi.getFormu().getChamp("id_pere").setPageAppel("choix/menuPereChoix.jsp");

        pi.preparerDataFormu();
%>
<div class="content-wrapper">
    <h1 align="center">Menu</h1>
    <form action="<%=pi.getLien()%>?but=apresTarif.jsp" method="post" name="menu" id="menu" data-parsley-validate>
        <%
            pi.getFormu().makeHtmlInsertTabIndex();
            out.println(pi.getFormu().getHtmlInsert());
        %>
        <input name="acte" type="hidden" id="nature" value="insert">
        <input name="bute" type="hidden" id="bute" value="menu/menu-saisie.jsp">
        <input name="classe" type="hidden" id="classe" value="menu.MenuDynamique">
    </form>
</div>
<%
} catch (Exception e) {
    e.printStackTrace();
%>
<script language="JavaScript"> alert('<%=e.getMessage()%>');
    history.back();</script>

<% } %>
