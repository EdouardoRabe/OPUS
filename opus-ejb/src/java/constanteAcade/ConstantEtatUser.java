package constanteAcade;

import utilitaire.ConstanteEtat;

public class ConstantEtatUser extends ConstanteEtat {
    public static final int etatUtilisateurCreer = 1;
    public static final int etatUtilisateurValider = 11;
    public static final int etatUtilisateurBanis = 0;
    public static final int etatUtilisateurActiver = 100;

    public static String etatToChaine(int etat) {
        switch (etat) {
            case etatUtilisateurCreer:
                return "<span class=\"usr-badge usr-badge-cree\">Créé</span>";
            case etatUtilisateurValider:
                return "<span class=\"usr-badge usr-badge-valide\">Validé</span>";
            case etatUtilisateurBanis:
                return "<span class=\"usr-badge usr-badge-banni\">Banni</span>";
            case etatUtilisateurActiver:
                return "<span class=\"usr-badge usr-badge-actif\">Activé</span>";
            default:
                return "<span class=\"usr-badge\">Inconnu</span>";
        }
    }
}
