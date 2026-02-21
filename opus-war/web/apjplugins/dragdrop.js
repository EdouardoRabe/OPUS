/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
        function sendModif(){
            for(var y = 0; y<NOMBRECRITERE; y++){
                var targ = document.getElementById("div"+y);
		var critere = targ.querySelector('#critere'+targ.id);
                if(targ == null){
                    continue;
                }
                console.log(targ.id);
                console.log(critere.innerHTML);                
                var tab = targ.childNodes;
				for(var i = 0; i<tab.length;i++){
					for(var j = 0; j<TAILLE; j++){
						if(tab[i].id == "elem"+j){
                                                    var inputhidden = document.getElementById("iphidden"+j);
                                                    if(inputhidden == null){
                                                        continue;
                                                    }
                                                    console.log(inputhidden.id);
                                                    console.log(inputhidden.value);                                                      
                                                    inputhidden.value = critere.innerHTML;
						}				
					}
				}                
            }
        }	 //VARIABLE UTILE 

                
    // VARIABLE UTILE FIN
		 
		// PAGE ONLOAD 
			function codeAddress(){ //MOIS AFFICHER EN PREMIER
				document.getElementById("datycal_"+anneediv+"-"+moisdiv).style.display = "block";
			};
                        
                        function codeCouleur(val, max){
                            var valpourc = (100 * val)/max;
                            if(valpourc>0 && valpourc<=25){
                                return "etat_faible";
                            }
                            if(valpourc>25 && valpourc<=50){
                                return "etat_moyen";
                            }                     
                            if(valpourc>50 && valpourc<=75){
                                return "etat_charge";
                            }                     
                            if(valpourc>75 && valpourc<=100){
                                return "etat_trescharge";
                            }        
                            if(valpourc>100){
                                return "etat_surcharge";
                            }
                            return "etat_neutre";
                        }
                        
			function calculSomme(){ //SOMME DES DATA-VALUE DES DIV
				for(var y = 1; y<=totalDiv; y++){
					var targ = document.getElementById("div_"+y+"_"+anneediv+"-"+moisdiv);
					if(targ == null){
						continue;
					}
					var elem = [];
					var t = 0;
					var lib = targ.querySelector('#recap');
                                        var tab = targ.querySelectorAll('*[id^="elem_"]');
					for(var i = 0; i<tab.length;i++){
                                                        if(tab[i].id != null){
                                                            t = t + parseFloat(document.getElementById(tab[i].id).dataset.value);		
                                                        }
					}
                                        var couleurrecap = codeCouleur(t, parseFloat(lib.getAttribute("max")));
                                        var inf = targ.querySelector('#infojour');
                                        inf.setAttribute('class', couleurrecap);
                                        
					lib.innerHTML = Math.round(t * 100) / 100;		
				}            
			}
			
			function calculSommeById(id){ //SOMME DES DATA-VALUE DIV
					var targ = document.getElementById(id);
					if(targ == null){
						return ;
					}
					var elem = [];
					var t = 0;
					var lib = targ.querySelector('#recap');
                                        var tab = targ.querySelectorAll('*[id^="elem_"]');
					for(var i = 0; i<tab.length;i++){
							if(tab[i].id != null){
								t = t + parseFloat(document.getElementById(tab[i].id).dataset.value);		
							}
					}	
                                        var couleurrecap = codeCouleur(t, parseFloat(lib.getAttribute("max")));
                                        var inf = targ.querySelector('#infojour');  
                                        inf.setAttribute('class', couleurrecap);
                                                                                
					lib.innerHTML = Math.round(t * 100) / 100;		
				}            
			
			
			window.onload = dofirst;//FONCTION EXECUTE EN PREMIER
		// PAGE ONLOAD FIN 
		
	// SHOW PAGINATION MOIS 
		function showMois(actuel, target){
			var act = document.getElementById(actuel);
			var target = document.getElementById(target);
			act.style.display = "none";
			target.style.display = "block";
		}
                                
				function showdetail(ev){
					var ind = ev.target.parentElement.parentElement.id;
					var d = document.getElementById("elemdiv");
					var fiche = document.getElementById(ind).querySelector("#dispelem");
					var cln = fiche.cloneNode(true);
					d.appendChild(cln);
									
					d.style.display = "block";
					d.querySelector("#dispelem").style.display = "block";
					document.getElementById("mybackground").style.display = "block";
				}
				
				function hidedetail(){
						var d = document.getElementById("elemdiv");
						var fiche = d.querySelector("#dispelem");			
						d.removeChild(fiche);
						d.style.display = "none";
						document.getElementById("mybackground").style.display = "none";			
				};
                                
                        function createInput(nom, valeur, idajout, position){
                            var d = document.getElementById(idajout);
                            var input = document.createElement("input");
                            input.setAttribute("type", "hidden");
                            input.setAttribute("name", nom);
                            input.setAttribute("value", valeur);
                            input.setAttribute("id", nom);
                            d.insertAdjacentElement(position, input);
                        }                                
						                                               
                        function displayMois(annee, mois, idelem){ 
                            var elemhtml = [];
                            createInput("changemois_length", idelem.length, "prestation", "afterbegin");
                            for(var i = 0; i<idelem.length; i++){
                                elemhtml[i] = document.getElementById(idelem[i]).outerHTML;
                                elemhtml[i] = elemhtml[i].replace(/(\r\n|\n|\r)/gm, "");
                                createInput("changemois_"+i, elemhtml[i], "prestation", "afterbegin");
                            }
                            const areaSelectmois = document.querySelector(`[id="etat_mois"]`);
                            areaSelectmois.value = mois;

                            const areaSelectannee = document.querySelector(`[id="etat_annee"]`);
                            areaSelectannee.value = annee;        
                            changerDesignation();
                        }  
                        
   