/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


		var timeout; //CONTIENT LE MINUTEURE
		var elemSelect = []; //ELEMENT SELECTIONNER
		var ctrlEtat = false; //ETAT TOUCHE CTRL			
		var executetimeout = true; //ETAT MINUTEURE
		var root = ""; //SOURCE DU DRAG

			function dragover_handler(ev){
				ev.preventDefault();
				ev.dataTransfer.dropEffect = "move";
			}
			
			function dragover_handler_month(ev, annee, mois){
				executetimeout = true;
				ev.preventDefault();
				ev.dataTransfer.dropEffect = "move";
                                var data = ev.dataTransfer.items;
                                var t = 0;
                                var end = data.length - 1;
                                var tabelem = [];
				for(var h = 0; h<data.length; h++){
					var id = "";
					data[h].getAsString(function am(s){
						id = s;
                                                tabelem.push(id);
                                                if(t === end){
                                                    timeout = setTimeout(function(){
                                                                            if(executetimeout){
                                                                                    displayMois(annee, mois, tabelem);
                                                                            }}, 750
                                                                    );                                                    
                                                }
                                                t++;
					});			
				}                                		
			}
                        
			function dragleave_handler_month(ev){
				ev.preventDefault();		
				executetimeout = false;
				clearTimeout(timeout);
			}
                        
                        function confirmUpdate(){
                                if(confirm("Voulez-vous vraiment modifier cet/ces �l�ment(s)?")){
                                        return true;
                                }else{
                                        return false;
                                }		
                        }     
                        
                        function confirmDepasseMax(maxautorise){
                                if(confirm("ATTENTION: Cette modification d�passe le maximum ("+maxautorise+") autoris� pour cette date, voulez-vous confirmer quand m�me?")){
                                        return true;
                                }else{
                                        return false;
                                }		
                        }     
                        
                        
                     function changerElem(obj){       
                            document.getElementById("nombreLigne").value = indiceinput + 1;
                            obj["classefille"] = document.getElementById("classefille").value;
                            obj["nombreLigne"] = indiceinput + 1;
                            updateObject(obj);
                        }     
                        
                        function updateObject(obj) {
                            var postData = JSON.stringify(obj);
                            $.ajax({
                                type: "POST",
                                url: "../../opus/CalendrierUpdate",
                                contentType: 'application/json; charset=utf-8',
                                data: postData
                                /*success: function (msg) {
                                    alert("ok");
                                }*/
                            });
                        }            
                        
                        var objUp;        
                        var indiceinput = 0;
                        var indiceinputtotal = 0;
                        var limit = 0;
			function drop_handler(ev){
                                objUp = new Object();
				ev.preventDefault();
				var data = ev.dataTransfer.items;
				if(ev.target.id.startsWith('div_')){
					if(root != ev.target.id){
						if(!confirmUpdate()){
                                                    return ;
                                                }
					}				
				}
                                //document.getElementById("divtmp").innerHTML = "";
                                objUp["colonne"] = colonne;
                                objUp["valeur"] = ev.target.dataset.value;
                                indiceinput = 0;
                                indiceinputtotal = 0;
                                limit = 0;
                                limit = data.length - 1;

                                var recap = ev.target.querySelector('#recap');
                                var maxautorise = parseFloat(recap.getAttribute("max"));
                                var valactu = parseFloat(recap.innerHTML);
                                var total = 0;
                                var indiceinputtotal_ = 0;
                                var limit_ = data.length - 1;                            
                                for(var k = 0; k<data.length; k++){
                                    data[k].getAsString(function am(s){                                
                                        var valid = document.getElementById(s).dataset.value;
                                        total = total + parseFloat(valid);
                                                    if(indiceinputtotal_===limit_){
                                                        if((total + valactu)>maxautorise){
                                                            if(!confirmDepasseMax(maxautorise)){
                                                                return ;
                                                            }
                                                        }
                                                        
                                                    for(var h = 0; h<data.length; h++){
                                                            var id = "";
                                                            data[h].getAsString(function am(s){
                                                                    id = s;
                                                                    if(ev.target.id.startsWith('div_')){	                          
                                                                            var valid = document.getElementById(id).querySelector("#hidden_"+id).value;
                                                                            objUp["id_"+indiceinput] = valid;
                                                                            ev.target.querySelector('#prep').insertAdjacentElement('afterend', document.getElementById(id));
                                                                            calculSommeById(root);
                                                                            calculSommeById(ev.target.id);	
                                                                    }
                                                                    if(indiceinputtotal===limit){
                                                                        changerElem(objUp);
                                                                    }
                                                                    indiceinput++;
                                                                    indiceinputtotal++;
                                                            });			
                                                    }                                                        
                                                    }                                    
                                        indiceinputtotal_++;
                                    });
                                }                                
			}       
                        
			function dragstart_handler(ev){
				var datalist =  ev.dataTransfer.items;
				if(elemSelect.length==0){
					clickElemById(ev.target.id);
				}else{
					var t = true;
					for(var i = 0; i<elemSelect.length; i++){
						if(elemSelect[i].id == ev.target.id){
							t = false;
						}
					}		if(t){
								clearSelection();
								clickElemById(ev.target.id);			
							}
				}
				for(var i = 0; i<elemSelect.length; i++){
					datalist.add(elemSelect[i].id, "text/plain_"+i);
					//ev.dataTransfer.dropEffect = "move";		
				}
				root = ev.target.parentElement.id;
			}
                        
				document.onclick = function(e){
					if((e.target.id!="descr")){
						if(elemSelect.length!=0){
							clearSelection();
						}			
					}
				}
                                
		
				function clearSelection(){
							for(var i = 0; i<elemSelect.length; i++){
                                                            document.getElementById("datycal_"+anneediv+'-'+moisdiv).querySelector("#"+elemSelect[i].id).querySelector("#descr").style.backgroundColor = "#f0f0f0";
							}	
					elemSelect = [];
				}
				
				function clickElem(ev){		
					var ind = ev.target.parentElement.id;
					var d = document.getElementById(ind);
                                        if(!d.draggable){
                                            return;
                                        }
					var sec = false;
					if(ctrlEtat === false){
						if(elemSelect.length!=0){				
							for(var i = 0; i<elemSelect.length; i++){
								if(elemSelect[i].id == ind){
									sec = true;
									clearSelection();
									break;
								}
							}				
							clearSelection();
						}
					}else{
							if(elemSelect.length!=0){
								var cdt = false;
								for(var i = 0; i<elemSelect.length; i++){					
									if(elemSelect[i].parentElement.id!=d.parentElement.id){
										cdt = true;
										break;
									}
									if(elemSelect[i].id == ind){
										sec = true;
										elemSelect.splice(i, 1);
										break;
									}
								}
								if(cdt){				
									clearSelection();
								}
							}	
					}
                                        var tmp = document.querySelectorAll('*[id^="datycal_"]');
                                        if(tmp.length>0){
                                            if(sec){
                                                    tmp[0].querySelector("#"+ind).querySelector("#descr").style.backgroundColor = '#f0f0f0';
                                            }else{
                                                    tmp[0].querySelector("#"+ind).querySelector("#descr").style.backgroundColor = '#8ad';
                                                    elemSelect.push(d);			
                                            }
                                        }
				}
				
				function clickElemById(id){		
					var ind = id;
					var d = document.getElementById(ind);
                                        if(!d.draggable){
                                            return;
                                        }
					var sec = false;
					if(ctrlEtat === false){
						if(elemSelect.length!=0){				
							for(var i = 0; i<elemSelect.length; i++){
								if(elemSelect[i].id == ind){
									sec = true;
									clearSelection();
									break;
								}
							}				
							clearSelection();
						}
					}else{
							if(elemSelect.length!=0){
								var cdt = false;
								for(var i = 0; i<elemSelect.length; i++){					
									if(elemSelect[i].parentElement.id!=d.parentElement.id){
										cdt = true;
										break;
									}
									if(elemSelect[i].id == ind){
										sec = true;
										elemSelect.splice(i, 1);
										break;
									}
								}
								if(cdt){				
									clearSelection();
								}
							}	
					}
                                        var tmp = document.querySelectorAll('*[id^="datycal_"]');
                                        if(tmp.length>0){
                                            if(sec){                                                

                                                    tmp[0].querySelector("#"+ind).querySelector("#descr").style.backgroundColor = '#f0f0f0';
                                            }else{
                                                    tmp[0].querySelector("#"+ind).querySelector("#descr").style.backgroundColor = '#8ad';
                                                    elemSelect.push(d);			
                                            }                                            
                                        }
				}                                

                        document.body.onkeydown = function(e) { //TOUCHE CTRL MAINTENIR
  if (e.keyCode == 17) {
	ctrlEtat = true;
    e.preventDefault()
  }
}			
  
document.body.onkeyup = function(e) { //TOUCHE CTRL LACHER
  if (e.keyCode == 17) {
	ctrlEtat = false;
    e.preventDefault()
  }
  }                        
