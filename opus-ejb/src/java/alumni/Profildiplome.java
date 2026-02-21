package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

/**
 * Entite pour la table profildiplome.
 * Cle primaire composite en DB : (idoption, idprofil, idprofildiplome).
 * Le champ idprofildiplome sert d'identifiant unique pour le framework APJ.
 */
public class Profildiplome extends ClassMAPTable {

    private String idoption;
    private String idprofil;
    private String idprofildiplome;
    private int etat;
    private String iddiplome;

    public Profildiplome() {
        setNomTable("profildiplome");
    }

    @Override
    public String getTuppleID() {
        return getIdprofildiplome();
    }

    @Override
    public String getAttributIDName() {
        return "idprofildiplome";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PFD", "get_seq_profildiplome");
        this.setIdprofildiplome(makePK(c));
    }

    public String getIdoption() {
        return idoption;
    }

    public void setIdoption(String idoption) {
        this.idoption = idoption;
    }

    public String getIdprofil() {
        return idprofil;
    }

    public void setIdprofil(String idprofil) {
        this.idprofil = idprofil;
    }

    public String getIdprofildiplome() {
        return idprofildiplome;
    }

    public void setIdprofildiplome(String idprofildiplome) {
        this.idprofildiplome = idprofildiplome;
    }

    public int getEtat() {
        return etat;
    }

    public void setEtat(int etat) {
        this.etat = etat;
    }

    public String getIddiplome() {
        return iddiplome;
    }

    public void setIddiplome(String iddiplome) {
        this.iddiplome = iddiplome;
    }
}
