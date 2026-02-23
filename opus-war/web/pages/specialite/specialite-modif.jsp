<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page import="alumni.Specialite" %>
<%
    String lien     = (String) session.getValue("lien");
    String id       = "";
    String apres    = "specialite/specialite-fiche.jsp";
    String photoPath = "";
    String mapping  = "alumni.Specialite";
    String nomtable = "specialite";
    String titre    = "Modification sp&eacute;cialit&eacute;";
    String htmlForm = "";
    try {
        Specialite t = new Specialite();

        PageUpdate pu = new PageUpdate(t, request, (user.UserEJB) session.getValue("u"));
        pu.setLien(lien);
        pu.setTitre(titre);

        pu.getFormu().getChamp("idspecialite").setLibelle("ID");
        pu.getFormu().getChamp("idspecialite").setAutre("readonly");
        pu.getFormu().getChamp("libelle").setLibelle("Libell&eacute;");

        // Description
        pu.getFormu().getChamp("description").setLibelle("Description");

        // Photo : libellé visible, le JS remplacera le textbox par un input file
        pu.getFormu().getChamp("photo").setLibelle("Photo");

        pu.preparerDataFormu();

        id        = pu.getBase().getTuppleID();
        photoPath = ((Specialite) pu.getBase()).getPhoto();
        if (photoPath == null) photoPath = "";
        pu.getFormu().makeHtmlInsertTabIndex();
        htmlForm  = pu.getFormu().getHtmlInsert();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!-- ═══ PAGE HEADER ═══ -->
<div class="page-header-top">
    <h1 class="page-title-lg">
        <a href="<%= lien %>?but=specialite/specialite-fiche.jsp&idspecialite=<%= id %>"
           style="color:var(--gray-400);margin-right:10px;font-size:1rem;vertical-align:middle;"
           title="Retour à la fiche">
            <i class="fa fa-arrow-left"></i>
        </a>
        <i class="fa fa-pencil" style="color:var(--itu-blue);font-size:1.1rem;margin-right:8px;"></i>
        Modifier la sp&eacute;cialit&eacute;
    </h1>
    <span style="font-size:0.85rem;color:var(--gray-500);">
        <a href="<%= lien %>?but=specialite/specialite-list.jsp"
           style="color:var(--gray-500);text-decoration:none;">
            <i class="fa fa-tags" style="margin-right:4px;"></i>Liste des sp&eacute;cialit&eacute;s
        </a>
    </span>
</div>

<!-- ═══ FORM CARD ═══ -->
<div style="max-width:680px;margin:0 auto;">
    <div class="custom-card no-hover">

        <form id="formModif" enctype="multipart/form-data">
            <input type="hidden" name="photoActuelle" value="<%= photoPath != null ? photoPath : "" %>">
            <input type="hidden" name="idspecialite"  value="<%= id %>">

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
                #formModif input[type=file],
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
                #formModif input[type=file] { display: none !important; }
                .photo-upload-zone {
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    border: 2px dashed var(--gray-200);
                    border-radius: var(--radius-md);
                    padding: 1.5rem 1rem;
                    cursor: pointer;
                    transition: border-color 0.2s, background 0.2s;
                    background: #f9fafb;
                    position: relative;
                    min-height: 120px;
                    gap: 0.5rem;
                }
                .photo-upload-zone:hover { border-color: var(--itu-blue); background: rgba(0,139,255,0.03); }
                .photo-upload-zone.dragover { border-color: var(--itu-blue); background: rgba(0,139,255,0.06); }
                .photo-upload-icon { font-size: 2rem; color: var(--gray-300); }
                .photo-upload-label { font-size: 0.85rem; color: var(--gray-500); text-align: center; }
                .photo-upload-label strong { color: var(--itu-blue); }
                .photo-upload-hint { font-size: 0.75rem; color: var(--gray-400); }
                .photo-preview-wrap {
                    display: none;
                    flex-direction: column;
                    align-items: center;
                    gap: 0.6rem;
                    padding: 0.75rem;
                }
                .photo-preview-wrap img {
                    max-height: 140px;
                    max-width: 100%;
                    border-radius: var(--radius-md);
                    object-fit: cover;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.10);
                    border: 1.5px solid var(--gray-200);
                }
                .photo-preview-name { font-size: 0.78rem; color: var(--gray-500); }
                .photo-remove-btn {
                    font-size: 0.75rem;
                    color: #e53e3e;
                    background: none;
                    border: none;
                    cursor: pointer;
                    padding: 0;
                    text-decoration: underline;
                }
                #formModif .form-group {
                    margin-bottom: 1.25rem;
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
            </style>

            <%= htmlForm %>
        </form>

    </div>
</div>

