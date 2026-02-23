package user;
 
import bean.ClassEtat;
import bean.ClassMAPTable;
import bean.ResultatEtSomme;
import bean.TypeObjet;
import historique.MapRoles;
import historique.MapUtilisateur;
import java.sql.Connection;
import java.sql.Date;
import java.util.*;
import javax.ejb.Local;
import lc.Direction;
import mg.cnaps.utilisateur.CNAPSUser;

@Local
public interface UserEJB {

    public CNAPSUser getCnapsUser();
    public Object[] getData(ClassMAPTable e, String req, Connection c) throws Exception;

    public void createObjectFilleMultipleSansMere(ClassMAPTable[] fille) throws Exception;
    
    public ResultatEtSomme getDataPageMax(ClassMAPTable e, String[] colInt, String[] valInt, int numPage, String apresWhere, String[] nomColSomme, Connection c) throws Exception;

    public ResultatEtSomme getDataPageMax(ClassMAPTable e, String[] colInt, String[] valInt, int numPage, String apresWhere, String[] nomColSomme, Connection c, int npp) throws Exception;

    //public Object createRemisemagasinMultiple(String[] immo, String magasin) throws Exception;
    //public void ejbRemove();

    public void deleteObjetFille(ClassMAPTable o, Connection conn) throws Exception;

    public void deleteObjetFille(ClassMAPTable o) throws Exception;

    public Object annulerObject(ClassMAPTable o) throws Exception;

    public Object annulerObject(ClassMAPTable o, Connection c) throws Exception;

    public String getMaxId(String table, String[] colonne, String[] listeCritere) throws Exception;

    public String getMaxId(String table) throws Exception;

    public void updateEtat(ClassMAPTable e, int valeurEtat, String id) throws Exception;

    public String createTypeObjet(String nomTable, String proc, String pref, String typ, String desc) throws Exception;

    public String updateTypeObjet(String table, String id, String typ, String desc) throws Exception;

    public TypeObjet[] findTypeObjet(String nomTable, String id, String typ) throws Exception;

    public int deleteTypeObjet(String nomTable, String id) throws Exception;

    public MapUtilisateur[] findUtilisateurs(String refuser, String loginuser, String pwduser, String nomuser, String adruser, String teluser, String idrole) throws Exception;

    public MapRoles[] findRole(String rol);

    public MapUtilisateur   getUser();

    public int rejeterObjectMultiple(ClassEtat o, String[] listeIdObjet, String nomTableRejet, String nomTableCategorieRejet) throws Exception;

    public int viserObjectMultiple(ClassEtat o, String[] listeIdObjet) throws Exception;

    public int retournerObjectMultiple(ClassEtat o, String[] listeIdObjet, String motif) throws Exception;

    public int recuObjectMultiple(ClassEtat o, String[] listeIdObjet) throws Exception;

    public int validerObjectMultiple(ClassEtat[] o) throws Exception;

    public Object finaliser(ClassMAPTable o, Connection c) throws Exception;

    public Object finaliser(ClassMAPTable o) throws Exception;

    public String updateUtilisateurs(String refuser, String loginuser, String pwduser, String nomuser, String adruser, String teluser, String idrole) throws Exception;

    public int deleteUtilisateurs(String refuser) throws Exception;

    void createObjectFilleMultipleSansMere(String u, ClassMAPTable[] fille) throws Exception;

    public String createUtilisateurs(String loginuser, String pwduser, String nomuser, String adruser, String teluser, String idrole) throws Exception;

    public int desactiveUtilisateur(String ref) throws Exception;

    public int activeUtilisateur(String ref) throws Exception;

    public void testLogin(String user, String pass) throws Exception;

    public void testLogin(String user, String pass, String param) throws Exception;

    public void testLoginAlumni(String etu, String pass) throws Exception;

    public String findHomePageServices(String codeService) throws Exception;

    public String mapperMereFille(ClassMAPTable e, String idMere, String[] idFille, String rem, String montant, String etat) throws Exception;

    public String mapperMereFille(ClassMAPTable e, String nomTable, String idMere, String[] idFille, String rem, String montant, String etat) throws Exception;

    public void deleteMereFille(ClassMAPTable e, String idMere, String[] liste_id_fille) throws Exception;

    public void annulerVisa(ClassMAPTable o) throws Exception; //
    
    public void annulerVisa(ClassMAPTable o,Connection c) throws Exception; //

    public void deleteMereFille(ClassMAPTable e, String nomTable, String idMere, String[] liste_id_fille) throws Exception;

    public ResultatEtSomme getDataPage(ClassMAPTable e, String[] colInt, String[] valInt, int numPage, String apresWhere, String[] nomColSomme, Connection c) throws Exception;

    public ResultatEtSomme getDataPage(ClassMAPTable e, String[] colInt, String[] valInt, int numPage, String apresWhere, String[] nomColSomme, Connection c, int npp) throws Exception;

    public ResultatEtSomme getDataPageGroupe(ClassMAPTable e, String[] groupe, String[] sommeGroupe, String[] colInt, String[] valInt, int numPage, String apresWhere, String[] nomColSomme, String ordre, Connection c) throws Exception;

    public ResultatEtSomme getDataPageGroupe(ClassMAPTable e, String[] groupe, String[] sommeGroupe, String[] colInt, String[] valInt, int numPage, String apresWhere, String[] nomColSomme, String ordre, Connection c, int npp) throws Exception;

