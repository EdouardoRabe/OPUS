package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Specialite extends ClassMAPTable {

    private String idspecialite;
    private String libelle;

    public Specialite() {
        setNomTable("specialite");
    }

    @Override
    public String getTuppleID() {
        return getIdspecialite();
    }

    @Override
    public String getAttributIDName() {
        return "idspecialite";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("SPE", "get_seq_specialite");
        this.setIdspecialite(makePK(c));
    }

    public String getIdspecialite() {
        return idspecialite;
    }

    public void setIdspecialite(String idspecialite) {
        this.idspecialite = idspecialite;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
