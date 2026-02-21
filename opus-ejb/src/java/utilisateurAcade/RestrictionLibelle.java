/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package utilisateurAcade;

import bean.ClassMAPTable;

/**
 *
 * @author Jetta
 */
public class RestrictionLibelle extends ClassMAPTable {

    private String idrole;
    private String tablename;
    private String ajout;
    private String modif;
    private String suppr;
    private String read;
    private String idaction;
    private String iddirection;

    public RestrictionLibelle(String idrole, String tablename, String ajout, String modif, String suppr, String read, String idaction, String iddirection) {
        this.setIdrole(idrole);
        this.setTablename(tablename);
        this.setAjout(ajout);
        this.setModif(modif);
        this.setSuppr(suppr);
        this.setRead(read);
        this.setIdaction(idaction);
        this.setIddirection(iddirection);
        super.setNomTable("RESTRICTION_LIBELLE");
    }

    public String getIddirection() {
        return iddirection;
    }

    public void setIddirection(String iddirection) {
        this.iddirection = iddirection;
    }

    public RestrictionLibelle() {
        super.setNomTable("RESTRICTION_LIBELLE");
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
