package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Poste extends ClassMAPTable {

    private String idposte;
    private String libelle;

    public Poste() {
        setNomTable("poste");
    }

    @Override
    public String getTuppleID() {
        return getIdposte();
    }

    @Override
    public String getAttributIDName() {
        return "idposte";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("POS", "get_seq_poste");
        this.setIdposte(makePK(c));
    }

    public String getIdposte() {
        return idposte;
    }

    public void setIdposte(String idposte) {
        this.idposte = idposte;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
