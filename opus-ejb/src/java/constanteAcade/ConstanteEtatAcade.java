package constanteAcade;

import utilitaire.ConstanteEtat;
import utilitaireAcade.UtilitaireAcade;

/**
 * Constantes d'etat du workflow APJ pour le projet OPUS.
 * Etend les constantes de base du framework (ConstanteEtat).
 */
public class ConstanteEtatAcade extends ConstanteEtat {

    // --- Etats de base du workflow ---
    private static final int etatAnnuler = 0;
    private static final int etatCreer = 1;
    private static final int etatEnAttente = 7;
    private static final int etatCloture = 9;
    private static final int etatFait = 10;
    private static final int etatValider = 11;
    private static final int etatLivraison = 20;
    private static final int etatEncoursPayement = 30;
    private static final int etatPaye = 40;
    public static final int constanteEtatFinaliser = 4;

    // --- Getters ---
    public static int getEtatCreer() {
        return etatCreer;
    }

    public static int getEtatAnnuler() {
        return etatAnnuler;
    }

    public static int getEtatEnAttente() {
        return etatEnAttente;
    }

    public static int getEtatCloture() {
        return etatCloture;
    }

    public static int getEtatFait() {
        return etatFait;
    }

    public static int getEtatValider() {
        return etatValider;
    }

    public static int getEtatLivraison() {
        return etatLivraison;
    }

    public static int getEtatEncoursPayement() {
        return etatEncoursPayement;
    }

    public static int getEtatPaye() {
        return etatPaye;
    }

    public static int getConstanteEtatFinaliser() {
        return constanteEtatFinaliser;
    }

    // --- Conversion etat <-> chaine ---
    public static String etatToChaine(String valeur) {
        int val = UtilitaireAcade.stringToInt(valeur);
        if (val == getEtatCreer()) return "<b style='color:lightskyblue'>CR&Eacute;&Eacute;(E)</b>";
        if (val == getEtatValider()) return "<b style='color:green'>VIS&Eacute;(E)</b>";
        if (val == getEtatAnnuler()) return "<b style='color:orange'>ANNUL&Eacute;(E)</b>";
        if (val == getEtatCloture()) return "<b style='color:orange'>CLOTUR&Eacute;(E)</b>";
        if (val == getEtatFait()) return "<b style='color:green'>FAIT</b>";
        if (val == getEtatPaye()) return "<b style='color:green'>PAY&Eacute;</b>";
        return "<b>AUTRE</b>";
    }

    public static int chaineToEtat(String chaine) {
        if (chaine.compareToIgnoreCase("cree") == 0) return getEtatCreer();
        if (chaine.compareToIgnoreCase("valide") == 0) return getEtatValider();
        if (chaine.compareToIgnoreCase("cloture") == 0) return getEtatCloture();
        int val = UtilitaireAcade.stringToInt(chaine);
        if (val > 0) return val;
        return 0;
    }
}
