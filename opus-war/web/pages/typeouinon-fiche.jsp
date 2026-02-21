<%@page import="generateurcode.page.*"%>
<%@page import="utilisateur.Utilisateur"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page import="utils.TypeOuiNon" %>
<%
    try{
        UserEJB user = (UserEJB) session.getValue("u");
        TypeOuiNon lib = new TypeOuiNon();
        PageConsulte pc = new PageConsulte(lib, request, user);

        pc.setTitre("Fiche Type OUI / NON");
        lib = (TypeOuiNon) pc.getBase();
        String id = lib.getId();

        pc.getChampByName("id").setVisible(false);
        pc.getChampByName("val").setLibelle("Val");
        pc.getChampByName("desce").setLibelle("Desce");
%>

<div class="content-wrapper">
    <h1 class="box-title"><%=pc.getTitre()%></h1>
    <div class="row m-0">
        <div class="col-md-12 nopadding">
            <div class="box-fiche">
                <div class="box mb-5">
                    <div class="box-body">
                        <%
                            out.println(pc.getHtml());
                        %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

</div>

<%}
catch(Exception e){
    e.printStackTrace();
%>
<script language="JavaScript">
    alert('<%=e.getMessage()%>');
    history.back();
</script>
<%
    }
%>
<script>
    function corrigerStyleMalForme(html) {
        return html
            .replace(/="">/g, '">')
            .replace(/=""/g, ' ')
            .replace(/:"/g, ':');
    }

    window.addEventListener('DOMContentLoaded', () => {
        document.querySelectorAll('.fiche-container > .table > tbody > tr > td > div > span')
            .forEach(span => {
                if (span.innerHTML.trim() !== '') {
                    console.log("inner =====" + span.innerHTML);
                    span.innerHTML = corrigerStyleMalForme(span.innerHTML);
                    console.log("inner modifier =====" + span.innerHTML);
                }
            });
    });
</script>