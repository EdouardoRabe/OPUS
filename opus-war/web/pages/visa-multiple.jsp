<%@page import="bean.ClassMAPTable"%>
<%@page import="user.UserEJB"%>
<%@ page import="user.*" %>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="bean.*" %>
<%@ page import="java.sql.SQLException" %>
<%
    String[] val = request.getParameterValues("id");
    if (val == null || val.length == 0) {
        throw new Exception("Vous devez  cocher au moins un element");
    }
    String nomTableRejet = request.getParameter("nomTableRejet");
    String nomTableCategorieRejet = request.getParameter("nomTableCategorieRejet");
    UserEJB u = (user.UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String bute = request.getParameter("bute");
    String classe = request.getParameter("classe");
    String acte = request.getParameter("acte");
    String etatMere = request.getParameter("etatMere");
    String table = request.getParameter("nomTable");
    ClassEtat t = null;
    
    try {

        if (acte.compareToIgnoreCase("viser") == 0) {
            t = (ClassEtat) (Class.forName(classe).newInstance());
            t.setNomTable(table);
            u.viserObjectMultiple(t, val);
        }
%>
<script language="JavaScript">
    document.location.replace("<%=lien%>?but=<%=bute%>");
</script>
<%
} catch (Exception e) {
    e.printStackTrace();
%>
<script>
    alert('<%=e.getMessage()%>');
    history.back();
</script>
<% } %>