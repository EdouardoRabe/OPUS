<%-- 
    Document   : menu-fiche
    Created on : 30 d�c. 2015, 15:16:34
    Author     : Jetta
--%>


<%@page import="menu.MenuDynamique"%>
<%@page import="affichage.PageConsulte"%> 
<%!
    MenuDynamique menu;
%>
<%
    menu = new MenuDynamique();
    //autorisation.setNomTable("POINT_AUTORISATION_LIBELLE");
    String[] libelleAutorisationFiche = {"id", "Entete", "icone", "Lien cible", "rang", "niveau", "Pere"};
    PageConsulte pc = new PageConsulte(menu, request, (user.UserEJB) session.getValue("u"));
    pc.setLibAffichage(libelleAutorisationFiche);
    pc.setTitre("Fiche Menu");
%>
<div class="content-wrapper">
    <div class="row">
        <div class="col-md-6">
            <div class="box-fiche">
                <div class="box">
                    <div class="box-title with-border">
                        <h1 class="box-title"><a href="<%=(String) session.getValue("lien")%>?but=menu/menu-liste.jsp"><i class="fa fa-arrow-circle-left"></i></a><%=pc.getTitre()%></h1>
                    </div>
                    <div class="box-body">
                        <%
                            out.println(pc.getHtml());
                        %>
                        <br/>
                        <div class="box-footer">
                            <a class="btn btn-warning pull-right"  href="<%=(String) session.getValue("lien") + "?but=menu/menu-modif.jsp&id=" + request.getParameter("id")%>" style="margin-right: 10px">Modifier</a>
                            <a class="btn btn-danger pull-right"  href="<%=(String) session.getValue("lien") + "?but=apresTarif.jsp&id=" + request.getParameter("id")%>&acte=delete&bute=menu/menu-liste.jsp&classe=menu.MenuDynamique" style="margin-right: 10px">Supprimer</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%out.println(pc.getBasPage());%>
</div>

