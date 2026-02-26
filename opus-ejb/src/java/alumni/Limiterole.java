package alumni;

import bean.ClassMAPTable;
import bean.CGenUtil;
import java.sql.Connection;
import java.sql.Date;


public class Limiterole extends ClassMAPTable {

    private String idlimiterole;
    private String idrole;
    private int maxpublicationparjour;
    private Date daty;

    public Limiterole() {
        setNomTable("limiterole");
    }

    @Override
    public String getTuppleID() {
        return getIdlimiterole();
    }

    @Override
    public String getAttributIDName() {
        return "idlimiterole";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("LMR", "get_seq_limiterole");
        this.setIdlimiterole(makePK(c));
    }

    // --- Getters / Setters ---

    public String getIdlimiterole() {
        return idlimiterole;
    }

    public void setIdlimiterole(String idlimiterole) {
        this.idlimiterole = idlimiterole;
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

    // --- Methodes utilitaires (APJ) ---

    /**
     * Retourne la limite actuelle pour un role (via la vue v_limiterole_actuel).
     * @return -1 si le role n'a pas de limite (absent de la table), 0 si interdit, >0 si limite
     */
    public static int getMaxParJour(Connection conn, String idrole) throws Exception {
        LimiteroleActuel[] results = (LimiteroleActuel[]) CGenUtil.rechercher(
            new LimiteroleActuel(), null, null, conn, " and idrole = '" + idrole + "'");
        if (results != null && results.length > 0) {
            return results[0].getMaxpublicationparjour();
        }
        return -1; // role absent = pas de limite
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
