package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Publicationcommentaire extends ClassMAPTable {

    private String idpublicationcommentaire;
    private String description;
    private int etat;
    private int idutilisateur;
    private String idpublicationcommentaire_1;
    private String idpublication;

    public Publicationcommentaire() {
        setNomTable("publicationcommentaire");
    }

    @Override
    public String getTuppleID() {
        return getIdpublicationcommentaire();
    }

    @Override
    public String getAttributIDName() {
        return "idpublicationcommentaire";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PCM", "get_seq_publicationcommentaire");
        this.setIdpublicationcommentaire(makePK(c));
    }

    public String getIdpublicationcommentaire() {
        return idpublicationcommentaire;
    }

    public void setIdpublicationcommentaire(String idpublicationcommentaire) {
        this.idpublicationcommentaire = idpublicationcommentaire;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getEtat() {
        return etat;
    }

    public void setEtat(int etat) {
        this.etat = etat;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public String getIdpublicationcommentaire_1() {
        return idpublicationcommentaire_1;
    }

    public void setIdpublicationcommentaire_1(String idpublicationcommentaire_1) {
        this.idpublicationcommentaire_1 = idpublicationcommentaire_1;
    }

    public String getIdpublication() {
        return idpublication;
    }

    public void setIdpublication(String idpublication) {
        this.idpublication = idpublication;
    }
}
