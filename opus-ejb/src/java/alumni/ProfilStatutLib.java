package alumni;

public class ProfilStatutLib extends ProfilStatut{
    
    private String libelle;
    private String couleur;

    public ProfilStatutLib() {
        setNomTable("v_profilstatut_latest");
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }

    public String getCouleur() {
        return couleur;
    }

    public void setCouleur(String couleur) {
        this.couleur = couleur;
    }
}
