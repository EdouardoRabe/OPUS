package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.ResultSet;
import java.sql.Statement;

public class ProfilStatut extends ClassMAPTable {

    private String id;
    private String idprofil;
    private String idprofiltypestatut;
    private Timestamp daty;

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

    public Timestamp getDaty() {
        return daty;
    }

    public void setDaty(Timestamp daty) {
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
        Statement stmt = null;
        ResultSet rs = null;
        try {
            stmt = c.createStatement();
            rs = stmt.executeQuery("SELECT getseqprofilstatut()");
            if (rs.next()) {
                this.setId(rs.getString(1));
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignore) {}
            if (stmt != null) try { stmt.close(); } catch (Exception ignore) {}
        }
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
