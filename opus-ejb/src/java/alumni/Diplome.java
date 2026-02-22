package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Diplome extends ClassMAPTable {

    private String iddiplome;
    private String libelle;

    public Diplome() {
        setNomTable("diplome");
    }

    @Override
    public String getTuppleID() {
        return getIddiplome();
    }

    @Override
    public String getAttributIDName() {
        return "iddiplome";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("DIP", "get_seq_diplome");
        this.setIddiplome(makePK(c));
    }

    public String getIddiplome() {
        return iddiplome;
    }

    public void setIddiplome(String iddiplome) {
        this.iddiplome = iddiplome;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