    public Object[] getData(ClassMAPTable e, String[] colInt, String[] valInt, Connection c, String apresWhere) throws Exception;

    public Object createObject(ClassMAPTable o) throws Exception;

    public Object dupliquerObject(ClassMAPTable o, String mapFille, String nomColonneMere) throws Exception;

    public Object dupliquerObject(ClassMAPTable o, String mapFille, String nomColonneMere, Connection c) throws Exception;

    public Object createObject(ClassMAPTable o, Connection c) throws Exception;

    public Object updateObject(ClassMAPTable o) throws Exception;

    public Object validerObject(ClassMAPTable o) throws Exception;
    
    public Object validerObject(ClassMAPTable o, Connection c) throws Exception;

    public Object rejeterObject(ClassMAPTable o) throws Exception;

    public Object cloturerObject(ClassMAPTable o) throws Exception;

    public void deleteObject(ClassMAPTable o) throws Exception;

    public boolean isSuperUser();

    public void setIdDirection(String idDirection);

    public String getIdDirection();

    public Direction[] findDirection(String idDir, String libelledir, String descdir, String abbrevDir, String idDirecteur) throws Exception;

    public ResultatEtSomme findResultatFinalePage(String nomTable, String apresW, String colonne, String ordre) throws Exception;

    public int testRestriction(String user, String permission, String table, Connection con) throws Exception;

    public String[] getAllTable() throws Exception;

    public config.Table[] getListeTable(String role, String adruser) throws Exception;

    public int deletePJ(String idDossier, String idPj) throws Exception;

    public int deletePJ(String idDossier, String idPj, Connection con) throws Exception;

    public int ajouterPJInfo(String info_valeur, String pieces_id, String info_id, String info_ok) throws Exception;

    public int ajouterPJInfo(String info_valeur, String pieces_id, String info_id, String info_ok, Connection con) throws Exception;

    public int ajouterPJTiers(String idPiece, List<String[]> listeTiers) throws Exception;

    public int ajouterPJTiers(String idPiece, List<String[]> listeTiers, Connection con) throws Exception;

    public int detacherTiers(String idtiers) throws Exception;

    public Object createObjectMultiple(ClassMAPTable[] o) throws Exception;
    
    public void createUploadedPj(String nomtable, String nomprocedure, String libelle, String chemin, String mere) throws Exception;//Upload generaliser

    public void deleteUploadedPj(String nomtable, String id) throws Exception;//delete d'upload generaliser

    public void ajoutrestriction(String[] table, String idrole, String idaction, String direction) throws Exception;

    public void ajoutrestriction(String[] val, String idrole, String idaction, String direction, Connection c) throws Exception;

    public String mapperMereToFilleMetier(ClassMAPTable e, String idMere, String[] idFille, String rem, String montant, String etat) throws Exception;

    public String mapperMereToFilleMetier(ClassMAPTable e, String nomTable, String idMere, String[] idFille, String rem, String montant, String etat) throws Exception;

    public void notifierObjectMultiple(String[] ids, String classe) throws Exception;

    public void updateEtat(ClassMAPTable e, int valeurEtat, String id, Connection c) throws Exception;

    public void updateEtat(ClassMAPTable e, int valeurEtat, String id, String colid) throws Exception;

    public Object updateObject(ClassMAPTable o, Connection c) throws Exception;

    public Object createObjectMultiple(ClassMAPTable mere, String colonneMere, ClassMAPTable[] fille) throws Exception;

    public void createUploadedPjService(String iddossier, HashMap<String, String> listeVal, Iterator it, String nomtable, String nomprocedure, String mere) throws Exception;
    
    public Object createUploadedPjServiceRetour(String iddossier, HashMap<String, String> listeVal, Iterator it, String nomtable, String nomprocedure, String mere) throws Exception;

    public ResultatEtSomme getDataPageMaxSansRecap(ClassMAPTable e, String[] colInt, String[] valInt, int numPage, String apresWhere, String[] nomColSomme, Connection c, int npp) throws Exception;
    
    public int validerObjetMereFille(ClassEtat mere, ClassEtat fille, String idmere, String nomcolonneidmere, Connection c) throws Exception;

    public HashMap<String, String> getMapAutoComplete();
    
    public void setMapAutoComplete(HashMap<String, String> mapAutoComplete);
    
    public Object updateObjectMultiple(ClassMAPTable[] o) throws Exception;
    
    public Object updateObjectMultiple(ClassMAPTable mere, String colonneMere, ClassMAPTable[] fille) throws Exception;
    
    public Object[] updateInsertObjectMultiple(ClassMAPTable[] o) throws Exception;
    
    public void updateOneColonneMultiple(String nomTable, String colonne, String colonneCritere, String[]valeurCritere, Object valeur) throws Exception;
    
    public String createTypeObjet(String nomTable, String proc, String pref, String typ, String desc, Connection c) throws Exception;
    
    public void createTypeObjetMultiple(String nomTable, String proc, String pref, String[] typ, String[] desc) throws Exception;
    
    public void deleteMultiple(String[]ids, String classe,String nomtable,Connection c) throws Exception;
    public ClassMAPTable[] getDataPage(ClassMAPTable e, String requete, Connection c) throws Exception;
    public String getLangue();
    public void setLangue(String langue);
    public Map<String, String> getMapTraduction();
    public void setMapTraduction(Map<String, String> mapTraduction);
    public String getTraduction(String mot);
}
