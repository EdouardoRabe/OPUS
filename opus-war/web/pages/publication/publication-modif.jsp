<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Typepublication" %>
<%
    String lien     = (String) session.getValue("lien");
    String id       = "";
    String apres    = "accueil.jsp";
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

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <a href="<%= lien %>?but=accueil.jsp"
           style="color:var(--gray-400);margin-right:10px;font-size:1rem;vertical-align:middle;"
           title="Retour à l'accueil">
            <i class="fa fa-arrow-left"></i>
        </a>
        <i class="fa fa-pencil" style="color:var(--itu-blue);font-size:1.1rem;margin-right:8px;"></i>
        Modifier la publication
    </h1>
</div>

<!-- ═══ FORM CARD ═══ -->
<div style="max-width:680px;margin:0 auto;">
    <div class="custom-card no-hover">

        <form id="formModif">
            <input type="hidden" name="idpublication" value="<%= id %>">

            <style>
                /* ── Scope APJ-generated fields to alumni theme ── */
                #formModif .form-group label,
                #formModif label {
                    font-size: 0.78rem;
                    font-weight: 700;
                    color: var(--itu-dark);
                    margin-bottom: 0.4rem;
                    letter-spacing: 0.04em;
                    text-transform: uppercase;
                    display: block;
                }
                #formModif input[type=text],
                #formModif textarea,
                #formModif select {
                    width: 100%;
                    padding: 0.72rem 1rem;
                    border: 1.5px solid var(--gray-200);
                    border-radius: var(--radius-md);
                    font-family: var(--font-sans);
                    font-size: 0.92rem;
                    outline: none;
                    background: var(--white);
                    color: var(--itu-dark);
                    transition: border-color 0.2s ease, box-shadow 0.2s ease;
                    box-sizing: border-box;
                }
                #formModif input[type=text]:focus,
                #formModif textarea:focus,
                #formModif select:focus {
                    border-color: var(--itu-blue);
                    box-shadow: 0 0 0 3px rgba(0,139,255,0.1);
                }
                #formModif .form-group {
                    margin-bottom: 1.25rem;
                }
                #formModif .box,
                #formModif .box-body,
                #formModif .box-header { all: unset; display: block; }
                #formModif .box-footer {
                    all: unset;
                    display: flex !important;
                    justify-content: flex-end;
                    align-items: center;
                    gap: 0.75rem;
                    margin-top: 1.75rem;
                    padding-top: 1.25rem;
                }
                #formModif .box-footer .btn { float: none !important; margin: 0 !important; }
                #uploadBox { display: none !important; }
                /* Type publication custom select */
                .type-pub-group {
                    margin-bottom: 1.25rem;
                }
                .type-pub-group label {
                    font-size: 0.78rem;
                    font-weight: 700;
                    color: var(--itu-dark);
                    margin-bottom: 0.4rem;
                    letter-spacing: 0.04em;
                    text-transform: uppercase;
                    display: block;
                }
                .type-pub-group select {
                    width: 100%;
                    padding: 0.72rem 1rem;
                    border: 1.5px solid var(--gray-200);
                    border-radius: var(--radius-md);
                    font-family: var(--font-sans);
                    font-size: 0.92rem;
                    outline: none;
                    background: var(--white);
                    color: var(--itu-dark);
                }
                /* Description custom textarea */
                .desc-group {
                    margin-bottom: 1.25rem;
                }
                .desc-group label {
                    font-size: 0.78rem;
                    font-weight: 700;
                    color: var(--itu-dark);
                    margin-bottom: 0.4rem;
                    letter-spacing: 0.04em;
                    text-transform: uppercase;
                    display: block;
                }
                .desc-group textarea {
                    width: 100%;
                    min-height: 150px;
                    padding: 0.72rem 1rem;
                    border: 1.5px solid var(--gray-200);
                    border-radius: var(--radius-md);
                    font-family: var(--font-sans);
                    font-size: 0.92rem;
                    outline: none;
                    background: var(--white);
                    color: var(--itu-dark);
                    resize: vertical;
                }
                .desc-group textarea:focus {
                    border-color: var(--itu-blue);
                    box-shadow: 0 0 0 3px rgba(0,139,255,0.1);
                }
            </style>

            <!-- Type de publication -->
            <div class="type-pub-group">
                <label for="idtypepublication">Type de publication</label>
                <select name="idtypepublication" id="idtypepublication">
                    <% for (int tp = 0; tp < typesPub.length; tp++) { %>
                    <option value="<%= typesPub[tp].getIdtypepublication() %>"
                            <%= typeActuel.equals(typesPub[tp].getIdtypepublication()) ? "selected" : "" %>>
                        <%= typesPub[tp].getLibelle() %>
                    </option>
                    <% } %>
                </select>
            </div>

            <!-- Description -->
            <div class="desc-group">
                <label for="descritpion">Description</label>
                <textarea name="descritpion" id="descritpion"><%= descActuelle %></textarea>
            </div>

            <!-- Boutons -->
            <div style="display:flex;justify-content:flex-end;align-items:center;gap:0.75rem;margin-top:1.75rem;padding-top:1.25rem;">
                <a href="<%= lien %>?but=accueil.jsp" class="btn btn-ghost">Annuler</a>
                <button type="submit" id="btnSubmit" class="btn btn-primary"
                        style="display:inline-flex;align-items:center;gap:6px;">
                    <i class="fa fa-check"></i> Enregistrer
                </button>
            </div>
        </form>

    </div>
</div>

<script>
(function () {
    document.getElementById("formModif").addEventListener("submit", function(e) {
        e.preventDefault();
        var btn = document.getElementById("btnSubmit");
        btn.disabled = true;
        btn.innerHTML = '<i class="fa fa-spinner fa-spin" style="margin-right:5px;"></i>Enregistrement...';

        fetch("<%= request.getContextPath() %>/pages/publication/ajax/traitement-update.jsp", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
            body: new URLSearchParams(new FormData(this)).toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                alert("Publication modifi\u00e9e avec succ\u00e8s !");
                window.location.href = "<%= lien %>?but=accueil.jsp";
            } else {
                alert("Erreur : " + data.error);
                btn.disabled = false;
                btn.innerHTML = '<i class="fa fa-check" style="margin-right:5px;"></i>Enregistrer';
            }
        })
        .catch(function(err) {
            alert("Erreur r\u00e9seau : " + err);
            btn.disabled = false;
            btn.innerHTML = '<i class="fa fa-check" style="margin-right:5px;"></i>Enregistrer';
        });
    });
})();
</script>
