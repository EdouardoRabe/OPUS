package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Identification extends ClassMAPTable {

    private String ididentification;
    private int idutilisateur;
    private String idpublication;

    public Identification() {
        setNomTable("identification");
    }

    @Override
    public String getTuppleID() {
        return getIdidentification();
    }

    @Override
    public String getAttributIDName() {
        return "ididentification";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("IDN", "get_seq_identification");
        this.setIdidentification(makePK(c));
    }

    public String getIdidentification() {
        return ididentification;
    }

    public void setIdidentification(String ididentification) {
        this.ididentification = ididentification;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public String getIdpublication() {
        return idpublication;
    }

    public void setIdpublication(String idpublication) {
        this.idpublication = idpublication;
    }
}
