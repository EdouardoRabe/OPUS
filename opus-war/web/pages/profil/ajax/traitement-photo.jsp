<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" buffer="none" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.ProfilService" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="java.awt.Graphics2D" %>
<%@ page import="java.awt.RenderingHints" %>
<%@ page import="javax.imageio.ImageIO" %>
<%@ page import="java.io.ByteArrayInputStream" %>
<%!
    // Dimensions pour photo de profil (carree)
    private static final int PROFILE_SIZE = 200;
    // Dimensions pour photo de couverture
    private static final int COVER_WIDTH = 700;
    private static final int COVER_HEIGHT = 200;

    /**
     * Redimensionne une image selon le type de photo
     * @param originalImage L'image originale
     * @param photoType 1 = photo de profil, 0 = photo de couverture
     * @return L'image redimensionnee
     */
    private BufferedImage resizeImage(BufferedImage originalImage, int photoType) {
        int targetWidth, targetHeight;

        if (photoType == 0) {
            // Photo de couverture - redimensionnement simple sans crop
            targetWidth = COVER_WIDTH;
            targetHeight = COVER_HEIGHT;
        } else {
            // Photo de profil - carree avec crop centre
            targetWidth = PROFILE_SIZE;
            targetHeight = PROFILE_SIZE;
        }

        int originalWidth = originalImage.getWidth();
        int originalHeight = originalImage.getHeight();

        BufferedImage processedImage = originalImage;

        // Pour photo de profil, faire un crop centre
        if (photoType == 1) {
            double targetRatio = (double) targetWidth / targetHeight;
            double originalRatio = (double) originalWidth / originalHeight;

            int cropX = 0, cropY = 0, cropWidth = originalWidth, cropHeight = originalHeight;

            if (originalRatio > targetRatio) {
                // Image trop large, crop horizontal
                cropWidth = (int) (originalHeight * targetRatio);
                cropX = (originalWidth - cropWidth) / 2;
            } else {
                // Image trop haute, crop vertical
                cropHeight = (int) (originalWidth / targetRatio);
                cropY = (originalHeight - cropHeight) / 2;
            }

            // Extraire la zone a conserver (crop centre)
            processedImage = originalImage.getSubimage(cropX, cropY, cropWidth, cropHeight);
        }

        // Redimensionner a la taille cible
        BufferedImage resizedImage = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = resizedImage.createGraphics();
        g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g2d.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g2d.drawImage(processedImage, 0, 0, targetWidth, targetHeight, null);
        g2d.dispose();

        return resizedImage;
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String PHOTO_DIR = System.getProperty("jboss.server.base.dir")
            + "/deployments/opus.war/assets/img/profil/";
    String PHOTO_REL = "assets/img/profil/";

    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }
        int refuser = u.getUser().getRefuser();

        String typeStr = null;
        FileItem photoItem = null;

        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setSizeMax(10 * 1024 * 1024);
        List items = upload.parseRequest(request);
        for (int i = 0; i < items.size(); i++) {
            FileItem item = (FileItem) items.get(i);
            if (item.isFormField()) {
                if ("type".equals(item.getFieldName()))
                    typeStr = item.getString("UTF-8");
            } else {
                if ("photo".equals(item.getFieldName()) && item.getSize() > 0
                        && item.getName() != null && !item.getName().trim().isEmpty())
                    photoItem = item;
            }
        }

        if (photoItem == null) {
            out.print("{\"success\":false,\"error\":\"Aucune image selectionnee\"}");
            return;
        }
        int photoType = (typeStr != null) ? Integer.parseInt(typeStr) : 1;

        // Lecture et redimensionnement de l'image
        BufferedImage originalImage = ImageIO.read(new ByteArrayInputStream(photoItem.get()));
        if (originalImage == null) {
            out.print("{\"success\":false,\"error\":\"Format d'image non supporte\"}");
            return;
        }
        BufferedImage resizedImage = resizeImage(originalImage, photoType);

        // Sauvegarde fichier sur disque
        String origName = photoItem.getName();
        if (origName.contains("\\")) origName = origName.substring(origName.lastIndexOf("\\") + 1);
        if (origName.contains("/"))  origName = origName.substring(origName.lastIndexOf("/") + 1);
        // Forcer l'extension .jpg pour les images redimensionnees
        String baseName = origName.replaceAll("\\.[^.]+$", "");
        String safeName = System.currentTimeMillis() + "_" + baseName.replaceAll("[^a-zA-Z0-9._-]", "_") + ".jpg";
        File dir = new File(PHOTO_DIR);
        if (!dir.exists()) dir.mkdirs();
        File outputFile = new File(PHOTO_DIR + safeName);
        ImageIO.write(resizedImage, "jpg", outputFile);
        String photoPath = PHOTO_REL + safeName;

        // Delegation au service pour l'insertion en BDD
        out.print(ProfilService.uploadPhoto(refuser, photoType, photoPath));

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"","'").replace("\n"," ") : "Erreur inconnue";
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    }
%>
