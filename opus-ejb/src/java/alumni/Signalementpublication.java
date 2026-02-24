package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;

public class Signalementpublication extends ClassMAPTable {

    private String idsignalementpublication;
    private Date daty;
    private String descritpion;
    private String typesignalement;
    private String idpublication;
    private int idutilisateur;
    private String heure;

    public Signalementpublication() {
        setNomTable("signalementpublication");
    }

    @Override
    public String getTuppleID() {
        return getIdsignalementpublication();
    }

    @Override
    public String getAttributIDName() {
        return "idsignalementpublication";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("SGP", "get_seq_signalementpublication");
        this.setIdsignalementpublication(makePK(c));
    }

    public String getIdsignalementpublication() {
        return idsignalementpublication;
    }

    public void setIdsignalementpublication(String idsignalementpublication) {
        this.idsignalementpublication = idsignalementpublication;
    }

    public Date getDaty() {
        return daty;
    }

    public void setDaty(Date daty) {
        this.daty = daty;
    }

    public String getDescritpion() {
        return descritpion;
    }

    public void setDescritpion(String descritpion) {
        this.descritpion = descritpion;
    }

    public String getTypesignalement() {
        return typesignalement;
    }

    public void setTypesignalement(String typesignalement) {
        this.typesignalement = typesignalement;
    }

    public String getIdpublication() {
        return idpublication;
    }

    public void setIdpublication(String idpublication) {
        this.idpublication = idpublication;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(String idutilisateur) throws Exception{
        if(idutilisateur != null){
            try {
                this.idutilisateur = Integer.parseInt(idutilisateur);
            } catch (Exception e) {
                throw new Exception("Erreur lors du parse de l'idutilisateur" + e.getMessage());
            }
        }
    }
    
    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public void setHeure(String heure) {
        this.heure = heure;
    }

    public String getHeure() {
        return heure;
    }
}
