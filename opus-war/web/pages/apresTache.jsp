<%-- 
    Document   : apresInsertMultiple
    Created on : 21 sept. 2016, 10:25:01
    Author     : Joe
--%>
<%@page import="mg.mapping.TacheMere"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="mg.mapping.Tache"%>
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
        Timestamp dateDebut=null, dateFin=null;
        String[] tId;
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
            Tache o = null;
            String val = "";
            String id = request.getParameter("id");
            Tache t=(Tache) new Tache().getById(id, "", null);
            ClassMAPTable mere = null;
            ClassMAPTable fille = null;   
            String classefille = request.getParameter("classefille");            
            String nombreDeLigne = request.getParameter("nombreLigne");
            int nbLine = UtilitaireAcade.stringToInt(nombreDeLigne);            
            tId = request.getParameterValues("id");
            String colonneMere = request.getParameter("colonneMere");
            String idmere = request.getParameter("idmere");
                       
            if (acte.compareToIgnoreCase("debut") == 0) {
                dateDebut=t.getDebut();
                if (dateDebut==null){
                    o = (Tache) (Class.forName(classe).newInstance());
                    o.setId(id);                    
                    o.debut(u,null);                         
                }
            }
            if (acte.compareToIgnoreCase("fin") == 0) {
                dateFin=t.getFin();
                if(dateFin==null){
                  o = (Tache) (Class.forName(classe).newInstance());
                  o.setId(id);                  
                  o.fin(u,null); 
                }

            }
      
            if(acte.compareToIgnoreCase("attribue") == 0){
                o = (Tache) (Class.forName(classe).newInstance());
                o.setId(id);
                String idUtilisateur = request.getParameter("idutilisateur");
                o.setResponsable(idUtilisateur);
                o.attribuer(u,null);
            }
            if(acte.compareToIgnoreCase("cloturerGenerer") == 0){
                TacheMere tachemere = t.cloturerGenerer(u, null);
                if(tachemere != null) id = tachemere.getId();
            }
            if(acte.compareToIgnoreCase("deployer") == 0){
                o = (Tache) (Class.forName(classe).newInstance());
                o.setId(id);
                o.deployer(u,null);
            }
            if(acte.compareToIgnoreCase("deployertachemere") == 0){
                TacheMere tachemere = (TacheMere)(Class.forName(classe).newInstance());
                tachemere.setId(id);
                tachemere.deployer(u,null);
            }
            if (acte != null && acte.compareToIgnoreCase("insert") == 0) {
                mere = (ClassMAPTable) (Class.forName(classe).newInstance());
                fille = (ClassMAPTable) (Class.forName(classefille).newInstance());
                PageInsertMultiple p = new PageInsertMultiple(mere, fille, request, nbLine, tId);
                ClassMAPTable cmere = p.getObjectAvecValeur();
                
                ClassMAPTable[] cfille = p.getObjectFilleAvecValeur();
                for (int i = 0; i < cfille.length; i++) {
                    cfille[i].setNomTable(nomtable);
                }
                ClassMAPTable obj = (ClassMAPTable) u.createObjectMultiple(cmere, colonneMere, cfille);
                temp = (Object) obj;
                if (temp != null) {
                    val = temp.toString();
                    idmere = obj.getTuppleID();
                }
                
    %>
    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=idmere%>");</script>
    <% }            

            %>
            <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=UtilitaireAcade.champNull(id)%>");</script>
            <%
        } catch (Exception e) {
            e.printStackTrace();
            %>

            <script language="JavaScript"> 
                alert("<%=e.getMessage()%>");
                history.back();
            </script>
    <% return;}%>
</html>