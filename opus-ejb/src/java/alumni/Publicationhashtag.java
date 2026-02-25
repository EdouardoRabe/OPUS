package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Publicationhashtag extends ClassMAPTable {

    private String idpublicationhashtag;
    private String idpublication;
    private String hashtag;
    private String typetag;
    private String idref;

    public Publicationhashtag() {
        setNomTable("publicationhashtag");
    }

    @Override
    public String getTuppleID() {
        return getIdpublicationhashtag();
    }

    @Override
    public String getAttributIDName() {
        return "idpublicationhashtag";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PHS", "get_seq_publicationhashtag");
        this.setIdpublicationhashtag(makePK(c));
    }

    public String getIdpublicationhashtag() {
        return idpublicationhashtag;
    }

    public void setIdpublicationhashtag(String idpublicationhashtag) {
        this.idpublicationhashtag = idpublicationhashtag;
    }

    public String getIdpublication() {
        return idpublication;
    }

    public void setIdpublication(String idpublication) {
        this.idpublication = idpublication;
    }

    public String getHashtag() {
        return hashtag;
    }

    public void setHashtag(String hashtag) {
        this.hashtag = hashtag;
    }

    public String getTypetag() {
        return typetag;
    }

    public void setTypetag(String typetag) {
        this.typetag = typetag;
    }

    public String getIdref() {
        return idref;
    }

    public void setIdref(String idref) {
        this.idref = idref;
    }
}
