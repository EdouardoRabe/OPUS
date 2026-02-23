package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;

public class Evenement extends ClassMAPTable {

    private String idevenement;
    private String description;
    private Date daty;
    private Date datefin;
    private Date datedebut;
    private int idutilisateur;

    public Evenement() {
        setNomTable("evenement");
    }

    @Override
    public String getTuppleID() {
        return getIdevenement();
    }

    @Override
    public String getAttributIDName() {
        return "idevenement";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("EVT", "get_seq_evenement");
        this.setIdevenement(makePK(c));
    }

    public String getIdevenement() {
        return idevenement;
    }

    public void setIdevenement(String idevenement) {
        this.idevenement = idevenement;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Date getDaty() {
        return daty;
    }

    public void setDaty(Date daty) {
        this.daty = daty;
    }

    public Date getDatefin() {
        return datefin;
    }

    public void setDatefin(Date datefin) {
        this.datefin = datefin;
    }

    public Date getDatedebut() {
        return datedebut;
    }

    public void setDatedebut(Date datedebut) {
        this.datedebut = datedebut;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }
}
