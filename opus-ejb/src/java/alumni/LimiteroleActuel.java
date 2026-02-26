package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;

/**
 * Bean en lecture seule sur la vue v_limiterole_actuel.
 * Retourne la limite la plus recente par role.
 */
public class LimiteroleActuel extends ClassMAPTable {

    private String idrole;
    private int maxpublicationparjour;
    private Date daty;

    public LimiteroleActuel() {
        setNomTable("v_limiterole_actuel");
    }

    @Override
    public String getTuppleID() {
        return getIdrole();
    }

    @Override
    public String getAttributIDName() {
        return "idrole";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        // Vue en lecture seule, pas de PK a generer
    }

    public String getIdrole() {
        return idrole;
    }

    public void setIdrole(String idrole) {
        this.idrole = idrole;
    }

    public int getMaxpublicationparjour() {
        return maxpublicationparjour;
    }

    public void setMaxpublicationparjour(int maxpublicationparjour) {
        this.maxpublicationparjour = maxpublicationparjour;
    }

    public Date getDaty() {
        return daty;
    }

    public void setDaty(Date daty) {
        this.daty = daty;
    }
}
