package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;

public class Historique extends ClassMAPTable {

    private String idhistorique;
    private Date datehistorique;
    private String heure;
    private String objet;
    private String action;
    private int idutilisateur;
    private String refobjet;

    public Historique() {
        setNomTable("historique");
    }

    public String getIdhistorique() {
        return idhistorique;
    }

    public void setIdhistorique(String idhistorique) {
        this.idhistorique = idhistorique;
    }

    @Override
    public String getTuppleID() {
        return getIdhistorique();
    }

    @Override
    public String getAttributIDName() {
        return "idhistorique";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("HIS", "get_seq_historique");
        this.setIdhistorique(makePK(c));
    }

    public Date getDatehistorique() {
        return datehistorique;
    }

    public void setDatehistorique(Date datehistorique) {
        this.datehistorique = datehistorique;
    }

    public String getHeure() {
        return heure;
    }

    public void setHeure(String heure) {
        this.heure = heure;
    }

    public String getObjet() {
        return objet;
    }

    public void setObjet(String objet) {
        this.objet = objet;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public String getRefobjet() {
        return refobjet;
    }

    public void setRefobjet(String refobjet) {
        this.refobjet = refobjet;
    }
}
