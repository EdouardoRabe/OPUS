package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Publication extends ClassMAPTable {

    private String idpublication;
    private String daty;
    private String descritpion;
    private int etat;
    private String idorigine;
    private String heure;
    private String idtypepublication;
    private String idutilisateur;

    public Publication() {
        setNomTable("publication");
    }

    @Override
    public String getTuppleID() {
        return getIdpublication();
    }

    @Override
    public String getAttributIDName() {
        return "idpublication";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PUB", "get_seq_publication");
        this.setIdpublication(makePK(c));
    }

    public String getIdpublication() {
        return idpublication;
    }

    public void setIdpublication(String idpublication) {
        this.idpublication = idpublication;
    }

    public String getDaty() {
        return daty;
    }

    public void setDaty(String daty) {
        this.daty = daty;
    }

    public String getDescritpion() {
        return descritpion;
    }

    public void setDescritpion(String descritpion) {
        this.descritpion = descritpion;
    }

    public int getEtat() {
        return etat;
    }

    public void setEtat(int etat) {
        this.etat = etat;
    }

    public String getIdorigine() {
        return idorigine;
    }

    public void setIdorigine(String idorigine) {
        this.idorigine = idorigine;
    }

    public String getHeure() {
        return heure;
    }

    public void setHeure(String heure) {
        this.heure = heure;
    }

    public String getIdtypepublication() {
        return idtypepublication;
    }

    public void setIdtypepublication(String idtypepublication) {
        this.idtypepublication = idtypepublication;
    }

    public String getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(String idutilisateur) {
        this.idutilisateur = idutilisateur;
    }
}
