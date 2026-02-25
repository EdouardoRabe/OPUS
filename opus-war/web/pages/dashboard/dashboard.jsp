<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Historique" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="alumni.Specialiteprofil" %>
<%@ page import="alumni.Publicationhashtag" %>

<%
    UserEJB uEJB = (UserEJB) session.getAttribute("u");
    if (uEJB == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    Connection conn = null;
    int totalAlumni = 0;
    int totalPubs = 0;
    int totalContribs = 0;
    
    List<Map<String, Object>> dailyLogins = new ArrayList<Map<String, Object>>();
    List<Map<String, Object>> recentActions = new ArrayList<Map<String, Object>>();

    try {
        conn = new UtilDB().GetConn();

        // 1. Total Alumni
        ProfilLib[] profils = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, conn, " and estactif = 1");
        if (profils != null) totalAlumni = profils.length;

        // 2. Total Publications
        Publication[] publications = (Publication[]) CGenUtil.rechercher(new Publication(), null, null, conn, " and etat = 1");
        if (publications != null) totalPubs = publications.length;

        // 3. Logins per Day (Last 7 days logic in Java)
        // Fetch last logins (e.g., last 1000 or from last 7 days)
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_YEAR, -7);
        java.sql.Date sevenDaysAgo = new java.sql.Date(cal.getTimeInMillis());
        
        Historique[] logs = (Historique[]) CGenUtil.rechercher(new Historique(), null, null, conn, 
            " and action = 'login' and datehistorique >= '" + sevenDaysAgo + "' order by datehistorique desc");
        
        if (logs != null) {
            Map<String, Integer> counts = new LinkedHashMap<String, Integer>();
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
            for (Historique h : logs) {
                String dStr = sdf.format(h.getDatehistorique());
                counts.put(dStr, counts.getOrDefault(dStr, 0) + 1);
            }
            int limit = 0;
            for (Map.Entry<String, Integer> entry : counts.entrySet()) {
                if (limit++ >= 7) break;
                Map<String, Object> m = new HashMap<String, Object>();
                m.put("date", sdf.parse(entry.getKey()));
                m.put("count", entry.getValue());
                dailyLogins.add(m);
            }
        }

        // 4. Specialities Distribution
        List<Map<String, Object>> topSpecialities = new ArrayList<Map<String, Object>>();
        Specialiteprofil[] specProfs = (Specialiteprofil[]) CGenUtil.rechercher(new Specialiteprofil(), null, null, conn, "");
        if (specProfs != null) {
            Map<String, Integer> specCounts = new HashMap<String, Integer>();
            for (Specialiteprofil sp : specProfs) {
                specCounts.put(sp.getIdspecialite(), specCounts.getOrDefault(sp.getIdspecialite(), 0) + 1);
            }
            
            // Sort by count
            List<Map.Entry<String, Integer>> list = new ArrayList<Map.Entry<String, Integer>>(specCounts.entrySet());
            Collections.sort(list, new Comparator<Map.Entry<String, Integer>>() {
                public int compare(Map.Entry<String, Integer> o1, Map.Entry<String, Integer> o2) {
                    return o2.getValue().compareTo(o1.getValue());
                }
            });
            
            // Take top 5
            Specialite sTmp = new Specialite();
            int i = 0;
            for (Map.Entry<String, Integer> entry : list) {
                if (i++ >= 5) break;
                Specialite[] sArr = (Specialite[]) CGenUtil.rechercher(sTmp, null, null, conn, " and idspecialite = '" + entry.getKey() + "'");
                if (sArr != null && sArr.length > 0) {
                    Map<String, Object> m = new HashMap<String, Object>();
                    m.put("libelle", sArr[0].getLibelle());
                    m.put("count", entry.getValue());
                    topSpecialities.add(m);
                }
            }
        }
        request.setAttribute("topSpecs", topSpecialities);

        // 5. Most Demanded Specialities (from Publication Hashtags)
        List<Map<String, Object>> demandedSpecs = new ArrayList<Map<String, Object>>();
        Publicationhashtag phTmp = new Publicationhashtag();
        Publicationhashtag[] pHashtags = (Publicationhashtag[]) CGenUtil.rechercher(phTmp, null, null, conn, " and typetag = 'SPECIALITE'");
        if (pHashtags != null) {
            Map<String, Integer> demandCounts = new HashMap<String, Integer>();
            for (Publicationhashtag ph : pHashtags) {
                if (ph.getIdref() != null) {
                    demandCounts.put(ph.getIdref(), demandCounts.getOrDefault(ph.getIdref(), 0) + 1);
                }
            }
            List<Map.Entry<String, Integer>> demandList = new ArrayList<Map.Entry<String, Integer>>(demandCounts.entrySet());
            Collections.sort(demandList, new Comparator<Map.Entry<String, Integer>>() {
                public int compare(Map.Entry<String, Integer> o1, Map.Entry<String, Integer> o2) {
                    return o2.getValue().compareTo(o1.getValue());
                }
            });
            
            Specialite sTmp = new Specialite();
            int j = 0;
            for (Map.Entry<String, Integer> entry : demandList) {
                if (j++ >= 5) break;
                Specialite[] sArr = (Specialite[]) CGenUtil.rechercher(sTmp, null, null, conn, " and idspecialite = '" + entry.getKey() + "'");
                if (sArr != null && sArr.length > 0) {
                    Map<String, Object> dm = new HashMap<String, Object>();
                    dm.put("libelle", sArr[0].getLibelle());
                    dm.put("count", entry.getValue());
                    demandedSpecs.add(dm);
                }
            }
        }
        request.setAttribute("demandedSpecs", demandedSpecs);

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) conn.close();
    }
