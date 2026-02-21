/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package utilisateurAcade;

import bean.CGenUtil;
import bean.ClassMAPTable;
import user.HistoriqueActifLib;
import utilisateur.Role;
import utilisateur.Utilisateur;
import utilitaire.UtilDB;
import utilitaire.Utilitaire;

import java.sql.Connection;
/**
 *
 * @author user
 */
public class UtilisateurAcade extends Utilisateur{

    private String refuser;
    private String loginuser ;
    private String pwduser;
    private String idrole;
    private String nomuser;
    private String teluser;
    private String adruser;
    private int estActif;
    private String id;

    
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public UtilisateurAcade() {
        super.setNomTable("Utilisateur");
    }
    
    public UtilisateurAcade(String loginuser, String pwduser, String idrole, String nomuser, String teluser) {
        this.setLoginuser(loginuser);
        this.setPwduser(pwduser);
        this.setIdrole(idrole);
        this.setNomuser(nomuser);
        this.setTeluser(teluser);
    }
    
    public String getAdruser() {
        return adruser;
    }
    
    public void setAdruser(String adruser) {
        this.adruser = adruser;
    }
    
    public String getRefuser() {
        return refuser;
    }

    public void setRefuser(String refuser) {
        this.refuser = refuser;
    }
    
    public String getLoginuser() {
        return loginuser;
    }
    
    public void setLoginuser(String loginuser) {
        this.loginuser = loginuser;
    }

    public String getPwduser() {
        return pwduser;
    }
    
    public void setPwduser(String pwduser) {
        this.pwduser = pwduser;
    }

    public int getEstActif() {
        return estActif;
    }

    public void setEstActif(int estActif) {
        this.estActif = estActif;
    }

    public String getIdRole() {
        return idrole;
    }

    public void setIdrole(String idrole) {
        this.idrole = idrole;
    }

    public String getNomuser() {
        return nomuser;
    }

    public void setNomuser(String nomuser) {
        this.nomuser = nomuser;
    }

    public String getTeluser() {
        return teluser;
    }

    public void setTeluser(String teluser) {
        this.teluser = teluser;
    }
    
    @Override
    public String getTuppleID() {
        return id;
    }

    @Override
    public String getAttributIDName() {
        return "id"; 
    }
    public void construirePK(Connection c) throws Exception {
        if (c == null) {
            c = new UtilDB().GetConn();
        }
        super.setNomTable("Utilisateur");
        this.preparePk("USER", "getSeqUtilisateur");
        this.setRefuser(makePK(c));
    }
    
    
    
     public static void isDg (String u,Connection c) throws Exception{
    
        UtilisateurAcade user = new UtilisateurAcade();                                  
        UtilisateurAcade[] luser = (UtilisateurAcade[]) CGenUtil.rechercher(user, null, null, c, String.format(" and refuser = %s", u));
        if(luser.length==0){
            throw new Exception("Connectez-vous d abord");
        }
        user = luser[0];
        Role role = new Role();
        role.setIdrole(user.getIdRole());
        Role[] lrole = (Role[]) CGenUtil.rechercher(role, null, null, c, " and rang > 3");
        if(lrole.length==0){
           throw new Exception("Vous n etes pas autorise a valide"); 
        }
    }

    public void changerActif(String u,Connection c) throws Exception{
        boolean canClose=false;
        try {
            if (c == null) {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            canClose=true;
            }
            if(this.getEstActif() == 1){
                this.setEstActif(0);
            } else {
                this.setEstActif(1);
            }
            genererHistoriqueActif().createObject(u,c);
            String req="update utilisateur set estActif="+getEstActif()+" where id='"+getId()+"'";
            this.updateToTableDirecte(req, c);
            if (canClose) {
                c.commit();
            }
        } catch (Exception e) {
            c.rollback();
            e.printStackTrace();
            throw e;
        }
        finally{
            if (canClose) {
                c.close();
            }
        }
    }

    public static UtilisateurAcade[] findUsersActif(Connection c) throws Exception {
        UtilisateurAcade a = new UtilisateurAcade();
        a.setEstActif(1);
        return (UtilisateurAcade[]) CGenUtil.rechercher(a, null, null, c, "");
    }

    public HistoriqueActifLib genererHistoriqueActif() throws Exception{
        HistoriqueActifLib historiqueActifLib = new HistoriqueActifLib();
        historiqueActifLib.setNomTable("historiqueActif");
        historiqueActifLib.setEstactif (this.getEstActif());
        historiqueActifLib.setDaty (Utilitaire.dateDuJourSql());
        historiqueActifLib.setIdutilisateur(this.getId());

        return historiqueActifLib;
    }

    public String[] getMotCles() { return new String[]{"id","nomuser"};}

}
