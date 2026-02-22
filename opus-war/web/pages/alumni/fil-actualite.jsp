<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="bean.ClassMAPTable" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Media" %>
<%@ page import="alumni.Publicationreaction" %>
<%@ page import="alumni.Publicationcommentaire" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="utilisateurAcade.UtilisateurAcade" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    UserEJB uFil = (UserEJB) session.getAttribute("u");
    MapUtilisateur mapFil = uFil.getUser();
    int refuserConnecte = mapFil.getRefuser();
    String nomConnecte = mapFil.getNomuser() != null ? mapFil.getNomuser() : "";
    String ctx = request.getContextPath();

    // Messages flash
    String msgSucces = (String) session.getAttribute("pubSucces");
    if (msgSucces != null) session.removeAttribute("pubSucces");
    String msgErreur = (String) session.getAttribute("pubErreur");
    if (msgErreur != null) session.removeAttribute("pubErreur");
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>Fil d'actualit&eacute;</h1>
    </section>
    <section class="content">

        <% if (msgSucces != null) { %>
            <div style="background:#dff0d8;padding:10px;margin-bottom:10px;border:1px solid #d6e9c6;"><%= msgSucces %></div>
        <% } %>
        <% if (msgErreur != null) { %>
            <div style="background:#f2dede;padding:10px;margin-bottom:10px;border:1px solid #ebccd1;"><%= msgErreur %></div>
        <% } %>

        <!-- ==================== FORMULAIRE NOUVELLE PUBLICATION ==================== -->
        <div style="border:1px solid #ccc;padding:15px;margin-bottom:20px;background:#fafafa;">
            <h3>Nouvelle publication</h3>
            <form method="POST" action="<%= ctx %>/pages/alumni/ajax/creer-publication.jsp">
                <div>
                    <textarea name="description" rows="3" style="width:100%;padding:8px;"
                              placeholder="Quoi de neuf, <%= nomConnecte %> ?"></textarea>
                </div>
                <div style="margin-top:8px;">
                    <input type="text" name="imageUrl" style="width:100%;padding:6px;"
                           placeholder="URL de l'image (optionnel, ex: https://exemple.com/photo.jpg)">
                </div>
                <div style="margin-top:8px;">
                    <button type="submit" style="padding:8px 20px;">Publier</button>
                </div>
            </form>
        </div>

        <!-- ==================== LISTE DES PUBLICATIONS (100% APJ) ==================== -->
        <%
            Connection conn = null;
            try {
                conn = new UtilDB().GetConn();

                // --- APJ: Charger types de reactions ---
                Reactiontype[] reactTypes = (Reactiontype[]) CGenUtil.rechercher(
                    new Reactiontype(), null, null, conn, " order by idreactiontype");
                if (reactTypes == null) reactTypes = new Reactiontype[0];

                // --- APJ: Charger tous les utilisateurs pour lookup nom ---
                UtilisateurAcade[] allUsers = (UtilisateurAcade[]) CGenUtil.rechercher(
                    new UtilisateurAcade(), null, null, conn, "");
                Map userNames = new HashMap();
                if (allUsers != null) {
                    for (int i = 0; i < allUsers.length; i++) {
                        userNames.put(allUsers[i].getRefuser(), allUsers[i].getNomuser());
                    }
                }

                // --- APJ: Charger les publications actives ---
                Publication[] pubs = (Publication[]) CGenUtil.rechercher(
                    new Publication(), null, null, conn, " and etat = 1 order by daty desc, heure desc");
                if (pubs == null) pubs = new Publication[0];

                if (pubs.length == 0) {
        %>
            <div style="text-align:center;padding:40px;color:#999;">
                <p>Aucune publication pour le moment. Soyez le premier &agrave; publier !</p>
            </div>
        <%
                }

                for (int p = 0; p < pubs.length; p++) {
                    Publication pub = pubs[p];
                    String idpub = pub.getIdpublication();
                    String auteur = (String) userNames.get(pub.getIdutilisateur());
                    if (auteur == null) auteur = "Utilisateur";

                    // --- APJ: Medias de cette publication ---
                    Media[] medias = (Media[]) CGenUtil.rechercher(
                        new Media(), null, null, conn,
                        " and idpublication = '" + idpub + "'");
                    if (medias == null) medias = new Media[0];

                    // --- APJ: Reactions sur cette publication ---
                    Publicationreaction[] reactions = (Publicationreaction[]) CGenUtil.rechercher(
                        new Publicationreaction(), null, null, conn,
                        " and idpublication = '" + idpub + "'");
                    if (reactions == null) reactions = new Publicationreaction[0];

                    // Compter par type + trouver ma reaction
                    Map reactCounts = new HashMap();
                    int totalReactions = 0;
                    String myReaction = "";
                    for (int r = 0; r < reactions.length; r++) {
                        String type = reactions[r].getIdreactiontype();
                        Integer cnt = (Integer) reactCounts.get(type);
                        reactCounts.put(type, cnt == null ? new Integer(1) : new Integer(cnt.intValue() + 1));
                        totalReactions++;
                        if (reactions[r].getIdutilisateur().equals(String.valueOf(refuserConnecte))) {
                            myReaction = type;
                        }
                    }

                    // --- APJ: Commentaires de cette publication ---
                    Publicationcommentaire[] comments = (Publicationcommentaire[]) CGenUtil.rechercher(
                        new Publicationcommentaire(), null, null, conn,
                        " and idpublication = '" + idpub + "' and etat = 1");
                    if (comments == null) comments = new Publicationcommentaire[0];
                    int nbComm = comments.length;

                    // Echapper description
                    String desc = pub.getDescritpion();
                    String descSafe = "";
                    if (desc != null) {
                        descSafe = desc.replace("&", "&amp;").replace("<", "&lt;")
                                       .replace(">", "&gt;").replace("\n", "<br>");
                    }
        %>
        <!-- ====== PUBLICATION ====== -->
        <div id="pub-<%= idpub %>" style="border:1px solid #ddd;padding:15px;margin-bottom:15px;background:#fff;">
            <!-- En-tete -->
            <div style="margin-bottom:10px;">
                <strong><%= auteur %></strong>
                &nbsp;&mdash;&nbsp;
                <small><%= pub.getDaty() %> &agrave; <%= pub.getHeure() != null ? pub.getHeure() : "" %></small>
            </div>

            <!-- Contenu -->
            <div style="margin-bottom:10px;">
                <p><%= descSafe %></p>
                <% for (int m = 0; m < medias.length; m++) { %>
                    <div style="margin-top:8px;">
                        <img src="<%= medias[m].getMediaurl() %>" style="max-width:100%;max-height:400px;border:1px solid #eee;" alt="media">
                    </div>
                <% } %>
            </div>

            <!-- Resume reactions -->
            <div style="color:#666;font-size:12px;margin-bottom:5px;">
                <% if (totalReactions > 0) { %>
                    <%= totalReactions %> r&eacute;action(s)
                <% } %>
            </div>

            <hr style="margin:5px 0;">

            <!-- Boutons reactions -->
            <div id="reactions-<%= idpub %>" style="margin-bottom:8px;">
                <% for (int rt = 0; rt < reactTypes.length; rt++) {
                    String rtId = reactTypes[rt].getIdreactiontype();
                    String rtLib = reactTypes[rt].getLibelle();
                    Integer cntObj = (Integer) reactCounts.get(rtId);
                    int count = cntObj != null ? cntObj.intValue() : 0;
                    boolean isMyReaction = rtId.equals(myReaction);
                    String btnStyle = isMyReaction
                        ? "font-weight:bold;background:#d0e8ff;border:1px solid #80b3e0;padding:3px 8px;margin-right:3px;cursor:pointer;"
                        : "padding:3px 8px;margin-right:3px;cursor:pointer;border:1px solid #ccc;background:#f5f5f5;";
                %>
                <button onclick="toggleReaction('<%= idpub %>', '<%= rtId %>')"
                        style="<%= btnStyle %>">
                    <%= rtLib %><% if (count > 0) { %> (<%= count %>)<% } %>
                </button>
                <% } %>
            </div>

            <!-- Lien commentaires -->
            <div>
                <a href="javascript:void(0)" onclick="toggleCommentaires('<%= idpub %>')" style="text-decoration:none;color:#333;">
                    &#128172; <span id="nb-comm-<%= idpub %>"><%= nbComm %></span> commentaire(s)
                </a>
            </div>

            <!-- Zone commentaires (cachee) -->
            <div id="commentaires-<%= idpub %>" style="display:none;margin-top:10px;padding-left:15px;border-left:2px solid #eee;">
                <div id="liste-comm-<%= idpub %>"><em>Chargement...</em></div>
                <div style="margin-top:8px;padding-top:8px;border-top:1px solid #eee;">
                    <input type="text" id="comm-text-<%= idpub %>" placeholder="Ecrire un commentaire..." style="width:75%;padding:5px;">
                    <button onclick="ajouterCommentaire('<%= idpub %>')" style="padding:5px 12px;">Envoyer</button>
                </div>
            </div>
        </div>
        <%
                } // fin for publications
            } catch (Exception e) {
                e.printStackTrace();
        %>
            <div style="background:#f2dede;padding:10px;border:1px solid #ebccd1;">
                Erreur lors du chargement: <%= e.getMessage() %>
            </div>
        <%
            } finally {
                if (conn != null) try { conn.close(); } catch (Exception ex) {}
            }
        %>
    </section>
