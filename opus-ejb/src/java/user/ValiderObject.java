/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package user;

import bean.CGenUtil;
import bean.ClassEtat;
import bean.ClassMAPTable;
import historique.MapUtilisateur;
import java.sql.Connection;
import mg.cnaps.configuration.Configuration;
import constanteAcade.ConstanteEtatAcade;
import utilitaire.UtilDB;

public class ValiderObject {
    
    public static Object validerObject(Connection c,ClassMAPTable o,UserEJBBean user)throws Exception
    {
        return validerObject(c,o,user,user.getUser(),user.getListeConfiguration());
    }
    
    public static Object validerObject(Connection c, ClassMAPTable o, UserEJBBean user, MapUtilisateur u, Configuration[] listeConfig) throws Exception{
        try{
            ClassEtat []lo=null;
            if (o instanceof ClassEtat)
            {
                ClassEtat filtre=(ClassEtat)o.getClass().newInstance();
                System.out.println("NOM TABLE "+o.getNomTable());
                filtre.setNomTable(o.getNomTable());
                
                lo=(ClassEtat [])CGenUtil.rechercher(filtre,null,null,c," and "+o.getAttributIDName()+"='"+o.getTuppleID()+"'");
                if(lo.length==0)throw new Exception("objet non existante");
                if (lo[0].getEtat()>=ConstanteEtatAcade.getEtatValider())throw new Exception("objet deja vise");
                o=lo[0];
              
            }
            o.controleVisa(c);
            if (o instanceof ClassEtat)
            {
                ((ClassEtat) o).validerObject(user.getUser().getTuppleID(), c);
            }
            else
            {
                o.setMode("modif");
                o.controler(c);
                user.updateEtat(o, ConstanteEtatAcade.getEtatValider(), o.getValInsert(o.getAttributIDName()), c);
            }
            

        }
        catch(Exception e){
            if(c!=null)c.rollback();
            throw e;
        }
        return o;
    }
    public static int validerObjetMultiple(ClassEtat mere, ClassEtat fille, String idmere, String nomcolonneidmere, Connection c, UserEJBBean user) throws Exception{
        int verif = 0;
        try{
            if(c == null){
                c = new UtilDB().GetConn();
                verif = 1;
            }
            user.validerObject(mere, c);
            ClassEtat[] filles = (ClassEtat[])CGenUtil.rechercher(fille, null, null, c, " and " + nomcolonneidmere + " = '"+idmere+"'");
            user.validerObjectMultiple(filles, c);
            if(verif == 1) c.commit();
            return 1;
        }catch(Exception e){
            e.printStackTrace();
            c.rollback();
            throw e;
        }finally{
            if(c != null & verif == 1) c.close();
        }
    }
}
