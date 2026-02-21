package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Option extends ClassMAPTable {

    private String idoption;
    private String libelle;

    public Option() {
        setNomTable("option");
    }

    @Override
    public String getTuppleID() {
        return getIdoption();
    }

    @Override
    public String getAttributIDName() {
        return "idoption";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("OPT", "get_seq_option");
        this.setIdoption(makePK(c));
    }

    public String getIdoption() {
        return idoption;
    }

    public void setIdoption(String idoption) {
        this.idoption = idoption;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
