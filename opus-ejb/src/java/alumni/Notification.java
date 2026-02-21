package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Notification extends ClassMAPTable {

    private String idnotification;
    private String objet;
    private String daty;
    private String idorigine;
    private String lien;
    private int etat;
    private String heure;
    private String idutilisateur;

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
        this.preparePk("NTF", "get_seq_notifalumni");
        this.setIdnotification(makePK(c));
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

    public String getDaty() {
        return daty;
    }

    public void setDaty(String daty) {
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

    public String getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(String idutilisateur) {
        this.idutilisateur = idutilisateur;
    }
}
