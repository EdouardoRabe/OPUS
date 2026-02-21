package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Parcours extends ClassMAPTable {

    private String idparcours;
    private String libelle;

    public Parcours() {
        setNomTable("parcours");
    }

    @Override
    public String getTuppleID() {
        return getIdparcours();
    }

    @Override
    public String getAttributIDName() {
        return "idparcours";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PAR", "get_seq_parcours");
        this.setIdparcours(makePK(c));
    }

    public String getIdparcours() {
        return idparcours;
    }

    public void setIdparcours(String idparcours) {
        this.idparcours = idparcours;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
