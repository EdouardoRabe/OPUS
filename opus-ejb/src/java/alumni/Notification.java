package alumni;

import bean.ClassMAPTable;
import bean.CGenUtil;
import java.sql.Connection;
import java.text.SimpleDateFormat;
import java.util.Date;
import web.socket.NotificationSocket;

/**
 * Entite Notification - notifications de type Facebook
 * Types: COMMENT, REPLY, PUB_REACTION, COMM_REACTION, MENTION, IDENTIFICATION
 */
public class Notification extends ClassMAPTable {

    // Types de notification
    public static final String TYPE_COMMENT = "COMMENT";
    public static final String TYPE_REPLY = "REPLY";
    public static final String TYPE_PUB_REACTION = "PUB_REACTION";
    public static final String TYPE_COMM_REACTION = "COMM_REACTION";
    public static final String TYPE_MENTION = "MENTION";
    public static final String TYPE_IDENTIFICATION = "IDENTIFICATION";
    public static final String TYPE_EVENEMENT = "EVENEMENT";
    public static final String TYPE_HASHTAG = "HASHTAG";

    private String idnotification;
    private String objet;
    private java.sql.Date daty;
    private String idorigine;
    private String lien;
    private int etat;
    private String heure;
    private int idutilisateur;
    private String typenotif;

    public Notification() {
        setNomTable("notification");
    }

    @Override
    public String getTuppleID() {
        return getIdnotification();
    }

    @Override
    public String getAttributIDName() {
        return "idnotification";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("NTF", "get_seq_notification");
        this.setIdnotification(makePK(c));
    }

    public static void creerEtEnvoyer(Connection conn, String userId, int targetUser, 
                                        String objet, String typenotif, String lien) throws Exception {
        if (String.valueOf(targetUser).equals(userId)) return;

        Notification notif = new Notification();
        notif.setObjet(objet);
        notif.setTypenotif(typenotif);
        notif.setLien(lien);
        notif.setIdorigine(userId);
        notif.setIdutilisateur(targetUser);
        notif.setEtat(0); 
        SimpleDateFormat sdfHeure = new SimpleDateFormat("HH:mm:ss");
        Date now = new Date();
        notif.setDaty(new java.sql.Date(now.getTime()));
        notif.setHeure(sdfHeure.format(now));

        notif.construirePK(conn);
        notif.insertToTableWithHisto(userId, conn);

        try {
            String wsMessage = "{\"refUser\":\"" + targetUser + "\",\"message\":\"" 
                + objet.replace("\"", "'") + "\",\"type\":\"" + typenotif + "\"}";
            NotificationSocket.broadcast(wsMessage);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

  
    public static String getNomUtilisateur(Connection conn, int idutilisateur) {
        try {
            Profil[] profils = (Profil[]) CGenUtil.rechercher(
                new Profil(), null, null, conn, 
                " and idutilisateur = " + idutilisateur);
            if (profils != null && profils.length > 0) {
                return profils[0].getNom() + " " + profils[0].getPrenom();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "Quelqu'un";
    }


    public String getIdnotification() {
        return idnotification;
    }

    public void setIdnotification(String idnotification) {
        this.idnotification = idnotification;
    }

    public String getObjet() {
        return objet;
    }

    public void setObjet(String objet) {
        this.objet = objet;
    }

    public java.sql.Date getDaty() {
        return daty;
    }

    public void setDaty(java.sql.Date daty) {
        this.daty = daty;
    }

    public String getIdorigine() {
        return idorigine;
    }

    public void setIdorigine(String idorigine) {
        this.idorigine = idorigine;
    }

    public String getLien() {
        return lien;
    }

    public void setLien(String lien) {
        this.lien = lien;
    }

    public int getEtat() {
        return etat;
    }

    public void setEtat(int etat) {
        this.etat = etat;
    }

    public String getHeure() {
        return heure;
    }

    public void setHeure(String heure) {
        this.heure = heure;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public String getTypenotif() {
        return typenotif;
    }

    public void setTypenotif(String typenotif) {
        this.typenotif = typenotif;
    }
}
