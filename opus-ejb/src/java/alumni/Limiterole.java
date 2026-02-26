package alumni;

import bean.ClassMAPTable;
import bean.CGenUtil;
import java.sql.Connection;


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
        Limiterole[] results = (Limiterole[]) CGenUtil.rechercher(
            new Limiterole(), null, null, conn, " and idrole = '" + idrole + "'");
        if (results != null && results.length > 0) {
            return results[0].getMaxpublicationparjour();
        }
        return -1; // role absent de limiterole = pas de limite
    }

    public static int countPublicationsDuJour(Connection conn, int refuser) throws Exception {
        Publication[] results = (Publication[]) CGenUtil.rechercher(
            new Publication(), null, null, conn,
            " and idutilisateur = " + refuser + " AND daty = CURRENT_DATE AND etat = 1");
        return (results != null) ? results.length : 0;
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
