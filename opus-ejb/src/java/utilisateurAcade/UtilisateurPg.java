/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package utilisateurAcade;

import bean.ClassMAPTable;
import java.sql.Connection;
/**
 *
 * @author user
 */
public class UtilisateurPg extends ClassMAPTable{

    private int refuser;
    private String loginuser ;
    private String pwduser;
    private String idrole;
    private String nomuser;
    private String teluser;
    private String adruser;
    private String acronyme;

    private String profile;

    private String matricule;

    public String getProfile() {
        return profile;
    }

    public void setProfile(String profile) {
        this.profile = profile;
    }

    public String getMatricule() {
        return matricule;
    }

    public void setMatricule(String matricule) {
        this.matricule = matricule;
    }

    public UtilisateurPg() {
        super.setNomTable("utilisateur");
    }

    public UtilisateurPg(String loginuser, String pwduser, String idrole, String nomuser, String teluser) {
        this.setLoginuser(loginuser);
        this.setPwduser(pwduser);
        this.setIdrole(idrole);
        this.setNomuser(nomuser);
        this.setTeluser(teluser);
    }

    public int getRefuser() {
        return refuser;
    }

    public void setRefuser(int refuser) {
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
    public String getIdrole() {
        return idrole;
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
        public String getAdruser() {
        return adruser;
    }

    public void setAdruser(String adruser) {
        this.adruser = adruser;
    }

    
    @Override
    public String getTuppleID() {
        return String.valueOf(this.refuser);
    }

    @Override
    public String getAttributIDName() {
        return "refuser"  ; 
    }
    public String getAttribuLoguser(){
        return "loginuser";
    }
    public String getAttribumdp(){
        return "pwduser";
    }
    public void construirePK(Connection c) throws Exception {
        super.setNomTable("utilisateur");
        this.preparePk("", "getSeqUtilisateur");
        this.setRefuser(Integer.valueOf(makePK(c)));
    }

    public String getAcronyme() {
        return acronyme;
    }

    public void setAcronyme(String acronyme) {
        this.acronyme = acronyme;
    }
}