<script>
(function () {
    // Remplace l'input texte pour "photo" par un upload zone stylisée
    var input = document.getElementById("photo");
    if (input) {
        var fi = document.createElement("input");
        fi.type = "file"; fi.name = "photo"; fi.id = "photo";
        fi.accept = "image/*";
        input.parentNode.replaceChild(fi, input);

        // Build upload zone
        var zone = document.createElement("div");
        zone.className = "photo-upload-zone";
        zone.id = "photoUploadZone";
        zone.innerHTML =
            '<i class="fa fa-cloud-upload photo-upload-icon"></i>' +
            '<span class="photo-upload-label"><strong>Cliquer pour choisir</strong> ou glisser-déposer</span>' +
            '<span class="photo-upload-hint">PNG, JPG, GIF — max 5 Mo</span>';

        var previewWrap = document.createElement("div");
        previewWrap.className = "photo-preview-wrap";
        previewWrap.id = "photoPreviewWrap";
        previewWrap.innerHTML =
            '<img id="photoPreviewImg" src="" alt="Aperçu">' +
            '<span class="photo-preview-name" id="photoPreviewName"></span>' +
            '<button type="button" class="photo-remove-btn" id="photoRemoveBtn">✕ Changer la photo</button>';

        fi.parentNode.insertBefore(zone, fi);
        fi.parentNode.insertBefore(previewWrap, fi);

        // Pre-fill preview if existing photo
        var existingPhoto = "<%= photoPath != null ? photoPath : "" %>";
        if (existingPhoto && existingPhoto.length > 0) {
            document.getElementById("photoPreviewImg").src = "<%= request.getContextPath() %>/" + existingPhoto;
            document.getElementById("photoPreviewName").textContent = existingPhoto.split("/").pop();
            zone.style.display = "none";
            previewWrap.style.display = "flex";
        }

        zone.addEventListener("click", function() { fi.click(); });
        zone.addEventListener("dragover", function(e) { e.preventDefault(); zone.classList.add("dragover"); });
        zone.addEventListener("dragleave", function() { zone.classList.remove("dragover"); });
        zone.addEventListener("drop", function(e) {
            e.preventDefault(); zone.classList.remove("dragover");
            if (e.dataTransfer.files.length) { handleFile(e.dataTransfer.files[0]); }
        });
        fi.addEventListener("change", function() {
            if (fi.files.length) handleFile(fi.files[0]);
        });
        document.getElementById("photoRemoveBtn").addEventListener("click", function() {
            fi.value = "";
            zone.style.display = "flex";
            previewWrap.style.display = "none";
        });

        function handleFile(file) {
            var reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById("photoPreviewImg").src = e.target.result;
                document.getElementById("photoPreviewName").textContent = file.name;
                zone.style.display = "none";
                previewWrap.style.display = "flex";
            };
            reader.readAsDataURL(file);
        }
    }

    // Restyle APJ submit button and replace reset with Annuler link
    var footer = document.querySelector("#formModif .box-footer");
    if (footer) {
        var submitBtn = footer.querySelector("button[type=submit]");
        if (submitBtn) {
            submitBtn.id = "btnSubmit";
            submitBtn.className = "btn btn-primary";
            submitBtn.style.cssText = "display:inline-flex;align-items:center;gap:6px;";
            submitBtn.innerHTML = '<i class="fa fa-check"></i> Enregistrer';
        }
        var resetBtn = footer.querySelector("button[type=reset]");
        if (resetBtn) {
            var cancelLink = document.createElement("a");
            cancelLink.href = "<%= lien %>?but=specialite/specialite-fiche.jsp&idspecialite=<%= id %>";
            cancelLink.className = "btn btn-ghost";
            cancelLink.textContent = "Annuler";
            resetBtn.parentNode.replaceChild(cancelLink, resetBtn);
        }
    }

    document.getElementById("formModif").addEventListener("submit", function(e) {
        e.preventDefault();
        var btn = document.getElementById("btnSubmit");
        btn.disabled = true;
        btn.innerHTML = '<i class="fa fa-spinner fa-spin" style="margin-right:5px;"></i>Enregistrement...';

        fetch("<%= request.getContextPath() %>/pages/specialite/ajax/traitement-update.jsp", {
            method: "POST",
            body: new FormData(this)
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                window.location.href = "<%= lien %>?but=<%= apres %>&idspecialite=" + data.id;
            } else {
                alert("Erreur : " + data.error);
                btn.disabled = false;
                btn.innerHTML = '<i class="fa fa-check" style="margin-right:5px;"></i>Enregistrer';
            }
        })
        .catch(function(err) {
            alert("Erreur reseau : " + err);
            btn.disabled = false;
            btn.innerHTML = '<i class="fa fa-check" style="margin-right:5px;"></i>Enregistrer';
        });
    });
})();
</script>
