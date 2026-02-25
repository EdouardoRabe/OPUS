<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="alumni.Typesignalement" %>
<%@ page import="alumni.Publication" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="utilitaire.UtilDB" %>
<%
    UserEJB uSig = (UserEJB) session.getAttribute("u");
    if (uSig == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    MapUtilisateur mapSig = uSig.getUser();
    int refuserSig = mapSig.getRefuser();
    String ctx = request.getContextPath();

    String idpub = request.getParameter("idpublication");
    if (idpub == null || idpub.trim().isEmpty()) {
        response.sendRedirect(ctx + "/pages/module.jsp?but=accueil.jsp");
        return;
    }

    // Charger les types de signalement (APJ)
    Typesignalement[] types = (Typesignalement[]) CGenUtil.rechercher(
        new Typesignalement(), null, null, " order by idtypesignalement");
    if (types == null) types = new Typesignalement[0];

    // Message flash
    String sigSucces = (String) session.getAttribute("sigSucces");
    if (sigSucces != null) session.removeAttribute("sigSucces");
    String sigErreur = (String) session.getAttribute("sigErreur");
    if (sigErreur != null) session.removeAttribute("sigErreur");
%>

<style>
:root {
    --itu-blue: #008BFF;
    --sig-bg: #f8f9fb;
    --sig-card-bg: #fff;
    --sig-text: #1d2129;
    --sig-text-secondary: #65676b;
    --sig-border: #dde3ec;
}

.sig-container {
    max-width: 580px;
    margin: 20px auto;
    padding: 0 16px;
}

.sig-back-link {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: var(--sig-text-secondary);
    text-decoration: none;
    font-size: 14px;
    margin-bottom: 16px;
    transition: color .15s;
}
.sig-back-link:hover { color: var(--itu-blue); }

.sig-card {
    background: var(--sig-card-bg);
    border-radius: 12px;
    box-shadow: 0 1px 4px rgba(0,0,0,.12);
    padding: 24px;
}

.sig-title {
    font-size: 20px;
    font-weight: 700;
    color: var(--sig-text);
    margin: 0 0 4px;
}
.sig-subtitle {
    font-size: 14px;
    color: var(--sig-text-secondary);
    margin: 0 0 20px;
}

.sig-type-list {
    list-style: none;
    padding: 0;
    margin: 0 0 20px;
}
.sig-type-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 14px;
    border: 1px solid var(--sig-border);
    border-radius: 8px;
    margin-bottom: 8px;
    cursor: pointer;
    transition: background .15s, border-color .15s;
}
.sig-type-item:hover {
    background: #f0f6ff;
    border-color: var(--itu-blue);
}
.sig-type-item input[type="checkbox"] {
    width: 18px;
    height: 18px;
    accent-color: var(--itu-blue);
    cursor: pointer;
    flex-shrink: 0;
}
.sig-type-label {
    font-size: 15px;
    font-weight: 500;
    color: var(--sig-text);
    cursor: pointer;
    flex: 1;
}

.sig-desc-group {
    margin-bottom: 20px;
}
.sig-desc-group label {
    display: block;
    font-size: 14px;
    font-weight: 600;
    color: var(--sig-text);
    margin-bottom: 6px;
}
.sig-desc-group textarea {
    width: 100%;
    min-height: 80px;
    border: 1px solid var(--sig-border);
    border-radius: 8px;
    padding: 10px 12px;
    font-size: 14px;
    font-family: inherit;
    resize: vertical;
    transition: border-color .15s;
    box-sizing: border-box;
}
.sig-desc-group textarea:focus {
    outline: none;
    border-color: var(--itu-blue);
}

