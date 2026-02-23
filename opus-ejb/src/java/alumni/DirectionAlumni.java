package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class DirectionAlumni extends ClassMAPTable {
    private String id;
    private String val;
    private String desce;

    public DirectionAlumni() {
        setNomTable("direction");
    }

    public DirectionAlumni(String id, String val, String desce) {
        setNomTable("direction");
        this.id = id;
        this.val = val;
        this.desce = desce;
    }

    @Override
    public String getTuppleID() {
        return getId();
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("DIR", "getSeqDirection");
        this.setId(makePK(c));
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getVal() {
        return val;
    }

    public void setVal(String val) {
        this.val = val;
    }

    public String getDesce() {
        return desce;
    }

    public void setDesce(String desce) {
        this.desce = desce;
    }
}
