package user;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;

public class HistoriqueActifLib  extends ClassMAPTable {
    private String id;
    private String idutilisateur;
    private int estactif;
    private Date daty;
    private String estactiflib;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(String idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public int getEstactif() {
        return estactif;
    }

    public void setEstactif(int estactif) {
        this.estactif = estactif;
    }

    public Date getDaty() {
        return daty;
    }

    public void setDaty(Date daty) {
        this.daty = daty;
    }

    public String getEstactiflib() {
        return estactiflib;
    }

    public void setEstactiflib(String estactiflib) {
        this.estactiflib = estactiflib;
    }



    public HistoriqueActifLib () throws Exception {
        this.setNomTable("historiqueactiflib");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("HISA","Getseqhistoriqueactif");
        this.setId(makePK(c));
    }

    @Override
    public String getTuppleID() {
        return id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }
}

