package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Promotion extends ClassMAPTable {

    private String idpromotion;
    private int annee;
    private String libelle;
    private String idparcours;

    public Promotion() {
        setNomTable("promotion");
    }

    @Override
    public String getTuppleID() {
        return getIdpromotion();
    }

    @Override
    public String getAttributIDName() {
        return "idpromotion";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PRM", "get_seq_promotion");
        this.setIdpromotion(makePK(c));
    }

    public String getIdpromotion() {
        return idpromotion;
    }

    public void setIdpromotion(String idpromotion) {
        this.idpromotion = idpromotion;
    }

    public int getAnnee() {
        return annee;
    }

    public void setAnnee(int annee) {
        this.annee = annee;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }

    public String getIdparcours() {
        return idparcours;
    }

    public void setIdparcours(String idparcours) {
        this.idparcours = idparcours;
    }
}
