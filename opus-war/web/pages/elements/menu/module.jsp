<%@page import="menu.MenuDynamique"%>
<%@page import="java.util.ArrayList"%>
<%@page import="utilisateur.UserMenu"%>
<%@page import="bean.CGenUtil"%>
<%@page import="user.UserEJB"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.ResourceBundle"%>

<%
    HttpSession sess = request.getSession();
    String lang = "fr"; 
    if(sess.getAttribute("lang")!=null){
        lang = String.valueOf(sess.getAttribute("lang"));
    }
    ResourceBundle RB = ResourceBundle.getBundle("text", new Locale(lang));

    if (request.getParameter("currentMenu") != null && request.getParameter("currentMenu") != "") {
        session.setAttribute("currentMenu", request.getParameter("currentMenu"));
    }
    String currentMenu = (String) request.getSession().getAttribute("currentMenu");
    UserEJB u = (UserEJB) session.getAttribute("u");
    ArrayList<ArrayList<MenuDynamique>> arbre = null;
    if (session.getAttribute("MENU") == null) {
        arbre = MenuDynamique.getElementMenu(request, u.getUser());
        session.setAttribute("MENU", arbre);
    } else {
        arbre = (ArrayList<ArrayList<MenuDynamique>>) session.getAttribute("MENU");
    }
    MenuDynamique[] tabMenu = null;
    if (request.getServletContext().getAttribute("tabMenu") != null) {
        tabMenu = (MenuDynamique[]) request.getServletContext().getAttribute("tabMenu");
    }
%>

<%
    String lien = (String) session.getValue("lien");
%>
<div style="background-color:rgba(28,38,61,255);  ">
    <aside class="main-sidebar">
        <section class="sidebar">
            <!-- sidebar menu: : style can be found in sidebar.less -->
            <ul class="sidebar-menu" id="menuslider">
                <%=MenuDynamique.renderMenu(arbre, currentMenu, tabMenu)%>              
            </ul>
        </section>
        <!-- /.sidebar -->
<%--        <img src="${pageContext.request.contextPath}/assets/img/Logo-Async-Footer.png" >--%>
    </aside>
</div>