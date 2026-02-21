<%-- 
    Document   : apresInsertMultiple
    Created on : 21 sept. 2016, 10:25:01
    Author     : Joe
--%>
<%@page import="mg.mapping.NotificationLib"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="mg.mapping.Notification"%>
<%@page import="java.util.concurrent.TimeUnit"%>
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
            String val = "";
            String id = request.getParameter("id");
            Tache t= null;
            
            if(classe!=null && classe.compareToIgnoreCase("mg.mapping.Tache") == 0){
                t = (Tache) new Tache().getById(id, "", null);                
            }

            
            if (acte.compareToIgnoreCase("debut") == 0) {
                dateDebut=t.getDebut();
                if (dateDebut==null){   
                    t.debutSignale(u,null);                                             
                }
            }
            if (acte.compareToIgnoreCase("pause") == 0) {
                dateDebut=t.getDebut();
                if (dateDebut!=null){
                    t.pauseSignale(String.valueOf(u.getUser().getRefuser()),null);
                }
            }
            if (acte.compareToIgnoreCase("relancer") == 0) {
                dateDebut=t.getDebut();
                if (dateDebut!=null){
                    t.relancerSignale(u,null);
                }
            }
            if (acte.compareToIgnoreCase("fin") == 0) {
                dateFin=t.getFin();
                if(dateFin==null){
                  t.setEtat(1);
                  String hsup = request.getParameter("hsup");                    
                  if(hsup!=null){
                      t.setEtat(7);
                  }
                  t.finSignale(u,null); 
                }

            }            
            
        if (acte.compareToIgnoreCase("rappel") == 0) {     // RAPPEL NOTIF
            Timestamp rap = new Timestamp(System.currentTimeMillis());
            String idrappel = request.getParameter("idrappel");
            String rappel1 = request.getParameter("rappel1");
            String rappel2 = request.getParameter("rappel2");
            if(idrappel == null){
                throw new Exception("Rappel invalide");
            }

            if(idrappel.compareToIgnoreCase("temps") == 0){
                try{
                    long valeurrappel = Long.valueOf(rappel1);
                    long ajout = 0;
                    if(rappel2.compareToIgnoreCase("m") == 0){
                        ajout = TimeUnit.MINUTES.toMillis(valeurrappel);
                    }
                    else if(rappel2.compareToIgnoreCase("h") == 0){
                        ajout = TimeUnit.HOURS.toMillis(valeurrappel);
                    }
                    else if(rappel2.compareToIgnoreCase("j") == 0){
                        ajout = TimeUnit.DAYS.toMillis(valeurrappel);
                    }
                    else{
                        throw new Exception("Unite non valide");
                    }
                    if(ajout<=0){
                        throw new Exception("Valeur null ou negative invalide");
                    }
                    rap.setTime(rap.getTime()+ajout);
                }catch(Exception ex){
                    throw new Exception("Valeur de rappel invalide");
                }
            }else if(idrappel.compareToIgnoreCase("date") == 0){
                String valeurrappel = rappel1+" "+rappel2+":00.000";
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss.SSS");
                try{
                    Date parsedDate = dateFormat.parse(valeurrappel);
                    try{
                        String[]heures = rappel2.split(":");   
                        int h = Integer.valueOf(heures[0]);
                        int m = Integer.valueOf(heures[1]);
                        if(h<0 || h>24){
                            throw new Exception("Heure invalide");
                        }        
                        if(m<0 || m>60){
                            throw new Exception("Heure invalide");
                        }
                    }catch(Exception ex){
                        throw ex;
                    }                    
                    Timestamp tmp = new Timestamp(parsedDate.getTime());
                    rap.setTime(tmp.getTime());                    
                }catch(Exception ex){
                    throw new Exception("Date/heure invalide");
                }
            }else{
                throw new Exception("Rappel invalide");
            }

            Notification notif = (Notification)t.createNotifTacheRappel(new Integer(u.getUser().getRefuser()).toString(), null, rap);
        }
        
            if (acte.compareToIgnoreCase("signal") == 0) {
                  if(request.getParameter("signal") != null){
                        t.createSignal(new Integer(u.getUser().getRefuser()).toString(), null, request.getParameter("signal"));      
                  }                  
            } 

        if (acte.compareToIgnoreCase("vu") == 0) {     // VU NOTIF
            Notification notif = (Notification) (Class.forName(classe).newInstance());
            notif.setValChamp(notif.getAttributIDName(), request.getParameter("id"));
            notif.setNomTable(nomtable);
            ClassMAPTable o = notif.vu(u, null);
            temp = notif;
            val = o.getTuppleID();%>
            <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=request.getParameter("ref")%>");</script>
            <%
        }

        if (acte.compareToIgnoreCase("toutvu") == 0) {     // TOUT VU NOTIF
            Notification notif = new Notification();
            notif.setNomTable("notification");
            String where = " and receiver = '%s' and etat = 1";
            where = String.format(where, (new Integer(u.getUser().getRefuser())).toString());
            Notification[]mesnotifs = (Notification[])CGenUtil.rechercher(notif, null, null, where);
            notif.vu(u, null, mesnotifs);
            %>
            <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&receiver=<%=u.getUser().getRefuser()%>");</script>
            <%
        }
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