</div>

<!-- ==================== JAVASCRIPT ==================== -->
<script>
var CTX = '<%= ctx %>';

// ========== REACTIONS PUBLICATION ==========
function toggleReaction(idpub, idreactiontype) {
    fetch(CTX + '/pages/alumni/ajax/reagir-publication.jsp?idpublication=' + idpub + '&idreactiontype=' + idreactiontype)
    .then(function(r) { return r.text(); })
    .then(function(text) {
        try { var data = JSON.parse(text); } catch(e) { alert('Erreur serveur'); return; }
        if (data.success) {
            location.reload();
        } else {
            alert(data.error || 'Erreur');
        }
    })
    .catch(function(e) { alert('Erreur: ' + e); });
}

// ========== COMMENTAIRES ==========
function toggleCommentaires(idpub) {
    var div = document.getElementById('commentaires-' + idpub);
    if (div.style.display === 'none') {
        div.style.display = 'block';
        chargerCommentaires(idpub);
    } else {
        div.style.display = 'none';
    }
}

function chargerCommentaires(idpub) {
    var listeDiv = document.getElementById('liste-comm-' + idpub);
    listeDiv.innerHTML = '<em>Chargement...</em>';

    fetch(CTX + '/pages/alumni/ajax/charger-commentaires.jsp?idpublication=' + idpub)
    .then(function(r) { return r.text(); })
    .then(function(text) {
        try { var data = JSON.parse(text); } catch(e) { listeDiv.innerHTML = '<span style="color:red;">Erreur serveur</span>'; return; }
        if (!data.success) {
            listeDiv.innerHTML = '<span style="color:red;">' + (data.error || 'Erreur') + '</span>';
            return;
        }
        var html = '';
        var comms = data.commentaires;
        var rTypes = data.reactionTypes;

        if (comms.length === 0) {
            html = '<p style="color:#999;"><em>Aucun commentaire</em></p>';
        }

        for (var i = 0; i < comms.length; i++) {
            var c = comms[i];
            var isReply = c.idparent && c.idparent !== '';
            var indent = isReply ? 'margin-left:25px;' : '';

            html += '<div style="padding:8px 0;border-bottom:1px solid #f0f0f0;' + indent + '">';
            if (isReply) html += '<small style="color:#999;">&#8627; r&eacute;ponse</small> ';
            html += '<strong>' + escHtml(c.auteur) + '</strong>: ' + escHtml(c.description);

            // Reactions du commentaire
            html += ' <span style="font-size:11px;">';
            for (var j = 0; j < rTypes.length; j++) {
                var rt = rTypes[j];
                var cnt = c.reactions[rt.id] || 0;
                var bold = (c.myReaction === rt.id) ? 'font-weight:bold;background:#d0e8ff;' : '';
                html += ' <button style="font-size:10px;padding:1px 5px;cursor:pointer;' + bold + '" ';
                html += 'onclick="toggleReactionComm(\'' + c.id + '\',\'' + rt.id + '\',\'' + idpub + '\')">';
                html += rt.libelle;
                if (cnt > 0) html += '(' + cnt + ')';
                html += '</button>';
            }
            html += '</span>';

            // Bouton repondre (top-level uniquement)
            if (!isReply) {
                html += ' <a href="javascript:void(0)" onclick="montrerReponse(\'' + c.id + '\')" style="font-size:11px;color:#337ab7;">R&eacute;pondre</a>';
                html += '<div id="reponse-form-' + c.id + '" style="display:none;margin-top:5px;margin-left:15px;">';
                html += '<input type="text" id="reponse-text-' + c.id + '" placeholder="Votre r&eacute;ponse..." style="width:60%;padding:4px;">';
                html += ' <button onclick="ajouterReponse(\'' + idpub + '\',\'' + c.id + '\')" style="padding:4px 10px;">Envoyer</button>';
                html += '</div>';
            }

            html += '</div>';
        }
        listeDiv.innerHTML = html;
    })
    .catch(function(e) { listeDiv.innerHTML = '<span style="color:red;">Erreur: ' + e + '</span>'; });
}

