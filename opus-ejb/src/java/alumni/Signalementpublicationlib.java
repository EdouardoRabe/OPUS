package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Signalementpublicationlib extends ClassMAPTable {

    private String idsignalement;
    private String idpublication;
    private String idsignalant;
    private String nomsignalant;
    private String idsignale;
    private String nomsignale;
    private String typesignalement;
    private String daty;
    private String heure;
    private String motifdesc;
    private String motiflibelle;

    public Signalementpublicationlib() {
        setNomTable("signalementpublicationlib");
    }

    @Override
    public String getTuppleID() {
        return getIdsignalement();
    }

    @Override
    public String getAttributIDName() {
        return "idsignalement";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        // view, pas de PK à construire
    }

    public String getIdsignalement() { return idsignalement; }
    public void setIdsignalement(String idsignalement) { this.idsignalement = idsignalement; }

    public String getIdpublication() { return idpublication; }
    public void setIdpublication(String idpublication) { this.idpublication = idpublication; }

    public String getIdsignalant() { return idsignalant; }
    public void setIdsignalant(String idsignalant) { this.idsignalant = idsignalant; }

    public String getNomsignalant() { return nomsignalant; }
    public void setNomsignalant(String nomsignalant) { this.nomsignalant = nomsignalant; }

    public String getIdsignale() { return idsignale; }
    public void setIdsignale(String idsignale) { this.idsignale = idsignale; }

    public String getNomsignale() { return nomsignale; }
    public void setNomsignale(String nomsignale) { this.nomsignale = nomsignale; }

    public String getTypesignalement() { return typesignalement; }
    public void setTypesignalement(String typesignalement) { this.typesignalement = typesignalement; }

    public String getDaty() { return daty; }
    public void setDaty(String daty) { this.daty = daty; }

    public String getHeure() { return heure; }
    public void setHeure(String heure) { this.heure = heure; }

    public String getMotifdesc() { return motifdesc; }
    public void setMotifdesc(String motifdesc) { this.motifdesc = motifdesc; }

    public String getMotiflibelle() { return motiflibelle; }
    public void setMotiflibelle(String motiflibelle) { this.motiflibelle = motiflibelle; }
}
