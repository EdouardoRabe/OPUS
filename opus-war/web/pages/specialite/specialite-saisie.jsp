<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page import="alumni.Specialite" %>
<%
    try {
        Specialite a = new Specialite();
        PageInsert pi = new PageInsert(a, request, (user.UserEJB) session.getValue("u"));
        pi.setLien((String) session.getValue("lien"));

        //Modification des affichages
        pi.getFormu().getChamp("libelle").setLibelle("Libell&eacute;");
        pi.getFormu().getChamp("description").setLibelle("Description");
        pi.getFormu().getChamp("photo").setLibelle("Photo");

        //Variables de navigation
        String butApresPost = "specialite/specialite-list.jsp";
        String[] ordre   = {"libelle", "description", "photo"};
        pi.getFormu().setOrdre(ordre);

        //Generer les affichages
        pi.preparerDataFormu();
        pi.getFormu().makeHtmlInsertTabIndex();
%>
<div class="content-wrapper">
    <h1 align="center">Saisie sp&eacute;cialit&eacute;</h1>
    <form action="<%=request.getContextPath()%>/uploadPhotoSpecialite" method="post"
            enctype="multipart/form-data" data-parsley-validate>
        <%
            out.println(pi.getFormu().getHtmlInsert());
        %>
        <input name="bute"type="hidden" value="<%= butApresPost %>">
    </form>
</div>

<script>
(function () {
    // Remplace l'input texte généré pour "photo" par un input type=file
    var input = document.getElementById("photo");
    if (!input) return;

    var fileInput = document.createElement("input");
    fileInput.type      = "file";
    fileInput.name      = "photo";
    fileInput.id        = "photo";
    fileInput.accept    = "image/*";
    fileInput.className = input.className;

    input.parentNode.replaceChild(fileInput, input);
})();
</script>
<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
