package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;

public class ParticipationEvenement extends ClassMAPTable {

    private String idparticipation;
    private String idevenement;
    private int idutilisateur;
    private Date dateparticipation;

    public ParticipationEvenement() {
        setNomTable("participation_evenement");
    }

    @Override
    public String getTuppleID() {
        return getIdparticipation();
    }

    @Override
    public String getAttributIDName() {
        return "idparticipation";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PEV", "get_seq_participation_evenement");
        this.setIdparticipation(makePK(c));
    }

    public String getIdparticipation() {
        return idparticipation;
    }

    public void setIdparticipation(String idparticipation) {
        this.idparticipation = idparticipation;
    }

    public String getIdevenement() {
        return idevenement;
    }

    public void setIdevenement(String idevenement) {
        this.idevenement = idevenement;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public Date getDateparticipation() {
        return dateparticipation;
    }

    public void setDateparticipation(Date dateparticipation) {
        this.dateparticipation = dateparticipation;
    }
}
