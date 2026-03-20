<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.CreerPublicationService" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.FileUploadBase" %>
<%
    // POST multipart: Creer publication + upload image dans table media
    // Utilise Commons FileUpload (meme lib que UploadDownloadFileServlet)
    // Utilise ClassMAPTable.construirePK + insertToTableWithHisto (100% APJ)

    String ctx = request.getContextPath();
    String redirectUrl = ctx + "/pages/module.jsp?but=accueil.jsp";

    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            response.sendRedirect(ctx + "/index.jsp");
            return;
        }
        MapUtilisateur map = u.getUser();
        String userId = String.valueOf(map.getRefuser());

        {
            String erreurLimite = CreerPublicationService.verifierDroitPublication(
                map.getIdrole(), map.getRefuser());
            if (erreurLimite != null) {
                session.setAttribute("pubErreur", erreurLimite);
                response.sendRedirect(redirectUrl);
                return;
            }
        }

        // --- Parse multipart avec Commons FileUpload ---
        String description = null;
        String idtypepublication = null;
        String identifications = null;
        String visSpec = null, visParc = null, visPromoAnnee = null, visLier = null;
        List mediaItems = new java.util.ArrayList(); // List<FileItem>

        if (ServletFileUpload.isMultipartContent(request)) {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(50 * 1024 * 1024); // 50 Mo max (videos)
            upload.setFileSizeMax(50 * 1024 * 1024); // 50 Mo max par fichier
            List items = null;
            try {
                items = upload.parseRequest(request);
            } catch (FileUploadBase.SizeLimitExceededException sle) {
                long actualMB = sle.getActualSize() / (1024 * 1024);
                long maxMB = sle.getPermittedSize() / (1024 * 1024);
                session.setAttribute("pubErreur",
                    "Le fichier est trop volumineux (" + actualMB + " Mo). La taille maximale autorisee est de " + maxMB + " Mo.");
                response.sendRedirect(redirectUrl);
                return;
            } catch (FileUploadBase.FileSizeLimitExceededException fsle) {
                long maxMB = fsle.getPermittedSize() / (1024 * 1024);
                session.setAttribute("pubErreur",
                    "Un des fichiers depasse la taille maximale autorisee de " + maxMB + " Mo.");
                response.sendRedirect(redirectUrl);
                return;
            }
            for (int i = 0; i < items.size(); i++) {
                FileItem item = (FileItem) items.get(i);
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    String fieldValue = item.getString("UTF-8");
                    if ("description".equals(fieldName)) description = fieldValue;
                    else if ("idtypepublication".equals(fieldName)) idtypepublication = fieldValue;
                    else if ("identifications".equals(fieldName)) identifications = fieldValue;
                    else if ("vis_spec".equals(fieldName)) visSpec = fieldValue;
                    else if ("vis_parc".equals(fieldName)) visParc = fieldValue;
                    else if ("vis_promo_annee".equals(fieldName)) visPromoAnnee = fieldValue;
                    else if ("vis_lier".equals(fieldName)) visLier = fieldValue;
                } else {
                    if (item.getSize() > 0 && item.getName() != null && !item.getName().trim().isEmpty()) {
                        mediaItems.add(item);
                    }
                }
            }
        } else {
            // Fallback formulaire classique (sans fichier)
            description = request.getParameter("description");
            idtypepublication = request.getParameter("idtypepublication");
            visSpec      = request.getParameter("vis_spec");
            visParc      = request.getParameter("vis_parc");
            visPromoAnnee= request.getParameter("vis_promo_annee");
            visLier      = request.getParameter("vis_lier");
        }

        boolean hasMedia = (mediaItems != null && mediaItems.size() > 0);
        if ((description == null || description.trim().isEmpty()) && !hasMedia) {
            session.setAttribute("pubErreur", "Veuillez ajouter un texte ou un fichier media.");
            response.sendRedirect(redirectUrl);
            return;
        }
        if (description == null) description = "";
        if (idtypepublication == null || idtypepublication.trim().isEmpty()) {
            idtypepublication = "TPB000001";
        }

        // --- Sauvegarder les fichiers media sur disque ---
        List savedMediaFiles = new java.util.ArrayList(); // List<File>
        String basePath = System.getProperty("jboss.server.base.dir")
            + File.separator + "deployments" + File.separator + "dossier.war"
            + File.separator + "async" + File.separator + "publications";
        File dir = new File(basePath);
        if (!dir.exists()) dir.mkdirs();

        for (int mi = 0; mi < mediaItems.size(); mi++) {
            FileItem mediaFile = (FileItem) mediaItems.get(mi);
            String origName = mediaFile.getName();
            if (origName.contains("\\")) origName = origName.substring(origName.lastIndexOf("\\") + 1);
            if (origName.contains("/")) origName = origName.substring(origName.lastIndexOf("/") + 1);
            String safeName = origName.replaceAll("[^a-zA-Z0-9._-]", "_");
            String fileName = System.currentTimeMillis() + "_" + mi + "_" + safeName;
            File dest = new File(basePath + File.separator + fileName);
            mediaFile.write(dest);

            // Stocker [relativePath, mediaTypeId]
            String[] info = new String[2];
            info[0] = "/async/publications/" + fileName;
            String contentType = mediaFile.getContentType();
            info[1] = (contentType != null && contentType.startsWith("video/")) ? "MDT000002" : "MDT000001";
            savedMediaFiles.add(info);
        }

        // --- Deleguer la creation DB au service ---
        CreerPublicationService.creerPublication(map.getRefuser(), description, idtypepublication,
            identifications, visSpec, visParc, visPromoAnnee, visLier, savedMediaFiles);

        session.setAttribute("pubSucces", "Publication creee avec succes !");
        response.sendRedirect(redirectUrl);

    } catch (org.apache.commons.fileupload.FileUploadException fue) {
        // Erreur liee au telechargement du fichier (taille, format, etc.)
        String fueMsg = fue.getMessage();
        if (fueMsg != null && fueMsg.contains("size")) {
            session.setAttribute("pubErreur", "Le fichier est trop volumineux. La taille maximale autorisee est de 50 Mo.");
        } else {
            session.setAttribute("pubErreur", "Erreur lors du telechargement du fichier. Veuillez reessayer.");
        }
        response.sendRedirect(request.getContextPath() + "/pages/module.jsp?but=accueil.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        String errMsg = e.getMessage();
        if (errMsg != null && errMsg.length() > 200) errMsg = errMsg.substring(0, 200);
        session.setAttribute("pubErreur", "Erreur lors de la creation de la publication. Veuillez reessayer.");
        response.sendRedirect(request.getContextPath() + "/pages/module.jsp?but=accueil.jsp");
    }
%>
