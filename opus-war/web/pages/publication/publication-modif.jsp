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

<style>
    /* ── Facebook-style variables (cohérent accueil.jsp) ── */
    .pm-page {
        --fa-bg: #f0f2f5;
        --fa-card-bg: #ffffff;
        --fa-border: #e4e6eb;
        --fa-text: #050505;
        --fa-text-secondary: #65676b;
    }
    .pm-page {
        max-width: 680px;
        margin: 0 auto;
        padding: 0 0 40px;
    }

    /* ── Header card (Facebook "Créer une publication" style) ── */
    .pm-header-card {
        background: var(--fa-card-bg);
        border-radius: 12px;
        box-shadow: 0 1px 4px rgba(0,0,0,.12);
        padding: 14px 18px;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .pm-back-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 36px; height: 36px;
        border-radius: 50%;
        background: #f0f2f5;
        color: var(--fa-text-secondary);
        font-size: 16px;
        text-decoration: none;
        transition: background .15s, color .15s;
        flex-shrink: 0;
    }
    .pm-back-btn:hover { background: #e4e6eb; color: var(--fa-text); }
    .pm-header-title {
        font-weight: 700;
        font-size: 20px;
        color: var(--fa-text);
        margin: 0;
        line-height: 1.3;
    }
    .pm-header-subtitle {
        font-size: 13px;
        color: var(--fa-text-secondary);
        margin-top: 2px;
    }

    /* ── Form card (Facebook post-card style) ── */
    .pm-form-card {
        background: var(--fa-card-bg);
        border-radius: 12px;
        box-shadow: 0 1px 4px rgba(0,0,0,.12);
        overflow: hidden;
    }
    .pm-form-body {
        padding: 16px 18px 0;
    }

    /* ── Type select (Facebook-style compact badge dropdown) ── */
    .pm-type-section {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 14px;
        padding-bottom: 14px;
        border-bottom: 1px solid var(--fa-border);
    }
    .pm-type-avatar {
        width: 44px; height: 44px;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--itu-dark,#1c1e29) 0%, var(--itu-blue,#008BFF) 100%);
        color: #fff;
        font-weight: 700;
        font-size: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        user-select: none;
        overflow: hidden;
    }
    .pm-type-avatar img {
        width: 100%; height: 100%;
        object-fit: cover; border-radius: 50%;
    }
    .pm-type-info { flex: 1; min-width: 0; }
    .pm-type-name {
        font-weight: 700;
        font-size: 15px;
        color: var(--fa-text);
        margin-bottom: 4px;
    }
    .pm-type-select {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 4px 10px;
        background: #e4e6eb;
        border: none;
        border-radius: 6px;
        font-size: 13px;
        font-weight: 600;
        color: var(--fa-text);
        cursor: pointer;
        transition: background .15s;
        font-family: inherit;
        -webkit-appearance: none;
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%2365676b'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 8px center;
        padding-right: 24px;
    }
    .pm-type-select:hover { background: #d8dadf; }
    .pm-type-select:focus {
        outline: none;
        background: #d8dadf;
        box-shadow: 0 0 0 2px rgba(0,139,255,.2);
    }

    /* ── Textarea (Facebook composer style — borderless, immersive) ── */
    .pm-textarea-wrap {
        padding: 4px 0 16px;
    }
    .pm-textarea {
        width: 100%;
        min-height: 160px;
        border: none;
        outline: none;
        resize: none;
        font-size: 16px;
        line-height: 1.5;
        color: var(--fa-text);
        background: transparent;
        font-family: inherit;
        padding: 0;
        box-sizing: border-box;
    }
    .pm-textarea::placeholder {
        color: var(--fa-text-secondary);
    }
    .pm-textarea:focus {
        outline: none;
    }
    /* Subtle bottom hint line on focus */
    .pm-textarea-wrap--focus {
        border-bottom: 2px solid var(--itu-blue, #008BFF);
    }

    /* ── Footer buttons (Facebook style) ── */
    .pm-form-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px 18px;
        border-top: 1px solid var(--fa-border);
        gap: 10px;
    }
    .pm-footer-hint {
        font-size: 13px;
        color: var(--fa-text-secondary);
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .pm-footer-actions {
        display: flex;
        gap: 8px;
        margin-left: auto;
    }
    .pm-btn-cancel {
        padding: 8px 16px;
        background: #e4e6eb;
        border: none;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 600;
        color: var(--fa-text);
        cursor: pointer;
        transition: background .15s;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
    }
    .pm-btn-cancel:hover { background: #d8dadf; color: var(--fa-text); }
    .pm-btn-submit {
        padding: 8px 20px;
        background: var(--itu-blue, #008BFF);
        color: #fff;
        border: none;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 700;
        cursor: pointer;
        transition: background .15s, opacity .15s;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .pm-btn-submit:hover { background: #0069cc; }
    .pm-btn-submit:disabled { opacity: .5; cursor: default; }

    /* ── Spinner (same as accueil.jsp) ── */
    .pm-spinner {
        display: inline-block;
        width: 16px; height: 16px;
        border: 2px solid rgba(255,255,255,.4);
        border-top-color: #fff;
        border-radius: 50%;
        animation: pmSpin .7s linear infinite;
    }
    @keyframes pmSpin { to { transform: rotate(360deg); } }

    /* ── Hide APJ-generated chrome ── */
    #formModif .box,
    #formModif .box-body,
    #formModif .box-header { all: unset; display: block; }
    #formModif .box-footer { display: none !important; }
    #uploadBox { display: none !important; }
    #formModif .form-group { margin-bottom: 0; }
</style>

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
