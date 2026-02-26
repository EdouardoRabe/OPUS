<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page import="affichage.PageRecherche"%>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="constanteAcade.ConstantEtatUser" %>

<% try {
    user.UserEJB uEjb = (user.UserEJB) session.getValue("u");
    MapUtilisateur currentUser = uEjb.getUser();

    // --- Action POST : activer / desactiver / supprimer (avant PageRecherche) ---
    String actionMsg = null;
    String actionErr = null;
    String action = request.getParameter("action");
    String targetRef = request.getParameter("refuser");
    if (action != null && targetRef != null && !targetRef.isEmpty()) {
        try {
            if ("valider".equals(action)) {
                uEjb.activeUtilisateur(targetRef);
                actionMsg = "Utilisateur valid\u00e9 et activ\u00e9 avec succ\u00e8s.";
            } else if ("activer".equals(action)) {
                uEjb.activeUtilisateur(targetRef);
                actionMsg = "Utilisateur activ\u00e9 avec succ\u00e8s.";
            } else if ("desactiver".equals(action)) {
                String descDesac = request.getParameter("description");
                uEjb.desactiveUtilisateur(targetRef, descDesac);
                actionMsg = "Utilisateur d\u00e9sactiv\u00e9 avec succ\u00e8s.";
            }
        } catch (Exception ex) {
            actionErr = ex.getMessage();
        }
    }

    ProfilLib t = new ProfilLib();
    String listeCrt[] = {"nom", "loginuser", "email", "promotionlib", "parcourslib", "idrole"};
    String listeInt[] = {};
    String libEntete[] = {"idprofil", "nom", "prenom", "email", "telephone", "loginuser", "idrole", "promotionlib", "parcourslib", "photoprofil", "estactif", "refuser"};
    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Gestion des utilisateurs");
    pr.setUtilisateur(uEjb);
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("mod/gestion-utilisateurs.jsp");
    pr.getFormu().getChamp("nom").setVisible(false);
    pr.getFormu().getChamp("loginuser").setLibelle("ETU / Login");
    pr.getFormu().getChamp("email").setLibelle("Email");
    pr.getFormu().getChamp("promotionlib").setLibelle("Promotion");
    pr.getFormu().getChamp("parcourslib").setLibelle("Parcours");
    pr.getFormu().getChamp("idrole").setLibelle("R&ocirc;le");
    String[] colSomme = {};
    pr.creerObjetPage(libEntete, colSomme);

    String lienBase = (String) session.getValue("lien");

    /* Avatar gradient palette */
    String[] avatarGradients = {
            "background:linear-gradient(135deg,#008BFF,#0056b3)",
            "background:linear-gradient(135deg,#5B23FF,#4a1cd9)",
            "background:linear-gradient(135deg,#ef4444,#dc2626)",
            "background:linear-gradient(135deg,#10b981,#059669)",
            "background:linear-gradient(135deg,#f59e0b,#d97706)",
            "background:linear-gradient(135deg,#8b5cf6,#7c3aed)",
            "background:linear-gradient(135deg,#06b6d4,#0891b2)",
            "background:linear-gradient(135deg,#E4FF30,#d4ef1f)"
    };
    String[] avatarTextColors = {"color:#fff","color:#fff","color:#fff","color:#fff","color:#fff","color:#fff","color:#fff","color:#362F4F"};

    /* Stats - calculées sur TOUS les utilisateurs */
    ProfilLib[] allUsersTotal = (ProfilLib[]) pr.getListe();
    int totalActifs = 0, totalInactifs = 0, totalCrees = 0, totalBannis = 0;
    for (int i = 0; i < allUsersTotal.length; i++) {
        int etat = allUsersTotal[i].getEtatdetail();
        if (etat == ConstantEtatUser.etatUtilisateurActiver || etat == ConstantEtatUser.etatUtilisateurValider) totalActifs++;
        else if (etat == ConstantEtatUser.etatUtilisateurCreer) totalCrees++;
        else totalBannis++;
    }
    int totalUsers = allUsersTotal.length;

    /* Pagination manuelle */
    int npp = 12; // nombre par page
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try { currentPage = Integer.parseInt(pageParam); } catch (Exception e) { currentPage = 1; }
    }
    if (currentPage < 1) currentPage = 1;
    int totalPages = (int) Math.ceil((double) totalUsers / npp);
    if (totalPages < 1) totalPages = 1;
    if (currentPage > totalPages) currentPage = totalPages;

    int startIdx = (currentPage - 1) * npp;
    int endIdx = Math.min(startIdx + npp, totalUsers);
    java.util.List pageList = new java.util.ArrayList();
    for (int pi = startIdx; pi < endIdx; pi++) {
        pageList.add(allUsersTotal[pi]);
    }
    ProfilLib[] allUsers = (ProfilLib[]) pageList.toArray(new ProfilLib[0]);
