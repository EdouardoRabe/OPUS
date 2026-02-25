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
    private int idutilisateur;

    public Profil() {
        setNomTable("profil");
    }

    public ProfilStatutLib getProfilStatut() throws Exception {
        ProfilStatutLib result = null;
        Connection c = null;
        try {
            c = new utilitaire.UtilDB().GetConn();
            ProfilStatutLib filtre = new ProfilStatutLib();
            filtre.setIdprofil(this.idprofil);
            Object[] res = CGenUtil.rechercher(filtre, null, null, c, "");
            if (res != null && res.length > 0) {
                result = (ProfilStatutLib) res[0];
            }
        } catch (Exception e) {
            throw e;
        } finally {
            if (c != null) {
                try {
                    c.close();
                } catch (Exception e) {
                    throw e;
                }
            }
        }
        return result;
    }

    public int getContribution() throws Exception {
        int count = 0;
        Connection c = null;
        try {
            c = new utilitaire.UtilDB().GetConn();
            Publication filtre = new Publication();
            // System.out.println("ID utilisateur pour contribution: " +
            // this.idutilisateur);
            // filtre.setIdutilisateur(this.idutilisateur);
            filtre.setIdtypepublication("TPB000004");
            Object[] res = CGenUtil.rechercher(filtre, null, null, c, " and idutilisateur = " + this.idutilisateur);
            if (res != null) {
                count = res.length;
            }
        } catch (Exception e) {
            throw e;
        } finally {
            if (c != null) {
                try {
                    c.close();
                } catch (Exception e) {
                    throw e;
                }
            }
        }
        return count;
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

    public static Profil findByRefUser(int refuser, Connection c) throws Exception {
        Profil filtre = new Profil();
        Profil[] res = (Profil[]) CGenUtil.rechercher(
                filtre, null, null, c, " and idutilisateur=" + refuser);
        return (res != null && res.length > 0) ? res[0] : null;
    }
}
