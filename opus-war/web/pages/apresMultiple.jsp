<%--
    Document   : apresMultiple
    Created on : Oct 19, 2018, 2:55:36 PM
    Author     : Jerry
--%>
<%@ page import="user.*" %>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="bean.*" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="affichage.*" %>
<%@ page import="utils.HtmlUtils" %>
<%@ page import="java.sql.Connection" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <meta charset="UTF-8">
    <link href="${pageContext.request.contextPath}/dist/css/swal.css" rel="stylesheet" type="text/css" />
    <script src="${pageContext.request.contextPath}/dist/js/swal.js"></script>
</head>
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
            System.out.println("Acte oo == ");
            System.out.println(acte);

            bute = request.getParameter("bute");
            Object temp = null;
            String[] rajoutLien = null;
            String classe = request.getParameter("classe");
            ClassMAPTable t = null;
            String tempRajout = request.getParameter("rajoutLien");
            String val = "";
            String id = request.getParameter("id");
            tId = request.getParameterValues("ids");

            String nombreLigneS = request.getParameter("nombreLigne");
            int nombreLigne = UtilitaireAcade.stringToInt(nombreLigneS);

            String idmere = request.getParameter("idmere");
            String classefille = request.getParameter("classefille");
            ClassMAPTable mere = null;
            ClassMAPTable fille = null;
            String colonneMere = request.getParameter("colonneMere");
            String nombreDeLigne = request.getParameter("nombreLigne");
            int nbLine = UtilitaireAcade.stringToInt(nombreDeLigne);
            String colid = request.getParameter("colid");

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

            if (acte != null && acte.compareToIgnoreCase("insert") == 0) {
                mere = (ClassMAPTable) (Class.forName(classe).newInstance());
                fille = (ClassMAPTable) (Class.forName(classefille).newInstance());
                PageInsertMultiple p = new PageInsertMultiple(mere, fille, request, nbLine, tId);
                ClassMAPTable cmere = p.getObjectAvecValeur();
                ClassMAPTable[] cfille = p.getObjectFilleAvecValeur();
                for (int i = 0; i < cfille.length; i++) {
                    if (cfille[i]!=null){
                        cfille[i].setNomTable(nomtable);
                    }
                }

                ClassMAPTable o = (ClassMAPTable) u.createObjectMultiple(cmere, colonneMere, cfille);
                temp = (Object) o;
                if (temp != null) {
                    val = temp.toString();
                    idmere = o.getTuppleID();


                }

                if(colid != null && !colid.isEmpty()){%>
                    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&<%=colid%>=<%=idmere%>");</script>
                <%}
    %>

    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&<%= mere.getAttributIDName()%>=<%=idmere%>");</script>
    <% }

        if (acte != null && acte.compareToIgnoreCase("updateInsert") == 0) {
            mere = (ClassMAPTable) (Class.forName(classe).newInstance());
            fille = (ClassMAPTable) (Class.forName(classefille).newInstance());
            PageUpdateMultiple p = new PageUpdateMultiple(mere, fille, request, nbLine, tId);
            ClassMAPTable cmere = p.getObjectAvecValeur();
            ClassMAPTable[] cfille = p.getObjectFilleAvecValeur();
            /*for (int i = 0; i < cfille.length; i++) {
                cfille[i].setNomTable(nomtable);
            }*/
            ClassMAPTable o = (ClassMAPTable) u.updateObjectMultiple(cmere, colonneMere, cfille);
            temp = (Object) o;
            if (temp != null) {
                val = temp.toString();
                idmere = o.getTuppleID();
            }%>
    %>
    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=idmere%>");</script>
    <% }

        if (acte != null && acte.compareToIgnoreCase("updateMultiple") == 0) {
            System.out.println("miditra");
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            Page p = new Page(t, request, nombreLigne, tId);
            ClassMAPTable[] f = p.getObjectAvecValeurTableauUpdate();
            u.updateObjectMultiple(f);
        }

        if (acte != null && acte.compareToIgnoreCase("insertFille") == 0) {
            fille = (ClassMAPTable)(Class.forName(classefille).newInstance());
            PageInsertMultiple p = new PageInsertMultiple(fille, request, nbLine, tId);
            ClassMAPTable[] cfille = p.getObjectFilleAvecValeur();
            for(int i = 0;i<cfille.length;i++){
                cfille[i].setNomTable(nomtable);
            }
            for (int i = 0; i < cfille.length; i++) {
                System.out.println("cfilletestttt!!!!!![" + i + "] = " + cfille[i]);
            }


            temp = u.createObjectMultiple(cfille);
            if(temp != null){
                val = temp.toString();
            }


        }

        if (acte != null && acte.compareToIgnoreCase("insertUpdateFille") == 0) {
            mere = (ClassMAPTable) (Class.forName(classe).newInstance());
            fille = (ClassMAPTable) (Class.forName(classefille).newInstance());
            PageUpdateMultiple p = new PageUpdateMultiple(mere, fille, request, nbLine, tId);
            ClassMAPTable[] cfille = p.getObjectFilleAvecValeur();
            for(int i = 0;i<cfille.length;i++){
                cfille[i].setNomTable(nomtable);
            }
            ClassMAPTable[]o = (ClassMAPTable[]) u.updateInsertObjectMultiple(cfille);   %>
    %>
    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&<%= mere.getAttributIDName()%>=<%=idmere%>");</script>

    <% }if (acte != null && acte.compareToIgnoreCase("insertFilleSeul") == 0) {

        mere = (ClassMAPTable) (Class.forName(classe).newInstance());
        fille = (ClassMAPTable) (Class.forName(classefille).newInstance());
        PageInsertMultiple p = new PageInsertMultiple(mere, fille, request, nbLine, tId);
        ClassMAPTable[] cfille = p.getObjectFilleAvecValeur();
        for (int i = 0; i < cfille.length; i++) {
            cfille[i].setNomTable(nomtable);
        }
        u.createObjectFilleMultipleSansMere(String.valueOf(u.getUser().getRefuser()),cfille);
    %>

    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&<%= mere.getAttributIDName()%>=<%=idmere%>");</script>
    <% }

       //System.out.println("acte: " + acte);

        if (acte != null && acte.compareToIgnoreCase("deleteFille") == 0) {

            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            t.setValChamp(t.getAttributIDName(), request.getParameter("id"));
            temp = (Object) t;
            u.deleteObjetFille(t);
        }

        /**
         * ********************************************
         */
        /**
         * ********************************************
         */
        if (acte != null && acte.compareToIgnoreCase("attacher") == 0) {
            System.out.println("--------------- BOUTON VALIDER");
            for (int i = 0; i < tId.length; i++) {
                System.out.println("--------------- " + tId[i]);
                t = (ClassMAPTable) (Class.forName(classe).newInstance());
                System.out.println("t--------------- " + t);
                System.out.println("nomtable--------------- " + nomtable);
                t.setValChamp(t.getAttributIDName(), tId[i]);
                t.setNomTable(nomtable);
                ClassMAPTable o = (ClassMAPTable) u.validerObject(t);
                System.out.println("VITA " + tId[i]);
            }
        }
        if (acte != null && acte.compareToIgnoreCase("delete") == 0) {
            String error = ""; %>
    <%//if(request.getParameter("confirm") != null){
        try {
            //System.out.println("suppression : " + request.getParameter("confirm") + " nom table : " + nomtable);
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            t.setValChamp(t.getAttributIDName(), request.getParameter("id"));
            if (nomtable != null && !nomtable.isEmpty()) {
                t.setNomTable(nomtable);
            }
            u.deleteObject(t);
        } catch (Exception e) {%>
    <script language="JavaScript">alert('<%=e.getMessage()%>');
        history.back();</script>
        <%
            }
            //                }else{%>
    <!--<script language="JavaScript">
//                    if (confirm("Voulez-vous vraiment supprimer ?")) { // Clic sur OK
//                        var url = window.location.href;
//                        url = url+"&confirm=oui";
//                        window.location.replace(url);
//                        //alert("url : "+url);
//                    } else{
//                        var url = document.referrer;
//                        window.location.replace(url);
//                    }
    </script>-->
    <%//  }
        }
        if (acte != null && acte.compareToIgnoreCase("insertTypeObjet") == 0) {
            String[] vals = null;
            String[] desce = null;
            String nomTable = request.getParameter("nomtable");
            String nomProcedure = request.getParameter("procedure");
            String startProcedure = request.getParameter("prefixe");
            if (request.getParameter("nbrLigne") != null) {
                int taille = UtilitaireAcade.stringToInt(request.getParameter("nbrLigne"));
                vals = new String[taille];
                desce = new String[taille];
                for (int i = 0; i < taille; i++) {
                    vals[i] = request.getParameter("val_" + (i + 1));
                    desce[i] = request.getParameter("desce_" + (i + 1));
                }
            }
            u.createTypeObjetMultiple(nomTable, nomProcedure, startProcedure, vals, desce);
        }
        if (acte != null && acte.compareToIgnoreCase("update") == 0) {
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            Page p = new Page(t, request);
            ClassMAPTable f = p.getObjectAvecValeur();
            temp = f;
            if (nomtable != null) {
                f.setNomTable(nomtable);
            }

            u.updateObject(f);
        }
        if (acte != null && acte.compareToIgnoreCase("dupliquer") == 0) {
            String classeFille = request.getParameter("nomClasseFille");
            String nomColonneMere = request.getParameter("nomColonneMere");
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            t.setValChamp(t.getAttributIDName(), request.getParameter("id"));
            Object o = u.dupliquerObject(t, classeFille, nomColonneMere);
            val = o.toString();
    %>
    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=val%>");</script>
    <%
        }
        if (acte != null && acte.compareToIgnoreCase("annuler") == 0) {
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            t.setValChamp(t.getAttributIDName(), request.getParameter("id"));
            u.annulerObject(t);
        }
        if (acte != null && acte.compareToIgnoreCase("annulerVisaMultiple") == 0) {
            String[] tId = request.getParameterValues("id");
            for (int i = 0; i < tId.length; i++) {
                t = (ClassMAPTable) (Class.forName(classe).newInstance());
                t.setValChamp(t.getAttributIDName(), tId[i]);
                temp = t;
                u.annulerVisa(t);
            }

    %>
    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>");</script>
    <%
        }
        if (acte != null && acte.compareToIgnoreCase("annulerVisa") == 0) {
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            t.setValChamp(t.getAttributIDName(), request.getParameter("id"));
            temp = t;
            u.annulerVisa(t);
        }
        if (acte != null && acte.compareToIgnoreCase("finaliser") == 0) {
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            t.setValChamp(t.getAttributIDName(), request.getParameter("id"));
            temp = t;
            u.finaliser(t);
        }

        if (acte != null && acte.compareToIgnoreCase("valider") == 0) {     // VISER
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            t.setValChamp(t.getAttributIDName(), request.getParameter("id"));
            ClassMAPTable o = (ClassMAPTable) u.validerObject(t);
            temp = t;
            val = o.getTuppleID();

    %>
    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute + rajoutLie%>&id=<%=val%>");</script>
    <%
        }
        if (acte != null && acte.compareToIgnoreCase("rejeter") == 0) {
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            PageInsert p = new PageInsert(t, request);
            ClassMAPTable f = p.getObjectAvecValeur();
            t.setNomTable(nomtable);
            t.setValChamp(t.getAttributIDName(), request.getParameter("id"));
            //u.rejeterObject(t);
        }
        if (acte != null && acte.compareToIgnoreCase("cloturer") == 0) {
            t = (ClassMAPTable) (Class.forName(classe).newInstance());
            t.setValChamp(t.getAttributIDName(), request.getParameter("id"));

            u.cloturerObject(t);
        }

        if (acte != null && acte.compareToIgnoreCase("deleteMultiple") == 0) {
            u.deleteMultiple(tId, classe,nomtable,null);
    %>
    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=idmere%>");</script>
    <%
        }
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
    <script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute + rajoutLie%>&valeur=<%=val%>&id=<%=id%>");</script>
    <%

    } catch (Exception ex) {
        ex.printStackTrace();
    %>
<%--    <script type="text/javascript">--%>
<%--        alert("<%=ex.getMessage()%>");--%>
<%--        history.back();--%>
<%--    </script>--%>

    <script type="text/javascript">
        console.log("GEGE");
        Swal.fire({
            title: "Oups !",
            html: "<strong><%= HtmlUtils.escapeHtmlAccents(ex.getMessage()) %></strong>",
            icon: "error",
            confirmButtonText: "OK"
        }).then((result) => {
            if (result.isConfirmed) {
                history.back();
            }
        });
    </script>


<%
            return;
        }%>
</html>



