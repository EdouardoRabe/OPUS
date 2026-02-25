package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;

public class ProfilStatut extends ClassMAPTable {

    private String id;
    private String idprofil;
    private String idprofiltypestatut;
    private Date daty;

    public ProfilStatut() {
        setNomTable("profilstatut");
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getIdprofil() {
        return idprofil;
    }

    public void setIdprofil(String idprofil) {
        this.idprofil = idprofil;
    }

    public String getIdprofiltypestatut() {
        return idprofiltypestatut;
    }

    public void setIdprofiltypestatut(String idprofiltypestatut) {
        this.idprofiltypestatut = idprofiltypestatut;
    }

    public Date getDaty() {
        return daty;
    }

    public void setDaty(Date daty) {
        this.daty = daty;
    }

    @Override
    public String getTuppleID() {
        return getId();
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PS", "getseqprofilstatut");
        this.setId(makePK(c));
    }

    @Override
    public String toString() {
        return "ProfilStatut{" +
                "id='" + id + '\'' +
                ", idprofil='" + idprofil + '\'' +
                ", idprofiltypestatut='" + idprofiltypestatut + '\'' +
                '}';
    }
}
