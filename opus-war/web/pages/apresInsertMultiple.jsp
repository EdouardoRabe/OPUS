<%-- 
    Document   : apresInsertMultiple
    Created on : 21 sept. 2016, 10:25:01
    Author     : Joe
--%>
<%@ page import="user.*" %>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="bean.*" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="affichage.*" %>
<%@ page import="utils.HtmlUtils" %>
<html>
    <%!
        UserEJB u = null;
        String acte = null;
        String lien = null;
        String bute;
        String nomtable;
    %>
    <%
        try {
            nomtable = request.getParameter("nomtable");
            lien = (String) session.getValue("lien");
            u = (UserEJB) session.getAttribute("u");
            acte = request.getParameter("acte");
            bute = request.getParameter("bute");
            Object temp = null;
            String classe = request.getParameter("classe");
            String classefille = request.getParameter("classefille");
            ClassMAPTable mere = null;
            ClassMAPTable fille = null;
            String val = "";
            String id = request.getParameter("id");
            String idmere = request.getParameter("idmere");
            String nombreDeLigne = request.getParameter("nombreLigne");
            String colonneMere = request.getParameter("colonneMere");
            int nbLine = UtilitaireAcade.stringToInt(nombreDeLigne);
            if (acte.compareToIgnoreCase("insert") == 0) {
                
                mere = (ClassMAPTable) (Class.forName(classe).newInstance());
                fille = (ClassMAPTable)(Class.forName(classefille).newInstance());

                PageInsertMultiple p = new PageInsertMultiple(mere, fille, request, nbLine);
                ClassMAPTable cmere = p.getObjectAvecValeur();
                ClassMAPTable[] cfille = p.getObjectFilleAvecValeur();
                for(int i = 0;i<cfille.length;i++){
                    cfille[i].setNomTable(nomtable);
                }
                temp = u.createObjectMultiple(cmere, colonneMere, cfille);
                if(temp != null){
                    val = temp.toString();
                }
            }
            if (acte.compareToIgnoreCase("deleteMultiple") == 0) {
                String error = "";
                
                fille = (ClassMAPTable) (Class.forName(classe).newInstance());
                fille.setValChamp(fille.getAttributIDName(), request.getParameter("idmultiple"));
                
                u.deleteObject(fille);
                
            }
            %>
            <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=UtilitaireAcade.champNull(idmere)%>");</script>
            <%
        } catch (Exception e) {
            e.printStackTrace();
            %>

            <script language="JavaScript"> 
                alert('<%=e.getMessage()%>');
                history.back();
            </script>
    <% return;}%>
</html>