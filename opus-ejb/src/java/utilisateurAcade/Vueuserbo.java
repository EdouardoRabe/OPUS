/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package utilisateurAcade;

import bean.ClassMAPTable;

/**
 *
 * @author user
 */
public class Vueuserbo extends ClassMAPTable{
    
    private String refuser;
    private String nomuser;
    private String loginuser ;
    private String pwduser;
    private String roleuser;
    private String teluser;

    public Vueuserbo() {
        super.setNomTable("vueuserbo");
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

    public String getRoleuser() {
        return roleuser;
    }

    public void setRoleuser(String roleuser) {
        this.roleuser = roleuser;
    }

    
    public String getPwduser() {
        return pwduser;
    }

    public void setPwduser(String pwduser) {
        this.pwduser = pwduser;
    }

    public String getRole() {
        return roleuser;
    }

    public void setRole(String role) {
        this.roleuser = role;
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
        return refuser;
    }

    @Override
    public String getAttributIDName() {
        return "refuser";
    }
    
}
