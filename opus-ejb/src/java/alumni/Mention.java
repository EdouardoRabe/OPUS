package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Mention extends ClassMAPTable {

    private String idmention;
    private int idutilisateur;       
    private String idpublicationcommentaire;

    public Mention() {
        setNomTable("mention");
    }

    @Override
    public String getTuppleID() {
        return getIdmention();
    }

    @Override
    public String getAttributIDName() {
        return "idmention";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("MNT", "get_seq_mention");
        this.setIdmention(makePK(c));
    }

    public String getIdmention() {
        return idmention;
    }

    public void setIdmention(String idmention) {
        this.idmention = idmention;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public String getIdpublicationcommentaire() {
        return idpublicationcommentaire;
    }

    public void setIdpublicationcommentaire(String idpublicationcommentaire) {
        this.idpublicationcommentaire = idpublicationcommentaire;
    }
}
