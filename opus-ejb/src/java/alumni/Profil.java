package alumni;

import bean.ClassMAPTable;
import bean.CGenUtil;
import java.sql.Connection;
import java.sql.Date;

public class Profil extends ClassMAPTable {

    private String idprofil;
    private String email;
    private String nom;
    private String prenom;
    private java.sql.Date dtn;
    private String telephone;
    private String idpromotion;
    private String idparcours;
    // linked genre (homme / femme etc)
    private String idgenre;
    private Integer idutilisateur;

    public Profil() {
        setNomTable("profil");
    }


    @Override
    public String getTuppleID() {
        return getIdprofil();
    }

    @Override
    public String getAttributIDName() {
        return "idprofil";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PRF", "get_seq_profil");
        this.setIdprofil(makePK(c));
    }

    public String getIdprofil() {
        return idprofil;
    }

    public void setIdprofil(String idprofil) {
        this.idprofil = idprofil;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getPrenom() {
        return prenom;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public Date getDtn() {
        return dtn;
    }

    public void setDtn(Date dtn) {
        this.dtn = dtn;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public String getIdpromotion() {
        return idpromotion;
    }

    public void setIdpromotion(String idpromotion) {
        this.idpromotion = idpromotion;
    }

    public String getIdparcours() {
        return idparcours;
    }

    public void setIdparcours(String idparcours) {
        this.idparcours = idparcours;
    }

    public String getIdgenre() {
        return idgenre;
    }

    public void setIdgenre(String idgenre) {
        this.idgenre = idgenre;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }
}
