<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Profil" %>
<%@ page import="alumni.Specialiteprofil" %>
<%@ page import="alumni.Specialite" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
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

        Profil profil = Profil.findByRefUser(refuser, conn);
        if (profil == null) { out.print("{\"success\":false,\"error\":\"Profil introuvable\"}"); return; }
        String idprofil = profil.getIdprofil();

        /* ──────────────── ADD ──────────────── */
        if ("add".equals(action)) {
            String idspecialite = request.getParameter("idspecialite");
            String niveauStr   = request.getParameter("niveau");

            if (idspecialite == null || idspecialite.trim().isEmpty()) {
                out.print("{\"success\":false,\"error\":\"Specialite obligatoire\"}"); return;
            }

            int niveau = 1;
            try { if (niveauStr != null) niveau = Integer.parseInt(niveauStr.trim()); } catch (Exception e) {}

            // Verifier doublon
            Specialiteprofil[] existing = (Specialiteprofil[]) CGenUtil.rechercher(
                new Specialiteprofil(), null, null, conn,
                " and idprofil='" + idprofil.replace("'","''") + "' and idspecialite='" + idspecialite.trim().replace("'","''") + "'"
            );
            if (existing != null && existing.length > 0) {
                out.print("{\"success\":false,\"error\":\"Cette specialite est deja ajoutee\"}"); return;
            }

            Specialiteprofil sp = new Specialiteprofil();
            sp.construirePK(conn);
            sp.setIdspecialite(idspecialite.trim());
            sp.setIdprofil(idprofil);
            sp.setEtat(1);
            sp.setNiveau(niveau);
            sp.insertToTableWithHisto(userId, conn);
            conn.commit();

            // Charger libelle
            Specialite[] specRes = (Specialite[]) CGenUtil.rechercher(
                new Specialite(), null, null, conn,
                " and idspecialite='" + idspecialite.trim().replace("'","''") + "'"
            );
            String libelle = "";
            if (specRes != null && specRes.length > 0 && specRes[0].getLibelle() != null) libelle = specRes[0].getLibelle();

            out.print("{\"success\":true,\"id\":\"" + sp.getSpecialiteprofil() + "\",\"libelle\":\"" + libelle.replace("\"","\\\"") + "\",\"niveau\":" + niveau + "}");

        /* ──────────────── UPDATE ──────────────── */
        } else if ("update".equals(action)) {
            String spId      = request.getParameter("specialiteprofil");
            String niveauStr = request.getParameter("niveau");

            if (spId == null) { out.print("{\"success\":false,\"error\":\"ID manquant\"}"); return; }

            Specialiteprofil[] arr = (Specialiteprofil[]) CGenUtil.rechercher(
                new Specialiteprofil(), null, null, conn,
                " and specialiteprofil='" + spId.replace("'","''") + "' and idprofil='" + idprofil.replace("'","''") + "'"
            );
            if (arr == null || arr.length == 0) {
                out.print("{\"success\":false,\"error\":\"Specialite profil non trouvee\"}"); return;
            }

            Specialiteprofil sp = arr[0];
            if (niveauStr != null) {
                try { sp.setNiveau(Integer.parseInt(niveauStr.trim())); } catch (Exception e) {}
            }
            sp.setMode("modif");
            sp.updateToTableWithHisto(userId, conn);
            conn.commit();
            out.print("{\"success\":true}");

        /* ──────────────── DELETE ──────────────── */
        } else if ("delete".equals(action)) {
            String spId = request.getParameter("specialiteprofil");
            if (spId == null) { out.print("{\"success\":false,\"error\":\"ID manquant\"}"); return; }

            Specialiteprofil[] arr = (Specialiteprofil[]) CGenUtil.rechercher(
                new Specialiteprofil(), null, null, conn,
                " and specialiteprofil='" + spId.replace("'","''") + "' and idprofil='" + idprofil.replace("'","''") + "'"
            );
            if (arr == null || arr.length == 0) {
                out.print("{\"success\":false,\"error\":\"Specialite profil non trouvee\"}"); return;
            }

            arr[0].deleteToTable(conn);
            conn.commit();
            out.print("{\"success\":true}");

        /* ──────────────── LIST ──────────────── */
        } else if ("list".equals(action)) {
            Specialiteprofil[] spArr = (Specialiteprofil[]) CGenUtil.rechercher(
                new Specialiteprofil(), null, null, conn,
                " and idprofil='" + idprofil.replace("'","''") + "'"
            );
            StringBuilder sb = new StringBuilder("[");
            if (spArr != null) {
                for (int i = 0; i < spArr.length; i++) {
                    // Charger libelle
                    String libelle = "";
                    Specialite[] sRes = (Specialite[]) CGenUtil.rechercher(
                        new Specialite(), null, null, conn,
                        " and idspecialite='" + spArr[i].getIdspecialite().replace("'","''") + "'"
                    );
                    if (sRes != null && sRes.length > 0 && sRes[0].getLibelle() != null) libelle = sRes[0].getLibelle();

                    if (i > 0) sb.append(",");
                    sb.append("{");
                    sb.append("\"specialiteprofil\":\"").append(spArr[i].getSpecialiteprofil()).append("\",");
                    sb.append("\"idspecialite\":\"").append(spArr[i].getIdspecialite()).append("\",");
                    sb.append("\"libelle\":\"").append(libelle.replace("\"","\\\"")).append("\",");
                    sb.append("\"niveau\":").append(spArr[i].getNiveau());
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