function ajouterCommentaire(idpub) {
    var input = document.getElementById('comm-text-' + idpub);
    var text = input.value.trim();
    if (!text) return;

    fetch(CTX + '/pages/alumni/ajax/commenter.jsp', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'idpublication=' + encodeURIComponent(idpub) + '&description=' + encodeURIComponent(text)
    })
    .then(function(r) { return r.text(); })
    .then(function(text) {
        try { var data = JSON.parse(text); } catch(e) { alert('Erreur serveur'); return; }
        if (data.success) {
            input.value = '';
            chargerCommentaires(idpub);
            var nbSpan = document.getElementById('nb-comm-' + idpub);
            nbSpan.textContent = parseInt(nbSpan.textContent) + 1;
        } else {
            alert(data.error || 'Erreur');
        }
    })
    .catch(function(e) { alert('Erreur: ' + e); });
}

function montrerReponse(idcomm) {
    var div = document.getElementById('reponse-form-' + idcomm);
    div.style.display = (div.style.display === 'none') ? 'block' : 'none';
}

function ajouterReponse(idpub, idparent) {
    var input = document.getElementById('reponse-text-' + idparent);
    var text = input.value.trim();
    if (!text) return;

    fetch(CTX + '/pages/alumni/ajax/commenter.jsp', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'idpublication=' + encodeURIComponent(idpub)
            + '&description=' + encodeURIComponent(text)
            + '&idparent=' + encodeURIComponent(idparent)
    })
    .then(function(r) { return r.text(); })
    .then(function(text) {
        try { var data = JSON.parse(text); } catch(e) { alert('Erreur serveur'); return; }
        if (data.success) {
            input.value = '';
            chargerCommentaires(idpub);
            var nbSpan = document.getElementById('nb-comm-' + idpub);
            nbSpan.textContent = parseInt(nbSpan.textContent) + 1;
        } else {
            alert(data.error || 'Erreur');
        }
    })
    .catch(function(e) { alert('Erreur: ' + e); });
}

// ========== REACTIONS COMMENTAIRE ==========
function toggleReactionComm(idcomm, idreactiontype, idpub) {
    fetch(CTX + '/pages/alumni/ajax/reagir-commentaire.jsp?idcommentaire=' + idcomm + '&idreactiontype=' + idreactiontype)
    .then(function(r) { return r.text(); })
    .then(function(text) {
        try { var data = JSON.parse(text); } catch(e) { alert('Erreur serveur'); return; }
        if (data.success) {
            chargerCommentaires(idpub);
        } else {
            alert(data.error || 'Erreur');
        }
    })
    .catch(function(e) { alert('Erreur: ' + e); });
}

function escHtml(str) {
    if (!str) return '';
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
</script>
