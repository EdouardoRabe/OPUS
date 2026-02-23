<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page import="user.UserEJB"%>
<%@ page import="historique.MapUtilisateur" %>
<%
    UserEJB uAccueil = (UserEJB) session.getAttribute("u");
    MapUtilisateur mapAccueil = uAccueil.getUser();
    String nomAccueil = mapAccueil.getNomuser() != null ? mapAccueil.getNomuser() : "";
    String etuAccueil = mapAccueil.getLoginuser() != null ? mapAccueil.getLoginuser() : "";
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Accueil <small>ITU Alumni</small></h1>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-12">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title">Bienvenue sur ITU Alumni, <%= nomAccueil %></h3>
                    </div>
                    <div class="box-body">
                        <p>Connect&eacute; en tant que : <strong><%= etuAccueil %></strong></p>
                        <p>Utilisez le menu lat&eacute;ral pour naviguer.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>
