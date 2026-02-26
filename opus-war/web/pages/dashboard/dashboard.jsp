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
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');

    :root {
        --li-blue: #0a66c2;
        --li-blue-dark: #004182;
        --li-blue-light: #e8f3ff;
        --li-green: #057642;
        --li-green-light: #e2f6e9;
        --li-amber: #b24020;
        --li-amber-light: #fef3ed;
        --li-bg: #f4f2ee;
        --li-card: #ffffff;
        --li-text-primary: #191919;
        --li-text-secondary: #666666;
        --li-text-tertiary: #00000099;
        --li-border: #e0dfdc;
        --li-border-light: rgba(0,0,0,0.08);
        --li-shadow-sm: 0 0 0 1px rgba(0,0,0,0.08), 0 2px 4px rgba(0,0,0,0.05);
        --li-shadow-md: 0 0 0 1px rgba(0,0,0,0.08), 0 4px 12px rgba(0,0,0,0.12);
        --li-shadow-lg: 0 4px 24px rgba(0,0,0,0.15);
        --li-radius: 8px;
        --li-radius-lg: 12px;
    }

    .dash-container * { box-sizing: border-box; }

    .dash-container {
        padding: 24px 32px 48px;
        max-width: 1280px;
        margin: 0 auto;
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
    }

    /* ─── HERO HEADER ─── */
    .dash-hero {
        background: linear-gradient(135deg, #0a66c2 0%, #004182 60%, #00214d 100%);
        border-radius: var(--li-radius-lg);
        padding: 36px 40px;
        margin-bottom: 24px;
        color: #fff;
        position: relative;
        overflow: hidden;
        box-shadow: var(--li-shadow-md);
    }
    .dash-hero::before {
        content: '';
        position: absolute;
        top: -60%;
        right: -10%;
        width: 400px;
        height: 400px;
        background: radial-gradient(circle, rgba(255,255,255,0.08) 0%, transparent 70%);
        pointer-events: none;
    }
    .dash-hero::after {
        content: '';
        position: absolute;
        bottom: -40%;
        left: 20%;
        width: 300px;
        height: 300px;
        background: radial-gradient(circle, rgba(255,255,255,0.05) 0%, transparent 70%);
        pointer-events: none;
    }
    .dash-hero-inner {
        position: relative;
        z-index: 1;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .dash-hero h1 {
        font-size: 26px;
        font-weight: 700;
        margin: 0 0 6px 0;
        letter-spacing: -0.3px;
    }
    .dash-hero p {
        font-size: 14px;
        margin: 0;
        opacity: 0.85;
        font-weight: 400;
    }
    .dash-hero-date {
        font-size: 13px;
        font-weight: 500;
        background: rgba(255,255,255,0.15);
        backdrop-filter: blur(4px);
        padding: 8px 16px;
        border-radius: 20px;
        letter-spacing: 0.02em;
        white-space: nowrap;
    }

    /* ─── KPI STAT CARDS ─── */
    .dash-kpi-row {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    @media (max-width: 1024px) {
        .dash-kpi-row { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 600px) {
        .dash-kpi-row { grid-template-columns: 1fr; }
    }
    .dash-kpi {
        background: var(--li-card);
        border-radius: var(--li-radius-lg);
        padding: 24px;
        box-shadow: var(--li-shadow-sm);
        transition: box-shadow 0.25s ease, transform 0.25s ease;
        position: relative;
        overflow: hidden;
    }
    .dash-kpi:hover {
        box-shadow: var(--li-shadow-md);
        transform: translateY(-2px);
    }
    .dash-kpi-top {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        margin-bottom: 16px;
    }
    .dash-kpi-icon {
        width: 44px;
        height: 44px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }
    .dash-kpi-icon.blue   { background: var(--li-blue-light); color: var(--li-blue); }
    .dash-kpi-icon.green  { background: var(--li-green-light); color: var(--li-green); }
    .dash-kpi-icon.amber  { background: var(--li-amber-light); color: var(--li-amber); }
    .dash-kpi-label {
        font-size: 12px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.06em;
        color: var(--li-text-secondary);
        margin-bottom: 4px;
    }
    .dash-kpi-value {
        font-size: 32px;
        font-weight: 800;
        color: var(--li-text-primary);
        line-height: 1.1;
        letter-spacing: -0.5px;
    }
    .dash-kpi-footer {
        margin-top: 12px;
        font-size: 12px;
        color: var(--li-text-secondary);
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .dash-kpi-footer .trend-up   { color: var(--li-green); font-weight: 600; }
    .dash-kpi-footer .trend-warn { color: var(--li-amber); font-weight: 600; }
    .dash-kpi::after {
        content: '';
        position: absolute;
        bottom: 0; left: 0; right: 0;
        height: 3px;
        border-radius: 0 0 var(--li-radius-lg) var(--li-radius-lg);
    }
    .dash-kpi.kpi-alumni::after    { background: var(--li-blue); }
    .dash-kpi.kpi-pubs::after      { background: #7c3aed; }
    .dash-kpi.kpi-connexions::after { background: var(--li-green); }
    .dash-kpi.kpi-signalements::after { background: var(--li-amber); }

    /* ─── SECTION TITLES ─── */
    .dash-section {
        margin-bottom: 24px;
    }
    .dash-section-header {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 16px;
        padding-left: 2px;
    }
    .dash-section-header .section-icon {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        background: var(--li-blue-light);
        color: var(--li-blue);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
    }
    .dash-section-header h2 {
        font-size: 18px;
        font-weight: 700;
        color: var(--li-text-primary);
        margin: 0;
        letter-spacing: -0.2px;
    }

    /* ─── CARDS ─── */
    .dash-card {
        background: var(--li-card);
        border-radius: var(--li-radius-lg);
        box-shadow: var(--li-shadow-sm);
        overflow: hidden;
        transition: box-shadow 0.25s ease;
    }
    .dash-card:hover {
        box-shadow: var(--li-shadow-md);
    }
    .dash-card-head {
        padding: 20px 24px 0;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .dash-card-head h3 {
        font-size: 15px;
        font-weight: 700;
        color: var(--li-text-primary);
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .dash-card-head h3 i {
        font-size: 18px;
        color: var(--li-blue);
    }
    .dash-card-body {
        padding: 20px 24px 24px;
    }

    /* ─── GRID LAYOUTS ─── */
    .dash-grid-2 {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;
    }
    .dash-grid-full {
        display: grid;
        grid-template-columns: 1fr;
        gap: 16px;
        margin-bottom: 24px;
    }
    @media (max-width: 900px) {
        .dash-grid-2 { grid-template-columns: 1fr; }
    }
    .dash-grid-3-1 {
        display: grid;
        grid-template-columns: 1.6fr 1fr;
        gap: 16px;
    }
    @media (max-width: 900px) {
        .dash-grid-3-1 { grid-template-columns: 1fr; }
    }

    /* ─── CHART WRAPPER ─── */
    .chart-wrapper {
        position: relative;
        height: 300px;
        width: 100%;
    }

    /* ─── MODERATION TABLE ─── */
    .mod-table {
        width: 100%;
        border-collapse: collapse;
    }
    .mod-table thead th {
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: var(--li-text-secondary);
        padding: 12px 16px;
        text-align: left;
        border-bottom: 2px solid var(--li-border);
        background: #fafaf8;
    }
    .mod-table tbody tr {
        border-bottom: 1px solid var(--li-border-light);
        transition: background 0.15s ease;
        cursor: pointer;
    }
    .mod-table tbody tr:hover {
        background: #f8f8f6;
    }
    .mod-table tbody tr:last-child {
        border-bottom: none;
    }
    .mod-table td {
        padding: 14px 16px;
        font-size: 14px;
        color: var(--li-text-primary);
        vertical-align: middle;
    }
    .mod-rank {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 28px;
        height: 28px;
        border-radius: 50%;
        font-weight: 700;
        font-size: 12px;
    }
    .mod-rank.gold   { background: #fef3c7; color: #92400e; }
    .mod-rank.silver { background: #f1f5f9; color: #475569; }
    .mod-rank.bronze { background: #fde9d9; color: #9a3412; }
    .mod-rank.plain  { background: #f4f2ee; color: #666; }
    .mod-user-cell {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .mod-user-avatar {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--li-blue-light), #dbeafe);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
        color: var(--li-blue);
        flex-shrink: 0;
    }
    .mod-user-name {
        font-weight: 600;
        color: var(--li-text-primary);
        font-size: 14px;
        text-decoration: none;
    }
    .mod-user-name:hover {
        color: var(--li-blue);
        text-decoration: underline;
    }
    .mod-badge {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 700;
        background: #fef2f2;
        color: #dc2626;
    }
    .mod-badge i { font-size: 11px; }

    .no-data-msg {
        text-align: center;
        padding: 48px 24px;
        color: var(--li-text-secondary);
        font-size: 14px;
    }
    .no-data-msg i {
        font-size: 32px;
        color: var(--li-green);
        display: block;
        margin-bottom: 12px;
    }

    /* ─── ANIMATIONS ─── */
    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(16px); }
        to   { opacity: 1; transform: translateY(0); }
    }
    .dash-kpi, .dash-card {
        animation: fadeInUp 0.45s ease both;
    }
    .dash-kpi:nth-child(1) { animation-delay: 0.05s; }
    .dash-kpi:nth-child(2) { animation-delay: 0.10s; }
    .dash-kpi:nth-child(3) { animation-delay: 0.15s; }
    .dash-kpi:nth-child(4) { animation-delay: 0.20s; }
    .dash-card { animation-delay: 0.25s; }

    @media (prefers-reduced-motion: reduce) {
        .dash-kpi, .dash-card { animation: none !important; transform: none !important; transition: none !important; }
    }
</style>

<script src="<%= request.getContextPath() %>/chartPlugins/jquery.min.js"></script>
<script src="<%= request.getContextPath() %>/chartPlugins/Chart.min.js"></script>

<%
    // Compute logins7j early for the hero
    int logins7j = 0;
    for(Map m2 : dailyLogins) logins7j += (Integer)m2.get("count");
    String ctxPath = request.getContextPath();
%>

<div class="dash-container">

    <!-- ═══════════════ HERO HEADER ═══════════════ -->
    <div class="dash-hero">
        <div class="dash-hero-inner">
            <div>
                <h1>Tableau de bord</h1>
                <p>Bienvenue, <%= uEJB.getUser().getNomuser() %> &mdash; voici un aper&ccedil;u de votre plateforme.</p>
            </div>
            <div class="dash-hero-date">
                <i class="bi bi-calendar3"></i>&nbsp;
                <%= new java.text.SimpleDateFormat("EEEE d MMMM yyyy", new java.util.Locale("fr")).format(new java.util.Date()) %>
            </div>
        </div>
    </div>

    <!-- ═══════════════ KPI CARDS ═══════════════ -->
    <div class="dash-kpi-row">
        <div class="dash-kpi kpi-alumni">
            <div class="dash-kpi-top">
                <div>
                    <div class="dash-kpi-label">Total Alumni</div>
                    <div class="dash-kpi-value"><%= totalAlumni %></div>
                </div>
                <div class="dash-kpi-icon blue"><i class="bi bi-people-fill"></i></div>
            </div>
            <div class="dash-kpi-footer">
                <span class="trend-up"><i class="bi bi-mortarboard-fill"></i></span>
                Membres inscrits
            </div>
        </div>
        <div class="dash-kpi kpi-pubs">
            <div class="dash-kpi-top">
                <div>
                    <div class="dash-kpi-label">Publications</div>
                    <div class="dash-kpi-value"><%= totalPubs %></div>
                </div>
                <div class="dash-kpi-icon blue" style="background:#f3e8ff;color:#7c3aed;"><i class="bi bi-file-richtext-fill"></i></div>
            </div>
            <div class="dash-kpi-footer">
                <span class="trend-up" style="color:#7c3aed;"><i class="bi bi-pen-fill"></i></span>
                Contenus actifs
            </div>
        </div>
        <div class="dash-kpi kpi-connexions">
            <div class="dash-kpi-top">
                <div>
                    <div class="dash-kpi-label">Connexions (7j)</div>
                    <div class="dash-kpi-value"><%= logins7j %></div>
                </div>
                <div class="dash-kpi-icon green"><i class="bi bi-graph-up-arrow"></i></div>
            </div>
            <div class="dash-kpi-footer">
                <span class="trend-up"><i class="bi bi-activity"></i></span>
                7 derniers jours
            </div>
        </div>
        <div class="dash-kpi kpi-signalements">
            <div class="dash-kpi-top">
                <div>
                    <div class="dash-kpi-label">Signalements</div>
                    <div class="dash-kpi-value"><%= totalSignalements %></div>
                </div>
                <div class="dash-kpi-icon amber"><i class="bi bi-shield-exclamation"></i></div>
            </div>
            <div class="dash-kpi-footer">
                <span class="trend-warn"><i class="bi bi-flag-fill"></i></span>
                Contenus signal&eacute;s
            </div>
        </div>
    </div>

    <!-- ═══════════════ SECTION: ACTIVITE ═══════════════ -->
    <div class="dash-section">
        <div class="dash-section-header">
            <div class="section-icon"><i class="bi bi-bar-chart-line-fill"></i></div>
            <h2>Activit&eacute; &amp; Engagement</h2>
        </div>

        <!-- Frequentation full-width -->
        <div class="dash-grid-full">
            <div class="dash-card">
                <div class="dash-card-head">
                    <h3><i class="bi bi-activity"></i> Fr&eacute;quentation &mdash; Connexions par jour</h3>
                </div>
                <div class="dash-card-body">
                    <div class="chart-wrapper">
                        <canvas id="loginChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Specialities + Demands -->
        <div class="dash-grid-2">
            <div class="dash-card">
                <div class="dash-card-head">
                    <h3><i class="bi bi-pie-chart-fill"></i> R&eacute;partition des Sp&eacute;cialit&eacute;s</h3>
                </div>
                <div class="dash-card-body">
                    <div class="chart-wrapper">
                        <canvas id="specChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="dash-card">
                <div class="dash-card-head">
                    <h3><i class="bi bi-bar-chart-fill"></i> Sp&eacute;cialit&eacute;s les plus demand&eacute;es</h3>
                </div>
                <div class="dash-card-body">
                    <div class="chart-wrapper">
                        <canvas id="demandChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══════════════ SECTION: MODERATION ═══════════════ -->
    <div class="dash-section">
        <div class="dash-section-header">
            <div class="section-icon" style="background:var(--li-amber-light);color:var(--li-amber);"><i class="bi bi-shield-fill-check"></i></div>
            <h2>Mod&eacute;ration</h2>
        </div>
        <div class="dash-card">
            <div class="dash-card-head">
                <h3><i class="bi bi-shield-exclamation" style="color:var(--li-amber);"></i> Utilisateurs les plus signal&eacute;s</h3>
            </div>
            <div class="dash-card-body">
                <% if (reportedUsers != null && !reportedUsers.isEmpty()) { %>
                <table class="mod-table">
                    <thead>
                        <tr>
                            <th style="width:52px;">#</th>
                            <th>Utilisateur</th>
                            <th style="width:130px;text-align:center;">Signalements</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% int rank = 1;
                       for (Map ru : reportedUsers) {
                           String profLink = ctxPath + "/pages/module.jsp?but=annuaire/fiche-utilisateur.jsp&idprofil=" + ru.get("idprofil");
                           String rankClass = rank == 1 ? "gold" : rank == 2 ? "silver" : rank == 3 ? "bronze" : "plain";
                           String initial = ru.get("name") != null ? ru.get("name").toString().substring(0,1).toUpperCase() : "?";
                    %>
                        <tr onclick="window.location.href='<%= profLink %>'">
                            <td><span class="mod-rank <%= rankClass %>"><%= rank++ %></span></td>
                            <td>
                                <div class="mod-user-cell">
                                    <div class="mod-user-avatar"><%= initial %></div>
                                    <a href="<%= profLink %>" class="mod-user-name"><%= ru.get("name") %></a>
                                </div>
                            </td>
                            <td style="text-align:center;"><span class="mod-badge"><i class="bi bi-flag-fill"></i> <%= ru.get("count") %></span></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="no-data-msg">
                    <i class="bi bi-check-circle-fill"></i>
                    Aucun signalement enregistr&eacute;. Tout est en ordre.
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
    // ─── LinkedIn-style chart defaults ───
    Chart.defaults.global.defaultFontFamily = "'Inter', -apple-system, sans-serif";
    Chart.defaults.global.defaultFontColor = '#666666';
    Chart.defaults.global.defaultFontSize = 12;

    // ═══ CONNEXIONS LINE CHART ═══
    var ctx = document.getElementById('loginChart').getContext('2d');
    var gradient = ctx.createLinearGradient(0, 0, 0, 280);
    gradient.addColorStop(0, 'rgba(10, 102, 194, 0.18)');
    gradient.addColorStop(1, 'rgba(10, 102, 194, 0.01)');

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: [<%= labels.toString() %>],
            datasets: [{
                label: 'Connexions',
                data: [<%= data.toString() %>],
                borderColor: '#0a66c2',
                backgroundColor: gradient,
                borderWidth: 2.5,
                pointBackgroundColor: '#ffffff',
                pointBorderColor: '#0a66c2',
                pointBorderWidth: 2,
                pointRadius: 5,
                pointHoverRadius: 7,
                pointHoverBackgroundColor: '#0a66c2',
                pointHoverBorderColor: '#ffffff',
                pointHoverBorderWidth: 2,
                fill: true,
                tension: 0.35
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            legend: { display: false },
            scales: {
                yAxes: [{
                    ticks: {
                        beginAtZero: true,
                        stepSize: 1,
                        padding: 12,
                        fontColor: '#999'
                    },
                    gridLines: {
                        color: 'rgba(0,0,0,0.05)',
                        drawBorder: false,
                        zeroLineColor: 'rgba(0,0,0,0.08)'
                    }
                }],
                xAxes: [{
                    ticks: { padding: 10, fontColor: '#999' },
                    gridLines: { display: false }
                }]
            },
            tooltips: {
                backgroundColor: '#191919',
                titleFontSize: 13,
                bodyFontSize: 12,
                cornerRadius: 6,
                padding: 14,
                displayColors: false,
                xPadding: 14,
                yPadding: 10,
                caretSize: 6,
                callbacks: {
                    label: function(t) { return t.yLabel + ' connexion(s)'; }
                }
            }
        }
    });

    // ═══ SPECIALITES DOUGHNUT CHART ═══
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
    new Chart(document.getElementById('specChart').getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: [<%= sLabels.toString() %>],
            datasets: [{
                data: [<%= sData.toString() %>],
                backgroundColor: [
                    '#0a66c2',
                    '#7c3aed',
                    '#057642',
                    '#b24020',
                    '#0073b1',
                    '#e16745'
                ],
                borderWidth: 2,
                borderColor: '#ffffff',
                hoverBorderColor: '#ffffff',
                hoverBorderWidth: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutoutPercentage: 70,
            legend: {
                position: 'bottom',
                labels: {
                    usePointStyle: true,
                    padding: 20,
                    fontSize: 12,
                    fontColor: '#666'
                }
            },
            tooltips: {
                backgroundColor: '#191919',
                cornerRadius: 6,
                padding: 14,
                displayColors: true,
                callbacks: {
                    label: function(t, d) {
                        var label = d.labels[t.index] || '';
                        var val = d.datasets[0].data[t.index];
                        var total = d.datasets[0].data.reduce(function(a,b){ return a+b; }, 0);
                        var pct = Math.round(val / total * 100);
                        return ' ' + label + ': ' + val + ' (' + pct + '%)';
                    }
                }
            }
        }
    });

    // ═══ DEMANDED SPECIALITES BAR CHART ═══
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
    new Chart(document.getElementById('demandChart').getContext('2d'), {
        type: 'horizontalBar',
        data: {
            labels: [<%= dLabels.toString() %>],
            datasets: [{
                label: 'Mentions',
                data: [<%= dData.toString() %>],
                backgroundColor: 'rgba(10, 102, 194, 0.85)',
                hoverBackgroundColor: '#0a66c2',
                borderRadius: 4,
                barPercentage: 0.6,
                categoryPercentage: 0.8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            legend: { display: false },
            scales: {
                xAxes: [{
                    ticks: {
                        beginAtZero: true,
                        stepSize: 1,
                        padding: 10,
                        fontColor: '#999'
                    },
                    gridLines: {
                        color: 'rgba(0,0,0,0.05)',
                        drawBorder: false,
                        zeroLineColor: 'rgba(0,0,0,0.08)'
                    }
                }],
                yAxes: [{
                    ticks: { padding: 12, fontColor: '#666' },
                    gridLines: { display: false }
                }]
            },
            tooltips: {
                backgroundColor: '#191919',
                cornerRadius: 6,
                padding: 14,
                callbacks: {
                    label: function(t) { return t.xLabel + ' mention(s)'; }
                }
            }
        }
    });
});
</script>
