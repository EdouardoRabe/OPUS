package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Typesignalement extends ClassMAPTable {

    private String idtypesignalement;
    private String libelle;

    public Typesignalement() {
        setNomTable("typesignalement");
    }

    @Override
    public String getTuppleID() {
        return getIdTypesignalement();
    }

    @Override
    public String getAttributIDName() {
        return "idtypesignalement";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("TSG", "get_seq_typesignalement");
        this.setTypesignalement(makePK(c));
    }

    public String getIdTypesignalement() {
        return idtypesignalement;
    }

    public void setTypesignalement(String typesignalement) {
        this.idtypesignalement = typesignalement;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
