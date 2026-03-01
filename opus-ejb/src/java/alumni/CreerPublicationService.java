package alumni;

import java.sql.*;
import java.util.*;
import java.util.regex.*;
import java.io.File;
import bean.CGenUtil;
import utilitaire.UtilDB;

/**
 * Service pour la creation de publication (operations DB uniquement).
 * Le parsing multipart reste dans le JSP.
 * Gere sa propre connexion.
 * Utilise APJ (CGenUtil, ClassMAPTable) au maximum.
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

            // ── Creer la publication ──
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

            // ── Medias ──
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

            // ── Identifications ──
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

            // ── Hashtags : charger les referentiels via APJ ──
            Pattern hp = Pattern.compile("#([A-Za-z0-9]+)");
            Matcher hm = hp.matcher(pub.getDescritpion() != null ? pub.getDescritpion() : "");
            Set htDone = new HashSet();

            // Charger specialites via APJ
            Specialite[] specArr = (Specialite[]) CGenUtil.rechercher(
                new Specialite(), null, null, conn, "");
            if (specArr == null) specArr = new Specialite[0];
            String[] sIds = new String[specArr.length];
            String[] sNorms = new String[specArr.length];
            for (int si = 0; si < specArr.length; si++) {
                sIds[si] = specArr[si].getIdspecialite();
                sNorms[si] = specArr[si].getLibelle() != null
                    ? specArr[si].getLibelle().toUpperCase().replaceAll("[^A-Z0-9]", "") : "";
            }

            // Charger promotions via APJ
            Promotion[] promoArr = (Promotion[]) CGenUtil.rechercher(
                new Promotion(), null, null, conn, "");
            if (promoArr == null) promoArr = new Promotion[0];
            String[] pIds = new String[promoArr.length];
            String[] pNorms = new String[promoArr.length];
            for (int pi = 0; pi < promoArr.length; pi++) {
                pIds[pi] = promoArr[pi].getIdpromotion();
                pNorms[pi] = promoArr[pi].getLibelle() != null
                    ? promoArr[pi].getLibelle().toUpperCase().replaceAll("[^A-Z0-9]", "") : "";
            }

            // Charger parcours via APJ
            Parcours[] parcArr = (Parcours[]) CGenUtil.rechercher(
                new Parcours(), null, null, conn, "");
            if (parcArr == null) parcArr = new Parcours[0];
            String[] rcIds = new String[parcArr.length];
            String[] rcNorms = new String[parcArr.length];
            for (int ri = 0; ri < parcArr.length; ri++) {
                rcIds[ri] = parcArr[ri].getIdparcours();
                rcNorms[ri] = parcArr[ri].getLibelle() != null
                    ? parcArr[ri].getLibelle().toUpperCase().replaceAll("[^A-Z0-9]", "") : "";
            }

            // ── Inserer les hashtags (raw SQL : SERIAL PK + ON CONFLICT DO NOTHING) ──
            while (hm.find()) {
                String tok = hm.group(1).toUpperCase().replaceAll("[^A-Z0-9]", "");
                if (tok.isEmpty() || htDone.contains(tok)) continue;
                htDone.add(tok);
                String tag = "#" + tok;
                boolean found = false;

                // Match specialite
                for (int xi = 0; xi < sIds.length && !found; xi++) {
                    if (sNorms[xi].equals(tok) || sNorms[xi].startsWith(tok) || tok.startsWith(sNorms[xi])) {
                        insertHashtagRaw(conn, pub.getIdpublication(), tag, "SPECIALITE", sIds[xi]);
                        found = true;
                    }
                }
                // Match promotion
                if (!found) {
                    for (int xi = 0; xi < pIds.length; xi++) {
                        if (pNorms[xi].equals(tok)) {
                            insertHashtagRaw(conn, pub.getIdpublication(), tag, "PROMOTION", pIds[xi]);
                            found = true; break;
                        }
                    }
                }
                // Match parcours
                if (!found) {
                    for (int xi = 0; xi < rcIds.length; xi++) {
                        if (rcNorms[xi].equals(tok) || rcNorms[xi].startsWith(tok) || tok.startsWith(rcNorms[xi])) {
                            insertHashtagRaw(conn, pub.getIdpublication(), tag, "PARCOURS", rcIds[xi]);
                            found = true; break;
                        }
                    }
                }
            }

            // ── Notifications hashtag ──
            {
                String nomSource = Notification.getNomUtilisateur(conn, refuser);
                String lienPub = "module.jsp?but=accueil.jsp&scrollTo=pub-" + pub.getIdpublication();
                Set notifUsers = new HashSet();

                // Charger les hashtags de cette publication via APJ
                Publicationhashtag[] htArr = (Publicationhashtag[]) CGenUtil.rechercher(
                    new Publicationhashtag(), null, null, conn,
                    " and idpublication='" + pub.getIdpublication() + "'");
                if (htArr == null) htArr = new Publicationhashtag[0];

                for (int hi = 0; hi < htArr.length; hi++) {
                    String typetag = htArr[hi].getTypetag();
                    String idref = htArr[hi].getIdref();
                    if ("SPECIALITE".equals(typetag)) {
                        // JOIN specialiteprofil + profil : raw SQL justifie (JOIN)
                        PreparedStatement ups = conn.prepareStatement(
                            "SELECT DISTINCT p.idutilisateur FROM specialiteprofil sp "
                            + "JOIN profil p ON sp.idprofil = p.idprofil "
                            + "WHERE sp.idspecialite = ? AND sp.etat = 1");
                        ups.setString(1, idref);
                        ResultSet urs = ups.executeQuery();
                        while (urs.next()) notifUsers.add(new Integer(urs.getInt("idutilisateur")));
                        urs.close(); ups.close();
                    } else if ("PROMOTION".equals(typetag)) {
                        // Requete simple sur profil via APJ
                        Profil[] profils = (Profil[]) CGenUtil.rechercher(
                            new Profil(), null, null, conn,
                            " and idpromotion='" + idref.replace("'", "''") + "'");
                        if (profils != null) {
                            for (int pi = 0; pi < profils.length; pi++)
                                notifUsers.add(new Integer(profils[pi].getIdutilisateur()));
                        }
                    } else if ("PARCOURS".equals(typetag)) {
                        // Requete simple sur profil via APJ
                        Profil[] profils = (Profil[]) CGenUtil.rechercher(
                            new Profil(), null, null, conn,
                            " and idparcours='" + idref.replace("'", "''") + "'");
                        if (profils != null) {
                            for (int pi = 0; pi < profils.length; pi++)
                                notifUsers.add(new Integer(profils[pi].getIdutilisateur()));
                        }
                    }
                }

                notifUsers.remove(new Integer(refuser));

                // Construire la liste de tags pour le message de notification
                StringBuilder tagList = new StringBuilder();
                for (int hi = 0; hi < htArr.length; hi++) {
                    if (tagList.length() > 0) tagList.append(" ");
                    tagList.append(htArr[hi].getHashtag());
                }
                String tagsStr = tagList.toString();

                Iterator it = notifUsers.iterator();
                while (it.hasNext()) {
                    int targetUser = ((Integer) it.next()).intValue();
                    String objet = nomSource + " a publie une offre qui vous concerne " + tagsStr;
                    Notification.creerEtEnvoyer(conn, userId, targetUser,
                        objet, Notification.TYPE_HASHTAG, lienPub);
                }
            }

            // ── Visibilite (raw SQL justifie : SERIAL PK + ON CONFLICT DO NOTHING) ──
            if (visSpec != null && !visSpec.trim().isEmpty()) {
                String[] vs = visSpec.split(",");
                for (int vi = 0; vi < vs.length; vi++) {
                    String v = vs[vi].trim().replaceAll("[^A-Za-z0-9]", "");
                    if (!v.isEmpty())
                        conn.createStatement().execute(
                            "INSERT INTO publicationvisibilite(idpublication,typecible,idref) "
                            + "VALUES('" + pub.getIdpublication() + "','SPECIALITE','" + v + "') "
                            + "ON CONFLICT DO NOTHING");
                }
            }
            if (visParc != null && !visParc.trim().isEmpty()) {
                String[] vp = visParc.split(",");
                for (int vi = 0; vi < vp.length; vi++) {
                    String v = vp[vi].trim().replaceAll("[^A-Za-z0-9]", "");
                    if (!v.isEmpty())
                        conn.createStatement().execute(
                            "INSERT INTO publicationvisibilite(idpublication,typecible,idref) "
                            + "VALUES('" + pub.getIdpublication() + "','PARCOURS','" + v + "') "
                            + "ON CONFLICT DO NOTHING");
                }
            }
            if (visPromoAnnee != null && !visPromoAnnee.trim().isEmpty()) {
                String vpa = visPromoAnnee.trim();
                if (vpa.matches("\\d{4}[+-]")) {
                    int anneeRef = Integer.parseInt(vpa.substring(0, 4));
                    String dir = String.valueOf(vpa.charAt(4));
                    conn.createStatement().execute(
                        "INSERT INTO publicationvisibilite(idpublication,typecible,idref,anneeref,anneedirection) "
                        + "VALUES('" + pub.getIdpublication() + "','PROMOTION',NULL," + anneeRef + ",'" + dir + "') "
                        + "ON CONFLICT DO NOTHING");
                }
            }
            // Logique visibilite AND : mise a jour via APJ
            if ("AND".equalsIgnoreCase(visLier)) {
                pub.setLogique_visibilite("AND");
                pub.setMode("modif");
                pub.updateToTableWithHisto(userId, conn);
            }

            conn.commit();
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception rx) {}
            throw e;
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception x) {}
        }
    }

    /**
     * Insere un hashtag via raw SQL (SERIAL PK + ON CONFLICT DO NOTHING).
     * La table publicationhashtag a une PK SERIAL (integer auto-increment),
     * incompatible avec construirePK() d'APJ qui genere des VARCHAR.
     */
    private static void insertHashtagRaw(Connection conn,
            String idpublication, String hashtag, String typetag, String idref) throws Exception {
        Statement st = conn.createStatement();
        st.execute("INSERT INTO publicationhashtag(idpublication, hashtag, typetag, idref) "
            + "VALUES('" + idpublication + "','" + hashtag.replace("'", "''") + "','"
            + typetag + "','" + idref + "') ON CONFLICT DO NOTHING");
        st.close();
    }
}