<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
    String queryString = request.getQueryString();
    String but = "pages/testLogin.jsp";
    if(queryString != null && !queryString.equals("")){
        but += "?" + queryString;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ITU Alumni - Connexion</title>
</head>
<body>
    <h1>ITU Alumni - Connexion</h1>

    <%
        String loginError = (String) session.getAttribute("errorLogin");
        if (loginError != null) {
            session.removeAttribute("errorLogin");
    %>
        <p><b>Erreur : </b><%= loginError %></p>
    <%
        }
    %>

    <form action="<%= but %>" method="post">
        <p>
            <label for="identifiant">Num&eacute;ro ETU :</label><br/>
            <input type="text" id="identifiant" name="identifiant" placeholder="Ex: ETU000001" required />
        </p>
        <p>
            <label for="passe">Mot de passe :</label><br/>
            <input type="password" id="passe" name="passe" placeholder="Mot de passe" required />
        </p>
        <p>
            <button type="submit">Se connecter</button>
        </p>
    </form>
</body>
</html>