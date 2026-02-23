
<%@page import="bean.TypeObjet"%>
<%@page import="user.*"%>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="lc.Direction" %>
<%@ page import="historique.MapUtilisateur" %>

<%
    UserEJB u = null;
    String username = null;
    String pwd = null;
    historique.MapUtilisateur ut = null;
    String lien;
    String queryString;
%>

<%  try {
        username = request.getParameter("identifiant");
        pwd = request.getParameter("passe");

        u = UserEJBClient.lookupUserEJBBeanLocal();
        u.testLoginAlumni(username, pwd);

        session.setAttribute("username", username);
        session.setAttribute("u", u);
        ut = u.getUser();

        session.setAttribute("entmenu", "_all-skins");
        session.setAttribute("lang", "fr");

        lien = "module.jsp";
        queryString = "but=accueil.jsp";

        String queryURL = request.getQueryString();
        if (queryURL != null && !queryURL.equals("")) {
            queryString = queryURL;
        }

        // Menu dynamique par defaut
        String menu = "module.jsp";
        session.setAttribute("lien", lien);
        session.setAttribute("menu", menu);
        session.setAttribute("dir", ut.getAdruser());

        out.println("<script language='JavaScript'> document.location.replace('" + lien + "?" + queryString + "');</script>");

    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("errorLogin", e.getMessage());
%>
<script language="JavaScript">
    document.location.replace("<%= request.getContextPath() %>/index.jsp");
</script>
<%
    }
%>
