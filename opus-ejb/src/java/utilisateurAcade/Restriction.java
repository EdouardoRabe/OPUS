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
 * @author Jetta
 */
public class Restriction extends ClassMAPTable {

    private String id;
    private String idrole;
    private String idaction;
    private String tablename;
    private String autorisation;
    private String description;
    private String iddirection;

    public Restriction(String idrole, String idaction, String tablename, String autorisation, String description, String iddirection) {
        this.setIdrole(idrole);
        this.setIdaction(idaction);
        this.setTablename(tablename);
        this.setAutorisation("false");
        this.setDescription(description);
        this.setIddirection(iddirection);
        super.setNomTable("restriction");
    }

    public String getIddirection() {
        return iddirection;
    }

    public void setIddirection(String iddirection) {
        this.iddirection = iddirection;
    }

    public Restriction(String idrole, String idpermission, String nt) {
        super.setNomTable("restriction");
        this.setIdrole(idrole);
        this.setIdaction(idpermission);
        this.setTablename(nt);
        this.setAutorisation("false");
        this.setDescription("");
    }

    public Restriction(String idrole, String action, String nt, String direction) {
        super.setNomTable("restriction");
        this.setIdrole(idrole);
        this.setIdaction(action);
        this.setTablename(nt);
        this.setAutorisation("non");
           this.setIddirection(direction);
    }

    public Restriction() {
        super.setNomTable("restriction");
    }

    @Override
    public String getTuppleID() {
        return id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        super.setNomTable("restriction");
        this.preparePk("RES", "getSeqRestriction");
        this.setId(makePK(c));
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getIdrole() {
        return idrole;
    }

    public void setIdrole(String idrole) {
        this.idrole = idrole;
    }

    public String getIdaction() {
        return idaction;
    }

    public void setIdaction(String idaction) {
        this.idaction = idaction;
    }

    public String getTablename() {
        return tablename;
    }

    public void setTablename(String idelement) {
        this.tablename = idelement;
    }

    public String getAutorisation() {
        return autorisation;
    }

    public void setAutorisation(String autorisation) {
        this.autorisation = autorisation;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
