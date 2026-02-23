<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page import="alumni.Specialite" %>
<%
    String lienSaisie    = (String) session.getValue("lien");
    String butApresPost  = "specialite/specialite-list.jsp";
    String htmlFormSaisie = "";
    try {
        Specialite a = new Specialite();
        PageInsert pi = new PageInsert(a, request, (user.UserEJB) session.getValue("u"));
        pi.setLien(lienSaisie);
        pi.getFormu().getChamp("libelle").setLibelle("Libell&eacute;");
        pi.getFormu().getChamp("description").setLibelle("Description");
        pi.getFormu().getChamp("photo").setLibelle("Photo");

        //Variables de navigation
        String butApresPost = "specialite/specialite-list.jsp";
        String[] ordre   = {"libelle", "description", "photo"};
        pi.getFormu().setOrdre(ordre);
        pi.preparerDataFormu();
        pi.getFormu().makeHtmlInsertTabIndex();
        htmlFormSaisie = pi.getFormu().getHtmlInsert();
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
                            <a href="<%= lienSaisie %>?but=specialite/specialite-list.jsp">
                                <i class="fa fa-arrow-circle-left"></i>
                            </a>
                            Saisie sp&eacute;cialit&eacute;
                        </h1>
                    </div>
                    <form id="formSaisie" enctype="multipart/form-data">
                        <style>#uploadBox { display:none !important; }</style>
                        <%= htmlFormSaisie %>
                        <div class="row">
                            <div class="col-md-11">
                                <button type="submit" class="btn btn-primary pull-right">Enregistrer</button>
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

    document.getElementById("formSaisie").addEventListener("submit", function(e) {
        e.preventDefault();
        var btn = this.querySelector("button[type=submit]");
        btn.disabled = true;
        btn.textContent = "Enregistrement...";

        fetch("<%= request.getContextPath() %>/pages/specialite/ajax/traitement-insert.jsp", {
            method: "POST",
            body: new FormData(this)
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                window.location.href = "<%= lienSaisie %>?but=<%= butApresPost %>";
            } else {
                alert("Erreur : " + data.error);
                btn.disabled = false;
                btn.textContent = "Enregistrer";
            }
        })
        .catch(function(err) {
            alert("Erreur reseau : " + err);
            btn.disabled = false;
            btn.textContent = "Enregistrer";
        });
    });
})();
</script>
