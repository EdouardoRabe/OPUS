<%@page import="user.UserEJB"%>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="utils.HtmlUtils" %>

<%
    String but = "index.jsp";
    String lien = "module.jsp";
    String lienContenu = "index.jsp";
    String menu = "elements/menu/";
    String langue = "";
	
    if (request.getParameter("langue") != null) {
        session.setAttribute("langue", (String) request.getParameter("langue"));
    }
    langue = (String) session.getAttribute("langue");
    try{
%>
<%@include file="security-login.jsp"%>
<%@include file="security-access.jsp"%>
<%
    if (session.getAttribute("lien") != null) {
        lien = (String) session.getAttribute("lien");
    }
    if (request.getParameter("idmenu") != null) {
        session.setAttribute("lien", (String) request.getParameter("idmenu"));
        session.setAttribute("menu", (String) request.getParameter("idmenu"));
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
	UserEJB u = (user.UserEJB) session.getValue("u");
%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>OPUS</title>
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
    <jsp:include page='elements/css.jsp'/>
    <!-- Alumni Navbar Module CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/alumni-navbar-module.css" rel="stylesheet" type="text/css" />
    <!-- Alumni Theme (card grids, page layouts, specialité, etc.) -->
    <link href="${pageContext.request.contextPath}/assets/css/alumni-theme.css" rel="stylesheet" type="text/css" />
    <script>
        const _CONTEXT_PATH = '<%= request.getContextPath() %>';
    </script>
</head>
<body>
<!-- Header Alumni Navbar -->
<jsp:include page='elements/header.jsp'/>

<!-- Main Alumni Page -->
<div class="alumni-page">
  <div class="alumni-page-wide">
    <!-- Main Content -->
    <% try {%>
    <jsp:include page='<%=but%>'/>
    <% } catch (Exception e) {%>
    <script language="JavaScript">
      alert('<%=HtmlUtils.escapeHtmlAccents(e.getMessage().toUpperCase()) %>');
      history.back();
    </script>
    <%
      }
    %>
  </div>
</div>

<!-- Panel -->
<jsp:include page='elements/panel.jsp'/>

<jsp:include page='elements/js.jsp'/>

<!-- Alumni Navbar JS (LinkedIn-style) -->
<script src="${pageContext.request.contextPath}/assets/js/alumni-navbar.js" defer></script>

<%
    String exception = (String) session.getAttribute("exception");
    if (exception != null) {
        System.out.println("exceptionnnnnnn");
        session.removeAttribute("exception");
%>
<script>
    Swal.fire({
        title: "Ouupss !",
        text: "<%= exception %>",
        icon: "error",
        confirmButtonText: "OK"
    });
</script>
<%
    }
%>

<script>
    <%
        UserEJB user = (UserEJB)request.getSession().getAttribute("u");
    %>
    runWScommunication('<%=user.getUser().getTuppleID()%>');
</script>
<script src="${pageContext.request.contextPath}/apjplugins/champcalcul.js" defer></script>
<script src="${pageContext.request.contextPath}/apjplugins/champdate.js" defer></script>
<script src="${pageContext.request.contextPath}/apjplugins/champautocomplete.js" defer></script>
<script src="${pageContext.request.contextPath}/apjplugins/moreAction.js" defer></script>
<script src="${pageContext.request.contextPath}/assets/js/timer-flottant.js"></script>
<!-- Alumni Navbar JS (LinkedIn-style) -->
<script src="${pageContext.request.contextPath}/assets/js/alumni-navbar.js" defer></script>
</body>
</html>

<%
} catch (Exception e) {
    e.printStackTrace();
%>

<script language="JavaScript">
    alert('<%=HtmlUtils.escapeHtmlAccents(e.getMessage())%>');
    history.back();
</script>
<% }%>