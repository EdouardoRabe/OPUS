<%@ page pageEncoding="UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="alumni.Profil" %>
<%@ page import="alumni.Visibilite" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.util.Calendar" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    String contextPath = request.getContextPath();
    boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
    
    if (isAjax) {
        response.setContentType("application/json; charset=UTF-8");
    }

    Connection conn = null;
    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            if (isAjax) {
                out.print("{\"success\":false,\"error\":\"Non connecte\"}");
            } else {
                response.sendRedirect(contextPath + "/pages/module.jsp?but=profil/confidentialite.jsp&erreur=Non+connecte");
            }
            return;
        }
        int    refuser = u.getUser().getRefuser();
        String userId  = String.valueOf(refuser);

        // Récupérer idprofil
        String idprofil = request.getParameter("idprofil");
        if (idprofil == null || idprofil.trim().isEmpty()) {
            // Résolution depuis refuser si non fourni
            conn = new UtilDB().GetConn();
            Profil profil = Profil.findByRefUser(refuser, conn);
            if (profil == null) {
                if (isAjax) {
                    out.print("{\"success\":false,\"error\":\"Profil introuvable\"}");
                } else {
                    response.sendRedirect(contextPath + "/pages/module.jsp?but=profil/confidentialite.jsp&erreur=Profil+introuvable");
                }
                return;
            }
            idprofil = profil.getIdprofil();
            conn.close();
            conn = null;
        }
        idprofil = idprofil.trim();

        // Champs à traiter
        String[] champs = {"nom", "prenom", "dtn", "experience", "specialite", "promotion", "email", "parcours", "telephone", "genre"};

        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);

        Date today = new Date(Calendar.getInstance().getTimeInMillis());

        for (int i = 0; i < champs.length; i++) {
            String champ     = champs[i];
            String statusParam = request.getParameter("status_" + champ);
            // Checkbox: present = 1 (public), absent = 0 (prive)
            int status = (statusParam != null && !statusParam.trim().isEmpty()) ? 1 : 0;

            // Chercher si une ligne existe déjà
            Visibilite[] existing = (Visibilite[]) CGenUtil.rechercher(
                new Visibilite(), null, null, conn,
                " and idprofil='" + idprofil + "' and champvisibilite='" + champ + "'"
            );

            if (existing != null && existing.length > 0) {
                // UPDATE
                Visibilite v = existing[0];
                v.setStatus(status);
                v.setDaty(today);
                v.setMode("modif");
                v.updateToTableWithHisto(userId, conn);
            } else {
                // INSERT
                Visibilite v = new Visibilite();
                v.construirePK(conn);
                v.setChampvisibilite(champ);
                v.setStatus(status);
                v.setIdprofil(idprofil);
                v.setDaty(today);
                v.insertToTableWithHisto(userId, conn);
            }
        }

        conn.commit();
        
        if (isAjax) {
            out.print("{\"success\":true}");
        } else {
            response.sendRedirect(contextPath + "/pages/module.jsp?but=profil/confidentialite.jsp&msg=Parametres+enregistres");
        }

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
        e.printStackTrace();
        System.err.println("traitement-confidentialite.jsp ERROR: " + e.getClass().getName());
        System.err.println("Message: " + e.getMessage());
        
        String msg = e.getClass().getName() + ": " + (e.getMessage() != null
            ? e.getMessage().replace("\"", "'").replace("\n", " ")
            : "Erreur inconnue");
        
        if (isAjax) {
            out.print("{\"success\":false,\"error\":\"" + msg + "\"}");
        } else {
            response.sendRedirect(contextPath + "/pages/module.jsp?but=profil/confidentialite.jsp&erreur=" + java.net.URLEncoder.encode(msg, "UTF-8"));
        }
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
