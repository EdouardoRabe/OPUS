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
    <%--        <script src="${pageContext.request.contextPath}/dist/js/chart.js"></script>--%>
    <script>
        const _CONTEXT_PATH = '<%= request.getContextPath() %>';
    </script>
    <%--        <link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet">--%>
    <%--        <script src="https://cdn.quilljs.com/1.3.6/quill.js"></script>--%>
</head>
<body class="skin-blue sidebar-mini">
<!-- Site wrapper -->
<div class="wrapper">
    <!-- Header -->
    <jsp:include page='elements/header.jsp'/>

    <jsp:include page='elements/menu/module.jsp'/>
    <!-- chatbot -->
    <%--            <jsp:include page='chatbot/chat.jsp'/>--%>
    <!-- =============================================== -->
    <!-- Content -->
    <% try {%>
    <jsp:include page='<%=but%>'/>
    <% } catch (Exception e) {%>
    <script language="JavaScript"> alert('<%=HtmlUtils.escapeHtmlAccents(e.getMessage().toUpperCase()) %>');
    history.back();</script>
    <%
        }
    %>
    <!-- =============================================== -->
    <!-- Footer -->
    <!-- <jsp:include page='elements/footer.jsp'/> -->
    <!-- =============================================== -->
    <!-- Panel -->
    <jsp:include page='elements/panel.jsp'/>
    <!-- =============================================== -->
</div>
<!-- ./wrapper -->
<jsp:include page='elements/js.jsp'/>

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

<!-- Div flottant global amélioré -->
<%--        <div id="mon-div-flottant" style="--%>
<%--            position: fixed;--%>
<%--            bottom: 20px;--%>
<%--            right: 20px;--%>
<%--            width: 250px;--%>
<%--            background-color: #fff;--%>
<%--            border: 1px solid #ddd;--%>
<%--            border-radius: 8px;--%>
<%--            box-shadow: 0 4px 15px rgba(0,0,0,0.3);--%>
<%--            z-index: 9999;--%>
<%--            font-family: 'Open Sans', sans-serif;">--%>
<%--            <div id="drag-handle" style="--%>
<%--                padding: 10px;--%>
<%--                background-color: #007bff;--%>
<%--                color: white;--%>
<%--                border-radius: 8px 8px 0 0;--%>
<%--                cursor: move;--%>
<%--                font-weight: bold;--%>
<%--                display: flex;--%>
<%--                justify-content: space-between;--%>
<%--                align-items: center;">--%>
<%--                <span>&#128190; T&acirc;ches en cours</span>--%>
<%--                <button onclick="$('#timer-content').toggle()" style="background:none; border:none; color:white; cursor:pointer; font-weight: bold;">_</button>--%>
<%--            </div>--%>
<%--            <div id="timer-content" style="padding: 0; max-height: 300px; overflow-y: auto;">--%>
<%--                <ul id="timer-list" style="list-style: none; padding: 0; margin: 0;">--%>
<%--                    <li style="color: #666; font-style: italic; text-align: center; font-size: 12px; padding: 10px;">Chargement...</li>--%>
<%--                </ul>--%>
<%--            </div>--%>
<%--        </div>--%>
<script src="${pageContext.request.contextPath}/assets/js/timer-flottant.js"></script>
</body>
<script>
</script>
<style>
    .recap-table {
        font-size: 18px !important;
    }
    .filtre-btn {
        display: none !important;
    }
</style>
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