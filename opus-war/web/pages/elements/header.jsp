<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page import="bean.CGenUtil"%>
<%@page import="historique.MapUtilisateur"%>

<%@page import="user.UserEJB"%>
<%
    String lien = (String) session.getValue("lien");
    UserEJB ue = (UserEJB) session.getValue("u");
    MapUtilisateur map = ue.getUser();
    /*NotificationLib notif = new NotificationLib();
    notif.setNomTable("notificationLibNonLu");
    String where = " and receiver = '%s' order by etat asc, daty desc, heure desc";
    where = String.format(where, ue.getUser().getRefuser());
    NotificationLib[]mesnotifs = (NotificationLib[])CGenUtil.rechercher(notif, null, null, where);
    int limit = 5;
    if(mesnotifs.length <5){
        limit = mesnotifs.length;
    }*/
%>
        <script>          

        function verifEditerTef(et,name){
        if(et<11){
                alert('Impossible d\'editer Tef. '+name+' non vis� ');
        }else{
            document.tef.submit();
                
            }
        }
        function verifLivraisonBC(et){
        if(et<11){
                alert('Impossible d effectuer la livraison du bon de commande');
        }else{
            document.tef.submit();
                
            }
        }
        function CocherToutCheckBox(ref, name) {
            var form = ref;

            while (form.parentNode && form.nodeName.toLowerCase() != 'form') {
                form = form.parentNode;
            }

            var elements = form.getElementsByTagName('input');

            for (var i = 0; i < elements.length; i++) {
                if (elements[i].type == 'checkbox' && elements[i].name == name) {
                    elements[i].checked = ref.checked;
                }
            }
        }
        
        </script>
<header class="main-header" style="position: fixed; left: 0; right: 0;">
    <!-- Logo -->
	<div>
		<a href="<%= lien %>?but=accueil.jsp" class="logo" style="background-color:var(--Background-primaire);color: var(--Text-primary);">
            <span class="logo-mini" style="color:#333;font-weight: 600;">
                <img style="width: auto;height:42px;" src="${pageContext.request.contextPath}/assets/img/logo.png"/>
            </span>
            <!-- logo for regular state and mobile devices -->
            <span class="logo-lg">

                <img style="width: auto;height:42px;" src="${pageContext.request.contextPath}/assets/img/logo.png"/>
            </span>
        </a>
	</div>
    <!-- Header Navbar: style can be found in header.less -->
    <nav class="navbar navbar-static-top" role="navigation">
        <!-- Sidebar toggle button-->
        <button class="sidebar-toggle" style="background:none;border:none;cursor:pointer;color:var(--Text-primary)"
                data-toggle="offcanvas" role="button" aria-label="Toggle navigation">

            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 12 13" fill="none">
                <path
                        d="M9.05 8.1828V4.84946C9.05 4.73924 8.99722 4.66446 8.89167 4.62513C8.78611 4.58579 8.69444 4.60502 8.61667 4.6828L7.13333 6.16613C7.03333 6.26613 6.98333 6.3828 6.98333 6.51613C6.98333 6.64946 7.03333 6.76613 7.13333 6.86613L8.61667 8.34946C8.69444 8.42724 8.78611 8.44646 8.89167 8.40713C8.99722 8.3678 9.05 8.29302 9.05 8.1828ZM1 12.5161C0.725 12.5161 0.489611 12.4182 0.293833 12.2223C0.0979445 12.0265 0 11.7911 0 11.5161V1.51613C0 1.24113 0.0979445 1.00568 0.293833 0.809795C0.489611 0.614017 0.725 0.516129 1 0.516129H11C11.275 0.516129 11.5104 0.614017 11.7063 0.809795C11.9021 1.00568 12 1.24113 12 1.51613V11.5161C12 11.7911 11.9021 12.0265 11.7063 12.2223C11.5104 12.4182 11.275 12.5161 11 12.5161H1ZM3.45 11.5161V1.51613H1V11.5161H3.45ZM4.45 11.5161H11V1.51613H4.45V11.5161Z"
                        fill="currentColor" />
            </svg>
        </button>
        <div class="recherche-global " >
            <form action="<%=lien%>" method="GET" >
                <div class="form-input col-md-12 form-input-apj recherche-global-container ">
                    <label class="Body14pxRegular" style="margin-right: 10px;white-space: nowrap;">Recherche Globale</label>
                    <input value="recherche-global.jsp" name="but" type="hidden">
                    <div style="position: relative; flex: 1;width: 100%">
                        <input name="remarque" type="text" class="form-control global-search-input" style="height: 28px; padding-right: 30px;"
                               onkeydown="if(event.key === 'Enter'){ event.preventDefault(); this.form.submit(); }">
                        <span onclick="this.parentNode.querySelector('input[name=remarque]').form.submit();" style="position: absolute; right: 8px; top: 50%; transform: translateY(-50%); color: #aaa;">
                                    <i class="fa fa-search"></i>
                                </span>
                    </div>
                </div>
            </form>
        </div>
