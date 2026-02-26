<%@ page import="user.*" %>
<%@ page import="alumni.Evenement" %>
<%
    String lienSaisie   = (String) session.getValue("lien");
    String butApresPost = "evenement/evenement-list.jsp";
%>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <a href="<%= lienSaisie %>?but=evenement/evenement-list.jsp"
            style="color:var(--gray-400);margin-right:10px;font-size:1rem;vertical-align:middle;"
            title="Retour &agrave; la liste">
            <i class="fa fa-arrow-left"></i>
        </a>
        <i class="fa fa-plus-circle" style="color:var(--itu-blue);font-size:1.1rem;margin-right:8px;"></i>
        Nouvel &eacute;v&eacute;nement
    </h1>
    <span style="font-size:0.85rem;color:var(--gray-500);">
        <a href="<%= lienSaisie %>?but=evenement/evenement-list.jsp"
            style="color:var(--gray-500);text-decoration:none;">
            <i class="fa fa-calendar" style="margin-right:4px;"></i>Liste des &eacute;v&eacute;nements
        </a>
    </span>
</div>

<!-- ═══ FORM CARD ═══ -->
<div style="max-width:680px;margin:0 auto;">
    <div class="custom-card no-hover">

        <style>
            .evt-form-group { margin-bottom: 1.4rem; }
            .evt-form-label {
                display: block; font-size: 0.76rem; font-weight: 700;
                color: var(--itu-dark); margin-bottom: 0.45rem;
                letter-spacing: 0.04em; text-transform: uppercase;
            }
            .evt-form-label .req { color: #ef4444; margin-left: 2px; }
            .evt-form-input, .evt-form-textarea {
                width: 100%; padding: 0.72rem 1rem;
                border: 1.5px solid var(--gray-200); border-radius: var(--radius-md, 8px);
                font-family: var(--font-sans, 'Inter', sans-serif); font-size: 0.92rem;
                outline: none; background: var(--white, #fff); color: var(--itu-dark, #1a1a2e);
                transition: border-color .2s ease, box-shadow .2s ease; box-sizing: border-box;
            }
            .evt-form-input:focus, .evt-form-textarea:focus {
                border-color: var(--itu-blue, #008BFF);
                box-shadow: 0 0 0 3px rgba(0,139,255,0.1);
            }
            .evt-form-textarea { resize: vertical; min-height: 100px; }
            .evt-form-hint { font-size: 0.72rem; color: var(--gray-400, #9ca3af); margin-top: 0.3rem; }
            .evt-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
            @media (max-width: 520px) { .evt-form-row { grid-template-columns: 1fr; } }
            .evt-form-actions {
                display: flex; justify-content: flex-end; align-items: center;
                gap: 0.75rem; margin-top: 2rem; padding-top: 1.25rem;
                border-top: 1px solid var(--gray-100, #f3f4f6);
            }
            .evt-form-error {
                display: none; background: #fef2f2; border: 1px solid #fecaca;
                color: #dc2626; border-radius: 8px; padding: 0.7rem 1rem;
                font-size: 0.85rem; margin-bottom: 1.25rem; align-items: center; gap: 0.5rem;
            }
            .evt-form-error.show { display: flex; }
        </style>

        <form id="formSaisie">
            <div class="evt-form-error" id="formError">
                <i class="fa fa-exclamation-circle"></i>
                <span id="formErrorMsg"></span>
            </div>

            <div class="evt-form-group">
                <label class="evt-form-label">
                    <i class="fa fa-align-left" style="margin-right:5px;color:var(--itu-blue);"></i>
                    Description <span class="req">*</span>
                </label>
                <textarea class="evt-form-textarea" id="description" name="description"
                            rows="4" placeholder="D&eacute;crivez l'&eacute;v&eacute;nement..." required></textarea>
            </div>

            <div class="evt-form-row">
                <div class="evt-form-group">
                    <label class="evt-form-label">
                        <i class="fa fa-play" style="margin-right:5px;color:#10b981;"></i>
                        Date de d&eacute;but <span class="req">*</span>
                    </label>
                    <input class="evt-form-input" type="date" id="datedebut" name="datedebut" required>
                </div>
                <div class="evt-form-group">
                    <label class="evt-form-label">
                        <i class="fa fa-stop" style="margin-right:5px;color:#ef4444;"></i>
                        Date de fin
                    </label>
                    <input class="evt-form-input" type="date" id="datefin" name="datefin">
                    <div class="evt-form-hint">Optionnel</div>
                </div>
            </div>

            <div class="evt-form-actions">
                <a href="<%= lienSaisie %>?but=evenement/evenement-list.jsp" class="btn btn-ghost">Annuler</a>
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
    var form   = document.getElementById('formSaisie');
    var btn    = document.getElementById('btnSubmit');
    var errEl  = document.getElementById('formError');
    var errMsg = document.getElementById('formErrorMsg');

    // Valeurs par défaut
    var today = new Date();
    var yyyy = today.getFullYear();
    var mm = String(today.getMonth() + 1).padStart(2, '0');
    var dd = String(today.getDate()).padStart(2, '0');
    var todayStr = yyyy + '-' + mm + '-' + dd;
    document.getElementById('datedebut').value = todayStr;
    document.getElementById('datedebut').min = todayStr;
    document.getElementById('datefin').value = todayStr;
    document.getElementById('datefin').min = todayStr;
    document.getElementById('description').value = 'Evenement ITU';
    

    function showError(msg) {
        errMsg.textContent = msg;
        errEl.classList.add('show');
        errEl.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
    function hideError() { errEl.classList.remove('show'); }

    form.addEventListener('submit', function(e) {
        e.preventDefault();
        hideError();

        var desc  = document.getElementById('description').value.trim();
        var debut = document.getElementById('datedebut').value;
        var fin   = document.getElementById('datefin').value;

        if (!desc)  { showError('La description est obligatoire.'); return; }
        if (!debut) { showError('La date de d\u00e9but est obligatoire.'); return; }
        if (fin && fin < debut) { showError('La date de fin ne peut pas \u00eatre avant la date de d\u00e9but.'); return; }

        btn.disabled = true;
        btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Enregistrement...';

        var params = new URLSearchParams();
        params.append('description', desc);
        params.append('datedebut', debut);
        if (fin) params.append('datefin', fin);

        fetch('<%= request.getContextPath() %>/pages/evenement/ajax/traitement-insert.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                window.location.href = '<%= lienSaisie %>?but=<%= butApresPost %>';
            } else {
                showError(data.error || 'Erreur inconnue');
                btn.disabled = false;
                btn.innerHTML = '<i class="fa fa-check"></i> Enregistrer';
            }
        })
        .catch(function(err) {
            showError('Erreur r\u00e9seau : ' + err);
            btn.disabled = false;
            btn.innerHTML = '<i class="fa fa-check"></i> Enregistrer';
        });
    });
})();
</script>
