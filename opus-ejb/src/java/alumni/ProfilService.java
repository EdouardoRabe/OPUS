package alumni;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Time;
import java.sql.Timestamp;
import java.io.File;
import java.util.*;
import bean.CGenUtil;
import utilitaire.UtilDB;
import utilitaire.Utilitaire;

/**
 * Service pour le profil utilisateur.
 * Combine les 11 profil/ajax JSPs.
 * Gere sa propre connexion.
 */
public class ProfilService {

    private static String ej(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }

    /* ═══════════════════════════════════════════════════════════
     * CONFIDENTIALITE
     * ═══════════════════════════════════════════════════════════ */

    /**
     * Met a jour les parametres de confidentialite du profil.
     * @param refuser   ID utilisateur
     * @param idprofil  ID profil (peut etre null, sera resolu automatiquement)
     * @param statusMap Map(champ -> statusValue) pour les 12 champs de visibilite
     * @return JSON result ou null si redirection necessaire
     */
    public static String updateConfidentialite(int refuser, String idprofil,
            Map statusMap) throws Exception {

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();

            // Resoudre idprofil si non fourni
            if (idprofil == null || idprofil.trim().isEmpty()) {
                Profil profil = Profil.findByRefUser(refuser, conn);
                if (profil == null) return "{\"success\":false,\"error\":\"Profil introuvable\"}";
                idprofil = profil.getIdprofil();
            }
            idprofil = idprofil.trim();

            conn.setAutoCommit(false);
            Date today = new Date(Calendar.getInstance().getTimeInMillis());

            String[] champs = {"nom", "prenom", "dtn", "experience", "specialite", "promotion",
                               "email", "parcours", "telephone", "genre", "socialmedia", "localisation"};

            for (int i = 0; i < champs.length; i++) {
                String champ = champs[i];
                String statusParam = (String) statusMap.get("status_" + champ);
                int status = (statusParam != null && !statusParam.trim().isEmpty()) ? 1 : 0;

                Visibilite[] existing = (Visibilite[]) CGenUtil.rechercher(
                    new Visibilite(), null, null, conn,
                    " and idprofil='" + idprofil + "' and champvisibilite='" + champ + "'");

                if (existing != null && existing.length > 0) {
                    Visibilite v = existing[0];
                    v.setStatus(status);
                    v.setDaty(today);
                    v.setMode("modif");
                    v.updateToTableWithHisto(userId, conn);
                } else {
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
            return "{\"success\":true}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * CV DELETE
     * ═══════════════════════════════════════════════════════════ */
    public static String deleteCv(int refuser) throws Exception {
        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Profil profil = Profil.findByRefUser(refuser, conn);
            if (profil == null) return "{\"success\":false,\"error\":\"Profil introuvable\"}";

            String oldCv = profil.getCv();
            if (oldCv != null && !oldCv.isEmpty()) {
                String cvPath = System.getProperty("jboss.server.base.dir")
                    + "/deployments/opus.war/" + oldCv;
                File f = new File(cvPath);
                if (f.exists()) f.delete();
            }

            profil.setCv(null);
            profil.updateToTableWithHisto(userId, conn);
            conn.commit();
            return "{\"success\":true}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * CV UPLOAD (le fichier est deja sauvegarde sur disque par le JSP)
     * ═══════════════════════════════════════════════════════════ */
    public static String uploadCv(int refuser, String cvRelPath) throws Exception {
        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Profil profil = Profil.findByRefUser(refuser, conn);
            if (profil == null) return "{\"success\":false,\"error\":\"Profil introuvable pour cet utilisateur\"}";

            profil.setCv(cvRelPath);
            profil.updateToTableWithHisto(userId, conn);
            conn.commit();
            return "{\"success\":true,\"cv\":\"" + cvRelPath + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * EXPERIENCE CRUD
     * ═══════════════════════════════════════════════════════════ */
    public static String crudExperience(int refuser, String action, String idexperience,
            String entreprise, String debut, String fin, String description,
            String idposte) throws Exception {

        if (action == null) return "{\"success\":false,\"error\":\"Action manquante\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Profil profil = Profil.findByRefUser(refuser, conn);
            if (profil == null) return "{\"success\":false,\"error\":\"Profil introuvable\"}";
            String idprofil = profil.getIdprofil();

            /* ── CREATE ── */
            if ("create".equals(action)) {
                if (entreprise == null || entreprise.trim().isEmpty())
                    return "{\"success\":false,\"error\":\"Entreprise obligatoire\"}";
                if (idposte == null || idposte.trim().isEmpty())
                    return "{\"success\":false,\"error\":\"Poste obligatoire\"}";

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

                ExperienceLib[] res = (ExperienceLib[]) CGenUtil.rechercher(
                    new ExperienceLib(), null, null, conn,
                    " and idexperience='" + exp.getIdexperience().replace("'", "''") + "'");
                String postelib = "";
                if (res != null && res.length > 0 && res[0].getPostelib() != null)
                    postelib = res[0].getPostelib();

                return "{\"success\":true,\"id\":\"" + exp.getIdexperience()
                    + "\",\"postelib\":\"" + postelib.replace("\"", "\\\"") + "\"}";

            /* ── UPDATE ── */
            } else if ("update".equals(action)) {
                if (idexperience == null) return "{\"success\":false,\"error\":\"ID manquant\"}";

                Experience[] arr = (Experience[]) CGenUtil.rechercher(
                    new Experience(), null, null, conn,
                    " and idexperience='" + idexperience.replace("'", "''")
                    + "' and idprofil='" + idprofil.replace("'", "''") + "'");
                if (arr == null || arr.length == 0)
                    return "{\"success\":false,\"error\":\"Experience non trouvee\"}";

                Experience exp = arr[0];
                if (entreprise != null) exp.setEntreprise(entreprise.trim());
                if (debut != null) exp.setDebut(debut.trim().isEmpty() ? null : Date.valueOf(debut.trim()));
                if (fin != null) exp.setFin(fin.trim().isEmpty() ? null : Date.valueOf(fin.trim()));
                if (description != null) exp.setDescription(description.trim());
                if (idposte != null && !idposte.trim().isEmpty()) exp.setIdposte(idposte.trim());
                exp.setMode("modif");
                exp.updateToTableWithHisto(userId, conn);
                conn.commit();

                ExperienceLib[] res = (ExperienceLib[]) CGenUtil.rechercher(
                    new ExperienceLib(), null, null, conn,
                    " and idexperience='" + exp.getIdexperience().replace("'", "''") + "'");
                String postelib = "";
                if (res != null && res.length > 0 && res[0].getPostelib() != null)
                    postelib = res[0].getPostelib();

                return "{\"success\":true,\"postelib\":\"" + postelib.replace("\"", "\\\"") + "\"}";

            /* ── DELETE ── */
            } else if ("delete".equals(action)) {
                if (idexperience == null) return "{\"success\":false,\"error\":\"ID manquant\"}";

                Experience[] arr = (Experience[]) CGenUtil.rechercher(
                    new Experience(), null, null, conn,
                    " and idexperience='" + idexperience.replace("'", "''")
                    + "' and idprofil='" + idprofil.replace("'", "''") + "'");
                if (arr == null || arr.length == 0)
                    return "{\"success\":false,\"error\":\"Experience non trouvee\"}";

                arr[0].deleteToTable(conn);
                conn.commit();
                return "{\"success\":true}";

            /* ── LIST ── */
            } else if ("list".equals(action)) {
                ExperienceLib[] exps = (ExperienceLib[]) CGenUtil.rechercher(
                    new ExperienceLib(), null, null, conn,
                    " and idutilisateur=" + refuser + " order by debut desc");
                StringBuilder sb = new StringBuilder("[");
                if (exps != null) {
                    for (int i = 0; i < exps.length; i++) {
                        if (i > 0) sb.append(",");
                        sb.append("{");
                        sb.append("\"idexperience\":\"").append(exps[i].getIdexperience() != null ? exps[i].getIdexperience() : "").append("\",");
                        sb.append("\"entreprise\":\"").append(exps[i].getEntreprise() != null ? ej(exps[i].getEntreprise()) : "").append("\",");
                        sb.append("\"debut\":\"").append(exps[i].getDebut() != null ? exps[i].getDebut() : "").append("\",");
                        sb.append("\"fin\":\"").append(exps[i].getFin() != null ? exps[i].getFin() : "").append("\",");
                        sb.append("\"description\":\"").append(exps[i].getDescription() != null ? ej(exps[i].getDescription()) : "").append("\",");
                        sb.append("\"idposte\":\"").append(exps[i].getIdposte() != null ? exps[i].getIdposte() : "").append("\",");
                        sb.append("\"postelib\":\"").append(exps[i].getPostelib() != null ? ej(exps[i].getPostelib()) : "").append("\"");
                        sb.append("}");
                    }
                }
                sb.append("]");
                return "{\"success\":true,\"data\":" + sb.toString() + "}";

            } else {
                return "{\"success\":false,\"error\":\"Action inconnue: " + action + "\"}";
            }
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * LOCALISATION CRUD
     * ═══════════════════════════════════════════════════════════ */
    public static String crudLocalisation(int refuser, String action, String id,
            String idprofil, String latitude, String longitude) throws Exception {

        if (action == null) return "{\"success\":false,\"error\":\"Action manquante\"}";
        if (idprofil == null || latitude == null || longitude == null)
            return "{\"success\":false,\"error\":\"Donnees manquantes\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            if ("create".equals(action)) {
                Profilemplacement emp = new Profilemplacement();
                emp.construirePK(conn);
                emp.setIdprofil(idprofil);
                emp.setLatitude(Double.parseDouble(latitude));
                emp.setLongitude(Double.parseDouble(longitude));
                emp.insertToTableWithHisto(userId, conn);
                conn.commit();
                return "{\"success\":true}";

            } else if ("update".equals(action)) {
                if (id == null) return "{\"success\":false,\"error\":\"ID emplacement manquant\"}";

                Profilemplacement emp = new Profilemplacement();
                emp.setId(id);
                emp.setIdprofil(idprofil);
                emp.setLatitude(Double.parseDouble(latitude));
                emp.setLongitude(Double.parseDouble(longitude));
                emp.setMode("modif");
                emp.updateToTableWithHisto(userId, conn);
                conn.commit();
                return "{\"success\":true}";

            } else {
                return "{\"success\":false,\"error\":\"Action inconnue\"}";
            }
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * CHANGE PASSWORD
     * Retourne le JSON result.
     * NOTE: le JSP doit mettre a jour la session (mu.setPwduser) apres appel.
     * On retourne newPwdCrypt dans le JSON pour que le JSP puisse le faire.
     * ═══════════════════════════════════════════════════════════ */
    public static String changePassword(int refuser, String oldPassword,
            String newPassword, String confirmPassword) throws Exception {

        if (oldPassword == null || oldPassword.trim().isEmpty())
            return "{\"success\":false,\"error\":\"L'ancien mot de passe est requis\"}";
        if (newPassword == null || newPassword.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Le nouveau mot de passe est requis\"}";
        if (newPassword.trim().length() < 3)
            return "{\"success\":false,\"error\":\"Le mot de passe doit contenir au moins 3 caracteres\"}";
        if (!newPassword.equals(confirmPassword))
            return "{\"success\":false,\"error\":\"Les mots de passe ne correspondent pas\"}";

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            int niveau = 0, sens = 0;
            String storedPwd = null;

            PreparedStatement psPC = conn.prepareStatement(
                "SELECT p.niveau, p.croissante, u.pwduser "
                + "FROM paramcrypt p JOIN utilisateur u ON CAST(u.refuser AS varchar) = p.idutilisateur "
                + "WHERE p.idutilisateur = ?");
            psPC.setString(1, String.valueOf(refuser));
            ResultSet rsPC = psPC.executeQuery();
            if (rsPC.next()) {
                niveau = rsPC.getInt("niveau");
                sens = rsPC.getInt("croissante");
                storedPwd = rsPC.getString("pwduser");
            } else {
                rsPC.close(); psPC.close();
                conn.rollback();
                return "{\"success\":false,\"error\":\"Parametres de cryptage introuvables\"}";
            }
            rsPC.close(); psPC.close();

            String oldPwdCrypt = Utilitaire.cryptWord(oldPassword.trim().toLowerCase(), niveau, sens == 0);
            if (storedPwd == null || !storedPwd.equals(oldPwdCrypt)) {
                conn.rollback();
                return "{\"success\":false,\"error\":\"L'ancien mot de passe est incorrect\"}";
            }

            String newPwdCrypt = Utilitaire.cryptWord(newPassword.trim().toLowerCase(), niveau, sens == 0);

            PreparedStatement psUp = conn.prepareStatement(
                "UPDATE utilisateur SET pwduser = ? WHERE refuser = ?");
            psUp.setString(1, newPwdCrypt);
            psUp.setInt(2, refuser);
            int updated = psUp.executeUpdate();
            psUp.close();

            if (updated == 0) {
                conn.rollback();
                return "{\"success\":false,\"error\":\"Utilisateur non trouve\"}";
            }

            conn.commit();

            // Retourne le nouveau pwd crypte pour que le JSP mette a jour la session
            return "{\"success\":true,\"message\":\"Mot de passe modifie avec succes\",\"_pwdCrypt\":\""
                + ej(newPwdCrypt) + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * PHOTO UPLOAD (fichier deja sauvegarde par JSP)
     * ═══════════════════════════════════════════════════════════ */
    public static String uploadPhoto(int refuser, int photoType, String photoRelPath) throws Exception {
        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Profil profil = Profil.findByRefUser(refuser, conn);
            if (profil == null)
                return "{\"success\":false,\"error\":\"Profil introuvable pour cet utilisateur\"}";
            String idprofil = profil.getIdprofil();

            Photo ph = new Photo();
            ph.setIdprofil(idprofil);
            ph.setImage(photoRelPath);
            ph.setType(photoType);
            ph.setDaty(new Date(Calendar.getInstance().getTimeInMillis()));
            ph.setHeure(new Time(Calendar.getInstance().getTimeInMillis()));
            ph.construirePK(conn);
            ph.insertToTableWithHisto(userId, conn);
            conn.commit();

            return "{\"success\":true,\"image\":\"" + photoRelPath
                + "\",\"idphoto\":\"" + ph.getIdphoto() + "\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * UPDATE PROFIL INFO (nom, prenom, telephone)
     * ═══════════════════════════════════════════════════════════ */
    public static String updateProfilInfo(int refuser, String nom, String prenom,
            String telephone) throws Exception {

        if (nom == null || nom.trim().isEmpty() || prenom == null || prenom.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Nom et prénom obligatoires\"}";

        String nomuser = nom.trim() + " " + prenom.trim();
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            PreparedStatement ps = conn.prepareStatement(
                "UPDATE utilisateur SET nomuser=?, teluser=? WHERE refuser=?");
            ps.setString(1, nomuser);
            ps.setString(2, telephone != null ? telephone.trim() : "");
            ps.setInt(3, refuser);
            ps.executeUpdate();
            ps.close();

            conn.commit();
            return "{\"success\":true}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * UPDATE PROFIL STATUT
     * ═══════════════════════════════════════════════════════════ */
    public static String updateStatut(int refuser, String idprofil,
            String idprofiltypestatut) throws Exception {

        if (idprofil == null || idprofil.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Profil invalide\"}";
        if (idprofiltypestatut == null || idprofiltypestatut.trim().isEmpty())
            return "{\"success\":false,\"error\":\"Statut invalide\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            ProfilStatut ps = new ProfilStatut();
            ps.construirePK(conn);
            ps.setIdprofil(idprofil.trim());
            ps.setIdprofiltypestatut(idprofiltypestatut.trim());
            ps.setDaty(new Timestamp(System.currentTimeMillis()));
            ps.insertToTableWithHisto(userId, conn);
            conn.commit();

            return "{\"success\":true,\"message\":\"Statut mis à jour\"}";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * SOCIAL MEDIA CRUD
     * ═══════════════════════════════════════════════════════════ */
    public static String crudSocialMedia(int refuser, String action,
            String idprofilsocial, String idreseausocial, String valeur) throws Exception {

        if (action == null) return "{\"success\":false,\"error\":\"Action manquante\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Profil profil = Profil.findByRefUser(refuser, conn);
            if (profil == null) return "{\"success\":false,\"error\":\"Profil introuvable\"}";
            String idprofil = profil.getIdprofil();

            /* ── ADD ── */
            if ("add".equals(action)) {
                if (idreseausocial == null || idreseausocial.trim().isEmpty())
                    return "{\"success\":false,\"error\":\"Reseau social obligatoire\"}";
                if (valeur == null || valeur.trim().isEmpty())
                    return "{\"success\":false,\"error\":\"Valeur obligatoire\"}";

                // Verifier doublon
                ProfilSocialMedia[] existing = (ProfilSocialMedia[]) CGenUtil.rechercher(
                    new ProfilSocialMedia(), null, null, conn,
                    " and idprofil='" + idprofil.replace("'", "''")
                    + "' and idreseausocial='" + idreseausocial.trim().replace("'", "''") + "'");
                if (existing != null && existing.length > 0)
                    return "{\"success\":false,\"error\":\"Ce reseau social est deja ajoute\"}";

                ProfilSocialMedia psm = new ProfilSocialMedia();
                psm.construirePK(conn);
                psm.setIdprofil(idprofil);
                psm.setIdReseauSocial(idreseausocial.trim());
                psm.setValeur(valeur.trim());
                psm.setDatyCreation(new Timestamp(System.currentTimeMillis()));
                psm.setDatyModification(new Timestamp(System.currentTimeMillis()));
                CGenUtil.save(psm, conn);
                conn.commit();

                // Charger infos reseau
                ReseauSocial[] rsArr = (ReseauSocial[]) CGenUtil.rechercher(
                    new ReseauSocial(), null, null, conn,
                    " and idreseausocial='" + idreseausocial.trim().replace("'", "''") + "'");
                String libelle = "", icone = "", couleur = "", urlpat = "";
                if (rsArr != null && rsArr.length > 0) {
                    libelle = rsArr[0].getLibelle() != null ? rsArr[0].getLibelle() : "";
                    icone   = rsArr[0].getIconeClass() != null ? rsArr[0].getIconeClass() : "";
                    couleur = rsArr[0].getCouleurHex() != null ? rsArr[0].getCouleurHex() : "";
                    urlpat  = rsArr[0].getUrlPattern() != null ? rsArr[0].getUrlPattern() : "";
                }

                return "{\"success\":true,\"id\":\"" + psm.getIdProfilSocial() + "\","
                    + "\"idreseausocial\":\"" + ej(idreseausocial.trim()) + "\","
                    + "\"libelle\":\"" + ej(libelle) + "\","
                    + "\"icone\":\"" + ej(icone) + "\","
                    + "\"couleur\":\"" + ej(couleur) + "\","
                    + "\"urlpattern\":\"" + ej(urlpat) + "\","
                    + "\"valeur\":\"" + ej(valeur.trim()) + "\"}";

            /* ── DELETE ── */
            } else if ("delete".equals(action)) {
                if (idprofilsocial == null)
                    return "{\"success\":false,\"error\":\"ID manquant\"}";

                ProfilSocialMedia[] arr = (ProfilSocialMedia[]) CGenUtil.rechercher(
                    new ProfilSocialMedia(), null, null, conn,
                    " and idprofilsocial='" + idprofilsocial.replace("'", "''")
                    + "' and idprofil='" + idprofil.replace("'", "''") + "'");
                if (arr == null || arr.length == 0)
                    return "{\"success\":false,\"error\":\"Social media non trouve\"}";

                arr[0].deleteToTable(conn);
                conn.commit();
                return "{\"success\":true}";

            /* ── LIST ── */
            } else if ("list".equals(action)) {
                ProfilSocialMedia[] psmArr = (ProfilSocialMedia[]) CGenUtil.rechercher(
                    new ProfilSocialMedia(), null, null, conn,
                    " and idprofil='" + idprofil.replace("'", "''") + "'");
                StringBuilder sb = new StringBuilder("[");
                if (psmArr != null) {
                    for (int i = 0; i < psmArr.length; i++) {
                        ReseauSocial[] rsArr = (ReseauSocial[]) CGenUtil.rechercher(
                            new ReseauSocial(), null, null, conn,
                            " and idreseausocial='" + psmArr[i].getIdReseauSocial().replace("'", "''") + "'");
                        String libelle = "", icone = "", couleur = "", urlpat = "";
                        if (rsArr != null && rsArr.length > 0) {
                            libelle = rsArr[0].getLibelle() != null ? rsArr[0].getLibelle() : "";
                            icone   = rsArr[0].getIconeClass() != null ? rsArr[0].getIconeClass() : "";
                            couleur = rsArr[0].getCouleurHex() != null ? rsArr[0].getCouleurHex() : "";
                            urlpat  = rsArr[0].getUrlPattern() != null ? rsArr[0].getUrlPattern() : "";
                        }
                        if (i > 0) sb.append(",");
                        sb.append("{");
                        sb.append("\"idprofilsocial\":\"").append(ej(psmArr[i].getIdProfilSocial())).append("\",");
                        sb.append("\"idreseausocial\":\"").append(ej(psmArr[i].getIdReseauSocial())).append("\",");
                        sb.append("\"libelle\":\"").append(ej(libelle)).append("\",");
                        sb.append("\"icone\":\"").append(ej(icone)).append("\",");
                        sb.append("\"couleur\":\"").append(ej(couleur)).append("\",");
                        sb.append("\"urlpattern\":\"").append(ej(urlpat)).append("\",");
                        sb.append("\"valeur\":\"").append(psmArr[i].getValeur() != null ? ej(psmArr[i].getValeur()) : "").append("\"");
                        sb.append("}");
                    }
                }
                sb.append("]");
                return "{\"success\":true,\"data\":" + sb.toString() + "}";

            } else {
                return "{\"success\":false,\"error\":\"Action inconnue: " + action + "\"}";
            }
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /* ═══════════════════════════════════════════════════════════
     * SPECIALITE PROFIL CRUD
     * ═══════════════════════════════════════════════════════════ */
    public static String crudSpecialite(int refuser, String action,
            String specialiteprofil, String idspecialite, String niveauStr) throws Exception {

        if (action == null) return "{\"success\":false,\"error\":\"Action manquante\"}";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            Profil profil = Profil.findByRefUser(refuser, conn);
            if (profil == null) return "{\"success\":false,\"error\":\"Profil introuvable\"}";
            String idprofil = profil.getIdprofil();

            /* ── ADD ── */
            if ("add".equals(action)) {
                if (idspecialite == null || idspecialite.trim().isEmpty())
                    return "{\"success\":false,\"error\":\"Specialite obligatoire\"}";

                int niveau = 1;
                try { if (niveauStr != null) niveau = Integer.parseInt(niveauStr.trim()); } catch (Exception e) {}

                // Verifier doublon
                Specialiteprofil[] existing = (Specialiteprofil[]) CGenUtil.rechercher(
                    new Specialiteprofil(), null, null, conn,
                    " and idprofil='" + idprofil.replace("'", "''")
                    + "' and idspecialite='" + idspecialite.trim().replace("'", "''") + "'");
                if (existing != null && existing.length > 0)
                    return "{\"success\":false,\"error\":\"Cette specialite est deja ajoutee\"}";

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
                    " and idspecialite='" + idspecialite.trim().replace("'", "''") + "'");
                String libelle = "";
                if (specRes != null && specRes.length > 0 && specRes[0].getLibelle() != null)
                    libelle = specRes[0].getLibelle();

                return "{\"success\":true,\"id\":\"" + sp.getSpecialiteprofil()
                    + "\",\"libelle\":\"" + ej(libelle) + "\",\"niveau\":" + niveau + "}";

            /* ── UPDATE ── */
            } else if ("update".equals(action)) {
                if (specialiteprofil == null) return "{\"success\":false,\"error\":\"ID manquant\"}";

                Specialiteprofil[] arr = (Specialiteprofil[]) CGenUtil.rechercher(
                    new Specialiteprofil(), null, null, conn,
                    " and specialiteprofil='" + specialiteprofil.replace("'", "''")
                    + "' and idprofil='" + idprofil.replace("'", "''") + "'");
                if (arr == null || arr.length == 0)
                    return "{\"success\":false,\"error\":\"Specialite profil non trouvee\"}";

                Specialiteprofil sp = arr[0];
                if (niveauStr != null) {
                    try { sp.setNiveau(Integer.parseInt(niveauStr.trim())); } catch (Exception e) {}
                }
                sp.setMode("modif");
                sp.updateToTableWithHisto(userId, conn);
                conn.commit();
                return "{\"success\":true}";

            /* ── DELETE ── */
            } else if ("delete".equals(action)) {
                if (specialiteprofil == null) return "{\"success\":false,\"error\":\"ID manquant\"}";

                Specialiteprofil[] arr = (Specialiteprofil[]) CGenUtil.rechercher(
                    new Specialiteprofil(), null, null, conn,
                    " and specialiteprofil='" + specialiteprofil.replace("'", "''")
                    + "' and idprofil='" + idprofil.replace("'", "''") + "'");
                if (arr == null || arr.length == 0)
                    return "{\"success\":false,\"error\":\"Specialite profil non trouvee\"}";

                arr[0].deleteToTable(conn);
                conn.commit();
                return "{\"success\":true}";

            /* ── LIST ── */
            } else if ("list".equals(action)) {
                Specialiteprofil[] spArr = (Specialiteprofil[]) CGenUtil.rechercher(
                    new Specialiteprofil(), null, null, conn,
                    " and idprofil='" + idprofil.replace("'", "''") + "'");
                StringBuilder sb = new StringBuilder("[");
                if (spArr != null) {
                    for (int i = 0; i < spArr.length; i++) {
                        String libelle = "";
                        Specialite[] sRes = (Specialite[]) CGenUtil.rechercher(
                            new Specialite(), null, null, conn,
                            " and idspecialite='" + spArr[i].getIdspecialite().replace("'", "''") + "'");
                        if (sRes != null && sRes.length > 0 && sRes[0].getLibelle() != null)
                            libelle = sRes[0].getLibelle();

                        if (i > 0) sb.append(",");
                        sb.append("{");
                        sb.append("\"specialiteprofil\":\"").append(spArr[i].getSpecialiteprofil()).append("\",");
                        sb.append("\"idspecialite\":\"").append(spArr[i].getIdspecialite()).append("\",");
                        sb.append("\"libelle\":\"").append(ej(libelle)).append("\",");
                        sb.append("\"niveau\":").append(spArr[i].getNiveau());
                        sb.append("}");
                    }
                }
                sb.append("]");
                return "{\"success\":true,\"data\":" + sb.toString() + "}";

            } else {
                return "{\"success\":false,\"error\":\"Action inconnue: " + action + "\"}";
            }
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
