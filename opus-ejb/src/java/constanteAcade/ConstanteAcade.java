package constanteAcade;

import utilitaire.Constante;

/**
 * Constantes du projet OPUS.
 * Ajouter ici les constantes specifiques au projet.
 */
public class ConstanteAcade {

    // --- Roles ---
    public static String idRoleAdmin = "admin";
    public static String idRoleDg = "dg";
    public static String idRoleSaisie = "saisie";

    // --- Upload ---
    public static final String uploadDirLocation = System.getProperty("jboss.home.dir") + "/welcome-content/upload";
    public static final String uploadedDir = "/upload";
    public static final String fileExtension = ".jpg";

    // --- Mois ---
    private static String mois[] = {"Janvier", "Fevrier", "Mars", "Avril", "Mai", "Juin", "Juillet", "Aout", "Septembre", "Octobre", "Novembre", "Decembre"};
    private static String moisRang[] = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"};

    public static String[] getMois() {
        return mois;
    }

    public static String[] getMoisRang() {
        return moisRang;
    }
}
