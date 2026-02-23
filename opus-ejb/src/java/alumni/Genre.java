package alumni;
import bean.ClassMAPTable;
import java.sql.Connection;

public class Genre extends ClassMAPTable {
    private String idgenre;
    private String libelle;

    public Genre() {
        setNomTable("genre");
    }

    public Genre(String idgenre, String libelle) {
        this.idgenre = idgenre;
        this.libelle = libelle;
    }

     @Override
    public String getTuppleID() {
        return getIdgenre();
    }

    @Override
    public String getAttributIDName() {
        return "idgenre";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("GEN", "get_seq_genre");
        this.setIdgenre(makePK(c));
    }

    public String getIdgenre() {
        return idgenre;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setIdgenre(String idgenre) {
        this.idgenre = idgenre;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}