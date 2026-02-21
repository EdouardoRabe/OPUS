<%-- 
    Document   : popup
    Created on : 23 mai 2016, 15:54:22
    Author     : Admin
--%>
<%@page import="user.UserEJB"%>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>

<%
    String but = "index.jsp";
    String lien = "popup.jsp";
    String lienContenu = "index.jsp";
    String menu = "elements/menu/";
    String lang = "";
    if (request.getParameter("lang") != null) {
        session.setAttribute("lang", (String) request.getParameter("lang"));
    }
    lang = (String) session.getAttribute("lang");
%>
<%@include file="security-login.jsp"%>
<%  
    if (session.getAttribute("lien") != null) {
        lien = (String) session.getAttribute("lien");
    }
   
    if ((request.getParameter("but") != null) && session.getAttribute("u") != null) {
        but = request.getParameter("but");
        lien = (String) session.getAttribute("lien");
        menu += (String) session.getAttribute("menu");
    } else { %>
<script language="JavaScript">
    alert("Veuillez vous connecter pour acceder a ce contenu");
    document.location.replace("${pageContext.request.contextPath}/index.jsp");
</script>
<% }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>ATT</title>
        <!-- Tell the browser to be responsive to screen width -->
        <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
        <jsp:include page='elements/css.jsp'/>
    </head>
    <body class="skin-blue sidebar-mini">
        <!-- Site wrapper -->
        <div class="wrapper">
            <!-- Header -->
            <!-- =============================================== -->
            <!-- Menu Gauche -->
            
            <!-- =============================================== -->
            <!-- Content -->
            <% try {%>
            <jsp:include page='<%=but%>'/>
            <% } catch (Exception e) {
            e.printStackTrace();%>
            <script language="JavaScript"> alert('<%=e.getMessage().toUpperCase() %>');
                history.back();</script>
                <%
                    }
                %>
            <!-- =============================================== -->
            <!-- Footer -->
            <jsp:include page='elements/footer.jsp'/>
            <!-- =============================================== -->
            <!-- Panel -->
            <jsp:include page='elements/panel.jsp'/>
            <!-- =============================================== -->
        </div>
        <!-- ./wrapper -->
        <jsp:include page='elements/js.jsp'/>
        <script>
            <%
                UserEJB user = (UserEJB)request.getSession().getAttribute("u");
            %>
            runWScommunication('<%=user.getUser().getTuppleID()%>');
        </script>
        <script src="${pageContext.request.contextPath}/apjplugins/champcalcul.js" defer></script>      
        <script src="${pageContext.request.contextPath}/apjplugins/champdate.js" defer></script>      
        <script src="${pageContext.request.contextPath}/apjplugins/champautocomplete.js" defer></script>      
    </body>
    <script>
    </script>
</html>