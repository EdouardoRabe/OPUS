<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.SpecialiteAdminService" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String PHOTO_DIR = System.getProperty("jboss.server.base.dir")
            + "/deployments/opus.war/assets/img/specialite/";
    String PHOTO_REL = "assets/img/specialite/";

    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        String userId = String.valueOf(u.getUser().getRefuser());

        String libelle = null;
        String description = null;
        FileItem photoItem = null;

        // --- Parse multipart ---
        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setSizeMax(10 * 1024 * 1024);
        List items = upload.parseRequest(request);
        for (int i = 0; i < items.size(); i++) {
            FileItem item = (FileItem) items.get(i);
            if (item.isFormField()) {
                if ("libelle".equals(item.getFieldName()))
                    libelle = item.getString("UTF-8");
                if ("description".equals(item.getFieldName()))
                    description = item.getString("UTF-8");
            } else {
                if ("photo".equals(item.getFieldName()) && item.getSize() > 0
                        && item.getName() != null && !item.getName().trim().isEmpty())
                    photoItem = item;
            }
        }

        if (libelle == null || libelle.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Le libell\\u00e9 est obligatoire\"}");
            return;
        }

        // --- Sauvegarde photo ---
        String photoPath = "";
        if (photoItem != null) {
            String origName = photoItem.getName();
            if (origName.contains("\\")) origName = origName.substring(origName.lastIndexOf("\\") + 1);
            if (origName.contains("/"))  origName = origName.substring(origName.lastIndexOf("/") + 1);
            String safeName = System.currentTimeMillis() + "_" + origName.replaceAll("[^a-zA-Z0-9._-]", "_");
            File dir = new File(PHOTO_DIR);
            if (!dir.exists()) dir.mkdirs();
            photoItem.write(new File(PHOTO_DIR + safeName));
            photoPath = PHOTO_REL + safeName;
        }

        // --- Insert en base via service ---
        out.print(SpecialiteAdminService.inserer(userId, libelle, description, photoPath));

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
