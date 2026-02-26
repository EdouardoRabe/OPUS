<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Historique" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="alumni.Specialiteprofil" %>
<%@ page import="alumni.Publicationhashtag" %>
<%@ page import="alumni.Signalementpublication" %>

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
    int totalSignalements = 0;
    
    List<Map<String, Object>> dailyLogins = new ArrayList<Map<String, Object>>();
    List<Map<String, Object>> reportedUsers = new ArrayList<Map<String, Object>>();

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
            
            Specialite sTmp2 = new Specialite();
            int j = 0;
            for (Map.Entry<String, Integer> entry : demandList) {
                if (j++ >= 5) break;
                Specialite[] sArr = (Specialite[]) CGenUtil.rechercher(sTmp2, null, null, conn, " and idspecialite = '" + entry.getKey() + "'");
                if (sArr != null && sArr.length > 0) {
                    Map<String, Object> dm = new HashMap<String, Object>();
                    dm.put("libelle", sArr[0].getLibelle());
                    dm.put("count", entry.getValue());
                    demandedSpecs.add(dm);
                }
            }
        }
        request.setAttribute("demandedSpecs", demandedSpecs);

        // 6. Signalements - Users with most reported publications
        Signalementpublication[] signalements = (Signalementpublication[]) CGenUtil.rechercher(
            new Signalementpublication(), null, null, conn, "");
        if (signalements != null) {
            totalSignalements = signalements.length;
            // Group signalements by idpublication
            Map<String, Integer> pubReportCounts = new HashMap<String, Integer>();
            for (Signalementpublication sig : signalements) {
                if (sig.getIdpublication() != null) {
                    pubReportCounts.put(sig.getIdpublication(), pubReportCounts.getOrDefault(sig.getIdpublication(), 0) + 1);
                }
            }
            // For each reported publication, find the author and accumulate reports per user
            Map<Integer, Integer> userReportCounts = new HashMap<Integer, Integer>();
            for (Map.Entry<String, Integer> e : pubReportCounts.entrySet()) {
                Publication pTmp = new Publication();
                Publication[] pArr = (Publication[]) CGenUtil.rechercher(pTmp, null, null, conn, " and idpublication = '" + e.getKey() + "'");
                if (pArr != null && pArr.length > 0) {
                    int authorId = pArr[0].getIdutilisateur();
                    userReportCounts.put(authorId, userReportCounts.getOrDefault(authorId, 0) + e.getValue());
                }
            }
            // Sort by report count desc
            List<Map.Entry<Integer, Integer>> userList = new ArrayList<Map.Entry<Integer, Integer>>(userReportCounts.entrySet());
            Collections.sort(userList, new Comparator<Map.Entry<Integer, Integer>>() {
                public int compare(Map.Entry<Integer, Integer> o1, Map.Entry<Integer, Integer> o2) {
                    return o2.getValue().compareTo(o1.getValue());
                }
            });
            // Top 5 with user names
            int rk = 0;
            for (Map.Entry<Integer, Integer> ue2 : userList) {
                if (rk++ >= 5) break;
                String uName = "Utilisateur #" + ue2.getKey();
                String idProfil = "";
                try {
                    ProfilLib[] pLib = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, conn, " and refuser = " + ue2.getKey());
                    if (pLib != null && pLib.length > 0) {
                        uName = pLib[0].getNom() + " " + pLib[0].getPrenom();
                        if (pLib[0].getIdprofil() != null) idProfil = pLib[0].getIdprofil();
                    }
                } catch(Exception ignored) {}
                Map<String, Object> rm = new HashMap<String, Object>();
                rm.put("name", uName);
                rm.put("count", ue2.getValue());
                rm.put("userId", ue2.getKey());
                rm.put("idprofil", idProfil);
                reportedUsers.add(rm);
            }
        }
        request.setAttribute("reportedUsers", reportedUsers);

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
        color: var(--dash-primary);
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

    /* Section Headers */
    .dash-section {
        margin-bottom: 32px;
    }

    .dash-section-title {
        font-size: 13px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        color: var(--dash-text-light);
        margin: 0 0 16px 0;
        padding-left: 4px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .dash-section-title::before {
        content: '';
        display: inline-block;
        width: 3px;
        height: 16px;
        background: var(--dash-primary);
        border-radius: 2px;
    }

    /* Chart Wrapper */
    .chart-wrapper {
        position: relative;
        height: 320px;
        width: 100%;
    }

    /* Ranked Table */
    .ranked-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0 8px;
    }

    .ranked-table th {
        font-size: 11px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: var(--dash-text-light);
        padding: 0 16px 8px;
        text-align: left;
        border-bottom: 1px solid var(--dash-border);
    }

    .ranked-table td {
        padding: 12px 16px;
        font-size: 14px;
        background: #FFFBEB;
        color: #92400E;
    }

    .ranked-table tr td:first-child {
        border-radius: 8px 0 0 8px;
        font-weight: 700;
        width: 40px;
        text-align: center;
    }

    .ranked-table tr td:last-child {
        border-radius: 0 8px 8px 0;
        font-weight: 700;
        text-align: center;
        width: 80px;
    }

    .rank-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 28px;
        height: 28px;
        border-radius: 50%;
        background: #FDE68A;
        color: #92400E;
        font-weight: 700;
        font-size: 13px;
    }

    .report-count {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 4px 12px;
        border-radius: 20px;
        background: #FEF3C7;
        color: #B45309;
        font-size: 13px;
        font-weight: 600;
    }

    .no-data-msg {
        text-align: center;
        padding: 40px 20px;
        color: var(--dash-text-light);
        font-size: 14px;
        font-style: italic;
    }
