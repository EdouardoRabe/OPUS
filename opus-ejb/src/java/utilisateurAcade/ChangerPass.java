/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package utilisateurAcade;

import bean.ClassMAPTable;

/**
 *
 * @author laichristophe
 */
public class ChangerPass extends ClassMAPTable {

    private String iduser;
    private String password;
    private String confirmerpwd;
    private String adminpwd;

    public String getIduser() {
        return iduser;
    }

    public void setIduser(String iduser) {
        this.iduser = iduser;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getConfirmerpwd() {
        return confirmerpwd;
    }

    public void setConfirmerpwd(String confirmerpwd) {
        this.confirmerpwd = confirmerpwd;
    }

    public String getAdminpwd() {
        return adminpwd;
    }

    public void setAdminpwd(String adminpwd) {
        this.adminpwd = adminpwd;
    }

    @Override
    public String getTuppleID() {
        return this.getIduser();
    }

    @Override
    public String getAttributIDName() {
        return "iduser";
    }

}
