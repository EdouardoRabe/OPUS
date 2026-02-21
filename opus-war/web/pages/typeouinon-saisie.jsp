<%@page import="affichage.Liste"%>
<%@page import="bean.TypeObjet"%>
<%@page import="affichage.PageInsert"%>
<%@page import="utilitaireAcade.UtilitaireAcade"%>
<%@ page import="constanteAcade.ConstanteAcade" %>
<%@ page import="affichage.PageInsertMultiple" %>
<%@ page import="utils.TypeOuiNon" %>
<%
    try {
        String autreparsley = "data-parsley-range='[8, 40]' required";
        TypeOuiNon tpcs = new TypeOuiNon();
        PageInsert pi = new PageInsert(tpcs, request, (user.UserEJB) session.getValue("u"));
        pi.setLien((String) session.getValue("lien"));
        pi.getFormu().getChamp("val").setLibelle("Valeur");
        pi.getFormu().getChamp("desce").setLibelle("Description");
        pi.preparerDataFormu();
%>
<style>
    /* Description editor styling */
    .description-editor-wrapper { margin: 10px 0; }
    .description-editor-toolbar { display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin-bottom:8px; }
    .description-editor-toolbar input[type="button"], .description-editor-toolbar button { padding:6px 8px; border:1px solid #ccc; background:#f7f7f7; border-radius:4px; cursor:pointer; }
    .description-editor-toolbar input[type="color"] { width:34px; height:34px; padding:0; border:none; background:transparent; cursor:pointer; }
    .description-editor-toolbar label { margin:0 4px; font-weight:600; }
    .description-editor-toolbar input[type="file"] { display:inline-block; }
    #editor_0 { border:1px solid #ddd; min-height:140px; padding:8px; border-radius:4px; background-color:#fff; overflow:auto; }
    #editor_0:focus { outline:2px solid #cce5ff; }
    .description-editor-toolbar input[type="text"] { width:60px; padding:6px; border:1px solid #ccc; border-radius:4px; }
    .description-editor-toolbar select { padding:6px; border:1px solid #ccc; border-radius:4px; }
    .description-editor-toolbar input[type="file"] { max-width:200px; }
</style>

<div class="content-wrapper">
    </br>
    <h1 align="center">Type Champ Speciaux Saisie</h1>
    <form action="<%=pi.getLien()%>?but=apresTarif.jsp" method="post" name="sortie" id="sortie" data-parsley-validate>
        <%
            pi.getFormu().makeHtmlInsertTabIndex();
            out.println(pi.getFormu().getHtmlInsert());
        %>
        <input name="acte" type="hidden" id="acte" value="insert">
        <input name="bute" type="hidden" id="bute" value="typeouinon-fiche.jsp">
        <input name="classe" type="hidden" id="classe" value="utils.TypeOuiNon">
    </form>
</div>
<%
} catch (Exception e) {
    e.printStackTrace();
%>
<script language="JavaScript"> alert('<%=e.getMessage()%>');
history.back();
</script>

<%
    }
%>