</style>

<script src="<%= request.getContextPath() %>/chartPlugins/jquery.min.js"></script>
<script src="<%= request.getContextPath() %>/chartPlugins/Chart.min.js"></script>

<div class="dash-container">
    <div class="dash-header">
        <div class="dash-date"><%= new java.text.SimpleDateFormat("EEE, d MMM yyyy").format(new java.util.Date()) %></div>
    </div>

    <!-- ═══════════════════ SECTION: KPIs ═══════════════════ -->
    <div class="dash-section">
        <h3 class="dash-section-title">Vue d'ensemble</h3>
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
            <div class="dash-stat-card">
                <div class="dash-stat-icon" style="background:#FEF3C7;color:#B45309;"><i class="bi bi-exclamation-triangle-fill"></i></div>
                <div class="dash-stat-label">Signalements</div>
                <div class="dash-stat-value"><%= totalSignalements %></div>
            </div>
        </div>
    </div>

    <!-- ═══════════════════ SECTION: ACTIVITE ═══════════════════ -->
    <div class="dash-section">
        <h3 class="dash-section-title">Activit&eacute;</h3>
        <!-- Frequentation: full width -->
        <div class="dash-card" style="margin-bottom:24px;">
            <h2 class="dash-card-title"><i class="bi bi-activity"></i>Fr&eacute;quentation (Connexions/Jour)</h2>
            <div class="chart-wrapper">
                <canvas id="loginChart"></canvas>
            </div>
        </div>
        <div class="dash-main-grid">
            <div class="dash-card">
                <h2 class="dash-card-title"><i class="bi bi-pie-chart-fill"></i>R&eacute;partition des Sp&eacute;cialit&eacute;s</h2>
                <div class="chart-wrapper">
                    <canvas id="specChart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══════════════════ SECTION: SPECIALITES ═══════════════════ -->
    <div class="dash-section">
        <h3 class="dash-section-title">Sp&eacute;cialit&eacute;s &amp; Tendances</h3>
        <div class="dash-main-grid">
            <div class="dash-card">
                <h2 class="dash-card-title"><i class="bi bi-bar-chart-fill"></i>Sp&eacute;cialit&eacute;s les plus demand&eacute;es (Hashtags)</h2>
                <div class="chart-wrapper">
                    <canvas id="demandChart"></canvas>
                </div>
            </div>
            <!-- ═══════════ MODERATION ═══════════ -->
            <div class="dash-card">
                <h2 class="dash-card-title" style="color:#B45309;"><i class="bi bi-shield-exclamation" style="color:#B45309;"></i>Utilisateurs les plus signal&eacute;s</h2>
                <% if (reportedUsers != null && !reportedUsers.isEmpty()) { %>
                <table class="ranked-table">
                    <thead>
                        <tr><th>#</th><th>Utilisateur</th><th>Signalements</th></tr>
                    </thead>
                    <tbody>
                    <% int rank = 1;
                       String ctx = request.getContextPath();
                       for (Map ru : reportedUsers) {
                           String profLink = ctx + "/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp&idprofil=" + ru.get("idprofil");
                    %>
                        <tr style="cursor:pointer;" onclick="window.location.href='<%= profLink %>'">
                            <td><span class="rank-badge"><%= rank++ %></span></td>
                            <td><a href="<%= profLink %>" style="color:#92400E;text-decoration:none;font-weight:600;"><%= ru.get("name") %></a></td>
                            <td><span class="report-count"><i class="bi bi-flag-fill"></i> <%= ru.get("count") %></span></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="no-data-msg">
                    <i class="bi bi-check-circle" style="font-size:24px;color:var(--dash-success);display:block;margin-bottom:8px;"></i>
                    Aucun signalement enregistr&eacute;.
                </div>
                <% } %>
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
    java.text.SimpleDateFormat sdf2 = new java.text.SimpleDateFormat("dd/MM");
    
    for(int ii=0; ii<displayLogins.size(); ii++) {
        Map m = displayLogins.get(ii);
        labels.append("'").append(sdf2.format((java.util.Date)m.get("date"))).append("'");
        data.append(m.get("count"));
        if(ii < displayLogins.size()-1) {
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
            for (int jj = 0; jj < tSpecs.size(); jj++) {
                Map m = tSpecs.get(jj);
                sLabels.append("'").append(((String)m.get("libelle")).replace("'", "\\'")).append("'");
                sData.append(m.get("count"));
                if (jj < tSpecs.size() - 1) {
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
