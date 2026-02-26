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
    String typerole = request.getParameter("typerole");
    // Valider le role choisi (etu ou alu), defaut etu
    if(typerole == null || (!"+etu".equals("+" + typerole) && !"+alu".equals("+" + typerole))){
        typerole = "etu";
    }

    // Validation basique des champs obligatoires
    if(etu == null || etu.trim().isEmpty() || password == null || password.trim().isEmpty()){
        session.setAttribute("errorInscription", "Identifiant et mot de passe requis.");
        session.setAttribute("reg_typerole", typerole);
        response.sendRedirect("inscription.jsp");
        return;
    }
    if(email == null || email.trim().isEmpty() || nom == null || nom.trim().isEmpty()
       || prenom == null || prenom.trim().isEmpty() || idparcours == null || idparcours.trim().isEmpty()
       || idpromotion == null || idpromotion.trim().isEmpty()){
        session.setAttribute("errorInscription", "Veuillez remplir tous les champs obligatoires.");
        session.setAttribute("reg_etu", etu);
        session.setAttribute("reg_password", password);
        session.setAttribute("reg_idparcours", idparcours);
        session.setAttribute("reg_idpromotion", idpromotion);
        session.setAttribute("reg_idgenre", idgenre);
        session.setAttribute("reg_email", email);
        session.setAttribute("reg_prenom", prenom);
        session.setAttribute("reg_nom", nom);
        session.setAttribute("reg_dtn", dtn);
        session.setAttribute("reg_telephone", telephone);
        session.setAttribute("reg_typerole", typerole);
        response.sendRedirect("detailsInscription.jsp");
        return;
    }

    java.sql.Date dtnDate = null;
    if(dtn != null && !dtn.isEmpty()){
        try {
            dtnDate = java.sql.Date.valueOf(dtn); // expects yyyy-MM-dd
        } catch(IllegalArgumentException ex){
            session.setAttribute("errorInscription", "Format de date de naissance invalide.");
            session.setAttribute("reg_etu", etu);
            session.setAttribute("reg_password", password);
            session.setAttribute("reg_idparcours", idparcours);
            session.setAttribute("reg_idpromotion", idpromotion);
            session.setAttribute("reg_idgenre", idgenre);
            session.setAttribute("reg_email", email);
            session.setAttribute("reg_prenom", prenom);
            session.setAttribute("reg_nom", nom);
            session.setAttribute("reg_dtn", dtn);
            session.setAttribute("reg_telephone", telephone);
            session.setAttribute("reg_typerole", typerole);
            response.sendRedirect("detailsInscription.jsp");
            return;
        }
    }

    // build values for bean
    String loginuser = etu.trim(); 
    String pwduser = password;
    String nomuser = prenom.trim() + " " + nom.trim();
    String adruser = email.trim();
    String teluser = (telephone != null ? telephone.trim() : "");
    String idrole = typerole; 

    try {
        // Construire le profil
        Profil profil = new Profil();
        profil.setEmail(email.trim());
        profil.setNom(nom.trim());
        profil.setPrenom(prenom.trim());
        if(dtnDate != null) profil.setDtn(dtnDate);
        profil.setTelephone(teluser);
        profil.setIdparcours(idparcours);
        profil.setIdpromotion(idpromotion);
        if(idgenre != null && !idgenre.isEmpty()) {
            profil.setIdgenre(idgenre);
        }

        // Tout creer dans une seule transaction (utilisateur + profil)
        UserEJB u = UserEJBClient.lookupUserEJBBeanLocal();
        String ret = u.createUtilisateurs(loginuser, pwduser, nomuser, adruser, teluser, idrole, profil);

        // Verifier que la creation a bien retourne un ID valide
        if(ret == null || ret.trim().isEmpty() || ret.equals("0")){
            session.setAttribute("errorInscription", "Erreur lors de la creation du compte. Veuillez reessayer.");
            session.setAttribute("reg_etu", etu);
            session.setAttribute("reg_password", password);
            session.setAttribute("reg_idparcours", idparcours);
            session.setAttribute("reg_idpromotion", idpromotion);
            session.setAttribute("reg_idgenre", idgenre);
            session.setAttribute("reg_email", email);
            session.setAttribute("reg_prenom", prenom);
            session.setAttribute("reg_nom", nom);
            session.setAttribute("reg_dtn", dtn);
            session.setAttribute("reg_telephone", telephone);
            session.setAttribute("reg_typerole", typerole);
            response.sendRedirect("detailsInscription.jsp");
            return;
        }

        // redirect to attente validation
        response.sendRedirect("attenteValidation.jsp");
        return;

    } catch (Exception e) {
        e.printStackTrace();
        Throwable cause = e;
        while(cause.getCause() != null) cause = cause.getCause();
        String errText = cause.getMessage();
        if(errText == null) errText = e.toString();
        // Traduire les erreurs Postgres courantes
        if(errText.toLowerCase().contains("getsequtilisateur") || errText.toLowerCase().contains("getseqcnapsuser")
           || errText.toLowerCase().contains("getseqparamcrypt") || errText.toLowerCase().contains("sequence")){
            errText = "Probleme de configuration de la base de donnees. Veuillez contacter l'administrateur.";
        }
        if(errText.toLowerCase().contains("profil_email_key") || errText.toLowerCase().contains("cet email")){
            errText = "Cet email est deja utilise!";
        }
        if(errText.toLowerCase().contains("login deja")){
            errText = "Ce numero ETU est deja utilise!";
        }
        if(errText.toLowerCase().contains("unique") && errText.toLowerCase().contains("violation")){
            errText = "Un compte avec ces informations existe deja.";
        }
        // Sauvegarder les donnees du formulaire en session pour ne pas les perdre
        session.setAttribute("errorInscription", errText);
        session.setAttribute("reg_etu", etu);
        session.setAttribute("reg_password", password);
        session.setAttribute("reg_idparcours", idparcours);
        session.setAttribute("reg_idpromotion", idpromotion);
        session.setAttribute("reg_idgenre", idgenre);
        session.setAttribute("reg_email", email);
        session.setAttribute("reg_prenom", prenom);
        session.setAttribute("reg_nom", nom);
        session.setAttribute("reg_dtn", dtn);
        session.setAttribute("reg_telephone", telephone);
        session.setAttribute("reg_typerole", typerole);
        response.sendRedirect("detailsInscription.jsp");
        return;
    }
%>