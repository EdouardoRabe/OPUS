<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Media" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%
    // POST multipart: Creer publication + upload image dans table media
    // Utilise Commons FileUpload (meme lib que UploadDownloadFileServlet)
    // Utilise ClassMAPTable.construirePK + insertToTableWithHisto (100% APJ)

    String ctx = request.getContextPath();
    String redirectUrl = ctx + "/pages/module.jsp?but=alumni/fil-actualite.jsp";

    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            response.sendRedirect(ctx + "/index.jsp");
            return;
        }
        MapUtilisateur map = u.getUser();
        String userId = String.valueOf(map.getRefuser());

        // --- Parse multipart avec Commons FileUpload ---
        String description = null;
        String idtypepublication = null;
        FileItem imageItem = null;

        if (ServletFileUpload.isMultipartContent(request)) {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(10 * 1024 * 1024); // 10 Mo max
            List items = upload.parseRequest(request);
            for (int i = 0; i < items.size(); i++) {
                FileItem item = (FileItem) items.get(i);
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    String fieldValue = item.getString("UTF-8");
                    if ("description".equals(fieldName)) description = fieldValue;
                    else if ("idtypepublication".equals(fieldName)) idtypepublication = fieldValue;
                } else {
                    if (item.getSize() > 0 && item.getName() != null && !item.getName().trim().isEmpty()) {
                        imageItem = item;
                    }
                }
            }
        } else {
            // Fallback formulaire classique (sans fichier)
            description = request.getParameter("description");
            idtypepublication = request.getParameter("idtypepublication");
        }

        if (description == null || description.trim().isEmpty()) {
            session.setAttribute("pubErreur", "Le texte de la publication ne peut pas etre vide.");
            response.sendRedirect(redirectUrl);
            return;
        }
        if (idtypepublication == null || idtypepublication.trim().isEmpty()) {
            idtypepublication = "TPB000001";
        }

        // --- APJ: Construire l'entite Publication ---
        Publication pub = new Publication();
        pub.setDescritpion(description.trim());
        pub.setDaty(java.sql.Date.valueOf(java.time.LocalDate.now()));
        String heure = java.time.LocalTime.now().toString();
        if (heure.length() > 5) heure = heure.substring(0, 5);
        pub.setHeure(heure);
        pub.setEtat(1);
        pub.setIdtypepublication(idtypepublication.trim());
        pub.setIdutilisateur(map.getRefuser());

        // --- APJ: Creer avec connection manuelle ---
        Connection conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);
        try {
            pub.construirePK(conn);
            pub.insertToTableWithHisto(userId, conn);

            // Si image uploadee, sauvegarder le fichier et creer l'entite Media
            if (imageItem != null) {
                // Repertoire de stockage (meme pattern que UploadDownloadFileServlet)
                String basePath = System.getProperty("jboss.server.base.dir")
                    + File.separator + "deployments" + File.separator + "dossier.war"
                    + File.separator + "async" + File.separator + "publications";
                File dir = new File(basePath);
                if (!dir.exists()) dir.mkdirs();

                // Nom unique: timestamp + nom original (nettoye)
                String origName = imageItem.getName();
                if (origName.contains("\\")) origName = origName.substring(origName.lastIndexOf("\\") + 1);
                if (origName.contains("/")) origName = origName.substring(origName.lastIndexOf("/") + 1);
                String safeName = origName.replaceAll("[^a-zA-Z0-9._-]", "_");
                String fileName = System.currentTimeMillis() + "_" + safeName;
                File dest = new File(basePath + File.separator + fileName);
                imageItem.write(dest);

                // Creer entite Media (APJ) - chemin relatif pour UploadDownloadFileServlet
                Media media = new Media();
                media.setMediaurl("/async/publications/" + fileName);
                media.setIdmediatype("MDT000001"); // Image
                media.setIdpublication(pub.getIdpublication());
                media.construirePK(conn);
                media.insertToTableWithHisto(userId, conn);
            }

            conn.commit();
        } catch (Exception ex) {
            conn.rollback();
            throw ex;
        } finally {
            conn.close();
        }

        session.setAttribute("pubSucces", "Publication creee avec succes !");
        response.sendRedirect(redirectUrl);

    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("pubErreur", "Erreur: " + e.getMessage());
        response.sendRedirect(request.getContextPath() + "/pages/module.jsp?but=alumni/fil-actualite.jsp");
    }
%>
