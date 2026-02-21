package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Evenement extends ClassMAPTable {

    private String idevenement;
    private String description;
    private String daty;
    private String datefin;
    private String datedebut;
    private String idutilisateur;

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

    public String getDaty() {
        return daty;
    }

    public void setDaty(String daty) {
        this.daty = daty;
    }

    public String getDatefin() {
        return datefin;
    }

    public void setDatefin(String datefin) {
        this.datefin = datefin;
    }

    public String getDatedebut() {
        return datedebut;
    }

    public void setDatedebut(String datedebut) {
        this.datedebut = datedebut;
    }

    public String getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(String idutilisateur) {
        this.idutilisateur = idutilisateur;
    }
}
