package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Timestamp;

public class ProfilSocialMedia extends ClassMAPTable {

    private String idprofilsocial;
    private String idprofil;
    private String idReseauSocial;
    private String valeur;
    private Timestamp datyCreation;
    private Timestamp datyModification;

    public ProfilSocialMedia() {
        setNomTable("profilsocialmedia");
    }

    public String getIdprofilsocial() {
        return idprofilsocial;
    }

    public void setIdprofilsocial(String idprofilsocial) {
        this.idprofilsocial = idprofilsocial;
    }

    // Backward-compatible camelCase accessors
    public String getIdProfilSocial() { return getIdprofilsocial(); }
    public void setIdProfilSocial(String id) { setIdprofilsocial(id); }

    public ProfilSocialMedia(String idprofil, String idReseauSocial, String valeur) {
        setNomTable("profilsocialmedia");
        this.idprofil = idprofil;
        this.idReseauSocial = idReseauSocial;
        this.valeur = valeur;
    }

    @Override
    public String getTuppleID() {
        return getIdprofilsocial();
    }

    @Override
    public String getAttributIDName() {
        return "idprofilsocial";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PSM", "getseqprofilsocialmedia");
        this.setIdprofilsocial(makePK(c));
    }

    // Getters & Setters
    public String getIdprofil() {
        return idprofil;
    }

    public void setIdprofil(String idprofil) {
        this.idprofil = idprofil;
    }

    public String getIdReseauSocial() {
        return idReseauSocial;
    }

    public void setIdReseauSocial(String idReseauSocial) {
        this.idReseauSocial = idReseauSocial;
    }

    public String getValeur() {
        return valeur;
    }

    public void setValeur(String valeur) {
        this.valeur = valeur;
    }

    public Timestamp getDatyCreation() {
        return datyCreation;
    }

    public void setDatyCreation(Timestamp datyCreation) {
        this.datyCreation = datyCreation;
    }

    public Timestamp getDatyModification() {
        return datyModification;
    }

    public void setDatyModification(Timestamp datyModification) {
        this.datyModification = datyModification;
    }

    @Override
    public String toString() {
        return "ProfilSocialMedia{" +
                "idprofilsocial='" + idprofilsocial + '\'' +
                ", idprofil='" + idprofil + '\'' +
                ", idReseauSocial='" + idReseauSocial + '\'' +
                ", valeur='" + valeur + '\'' +
                '}';
    }
}
