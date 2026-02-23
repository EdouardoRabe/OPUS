package alumni;

public class SpecialiteCpl extends Specialite {

    private String photohtml;

    public SpecialiteCpl() {
        setNomTable("specialitecpl");
    }

    public String getPhotohtml() {
        return photohtml;
    }

    public void setPhotohtml(String photohtml) {
        this.photohtml = photohtml;
    }
}
