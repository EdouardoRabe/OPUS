<!-- jQuery 2.1.4 -->

<%--<script src="${pageContext.request.contextPath}/assets/js/moment.min.js"></script>--%>

<!-- jQuery UI 1.11.4 -->
<script src="${pageContext.request.contextPath}/dist/js/jquery-ui.min.js" type="text/javascript"></script>
<!-- Resolve conflict in jQuery UI tooltip with Bootstrap tooltip -->
<script type="text/javascript">
    $.widget.bridge('uibutton', $.ui.button);
</script>
<!-- Bootstrap 3.3.2 JS -->
<script src="${pageContext.request.contextPath}/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
<script src="${pageContext.request.contextPath}/bootstrap/js/jquery.dataTables.min.js" type="text/javascript"></script>
<script src="${pageContext.request.contextPath}/bootstrap/js/dataTables.bootstrap.min.js" type="text/javascript"></script>
<script src="${pageContext.request.contextPath}/bootstrap/js/jquery.tablesorter.min.js" type="text/javascript"></script>
<!-- Morris.js charts -->
<!--<script src="https://cdnjs.cloudflare.com/ajax/libs/raphael/2.1.0/raphael-min.js"></script>
<script src="${pageContext.request.contextPath}/plugins/morris/morris.min.js" type="text/javascript"></script>-->
<!-- Sparkline -->
<!--<script src="${pageContext.request.contextPath}/plugins/sparkline/jquery.sparkline.min.js" type="text/javascript"></script>-->
<!-- jvectormap -->
<!--<script src="${pageContext.request.contextPath}/plugins/jvectormap/jquery-jvectormap-1.2.2.min.js" type="text/javascript"></script>
<script src="${pageContext.request.contextPath}/plugins/jvectormap/jquery-jvectormap-world-mill-en.js" type="text/javascript"></script>-->
<!-- jQuery Knob Chart -->
<!--<script src="${pageContext.request.contextPath}/plugins/knob/jquery.knob.js" type="text/javascript"></script>-->
<!-- daterangepicker -->
<!--<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.10.2/moment.min.js" type="text/javascript"></script>-->
<script src="${pageContext.request.contextPath}/plugins/daterangepicker/daterangepicker.js" type="text/javascript"></script>
<!-- datepicker -->
<script src="${pageContext.request.contextPath}/plugins/datepicker/bootstrap-datepicker.js" type="text/javascript"></script>
<script src="${pageContext.request.contextPath}/plugins/timepicker/bootstrap-timepicker.min.js" type="text/javascript"></script>
<!-- Bootstrap WYSIHTML5 -->
<!--<script src="${pageContext.request.contextPath}/plugins/bootstrap-wysihtml5/bootstrap3-wysihtml5.all.min.js" type="text/javascript"></script>-->
<!-- Slimscroll -->
<script src="${pageContext.request.contextPath}/plugins/slimScroll/jquery.slimscroll.min.js" type="text/javascript"></script>
<!-- FastClick -->
<script src="${pageContext.request.contextPath}/plugins/fastclick/fastclick.min.js" type="text/javascript"></script>
<!-- ChartJS 1.0.1 -->
<!--<script src="${pageContext.request.contextPath}/plugins/chartjs/Chart.min.js" type="text/javascript"></script>-->
<!-- AdminLTE App -->
<script src="${pageContext.request.contextPath}/dist/js/app.min.js" type="text/javascript"></script>
<!-- AdminLTE dashboard demo (This is only for demo purposes) -->
<!--<script src="${pageContext.request.contextPath}/dist/js/pages/dashboard.js" type="text/javascript"></script>-->
<!-- AdminLTE dashboard demo (This is only for demo purposes) -->
<!--<script src="${pageContext.request.contextPath}/dist/js/pages/dashboard2.js" type="text/javascript"></script>-->
<!-- AdminLTE for demo purposes -->
<!--<script src="${pageContext.request.contextPath}/dist/js/demo.js" type="text/javascript"></script>-->
<!-- Parsley -->