%>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;500;600;700&family=Fira+Sans:wght@300;400;500;600;700&display=swap');

    :root {
        --dash-primary: #1E40AF;
        --dash-secondary: #3B82F6;
        --dash-accent: #F59E0B;
        --dash-bg: #F8FAFC;
        --dash-card-bg: #ffffff;
        --dash-text: #1E3A8A;
        --dash-text-light: #475569;
        --dash-border: #E2E8F0;
        --dash-success: #10B981;
        --dash-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
        --dash-shadow-hover: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
    }

    body {
        background-color: var(--dash-bg);
        font-family: 'Fira Sans', sans-serif;
        margin: 0;
        color: var(--dash-text);
        -webkit-font-smoothing: antialiased;
    }

    .dash-container {
        padding: 40px 24px;
        max-width: 1440px;
        margin: 0 auto;
    }

    .dash-header {
        margin-bottom: 32px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .dash-title {
        font-size: 28px;
        font-weight: 700;
        margin: 0;
        background: linear-gradient(135deg, var(--dash-primary), var(--dash-secondary));
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }

    .dash-stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 20px;
        margin-bottom: 32px;
    }

    .dash-stat-card {
        background: var(--dash-card-bg);
        border: 1px solid var(--dash-border);
        border-radius: 12px;
        padding: 24px;
        box-shadow: var(--dash-shadow);
        transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        cursor: pointer;
    }

    .dash-stat-card:hover {
        transform: translateY(-2px);
        box-shadow: var(--dash-shadow-hover);
    }

    .dash-stat-label {
        font-size: 14px;
        color: var(--dash-text-light);
        margin-bottom: 8px;
        font-weight: 500;
    }

    .dash-stat-value {
        font-size: 32px;
        font-weight: 700;
        color: var(--dash-text);
    }

    .dash-stat-icon {
        float: right;
        font-size: 20px;
        width: 48px;
        height: 48px;
        border-radius: 10px;
        background: #EFF6FF;
        color: var(--dash-primary);
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .dash-main-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 24px;
        margin-bottom: 24px;
    }

    .dash-full-grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 24px;
    }

    @media (max-width: 1024px) {
        .dash-main-grid {
            grid-template-columns: 1fr;
        }
    }

    .dash-card {
        background: var(--dash-card-bg);
        border: 1px solid var(--dash-border);
        border-radius: 12px;
        padding: 32px;
        box-shadow: var(--dash-shadow);
    }

    .dash-card-title {
        font-size: 16px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: var(--dash-text-light);
        margin: 0 0 24px 0;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .dash-card-title i {
        color: var(--dash-primary);
        font-size: 1.2em;
    }

    @media (prefers-reduced-motion: reduce) {
        .dash-stat-card, .dash-stat-card:hover {
            transform: none !important;
            transition: none !important;
        }
    }

    /* Chart Wrapper */
    .chart-wrapper {
        position: relative;
        height: 350px;
        width: 100%;
    }
</style>

<script src="<%= request.getContextPath() %>/chartPlugins/jquery.min.js"></script>
<script src="<%= request.getContextPath() %>/chartPlugins/Chart.min.js"></script>

<div class="dash-container">
    <div class="dash-header">
        <div class="dash-date"><%= new java.text.SimpleDateFormat("EEE, d MMM yyyy").format(new java.util.Date()) %></div>
    </div>

    <!-- Quick Stats -->
    <div class="dash-stats-grid">
        <div class="dash-stat-card">
            <div class="dash-stat-icon"><i class="bi bi-people-fill"></i></div>
            <div class="dash-stat-label">Total Alumni</div>
            <div class="dash-stat-value"><%= totalAlumni %></div>
        </div>
        <div class="dash-stat-card">
            <div class="dash-stat-icon"><i class="bi bi-newspaper"></i></div>
            <div class="dash-stat-label">Publications</div>
            <div class="dash-stat-value"><%= totalPubs %></div>
        </div>
        <div class="dash-stat-card">
            <div class="dash-stat-icon"><i class="bi bi-graph-up-arrow"></i></div>
            <div class="dash-stat-label">Connexions (7j)</div>
            <%
                int logins7j = 0;
                for(Map m : dailyLogins) logins7j += (Integer)m.get("count");
            %>
            <div class="dash-stat-value"><%= logins7j %></div>
        </div>
    </div>

    <div class="dash-main-grid">
        <!-- Connections Chart -->
        <div class="dash-card">
            <h2 class="dash-card-title"><i class="bi bi-activity"></i>Fr&eacute;quentation (Connexions/Jour)</h2>
            <div class="chart-wrapper">
                <canvas id="loginChart"></canvas>
            </div>
        </div>
        <div class="dash-card">
            <h2 class="dash-card-title"><i class="bi bi-pie-chart-fill"></i>R&eacute;partition des Sp&eacute;cialit&eacute;s</h2>
            <div class="chart-wrapper">
                <canvas id="specChart"></canvas>
            </div>
        </div>
    </div>

    <!-- Second Row -->
    <div class="dash-full-grid">
        <div class="dash-card">
            <h2 class="dash-card-title"><i class="bi bi-bar-chart-fill"></i>Sp&eacute;cialit&eacute;s les plus demand&eacute;es (Hashtags)</h2>
            <div class="chart-wrapper">
                <canvas id="demandChart"></canvas>
            </div>
        </div>
    </div>
</div>

<script>
<%
    List<Map<String, Object>> displayLogins = new ArrayList<Map<String, Object>>(dailyLogins);
    Collections.reverse(displayLogins);
    
    StringBuilder labels = new StringBuilder();
    StringBuilder data = new StringBuilder();
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM");
    
    for(int i=0; i<displayLogins.size(); i++) {
        Map m = displayLogins.get(i);
        labels.append("'").append(sdf.format((java.util.Date)m.get("date"))).append("'");
        data.append(m.get("count"));
        if(i < displayLogins.size()-1) {
            labels.append(",");
            data.append(",");
        }
    }
%>

$(function() {
    var ctx = document.getElementById('loginChart').getContext('2d');
    var chart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [<%= labels.toString() %>],
            datasets: [{
                label: 'Connexions',
                data: [<%= data.toString() %>],
                borderColor: '#008BFF',
                backgroundColor: 'rgba(0, 139, 255, 0.1)',
                borderWidth: 3,
                pointBackgroundColor: '#fff',
                pointBorderColor: '#008BFF',
                pointRadius: 5,
                pointHoverRadius: 7,
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            legend: {
                display: false
            },
            scales: {
                yAxes: [{
                    ticks: {
                        beginAtZero: true,
                        stepSize: 1,
                        fontFamily: "'Fira Sans', sans-serif",
                        fontColor: '#64748b',
                        padding: 10
                    },
                    gridLines: {
                        color: '#F1F5F9',
                        drawBorder: false
                    }
                }],
                xAxes: [{
                    ticks: {
                        fontFamily: "'Fira Sans', sans-serif",
                        fontColor: '#64748b',
                        padding: 10
                    },
                    gridLines: {
                        display: false
                    }
                }]
            },
            tooltips: {
                backgroundColor: '#0F172A',
                titleFontFamily: "'Fira Sans', sans-serif",
                bodyFontFamily: "'Fira Sans', sans-serif",
                titleFontSize: 14,
                bodyFontSize: 13,
                cornerRadius: 4,
                padding: 12,
                displayColors: false
            }
        }
    });

    // Specialities Chart
    <%
        List<Map<String, Object>> tSpecs = (List<Map<String, Object>>) request.getAttribute("topSpecs");
        StringBuilder sLabels = new StringBuilder();
        StringBuilder sData = new StringBuilder();
        if (tSpecs != null) {
            for (int j = 0; j < tSpecs.size(); j++) {
                Map m = tSpecs.get(j);
                sLabels.append("'").append(((String)m.get("libelle")).replace("'", "\\'")).append("'");
                sData.append(m.get("count"));
                if (j < tSpecs.size() - 1) {
                    sLabels.append(",");
                    sData.append(",");
                }
            }
        }
    %>
    var ctxSpec = document.getElementById('specChart').getContext('2d');
    var specChart = new Chart(ctxSpec, {
        type: 'doughnut',
        data: {
            labels: [<%= sLabels.toString() %>],
            datasets: [{
                data: [<%= sData.toString() %>],
                backgroundColor: [
                    '#008BFF',
                    '#5B23FF',
                    '#10b981',
                    '#f59e0b',
                    '#ef4444',
                    '#8b5cf6'
                ],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutoutPercentage: 75,
            legend: {
                position: 'bottom',
                labels: {
                    usePointStyle: true,
                    padding: 25,
                    fontFamily: "'Fira Sans', sans-serif",
                    fontColor: '#64748b',
                    fontSize: 12
                }
            },
            tooltips: {
                backgroundColor: '#0F172A',
                titleFontFamily: "'Fira Sans', sans-serif",
                bodyFontFamily: "'Fira Sans', sans-serif",
                cornerRadius: 4,
                padding: 12,
                displayColors: true
            }
        }
    });

    // Demand Chart
    <%
        List<Map<String, Object>> dSpecs = (List<Map<String, Object>>) request.getAttribute("demandedSpecs");
        StringBuilder dLabels = new StringBuilder();
        StringBuilder dData = new StringBuilder();
        if (dSpecs != null) {
            for (int k = 0; k < dSpecs.size(); k++) {
                Map m = dSpecs.get(k);
                dLabels.append("'").append(((String)m.get("libelle")).replace("'", "\\'")).append("'");
                dData.append(m.get("count"));
                if (k < dSpecs.size() - 1) {
                    dLabels.append(",");
                    dData.append(",");
                }
            }
        }
    %>
    var ctxDemand = document.getElementById('demandChart').getContext('2d');
    var demandChart = new Chart(ctxDemand, {
        type: 'horizontalBar',
        data: {
            labels: [<%= dLabels.toString() %>],
            datasets: [{
                label: 'Nombre de mentions',
                data: [<%= dData.toString() %>],
                backgroundColor: '#5B23FF',
                borderRadius: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            legend: {
                display: false
            },
            scales: {
                xAxes: [{
                    ticks: {
                        beginAtZero: true,
                        stepSize: 1,
                        fontFamily: "'Fira Sans', sans-serif",
                        fontColor: '#64748b',
                        padding: 10
                    },
                    gridLines: {
                        color: '#F1F5F9',
                        drawBorder: false
                    }
                }],
                yAxes: [{
                    ticks: {
                        fontFamily: "'Fira Sans', sans-serif",
                        fontColor: '#64748b',
                        padding: 10
                    },
                    gridLines: {
                        display: false
                    }
                }]
            },
            tooltips: {
                backgroundColor: '#0F172A',
                titleFontFamily: "'Fira Sans', sans-serif",
                bodyFontFamily: "'Fira Sans', sans-serif",
                cornerRadius: 4,
                padding: 12
            }
        }
    });
});
</script>
