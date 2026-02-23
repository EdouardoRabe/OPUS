package servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.Connection;
import java.sql.SQLException;

import alumni.Specialite;
import user.UserEJB;
import utilitaire.UtilDB;
import utilitaire.Utilitaire;

@WebServlet("/uploadPhotoSpecialite")
@MultipartConfig
public class ServletUploadPhotoSpecialite extends HttpServlet {

    // Dossier de sauvegarde des photos dans le WAR déployé
    private static final String PHOTO_DIR = System.getProperty("jboss.server.base.dir")
            + "/deployments/opus.war/assets/img/specialite/";

    // Chemin relatif stocké en base
    private static final String PHOTO_REL = "assets/img/specialite/";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        UserEJB u = (UserEJB) session.getAttribute("u");
        String lien = request.getContextPath() + "/pages/module.jsp";

        Part photoPart = request.getPart("photo");
        String libelle   = request.getParameter("libelle");
        String butApresPost = request.getParameter("bute");

        Connection c = null;
        try {
            // --- Sauvegarde du fichier ---
            String photoPath = "";
            if (photoPart != null && photoPart.getSize() > 0) {
                String originalName = getFileName(photoPart);
                String ext = "";
                int dot = originalName.lastIndexOf('.');
                if (dot > 0) ext = originalName.substring(dot); // ".jpg", ".png" …

                // Nom unique : timestamp + nom original nettoyé
                String savedName = Utilitaire.heureCourante()
                        .replace(":", "")
                        + Utilitaire.dateDuJour().replace("/", "")
                        + "-" + originalName.replace(" ", "_");

                File dir = new File(PHOTO_DIR);
                if (!dir.exists()) dir.mkdirs();

                File dest = new File(PHOTO_DIR + savedName);
                try (InputStream in = photoPart.getInputStream();
                    FileOutputStream out = new FileOutputStream(dest)) {
                    byte[] buf = new byte[4096];
                    int read;
                    while ((read = in.read(buf)) != -1) out.write(buf, 0, read);
                }
                photoPath = PHOTO_REL + savedName;
            }

            // --- Insertion en base ---
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);

            Specialite spe = new Specialite();
            spe.setLibelle(libelle);
            spe.setPhoto(photoPath);
            spe.createObject(u.getUser(), c);

            c.commit();

            response.sendRedirect(lien + "?but=" + (butApresPost != null ? butApresPost : "specialite/scpecialite-list.jsp"));

        } catch (Exception e) {
            if (c != null) {
                try { c.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.getWriter().println("Erreur lors de l'upload : " + e.getMessage());
        } finally {
            if (c != null) {
                try { c.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    /** Extrait le nom du fichier depuis le header content-disposition */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return "photo";
        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "photo";
    }
}
