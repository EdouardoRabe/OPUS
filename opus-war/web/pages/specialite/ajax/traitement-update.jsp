<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
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

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            return;
        }
        String userId = String.valueOf(u.getUser().getRefuser());

        String idspecialite  = null;
        String libelle       = null;
        String photoActuelle = null;
        FileItem photoItem   = null;

        // --- Parse multipart ---
        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setSizeMax(10 * 1024 * 1024);
        List items = upload.parseRequest(request);
        for (int i = 0; i < items.size(); i++) {
            FileItem item = (FileItem) items.get(i);
            if (item.isFormField()) {
                String n = item.getFieldName();
                String v = item.getString("UTF-8");
                if ("idspecialite".equals(n))  idspecialite  = v;
                if ("libelle".equals(n))        libelle       = v;
                if ("photoActuelle".equals(n))  photoActuelle = v;
            } else {
                if ("photo".equals(item.getFieldName()) && item.getSize() > 0
                        && item.getName() != null && !item.getName().trim().isEmpty())
                    photoItem = item;
            }
        }

        if (idspecialite == null || idspecialite.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"ID manquant\"}");
            return;
        }
        if (libelle == null || libelle.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Le libell\\u00e9 est obligatoire\"}");
            return;
        }

        // --- Nouvelle photo ou conserver l'ancienne ---
        String photoPath = (photoActuelle != null) ? photoActuelle : "";
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

        // --- Update en base ---
        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        Specialite spe = new Specialite();
        spe.setIdspecialite(idspecialite.trim());
        spe.setLibelle(libelle.trim());
        spe.setPhoto(photoPath);
        spe.setMode("modif");
        spe.updateToTableWithHisto(userId, conn);
        conn.commit();

        out.print("{\"success\":true,\"id\":\"" + idspecialite.trim() + "\"}");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
