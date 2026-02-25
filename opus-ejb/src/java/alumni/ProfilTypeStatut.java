package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class ProfilTypeStatut extends ClassMAPTable {

    private String idprofiltypestatut;
    private String libelle;
    private String couleur;

    public ProfilTypeStatut(String idprofiltypestatut, String libelle, String couleur) {
        this.idprofiltypestatut = idprofiltypestatut;
        this.libelle = libelle;
        this.couleur = couleur;
    }

    public String getCouleur() {
        return couleur;
    }

    public void setCouleur(String couleur) {
        this.couleur = couleur;
    }

    public ProfilTypeStatut() {
        setNomTable("profiltypestatut");
    }

    public String getIdprofiltypestatut() {
        return idprofiltypestatut;
    }

    public void setIdprofiltypestatut(String idprofiltypestatut) {
        this.idprofiltypestatut = idprofiltypestatut;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }

    @Override
    public String getTuppleID() {
        return getIdprofiltypestatut();
    }

    @Override
    public String getAttributIDName() {
        return "idprofiltypestatut";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PTS", "getseqprofiltypestatut");
        this.setIdprofiltypestatut(makePK(c));
    }

    
    @Override
    public String toString() {

        return "ProfilTypeStatut{" +
                "idprofiltypestatut='" + idprofiltypestatut + '\'' +
                ", libelle='" + libelle + '\'' +
                ", couleur='" + couleur + '\'' +
                '}';
    }
}
