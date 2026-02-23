<%@ page import="affichage.PageConsulte" %>
<%@ page import="alumni.Evenement" %>
<%@ page import="alumni.ParticipationEvenement" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.Publication" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%
    try {
        String lien = (String) session.getValue("lien");
        user.UserEJB uFiche = (user.UserEJB) session.getValue("u");
        int currentUserId = (uFiche != null) ? uFiche.getUser().getRefuser() : 0;

        Evenement t = new Evenement();
        PageConsulte pc = new PageConsulte(t, request, uFiche);
        t = (Evenement) pc.getBase();
        String id = request.getParameter("idevenement");
        if (id == null || id.isEmpty()) id = t.getTuppleID();

        String description = t.getDescription() != null ? t.getDescription() : "";
        String datedebut   = t.getDatedebut()   != null ? t.getDatedebut().toString()   : "";
        String datefin     = t.getDatefin()      != null ? t.getDatefin().toString()      : "";
        String daty        = t.getDaty()         != null ? t.getDaty().toString()         : "";

        String classe   = "alumni.Evenement";
        String nomTable = "evenement";
        String initial  = description.isEmpty() ? "E" : String.valueOf(Character.toUpperCase(description.charAt(0)));

        /* ── Charger les participants ── */
        Connection connFiche = null;
        java.util.List participantsList = new java.util.ArrayList();
        boolean dejaPublie = false;
        try {
            connFiche = new UtilDB().GetConn();

            // Participations pour cet événement
            ParticipationEvenement[] parts = (ParticipationEvenement[]) CGenUtil.rechercher(
                new ParticipationEvenement(), null, null, connFiche,
                " and idevenement = '" + id + "'");
            if (parts != null) {
                for (int p = 0; p < parts.length; p++) {
                    int uid = parts[p].getIdutilisateur();
                    // Chercher profil via ProfilLib (vue avec loginuser)
                    ProfilLib[] profs = (ProfilLib[]) CGenUtil.rechercher(
                        new ProfilLib(), null, null, connFiche,
                        " and refuser = " + uid);
                    if (profs != null && profs.length > 0) {
                        participantsList.add(profs[0]);
                    }
                }
            }

            // Vérifier si une publication existe déjà avec idorigine = cet événement
            Publication[] pubs = (Publication[]) CGenUtil.rechercher(
                new Publication(), null, null, connFiche,
                " and idorigine = '" + id + "'");
            dejaPublie = (pubs != null && pubs.length > 0);

        } catch (Exception ex) { ex.printStackTrace(); }
        finally { if (connFiche != null) try { connFiche.close(); } catch (Exception ex) {} }
%>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <a href="<%= lien %>?but=evenement/evenement-list.jsp"
           style="color:var(--gray-400);margin-right:10px;font-size:1rem;vertical-align:middle;"
           title="Retour à la liste">
            <i class="fa fa-arrow-left"></i>
        </a>
        <i class="fa fa-calendar-check-o" style="color:var(--itu-blue);font-size:1.1rem;margin-right:8px;"></i>
        Fiche &eacute;v&eacute;nement
    </h1>
    <span style="font-size:0.85rem;color:var(--gray-500);">
        <a href="<%= lien %>?but=evenement/evenement-list.jsp"
           style="color:var(--gray-500);text-decoration:none;">
            <i class="fa fa-calendar" style="margin-right:4px;"></i>Liste des &eacute;v&eacute;nements
        </a>
    </span>
</div>

<style>
.evt-fiche-card {
    max-width: 720px;
    margin: 0 auto;
    background: var(--white);
    border-radius: 16px;
    box-shadow: 0 2px 16px rgba(0,0,0,0.08);
    overflow: hidden;
    border: 1px solid var(--gray-200);
}
.evt-fiche-banner {
    height: 130px;
    background: linear-gradient(135deg, #0057b7 0%, #009fd9 60%, #00c6a7 100%);
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
}
.evt-fiche-banner-icon {
    width: 64px;
    height: 64px;
    background: rgba(255,255,255,0.2);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.8rem;
    color: #fff;
}
.evt-fiche-actions-top {
    position: absolute;
    bottom: 12px;
    right: 20px;
    display: flex;
    gap: 0.5rem;
}
.evt-fiche-body {
    padding: 2rem 2rem 2.5rem;
}
.evt-fiche-title {
    font-size: 1.45rem;
    font-weight: 700;
    color: var(--itu-dark);
    margin: 0 0 0.3rem;
    line-height: 1.3;
}
.evt-fiche-subtitle {
    font-size: 0.82rem;
    color: var(--gray-400);
    margin: 0 0 1.4rem;
    display: flex;
    align-items: center;
    gap: 0.4rem;
}
.evt-fiche-divider {
    border: none;
    border-top: 1px solid var(--gray-200);
    margin: 1.4rem 0;
}
.evt-fiche-section-label {
    font-size: 0.73rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--gray-400);
    margin-bottom: 0.5rem;
}
.evt-detail-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 1rem;
    margin-bottom: 1.5rem;
}
.evt-detail-item {
    background: var(--gray-50, #f9fafb);
    border-radius: 10px;
    padding: 1rem 1.1rem;
    border: 1px solid var(--gray-100);
}
.evt-detail-item .label {
    font-size: 0.72rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--gray-400);
    margin-bottom: 0.3rem;
}
.evt-detail-item .value {
    font-size: 0.95rem;
    font-weight: 600;
    color: var(--itu-dark);
}
.evt-detail-item .value.empty {
    color: var(--gray-400);
    font-style: italic;
    font-weight: 400;
}
.btn-danger-outline {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 0.42rem 0.95rem;
    border-radius: 20px;
    font-size: 0.82rem;
    font-weight: 600;
    border: 1.5px solid rgba(255,255,255,0.7);
    color: #fff;
    background: rgba(229,62,62,0.18);
    cursor: pointer;
    text-decoration: none;
    transition: background 0.2s;
}
.btn-danger-outline:hover { background: rgba(229,62,62,0.35); color:#fff; text-decoration:none; }
.btn-edit-outline {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 0.42rem 0.95rem;
    border-radius: 20px;
    font-size: 0.82rem;
    font-weight: 600;
    border: 1.5px solid rgba(255,255,255,0.7);
    color: #fff;
    background: rgba(255,255,255,0.18);
    cursor: pointer;
    text-decoration: none;
    transition: background 0.2s;
}
.btn-edit-outline:hover { background: rgba(255,255,255,0.32); color:#fff; text-decoration:none; }
</style>

<!-- ═══ FICHE CARD ═══ -->
<div class="evt-fiche-card">

    <!-- Banner -->
    <div class="evt-fiche-banner">
        <div class="evt-fiche-banner-icon">
            <i class="fa fa-calendar-check-o"></i>
        </div>
        <!-- Action buttons -->
        <div class="evt-fiche-actions-top">
            <a href="<%= lien + "?but=apresTarif.jsp&id=" + id + "&acte=delete&bute=evenement/evenement-list.jsp&classe=" + classe + "&nomtable=" + nomTable %>"
               class="btn-danger-outline"
               onclick="return confirm('\u00cates-vous s\u00fbr de vouloir supprimer cet \u00e9v\u00e9nement ?');">
                <i class="fa fa-trash"></i> Supprimer
            </a>
            <a href="<%= lien + "?but=evenement/evenement-modif.jsp&idevenement=" + id %>"
               class="btn-edit-outline">
                <i class="fa fa-pencil"></i> Modifier
            </a>
        </div>
    </div>

    <!-- Contenu -->
    <div class="evt-fiche-body">
        <h2 class="evt-fiche-title"><%= description.isEmpty() ? "&mdash;" : description %></h2>
        <div class="evt-fiche-subtitle">
            <i class="fa fa-hashtag"></i>
            <span>&Eacute;v&eacute;nement &bull; ID <%= id %></span>
        </div>

        <hr class="evt-fiche-divider">

        <!-- Dates grid -->
        <div class="evt-fiche-section-label"><i class="fa fa-clock-o" style="margin-right:5px;"></i>Dates</div>
        <div class="evt-detail-grid">
            <div class="evt-detail-item">
                <div class="label"><i class="fa fa-play" style="margin-right:4px;color:var(--itu-blue);"></i>Date de d&eacute;but</div>
                <div class="value <%= datedebut.isEmpty() ? "empty" : "" %>">
                    <%= datedebut.isEmpty() ? "Non renseign&eacute;e" : datedebut %>
                </div>
            </div>
            <div class="evt-detail-item">
                <div class="label"><i class="fa fa-stop" style="margin-right:4px;color:#ef4444;"></i>Date de fin</div>
                <div class="value <%= datefin.isEmpty() ? "empty" : "" %>">
                    <%= datefin.isEmpty() ? "Non renseign&eacute;e" : datefin %>
                </div>
            </div>
            <div class="evt-detail-item">
                <div class="label"><i class="fa fa-calendar-plus-o" style="margin-right:4px;color:#10b981;"></i>Date de cr&eacute;ation</div>
                <div class="value <%= daty.isEmpty() ? "empty" : "" %>">
                    <%= daty.isEmpty() ? "Non renseign&eacute;e" : daty %>
                </div>
            </div>
        </div>

        <hr class="evt-fiche-divider">

        <!-- Description -->
        <div class="evt-fiche-section-label"><i class="fa fa-align-left" style="margin-right:5px;"></i>Description</div>
        <% if (description.isEmpty()) { %>
        <p style="font-size:0.92rem;color:var(--gray-400);font-style:italic;">Aucune description renseign&eacute;e.</p>
        <% } else { %>
        <p style="font-size:0.97rem;color:var(--gray-700);line-height:1.7;white-space:pre-wrap;"><%= description %></p>
        <% } %>

        <hr class="evt-fiche-divider">

        <!-- ═══ PARTICIPANTS ═══ -->
        <div class="evt-fiche-section-label"><i class="fa fa-users" style="margin-right:5px;"></i>Participants (<%= participantsList.size() %>)</div>
        <% if (participantsList.isEmpty()) { %>
        <p style="font-size:0.88rem;color:var(--gray-400);font-style:italic;margin-bottom:1rem;">Aucun participant pour le moment.</p>
        <% } else { %>
        <div style="display:flex;flex-direction:column;gap:0.5rem;margin-bottom:1.5rem;">
            <% for (int pi = 0; pi < participantsList.size(); pi++) {
                ProfilLib plib = (ProfilLib) participantsList.get(pi);
                String pNom = plib.getNom() != null ? plib.getNom() : "";
                String pPrenom = plib.getPrenom() != null ? plib.getPrenom() : "";
                String pLogin = plib.getLoginuser() != null ? plib.getLoginuser() : "";
                String pInitial = pNom.isEmpty() ? "?" : String.valueOf(Character.toUpperCase(pNom.charAt(0)));
                String[] avatarColors = {"#008BFF","#5B23FF","#ef4444","#10b981","#f59e0b","#8b5cf6","#06b6d4","#ec4899"};
                String avatarColor = avatarColors[pi % avatarColors.length];
            %>
            <div style="display:flex;align-items:center;gap:0.75rem;padding:0.6rem 0.85rem;background:var(--gray-50,#f9fafb);border-radius:10px;border:1px solid var(--gray-100);">
                <div style="width:36px;height:36px;border-radius:50%;background:<%= avatarColor %>;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:0.85rem;flex-shrink:0;"><%= pInitial %></div>
                <div style="flex:1;min-width:0;">
                    <div style="font-size:0.9rem;font-weight:600;color:var(--itu-dark);"><%= pNom %> <%= pPrenom %></div>
                    <div style="font-size:0.72rem;color:var(--gray-400);"><i class="fa fa-user" style="margin-right:3px;"></i><%= pLogin %></div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>

        <% if (!dejaPublie) { %>
        <hr class="evt-fiche-divider">
        <!-- ═══ BOUTON PUBLIER ═══ -->
        <div class="evt-fiche-section-label"><i class="fa fa-share-alt" style="margin-right:5px;"></i>Publication</div>
        <p style="font-size:0.85rem;color:var(--gray-500);margin-bottom:0.75rem;">Partager cet &eacute;v&eacute;nement sur le fil d'actualit&eacute;</p>
        <button id="btnPublierEvt" onclick="publierEvenement()" class="btn btn-primary"
                style="display:inline-flex;align-items:center;gap:8px;font-weight:600;font-size:0.9rem;padding:0.6rem 1.4rem;border-radius:10px;cursor:pointer;">
            <i class="fa fa-bullhorn"></i> Publier sur le fil
        </button>
        <div id="publishResult" style="margin-top:0.75rem;display:none;"></div>
        <% } else { %>
        <hr class="evt-fiche-divider">
        <div style="display:flex;align-items:center;gap:8px;font-size:0.85rem;color:#10b981;">
            <i class="fa fa-check-circle"></i> Cet &eacute;v&eacute;nement a d&eacute;j&agrave; &eacute;t&eacute; publi&eacute; sur le fil d'actualit&eacute;.
        </div>
        <% } %>
    </div>
</div>

<script>
function publierEvenement() {
    var btn = document.getElementById('btnPublierEvt');
    var resultDiv = document.getElementById('publishResult');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Publication en cours...';

    var ctx = '<%= request.getContextPath() %>';
    fetch(ctx + '/pages/evenement/ajax/traitement-publier.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'idevenement=<%= id %>'
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.success) {
            btn.style.display = 'none';
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = '<div style="display:flex;align-items:center;gap:8px;color:#10b981;font-size:0.9rem;font-weight:600;"><i class="fa fa-check-circle"></i> Publi\u00e9 avec succ\u00e8s sur le fil d\'actualit\u00e9 !</div>';
        } else {
            btn.disabled = false;
            btn.innerHTML = '<i class="fa fa-bullhorn"></i> Publier sur le fil';
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = '<div style="color:#e53e3e;font-size:0.85rem;"><i class="fa fa-exclamation-circle"></i> ' + (data.error || 'Erreur') + '</div>';
        }
    })
    .catch(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="fa fa-bullhorn"></i> Publier sur le fil';
        resultDiv.style.display = 'block';
        resultDiv.innerHTML = '<div style="color:#e53e3e;font-size:0.85rem;"><i class="fa fa-exclamation-circle"></i> Erreur de connexion</div>';
    });
}
</script>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
