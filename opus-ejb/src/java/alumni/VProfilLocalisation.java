package alumni;

public class VProfilLocalisation extends ProfilLib {
    private double longitude;
    private double latitude;
    private String idemplacement;

    public VProfilLocalisation() {
        setNomTable("v_profil_localisation");
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public String getIdemplacement() {
        return idemplacement;
    }

    public void setIdemplacement(String idemplacement) {
        this.idemplacement = idemplacement;
    }
}
