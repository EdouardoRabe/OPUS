package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;

public class Publication extends ClassMAPTable {

    private String idpublication;
    private Date daty;
    private String descritpion;
    private int etat;
    private String idorigine;
    private String heure;
    private String idtypepublication;
    private int idutilisateur;
    private String idpuborigine;
    private String logique_visibilite;

    public Publication() {
        setNomTable("publication");
    }

    @Override
    public String getTuppleID() {
        return getIdpublication();
    }

    @Override
    public String getAttributIDName() {
        return "idpublication";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PUB", "get_seq_publication");
        this.setIdpublication(makePK(c));
    }

    public String getIdpublication() {
        return idpublication;
    }

    public void setIdpublication(String idpublication) {
        this.idpublication = idpublication;
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

    public int getEtat() {
        return etat;
    }

    public void setEtat(int etat) {
        this.etat = etat;
    }

    public String getIdorigine() {
        return idorigine;
    }

    public void setIdorigine(String idorigine) {
        this.idorigine = idorigine;
    }

    public String getHeure() {
        return heure;
    }

    public void setHeure(String heure) {
        this.heure = heure;
    }

    public String getIdtypepublication() {
        return idtypepublication;
    }

    public void setIdtypepublication(String idtypepublication) {
        this.idtypepublication = idtypepublication;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public String getIdpuborigine() {
        return idpuborigine;
    }

    public void setIdpuborigine(String idpuborigine) {
        this.idpuborigine = idpuborigine;
    }

    public String getLogique_visibilite() {
        return logique_visibilite;
    }

    public void setLogique_visibilite(String logique_visibilite) {
        this.logique_visibilite = logique_visibilite;
    }
}
