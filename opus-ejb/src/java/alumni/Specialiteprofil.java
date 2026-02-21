package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

/**
 * Entite pour la table specialiteprofil.
 * Cle primaire composite en DB : (idspecialite, idprofil, specialiteprofil).
 * Le champ specialiteprofil sert d'identifiant unique pour le framework APJ.
 */
public class Specialiteprofil extends ClassMAPTable {

    private String idspecialite;
    private String idprofil;
    private String specialiteprofil;
    private int etat;
    private int niveau;

    public Specialiteprofil() {
        setNomTable("specialiteprofil");
    }

    @Override
    public String getTuppleID() {
        return getSpecialiteprofil();
    }

    @Override
    public String getAttributIDName() {
        return "specialiteprofil";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("SPP", "get_seq_specialiteprofil");
        this.setSpecialiteprofil(makePK(c));
    }

    public String getIdspecialite() {
        return idspecialite;
    }

    public void setIdspecialite(String idspecialite) {
        this.idspecialite = idspecialite;
    }

    public String getIdprofil() {
        return idprofil;
    }

    public void setIdprofil(String idprofil) {
        this.idprofil = idprofil;
    }

    public String getSpecialiteprofil() {
        return specialiteprofil;
    }

    public void setSpecialiteprofil(String specialiteprofil) {
        this.specialiteprofil = specialiteprofil;
    }

    public int getEtat() {
        return etat;
    }

    public void setEtat(int etat) {
        this.etat = etat;
    }

    public int getNiveau() {
        return niveau;
    }

    public void setNiveau(int niveau) {
        this.niveau = niveau;
    }
}
