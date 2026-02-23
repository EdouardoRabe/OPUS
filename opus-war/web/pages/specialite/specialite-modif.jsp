<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page import="alumni.Specialite" %>
<%
    try {
        Specialite t = new Specialite();

        String mapping  = "alumni.Specialite",
               nomtable = "specialite",
               apres    = "specialite/specialite-fiche.jsp",
               titre    = "Modification sp&eacute;cialit&eacute;";

        PageUpdate pu = new PageUpdate(t, request, (user.UserEJB) session.getValue("u"));
        pu.setLien((String) session.getValue("lien"));
        pu.setTitre(titre);

        // Champ ID en lecture seule
        pu.getFormu().getChamp("idspecialite").setLibelle("ID");
        pu.getFormu().getChamp("idspecialite").setAutre("readonly");

        // Libelle
        pu.getFormu().getChamp("libelle").setLibelle("Libell&eacute;");

        // Description
        pu.getFormu().getChamp("description").setLibelle("Description");

        // Photo : libellé visible, le JS remplacera le textbox par un input file
        pu.getFormu().getChamp("photo").setLibelle("Photo");

        pu.preparerDataFormu();

        String lien = (String) session.getValue("lien");
        String id   = pu.getBase().getTuppleID();

        // Chemin photo actuel (conservé si pas de nouveau fichier)
        String photoPath = ((Specialite) pu.getBase()).getPhoto();
%>
<div class="content-wrapper">
    <div class="row">
        <div class="col-md-3"></div>
        <div class="col-md-6">
            <div class="box-fiche">
                <div class="box">
                    <div class="box-title with-border">
                        <h1 class="box-title">
                            <a href="<%= lien %>?but=specialite/specialite-fiche.jsp&idspecialite=<%= id %>">
                                <i class="fa fa-arrow-circle-left"></i>
                            </a>
                            <%= pu.getTitre() %>
                        </h1>
                    </div>
                    <form action="<%= request.getContextPath() %>/updatePhotoSpecialite"
                          method="post" enctype="multipart/form-data" data-parsley-validate>
                        <style>#uploadBox { display:none !important; }</style>
                        <%
                            out.println(pu.getFormu().getHtmlInsert());
                        %>

                        <%-- Photo actuelle (si elle existe) --%>
                        <% if (photoPath != null && !photoPath.isEmpty()) { %>
                        <div style="margin: 0 15px 10px;">
                            <label class="input-label"><b>Photo actuelle</b></label><br/>
                            <img src="<%= request.getContextPath() + "/" + photoPath %>"
                                 style="max-height:150px; max-width:250px; border:1px solid #ddd; padding:4px; margin-top:4px;">
                        </div>
                        <% } %>

                        <%-- Conserve l'ancien chemin si pas de nouveau fichier --%>
                        <input type="hidden" name="photoActuelle" value="<%= photoPath != null ? photoPath : "" %>">
                        <input type="hidden" name="idspecialite"  value="<%= id %>">
                        <input type="hidden" name="bute"          value="<%= apres %>">

                        <div class="row">
                            <div class="col-md-11">
                                <button class="btn btn-primary pull-right" name="Submit2" type="submit">Valider</button>
                            </div>
                            <br><br>
                        </div>
                        <%-- pas de acte/classe/nomtable : gérés par le servlet --%>
                    </form>
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
