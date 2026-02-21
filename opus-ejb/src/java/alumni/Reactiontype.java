package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Reactiontype extends ClassMAPTable {

    private String idreactiontype;
    private String libelle;

    public Reactiontype() {
        setNomTable("reactiontype");
    }

    @Override
    public String getTuppleID() {
        return getIdreactiontype();
    }

    @Override
    public String getAttributIDName() {
        return "idreactiontype";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("RCT", "get_seq_reactiontype");
        this.setIdreactiontype(makePK(c));
    }

    public String getIdreactiontype() {
        return idreactiontype;
    }

    public void setIdreactiontype(String idreactiontype) {
        this.idreactiontype = idreactiontype;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
