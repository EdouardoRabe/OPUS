<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Profil" %>
<%@ page import="alumni.Experience" %>
<%@ page import="alumni.ExperienceLib" %>
<%@ page import="alumni.Poste" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Date" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }

        int    refuser = u.getUser().getRefuser();
        String userId  = String.valueOf(refuser);

        String action = request.getParameter("action");
        if (action == null) { out.print("{\"success\":false,\"error\":\"Action manquante\"}"); return; }

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        // Resoudre idprofil
        Profil profil = Profil.findByRefUser(refuser, conn);
        if (profil == null) { out.print("{\"success\":false,\"error\":\"Profil introuvable\"}"); return; }
        String idprofil = profil.getIdprofil();

        /* ──────────────── CREATE ──────────────── */
        if ("create".equals(action)) {
            String entreprise  = request.getParameter("entreprise");
            String debut       = request.getParameter("debut");
            String fin         = request.getParameter("fin");
            String description = request.getParameter("description");
            String idposte     = request.getParameter("idposte");

            if (entreprise == null || entreprise.trim().isEmpty()) {
                out.print("{\"success\":false,\"error\":\"Entreprise obligatoire\"}"); return;
            }
            if (idposte == null || idposte.trim().isEmpty()) {
                out.print("{\"success\":false,\"error\":\"Poste obligatoire\"}"); return;
            }

            Experience exp = new Experience();
            exp.construirePK(conn);
            exp.setEntreprise(entreprise.trim());
            exp.setDebut(debut != null && !debut.trim().isEmpty() ? Date.valueOf(debut.trim()) : null);
            exp.setFin(fin != null && !fin.trim().isEmpty() ? Date.valueOf(fin.trim()) : null);
            exp.setDescription(description != null ? description.trim() : "");
            exp.setEtat(1);
            exp.setIdprofil(idprofil);
            exp.setIdposte(idposte.trim());
            exp.insertToTableWithHisto(userId, conn);

            conn.commit();

            // Charger avec postelib
            ExperienceLib[] res = (ExperienceLib[]) CGenUtil.rechercher(
                new ExperienceLib(), null, null, conn,
                " and idexperience='" + exp.getIdexperience().replace("'","''") + "'"
            );
            String postelib = "";
            if (res != null && res.length > 0 && res[0].getPostelib() != null) postelib = res[0].getPostelib();

            out.print("{\"success\":true,\"id\":\"" + exp.getIdexperience() + "\",\"postelib\":\"" + postelib.replace("\"","\\\"") + "\"}");

        /* ──────────────── UPDATE ──────────────── */
        } else if ("update".equals(action)) {
            String idexperience = request.getParameter("idexperience");
            if (idexperience == null) { out.print("{\"success\":false,\"error\":\"ID manquant\"}"); return; }

            // Verifier propriete
            Experience[] arr = (Experience[]) CGenUtil.rechercher(
                new Experience(), null, null, conn,
                " and idexperience='" + idexperience.replace("'","''") + "' and idprofil='" + idprofil.replace("'","''") + "'"
            );
            if (arr == null || arr.length == 0) {
                out.print("{\"success\":false,\"error\":\"Experience non trouvee\"}"); return;
            }
            Experience exp = arr[0];

            String entreprise  = request.getParameter("entreprise");
            String debut       = request.getParameter("debut");
            String fin         = request.getParameter("fin");
            String description = request.getParameter("description");
            String idposte     = request.getParameter("idposte");

            if (entreprise != null) exp.setEntreprise(entreprise.trim());
            if (debut != null)      exp.setDebut(debut.trim().isEmpty() ? null : Date.valueOf(debut.trim()));
            if (fin != null)        exp.setFin(fin.trim().isEmpty() ? null : Date.valueOf(fin.trim()));
            if (description != null) exp.setDescription(description.trim());
            if (idposte != null && !idposte.trim().isEmpty()) exp.setIdposte(idposte.trim());

            exp.setMode("modif");
            exp.updateToTableWithHisto(userId, conn);
            conn.commit();

            ExperienceLib[] res = (ExperienceLib[]) CGenUtil.rechercher(
                new ExperienceLib(), null, null, conn,
                " and idexperience='" + exp.getIdexperience().replace("'","''") + "'"
            );
            String postelib = "";
            if (res != null && res.length > 0 && res[0].getPostelib() != null) postelib = res[0].getPostelib();

            out.print("{\"success\":true,\"postelib\":\"" + postelib.replace("\"","\\\"") + "\"}");

        /* ──────────────── DELETE ──────────────── */
        } else if ("delete".equals(action)) {
            String idexperience = request.getParameter("idexperience");
            if (idexperience == null) { out.print("{\"success\":false,\"error\":\"ID manquant\"}"); return; }

            Experience[] arr = (Experience[]) CGenUtil.rechercher(
                new Experience(), null, null, conn,
                " and idexperience='" + idexperience.replace("'","''") + "' and idprofil='" + idprofil.replace("'","''") + "'"
            );
            if (arr == null || arr.length == 0) {
                out.print("{\"success\":false,\"error\":\"Experience non trouvee\"}"); return;
            }

            arr[0].deleteToTable(conn);
            conn.commit();
            out.print("{\"success\":true}");

        /* ──────────────── LIST ──────────────── */
        } else if ("list".equals(action)) {
            ExperienceLib[] exps = (ExperienceLib[]) CGenUtil.rechercher(
                new ExperienceLib(), null, null, conn,
                " and idutilisateur=" + refuser + " order by debut desc"
            );
            StringBuilder sb = new StringBuilder("[");
            if (exps != null) {
                for (int i = 0; i < exps.length; i++) {
                    if (i > 0) sb.append(",");
                    sb.append("{");
                    sb.append("\"idexperience\":\"").append(exps[i].getIdexperience() != null ? exps[i].getIdexperience() : "").append("\",");
                    sb.append("\"entreprise\":\"").append(exps[i].getEntreprise() != null ? exps[i].getEntreprise().replace("\"","\\\"") : "").append("\",");
                    sb.append("\"debut\":\"").append(exps[i].getDebut() != null ? exps[i].getDebut() : "").append("\",");
                    sb.append("\"fin\":\"").append(exps[i].getFin() != null ? exps[i].getFin() : "").append("\",");
                    sb.append("\"description\":\"").append(exps[i].getDescription() != null ? exps[i].getDescription().replace("\"","\\\"").replace("\n","\\n") : "").append("\",");
                    sb.append("\"idposte\":\"").append(exps[i].getIdposte() != null ? exps[i].getIdposte() : "").append("\",");
                    sb.append("\"postelib\":\"").append(exps[i].getPostelib() != null ? exps[i].getPostelib().replace("\"","\\\"") : "").append("\"");
                    sb.append("}");
                }
            }
            sb.append("]");
            out.print("{\"success\":true,\"data\":" + sb.toString() + "}");

        } else {
            out.print("{\"success\":false,\"error\":\"Action inconnue: " + action + "\"}");
        }

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        String msg = (e.getMessage() != null ? e.getMessage().replace("\"","'").replace("\n"," ") : "Erreur inconnue");
        out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
