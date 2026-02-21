$(function() {
    // Rendre le div draggable
    if ($.fn.draggable) {
        $("#mon-div-flottant").draggable({
            handle: "#drag-handle",
            containment: "window"
        });
    }

    // Initialiser le stockage du jour
    const today = new Date().toLocaleDateString();
    if (localStorage.getItem("timerDay") !== today) {
        localStorage.setItem("timerDay", today);
        localStorage.setItem("dailyTotalTime", "0");
    }

    // Chargement du son
    const alertSound = new Audio(_CONTEXT_PATH + "/assets/audio/notify.mp3");

    // Fonction pour formater le temps
    function formatTime(ms) {
        let totalSeconds = Math.floor(ms / 1000);
        let hours = Math.floor(totalSeconds / 3600);
        let minutes = Math.floor((totalSeconds % 3600) / 60);
        let seconds = totalSeconds % 60;
        return (hours < 10 ? "0" + hours : hours) + ":" + 
               (minutes < 10 ? "0" + minutes : minutes) + ":" + 
               (seconds < 10 ? "0" + seconds : seconds);
    }

    // Fonction pour mettre à jour l'affichage
    window.updateTimerDisplay = function() {
        let tasks = JSON.parse(localStorage.getItem("runningTasks") || "{}");
        let listElement = $("#timer-list");
        if (listElement.length === 0) return;
        
        listElement.empty();

        let hasTasks = false;
        let now = new Date().getTime();

        for (let id in tasks) {
            hasTasks = true;
            let task = tasks[id];
            let elapsed = task.accumulatedTime || 0;
            if (task.status === "running" && task.lastStartTime) {
                elapsed += (now - task.lastStartTime);
            }
            
            let statusLabel = task.status === "paused" ? " (Pause)" : "";
            let color = task.status === "paused" ? "#f39c12" : "#007bff";
            
            // Gestion de l'estimation et des couleurs
            if (task.estimation && task.estimation > 0) {
                let estimationMs = task.estimation * 60 * 1000;
                if (elapsed >= estimationMs) {
                    color = "#e74c3c"; // Rouge (dépassé)
                    if (task.status === "running" && !task.alertPlayed) {
                        alertSound.play().catch(e => console.log("Erreur audio:", e));
                        task.alertPlayed = true;
                        localStorage.setItem("runningTasks", JSON.stringify(tasks));
                    }
                } else if (elapsed >= (estimationMs * 0.9)) {
                    color = "#e67e22"; // Orange (90% du temps)
                }
            }

            // Construction du lien vers la tâche
            let context = typeof _CONTEXT_PATH !== 'undefined' ? _CONTEXT_PATH : '/opus';
            let taskLink = `${context}/pages/module.jsp?but=tache/tache-fiche.jsp&id=${id}`;
            
            listElement.append(`
                <li id="timer-item-${id}" style="padding: 8px; border-bottom: 1px solid #eee; display: flex; flex-direction: column;">
                    <div style="font-weight: bold; font-size: 11px; color: #333;">Tâche: <a href="${taskLink}" style="color: #007bff; text-decoration: none; border-bottom: 1px dotted #007bff;">${id}</a>${statusLabel}</div>
                    <div style="font-size: 14px; color: ${color}; font-family: monospace; font-weight: bold;">
                        ${formatTime(elapsed)} 
                        ${task.estimation ? `<span style="font-size: 10px; color: #999; font-weight: normal;"> / ${task.estimation}m</span>` : ''}
                    </div>
                </li>
            `);
        }

        if (!hasTasks) {
            listElement.append('<li style="color: #666; font-style: italic; text-align: center; font-size: 12px; padding: 10px;">Aucune tâche en cours</li>');
        }

        // Affichage du total journalier
        updateDailyTotal();
    };

    function updateDailyTotal() {
        let tasks = JSON.parse(localStorage.getItem("runningTasks") || "{}");
        let dailyFinished = parseInt(localStorage.getItem("dailyTotalTime") || "0");
        let now = new Date().getTime();
        let activeTotal = 0;

        for (let id in tasks) {
            let task = tasks[id];
            activeTotal += task.accumulatedTime || 0;
            if (task.status === "running" && task.lastStartTime) {
                activeTotal += (now - task.lastStartTime);
            }
        }

        let totalMs = dailyFinished + activeTotal;
        
        if ($("#daily-total-container").length === 0) {
            $("#timer-content").after(`
                <div id="daily-total-container" style="padding: 10px; background: #f8f9fa; border-top: 1px solid #ddd; border-radius: 0 0 8px 8px; font-size: 12px;">
                    <div style="color: #666; margin-bottom: 2px;">Total journée :</div>
                    <div id="daily-total-value" style="font-weight: bold; font-size: 15px; color: #28a745; font-family: monospace;">${formatTime(totalMs)}</div>
                </div>
            `);
        } else {
            $("#daily-total-value").text(formatTime(totalMs));
        }
    }

    // Fonctions globales
    window.startTaskTimer = function(id, estimation) {
        let tasks = JSON.parse(localStorage.getItem("runningTasks") || "{}");
        if (!tasks[id]) {
            tasks[id] = {
                accumulatedTime: 0,
                lastStartTime: new Date().getTime(),
                status: "running",
                estimation: parseFloat(estimation) || 0,
                alertPlayed: false
            };
        } else if (tasks[id].status === "paused") {
            tasks[id].status = "running";
            tasks[id].lastStartTime = new Date().getTime();
            if (estimation) tasks[id].estimation = parseFloat(estimation);
        }
        localStorage.setItem("runningTasks", JSON.stringify(tasks));
        window.updateTimerDisplay();
    };

    window.pauseTaskTimer = function(id) {
        let tasks = JSON.parse(localStorage.getItem("runningTasks") || "{}");
        if (tasks[id] && tasks[id].status === "running") {
            let now = new Date().getTime();
            tasks[id].accumulatedTime = (tasks[id].accumulatedTime || 0) + (now - tasks[id].lastStartTime);
            tasks[id].status = "paused";
            tasks[id].lastStartTime = null;
            localStorage.setItem("runningTasks", JSON.stringify(tasks));
            window.updateTimerDisplay();
        }
    };

    window.resumeTaskTimer = function(id, estimation) {
        window.startTaskTimer(id, estimation); 
    };

    window.stopTaskTimer = function(id) {
        let tasks = JSON.parse(localStorage.getItem("runningTasks") || "{}");
        if (tasks[id]) {
            let now = new Date().getTime();
            let finalElapsed = tasks[id].accumulatedTime || 0;
            if (tasks[id].status === "running" && tasks[id].lastStartTime) {
                finalElapsed += (now - tasks[id].lastStartTime);
            }
            
            // Ajouter au total journalier permanent
            let dailyTotal = parseInt(localStorage.getItem("dailyTotalTime") || "0");
            localStorage.setItem("dailyTotalTime", (dailyTotal + finalElapsed).toString());
            
            delete tasks[id];
            localStorage.setItem("runningTasks", JSON.stringify(tasks));
            window.updateTimerDisplay();
        }
    };

    // Démarrer l'intervalle de mise à jour
    setInterval(window.updateTimerDisplay, 1000);
    window.updateTimerDisplay();
});