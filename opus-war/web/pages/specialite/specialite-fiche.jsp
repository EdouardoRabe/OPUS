<%@ page import="affichage.PageConsulte" %>
<%@ page import="alumni.SpecialiteCpl" %>
<%
    try {
        String lien = (String) session.getValue("lien");
        SpecialiteCpl t = new SpecialiteCpl();
        PageConsulte pc = new PageConsulte(t, request, (user.UserEJB) session.getValue("u"));
        t = (SpecialiteCpl) pc.getBase();
        String id = request.getParameter("id");
        if (id == null || id.isEmpty()) id = t.getTuppleID();

        pc.getChampByName("idspecialite").setLibelle("ID");
        pc.getChampByName("libelle").setLibelle("Libell&eacute;");
        pc.getChampByName("photo").setVisible(false);
        pc.getChampByName("photohtml").setVisible(false);
        pc.setTitre("Fiche sp&eacute;cialit&eacute;");
        String classe   = "alumni.Specialite";
        String nomTable = "specialite";
%>
<div class="content-wrapper">
    <div class="row">
        <div class="col-md-3"></div>
        <div class="col-md-6">
            <div class="box-fiche">
                <div class="box">
                    <div class="box-title with-border">
                        <h1 class="box-title">
                            <a href="<%= lien %>?but=specialite/specialite-list.jsp">
                                <i class="fa fa-arrow-circle-left"></i>
                            </a>
                            <%= pc.getTitre() %>
                        </h1>
                    </div>
                    <div class="box-body">
                        <%
                            String html = pc.getHtml();
                            html = html.replace("__CTX__", request.getContextPath());
                            out.println(html);
                        %>
                        <% if (t.getPhotohtml() != null && !t.getPhotohtml().isEmpty()) { %>
                        <table class="table table-bordered" style="margin-top:10px;">
                            <tr>
                                <td width="33%"><b>Photo</b></td>
                                <td>
                                    <%= t.getPhotohtml().replace("__CTX__", request.getContextPath()) %>
                                </td>
                            </tr>
                        </table>
                        <% } %>
                        <br/>
                        <div class="box-footer">
                            <a class="pull-right" href="<%= lien + "?but=specialite/specialite-saisie.jsp&id=" + id %>"><button class="btn btn-warning">Modifier</button></a>
                            <a class="pull-right" href="<%= lien + "?but=apresTarif.jsp&id=" + id + "&acte=delete&bute=specialite/specialite-list.jsp&classe=" + classe + "&nomtable=" + nomTable %>"><button class="btn btn-danger">Supprimer</button></a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>