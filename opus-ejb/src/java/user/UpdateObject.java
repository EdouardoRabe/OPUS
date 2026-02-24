/*
 * To change user license header, choose License Headers in Project Properties.
 * To change user template file, choose Tools | Templates
 * and open the template in the editor.
 */
package user;

import bean.CGenUtil;
import bean.ClassEtat;
import bean.ClassMAPTable;
import bean.UnionIntraTable;
import historique.MapUtilisateur;
import historique.ParamCrypt;
import java.sql.Connection;
import utilisateurAcade.UtilisateurAcade;
import utilisateur.Utilisateur;

import constanteAcade.ConstanteEtatAcade;
import utilitaireAcade.UtilitaireAcade;

public class UpdateObject {

	public static Object updateObject(ClassMAPTable o, Connection c, MapUtilisateur u, UserEJBBean user)
			throws Exception {
		try {

			if (o instanceof bean.ClassEtat) {
				ClassEtat filtre = (ClassEtat) o.getClass().newInstance();
				filtre.setNomTable(o.getNomTable());

				ClassEtat[] lo = (ClassEtat[]) CGenUtil.rechercher(filtre, null, null, c,
						" and " + o.getAttributIDName() + "='" + o.getTuppleID() + "'");
				if (lo.length == 0)
					throw new Exception("objet non existante");
				if (lo[0].getEtat() >= ConstanteEtatAcade.getEtatValider())
					throw new Exception("objet deja vise");

				/*
				 * ClassEtat ce=(ClassEtat)o;
				 * if(ce.getEtat()>=ConstanteEtatAcade.getValider())throw new
				 * Exception("Objet deja valide, non modifiable");
				 * o.setValChamp("iduser", u.getTuppleID());
				 */
			}
			if (o instanceof bean.ClassUser) {
				o.setValChamp("iduser", u.getTuppleID());
			}

			o.controlerUpdate(c);
			o.updateToTableWithHisto(u.getTuppleID(), c);
			return o;
		} catch (Exception e) {
			throw e;
		}
	}
}
