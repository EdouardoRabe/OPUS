/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package utilisateurAcade;

import java.sql.Connection;
import java.sql.Date;

/**
 *
 * @author Murielle
 */
public class Personnel extends Personne{
    public String id, nom, prenom, sexe;
    public Date datenaissance;
    
    public Personnel() {
        super.setNomTable("personnel");
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
        this.preparePk("PERSL", "get_seq_personnel");
        this.setId(makePK(c));
    }
}