.sig-actions {
    display: flex;
    gap: 10px;
    justify-content: flex-end;
}
.sig-btn-cancel {
    padding: 10px 20px;
    background: #e4e6eb;
    color: var(--sig-text);
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: background .15s;
}
.sig-btn-cancel:hover { background: #d8dadf; }

.sig-btn-submit {
    padding: 10px 24px;
    background: #dc3545;
    color: #fff;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: background .15s;
}
.sig-btn-submit:hover { background: #c82333; }
.sig-btn-submit:disabled { background: #ccc; cursor: not-allowed; }

.sig-alert-success {
    background: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 16px;
    font-size: 14px;
}
.sig-alert-error {
    background: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 16px;
    font-size: 14px;
}
</style>

<div class="sig-container">

    <a href="javascript:history.back()" class="sig-back-link">
        <i class="bi bi-arrow-left"></i> Retour
    </a>

    <% if (sigSucces != null) { %>
    <div class="sig-alert-success"><i class="bi bi-check-circle"></i> <%= sigSucces %></div>
    <% } %>
    <% if (sigErreur != null) { %>
    <div class="sig-alert-error"><i class="bi bi-exclamation-circle"></i> <%= sigErreur %></div>
    <% } %>

    <div class="sig-card">
        <h2 class="sig-title"><i class="bi bi-flag" style="color:#dc3545;"></i> Signaler cette publication</h2>
        <p class="sig-subtitle">S&eacute;lectionnez le(s) motif(s) du signalement</p>

        <form id="formSignalement" method="POST" action="<%= ctx %>/pages/alumni/ajax/report-publication.jsp">
            <input type="hidden" name="idpublication" value="<%= idpub %>"/>

            <ul class="sig-type-list">
                <% for (int t = 0; t < types.length; t++) {
                    String tid = types[t].getIdTypesignalement();
                    String tlib = types[t].getLibelle();
                %>
                <li class="sig-type-item" onclick="toggleRadio(this)">
                    <input type="radio" name="typesignalement" value="<%= tid %>" id="tsg_<%= tid %>"/>
                    <label class="sig-type-label" for="tsg_<%= tid %>"><%= tlib %></label>
                </li>
                <% } %>
            </ul>

            <% if (types.length == 0) { %>
            <p style="color:#999; text-align:center; padding:20px 0;">Aucun type de signalement disponible.</p>
            <% } %>

            <div class="sig-desc-group">
                <label for="sigDescription">Description (optionnel)</label>
                <textarea id="sigDescription" name="description" placeholder="D&eacute;crivez le probl&egrave;me..."></textarea>
            </div>

            <div class="sig-actions">
                <button type="button" class="sig-btn-cancel" onclick="history.back()">Annuler</button>
                <button type="submit" class="sig-btn-submit" id="btnSubmitSignal" disabled>
                    <i class="bi bi-flag"></i> Envoyer le signalement
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function toggleRadio(li) {
        var radio = li.querySelector('input[type="radio"]');
        // ne toggle que si le click n'est pas directement sur le radio
        if (event && event.target.tagName !== 'INPUT') {
            radio.checked = !radio.checked;
        }
        updateSubmitBtn();
    }

    function updateSubmitBtn() {
        var checked = document.querySelectorAll('#formSignalement input[name="typesignalement"]:checked');
        document.getElementById('btnSubmitSignal').disabled = (checked.length === 0);
    }

    // Ecouter les changements directement sur les radio buttons aussi
    document.querySelectorAll('#formSignalement input[name="typesignalement"]').forEach(function(radio) {
        radio.addEventListener('change', updateSubmitBtn);
    });

    // Soumission AJAX
    document.getElementById('formSignalement').addEventListener('submit', function(e) {
        e.preventDefault();
        var form = this;
        var btn = document.getElementById('btnSubmitSignal');
        btn.disabled = true;
        btn.innerHTML = '<i class="bi bi-hourglass-split"></i> Envoi...';

        var formData = new FormData(form);
        // Récupérer le type sélectionné (un seul)
        var selectedType = document.querySelector('#formSignalement input[name="typesignalement"]:checked');

        var params = 'idpublication=' + encodeURIComponent(formData.get('idpublication'));
        params += '&description=' + encodeURIComponent(formData.get('description') || '');
        if (selectedType) {
            params += '&typesignalement=' + encodeURIComponent(selectedType.value);
        }

        fetch(form.action, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.success) {
                alert("Merci pour votre signalement. Nous utilisons vos retours pour améliorer la plateforme et détecter les contenus inappropriés.");
                window.location.href = '<%= ctx %>/pages/module.jsp?but=accueil.jsp'; // Redirige vers l'accueil
            } else {
                alert(d.error || 'Erreur inconnue');
                btn.disabled = false;
                btn.innerHTML = '<i class="bi bi-flag"></i> Envoyer le signalement';
            }
        })
        .catch(function(err) {
            alert('Erreur réseau');
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-flag"></i> Envoyer le signalement';
        });
    });
</script>
