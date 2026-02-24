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
            if ("activer".equals(action)) {
                uEjb.activeUtilisateur(targetRef);
                actionMsg = "Utilisateur activ\u00e9 avec succ\u00e8s.";
            } else if ("desactiver".equals(action)) {
                String descDesac = request.getParameter("description");
                uEjb.desactiveUtilisateur(targetRef, descDesac);
                actionMsg = "Utilisateur d\u00e9sactiv\u00e9 avec succ\u00e8s.";
            } else if ("supprimer".equals(action)) {
                uEjb.deleteUtilisateurs(targetRef);
                actionMsg = "Utilisateur supprim\u00e9 avec succ\u00e8s.";
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
    pr.getFormu().getChamp("nom").setLibelle("Nom");
    pr.getFormu().getChamp("loginuser").setLibelle("ETU / Login");
    pr.getFormu().getChamp("email").setLibelle("Email");
    pr.getFormu().getChamp("promotionlib").setLibelle("Promotion");
    pr.getFormu().getChamp("parcourslib").setLibelle("Parcours");
    pr.getFormu().getChamp("idrole").setLibelle("R&ocirc;le");
    pr.setNpp(50);
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

    /* Stats */
    ProfilLib[] allUsers = (ProfilLib[]) pr.getListe();
    int totalActifs = 0, totalInactifs = 0, totalCrees = 0, totalBannis = 0;
    for (int i = 0; i < allUsers.length; i++) {
        int etat = allUsers[i].getEtatdetail();
        if (etat == ConstantEtatUser.etatUtilisateurActiver || etat == ConstantEtatUser.etatUtilisateurValider) totalActifs++;
        else if (etat == ConstantEtatUser.etatUtilisateurCreer) totalCrees++;
        else totalBannis++;
    }
%>

<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <i class="fa fa-users" style="color:var(--itu-blue);font-size:1.1rem;margin-right:10px;"></i>
        Gestion des utilisateurs
    </h1>
    <div style="display:flex;align-items:center;gap:1rem;">
        <span style="font-size:0.85rem;color:var(--gray-500);">
            <strong style="color:var(--itu-dark);"><%= allUsers.length %></strong> utilisateur(s)
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
        <div style="font-size:1.8em;font-weight:700;color:#2c3e50;"><%= allUsers.length %></div>
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
.usr-menu-btn {
    background: transparent;
    border: 1px solid #dde3ec;
    border-radius: 6px;
    width: 32px;
    height: 32px;
    cursor: pointer;
    font-size: 1.2rem;
    line-height: 1;
    color: #6b7280;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background .15s, border-color .15s;
    padding: 0;
}
.usr-menu-btn:hover {
    background: #f0f4ff;
    border-color: var(--itu-blue, #008BFF);
    color: var(--itu-blue, #008BFF);
}
.usr-menu-dropdown {
    display: none;
    position: absolute;
    top: calc(100% + 4px);
    right: 0;
    min-width: 180px;
    background: #fff;
    border: 1px solid #dde3ec;
    border-radius: 8px;
    box-shadow: 0 6px 20px rgba(0,0,0,.12);
    overflow: hidden;
    z-index: 100;
}
.usr-menu-dropdown.open {
    display: block;
}
.usr-menu-dropdown a,
.usr-menu-dropdown button.usr-action-link {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 9px 14px;
    font-size: .85rem;
    color: #374151;
    text-decoration: none;
    transition: background .12s;
    border: none;
    background: transparent;
    width: 100%;
    cursor: pointer;
    text-align: left;
    font-family: inherit;
}
.usr-menu-dropdown a:hover,
.usr-menu-dropdown button.usr-action-link:hover {
    background: #f0f4ff;
    color: var(--itu-blue, #008BFF);
}
.usr-menu-dropdown button.usr-action-danger:hover {
    background: #fef2f2;
    color: #dc2626;
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
                <a href="<%= lienBase %>?but=annuaire/fiche-utilisateur.jsp&amp;refuser=<%= ref %>">
                    <i class="fa fa-eye"></i> Voir profil
                </a>
                <% if (!isSelf) { %>
                    <% if (etatDetail == ConstantEtatUser.etatUtilisateurCreer) { %>
                    <!-- Utilisateur créé → Valider -->
                    <form method="post" style="margin:0;" onsubmit="return confirm('Valider cet utilisateur ?');">
                        <input type="hidden" name="action" value="activer"/>
                        <input type="hidden" name="refuser" value="<%= ref %>"/>
                        <button type="submit" class="usr-action-link">
                            <i class="fa fa-check-circle"></i> Valider
                        </button>
                    </form>
                    <% } else if (etatDetail == ConstantEtatUser.etatUtilisateurBanis) { %>
                    <!-- Utilisateur banni → Activer -->
                    <form method="post" style="margin:0;" onsubmit="return confirm('R\u00e9activer cet utilisateur ?');">
                        <input type="hidden" name="action" value="activer"/>
                        <input type="hidden" name="refuser" value="<%= ref %>"/>
                        <button type="submit" class="usr-action-link">
                            <i class="fa fa-play-circle"></i> Activer
                        </button>
                    </form>
                    <% } else { %>
                    <!-- Utilisateur validé ou actif → Bannir -->
                    <form method="post" style="margin:0;" onsubmit="return promptDesactivation(this);">
                        <input type="hidden" name="action" value="desactiver"/>
                        <input type="hidden" name="refuser" value="<%= ref %>"/>
                        <input type="hidden" name="description" value=""/>
                        <button type="submit" class="usr-action-link">
                            <i class="fa fa-ban"></i> Bannir
                        </button>
                    </form>
                    <% } %>
                    <form method="post" style="margin:0;" onsubmit="return confirm('Supprimer d\u00e9finitivement cet utilisateur ?');">
                        <input type="hidden" name="action" value="supprimer"/>
                        <input type="hidden" name="refuser" value="<%= ref %>"/>
                        <button type="submit" class="usr-action-link usr-action-danger">
                            <i class="fa fa-trash"></i> Supprimer
                        </button>
                    </form>
                <% } %>
            </div>
        </div>

        <!-- Avatar / Photo -->
        <div class="speciality-icon" style="<%= hasPhoto ? "background:var(--gray-100);" : avatarGradients[idx] %>">
            <% if (hasPhoto) { %>
                <img src="<%= request.getContextPath() %>/uploads/<%= photoProfil %>" alt="Photo"
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
           href="<%= lienBase %>?but=annuaire/fiche-utilisateur.jsp&amp;refuser=<%= ref %>">
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
<div class="specialite-pagination-wrap">
    <%= pr.getBasPage() %>
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
    document.querySelectorAll('.usr-menu-dropdown.open').forEach(function(el) {
        el.classList.remove('open');
    });
    if (!isOpen) dd.classList.add('open');
}
document.addEventListener('click', function() {
    document.querySelectorAll('.usr-menu-dropdown.open').forEach(function(el) {
        el.classList.remove('open');
    });
});
</script>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>