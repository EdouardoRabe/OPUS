var mesnotifs = [];
var limit = 5;
var titre = document.title;
var check = false;

function getNotification() {
   var tmp = mesnotifs.length;
    $.ajax({
        type: "GET",
        url: "../../opus/Notification",
        dataType: "json",
        data: {"nb" : ""+mesnotifs.length},
        success: function (data, textStatus, jqXHR) {
            mesnotifs = data;
            buildHTMLNotif();
            var taillenotif =  mesnotifs.length;
            var ecart = taillenotif - tmp;
            if(check){
                for(var i = 0; i<ecart; i++){
                    getNotificationWindows(mesnotifs[i].message);
                }
            }
            check = true;
            if(taillenotif!=0){
                document.title = "("+taillenotif+") "+titre;
            }
        }
    });
}
                        
function getNotificationWindows(message) {
    $.ajax({
        type: "GET",
        url: "../../opus/Notification",
        dataType: "json",
        data: {"notifSys" : message},
        success: function (data, textStatus, jqXHR) {
        }
    });
}

//                 function buildHTMLNotif() {
//                     // 1. Vérifier si le dropdown est ouvert
//                     var wasOpen = $('.js-btn-notif').hasClass('open');
//
//                     if(mesnotifs.length < 5){
//                         limit = mesnotifs.length;
//                     }
//
//                     var c = "<div class='btn-group js-btn-notif";
//                     if (wasOpen) c += " open"; // 2. Forcer la classe "open" si elle était là
//                     c += "' style='position: initial; transform: scaleX(-1)'>\n\
//     <a class='dropdown-toggle' data-toggle='dropdown' aria-expanded='true'>\n\
//     <i class='fa fa-bell' data-toggle='tooltip' data-placement='bottom' style='color: white'></i>";
//
//                     if (mesnotifs.length != 0) {
//                         c += "<span class='badge badge-ketrika js-badge-notif' id='nbnonlu' style='background-color: rgb(204, 0, 0); transform: scaleX(-1)'>" + mesnotifs.length + "</span>";
//                     }
//
//                     c += "</a>\n\
//     <ul class='dropdown-menu with-caret dropdown-menu-notif' role='menu' style='border: 1px solid; width: 400px; transform: scaleX(-1);'>\n\
//         <h4 style='margin-left: 2%'>Notifications <i class='fa fa-exclamation-circle'></i></h4>\n";
//
//                     if (mesnotifs.length == 0) {
//                         c += "<h6 style='text-align: center'>Aucune notifications</h6>";
//                     } else {
//                         c += "<h5 style='text-align: right; margin-right: 2%'><a href='?but=apresNotif.jsp&acte=toutvu&bute=" + window.location.href.split('?but=')[1] + "'>Tout marqu&eacute; comme Lu</a></h5>";
//                     }
//
//                     for (var i = 0; i < limit; i++) {
//                         if (mesnotifs[i].etat == 1) {
//
//                             c += "<li style='background-color: rgb(249, 249, 249); border: 1px solid; padding: 0 2%; margin: 2% 0; cursor: pointer'>";
//                         }
//                         else {
//                             c += "<li onclick=\"location.href='" + mesnotifs[i].message + "';\" style='background-color: rgb(249, 249, 249); border: 1px solid; padding: 0 2%; margin: 2% 0; cursor: pointer'>";
//                         }
//                         c += "<p>" + mesnotifs[i].message + "</p><span class='dropdown-notif-time'>" + mesnotifs[i].ecartstring + "</span></li>";
//                     }
//
//                     c += "<a class='dropdown-menu-pagenotif col-xs-12 bg-primary' href='" + lien + "?but=tache/notification/notification-liste.jsp' style='text-align: center'> Voir tout</a>\n\
//     </ul>\n\
// </div>";
//
//                     // Remplacer le HTML
//                     $('#notifrefresh').html(c);
//                 }

function buildHTMLNotif() {
    var wasOpen = $('.js-btn-notif').hasClass('open');
    var limit = mesnotifs.length < 5 ? mesnotifs.length : 5;

    var c = "<div class='btn-group js-btn-notif" + (wasOpen ? " open" : "") + "' style='position: relative; transform: scaleX(-1)'>\
        <a class='dropdown-toggle' data-toggle='dropdown' aria-expanded='true'>\
            <i class='fa fa-bell' data-toggle='tooltip' data-placement='bottom' style='color: #434040; font-size: 17px;'></i>";

    if (mesnotifs.length !== 0) {
        c += "<span class='badge js-badge-notif' id='nbnonlu' >" + mesnotifs.length + "</span>";
    }

    c += "</a>\
        <ul class='dropdown-menu with-caret dropdown-menu-notif' role='menu' style='width: 400px; transform: scaleX(-1); padding: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); border-radius: 10px;'>\
            <div style='display: flex; justify-content: space-between; align-items: center; padding: 5px 10px; border-bottom: 1px solid #ddd;'>\
                <h4 style='margin: 0; font-size: 16px;'>Notifications <i class='fa fa-bell'></i></h4>";

    if (mesnotifs.length > 0) {
        var redirect = window.location.href.split('?but=')[1];
        c += "<a href='?but=apresNotif.jsp&acte=toutvu&bute=" + redirect + "' style='font-size: 12px;'>Tout marquer comme lu</a>";
    }

    c += "</div>";

    if (mesnotifs.length === 0) {
        c += "<div style='text-align: center; padding: 20px; color: #999;'>Aucune nouvelle notification</div>";
    } else {
        for (var i = 0; i < limit; i++) {
            var notif = mesnotifs[i];
            var background = notif.etat === 1 ? '#f1f1f1' : '#ffffff';
            var clickable = notif.etat !== 1 ? " onclick=\"location.href='" + notif.message + "';\"" : "";

            c += "<li style='list-style: none; background-color: " + background + "; border: 1px solid #e0e0e0; border-radius: 6px; padding: 10px 15px; margin: 8px 0; cursor: pointer;' " + clickable + ">";
            c += "<p style='margin: 0 0 5px; font-size: 14px;'>" + notif.message + "</p>";
            c += "<span style='font-size: 12px; color: #888;'>" + notif.ecartstring + "</span>";
            c += "</li>";
        }
    }

    c += "<a class='dropdown-menu-pagenotif btn btn-primary btn-block mt-2' href='" + lien + "?but=tache/notification/notification-liste.jsp' style='margin-top: 10px;'>Voir tout</a>\
        </ul>\
    </div>";

    $('#notifrefresh').html(c);
}


