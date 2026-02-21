<%-- 
    Document   : apresMultiple
    Created on : Oct 19, 2018, 2:55:36 PM
    Author     : Jerry
--%>
<%@page import="java.sql.Time"%>
<%@page import="java.sql.Date"%>
<%@page import="mg.mapping.configuration.Jourrepos"%>
<%@ page import="user.*" %>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="bean.*" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="affichage.*" %>
<%@ page import="utils.HtmlUtils" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
    <%!
        UserEJB u = null;
        String acte = null;
        String lien = null;
        String bute;
        String nomtable = null;
        String typeBoutton;
        String ben;
        String[] tId;
    %>
    <%
        try {
            ben = request.getParameter("nomtable");
            nomtable = request.getParameter("nomtable");
            typeBoutton = request.getParameter("type");
            lien = (String) session.getValue("lien");
            u = (UserEJB) session.getAttribute("u");
            acte = request.getParameter("acte");
            bute = request.getParameter("bute");
            Object temp = null;
            String[] rajoutLien = null;
            String classe = request.getParameter("classe");
            ClassMAPTable t = null;
            String tempRajout = request.getParameter("rajoutLien");
            String val = "";
            String id = request.getParameter("id");
            tId = request.getParameterValues("id");

            String nombreLigneS = request.getParameter("nombreLigne");
            int nombreLigne = UtilitaireAcade.stringToInt(nombreLigneS);

            String idmere = request.getParameter("idmere");
            String classefille = request.getParameter("classefille");
            ClassMAPTable mere = null;
            ClassMAPTable fille = null;
            String colonneMere = request.getParameter("colonneMere");
            String nombreDeLigne = request.getParameter("nombreLigne");
            int nbLine = UtilitaireAcade.stringToInt(nombreDeLigne);

            String rajoutLie = "";
            if (tempRajout != null && tempRajout.compareToIgnoreCase("") != 0) {
                rajoutLien = utilitaireAcade.UtilitaireAcade.split(tempRajout, "-");
            }
            if (bute == null || bute.compareToIgnoreCase("") == 0) {
                bute = "pub/Pub.jsp";
            }

            if (classe == null || classe.compareToIgnoreCase("") == 0) {
                classe = "pub.Montant";
            }

            if (typeBoutton == null || typeBoutton.compareToIgnoreCase("") == 0) {
                typeBoutton = "3"; //par defaut modifier
            }

            int type = UtilitaireAcade.stringToInt(typeBoutton);                   

                    if(nomtable.compareToIgnoreCase("tempstravail") == 0){
                        try{
                            String debutmatin = request.getParameter("debutmatin");
                            String finmatin = request.getParameter("finmatin");
                            String debutapresmidi = request.getParameter("debutapresmidi");
                            String finapresmidi = request.getParameter("finapresmidi");                        
                            if((debutmatin!=null) && (finmatin!=null) && (debutapresmidi!=null) && (finapresmidi!=null)){
                                Time dmatin, fmatin, dapresmidi, fapresmidi;
                                String[] hdebutmatin = debutmatin.split(":");   
                                String[] hfinmatin = finmatin.split(":");   
                                String[] hdebutapresmidi = debutapresmidi.split(":");   
                                String[] hfinapresmidi = finapresmidi.split(":");                            
                                if((Integer.valueOf(hdebutmatin[0])<0 || Integer.valueOf(hdebutmatin[0])>24) || (Integer.valueOf(hfinmatin[0])<0 || Integer.valueOf(hfinmatin[0])>24) || (Integer.valueOf(hdebutapresmidi[0])<0 || Integer.valueOf(hdebutapresmidi[0])>24) || (Integer.valueOf(hfinapresmidi[0])<0 || Integer.valueOf(hfinapresmidi[0])>24)){
                                    throw new Exception("Heure invalide");
                                }
                                if((Integer.valueOf(hdebutmatin[1])<0 || Integer.valueOf(hdebutmatin[1])>60) || (Integer.valueOf(hfinmatin[1])<0 || Integer.valueOf(hfinmatin[1])>60) || (Integer.valueOf(hdebutapresmidi[1])<0 || Integer.valueOf(hdebutapresmidi[1])>60) || (Integer.valueOf(hfinapresmidi[1])<0 || Integer.valueOf(hfinapresmidi[1])>60)){
                                    throw new Exception("Heure invalide");
                                } 
                                dmatin = new Time(Integer.valueOf(hdebutmatin[0]), Integer.valueOf(hdebutmatin[1]), 0);
                                fmatin = new Time(Integer.valueOf(hfinmatin[0]), Integer.valueOf(hfinmatin[1]), 0);
                                dapresmidi = new Time(Integer.valueOf(hdebutapresmidi[0]), Integer.valueOf(hdebutapresmidi[1]), 0);
                                fapresmidi = new Time(Integer.valueOf(hfinapresmidi[0]), Integer.valueOf(hfinapresmidi[1]), 0);
                                int test = 0;
                                if(dmatin.before(fmatin)){
                                    if(fmatin.before(dapresmidi)){
                                        if(dapresmidi.before(fapresmidi)){
                                            test = 1;
                                        }
                                    }
                                }
                                if(test!=1){
                                    throw new Exception("Ordre temps invalide");
                                }

                            }else{
                                throw new Exception("Champs vide");
                            }
                        }catch(Exception ex){
                            throw ex;
                        }                          
                    }                     
            
        if (acte.compareToIgnoreCase("insertFille") == 0) {
            fille = (ClassMAPTable)(Class.forName(classefille).newInstance());
            PageInsertMultiple p = new PageInsertMultiple(fille, request, nbLine, tId);
            ClassMAPTable[] cfille = p.getObjectFilleAvecValeur();
            for(int i = 0;i<cfille.length;i++){
                cfille[i].setNomTable(nomtable);
                Jourrepos jr = (Jourrepos)cfille[i];    
                try{
                    jr.verifier();
                }catch(Exception ex){
                        throw new Exception("Type de valeur invalide: "+ex.getMessage().replace('"', '\''));
                }
            }
            
            if (u.getUser().getIdrole().compareTo("Chef") == 0 || u.getUser().getIdrole().compareTo("admin") == 0 || u.getUser().getIdrole().compareTo("dg") == 0 || u.getUser().getIdrole().compareTo("adminFacture") == 0) {
                temp = u.createObjectMultiple(cfille);
                if(temp != null){
                    val = temp.toString();
                }            
            } else {
                throw new Exception("Erreur de droit");
            }
        }
        
        if (acte.compareToIgnoreCase("insert") == 0) {
            System.out.println("nomtable=" + nomtable + " " + "classe" + classe);
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            PageInsert p = new PageInsert(t, request);
            ClassMAPTable f = p.getObjectAvecValeur();
            f.setNomTable(nomtable);
            if (u.getUser().getIdrole().compareTo("Chef") == 0 || u.getUser().getIdrole().compareTo("admin") == 0 || u.getUser().getIdrole().compareTo("dg") == 0 || u.getUser().getIdrole().compareTo("adminFacture") == 0) {
            ClassMAPTable o = (ClassMAPTable) u.createObject(f);
            temp = (Object) o;
                if (o != null) {
                    id = o.getTuppleID();
                }
            } else {
                throw new Exception("Erreur de droit");
            } %>
            <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=id%>");</script>
        <% }        
        
        if (acte.compareToIgnoreCase("update") == 0) {
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            Page p = new Page(t, request);
            ClassMAPTable f = p.getObjectAvecValeur();
            System.out.println("apres getObjectAvecValeur");
            temp = f;
            if (nomtable != null) {
                f.setNomTable(nomtable);
            }
            System.out.println("before updateObject");
            if (u.getUser().getIdrole().compareTo("Chef") == 0 || u.getUser().getIdrole().compareTo("admin") == 0 || u.getUser().getIdrole().compareTo("dg") == 0 || u.getUser().getIdrole().compareTo("adminFacture") == 0) {
                u.updateObject(f);
            } else {
                throw new Exception("Erreur de droit");
            }
        }
        
        if (acte.compareToIgnoreCase("delete") == 0) {
            String error = "";
            try {
                t = (ClassMAPTable) (Class.forName(classe).newInstance());
                t.setValChamp(t.getAttributIDName(), request.getParameter("id"));
                if (nomtable != null && !nomtable.isEmpty()) {
                    t.setNomTable(nomtable);
                }
                if (u.getUser().getIdrole().compareTo("Chef") == 0 || u.getUser().getIdrole().compareTo("admin") == 0 || u.getUser().getIdrole().compareTo("dg") == 0 || u.getUser().getIdrole().compareTo("adminFacture") == 0) {
                    u.deleteObject(t);
                } else {
                throw new Exception("Erreur de droit");
                }
            } catch (Exception e) {
    %>
    <script language="JavaScript">alert('<%=HtmlUtils.escapeHtmlAccents(e.getMessage())%>');</script>
    <%
        }
    %>
    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute + rajoutLie%>");</script>
    <%
        }        

        System.out.println("acte: " + acte);
//        if (acte.compareToIgnoreCase("corriger") == 0) {
//
//            String[] listeVirement = request.getParameterValues("id");
//            u.corrigerVirement(listeVirement);
//        }

        if (rajoutLien != null) {

            for (int o = 0; o < rajoutLien.length; o++) {
                String valeur = request.getParameter(rajoutLien[o]);
                rajoutLie = rajoutLie + "&" + rajoutLien[o] + "=" + valeur;

            }

        }
    %>
    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>");</script>
    <%

    } catch (Exception ex) {
        ex.printStackTrace();
    %>
    <script type="text/javascript">alert("<%=ex.getMessage()%>"); history.back();</script>
    <%
            return;
        }%>
</html>



