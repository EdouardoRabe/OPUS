package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Typesignalement extends ClassMAPTable {

    private String typesignalement;
    private String libelle;

    public Typesignalement() {
        setNomTable("typesignalement");
    }

    @Override
    public String getTuppleID() {
        return getTypesignalement();
    }

    @Override
    public String getAttributIDName() {
        return "typesignalement";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("TSG", "get_seq_typesignalement");
        this.setTypesignalement(makePK(c));
    }

    public String getTypesignalement() {
        return typesignalement;
    }

    public void setTypesignalement(String typesignalement) {
        this.typesignalement = typesignalement;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