getNotification();
    // var getNotif = window.setInterval(function(){
    //     getNotification();
    // }, 10000);

function showAlarmPopup() {
    $('#alarmModal').modal('show');
}

$(document).ready(function () {
    $('#alarmForm').submit(function (e) {
        e.preventDefault();

        var message = $('#alarmMessage').val();
        var timestamp = $('#alarmTimestamp').val();

        var selectedDate = new Date(timestamp);
        var now = new Date();

        if (isNaN(selectedDate.getTime())) {
            Swal.fire({
                title: "Date invalide",
                html: "<p>Veuillez entrer une date valide.</p>",
                icon: "warning",
                confirmButtonText: "OK"
            });
            return;
        }

        if (selectedDate <= now) {
            Swal.fire({
                title: "Date pass&eacute;e",
                html: "<p>Veuillez choisir une date et une heure futures.</p>",
                icon: "warning",
                confirmButtonText: "OK"
            });
            return;
        }

        $.ajax({
            url: '/opus/alarm',
            method: 'POST',
            contentType: 'application/x-www-form-urlencoded',
            data: {
                message: message,
                dh: timestamp
            },
            success: function (response) {
                if (response.status === 'success') {
                    $('#alarmModal').modal('hide');
                    $('#alarmForm')[0].reset();

                    Swal.fire({
                        title: "Alarme enregistr&eacute;e !",
                        html: `
                            <p><strong>Message&nbsp;:</strong> ${message}</p>
                            <p><strong>Date &amp; Heure&nbsp;:</strong> ${new Date(timestamp).toLocaleString()}</p>
                        `,
                        icon: "success",
                        confirmButtonText: "OK"
                    });
                } else {
                    Swal.fire({
                        title: "Erreur",
                        html: `<p><strong>D&eacute;tail&nbsp;:</strong> ${response.message}</p>`,
                        icon: "error",
                        confirmButtonText: "OK"
                    });
                }
            },
            error: function (xhr, status, error) {
                console.error('Erreur lors de la création de l\'alarme', error);
                const errorMessage = xhr.responseText || 'Une erreur inconnue est survenue.';

                Swal.fire({
                    title: "Erreur lors de l&#39;enregistrement",
                    html: `<p><strong>D&eacute;tail&nbsp;:</strong> ${errorMessage}</p>`,
                    icon: "error",
                    confirmButtonText: "OK"
                });
            }
        });
    });
});

let loc = window.location;
let protocol = (loc.protocol === "https:") ? "wss://" : "ws://";

let ws_notif_url = protocol + loc.host + _CONTEXT_PATH + "/ws/notifications";
let ws_notif = new WebSocket(ws_notif_url);


ws_notif.onopen = () => console.log("CONNECTED NOTIF");
ws_notif.onerror = (e) => console.error("ERROR ALARM", e);

ws_notif.onmessage = function(event) {
    const message = event.data;
    getNotification();

    try {
        const data = JSON.parse(message);
        if (data.refUser === id_user_conn) {
            if (Notification.permission === "granted") {
                new Notification("Notification", {
                    body: data.message
                });
            } else if (Notification.permission !== "denied") {
                Notification.requestPermission().then(permission => {
                    if (permission === "granted") {
                        new Notification("Notification", {
                            body: data.message
                        });
                    }
                });
            }
        }
    } catch (e) {
        console.log(e);
    }
};


let wsUrl = protocol + loc.host + _CONTEXT_PATH + "/ws/alarm";
let ws_alarm = new WebSocket(wsUrl);

ws_alarm.onopen = () => console.log("CONNECTED ALARM");
ws_alarm.onerror = (e) => console.error("ERROR NOTIF", e);

ws_alarm.onmessage = function(event) {
    const data = JSON.parse(event.data);

    if (data.refUser === id_user_conn) {
        const showNotification = () => {
            new Notification("Il est temps !", {
                body: data.message
            });
        };

        if (Notification.permission === "granted") {
            showNotification();
        } else if (Notification.permission !== "denied") {
            Notification.requestPermission().then(permission => {
                if (permission === "granted") showNotification();
            });
        }

        const oldTitle = document.title;
        const blinkInterval = setInterval(() => {
            document.title = document.title === "[ALERTE]" ? oldTitle : "[ALERTE]";
        }, 1000);

        window.addEventListener('focus', () => {
            clearInterval(blinkInterval);
            document.title = oldTitle;
        });

        Swal.fire({
            title: "Il est temps !",
            html: `<strong>${data.message}</strong>`,
            icon: "info",
            confirmButtonText: "OK"
        });
    }
};
