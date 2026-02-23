<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page import="alumni.Specialite" %>
<%
    String lien     = (String) session.getValue("lien");
    String id       = "";
    String apres    = "specialite/specialite-fiche.jsp";
    String photoPath = "";
    String mapping  = "alumni.Specialite";
    String nomtable = "specialite";
    String titre    = "Modification sp&eacute;cialit&eacute;";
    String htmlForm = "";
    try {
        Specialite t = new Specialite();

        PageUpdate pu = new PageUpdate(t, request, (user.UserEJB) session.getValue("u"));
        pu.setLien(lien);
        pu.setTitre(titre);

        pu.getFormu().getChamp("idspecialite").setLibelle("ID");
        pu.getFormu().getChamp("idspecialite").setAutre("readonly");
        pu.getFormu().getChamp("libelle").setLibelle("Libell&eacute;");

        // Description
        pu.getFormu().getChamp("description").setLibelle("Description");

        // Photo : libellé visible, le JS remplacera le textbox par un input file
        pu.getFormu().getChamp("photo").setLibelle("Photo");

        pu.preparerDataFormu();

        id        = pu.getBase().getTuppleID();
        photoPath = ((Specialite) pu.getBase()).getPhoto();
        if (photoPath == null) photoPath = "";
        htmlForm  = pu.getFormu().getHtmlInsert();
    } catch (Exception e) {
        e.printStackTrace();
    }
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
                            <%= titre %>
                        </h1>
                    </div>
                    <form id="formModif" enctype="multipart/form-data">
                        <style>#uploadBox { display:none !important; }</style>
                        <%= htmlForm %>

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

                        <div class="row">
                            <div class="col-md-11">
                                <button class="btn btn-primary pull-right" name="Submit2" type="submit">Valider</button>
                            </div>
                            <br><br>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
(function () {
    // Remplace l'input texte pour "photo" par un input type=file
    var input = document.getElementById("photo");
    if (input) {
        var fi = document.createElement("input");
        fi.type = "file"; fi.name = "photo"; fi.id = "photo";
        fi.accept = "image/*"; fi.className = input.className;
        input.parentNode.replaceChild(fi, input);
    }

    document.getElementById("formModif").addEventListener("submit", function(e) {
        e.preventDefault();
        var btn = this.querySelector("button[type=submit]");
        btn.disabled = true;
        btn.textContent = "Enregistrement...";

        fetch("<%= request.getContextPath() %>/pages/specialite/ajax/traitement-update.jsp", {
            method: "POST",
            body: new FormData(this)
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                window.location.href = "<%= lien %>?but=<%= apres %>&idspecialite=" + data.id;
            } else {
                alert("Erreur : " + data.error);
                btn.disabled = false;
                btn.textContent = "Valider";
            }
        })
        .catch(function(err) {
            alert("Erreur reseau : " + err);
            btn.disabled = false;
            btn.textContent = "Valider";
        });
    });
})();
</script>
