package alumni;

public class ProfilLib extends Profil {

    private String promotionLib;
    private int    promotionAnnee;
    private String parcoursLib;
    private String photoProfil;
    private String photoCouverture;
    private int estactif;
    private String profile;
    private String idrole;
    private int refuser;

    public ProfilLib() {
        setNomTable("profillib");
    }

    /* ── promotion_lib ── */
    public String getPromotionLib() {
        return promotionLib;
    }

    public void setPromotionLib(String promotionLib) {
        this.promotionLib = promotionLib;
    }

    /* ── promotion_annee ── */
    public int getPromotionAnnee() {
        return promotionAnnee;
    }

    public void setPromotionAnnee(int promotionAnnee) {
        this.promotionAnnee = promotionAnnee;
    }

    /* ── parcours_lib ── */
    public String getParcoursLib() {
        return parcoursLib;
    }

    public void setParcoursLib(String parcoursLib) {
        this.parcoursLib = parcoursLib;
    }

    /* ── photo_profil ── */
    public String getPhotoProfil() {
        return photoProfil;
    }

    public void setPhotoProfil(String photoProfil) {
        this.photoProfil = photoProfil;
    }

    /* ── photo_couverture ── */
    public String getPhotoCouverture() {
        return photoCouverture;
    }

    public void setPhotoCouverture(String photoCouverture) {
        this.photoCouverture = photoCouverture;
    }

    /* ── estactif ── */
    public int getEstactif() {
        return estactif;
    }

    public void setEstactif(int estactif) {
        this.estactif = estactif;
    }

    /* ── profile ── */
    public String getProfile() {
        return profile;
    }

    public void setProfile(String profile) {
        this.profile = profile;
    }

    /* ── idrole ── */
    public String getIdrole() {
        return idrole;
    }

    public void setIdrole(String idrole) {
        this.idrole = idrole;
    }

    /* ── refuser ── */
    public int getRefuser() {
        return refuser;
    }

    public void setRefuser(int refuser) {
        this.refuser = refuser;
    }
}
