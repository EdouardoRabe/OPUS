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

        // 4. (Removed Recent Actions)

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) conn.close();
    }
%>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap');

    :root {
        --dash-primary: #008BFF;
        --dash-secondary: #5B23FF;
        --dash-bg: #f8fafc;
        --dash-card-bg: #ffffff;
        --dash-text: #1e293b;
        --dash-text-light: #64748b;
        --dash-border: #e2e8f0;
        --dash-success: #10b981;
    }

    body {
        background-color: var(--dash-bg);
        font-family: 'Plus Jakarta Sans', sans-serif;
        margin: 0;
        color: var(--dash-text);
    }

    .dash-container {
        padding: 24px;
        max-width: 1200px;
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
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        transition: transform 0.2s, box-shadow 0.2s;
    }

    .dash-stat-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
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
        font-size: 24px;
        padding: 12px;
        border-radius: 12px;
        background: #f0f7ff;
        color: var(--dash-primary);
    }

    .dash-main-grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 24px;
    }

    .dash-card {
        background: var(--dash-card-bg);
        border: 1px solid var(--dash-border);
        border-radius: 20px;
        padding: 30px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
    }

    .dash-card-title {
        font-size: 20px;
        font-weight: 700;
        margin: 0 0 25px 0;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .dash-card-title i {
        color: var(--dash-primary);
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
                        fontFamily: 'Plus Jakarta Sans',
                        fontColor: '#64748b'
                    },
                    gridLines: {
                        color: '#f1f5f9'
                    }
                }],
                xAxes: [{
                    ticks: {
                        fontFamily: 'Plus Jakarta Sans',
                        fontColor: '#64748b'
                    },
                    gridLines: {
                        display: false
                    }
                }]
            },
            tooltips: {
                backgroundColor: '#1e293b',
                titleFontFamily: 'Plus Jakarta Sans',
                bodyFontFamily: 'Plus Jakarta Sans',
                cornerRadius: 8,
                padding: 12
            }
        }
    });
});
</script>
