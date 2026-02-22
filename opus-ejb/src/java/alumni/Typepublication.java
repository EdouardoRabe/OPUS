package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Typepublication extends ClassMAPTable {

    private String idtypepublication;
    private String libelle;

    public Typepublication() {
        setNomTable("typepublication");
    }

    @Override
    public String getTuppleID() {
        return getIdtypepublication();
    }

    @Override
    public String getAttributIDName() {
        return "idtypepublication";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("TPB", "get_seq_typepublication");
        this.setIdtypepublication(makePK(c));
    }

    public String getIdtypepublication() {
        return idtypepublication;
    }

    public void setIdtypepublication(String idtypepublication) {
        this.idtypepublication = idtypepublication;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
