package alumni;

public class ExperienceLib extends Experience {

    private String postelib;
    private int    idutilisateur;

    public ExperienceLib() {
        setNomTable("experiencelib");
    }

    /* ── postelib ── */
    public String getPostelib() { return postelib; }
    public void   setPostelib(String postelib) { this.postelib = postelib; }

    /* ── idutilisateur ── */
    public int  getIdutilisateur() { return idutilisateur; }
    public void setIdutilisateur(int idutilisateur) { this.idutilisateur = idutilisateur; }
}
