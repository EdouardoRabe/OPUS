<%@ page import="affichage.PageConsulte" %>
<%@ page import="alumni.SpecialiteCpl" %>
<%
    try {
        String lien = (String) session.getValue("lien");
        SpecialiteCpl t = new SpecialiteCpl();
        PageConsulte pc = new PageConsulte(t, request, (user.UserEJB) session.getValue("u"));
        t = (SpecialiteCpl) pc.getBase();
        String id = request.getParameter("idspecialite");
        if (id == null || id.isEmpty()) id = t.getTuppleID();

        String libelle     = t.getLibelle()     != null ? t.getLibelle()     : "";
        String description = t.getDescription() != null ? t.getDescription() : "";
        String photo       = t.getPhoto()       != null ? t.getPhoto()       : "";
        String classe   = "alumni.Specialite";
        String nomTable = "specialite";
        String photoSrc = photo.isEmpty() ? "" : request.getContextPath() + "/" + photo;
        String initial  = libelle.isEmpty() ? "?" : String.valueOf(Character.toUpperCase(libelle.charAt(0)));
%>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <a href="<%= lien %>?but=specialite/specialite-list.jsp"
           style="color:var(--gray-400);margin-right:10px;font-size:1rem;vertical-align:middle;"
           title="Retour à la liste">
            <i class="fa fa-arrow-left"></i>
        </a>
        <i class="fa fa-tag" style="color:var(--itu-blue);font-size:1.1rem;margin-right:8px;"></i>
        Fiche sp&eacute;cialit&eacute;
    </h1>
    <span style="font-size:0.85rem;color:var(--gray-500);">
        <a href="<%= lien %>?but=specialite/specialite-list.jsp"
           style="color:var(--gray-500);text-decoration:none;">
            <i class="fa fa-tags" style="margin-right:4px;"></i>Liste des sp&eacute;cialit&eacute;s
        </a>
    </span>
</div>

<style>
.fiche-card {
    max-width: 720px;
    margin: 0 auto;
    background: var(--white);
    border-radius: 16px;
    box-shadow: 0 2px 16px rgba(0,0,0,0.08);
    overflow: hidden;
    border: 1px solid var(--gray-200);
}
.fiche-banner {
    height: 130px;
    background: linear-gradient(135deg, #0057b7 0%, #009fd9 60%, #00c6a7 100%);
    position: relative;
}
.fiche-avatar-wrap {
    position: absolute;
    bottom: -48px;
    left: 32px;
}
.fiche-avatar {
    width: 96px;
    height: 96px;
    border-radius: 50%;
    border: 4px solid var(--white);
    box-shadow: 0 4px 14px rgba(0,0,0,0.18);
    object-fit: cover;
    background: #e8f0fe;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2.2rem;
    font-weight: 700;
    color: #0057b7;
}
.fiche-avatar img {
    width: 100%;
    height: 100%;
    border-radius: 50%;
    object-fit: cover;
    display: block;
}
.fiche-actions-top {
    position: absolute;
    bottom: 12px;
    right: 20px;
    display: flex;
    gap: 0.5rem;
}
.fiche-body {
    padding: 64px 32px 32px;
}
.fiche-title {
    font-size: 1.45rem;
    font-weight: 700;
    color: var(--itu-dark);
    margin: 0 0 0.3rem;
    line-height: 1.3;
}
.fiche-subtitle {
    font-size: 0.82rem;
    color: var(--gray-400);
    margin: 0 0 1.4rem;
    display: flex;
    align-items: center;
    gap: 0.4rem;
}
.fiche-divider {
    border: none;
    border-top: 1px solid var(--gray-200);
    margin: 1.4rem 0;
}
.fiche-desc-label {
    font-size: 0.73rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--gray-400);
    margin-bottom: 0.5rem;
}
.fiche-desc-text {
    font-size: 0.97rem;
    color: var(--gray-700);
    line-height: 1.7;
    white-space: pre-wrap;
}
.fiche-desc-empty {
    font-size: 0.92rem;
    color: var(--gray-400);
    font-style: italic;
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
<div class="fiche-card">

    <!-- Banner + Avatar -->
    <div class="fiche-banner">
        <div class="fiche-avatar-wrap">
            <div class="fiche-avatar">
                <% if (!photoSrc.isEmpty()) { %>
                <img src="<%= photoSrc %>" alt="<%= libelle %>"
                     onerror="this.style.display='none';this.parentNode.innerText='<%= initial %>';">
                <% } else { %>
                <%= initial %>
                <% } %>
            </div>
        </div>
        <!-- Action buttons overlaid on banner -->
        <div class="fiche-actions-top">
            <a href="<%= lien + "?but=apresTarif.jsp&id=" + id + "&acte=delete&bute=specialite/specialite-list.jsp&classe=" + classe + "&nomtable=" + nomTable %>"
               class="btn-danger-outline"
               onclick="return confirm('Confirmer la suppression de cette spécialité ?');">
                <i class="fa fa-trash"></i> Supprimer
            </a>
            <a href="<%= lien + "?but=specialite/specialite-modif.jsp&idspecialite=" + id %>"
               class="btn-edit-outline">
                <i class="fa fa-pencil"></i> Modifier
            </a>
        </div>
    </div>

    <!-- Contenu -->
    <div class="fiche-body">
        <h2 class="fiche-title"><%= libelle.isEmpty() ? "—" : libelle %></h2>
        <div class="fiche-subtitle">
            <i class="fa fa-hashtag"></i>
            <span>Spécialité &bull; ID <%= id %></span>
        </div>

        <hr class="fiche-divider">

        <div class="fiche-desc-label"><i class="fa fa-align-left" style="margin-right:5px;"></i>Description</div>
        <% if (description.isEmpty()) { %>
        <p class="fiche-desc-empty">Aucune description renseignée.</p>
        <% } else { %>
        <p class="fiche-desc-text"><%= description %></p>
        <% } %>
    </div>
</div>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>