package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Commentairereaction extends ClassMAPTable {

    private String idcommentairereaction;
    private int idutilisateur;
    private String idpublicationcommentaire;
    private String idreactiontype;

    public Commentairereaction() {
        setNomTable("commentairereaction");
    }

    @Override
    public String getTuppleID() {
        return getIdcommentairereaction();
    }

    @Override
    public String getAttributIDName() {
        return "idcommentairereaction";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("CRE", "get_seq_commentairereaction");
        this.setIdcommentairereaction(makePK(c));
    }

    public String getIdcommentairereaction() {
        return idcommentairereaction;
    }

    public void setIdcommentairereaction(String idcommentairereaction) {
        this.idcommentairereaction = idcommentairereaction;
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

    public String getIdreactiontype() {
        return idreactiontype;
    }

    public void setIdreactiontype(String idreactiontype) {
        this.idreactiontype = idreactiontype;
    }
}
