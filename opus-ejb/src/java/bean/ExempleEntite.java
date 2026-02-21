package bean;

import bean.ClassMAPTable;
import java.sql.Connection;

/**
 * Exemple d'entite APJ pour le projet OPUS.
 * 
 * Pour creer une nouvelle entite :
 * 1. Creer une classe qui etend ClassMAPTable (ou ClassEtat pour le workflow)
 * 2. Definir les champs correspondant aux colonnes de la table
 * 3. Implementer le constructeur avec setNomTable()
 * 4. Implementer getTuppleID() et getAttributIDName()
 * 5. Implementer construirePK() avec le prefixe et la sequence
 * 
 * Exemple d'utilisation dans un JSP :
 *   ExempleEntite e = new ExempleEntite();
 *   PageInsert pi = new PageInsert(e, request, userEJB);
 *   // configurer le formulaire...
 *   pi.preparerDataFormu();
 *   out.println(pi.getFormu().getHtmlInsert());
 */
public class ExempleEntite extends ClassMAPTable {

    private String id;
    private String libelle;
    private String description;
    private String daty;

    public ExempleEntite() {
        setNomTable("EXEMPLE_ENTITE");
    }

    @Override
    public String getTuppleID() {
        return getId();
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("EXM", "GETSEQUEXEMPLE");
        this.setId(makePK(c));
    }

    // --- Getters et Setters ---
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getDaty() { return daty; }
    public void setDaty(String daty) { this.daty = daty; }
}
