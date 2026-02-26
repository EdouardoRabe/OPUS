<%@ page import="user.*" %>
<%@ page import="alumni.Limiterole" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%
    String lien  = (String) session.getValue("lien");
    String apres = "limiterole/limiterole-list.jsp";
    String idrole = request.getParameter("idrole");
    int valMaxpub = 0;

    if (idrole != null && !idrole.trim().isEmpty()) {
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            Limiterole[] arr = (Limiterole[]) CGenUtil.rechercher(
                new Limiterole(), null, null, conn,
                " and idrole='" + idrole.trim().replace("'","''") + "'"
            );
            if (arr != null && arr.length > 0) {
                Limiterole lr = arr[0];
                valMaxpub = lr.getMaxpublicationparjour();
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { if (conn != null) try { conn.close(); } catch (Exception ex) {} }
    }
    if (idrole == null) idrole = "";
%>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <a href="<%= lien %>?but=limiterole/limiterole-list.jsp"
           style="color:var(--gray-400);margin-right:10px;font-size:1rem;vertical-align:middle;"
           title="Retour &agrave; la liste">
            <i class="fa fa-arrow-left"></i>
        </a>
        <i class="fa fa-pencil" style="color:var(--itu-blue);font-size:1.1rem;margin-right:8px;"></i>
        Modifier la limite du r&ocirc;le
    </h1>
    <span style="font-size:0.85rem;color:var(--gray-500);">
        <a href="<%= lien %>?but=limiterole/limiterole-list.jsp"
           style="color:var(--gray-500);text-decoration:none;">
            <i class="fa fa-sliders" style="margin-right:4px;"></i>Liste des limites
        </a>
    </span>
</div>

<!-- ═══ FORM CARD ═══ -->
<div style="max-width:680px;margin:0 auto;">
    <div class="custom-card no-hover">

        <style>
            .lr-form-group { margin-bottom: 1.4rem; }
            .lr-form-label {
                display: block; font-size: 0.76rem; font-weight: 700;
                color: var(--itu-dark); margin-bottom: 0.45rem;
                letter-spacing: 0.04em; text-transform: uppercase;
            }
            .lr-form-label .req { color: #ef4444; margin-left: 2px; }
            .lr-form-input {
                width: 100%; padding: 0.72rem 1rem;
                border: 1.5px solid var(--gray-200); border-radius: var(--radius-md, 8px);
                font-family: var(--font-sans, 'Inter', sans-serif); font-size: 0.92rem;
                outline: none; background: var(--white, #fff); color: var(--itu-dark, #1a1a2e);
                transition: border-color .2s ease, box-shadow .2s ease; box-sizing: border-box;
            }
            .lr-form-input:focus {
                border-color: var(--itu-blue, #008BFF);
                box-shadow: 0 0 0 3px rgba(0,139,255,0.1);
            }
            .lr-form-input[readonly] {
                background: var(--gray-100, #f3f4f6);
                color: var(--gray-500, #6b7280);
                cursor: not-allowed;
            }
            .lr-form-hint { font-size: 0.72rem; color: var(--gray-400, #9ca3af); margin-top: 0.3rem; }
            .lr-form-actions {
                display: flex; justify-content: flex-end; align-items: center;
                gap: 0.75rem; margin-top: 2rem; padding-top: 1.25rem;
                border-top: 1px solid var(--gray-100, #f3f4f6);
            }
            .lr-form-error {
                display: none; background: #fef2f2; border: 1px solid #fecaca;
                color: #dc2626; border-radius: 8px; padding: 0.7rem 1rem;
                font-size: 0.85rem; margin-bottom: 1.25rem; align-items: center; gap: 0.5rem;
            }
            .lr-form-error.show { display: flex; }
            .lr-info-box {
                background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 8px;
                padding: 0.8rem 1rem; font-size: 0.82rem; color: #1e40af;
                margin-bottom: 1.5rem; display: flex; align-items: flex-start; gap: 0.6rem;
            }
            .lr-info-box i { margin-top: 2px; }
        </style>

        <form id="formModif">
            <input type="hidden" name="idrole" value="<%= idrole %>">

            <div class="lr-form-error" id="formError">
                <i class="fa fa-exclamation-circle"></i>
                <span id="formErrorMsg"></span>
            </div>

            <div class="lr-info-box">
                <i class="fa fa-info-circle"></i>
                <span>
                    <strong>0</strong> = interdit de publier &nbsp;|&nbsp;
                    <strong>-1</strong> = illimit&eacute; &nbsp;|&nbsp;
                    <strong>N</strong> = max N publications par jour
                </span>
            </div>

            <!-- ID Role (readonly) -->
            <div class="lr-form-group">
                <label class="lr-form-label">
                    <i class="fa fa-shield" style="margin-right:5px;color:var(--gray-400);"></i> R&ocirc;le
                </label>
                <input class="lr-form-input" type="text" value="<%= idrole %>" readonly>
            </div>

            <!-- Max publications par jour -->
            <div class="lr-form-group">
                <label class="lr-form-label">
                    <i class="fa fa-tachometer" style="margin-right:5px;color:var(--itu-blue);"></i>
                    Max publications par jour <span class="req">*</span>
                </label>
                <input class="lr-form-input" type="number" id="maxpublicationparjour" name="maxpublicationparjour"
                       value="<%= valMaxpub %>" required min="-1">
                <div class="lr-form-hint">Entrez 0 pour bloquer, -1 pour illimit&eacute;, ou un nombre positif pour limiter.</div>
            </div>

            <!-- Actions -->
            <div class="lr-form-actions">
                <a href="<%= lien %>?but=limiterole/limiterole-list.jsp" class="btn btn-ghost">Annuler</a>
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
    var form   = document.getElementById('formModif');
    var btn    = document.getElementById('btnSubmit');
    var errEl  = document.getElementById('formError');
    var errMsg = document.getElementById('formErrorMsg');

    function showError(msg) {
        errMsg.textContent = msg;
        errEl.classList.add('show');
        errEl.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
    function hideError() { errEl.classList.remove('show'); }

    form.addEventListener('submit', function(e) {
        e.preventDefault();
        hideError();

        var maxpub = document.getElementById('maxpublicationparjour').value;

        if (maxpub === '' || maxpub === null) {
            showError('Le nombre max de publications est obligatoire.');
            return;
        }
        var maxpubInt = parseInt(maxpub);
        if (isNaN(maxpubInt)) {
            showError('Veuillez entrer un nombre valide.');
            return;
        }
        if (maxpubInt < -1) {
            showError('La valeur minimale est -1 (illimit\u00e9).');
            return;
        }

        btn.disabled = true;
        btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Enregistrement...';

        var params = new URLSearchParams(new FormData(this));

        fetch('<%= request.getContextPath() %>/pages/limiterole/ajax/traitement-update.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                window.location.href = '<%= lien %>?but=limiterole/limiterole-list.jsp';
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
