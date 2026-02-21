package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Publicationreaction extends ClassMAPTable {

    private String idpublicationreaction;
    private String idreactiontype;
    private String idutilisateur;
    private String idpublication;

    public Publicationreaction() {
        setNomTable("publicationreaction");
    }

    @Override
    public String getTuppleID() {
        return getIdpublicationreaction();
    }

    @Override
    public String getAttributIDName() {
        return "idpublicationreaction";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PRE", "get_seq_publicationreaction");
        this.setIdpublicationreaction(makePK(c));
    }

    public String getIdpublicationreaction() {
        return idpublicationreaction;
    }

    public void setIdpublicationreaction(String idpublicationreaction) {
        this.idpublicationreaction = idpublicationreaction;
    }

    public String getIdreactiontype() {
        return idreactiontype;
    }

    public void setIdreactiontype(String idreactiontype) {
        this.idreactiontype = idreactiontype;
    }

    public String getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(String idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public String getIdpublication() {
        return idpublication;
    }

    public void setIdpublication(String idpublication) {
        this.idpublication = idpublication;
    }
}
