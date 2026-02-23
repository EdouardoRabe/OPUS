<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB, user.UserEJBClient" %>
<%@ page import="java.io.*" %>
<%@ page import="alumni.Profil" %>
<%@ page import="bean.CGenUtil" %>

<%
    // collect parameters
    String etu = request.getParameter("etu");
    String password = request.getParameter("password");
    String idparcours = request.getParameter("idparcours");
    String idpromotion = request.getParameter("idpromotion");
    String idgenre = request.getParameter("idgenre");
    String email = request.getParameter("email");
    String prenom = request.getParameter("prenom");
    String nom = request.getParameter("nom");
    String dtn = request.getParameter("dtn");
    String telephone = request.getParameter("telephone");
    java.sql.Date dtnDate = null;
    if(dtn != null && !dtn.isEmpty()){
        try {
            dtnDate = java.sql.Date.valueOf(dtn); // expects yyyy-MM-dd
        } catch(IllegalArgumentException ex){
            // leave null or handle error later
        }
    }

    // build values for bean
    String loginuser = etu; 
    String pwduser = password;
    String nomuser = (prenom != null ? prenom : "") + " " + (nom != null ? nom : "");
    String adruser = email;
    String teluser = telephone;
    String idrole = "etu"; 

    try {
        // Construire le profil
        Profil profil = new Profil();
        profil.setEmail(email);
        profil.setNom(nom);
        profil.setPrenom(prenom);
        if(dtnDate != null) profil.setDtn(dtnDate);
        profil.setTelephone(telephone);
        profil.setIdparcours(idparcours);
        profil.setIdpromotion(idpromotion);
        if(idgenre != null && !idgenre.isEmpty()) {
            profil.setIdgenre(idgenre);
        }

        // Tout creer dans une seule transaction (utilisateur + profil)
        UserEJB u = UserEJBClient.lookupUserEJBBeanLocal();
        String ret = u.createUtilisateurs(loginuser, pwduser, nomuser, adruser, teluser, idrole, profil);

        // redirect back to login with success flag
        response.sendRedirect(request.getContextPath() + "/index.jsp?inscription=success");
        return;

    } catch (Exception e) {
        e.printStackTrace();
        Throwable cause = e;
        while(cause.getCause() != null) cause = cause.getCause();
        String errText = cause.getMessage();
        if(errText == null) errText = e.toString();
        // Traduire les erreurs Postgres courantes
        if(errText.toLowerCase().contains("getseqcnapsuser")){
            errText = "Problème de configuration de la base : fonction de séquence utilisateur manquante";
        }
        if(errText.toLowerCase().contains("profil_email_key") || errText.toLowerCase().contains("email")){
            errText = "Cet email est déjà utilisé!";
        }
        session.setAttribute("errorInscription", errText);
        response.sendRedirect("inscription.jsp");
        return;
    }
%>