%>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <i class="fa fa-users" style="color:var(--itu-blue);font-size:1.1rem;margin-right:10px;"></i>
        Gestion des utilisateurs
    </h1>
    <div style="display:flex;align-items:center;gap:1rem;">
        <span style="font-size:0.85rem;color:var(--gray-500);">
            <strong style="color:var(--itu-dark);"><%= totalUsers %></strong> utilisateur(s)
        </span>
    </div>
</div>

<!-- ═══ MESSAGES FLASH ═══ -->
<% if (actionMsg != null) { %>
<div class="alert alert-success" style="margin-bottom:15px;border-radius:8px;">
    <i class="fa fa-check-circle" style="margin-right:6px;"></i><%= actionMsg %>
</div>
<% } %>
<% if (actionErr != null) { %>
<div class="alert alert-danger" style="margin-bottom:15px;border-radius:8px;">
    <i class="fa fa-exclamation-triangle" style="margin-right:6px;"></i><%= actionErr %>
</div>
<% } %>

<!-- ═══ STATS CARDS ═══ -->
<div style="display:flex;gap:15px;margin-bottom:20px;">
    <div class="custom-card no-hover" style="flex:1;text-align:center;padding:15px 20px;">
        <div style="font-size:1.8em;font-weight:700;color:#27ae60;"><%= totalActifs %></div>
        <div style="font-size:0.85em;color:#888;">Actifs / Valid&eacute;s</div>
    </div>
    <div class="custom-card no-hover" style="flex:1;text-align:center;padding:15px 20px;">
        <div style="font-size:1.8em;font-weight:700;color:#f59e0b;"><%= totalCrees %></div>
        <div style="font-size:0.85em;color:#888;">En attente</div>
    </div>
    <div class="custom-card no-hover" style="flex:1;text-align:center;padding:15px 20px;">
        <div style="font-size:1.8em;font-weight:700;color:#e74c3c;"><%= totalBannis %></div>
        <div style="font-size:0.85em;color:#888;">Bannis</div>
    </div>
    <div class="custom-card no-hover" style="flex:1;text-align:center;padding:15px 20px;">
        <div style="font-size:1.8em;font-weight:700;color:#2c3e50;"><%= totalUsers %></div>
        <div style="font-size:0.85em;color:#888;">Total</div>
    </div>
</div>

<!-- ═══ SEARCH & FILTER (APJ Standard) ═══ -->
<div class="custom-card no-hover" style="margin-bottom:20px;padding:1.25rem 1.5rem;">
    <form action="<%= pr.getLien() %>?but=<%= pr.getApres() %>" method="post" name="recherche" id="recherche">
        <%= pr.getFormu().getHtmlEnsemble() %>
    </form>
</div>