<%--<script src="${pageContext.request.contextPath}/plugins/sparkline/jquery.sparkline.min.js"></script>--%>
<script src="${pageContext.request.contextPath}/plugins/select2/select2.full.min.js"></script>
<%--<script src="${pageContext.request.contextPath}/dist/js/notify.min.js" type="text/javascript"></script>--%>
<%--<script src="${pageContext.request.contextPath}/dist/js/moreAction.js" type="text/javascript"></script>--%>

<!-- tab -->



<%--<script src="${pageContext.request.contextPath}/assets/js/modernizr.custom.js" type="text/javascript"></script>--%>
<%--<script src="${pageContext.request.contextPath}/assets/js/cbpFWTabs.js" type="text/javascript"></script>--%>

<script src="${pageContext.request.contextPath}/assets/js/jquery.mCustomScrollbar.concat.min.js"></script>
<%--<script src="${pageContext.request.contextPath}/apjplugins/chat.js"></script>--%>

<script type="text/javascript">
    if (window.ParsleyValidator) {
        window.ParsleyValidator.setLocale('fr');
    }
    $('.datepicker').datepicker({
        format: 'dd/mm/yyyy'
    });
    //    $(".timepicker").timepicker({
    //        showInputs: false
    //    });

    $(window).bind("load", function () {
//        getMessageDeploiement();
//        window.setInterval(getMessageDeploiement, 30000);
    });

    function getMessageDeploiement() {
        var text = 'ok';
        $.ajax({
            type: 'GET',
            url: '${pageContext.request.contextPath}/MessageDeploiement',
            contentType: 'application/json',
            data: {'mes': text},
            success: function (ma) {
                if (ma != null) {
                    var data = JSON.parse(ma);
                    if (data.message != null) {
                        alert(data.message);
                    }
                    if (data.erreur != null) {
                        alert(data.erreur);
                    }
                }

            },
            error: function (e) {
                //alert("Erreur Ajax");
            }

        });
    }

    function pagePopUp(page, width, height) {
        w = 750;
        h = 600;
        t = "D&eacute;tails";

        if (width != null || width == "")
        {
            w = width;
        }
        if (height != null || height == "") {
            h = height;
        }
        window.open(page + "?localite=" + document.getElementById("idlocalite").value, t, "titulaireresizable=no,scrollbars=yes,location=no,width=" + w + ",height=" + h + ",top=0,left=0");
    }

    function removeLineByIndex(iLigne) {
        var nomId = "ligne-multiple-" + iLigne;

        var ligne = document.getElementById(nomId);
        ligne.parentNode.removeChild(ligne);
        var nbrLigne = document.getElementById('nbrLigne').value;
        document.getElementById('nbrLigne').value = nbrLigne - 1;
    }
    function add_line() {

        var indexMultiple = document.getElementById('indexMultiple').value;
        alert('indexMultiple' + indexMultiple);
        var nbrLigne = document.getElementById('nbrLigne').value;
        var html = genererLigneFromIndex(indexMultiple);
        $('#ajout_multiple_ligne').append(html);
        document.getElementById('indexMultiple').value = parseInt(indexMultiple) + 1;
        document.getElementById('nbrLigne').value = parseInt(nbrLigne) + 1;
    }
    function searchKeyPress(e)
    {
        // look for window.event in case event isn't passed in
        e = e || window.event;
        if (e.keyCode == 13)
        {
            document.getElementById('btnListe').click();
            return false;
        }
        return true;
    }
    function back() {
        history.back();
    }
    function getChoix() {
        setTimeout("document.frmchx.submit()", 800);
    }
    $('#sigi').DataTable({
        "paging": false,
        "lengthChange": false,
        "searching": false,
        "ordering": true,
        "info": false,
        "autoWidth": false
    });
    $(function () {
        $(".select2").select2();
        $("#example1").DataTable();
        $('#example2').DataTable({
            "paging": true,
            "lengthChange": false,
            "searching": false,
            "ordering": true,
            "info": true,
            "autoWidth": false
        });
    });
    function CocheToutCheckbox(ref, name) {
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
    function dependante(valeurFiltre,champDependant,nomTable,nomClasse,nomColoneFiltre,nomColvaleur,nomColAffiche)
    {
        document.getElementById(champDependant).length=0;
        var param = {'valeurFiltre':valeurFiltre,'nomTable':nomTable,'nomClasse':nomClasse,'nomColoneFiltre':nomColoneFiltre,'nomColvaleur':nomColvaleur,'nomColAffiche':nomColAffiche};
        var lesValeur=[];
        $.ajax({
            type:'GET',
            url:'/opus/Deroulante',
            contentType: 'application/json',
            data:param,
            success:function(ma){
                var data = JSON.parse(ma);

                for(i in data.valeure)
                {
                    lesValeur.push(new Option(data.valeure[i].valeur, data.valeure[i].id, false, false));
                }
                addOptions(champDependant,lesValeur);
            }
        });


    }
    function dependantewithdefault(valeurFiltre,champDependant,nomTable,nomClasse,nomColoneFiltre,nomColvaleur,nomColAffiche,defaultValue = "")
    {
        document.getElementById(champDependant).length=0;
        var param = {'valeurFiltre':valeurFiltre,'nomTable':nomTable,'nomClasse':nomClasse,'nomColoneFiltre':nomColoneFiltre,'nomColvaleur':nomColvaleur,'nomColAffiche':nomColAffiche};
        var lesValeur=[];
        $.ajax({
            type:'GET',
            url:'/opus/Deroulante',
            contentType: 'application/json',
            data:param,
            success:function(ma){
                var data = JSON.parse(ma);

                for(i in data.valeure)
                {
                    const newOption = new Option(data.valeure[i].valeur, data.valeure[i].id, false, false);
                    if (newOption.value === defaultValue) {
                        newOption.selected = true;
                    }
                    lesValeur.push(newOption);
                }
                addOptions(champDependant,lesValeur);
            }
        });


    }
    function dependantewithtiret(valeurFiltre,champDependant,nomTable,nomClasse,nomColoneFiltre,nomColvaleur,nomColAffiche,esttiret)
    {
        document.getElementById(champDependant).length=0;
        var param = {'action':'wittiret','valeurFiltre':valeurFiltre,'nomTable':nomTable,'nomClasse':nomClasse,'nomColoneFiltre':nomColoneFiltre,'nomColvaleur':nomColvaleur,'nomColAffiche':nomColAffiche,'esttiret':esttiret};
        var lesValeur=[];
        $.ajax({
            type:'GET',
            url:'/opus/Deroulante',
            contentType: 'application/json',
            data:param,
            success:function(ma){
                var data = JSON.parse(ma);

                for(i in data.valeure)
                {
                    lesValeur.push(new Option(data.valeure[i].valeur, data.valeure[i].id, false, false));
                }
                addOptions(champDependant,lesValeur);
            }
        });


    }

    function addOptions(nomListe,lesopt)
    {
        var List = document.getElementById(nomListe);
        var elOption = lesopt;

        var i, n;
        n = elOption.length;

        for (i=0; i<n; i++)
        {
            List.options.add(elOption[i]);
        }
    }
</script>
<script src="${pageContext.request.contextPath}/assets/js/script.js" type="text/javascript"></script>

<script src="${pageContext.request.contextPath}/assets/js/controleTj.js" type="text/javascript"></script>
<script src="${pageContext.request.contextPath}/apjplugins/champcalcul.js" defer></script>

<script src="${pageContext.request.contextPath}/assets/js/soundmanager2-jsmin.js" type="text/javascript"></script>
<script type="text/javascript">
    if (typeof (Storage) !== "undefined") {
        // Code for localStorage/sessionStorage.
        var collapse = localStorage.getItem("menuCollapse");

    } else {
        // Sorry! No Web Storage support..
    }
    $(document).ready(function () {
        $("#ajoutPart").hide();
        if (localStorage.getItem("menuCollapse") == "true") {
            $("body").addClass("sidebar-collapse");
        }

        $(".sidebar-toggle").click(function () {
            if (localStorage.getItem("menuCollapse") == "false" || localStorage.getItem("menuCollapse") == "") {
                localStorage.setItem("menuCollapse", "true");
            } else {
                localStorage.setItem("menuCollapse", "false");
            }
        });
    });
    function ajoutParticip() {
        $("#ajoutPart").show();
    }

    function fetchAutocomplete(request, response, affiche, valeur, colFiltre, nomTable, classe,useMocle,champRetour) {
        if (request.term.length >= 1) {
            $.ajax({
                url: "/opus/autocomplete",
                method: "GET",
                contentType: "application/x-www-form-urlencoded",
                dataType: "json",
                data: {
                    libelle: request.term,
                    affiche: affiche,
                    valeur: valeur,
                    colFiltre: colFiltre,
                    nomTable: nomTable,
                    classe: classe,
                    useMotcle:useMocle,
                    champRetour: champRetour
                },
                success: function(data) {
                    response($.map(data.valeure, function(item) {
                        return {
                            label: item.valeur,
                            value: item.id,
                            retour: item.retour
                        };
                    }));
                }
            });
        }
    }

    // updateFille
    function updateFille(event, formId) {
        event.preventDefault();
        const input = event.target;
        const currentValue = input.value;
        if (input.dataset.lastValue === currentValue) {
            return;
        }
        input.dataset.lastValue = currentValue;

        const name = input.name;
        const lastValue = input.dataset.lastValue;

        // document.getElementById("loader").style.display = "flex";
        const fd = new FormData(document.getElementById(formId));
        const url = window.location.pathname + window.location.search + "&onchanged=true" + "&" + name + "=" + lastValue
        $.ajax({
            url: url,
            type: 'POST',
            data: fd,
            contentType: false,
            processData:false,
            success:function(response) {
                const doc = new DOMParser().parseFromString(response, 'text/html');
                const targetDiv = document.getElementById('butfillejsp');
                if (targetDiv) {
                    targetDiv.innerHTML = '';
                    const newContent = doc.getElementById('butfillejsp');
                    if (newContent) {
                        targetDiv.innerHTML = newContent.innerHTML;
                        newContent.querySelectorAll('script').forEach(script => {
                            const newScript = document.createElement('script');
                            newScript.text = script.textContent;
                            targetDiv.appendChild(newScript);
                        });
                    } else {
                        console.error('Élément butjsp introuvable dans la réponse.');
                    }
                } else {
                    console.error('Élément cible butjsp introuvable.');
                }
                // document.getElementById("loader").style.display = "none";
            },
            error: function(){
                // document.getElementById("loader").style.display = "none";
                console.error('Erreur lors de la mise à jour');
            }
        })
    }

    function pageAPJListener(event, defaultSuffix, idClass, idNom, idType, idChemin, idCheminApres, formId) {
        updateFille(event, formId)
        const idclasseLibInput = document.getElementById(idClass + "libelle");
        const idtypeInput = document.getElementById(idType);
        const cheminInput = document.getElementById(idChemin);
        const nomInput = document.getElementById(idNom);
        const cheminApres = document.getElementById(idCheminApres);
        const cheminApresLibelle = document.getElementById(idCheminApres+"libelle");

        const form = document.getElementById(formId);
        const formData = new FormData(form);
        const idclasselibelle = formData.get(idClass + "libelle");
        if (idclasselibelle != null && idclasselibelle.length > 0) {
            console.log(formData)
            let nomClasse = idclasselibelle.split(" - ")[1]
            const splits = nomClasse.split(".")
            nomClasse = splits[splits.length - 1]
            cheminInput.value = "";
            splits.forEach((item) => {
                cheminInput.value += "/" + item;
            })
            cheminInput.value += "/";
            let end = "-" + defaultSuffix + ".jsp"
            if (formData.get("idtype") != null && formData.get("idtype") == "TPGS000003") {
                end = "-" + defaultSuffix + "-multiple.jsp"
            }
            nomInput.value = nomClasse + end;
            if (cheminApres != null) {
                cheminApres.value = cheminInput.value+nomInput.value;
                cheminApresLibelle.value = cheminInput.value+nomInput.value;
            }
        }
    }
    function synchro(champ,champCheck)
    {
        // var vraiNom=champ.name.substring(9);
        let checkboxes = document.querySelectorAll('input[name="ids"]');
        checkboxes.forEach((checkbox) => {
            if(checkbox.id===champCheck) {
                checkbox.checked = true;
            }
        });
    }

</script>
<script>
    (function () {

        [].slice.call(document.querySelectorAll('.tabs')).forEach(function (el) {
            new CBPFWTabs(el);
        });

    })();
</script>