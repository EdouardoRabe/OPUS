package alumni;

import bean.ClassMAPTable;
import bean.CGenUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;


public class Limiterole extends ClassMAPTable {

    private String idrole;
    private int maxpublicationparjour;

    public Limiterole() {
        setNomTable("limiterole");
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
        // Pas de sequence, idrole est la PK directe
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

  
    public static int getMaxParJour(Connection conn, String idrole) throws Exception {
        int max = -1;
        PreparedStatement ps = conn.prepareStatement(
            "SELECT maxpublicationparjour FROM limiterole WHERE idrole = ?");
        ps.setString(1, idrole);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            max = rs.getInt(1);
        }
        rs.close();
        ps.close();
        return max;
    }

    public static int countPublicationsDuJour(Connection conn, int refuser) throws Exception {
        int count = 0;
        PreparedStatement ps = conn.prepareStatement(
            "SELECT COUNT(*) FROM publication WHERE idutilisateur = ? AND daty = CURRENT_DATE AND etat = 1");
        ps.setInt(1, refuser);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            count = rs.getInt(1);
        }
        rs.close();
        ps.close();
        return count;
    }

    public static String verifierDroitPublication(Connection conn, String idrole, int refuser) throws Exception {
        int max = getMaxParJour(conn, idrole);

        if (max == 0) {
            return "Votre role ne vous permet pas de publier.";
        }

        if (max > 0) {
            int pubAujourdHui = countPublicationsDuJour(conn, refuser);
            if (pubAujourdHui >= max) {
                return "Vous avez atteint la limite de " + max + " publication(s) par jour.";
            }
        }

        return null;
    }

    
    public static boolean peutPublier(Connection conn, String idrole) throws Exception {
        int max = getMaxParJour(conn, idrole);
        return max != 0;
    }

   
    public static int publicationsRestantes(Connection conn, String idrole, int refuser) throws Exception {
        int max = getMaxParJour(conn, idrole);
        if (max < 0) return -1; 
        if (max == 0) return 0;  
        int count = countPublicationsDuJour(conn, refuser);
        return Math.max(0, max - count);
    }
}
