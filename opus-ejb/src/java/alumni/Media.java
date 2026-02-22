package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Media extends ClassMAPTable {

    private String idmedia;
    private String mediaurl;
    private String idmediatype;
    private String idpublication;

    public Media() {
        setNomTable("media");
    }

    @Override
    public String getTuppleID() {
        return getIdmedia();
    }

    @Override
    public String getAttributIDName() {
        return "idmedia";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("MDA", "get_seq_media");
        this.setIdmedia(makePK(c));
    }

    public String getIdmedia() {
        return idmedia;
    }

    public void setIdmedia(String idmedia) {
        this.idmedia = idmedia;
    }

    public String getMediaurl() {
        return mediaurl;
    }

    public void setMediaurl(String mediaurl) {
        this.mediaurl = mediaurl;
    }

    public String getIdmediatype() {
        return idmediatype;
    }

    public void setIdmediatype(String idmediatype) {
        this.idmediatype = idmediatype;
    }

    public String getIdpublication() {
        return idpublication;
    }

    public void setIdpublication(String idpublication) {
        this.idpublication = idpublication;
    }
}
