package alumni;

import bean.ClassMAPTable;
import java.sql.Connection;

public class ReseauSocial extends ClassMAPTable {

    private String idreseausocial;
    private String libelle;
    private String urlPattern;
    private String iconeClass;
    private String couleurHex;
    private int priorite;
    private int actif;

    public int getActif() {
        return actif;
    }

    public ReseauSocial() {
        setNomTable("reseauxsociaux");
    }

    public ReseauSocial(String idReseauSocial, String libelle) {
        setNomTable("reseauxsociaux");
        this.idreseausocial = idReseauSocial;
        this.libelle = libelle;
    }

    @Override
    public String getTuppleID() {
        return getIdReseauSocial();
    }

    @Override
    public String getAttributIDName() {
        return "idreseausocial";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        // Les IDs de réseaux sociaux sont prédéfinis (github, linkedin, etc)
        // Pas besoin de générer une clé auto-incrémentielle
    }

    // Getters & Setters
    public String getIdReseauSocial() {
        return idreseausocial;
    }

    public void setIdReseauSocial(String idReseauSocial) {
        this.idreseausocial = idReseauSocial;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }

    public String getUrlPattern() {
        return urlPattern;
    }

    public void setUrlPattern(String urlPattern) {
        this.urlPattern = urlPattern;
    }

    public String getIconeClass() {
        return iconeClass;
    }

    public void setIconeClass(String iconeClass) {
        this.iconeClass = iconeClass;
    }

    public String getCouleurHex() {
        return couleurHex;
    }

    public void setCouleurHex(String couleurHex) {
        this.couleurHex = couleurHex;
    }

    public int getPriorite() {
        return priorite;
    }

    public void setPriorite(int priorite) {
        this.priorite = priorite;
    }

    public boolean isActif() {
        return actif == 1;
    }

    public void setActif(int actif) {
    this.actif = actif;

    }

    // Générer l'URL complète
    public String generateUrl(String value) {
        if (urlPattern == null || value == null || value.trim().isEmpty())
            return "";
        return urlPattern.replace("{value}", value);
    }

    @Override
    public String toString() {
        return "ReseauSocial{" +
                "idReseauSocial='" + idreseausocial + '\'' +
                ", libelle='" + libelle + '\'' +
                '}';
    }
}
