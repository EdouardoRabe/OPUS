<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Media" %>
<%@ page import="bean.ClassMAPTable" %>
<%
    // POST: Creation de publication via framework APJ (u.createObject / u.createObjectMultiple)
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    String redirectUrl = ctx + "/pages/module.jsp?but=alumni/fil-actualite.jsp";

    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            response.sendRedirect(ctx + "/index.jsp");
            return;
        }
        MapUtilisateur map = u.getUser();

        String description = request.getParameter("description");
        String imageUrl = request.getParameter("imageUrl");

        if (description == null || description.trim().isEmpty()) {
            session.setAttribute("pubErreur", "Le texte de la publication ne peut pas etre vide.");
            response.sendRedirect(redirectUrl);
            return;
        }

        // --- APJ: Construire l'entite Publication ---
        Publication pub = new Publication();
        pub.setDescritpion(description.trim());
        pub.setDaty(java.time.LocalDate.now().toString());
        String heure = java.time.LocalTime.now().toString();
        if (heure.length() > 5) heure = heure.substring(0, 5);
        pub.setHeure(heure);
        pub.setEtat(1);
        pub.setIdtypepublication("TPB000001"); // Normal
        pub.setIdutilisateur(String.valueOf(map.getRefuser()));

        // --- APJ: Creer avec ou sans media ---
        if (imageUrl != null && !imageUrl.trim().isEmpty()) {
            // Publication + Media en une transaction via createObjectMultiple (mere/fille)
            Media media = new Media();
            media.setMediaurl(imageUrl.trim());
            media.setIdmediatype("MDT000001"); // Image
            // Framework: cree pub, genere PK, puis set idpublication sur media et cree media
            u.createObjectMultiple(pub, "idpublication", new ClassMAPTable[]{media});
        } else {
            // Publication seule via createObject (genere PK automatiquement)
            u.createObject(pub);
        }

        session.setAttribute("pubSucces", "Publication creee avec succes !");
        response.sendRedirect(redirectUrl);

    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("pubErreur", "Erreur: " + e.getMessage());
        response.sendRedirect(redirectUrl);
    }
%>
