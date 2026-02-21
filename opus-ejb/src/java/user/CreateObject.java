/*
 * To change user license header, choose License Headers in Project Properties.
 * To change user template file, choose Tools | Templates
 * and open the template in the editor.
 */
package user;

import bean.ClassMAPTable;
import historique.MapUtilisateur;
import java.sql.Connection;

import constanteAcade.ConstanteAcade;
import constanteAcade.ConstanteEtatAcade;
import utilitaire.ConstanteUser;
import bean.AdminGen;
import bean.CGenUtil;
import bean.ClassEtat;
import bean.ClassMAPTable;
import bean.ClassUser;
import bean.ErreurDAO;
import bean.ListeColonneTable;
import bean.RejetTable;
import bean.ResultatEtSomme;
import bean.TypeObjet;
import bean.TypeObjetUtil;
import bean.UnionIntraTable;
import bean.UploadPj;
import config.Config;
import config.Table;
import historique.HistoriqueEJBClient;
import historique.HistoriqueLocal;
import historique.MapHistorique;
import historique.MapRoles;
import historique.MapUtilisateur;
import historique.UtilisateurUtil;
import java.sql.Array;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ejb.CreateException;
import javax.ejb.SessionBean;
import javax.ejb.SessionContext;
import javax.ejb.Stateful;
import lc.Direction;
import lc.DirectionUtil;
import mg.cnaps.configuration.Configuration;
import utilisateur.ConstanteUtilisateur;
import utilisateur.HomePageURL;
import utilisateur.UtilisateurRole;
import constanteAcade.ConstanteAcade;
import constanteAcade.ConstanteEtatAcade;
import utilitaire.ConstanteUser;
import utilitaire.UtilDB;
import utilitaireAcade.UtilitaireAcade;
import utilitaire.UtilitaireFormule;
import utilitaire.UtilitaireMetier;

public class CreateObject {
    
    public static Object createObject(ClassMAPTable o, Connection c, UserEJBBean u)throws Exception
    {
        return createObject(o,c,u.getUser(),u, u.getListeConfiguration());
    }
          
    public static Object createObject(ClassMAPTable o, Connection c, MapUtilisateur u, UserEJBBean user, Configuration[] listeConfig) throws Exception {
	try {
	    o.setMode("modif");
        System.out.println("------------"+o.getClassName());
	    if (o instanceof bean.ClassEtat) {
        //o.setValChamp("etat", Integer.valueOf(1));
		o.setValChamp("iduser", u.getTuppleID());
	    }
	    if (o instanceof bean.ClassUser) {
		o.setValChamp("iduser", u.getTuppleID());
	    } 
	    return o.createObject(u.getTuppleID(), c);
	} catch (Exception e) {
            e.printStackTrace();
	    throw e;
	}
    }
}
