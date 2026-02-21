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
public class Vuerestriction extends ClassMAPTable{
    private String idrole;
    private String tablename;
    private String ajout;
    private String modif;
    private String suppr;
    private String read;
    private String idaction;
    public Vuerestriction() {
        super.setNomTable("vuerestriction");
    }

    
   

    public String getIdrole() {
        return idrole;
    }

    public void setIdrole(String idrole) {
        this.idrole = idrole;
    }

    public String getTablename() {
        return tablename;
    }

    public void setTablename(String tablename) {
        this.tablename = tablename;
    }

    public String getAjout() {
        return ajout;
    }

    public void setAjout(String ajout) {
        this.ajout = ajout;
    }

    public String getModif() {
        return modif;
    }

    public void setModif(String modif) {
        this.modif = modif;
    }

    public String getSuppr() {
        return suppr;
    }

    public void setSuppr(String suppr) {
        this.suppr = suppr;
    }

    public String getRead() {
        return read;
    }

    public void setRead(String read) {
        this.read = read;
    }
    
    
    @Override
    public String getTuppleID() {
        return this.getIdrole();
    }

    @Override
    public String getAttributIDName() {
        return "idrole";
    }

    public String getIdaction() {
        return idaction;
    }

    public void setIdaction(String idaction) {
        this.idaction = idaction;
    }
    
    
}
