package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;

public class Experience extends ClassMAPTable {

    private String idexperience;
    private String entreprise;
    private Date debut;
    private Date fin;
    private String description;
    private int etat;
    private String idprofil;
    private String idposte;

    public Experience() {
        setNomTable("experience");
    }

    @Override
    public String getTuppleID() {
        return getIdexperience();
    }

    @Override
    public String getAttributIDName() {
        return "idexperience";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("EXP", "get_seq_experience");
        this.setIdexperience(makePK(c));
    }

    public String getIdexperience() {
        return idexperience;
    }

    public void setIdexperience(String idexperience) {
        this.idexperience = idexperience;
    }

    public String getEntreprise() {
        return entreprise;
    }

    public void setEntreprise(String entreprise) {
        this.entreprise = entreprise;
    }

    public Date getDebut() {
        return debut;
    }

    public void setDebut(Date debut) {
        this.debut = debut;
    }

    public Date getFin() {
        return fin;
    }

    public void setFin(Date fin) {
        this.fin = fin;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getEtat() {
        return etat;
    }

    public void setEtat(int etat) {
        this.etat = etat;
    }

    public String getIdprofil() {
        return idprofil;
    }

    public void setIdprofil(String idprofil) {
        this.idprofil = idprofil;
    }

    public String getIdposte() {
        return idposte;
    }

    public void setIdposte(String idposte) {
        this.idposte = idposte;
    }
}
