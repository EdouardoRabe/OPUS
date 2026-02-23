package servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

import alumni.Specialite;
import user.UserEJB;
import utilitaire.Utilitaire;

@WebServlet("/updatePhotoSpecialite")
@MultipartConfig
public class ServletUpdatePhotoSpecialite extends HttpServlet {

    private static final String PHOTO_DIR = System.getProperty("jboss.server.base.dir")
            + "/deployments/opus.war/assets/img/specialite/";
    private static final String PHOTO_REL = "assets/img/specialite/";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        UserEJB u = (UserEJB) session.getAttribute("u");
        String lien = request.getContextPath() + "/pages/module.jsp";

        String idspecialite  = request.getParameter("idspecialite");
        String libelle       = request.getParameter("libelle");
        String photoActuelle = request.getParameter("photoActuelle"); // chemin existant
        String butApresPost  = request.getParameter("bute");

        Part photoPart = request.getPart("photo");

        try {
            // --- Nouvelle photo si fichier envoyé ---
            String photoPath = (photoActuelle != null) ? photoActuelle : "";
            if (photoPart != null && photoPart.getSize() > 0) {
                String originalName = getFileName(photoPart);
                String savedName = Utilitaire.heureCourante().replace(":", "")
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

            // --- Mise à jour en base (updateObject gère sa propre connexion) ---
            Specialite spe = new Specialite();
            spe.setIdspecialite(idspecialite);
            spe.setLibelle(libelle);
            spe.setPhoto(photoPath);
            u.updateObject(spe);

            String redirect = lien + "?but=" + (butApresPost != null ? butApresPost : "specialite/specialite-list.jsp")
                    + "&idspecialite=" + idspecialite;
            response.sendRedirect(redirect);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Erreur lors de la mise à jour : " + e.getMessage());
        }
    }

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
