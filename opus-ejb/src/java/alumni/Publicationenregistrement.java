package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;

public class Publicationenregistrement extends ClassMAPTable {

    private String idpublicationenregistrement;
    private String idpublication;
    private int idutilisateur;
    private Date daty;
    private String heure;

    public Publicationenregistrement() {
        setNomTable("publicationenregistrement");
    }

    @Override
    public String getTuppleID() {
        return getIdpublicationenregistrement();
    }

    @Override
    public String getAttributIDName() {
        return "idpublicationenregistrement";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("ENR", "get_seq_publicationenregistrement");
        this.setIdpublicationenregistrement(makePK(c));
    }

    public String getIdpublicationenregistrement() {
        return idpublicationenregistrement;
    }

    public void setIdpublicationenregistrement(String idpublicationenregistrement) {
        this.idpublicationenregistrement = idpublicationenregistrement;
    }

    public String getIdpublication() {
        return idpublication;
    }

    public void setIdpublication(String idpublication) {
        this.idpublication = idpublication;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public Date getDaty() {
        return daty;
    }

    public void setDaty(Date daty) {
        this.daty = daty;
    }

    public String getHeure() {
        return heure;
    }

    public void setHeure(String heure) {
        this.heure = heure;
    }
}
