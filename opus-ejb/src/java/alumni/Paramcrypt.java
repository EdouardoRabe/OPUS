package alumni;

import bean.ClassMAPTable;

/**
 * Modele APJ pour la table paramcrypt (parametres de cryptage par utilisateur).
 * Utilisee principalement en lecture pour le changement de mot de passe.
 */
public class Paramcrypt extends ClassMAPTable {

    private String id;
    private int niveau;
    private int croissante;
    private String idutilisateur;

    public Paramcrypt() {
        setNomTable("paramcrypt");
    }

    @Override
    public String getTuppleID() {
        return getId();
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public int getNiveau() {
        return niveau;
    }

    public void setNiveau(int niveau) {
        this.niveau = niveau;
    }

    public int getCroissante() {
        return croissante;
    }

    public void setCroissante(int croissante) {
        this.croissante = croissante;
    }

    public String getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(String idutilisateur) {
        this.idutilisateur = idutilisateur;
    }
}