<%--        <div class="navbar-custom-menu">--%>
<%--            <ul class="nav navbar-nav">--%>
<%--                <!-- Messages: style can be found in dropdown.less-->--%>
<%--                <!--<li class="dropdown messages-menu">--%>
<%--                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" onclick="loadMessageHeader()">--%>
<%--                        <i class="fa fa-envelope-o"></i>--%>
<%--                        <//%if (0 == 0) {%>--%>
<%--                        <span class="label label-success" id="nb-inbox"><//%=0%></span>--%>
<%--                        <//%} else {%>--%>
<%--                        <span class="label label-success" id="nb-inbox"></span>--%>
<%--                        <//%}%>--%>

<%--                    </a>--%>
<%--                    <ul class="dropdown-menu" id="message-listcontent-header">--%>
<%--                        <li class="header">Vous avez <span id="inbox"><//%=0%></span> message(s)--%>
<%--                            <span class="btn btn-default pull-right" style="position: absolute; top: 0; right: 5px;" data-toggle="modal" data-target="#modalSendMessageTo"><i class="fa fa-plus"></i></span></li>--%>
<%--                        <!--                        <a title="Nouveau message">--%>
<%--                                                    <i class="fa fa-plus-square-o"></i>--%>
<%--                                                </a>-->--%>
<%--                        <!--<li>--%>
<%--                            <!-- inner menu: contains the actual data -->--%>
<%--                            <!--<ul class="menu" id="message-list-header">--%>

<%--                            </ul>--%>
<%--                        </li>--%>
<%--                        <li class="footer"><a href="#">Tous les Messages</a></li>--%>
<%--                    </ul>--%>
<%--                </li>-->--%>
<%--                <!-- Notifications: style can be found in dropdown.less -->--%>
<%--                <!--<li class="dropdown notifications-menu">--%>
<%--                    <a href="<//%= lien %>?but=notification/notification-liste.jsp" class="dropdown-toggle">--%>
<%--                        <i class="fa fa-bell-o"></i>--%>
<%--                        <span class="label label-danger"><//% if(0 >0 ) { %> <//%=0%> <//% }%></span>--%>
<%--                    </a>--%>
<%--                    <!--<ul class="dropdown-menu">--%>
<%--                        <li class="header">Vous avez 2 notifications</li>--%>
<%--                        <li>--%>
<%--                            <ul class="menu">--%>
<%--                                <li>--%>
<%--                                    <a href="#">--%>
<%--                                        <i class="fa fa-users text-aqua"></i> 2 nouveaux dossiers--%>
<%--                                    </a>--%>
<%--                                </li>--%>
<%--                                <li>--%>
<%--                                    <a href="#">--%>
<%--                                        <i class="fa fa-users text-aqua"></i> 1 dossier termin&eacute;--%>
<%--                                    </a>--%>
<%--                                </li>--%>
<%--                            </ul>--%>
<%--                        </li>--%>
<%--                        <li class="footer"><a href="#">Tout voir</a></li>--%>
<%--                    </ul>-->--%>
<%--                <!--</li>-->--%>
<%--                <!-- User Account: style can be found in dropdown.less -->--%>
<%--                <li>--%>
<%--                    <a class="btn btn-tertiary btn-small" onclick="showAlarmPopup()"><i class="fa fa-clock-o" style="scale: 1.3; position: relative; top: 2px"></i></a>--%>
<%--                </li>--%>
<%--                        <li style="margin-top: 7%" id="notifrefresh">--%>


