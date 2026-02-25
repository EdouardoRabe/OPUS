package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Typesignalement extends ClassMAPTable {

    private String idTypesignalement;
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
        this.setIdTypesignalement(makePK(c));
    }

    public String getIdTypesignalement() {
        return idTypesignalement;
    }

    public void setIdTypesignalement(String typesignalement) {
        this.idTypesignalement = typesignalement;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
