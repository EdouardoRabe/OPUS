package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Signalementpublication extends ClassMAPTable {

    private String idsignalementpublication;
    private String daty;
    private String descritpion;
    private String typesignalement;
    private String idpublication;
    private String idutilisateur;

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

    public String getDaty() {
        return daty;
    }

    public void setDaty(String daty) {
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

    public String getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(String idutilisateur) {
        this.idutilisateur = idutilisateur;
    }
}
