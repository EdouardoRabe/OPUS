<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%
    UserEJB u;
    MenuDynamique a;
%>
<%
   String autreparsley = "data-parsley-range='[8, 40]' required";
    a = new MenuDynamique();
    PageUpdate pi = new PageUpdate(a, request, (user.UserEJB) session.getValue("u"));
    pi.setLien((String) session.getValue("lien"));
    
    pi.setLien((String) session.getValue("lien"));
    pi.getFormu().getChamp("libelle").setLibelle("Libelle");
    pi.getFormu().getChamp("icone").setLibelle("icone");
    pi.getFormu().getChamp("href").setLibelle("Lien");
    pi.getFormu().getChamp("id_pere").setLibelle("Menu p&egrave;re");
    pi.getFormu().getChamp("rang").setLibelle("Rang");
    pi.getFormu().getChamp("niveau").setLibelle("Niveau");
            
    pi.preparerDataFormu();
%>
<div class="content-wrapper">
    <div class="row">
        <div class="col-md-6">
            <div class="box-fiche">
                <div class="box">
                    <h1>Modification d'un Menu</h1>
                    <form action="<%=(String) session.getValue("lien")%>?but=apresTarif.jsp&id=<%out.print(request.getParameter("id"));%>" method="post" name="menudynamique">
                        <%
                            out.println(pi.getFormu().getHtmlInsert());
                        %>
                        <div class="row">
                            <div class="col-md-11">
                                <button class="btn btn-primary pull-right" name="Submit2" type="submit">Valider</button>
                            </div>
                            <br><br> 
                        </div>
                        <input name="acte" type="hidden" id="acte" value="update">
                        <input name="bute" type="hidden" id="bute" value="menu/menu-fiche.jsp">
                        <input name="classe" type="hidden" id="classe" value="menu.MenuDynamique">
                        <input name="rajoutLien" type="hidden" id="rajoutLien" value="id-<%out.print(request.getParameter("id"));%>" >

                    </form>
                </div>
            </div>
        </div>
    </div>
</div>