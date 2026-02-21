package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Mediatype extends ClassMAPTable {

    private String idmediatype;
    private String libelle;

    public Mediatype() {
        setNomTable("mediatype");
    }

    @Override
    public String getTuppleID() {
        return getIdmediatype();
    }

    @Override
    public String getAttributIDName() {
        return "idmediatype";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("MDT", "get_seq_mediatype");
        this.setIdmediatype(makePK(c));
    }

    public String getIdmediatype() {
        return idmediatype;
    }

    public void setIdmediatype(String idmediatype) {
        this.idmediatype = idmediatype;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
