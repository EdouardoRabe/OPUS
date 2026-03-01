<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.ProfilService" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String CV_DIR = System.getProperty("jboss.server.base.dir")
            + "/deployments/opus.war/assets/cv/";
    String CV_REL = "assets/cv/";

    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        int refuser = u.getUser().getRefuser();

        FileItem cvItem = null;

        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setSizeMax(10 * 1024 * 1024);
        List items = upload.parseRequest(request);
        for (int i = 0; i < items.size(); i++) {
            FileItem item = (FileItem) items.get(i);
            if (!item.isFormField()) {
                if ("cv".equals(item.getFieldName()) && item.getSize() > 0
                        && item.getName() != null && !item.getName().trim().isEmpty())
                    cvItem = item;
            }
        }

        if (cvItem == null) {
            out.print("{\"success\":false,\"error\":\"Aucun fichier CV selectionne\"}");
            return;
        }

        // Verifier l'extension (PDF, DOC, DOCX)
        String origName = cvItem.getName();
        if (origName.contains("\\")) origName = origName.substring(origName.lastIndexOf("\\") + 1);
        if (origName.contains("/"))  origName = origName.substring(origName.lastIndexOf("/") + 1);

        String lowerName = origName.toLowerCase();
        if (!lowerName.endsWith(".pdf") && !lowerName.endsWith(".doc") && !lowerName.endsWith(".docx")) {
            out.print("{\"success\":false,\"error\":\"Format non supporte. Utilisez PDF, DOC ou DOCX.\"}");
            return;
        }

        // Sauvegarde fichier sur disque
        String safeName = System.currentTimeMillis() + "_" + origName.replaceAll("[^a-zA-Z0-9._-]", "_");
        File dir = new File(CV_DIR);
        if (!dir.exists()) dir.mkdirs();
        cvItem.write(new File(CV_DIR + safeName));
        String cvPath = CV_REL + safeName;

        // Delegation au service pour la mise a jour en BDD
        out.print(ProfilService.uploadCv(refuser, cvPath));

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"","'").replace("\n"," ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>