<!-- ═══ STYLES MENU KEBAB ═══ -->
<style>
    .usr-card-menu {
        position: absolute;
        top: 10px;
        right: 12px;
        z-index: 10;
    }

    /* ── Bouton trois points ── */
    .usr-menu-btn {
        background: rgba(255,255,255,0.85);
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        width: 34px;
        height: 34px;
        cursor: pointer;
        font-size: 1.25rem;
        line-height: 1;
        color: #64748b;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background .18s, border-color .18s, color .18s, box-shadow .18s;
        padding: 0;
        backdrop-filter: blur(4px);
    }
    .usr-menu-btn:hover,
    .usr-menu-btn.active {
        background: #eff6ff;
        border-color: #3b82f6;
        color: #2563eb;
        box-shadow: 0 0 0 3px rgba(59,130,246,.15);
    }

    /* ── Dropdown container ── */
    .usr-menu-dropdown {
        display: none;
        position: absolute;
        top: calc(100% + 6px);
        right: 0;
        min-width: 200px;
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        box-shadow: 0 10px 28px rgba(15,23,42,.14), 0 2px 8px rgba(15,23,42,.08);
        overflow: hidden;
        z-index: 100;
        transform-origin: top right;
        animation: usrMenuIn .15s ease forwards;
    }
    @keyframes usrMenuIn {
        from { opacity: 0; transform: scale(.95) translateY(-4px); }
        to   { opacity: 1; transform: scale(1)  translateY(0); }
    }
    .usr-menu-dropdown.open {
        display: block;
    }

    /* ── En-tête léger du dropdown ── */
    .usr-menu-header {
        padding: 10px 14px 8px;
        font-size: .72rem;
        font-weight: 700;
        letter-spacing: .06em;
        text-transform: uppercase;
        color: #94a3b8;
        border-bottom: 1px solid #f1f5f9;
    }

    /* ── Séparateur ── */
    .usr-menu-sep {
        height: 1px;
        background: #f1f5f9;
        margin: 4px 0;
    }

    /* ── Items du dropdown ── */
    .usr-menu-dropdown a,
    .usr-menu-dropdown button.usr-action-link {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 16px;
        font-size: .84rem;
        font-weight: 500;
        color: #334155;
        text-decoration: none;
        transition: background .13s, color .13s;
        border: none;
        background: transparent;
        width: 100%;
        cursor: pointer;
        text-align: left;
        font-family: inherit;
        line-height: 1.3;
    }
    .usr-menu-dropdown a .fa,
    .usr-menu-dropdown button.usr-action-link .fa {
        width: 16px;
        text-align: center;
        font-size: .88rem;
        opacity: .75;
        flex-shrink: 0;
    }

    /* Hover général */
    .usr-menu-dropdown a:hover,
    .usr-menu-dropdown button.usr-action-link:hover {
        background: #eff6ff;
        color: #2563eb;
    }
    .usr-menu-dropdown a:hover .fa,
    .usr-menu-dropdown button.usr-action-link:hover .fa {
        opacity: 1;
    }

    /* Variante success (valider / activer) */
    .usr-menu-dropdown button.usr-action-success:hover {
        background: #f0fdf4;
        color: #16a34a;
    }
    .usr-menu-dropdown button.usr-action-success:hover .fa {
        color: #16a34a;
    }

    /* Variante danger (bannir) */
    .usr-menu-dropdown button.usr-action-danger:hover {
        background: #fff1f2;
        color: #dc2626;
    }
    .usr-menu-dropdown button.usr-action-danger:hover .fa {
        color: #dc2626;
    }
    .mots-cless{
        display: none !important;
    }
    .usr-badge { display:inline-block; padding:2px 10px; border-radius:12px; font-size:0.75em; font-weight:600; }
    .usr-badge-actif { background:#d4edda; color:#155724; }
    .usr-badge-valide { background:#d1ecf1; color:#0c5460; }
    .usr-badge-cree { background:#fff3cd; color:#856404; }
    .usr-badge-banni { background:#f8d7da; color:#721c24; }
    .usr-badge-role { background:#d1ecf1; color:#0c5460; }

    /* publication menu */
    .pub-menu-btn { background:transparent;border:none;font-size:1.2rem;cursor:pointer;color:#6b7280;}
    .pub-menu-btn:hover { color:var(--itu-blue,#008BFF); }
    .pub-menu-dropdown .pub-menu-item { display:flex; align-items:center; gap:6px; }
    .pub-menu-dropdown .pub-menu-item i { width:14px; }
</style>

<!-- ═══ USERS GRID ═══ -->
<div class="specialities-grid">
    <%
        for (int i = 0; i < allUsers.length; i++) {
            ProfilLib p = allUsers[i];
            int idx = i % 8;
            String nomP = p.getNom() != null ? p.getNom() : "";
            String prenomP = p.getPrenom() != null ? p.getPrenom() : "";
            String initials = "";
            if (prenomP.length() > 0) initials += Character.toUpperCase(prenomP.charAt(0));
            if (nomP.length() > 0) initials += Character.toUpperCase(nomP.charAt(0));
            if (initials.isEmpty()) initials = "?";
            int etatDetail = p.getEtatdetail();
            String loginP = p.getLoginuser() != null ? p.getLoginuser() : "";
            String emailP = p.getEmail() != null ? p.getEmail() : "";
            String telP = p.getTelephone() != null ? p.getTelephone() : "";
            String promoP = p.getPromotionLib() != null ? p.getPromotionLib() : "";
            String parcP = p.getParcoursLib() != null ? p.getParcoursLib() : "";
            String roleP = p.getIdrole() != null ? p.getIdrole() : "";
            int ref = p.getRefuser();
            boolean isSelf = (ref == currentUser.getRefuser());
            String photoProfil = p.getPhotoProfil();
            boolean hasPhoto = (photoProfil != null && !photoProfil.trim().isEmpty());
    %>
    <div class="speciality-card" style="position:relative;">

        <!-- Menu 3 points -->
        <div class="usr-card-menu">
            <button class="usr-menu-btn" onclick="toggleUsrMenu(this, event)" title="Options">&#8942;</button>
            <div class="usr-menu-dropdown" id="usr-dd-<%= i %>">
                <div class="usr-menu-header">Actions</div>

                <a href="<%= lienBase %>?but=annuaire/fiche-utilisateur.jsp&amp;idprofil=<%= p.getIdprofil() %>">
                    <i class="fa fa-eye"></i> Voir le profil
                </a>

                <% if (!isSelf) { %>
                <div class="usr-menu-sep"></div>
                <% if (etatDetail == ConstantEtatUser.etatUtilisateurCreer) { %>
                <!-- Utilisateur créé → Valider -->
                <form method="post" style="margin:0;" onsubmit="return confirm('Valider cet utilisateur ?');">
                    <input type="hidden" name="action" value="valider"/>
                    <input type="hidden" name="refuser" value="<%= ref %>"/>
                    <button type="submit" class="usr-action-link usr-action-success">
                        <i class="fa fa-check-circle" style="color:#16a34a;"></i> Valider
                    </button>
                </form>
                <% } else if (etatDetail == ConstantEtatUser.etatUtilisateurBanis) { %>
                <!-- Utilisateur banni → Activer -->
                <form method="post" style="margin:0;" onsubmit="return confirm('R\u00e9activer cet utilisateur ?');">
                    <input type="hidden" name="action" value="activer"/>
                    <input type="hidden" name="refuser" value="<%= ref %>"/>
                    <button type="submit" class="usr-action-link usr-action-success">
                        <i class="fa fa-play-circle" style="color:#16a34a;"></i> R&eacute;activer
                    </button>
                </form>
                <% } else { %>
                <!-- Utilisateur validé ou actif → Bannir -->
                <form method="post" style="margin:0;" onsubmit="return promptDesactivation(this);">
                    <input type="hidden" name="action" value="desactiver"/>
                    <input type="hidden" name="refuser" value="<%= ref %>"/>
                    <input type="hidden" name="description" value=""/>
                    <button type="submit" class="usr-action-link usr-action-danger">
                        <i class="fa fa-ban" style="color:#dc2626;"></i> Bannir
                    </button>
                </form>
                <% } %>
                <% } %>
            </div>
        </div>

        <!-- Avatar / Photo -->
        <div class="speciality-icon" style="<%= hasPhoto ? "background:var(--gray-100);" : avatarGradients[idx] %>">
            <% if (hasPhoto) { %>
            <img src="<%= request.getContextPath() %>/<%= photoProfil %>" alt="Photo"
                 style="width:100%;height:100%;object-fit:cover;border-radius:50%;"/>
            <% } else { %>
            <span style="font-size:1.4rem;font-weight:700;<%= avatarTextColors[idx] %>"><%= initials %></span>
            <% } %>
        </div>

        <!-- Nom complet -->
        <h3 class="speciality-title"><%= prenomP %> <%= nomP %></h3>

        <!-- Email / Login -->
        <p class="speciality-desc" style="font-size:0.82em;">
            <i class="fa fa-envelope" style="margin-right:4px;opacity:.5;"></i><%= emailP.isEmpty() ? "&mdash;" : emailP %>
            <br/>
            <i class="fa fa-user" style="margin-right:4px;opacity:.5;"></i><%= loginP.isEmpty() ? "&mdash;" : loginP %>
        </p>

        <!-- Meta badges -->
        <div class="speciality-meta">
            <span class="usr-badge usr-badge-role"><%= roleP %></span>
            <%= ConstantEtatUser.etatToChaine(etatDetail) %>
        </div>

        <!-- Info promo / parcours -->
        <div style="font-size:0.8em;color:var(--gray-500,#6b7280);margin-top:6px;text-align:center;">
            <% if (!promoP.isEmpty()) { %><span><i class="fa fa-graduation-cap" style="margin-right:3px;"></i><%= promoP %></span><% } %>
            <% if (!parcP.isEmpty()) { %><span style="margin-left:8px;"><i class="fa fa-bookmark" style="margin-right:3px;"></i><%= parcP %></span><% } %>
        </div>

        <!-- Bouton Voir profil -->
        <a class="btn btn-outline-primary btn-speciality"
           href="<%= lienBase %>?but=annuaire/fiche-utilisateur.jsp&amp;idprofil=<%= p.getIdprofil() %>">
            <i class="fa fa-eye" style="margin-right:5px;"></i>Voir profil
        </a>

        <% if (isSelf) { %>
        <div style="position:absolute;top:10px;left:12px;">
            <span class="usr-badge" style="background:#e0e7ff;color:#3730a3;font-size:0.7em;">Vous</span>
        </div>
        <% } %>

    </div>
    <% } %>

    <% if (allUsers.length == 0) { %>
    <div style="grid-column:1/-1;text-align:center;padding:3rem 1rem;color:var(--gray-500);">
        <i class="fa fa-users" style="font-size:2.5rem;margin-bottom:1rem;display:block;opacity:.35;"></i>
        Aucun utilisateur trouv&eacute;.
    </div>
    <% } %>
</div>

<!-- ═══ PAGINATION ═══ -->
<div style="display:flex;justify-content:center;align-items:center;gap:8px;margin-top:20px;flex-wrap:wrap;">
    <% if (currentPage > 1) { %>
    <a href="<%= lienBase %>?but=mod/gestion-utilisateurs.jsp&page=1" class="btn btn-outline-secondary btn-sm" title="Premi&egrave;re page">&laquo;</a>
    <a href="<%= lienBase %>?but=mod/gestion-utilisateurs.jsp&page=<%= currentPage - 1 %>" class="btn btn-outline-secondary btn-sm">&lsaquo; Pr&eacute;c</a>
    <% } else { %>
    <span class="btn btn-outline-secondary btn-sm disabled">&laquo;</span>
    <span class="btn btn-outline-secondary btn-sm disabled">&lsaquo; Pr&eacute;c</span>
    <% } %>

    <span style="padding:0 12px;font-size:0.9em;">
        Page <strong><%= currentPage %></strong> / <strong><%= totalPages %></strong>
        &nbsp;(<%= totalUsers %> utilisateurs)
    </span>

    <% if (currentPage < totalPages) { %>
    <a href="<%= lienBase %>?but=mod/gestion-utilisateurs.jsp&page=<%= currentPage + 1 %>" class="btn btn-outline-secondary btn-sm">Suiv &rsaquo;</a>
    <a href="<%= lienBase %>?but=mod/gestion-utilisateurs.jsp&page=<%= totalPages %>" class="btn btn-outline-secondary btn-sm" title="Derni&egrave;re page">&raquo;</a>
    <% } else { %>
    <span class="btn btn-outline-secondary btn-sm disabled">Suiv &rsaquo;</span>
    <span class="btn btn-outline-secondary btn-sm disabled">&raquo;</span>
    <% } %>
</div>

<script>
    function promptDesactivation(form) {
        var desc = prompt('Raison de la d\u00e9sactivation (optionnel) :');
        if (desc === null) return false;
        form.querySelector('input[name="description"]').value = desc;
        return true;
    }
    function toggleUsrMenu(btn, e) {
        e.stopPropagation();
        var dd = btn.nextElementSibling;
        var isOpen = dd.classList.contains('open');
        // Fermer tous les menus ouverts et désactiver tous les boutons
        document.querySelectorAll('.usr-menu-dropdown.open').forEach(function(el) {
            el.classList.remove('open');
        });
        document.querySelectorAll('.usr-menu-btn.active').forEach(function(el) {
            el.classList.remove('active');
        });
        if (!isOpen) {
            dd.classList.add('open');
            btn.classList.add('active');
        }
    }
    document.addEventListener('click', function() {
        document.querySelectorAll('.usr-menu-dropdown.open').forEach(function(el) {
            el.classList.remove('open');
        });
        document.querySelectorAll('.usr-menu-btn.active').forEach(function(el) {
            el.classList.remove('active');
        });
    });
</script>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>