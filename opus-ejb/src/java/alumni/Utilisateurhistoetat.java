package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Utilisateurhistoetat extends ClassMAPTable {

    private String idutilisateurhistoetat;
    private String daty;
    private int etat;
    private String remarque;
    private String idutilisateur;

    public Utilisateurhistoetat() {
        setNomTable("utilisateurhistoetat");
    }

    @Override
    public String getTuppleID() {
        return getIdutilisateurhistoetat();
    }

    @Override
    public String getAttributIDName() {
        return "idutilisateurhistoetat";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("UHE", "get_seq_utilisateurhistoetat");
        this.setIdutilisateurhistoetat(makePK(c));
    }

    public String getIdutilisateurhistoetat() {
        return idutilisateurhistoetat;
    }

    public void setIdutilisateurhistoetat(String idutilisateurhistoetat) {
        this.idutilisateurhistoetat = idutilisateurhistoetat;
    }

    public String getDaty() {
        return daty;
    }

    public void setDaty(String daty) {
        this.daty = daty;
    }

    public int getEtat() {
        return etat;
    }

    public void setEtat(int etat) {
        this.etat = etat;
    }

    public String getRemarque() {
        return remarque;
    }

    public void setRemarque(String remarque) {
        this.remarque = remarque;
    }

    public String getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(String idutilisateur) {
        this.idutilisateur = idutilisateur;
    }
}
