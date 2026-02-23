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

    String message = null;
    try {
        UserEJB u = UserEJBClient.lookupUserEJBBeanLocal();
        String ret = u.createUtilisateurs(loginuser, pwduser, nomuser, adruser, teluser, idrole);
     
        if(ret != null && !ret.toLowerCase().startsWith("erreur")) {
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
                try {
                    profil.setIdutilisateur(Integer.parseInt(ret));
                } catch(NumberFormatException nfe) {
                    // leave null if parsing fails
                }
                profil.insertToTable();
        }
      
        if(message == null) {
            message = "Inscription réussie, vous pouvez maintenant vous connecter.";
        }

        // redirect back to login with success flag
        response.sendRedirect(request.getContextPath() + "/index.jsp?inscription=success");
        return;

    } catch (Exception e) {
        e.printStackTrace();
        // root cause if nested
        Throwable cause = e;
        while(cause.getCause() != null) cause = cause.getCause();
        String errText = cause.getMessage();
        if(errText == null) errText = e.toString();
        // translate common Postgres missing function message
        if(errText.toLowerCase().contains("getseqcnapsuser")){
            errText = "Problème de configuration de la base : fonction de séquence utilisateur manquante";
        }
        session.setAttribute("errorInscription", errText);
        // preserve form values by appending as query parameters
        String redirectURL = "detailsInscription.jsp?" +
                "etu=" + java.net.URLEncoder.encode(etu == null?"":etu, "UTF-8") +
                "&password=" + java.net.URLEncoder.encode(password==null?"":password, "UTF-8") +
                "&idparcours=" + java.net.URLEncoder.encode(idparcours==null?"":idparcours, "UTF-8") +
                "&idpromotion=" + java.net.URLEncoder.encode(idpromotion==null?"":idpromotion, "UTF-8") +
                "&idgenre=" + java.net.URLEncoder.encode(idgenre==null?"":idgenre, "UTF-8");
        response.sendRedirect(redirectURL);
        return;
    }
%>