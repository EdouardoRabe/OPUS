package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Photo extends ClassMAPTable {

    private String idphoto;
    private String image;
    private int type;
    private String daty;
    private String heure;
    private String idprofil;

    public Photo() {
        setNomTable("photo");
    }

    @Override
    public String getTuppleID() {
        return getIdphoto();
    }

    @Override
    public String getAttributIDName() {
        return "idphoto";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PHO", "get_seq_photo");
        this.setIdphoto(makePK(c));
    }

    public String getIdphoto() {
        return idphoto;
    }

    public void setIdphoto(String idphoto) {
        this.idphoto = idphoto;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public String getDaty() {
        return daty;
    }

    public void setDaty(String daty) {
        this.daty = daty;
    }

    public String getHeure() {
        return heure;
    }

    public void setHeure(String heure) {
        this.heure = heure;
    }

    public String getIdprofil() {
        return idprofil;
    }

    public void setIdprofil(String idprofil) {
        this.idprofil = idprofil;
    }
}