<%--                        </li>--%>
<%--                <li class="dropdown user user-menu">--%>
<%--                    <a href="#" class=" btn btn-tertiary btn-small dropdown-toggle" data-toggle="dropdown">--%>
<%--                        <span class="hidden-xs"><%=map.getLoginuser()%></span>--%>
<%--                    </a>--%>
<%--                    <!--<ul class="dropdown-menu">--%>
<%--                        <!-- User image -->--%>
<%--                        <!--<li class="user-header">--%>
<%--                            <p>--%>
<%--                                <//%=map.getLoginuser() + "-" + map.getIdrole()%>--%>
<%--                            </p>--%>
<%--                        </li>--%>
<%--                        <!-- Menu Body -->--%>
<%--                        <!-- Menu Footer-->--%>
<%--                        <!--<li class="user-footer">--%>
<%--                            <div class="pull-left">--%>
<%--                                <a href="<//%=lien%>?but=utilisateur/utilisateur-modif.jsp&id=<//%=map.getRefuser()%>" class="btn btn-default btn-flat">Modifier Profil</a>--%>
<%--                            </div>--%>
<%--                            <div class="pull-right">--%>
<%--                                <a href="deconnexion.jsp" class="btn btn-default btn-flat">D&eacute;connexion</a>--%>
<%--                            </div>--%>
<%--                        </li>--%>
<%--                    </ul>-->--%>
<%--                </li>--%>
<%--                <li>--%>
<%--                     <a class="btn btn-tertiary btn-small"  href="deconnexion.jsp"><i class="fa fa-sign-out"></i> D&eacute;connexion</a>--%>
<%--                </li>--%>
<%--            </ul>--%>
<%--        </div>--%>
    </nav>
</header>
<div class="modal fade" id="modalSendMessage" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="message-chat-title"></h4>
            </div>
            <div class="modal-body clearfix">
                <div class="message-chat-content clearfix" id="message-chat-content">

                </div>
                <br/>
                <form>
                    <textarea id="messagefrom" onkeypress="keypressedsendMessage(this, 1)" class="form-control" rows="3" placeholder="Votre message ici" ></textarea>
                    <br/><br/>
                    <input type="button" class="btn btn-primary pull-right" style="margin-left: 5px;" onclick="keypressedsendMessage(this, 2)" value="Envoyer"/>
                    <input type="reset" class="btn btn-danger pull-right" value="Annuler"/>
                </form>
            </div>
        </div>
    </div>
</div>
<div class="modal fade" id="modalSendMessageTo" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <%
                    MapUtilisateur[] utilisateurs = (MapUtilisateur[]) CGenUtil.rechercher(new MapUtilisateur(), null, null, " AND REFUSER <> '" + map.getRefuser() + "'");
                    for (MapUtilisateur utilisateur : utilisateurs) {%>
                <div class="radio">
                    <label>
                        <input type="radio" name="optionsRadios" id="optionsRadios1" value="<%=utilisateur.getRefuser()%>">
                        <%=utilisateur.getNomuser()%>
                    </label>
                </div>
                <%}
                %>

            </div>
            <div class="modal-body clearfix">
                <form>
                    <textarea id="msgelement" class="form-control" rows="3" placeholder="Votre message ici" ></textarea>
                    <br/><br/>
                    <input type="button" class="btn btn-primary pull-right" style="margin-left: 5px;" onclick="keypressedsendMessage(this, 3)" value="Envoyer"/>
                    <input type="reset" class="btn btn-danger pull-right" value="Annuler"/>
                </form>
            </div>
        </div>
    </div>
</div>


<div class="modal fade" id="alarmModal" tabindex="-1" role="dialog" aria-labelledby="alarmModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <form id="alarmForm">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Cr&eacute;er une alarme</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Fermer">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="alarmMessage">Message</label>
                        <input type="text" class="form-control" id="alarmMessage" required>
                    </div>
                    <div class="form-group">
                        <label for="alarmTimestamp">Date &amp; Heure</label>
                        <input type="datetime-local" class="form-control" id="alarmTimestamp" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">Cr&eacute;er</button>
                    <button type="button" class="btn btn-tertiary" data-dismiss="modal">Annuler</button>
                </div>
            </div>
        </form>
    </div>
</div>




<script src="${pageContext.request.contextPath}/apjplugins/notification.js" type="text/javascript"></script>                