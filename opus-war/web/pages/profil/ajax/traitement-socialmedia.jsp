<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Profil" %>
<%@ page import="alumni.ProfilSocialMedia" %>
<%@ page import="alumni.ReseauSocial" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Timestamp" %>
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
            String idreseausocial = request.getParameter("idreseausocial");
            String valeur         = request.getParameter("valeur");

            if (idreseausocial == null || idreseausocial.trim().isEmpty()) {
                out.print("{\"success\":false,\"error\":\"Reseau social obligatoire\"}"); return;
            }
            if (valeur == null || valeur.trim().isEmpty()) {
                out.print("{\"success\":false,\"error\":\"Valeur obligatoire\"}"); return;
            }

            // Verifier doublon
            ProfilSocialMedia[] existing = (ProfilSocialMedia[]) CGenUtil.rechercher(
                new ProfilSocialMedia(), null, null, conn,
                " and idprofil='" + idprofil.replace("'","''") + "' and idreseausocial='" + idreseausocial.trim().replace("'","''") + "'"
            );
            if (existing != null && existing.length > 0) {
                out.print("{\"success\":false,\"error\":\"Ce reseau social est deja ajoute\"}"); return;
            }

            ProfilSocialMedia psm = new ProfilSocialMedia();
            psm.construirePK(conn);
            psm.setIdprofil(idprofil);
            psm.setIdReseauSocial(idreseausocial.trim());
            psm.setValeur(valeur.trim());
            psm.setDatyCreation(new Timestamp(System.currentTimeMillis()));
            psm.setDatyModification(new Timestamp(System.currentTimeMillis()));
            CGenUtil.save(psm, conn);
            conn.commit();

            // Charger libelle du reseau
            ReseauSocial[] rsArr = (ReseauSocial[]) CGenUtil.rechercher(
                new ReseauSocial(), null, null, conn,
                " and idreseausocial='" + idreseausocial.trim().replace("'","''") + "'"
            );
            String libelle = "";
            String icone   = "";
            String couleur = "";
            String urlpat  = "";
            if (rsArr != null && rsArr.length > 0) {
                libelle = rsArr[0].getLibelle() != null ? rsArr[0].getLibelle() : "";
                icone   = rsArr[0].getIconeClass() != null ? rsArr[0].getIconeClass() : "";
                couleur = rsArr[0].getCouleurHex() != null ? rsArr[0].getCouleurHex() : "";
                urlpat  = rsArr[0].getUrlPattern() != null ? rsArr[0].getUrlPattern() : "";
            }

            out.print("{\"success\":true,\"id\":\"" + psm.getIdProfilSocial() + "\","
                + "\"idreseausocial\":\"" + idreseausocial.trim().replace("\"","\\\"") + "\","
                + "\"libelle\":\"" + libelle.replace("\"","\\\"") + "\","
                + "\"icone\":\"" + icone.replace("\"","\\\"") + "\","
                + "\"couleur\":\"" + couleur.replace("\"","\\\"") + "\","
                + "\"urlpattern\":\"" + urlpat.replace("\"","\\\"") + "\","
                + "\"valeur\":\"" + valeur.trim().replace("\"","\\\"") + "\"}");

        /* ──────────────── DELETE ──────────────── */
        } else if ("delete".equals(action)) {
            String psmId = request.getParameter("idprofilsocial");
            if (psmId == null) { out.print("{\"success\":false,\"error\":\"ID manquant\"}"); return; }

                ProfilSocialMedia[] arr = (ProfilSocialMedia[]) CGenUtil.rechercher(
                    new ProfilSocialMedia(), null, null, conn,
                    " and idprofilsocial='" + psmId.replace("'","''") + "' and idprofil='" + idprofil.replace("'","''") + "'"
                );
            if (arr == null || arr.length == 0) {
                out.print("{\"success\":false,\"error\":\"Social media non trouve\"}"); return;
            }

            arr[0].deleteToTable(conn);
            conn.commit();
            out.print("{\"success\":true}");

        /* ──────────────── LIST ──────────────── */
        } else if ("list".equals(action)) {
            ProfilSocialMedia[] psmArr = (ProfilSocialMedia[]) CGenUtil.rechercher(
                new ProfilSocialMedia(), null, null, conn,
                " and idprofil='" + idprofil.replace("'","''") + "'"
            );
            StringBuilder sb = new StringBuilder("[");
            if (psmArr != null) {
                for (int i = 0; i < psmArr.length; i++) {
                    ReseauSocial[] rsArr = (ReseauSocial[]) CGenUtil.rechercher(
                        new ReseauSocial(), null, null, conn,
                        " and idreseausocial='" + psmArr[i].getIdReseauSocial().replace("'","''") + "'"
                    );
                    String libelle = "";
                    String icone   = "";
                    String couleur = "";
                    String urlpat  = "";
                    if (rsArr != null && rsArr.length > 0) {
                        libelle = rsArr[0].getLibelle() != null ? rsArr[0].getLibelle() : "";
                        icone   = rsArr[0].getIconeClass() != null ? rsArr[0].getIconeClass() : "";
                        couleur = rsArr[0].getCouleurHex() != null ? rsArr[0].getCouleurHex() : "";
                        urlpat  = rsArr[0].getUrlPattern() != null ? rsArr[0].getUrlPattern() : "";
                    }
                    if (i > 0) sb.append(",");
                    sb.append("{");
                    sb.append("\"idprofilsocial\":\"").append(psmArr[i].getIdProfilSocial().replace("\"","\\\"")).append("\",");
                    sb.append("\"idreseausocial\":\"").append(psmArr[i].getIdReseauSocial().replace("\"","\\\"")).append("\",");
                    sb.append("\"libelle\":\"").append(libelle.replace("\"","\\\"")).append("\",");
                    sb.append("\"icone\":\"").append(icone.replace("\"","\\\"")).append("\",");
                    sb.append("\"couleur\":\"").append(couleur.replace("\"","\\\"")).append("\",");
                    sb.append("\"urlpattern\":\"").append(urlpat.replace("\"","\\\"")).append("\",");
                    sb.append("\"valeur\":\"").append(psmArr[i].getValeur() != null ? psmArr[i].getValeur().replace("\"","\\\"") : "").append("\"");
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
