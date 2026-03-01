package alumni;

import java.sql.*;
import java.util.*;
import java.util.regex.*;
import java.io.File;
import utilitaire.UtilDB;

/**
 * Service pour la creation de publication (operations DB uniquement).
 * Le parsing multipart reste dans le JSP.
 * Gere sa propre connexion.
 */
public class CreerPublicationService {

    /**
     * Verifie si l'utilisateur a le droit de publier.
     * @return null si OK, message d'erreur sinon
     */
    public static String verifierDroitPublication(String idrole, int refuser) throws Exception {
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            return Limiterole.verifierDroitPublication(conn, idrole, refuser);
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /**
     * Cree la publication avec medias, identifications, hashtags, visibilite, notifications.
     * @param refuser ID utilisateur
     * @param description texte de la publication
     * @param idtypepublication type de publication
     * @param identifications comma-separated user IDs
     * @param visSpec comma-separated specialite IDs
     * @param visParc comma-separated parcours IDs
     * @param visPromoAnnee ex: "2024+" ou "2020-"
     * @param visLier "AND" ou null
     * @param mediaFiles list of Object[] { String basePath, String fileName, String mediaTypeId }
     */
    public static void creerPublication(int refuser, String description, String idtypepublication,
            String identifications, String visSpec, String visParc, String visPromoAnnee, String visLier,
            List mediaFiles) throws Exception {

        if (description == null) description = "";
        if (idtypepublication == null || idtypepublication.trim().isEmpty())
            idtypepublication = "TPB000001";

        String userId = String.valueOf(refuser);
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            // Creer la publication
            Publication pub = new Publication();
            pub.setDescritpion(description.trim());
            pub.setDaty(java.sql.Date.valueOf(java.time.LocalDate.now()));
            String heure = java.time.LocalTime.now().toString();
            if (heure.length() > 5) heure = heure.substring(0, 5);
            pub.setHeure(heure);
            pub.setEtat(1);
            pub.setIdtypepublication(idtypepublication.trim());
            pub.setIdutilisateur(refuser);
            pub.construirePK(conn);
            pub.insertToTableWithHisto(userId, conn);

            // Medias
            if (mediaFiles != null) {
                for (int mi = 0; mi < mediaFiles.size(); mi++) {
                    Object[] mf = (Object[]) mediaFiles.get(mi);
                    String mediaUrl = (String) mf[0];
                    String mediaTypeId = (String) mf[1];
                    Media media = new Media();
                    media.setMediaurl(mediaUrl);
                    media.setIdmediatype(mediaTypeId);
                    media.setIdpublication(pub.getIdpublication());
                    media.construirePK(conn);
                    media.insertToTableWithHisto(userId, conn);
                }
            }

            // Identifications
            if (identifications != null && !identifications.trim().isEmpty()) {
                String nomSource = Notification.getNomUtilisateur(conn, refuser);
                String lienPub = "module.jsp?but=accueil.jsp&scrollTo=pub-" + pub.getIdpublication();
                String[] tagIds = identifications.split(",");
                for (int t = 0; t < tagIds.length; t++) {
                    String tid = tagIds[t].trim();
                    if (tid.isEmpty()) continue;
                    try {
                        int targetUser = Integer.parseInt(tid);
                        Identification ident = new Identification();
                        ident.setIdutilisateur(targetUser);
                        ident.setIdpublication(pub.getIdpublication());
                        ident.construirePK(conn);
                        ident.insertToTableWithHisto(userId, conn);
                        if (targetUser != refuser) {
                            Notification.creerEtEnvoyer(conn, userId, targetUser,
                                nomSource + " vous a identifie(e) dans une publication",
                                Notification.TYPE_IDENTIFICATION, lienPub);
                        }
                    } catch (NumberFormatException nfe) { /* ignorer */ }
                }
            }

            // Hashtags
            Pattern hp = Pattern.compile("#([A-Za-z0-9]+)");
            Matcher hm = hp.matcher(pub.getDescritpion() != null ? pub.getDescritpion() : "");
            Set htDone = new HashSet();

            PreparedStatement hpst = conn.prepareStatement("SELECT idspecialite, libelle FROM specialite");
            ResultSet hrst = hpst.executeQuery();
            String[] sIds = new String[200]; String[] sNorms = new String[200]; int sn = 0;
            while (hrst.next() && sn < 200) {
                sIds[sn] = hrst.getString("idspecialite");
                sNorms[sn] = hrst.getString("libelle").toUpperCase().replaceAll("[^A-Z0-9]", "");
                sn++;
            }
            hrst.close(); hpst.close();

            hpst = conn.prepareStatement("SELECT idpromotion, libelle FROM promotion");
            hrst = hpst.executeQuery();
            String[] pIds = new String[500]; String[] pNorms = new String[500]; int pn = 0;
            while (hrst.next() && pn < 500) {
                pIds[pn] = hrst.getString("idpromotion");
                pNorms[pn] = hrst.getString("libelle").toUpperCase().replaceAll("[^A-Z0-9]", "");
                pn++;
            }
            hrst.close(); hpst.close();

            hpst = conn.prepareStatement("SELECT idparcours, libelle FROM parcours");
            hrst = hpst.executeQuery();
            String[] rcIds = new String[200]; String[] rcNorms = new String[200]; int rcn = 0;
            while (hrst.next() && rcn < 200) {
                rcIds[rcn] = hrst.getString("idparcours");
                rcNorms[rcn] = hrst.getString("libelle").toUpperCase().replaceAll("[^A-Z0-9]", "");
                rcn++;
            }
            hrst.close(); hpst.close();

            while (hm.find()) {
                String tok = hm.group(1).toUpperCase().replaceAll("[^A-Z0-9]", "");
                if (tok.isEmpty() || htDone.contains(tok)) continue;
                htDone.add(tok);
                String tag = "#" + tok;
                boolean found = false;
                for (int xi = 0; xi < sn && !found; xi++) {
                    if (sNorms[xi].equals(tok) || sNorms[xi].startsWith(tok) || tok.startsWith(sNorms[xi])) {
                        conn.createStatement().execute("INSERT INTO publicationhashtag(idpublication,hashtag,typetag,idref) VALUES('" + pub.getIdpublication() + "','" + tag + "','SPECIALITE','" + sIds[xi] + "') ON CONFLICT DO NOTHING");
                        found = true;
                    }
                }
                if (!found) {
                    for (int xi = 0; xi < pn; xi++) {
                        if (pNorms[xi].equals(tok)) {
                            conn.createStatement().execute("INSERT INTO publicationhashtag(idpublication,hashtag,typetag,idref) VALUES('" + pub.getIdpublication() + "','" + tag + "','PROMOTION','" + pIds[xi] + "') ON CONFLICT DO NOTHING");
                            found = true; break;
                        }
                    }
                }
                if (!found) {
                    for (int xi = 0; xi < rcn; xi++) {
                        if (rcNorms[xi].equals(tok) || rcNorms[xi].startsWith(tok) || tok.startsWith(rcNorms[xi])) {
                            conn.createStatement().execute("INSERT INTO publicationhashtag(idpublication,hashtag,typetag,idref) VALUES('" + pub.getIdpublication() + "','" + tag + "','PARCOURS','" + rcIds[xi] + "') ON CONFLICT DO NOTHING");
                            found = true; break;
                        }
                    }
                }
            }

            // Notifications hashtag
            {
                String nomSource = Notification.getNomUtilisateur(conn, refuser);
                String lienPub = "module.jsp?but=accueil.jsp&scrollTo=pub-" + pub.getIdpublication();
                Set notifUsers = new HashSet();

                PreparedStatement nps = conn.prepareStatement(
                    "SELECT typetag, idref FROM publicationhashtag WHERE idpublication = ?");
                nps.setString(1, pub.getIdpublication());
                ResultSet nrs = nps.executeQuery();
                while (nrs.next()) {
                    String typetag = nrs.getString("typetag");
                    String idref = nrs.getString("idref");
                    if ("SPECIALITE".equals(typetag)) {
                        PreparedStatement ups = conn.prepareStatement(
                            "SELECT DISTINCT p.idutilisateur FROM specialiteprofil sp "
                            + "JOIN profil p ON sp.idprofil = p.idprofil WHERE sp.idspecialite = ? AND sp.etat = 1");
                        ups.setString(1, idref);
                        ResultSet urs = ups.executeQuery();
                        while (urs.next()) notifUsers.add(new Integer(urs.getInt("idutilisateur")));
                        urs.close(); ups.close();
                    } else if ("PROMOTION".equals(typetag)) {
                        PreparedStatement ups = conn.prepareStatement(
                            "SELECT DISTINCT idutilisateur FROM profil WHERE idpromotion = ?");
                        ups.setString(1, idref);
                        ResultSet urs = ups.executeQuery();
                        while (urs.next()) notifUsers.add(new Integer(urs.getInt("idutilisateur")));
                        urs.close(); ups.close();
                    } else if ("PARCOURS".equals(typetag)) {
                        PreparedStatement ups = conn.prepareStatement(
                            "SELECT DISTINCT idutilisateur FROM profil WHERE idparcours = ?");
                        ups.setString(1, idref);
                        ResultSet urs = ups.executeQuery();
                        while (urs.next()) notifUsers.add(new Integer(urs.getInt("idutilisateur")));
                        urs.close(); ups.close();
                    }
                }
                nrs.close(); nps.close();

                notifUsers.remove(new Integer(refuser));

                PreparedStatement hps2 = conn.prepareStatement(
                    "SELECT hashtag FROM publicationhashtag WHERE idpublication = ?");
                hps2.setString(1, pub.getIdpublication());
                ResultSet hrs2 = hps2.executeQuery();
                StringBuilder tagList = new StringBuilder();
                while (hrs2.next()) {
                    if (tagList.length() > 0) tagList.append(" ");
                    tagList.append(hrs2.getString("hashtag"));
                }
                hrs2.close(); hps2.close();
                String tagsStr = tagList.toString();

                Iterator it = notifUsers.iterator();
                while (it.hasNext()) {
                    int targetUser = ((Integer) it.next()).intValue();
                    String objet = nomSource + " a publie une offre qui vous concerne " + tagsStr;
                    Notification.creerEtEnvoyer(conn, userId, targetUser,
                        objet, Notification.TYPE_HASHTAG, lienPub);
                }
            }

            // Visibilite
            if (visSpec != null && !visSpec.trim().isEmpty()) {
                String[] vs = visSpec.split(",");
                for (int vi = 0; vi < vs.length; vi++) {
                    String v = vs[vi].trim().replaceAll("[^A-Za-z0-9]", "");
                    if (!v.isEmpty())
                        conn.createStatement().execute("INSERT INTO publicationvisibilite(idpublication,typecible,idref) VALUES('" + pub.getIdpublication() + "','SPECIALITE','" + v + "') ON CONFLICT DO NOTHING");
                }
            }
            if (visParc != null && !visParc.trim().isEmpty()) {
                String[] vp = visParc.split(",");
                for (int vi = 0; vi < vp.length; vi++) {
                    String v = vp[vi].trim().replaceAll("[^A-Za-z0-9]", "");
                    if (!v.isEmpty())
                        conn.createStatement().execute("INSERT INTO publicationvisibilite(idpublication,typecible,idref) VALUES('" + pub.getIdpublication() + "','PARCOURS','" + v + "') ON CONFLICT DO NOTHING");
                }
            }
            if (visPromoAnnee != null && !visPromoAnnee.trim().isEmpty()) {
                String vpa = visPromoAnnee.trim();
                if (vpa.matches("\\d{4}[+-]")) {
                    int anneeRef = Integer.parseInt(vpa.substring(0, 4));
                    String dir = String.valueOf(vpa.charAt(4));
                    conn.createStatement().execute("INSERT INTO publicationvisibilite(idpublication,typecible,idref,anneeref,anneedirection) VALUES('" + pub.getIdpublication() + "','PROMOTION',NULL," + anneeRef + ",'" + dir + "') ON CONFLICT DO NOTHING");
                }
            }
            if ("AND".equalsIgnoreCase(visLier)) {
                conn.createStatement().execute("UPDATE publication SET logique_visibilite='AND' WHERE idpublication='" + pub.getIdpublication() + "'");
            }

            conn.commit();
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }
}
