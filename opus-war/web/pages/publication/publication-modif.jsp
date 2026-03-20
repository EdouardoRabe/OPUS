<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Typepublication" %>
<%@ page import="alumni.ProfilLib" %>
<%
    String lien     = (String) session.getValue("lien");
    String id       = "";
    String fromPage = request.getParameter("from");
    if (fromPage == null || fromPage.isEmpty()) fromPage = "accueil.jsp";
    String apres    = fromPage;
    String mapping  = "alumni.Publication";
    String nomtable = "publication";
    String titre    = "Modification publication";
    String htmlForm = "";
    String descActuelle = "";
    String typeActuel   = "";
    int idutilActuel    = 0;

    UserEJB uModif = (user.UserEJB) session.getValue("u");
    int refModif   = uModif.getUser().getRefuser();

    // Charger les types de publication
    Typepublication[] typesPub = (Typepublication[]) CGenUtil.rechercher(
            new Typepublication(), null, null, " order by idtypepublication");
    if (typesPub == null) typesPub = new Typepublication[0];

    try {
        Publication t = new Publication();

        PageUpdate pu = new PageUpdate(t, request, uModif);
        pu.setLien(lien);
        pu.setTitre(titre);

        pu.getFormu().getChamp("idpublication").setLibelle("ID");
        pu.getFormu().getChamp("idpublication").setAutre("readonly");

        pu.getFormu().getChamp("descritpion").setLibelle("Description");

        // Cacher les champs non modifiables par le user
        pu.getFormu().getChamp("daty").setVisible(false);
        pu.getFormu().getChamp("heure").setVisible(false);
        pu.getFormu().getChamp("etat").setVisible(false);
        pu.getFormu().getChamp("idorigine").setVisible(false);
        pu.getFormu().getChamp("idutilisateur").setVisible(false);
        pu.getFormu().getChamp("idpuborigine").setVisible(false);
        pu.getFormu().getChamp("idtypepublication").setVisible(false);

        pu.preparerDataFormu();

        id             = pu.getBase().getTuppleID();
        descActuelle   = ((Publication) pu.getBase()).getDescritpion();
        typeActuel     = ((Publication) pu.getBase()).getIdtypepublication();
        idutilActuel   = ((Publication) pu.getBase()).getIdutilisateur();
        if (descActuelle == null) descActuelle = "";
        if (typeActuel == null) typeActuel = "";

        // Verifier que c'est bien le proprietaire
        if (idutilActuel != refModif) {
%>
<script>alert("Vous ne pouvez modifier que vos propres publications."); history.back();</script>
<%
            return;
        }

        pu.getFormu().makeHtmlInsertTabIndex();
        htmlForm = pu.getFormu().getHtmlInsert();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!-- Publication modification styles extracted to external CSS -->
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/pages/publication-modif-page.css" />

<div class="pm-page">

    <!-- ═══ HEADER CARD ═══ -->
    <div class="pm-header-card">
        <a href="<%= lien %>?but=<%= apres %>" class="pm-back-btn" title="Retour">
            <i class="fa fa-arrow-left"></i>
        </a>
        <div>
            <h1 class="pm-header-title">Modifier la publication</h1>
            <div class="pm-header-subtitle">Modifiez le type ou la description de votre publication</div>
        </div>
    </div>

    <!-- ═══ FORM CARD ═══ -->
    <div class="pm-form-card">
        <form id="formModif">
            <input type="hidden" name="idpublication" value="<%= id %>">

            <div class="pm-form-body">
                <!-- User avatar + Type select (Facebook composer header) -->
                <div class="pm-type-section">
                    <div class="pm-type-avatar">
                        <%
                            // Photo profil connecté (même pattern que accueil.jsp)
                            String _pmPhoto = "";
                            String _pmInitiale = "";
                            try {
                                ProfilLib[] _pmProfils = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, " and refuser=" + refModif);
                                if (_pmProfils != null && _pmProfils.length > 0) {
                                    if (_pmProfils[0].getPhotoProfil() != null && !_pmProfils[0].getPhotoProfil().trim().isEmpty())
                                        _pmPhoto = request.getContextPath() + "/" + _pmProfils[0].getPhotoProfil().trim();
                                }
                            } catch(Exception _ex) {}
                            String _pmNom = uModif.getUser().getNomuser();
                            if (_pmNom == null) _pmNom = "";
                            if (!_pmNom.isEmpty()) _pmInitiale = _pmNom.substring(0,1).toUpperCase();
                        %>
                        <% if (!_pmPhoto.isEmpty()) { %>
                            <img src="<%= _pmPhoto %>" alt="">
                        <% } else { %>
                            <%= _pmInitiale %>
                        <% } %>
                    </div>
                    <div class="pm-type-info">
                        <div class="pm-type-name"><%= _pmNom %></div>
                        <select name="idtypepublication" id="idtypepublication" class="pm-type-select">
                            <% for (int tp = 0; tp < typesPub.length; tp++) { %>
                            <option value="<%= typesPub[tp].getIdtypepublication() %>"
                                    <%= typeActuel.equals(typesPub[tp].getIdtypepublication()) ? "selected" : "" %>>
                                <%= typesPub[tp].getLibelle() %>
                            </option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <!-- Textarea (Facebook composer — borderless, immersive) -->
                <div class="pm-textarea-wrap" id="pmTextareaWrap">
                    <textarea name="descritpion" id="descritpion" class="pm-textarea"
                              placeholder="Qu'avez-vous en t&ecirc;te ?"><%= descActuelle %></textarea>
                </div>
            </div>

            <!-- Footer buttons -->
            <div class="pm-form-footer">
                <span class="pm-footer-hint">
                    <i class="fa fa-pencil" style="color:var(--itu-blue,#008BFF);"></i>
                    &Eacute;dition
                </span>
                <div class="pm-footer-actions">
                    <a href="<%= lien %>?but=<%= apres %>" class="pm-btn-cancel">Annuler</a>
                    <button type="submit" id="btnSubmit" class="pm-btn-submit">
                        <i class="fa fa-check"></i> Enregistrer
                    </button>
                </div>
            </div>
        </form>
    </div>

</div>

<script>
(function () {
    // Textarea focus effect (subtle bottom accent line)
    var ta = document.getElementById("descritpion");
    var wrap = document.getElementById("pmTextareaWrap");
    if (ta && wrap) {
        ta.addEventListener("focus", function() { wrap.classList.add("pm-textarea-wrap--focus"); });
        ta.addEventListener("blur",  function() { wrap.classList.remove("pm-textarea-wrap--focus"); });
    }

    // Auto-resize textarea
    if (ta) {
        function autoResize() {
            ta.style.height = "auto";
            ta.style.height = Math.max(160, ta.scrollHeight) + "px";
        }
        ta.addEventListener("input", autoResize);
        autoResize();
    }

    // Form submit
    document.getElementById("formModif").addEventListener("submit", function(e) {
        e.preventDefault();
        var btn = document.getElementById("btnSubmit");
        btn.disabled = true;
        btn.innerHTML = '<span class="pm-spinner"></span> Enregistrement...';

        fetch("<%= request.getContextPath() %>/pages/publication/ajax/traitement-update.jsp", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
            body: new URLSearchParams(new FormData(this)).toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                window.location.href = "<%= lien %>?but=<%= apres %>&highlight=" + data.id;
            } else {
                alert("Erreur : " + data.error);
                btn.disabled = false;
                btn.innerHTML = '<i class="fa fa-check"></i> Enregistrer';
            }
        })
        .catch(function(err) {
            alert("Erreur r\u00e9seau : " + err);
            btn.disabled = false;
            btn.innerHTML = '<i class="fa fa-check"></i> Enregistrer';
        });
    });
})();
</script>
