package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Visibilite extends ClassMAPTable {

    private String idvisibilite;
    private String champ;
    private int status;
    private String daty;
    private String idprofil;

    public Visibilite() {
        setNomTable("visibilite");
    }

    @Override
    public String getTuppleID() {
        return getIdvisibilite();
    }

    @Override
    public String getAttributIDName() {
        return "idvisibilite";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("VIS", "get_seq_visibilite");
        this.setIdvisibilite(makePK(c));
    }

    public String getIdvisibilite() {
        return idvisibilite;
    }

    public void setIdvisibilite(String idvisibilite) {
        this.idvisibilite = idvisibilite;
    }

    public String getChampVisibilite() {
        return champ;
    }

    public void setChampVisibilite(String champ) {
        this.champ = champ;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getDaty() {
        return daty;
    }

    public void setDaty(String daty) {
        this.daty = daty;
    }

    public String getIdprofil() {
        return idprofil;
    }

    public void setIdprofil(String idprofil) {
        this.idprofil = idprofil;
    }
}
