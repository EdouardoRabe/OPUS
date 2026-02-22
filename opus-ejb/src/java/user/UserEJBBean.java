package user;

import bean.CGenUtil;
import bean.ClassEtat;
import bean.ClassMAPTable;
import bean.ClassUser;
import bean.ErreurDAO;
import bean.ListeColonneTable;
import bean.RejetTable;
import bean.ResultatEtSomme;
import bean.TypeObjet;
import bean.TypeObjetUtil;
import bean.UnionIntraTable;
import bean.UploadPj;
import com.google.gson.Gson;
import config.Config;

import historique.HistoriqueEJBClient;
import historique.HistoriqueLocal;
import historique.MapHistorique;
import historique.MapRoles;
import historique.MapUtilisateur;
import historique.UtilisateurUtil;

import java.rmi.RemoteException;
import java.sql.*;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import javax.ejb.*;

import lc.Direction;
import lc.DirectionUtil;
import mg.cnaps.utilisateur.CNAPSUser;
import modules.GestionRole;

import utilisateur.ConstanteUtilisateur;
import utilisateur.HomePageURL;
import constanteAcade.ConstanteEtatAcade;
import utilitaire.ConstanteUser;
import utilitaire.UtilDB;
import utilitaireAcade.UtilitaireAcade;
import utilitaire.UtilitaireMetier;
import mg.cnaps.configuration.Configuration;

@Stateful
public class UserEJBBean implements UserEJB, UserEJBRemote, SessionBean {

    SessionContext sessionContext;
    MapUtilisateur u;
    MapUtilisateur uVue;
    String type;
    String idDirection;
    String home_page = "notification/notification-liste.jsp";
    Config c;
    CNAPSUser cnapsUser;
    Configuration[] listeConfig;
    String langue;
    Map<String, String> mapTraduction;

    public String getLangue() {
        return langue;
    }

    public void setLangue(String langue) {
        this.langue = langue;
    }

    public Map<String, String> getMapTraduction() {
        return mapTraduction;
    }

    public void setMapTraduction(Map<String, String> mapTraduction) {
        this.mapTraduction = mapTraduction;
    }

    public String getTraduction(String mot) {
        String result = mot;
        if (this.getLangue() != null && this.getLangue().equalsIgnoreCase("fr") == false) {
            String valeur = this.getMapTraduction().get(mot);
            if (valeur != null) {
                result = valeur;
            }
        }
        return result;
    }

    private HashMap<String, String> mapAutoComplete = new HashMap<>();

    public Configuration[] getListeConfiguration() {
        return listeConfig;
    }

    public CNAPSUser getCnapsUser() {
        return cnapsUser;
    }

    public UserEJBBean() {
        u = null;
    }

    // public void ejbRemove() {
    // MapHistorique histo = new MapHistorique("logout", "logout",
    // String.valueOf(u.getRefuser()), String.valueOf(u.getRefuser()));
    // histo.setObjet("mg.cnaps.utilisateur.CNAPSUser");
    // histo.setAction(histo.getAction());
    //
    // String heure = LocalTime.now().toString();
    // heure = heure.replace(".", ":");
    // histo.setHeure(heure);
    // try {
    // histo.insertToTable();
    //
    // TimingApplication timingApplication = new TimingApplication();
    // timingApplication.setRefuser(String.valueOf(u.getRefuser()));
    //
    // TimingApplication[] timingApplications = (TimingApplication[])
    // CGenUtil.rechercher(timingApplication, null, null, " and dateheurefin is
    // null");
    // if(timingApplications.length!=0){
    // timingApplication = timingApplications[0];
    // timingApplication.setDateHeureFin(Timestamp.valueOf(LocalDateTime.now()));
    //
    // LocalDateTime debut =
    // timingApplication.getDateHeureDebut().toLocalDateTime();
    // LocalDateTime fin = timingApplication.getDateHeureFin().toLocalDateTime();
    // int duration = (int) Duration.between(debut, fin).toMinutes();
    //
    // timingApplication.setDuree(duration);
    //
    // timingApplication.upDateToTable();
    // }
    // } catch (Exception e) {
    // throw new RuntimeException(e);
    // }
    // }

    public void ejbActivate() {
    }

    public void ejbPassivate() {
    }

    public void setSessionContext(SessionContext sessionContext) {
        this.sessionContext = sessionContext;
    }

    @Override
    public void ejbRemove() throws EJBException, RemoteException {

    }

    @Override
    public ClassMAPTable[] getDataPage(ClassMAPTable e, String requete, Connection c) throws Exception {
        return (ClassMAPTable[]) CGenUtil.rechercher(e, requete, c);
    }

    @Override
    public void createObjectFilleMultipleSansMere(ClassMAPTable[] fille) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);

            createObjectMultipleSansMere(fille, c);

            c.commit();
        } catch (Exception e) {
            e.printStackTrace();
            c.rollback();
            throw e;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    @Override
    public void createObjectFilleMultipleSansMere(String u, ClassMAPTable[] fille) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);

            createObjectMultipleSansMere(u, fille, c);

            c.commit();
        } catch (Exception e) {
            e.printStackTrace();
            c.rollback();
            throw e;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public Object[] createObjectMultipleSansMere(ClassMAPTable[] o, Connection c) throws Exception {
        try {
            Object[] ret = new Object[o.length];
            for (int i = 0; i < o.length; i++) {
                ret[i] = createObject(o[i], c);
            }
            return ret;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        }

    }

    public Object[] createObjectMultipleSansMere(String u, ClassMAPTable[] o, Connection c) throws Exception {
        try {
            Object[] ret = new Object[o.length];
            for (int i = 0; i < o.length; i++) {
                ret[i] = o[i].createObject(u, c);
                // ret[i] = createObject(o[i], c);
            }
            return ret;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        }

    }

    @Override
    public String createUtilisateurs(String loginuser, String pwduser, String nomuser, String adruser, String teluser,
            String idrole) throws Exception {
        HistoriqueLocal rl = null;
        try {
            if (u.getIdrole().compareTo("dg") == 0) {
                rl = HistoriqueEJBClient.lookupHistoriqueEJBBeanLocal();
                String s = rl.createUtilisateurs(loginuser, pwduser, nomuser, adruser, teluser, idrole,
                        u.getTuppleID());
                return s;
            } else {
                throw new Exception("Erreur de droit");
            }
        } catch (CreateException ex) {
            throw new Exception(ex.getMessage());
        }
    }

    @Override
    public String updateUtilisateurs(String refuser, String loginuser, String pwduser, String nomuser, String adruser,
            String teluser, String idrole) throws Exception {
        HistoriqueLocal rl = null;
        try {
            rl = HistoriqueEJBClient.lookupHistoriqueEJBBeanLocal();
            if (u.getIdrole().compareTo("dg") == 0) {
                return rl.updateUtilisateurs(refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole,
                        u.getTuppleID());
            } else if (String.valueOf(u.getRefuser()).compareTo(refuser) == 0) {
                return rl.updateUtilisateurs(refuser, loginuser, pwduser, nomuser, adruser, teluser, u.getIdrole(),
                        u.getTuppleID());
            } else {
                throw new Exception("Erreur de droit");
            }
        } catch (CreateException ex) {
            throw new Exception(ex.getMessage());
        }
    }

    @Override
    public int deleteUtilisateurs(String refuser) throws Exception {
        HistoriqueLocal rl = null;

        try {
            if (u.getIdrole().compareTo("admin") == 0 || u.getIdrole().compareTo("dg") == 0
                    || u.getIdrole().compareTo("adminFacture") == 0) {
                rl = HistoriqueEJBClient.lookupHistoriqueEJBBeanLocal();
                int i = rl.deleteUtilisateurs(refuser, u.getTuppleID());
                return i;
            } else {
                throw new Exception("Erreur de droit");
            }
        } catch (CreateException ex) {
            throw new Exception(ex.getMessage());
        }
    }

    public ClassMAPTable estIlExiste(ClassMAPTable o) throws Exception {
        try {
            ClassMAPTable[] liste = (ClassMAPTable[]) CGenUtil.rechercher(o, null, null, "");
            if (liste.length > 0) {
                return liste[0];
            } else {
                return null;
            }
        } catch (Exception ex) {
            throw ex;
        }
    }

    @Override
    public String createTypeObjet(String nomTable, String proc, String pref, String typ, String desc) throws Exception {
        try {
            if (u.getIdrole().compareTo("Chef") == 0 || u.getIdrole().compareTo("admin") == 0
                    || u.getIdrole().compareTo("dg") == 0 || u.getIdrole().compareTo("adminFacture") == 0) {
                TypeObjet to = new TypeObjet(nomTable, proc, pref, typ, desc);
                MapHistorique histo = new MapHistorique(nomTable, "insert", u.getTuppleID(), to.getId());
                histo.setObjet("bean.TypeObjet");
                to.insertToTable(histo);
                String s = to.getId();
                return s;
            } else {
                throw new Exception("Erreur de droit");
            }
        } catch (ErreurDAO ex) {
            throw new Exception(ex.getMessage());
        }
    }

    public String updateMontantUnionIntra(String nomTable, String id1, String[] id2, String[] montant)
            throws Exception {
        Connection c = null;
        Statement st = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            st = c.createStatement();
            for (int i = 0; i < id2.length; i++) {
                bean.UnionIntraTableUtil uiti = new bean.UnionIntraTableUtil();
                uiti.setNomTable(nomTable);
                UnionIntraTable[] liefflc = (UnionIntraTable[]) uiti.rechercher(1, id2[i], c);
                if (liefflc.length == 0) {
                    throw new Exception("le lien n existe pas");
                }
                if (liefflc[0].estIlModifiable() == true) {
                    liefflc[0].setMontantMere(Double.parseDouble(montant[i]));
                    liefflc[0].setNomTable(nomTable);
                    String rek = "update " + nomTable + "  set montantMere = " + montant[i] + " where id1 = '"
                            + liefflc[0].getId1() + "' and id2 = '" + liefflc[0].getId2() + "'";
                    st.executeUpdate(rek);
                }
            }
            c.commit();
            return "ok";
        } catch (SQLException ex) {
            ex.printStackTrace();
            c.rollback();
            throw new Exception();
        } finally {
            if (c != null) {
                c.close();
            }
            if (st != null) {
                st.close();
            }
        }
    }

    @Override
    public String updateTypeObjet(String table, String id, String typ, String desc) throws Exception {
        try {
            if (u.getIdrole().compareTo("Chef") == 0 || u.getIdrole().compareTo("admin") == 0
                    || u.getIdrole().compareTo("dg") == 0 || u.getIdrole().compareTo("adminFacture") == 0) {
                TypeObjet to = new TypeObjet(table, id, typ, desc);
                MapHistorique histo = new MapHistorique(table, "update", u.getTuppleID(), to.getId());
                histo.setObjet("bean.TypeObjet");
                to.updateToTableWithHisto(histo);
                String s = to.getId();
                return s;
            } else {
                throw new Exception("Erreur de droit");
            }
        } catch (ErreurDAO ex) {
            throw new Exception(ex.getMessage());
        }
    }

    @Override
    public int deleteTypeObjet(String nomTable, String id) throws Exception {
        try {
            if (u.getIdrole().compareTo("Chef") == 0 || u.getIdrole().compareTo("admin") == 0
                    || u.getIdrole().compareTo("dg") == 0 || u.getIdrole().compareTo("adminFacture") == 0) {

                TypeObjet to = new TypeObjet(nomTable, id, "-", "-");
                MapHistorique h = new MapHistorique(nomTable, "delete", u.getTuppleID(), id);
                h.setObjet("bean.TypeObjet");
                to.deleteToTable(h);
                int i = 1;
                return i;
            } else {
                throw new Exception("Erreur de droit");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            throw new Exception(ex.getMessage());
        }
    }

    @Override
    public MapUtilisateur[] findUtilisateurs(String refuser, String loginuser, String pwduser, String nomuser,
            String adruser, String teluser, String idrole) throws Exception {
        try {
            int[] a = { 1, 2, 3, 4, 5, 6, 7 }; // Donne le numero des champs sur lesquelles on va mettre des criteres
            String[] val = new String[a.length];
            val[0] = refuser;
            val[1] = loginuser;
            val[2] = pwduser;
            val[3] = nomuser;
            val[4] = adruser;
            val[5] = teluser;
            val[6] = idrole; // Affecte des valeurs aux criteres
            UtilisateurUtil cu = new UtilisateurUtil();
            return (MapUtilisateur[]) cu.rechercher(a, val);
        } catch (Exception ex) {
            throw new Exception(ex.getMessage());
        }
    }

    @Override
    public ResultatEtSomme findResultatFinalePage(String nomTable, String apresW, String colonne, String ordre)
            throws Exception {
        return null;
    }

    @Override
    public MapRoles[] findRole(String rol) {
        return (MapRoles[]) (new historique.RoleUtil().rechercher(1, rol));
    }

    @Override
    public MapUtilisateur getUser() {
        return u;
    }

    public int getMontantBilletage(String dix, String cinq, String deux, String un, String deuxCinq, String deuxCent,
            String cent, String cinquante, String vingt) {
        int retour1 = UtilitaireAcade.stringToInt(dix) * 10000 + 5000 * UtilitaireAcade.stringToInt(cinq)
                + 2000 * UtilitaireAcade.stringToInt(deux) + 1000 * UtilitaireAcade.stringToInt(un);
        int retour2 = UtilitaireAcade.stringToInt(deuxCinq) * 500 + 200 * UtilitaireAcade.stringToInt(deuxCent)
                + 100 * UtilitaireAcade.stringToInt(cent) + 50 * UtilitaireAcade.stringToInt(cinquante)
                + 20 * UtilitaireAcade.stringToInt(vingt);
        return retour1 + retour2;
    }

    public int desactiveUtilisateur(String ref, String refUser) throws Exception {
        try {
            historique.AnnulationUtilisateur au = new historique.AnnulationUtilisateur(ref);
            historique.MapHistorique h = new historique.MapHistorique("Utilisateurs", "annule", refUser, ref);
            h.setObjet("historique.AnnulationUtilisateur");
            au.insertToTable(h);
            return 1;
        } catch (ErreurDAO ex) {
            throw new bean.ErreurDAO(ex.getMessage());
        }
    }

    @Override
    public int desactiveUtilisateur(String ref) throws Exception {

        try {
            if (u.getIdrole().compareTo("admin") == 0 || u.getIdrole().compareTo("dg") == 0
                    || u.getIdrole().compareTo("adminFacture") == 0) {

                int i = desactiveUtilisateur(ref, u.getTuppleID());
                return i;
            } else {
                throw new Exception("Erreur de droit");
            }
        } catch (CreateException ex) {
            throw new Exception(ex.getMessage());
        }
    }

    public int activeUtilisateur(String ref, String refUser) throws bean.ErreurDAO {
        try {
            historique.AnnulationUtilisateur[] au = (historique.AnnulationUtilisateur[]) new historique.AnnulationUtilisateurUtil()
                    .rechercher(2, ref);
            historique.MapHistorique h = new historique.MapHistorique("Utilisateurs", "active", refUser, ref);
            h.setObjet("historique.AnnulationUtilisateur");
            for (int i = 0; i < au.length; i++) {
                au[i].deleteToTable(h);
            }
            return 1;
        } catch (ErreurDAO ex) {
            throw new bean.ErreurDAO(ex.getMessage());
        }
    }

    @Override
    public int activeUtilisateur(String ref) throws Exception {

        try {
            if (u.getIdrole().compareTo("admin") == 0 || u.getIdrole().compareTo("dg") == 0
                    || u.getIdrole().compareTo("adminFacture") == 0) {

                int i = activeUtilisateur(ref, u.getTuppleID());
                return i;
            } else {
                throw new Exception("Erreur de droit");
            }
        } catch (CreateException ex) {
            throw new Exception(ex.getMessage());
        }
    }

    public MapUtilisateur testeValide(String user, String pass) throws Exception {
        try {
            historique.UtilisateurUtil uI = new UtilisateurUtil();
            return uI.testeValide(user, pass);
        } catch (Exception ex) {
            ex.printStackTrace();
            throw new Exception(ex.getMessage());
        }
    }

    public String findHomePageServices(String codeService) throws Exception {
        Connection connection = null;
        try {
            connection = (new UtilDB()).GetConn();
            HomePageURL[] hommePageList = (HomePageURL[]) CGenUtil.rechercher(new HomePageURL(), null, null, connection,
                    "");
            if (hommePageList != null && hommePageList.length > 0) {
                this.home_page = hommePageList[0].getUrlpage();
            }
            return this.home_page;
        } catch (Exception ex) {
            ex.printStackTrace();
            throw new Exception(ex.getMessage());
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
    }

    @Override
    public Direction[] findDirection(String idDir, String libelledir, String descdir, String abbrevDir,
            String idDirecteur) throws Exception {

        try {
            String afterW = "";
            int[] numChamp = { 0, 1, 2 };
            String[] val = { idDir, libelledir, descdir };
            DirectionUtil du = new DirectionUtil();
            du.utiliserChampBase();
            // if(idDirecteur.compareToIgnoreCase("")==0 ||
            // idDirecteur.compareToIgnoreCase("%")==0) idDirecteur = "%";
            // afterW=" AND idDirecteur like '" + idDirecteur +"'";
            return (Direction[]) du.rechercher(numChamp, val, "");

        } catch (Exception ex) {
            throw new Exception(ex.getMessage());
        }

    }

    @Override
    public TypeObjet[] findTypeObjet(String nomTable, String id, String typ) throws Exception {
        try {
            TypeObjetUtil to = new TypeObjetUtil();
            TypeObjet atypeobjet[] = to.findTypeObjet(nomTable, id, typ);
            return atypeobjet;
        } catch (Exception ex) {
            throw new Exception(ex.getMessage());
        }
    }

    @Override
    public void testLogin(String user, String pass) throws Exception {
        Connection c = null;
        try {
            u = testeValide(user, pass);

            UtilisateurUtil crt = new UtilisateurUtil();
            uVue = crt.testeValide("utilisateurVue", user, pass);
            type = u.getIdrole();
            MapHistorique histo = new MapHistorique("login", "login", String.valueOf(u.getRefuser()),
                    String.valueOf(u.getRefuser()));
            histo.setObjet("mg.cnaps.utilisateur.CNAPSUser");
            histo.setAction(histo.getAction());

            String heure = LocalTime.now().toString();
            heure = heure.replace(".", ":");
            histo.setHeure(heure);

            histo.insertToTable();

            // TimingApplication timingApplication = new TimingApplication();
            // timingApplication.addTiming(u);

        } catch (Exception ex) {
            ex.printStackTrace();
            throw new Exception(ex.getMessage());
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    @Override
    public void testLogin(String user, String pass, String param) throws Exception {
        Connection c = null;
        try {
            user = "judicael";
            pass = "judicael";
            u = testeValide(user, pass);

            UtilisateurUtil crt = new UtilisateurUtil();
            uVue = crt.testeValide("utilisateurVue", user, pass);
            type = u.getIdrole();
            MapHistorique histo = new MapHistorique("login", "login", String.valueOf(u.getRefuser()),
                    String.valueOf(u.getRefuser()));
            histo.setObjet("mg.cnaps.utilisateur.CNAPSUser");
            histo.setAction(histo.getAction());

            String heure = LocalTime.now().toString();
            heure = heure.replace(".", ":");
            histo.setHeure(heure);

            histo.insertToTable();

            // TimingApplication timingApplication = new TimingApplication();
            // timingApplication.addTiming(u);

        } catch (Exception ex) {
            ex.printStackTrace();
            throw new Exception(ex.getMessage());
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public void ejbCreate() throws CreateException {
    }

    @Override
    public String getIdDirection() {
        return idDirection;
    }

    @Override
    public void setIdDirection(String idDirection) {
        this.idDirection = idDirection;
    }

    @Override
    public String mapperMereFille(ClassMAPTable e, String idMere, String[] idFille, String rem, String montant,
            String etat) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            mapperMereFille(e.getNomTable(), e.getNomProcedureSequence(), e.getINDICE_PK(), idMere, idFille, rem,
                    montant, etat, c);
            c.commit();
        } catch (Exception ex) {
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return null;
    }

    @Override
    public String mapperMereFille(ClassMAPTable e, String nomTable, String idMere, String[] idFille, String rem,
            String montant, String etat) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            String nomProcedure = "getSeq" + UtilitaireAcade.convertDebutMajuscule(nomTable);
            String indicePK = nomTable.substring(0, 3).toUpperCase();
            mapperMereFille(nomTable, nomProcedure, indicePK, idMere, idFille, rem, montant, etat, c);
            c.commit();
        } catch (Exception ex) {
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return null;
    }

    @Override
    public void deleteMereFille(ClassMAPTable e, String idMere, String[] liste_id_fille) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            deleteMereFille(e.getNomTable(), idMere, liste_id_fille, c);
            c.commit();
        } catch (Exception ex) {
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public String mapperMereFille(String nomtableMappage, String nomProcedure, String suffixeMap, String idMere,
            String[] idFille, String rem, String montant, String etat, Connection c) throws Exception {
        try {
            for (int i = 0; i < idFille.length; i++) {
                UtilitaireMetier.mapperMereToFille(nomtableMappage, nomProcedure, suffixeMap, idMere, idFille[i], rem,
                        montant, u.getTuppleID(), etat, c);
            }
        } catch (Exception e) {
            throw e;
        }
        return null;
    }

    public void deleteMereFille(String nomtableMappage, String idMere, String[] idFille, Connection c)
            throws Exception {
        try {
            for (int i = 0; i < idFille.length; i++) {
                UtilitaireMetier.deleteMereToFille(nomtableMappage, idMere, idFille[i], u.getTuppleID(), c);
            }
        } catch (Exception e) {
            throw e;
        }
    }

    @Override
    public void deleteMereFille(ClassMAPTable e, String nomTable, String idMere, String[] liste_id_fille)
            throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            deleteMereFille(nomTable, idMere, liste_id_fille, c);

            c.commit();
        } catch (Exception ex) {
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public boolean testMemeUser(int userAutres) throws Exception {
        if (u.getRefuser() != (userAutres)) {
            throw new Exception("Utilisateur different de vous");
        }
        return true;
    }

    public boolean testMemeDirection(int userAutres) throws Exception {
        boolean retour = true;
        MapUtilisateur crt = new MapUtilisateur();
        MapUtilisateur[] t = (MapUtilisateur[]) (bean.CGenUtil.rechercher(crt, null, null,
                " and refuser=" + userAutres));
        if (t.length == 0) {
            throw new Exception("Utilisateur finale " + userAutres + " non existante");
        }
        // System.out.println("u adre user = "+t.length+" t[0] adr user =
        // "+t[0].getAdruser()+" t[0] id user = "+userAutres);
        if (u.getAdruser().compareToIgnoreCase(t[0].getAdruser()) != 0) {
            throw new Exception("Utilisateur dans une autre direction");
        }
        return retour;
    }

    public String testRangUser(ClassMAPTable e, Connection c) throws Exception {
        String retour = "";

        // si adruser = DG => direction like '%'
        // si autre => direction = 'autre_direction'
        // if (e instanceof bean.ClassEtat || e instanceof bean.ClassUser) {
        // if
        // (u.getIdrole().compareTo("verificateur_recette")!=0&&u.getAdruser().compareTo("DG")
        // != 0 && ListeColonneTable.getChamp(e, "direction", c) != null) {
        // retour += " and direction like '" + u.getAdruser() + "'";
        // }
        // }

        /*
         * UtilisateurRole util = new UtilisateurRole();
         * UtilisateurRole[] utilEnCours = (UtilisateurRole[]) CGenUtil.rechercher(util,
         * null, null, c, " and refuser=" + u.getTuppleID());
         * if (utilEnCours.length != 0) {
         * UtilisateurRole[] liste_util = (UtilisateurRole[]) CGenUtil.rechercher(util,
         * null, null, c, " and rang <= " + utilEnCours[0].getRang());
         * String[] users = new String[liste_util.length];
         * 
         * for (int i = 0; i < liste_util.length; i++) {
         * users[i] = liste_util[i].getRefuser() + "";
         * }
         * if (e instanceof bean.ClassEtat || e instanceof bean.ClassUser) {
         * if (e instanceof mg.cnaps.notification.NotificationLibelle) {
         * return NotificationService.conditionLectureNotification(utilEnCours[0]);
         * } else if ((ListeColonneTable.getChamp(e, "direction", c) != null &&
         * ListeColonneTable.getChamp(e, "service", c) != null)) {
         * if (utilEnCours[0].getRang() < ConstanteUser.getRangChefDeService()) {
         * return " and ((iduser = '" + utilEnCours[0].getRefuser() +
         * "') OR (iduser like '%' AND service = '" + utilEnCours[0].getService() +
         * "') OR (iduser like '%' AND direction like '%'))";
         * }
         * if (utilEnCours[0].getRang() >= ConstanteUser.getRangChefDeService() &&
         * utilEnCours[0].getRang() < ConstanteUser.getRangDG()) {
         * return " and ((service = '" + utilEnCours[0].getService() +
         * "') OR (direction like '%' AND service like '%' ) OR (service like '%' AND direction = '"
         * + utilEnCours[0].getDirection() + "'))";
         * }
         * if (utilEnCours[0].getRang() >= ConstanteUser.getRangDG()) {
         * return " and (direction like '%' OR direction is null)";
         * }
         * } else {
         * retour = UtilitaireAcade.tabToString(users, "'", ",");
         * retour = " and iduser in (" + retour + ",'0')";
         * }
         * }
         * // if ((e.getClass().getSuperclass().getSimpleName() != null) &&
         * (e.getClass().getSuperclass().getSimpleName().compareToIgnoreCase(
         * "ClassEtat") == 0 ||
         * e.getClass().getSuperclass().getSimpleName().compareToIgnoreCase("ClassUser")
         * == 0)) {
         * // retour = UtilitaireAcade.tabToString(users, "'", ",");
         * // retour = " and iduser in (" + retour + ",'0')";
         * // }
         * }
         */
        return retour;
    }

    @Override
    public ResultatEtSomme getDataPageMax(ClassMAPTable e, String[] colInt, String[] valInt, int numPage,
            String apresWhere, String[] nomColSomme, Connection c) throws Exception {
        return getDataPageMax(e, colInt, valInt, numPage, apresWhere, nomColSomme, c, 0);
    }

    @Override
    public ResultatEtSomme getDataPageMax(ClassMAPTable e, String[] colInt, String[] valInt, int numPage,
            String apresWhere, String[] nomColSomme, Connection c, int npp) throws Exception {
        e.setMode("select");
        // novaina direction ilay iduser
        if (ListeColonneTable.getChamp(e, "direction", c) != null) {
            ClassUser temp = (ClassUser) e;
            apresWhere = testRangUser(e, c) + apresWhere;
        }
        if (e.getNomTableSelect().compareToIgnoreCase("SIG_TRAVAILLEUR_INFO_COMPLET") == 0) {
            return CGenUtil.rechercherPageMaxSansRecap(e, colInt, valInt, numPage, apresWhere, nomColSomme, c, npp);
        }
        // System.out.println("apres where vaovao oooo "+apresWhere+ "user vaovao
        // ooo"+u.getTuppleID());
        return CGenUtil.rechercherPageMax(e, colInt, valInt, numPage, apresWhere, nomColSomme, c, npp);
    }

    @Override
    public ResultatEtSomme getDataPage(ClassMAPTable e, String[] colInt, String[] valInt, int numPage,
            String apresWhere, String[] nomColSomme, Connection c) throws Exception {
        return getDataPage(e, colInt, valInt, numPage, apresWhere, nomColSomme, c, 0);
    }

    @Override
    public ResultatEtSomme getDataPage(ClassMAPTable e, String[] colInt, String[] valInt, int numPage,
            String apresWhere, String[] nomColSomme, Connection c, int npp) throws Exception {
        e.setMode("select");
        // novaina direction ilay iduser
        if (ListeColonneTable.getChamp(e, "direction", c) != null) {
            ClassUser temp = (ClassUser) e;
            apresWhere = testRangUser(e, c) + apresWhere;
        }
        ResultatEtSomme rs = CGenUtil.rechercherPage(e, colInt, valInt, numPage, apresWhere, nomColSomme, c, npp);

        return rs;
    }

    @Override
    public ResultatEtSomme getDataPageGroupe(ClassMAPTable e, String[] groupe, String[] sommeGroupe, String[] colInt,
            String[] valInt, int numPage, String apresWhere, String[] nomColSomme, String ordre, Connection c)
            throws Exception {
        e.setMode("select");
        // novaina direction ilay iduser
        if (ListeColonneTable.getChamp(e, "direction", c) != null) {
            apresWhere = testRangUser(e, c) + apresWhere;
        }
        return CGenUtil.rechercherPageGroupe(e, groupe, sommeGroupe, colInt, valInt, numPage, apresWhere, nomColSomme,
                ordre, c);
    }

    @Override
    public ResultatEtSomme getDataPageGroupe(ClassMAPTable e, String[] groupe, String[] sommeGroupe, String[] colInt,
            String[] valInt, int numPage, String apresWhere, String[] nomColSomme, String ordre, Connection c, int npp)
            throws Exception {
        e.setMode("select");
        // novaina direction ilay iduser

        if (ListeColonneTable.getChamp(e, "direction", c) != null) {
            apresWhere = testRangUser(e, c) + apresWhere;
        }
        // if(e instanceof HistoriqueCreationTacheTous){
        // String req=HistoriqueCreationTacheTous.getRequete(valInt);
        // return CGenUtil.rechercherPageGroupe( e, req, groupe, sommeGroupe, colInt,
        // valInt, numPage, apresWhere, nomColSomme, ordre, c, npp);
        // }
        System.out.println("new gsonnn " + new Gson().toJson(colInt) + " eee " + new Gson().toJson(valInt));
        return CGenUtil.rechercherPageGroupe(e, groupe, sommeGroupe, colInt, valInt, numPage, apresWhere, nomColSomme,
                ordre, c, npp);
    }

    @Override
    public Object[] getData(ClassMAPTable e, String[] colInt, String[] valInt, Connection c, String apresWhere)
            throws Exception {
        e.setMode("select");
        // novaina direction ilay iduser
        if (ListeColonneTable.getChamp(e, "direction", c) != null) {
            apresWhere = testRangUser(e, c) + apresWhere;
        }
        if (c == null) {
            return CGenUtil.rechercher(e, colInt, valInt, apresWhere);
        }
        return CGenUtil.rechercher(e, colInt, valInt, c, apresWhere);
    }

    public int getint() {
        return 0;
    }

    public String getMaxId(String table) throws Exception {
        Connection c = null;
        String retour = "---";
        try {
            c = new UtilDB().GetConn();
            java.sql.Statement sta = c.createStatement();
            java.sql.ResultSet res = sta.executeQuery("select max(id) from " + table);
            res.next();
            retour = res.getString(1);
        } catch (Exception e) {
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return retour;
    }

    public String getMaxId(String table, String[] colonne, String[] listeCritere) throws Exception {
        String retour = "----";
        int tailleCrt = listeCritere.length;
        Connection c = null;
        try {
            String temp = "select max(id) from " + table + " ";
            c = new UtilDB().GetConn();
            java.sql.Statement sta = c.createStatement();
            temp += "where " + colonne[0] + " ='" + listeCritere[0] + "'";
            // System.out.println("TY LE TEMP "+temp);
            if (tailleCrt > 1) {
                for (int i = 1; i < tailleCrt; i++) {
                    temp += " and " + colonne[i] + " = '" + listeCritere[i] + "'";
                }
            }
            java.sql.ResultSet res = sta.executeQuery(temp);
            res.next();
            retour = res.getString(1);
        } catch (Exception e) {
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return retour;
    }

    public static String getMaxColonne(String table, String colonne, String champCritere, String critere)
            throws Exception {
        String retour = "----";
        Connection c = null;
        try {
            String temp = "select max(" + colonne + ") from " + table + " where " + champCritere + "= " + critere;
            c = new UtilDB().GetConn();
            java.sql.Statement sta = c.createStatement();

            // System.out.println("TY LE TEMP "+temp);
            java.sql.ResultSet res = sta.executeQuery(temp);
            res.next();
            retour = res.getString(1);
        } catch (Exception e) {
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return retour;
    }

    public Object validerObject(ClassMAPTable o) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            Object ob = validerObject(o, c);
            c.commit();
            return ob;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public Object validerObject(ClassMAPTable o, Connection c) throws Exception {
        /*
         * if (u.getRang() < 4)
         * {
         * throw new Exception("	Erreur de droit");
         * }
         */
        try {
            return ValiderObject.validerObject(c, o, this, u, listeConfig);
        } catch (Exception ex) {
            ex.printStackTrace();
            if (c != null)
                c.rollback();
            throw ex;
        }
    }

    public Object cloturerObject(ClassMAPTable o) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            Object ob = cloturerObject(o, c);
            c.commit();
            return ob;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public void testClotureEtat(ClassMAPTable o, Connection c) throws Exception {
        try {
            String id = o.getValInsert("id");
            ClassMAPTable cl = (ClassMAPTable) Class.forName(o.getClassName()).newInstance();
            ClassMAPTable[] liste = (ClassMAPTable[]) CGenUtil.rechercher(cl, null, null, c, " and id = '" + id + "'");
            if (liste.length == 0) {
                throw new Exception("Objet inexistante");
            }
            if (o.getClass().getSuperclass().getSimpleName().compareToIgnoreCase("ClassEtat") == 0) {
                if (UtilitaireAcade.stringToInt(liste[0].getValInsert("etat")) == ConstanteEtatAcade.getEtatAnnuler()) {
                    throw new Exception("Impossible de cloturer. Objet annul?");
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
    }

    public Object cloturerObject(ClassMAPTable o, Connection c) throws Exception {
        if (testRestriction(u.getIdrole(), "ACT000008", o.getNomTable(), c) == 1) {
            throw new Exception("Erreur de droit");
        }

        testClotureEtat(o, c);
        try {
            o.setMode("modif");

            this.updateEtat(o, ConstanteEtatAcade.getEtatCloture(), o.getValInsert("id"), c);
            c.commit();
            return o;
        } catch (Exception ex) {
            ex.printStackTrace();
            throw ex;
        }
    }

    public Object rejeterObject(ClassMAPTable o) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            Object ob = rejeterObject(o, c);
            c.commit();
            return ob;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public void testRejectEtat(ClassMAPTable o, Connection c) throws Exception {
        try {
            ClassMAPTable[] liste = (ClassMAPTable[]) CGenUtil.rechercher(o, null, null, c, "");
            if (liste.length == 0) {
                throw new Exception("Objet inexistante");
            }
            if (o.getClass().getSuperclass().getSimpleName().compareToIgnoreCase("ClassEtat") == 0) {
                if (UtilitaireAcade.stringToInt(liste[0].getValInsert("etat")) == ConstanteEtatAcade.getEtatAnnuler()) {
                    throw new Exception(" Impossible de rejeter. Objet annul?");
                }
                if (UtilitaireAcade.stringToInt(liste[0].getValInsert("etat")) >= ConstanteEtatAcade.getEtatValider()) {
                    throw new Exception(" Impossible de rejeter. Objet d?j? vis?");
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
    }

    public Object rejeterObject(ClassMAPTable o, Connection c) throws Exception {
        if (testRestriction(u.getIdrole(), "ACT000007", o.getNomTable(), c) == 1) {
            throw new Exception("Erreur de droit");
        }
        testRejectEtat(o, c);
        try {
            o.setMode("modif");

            // this.updateEtat(o, ConstanteEtatAcade.getEtatRejeter(), o.getValInsert("id"),
            // c);
            c.commit();
            return o;
        } catch (Exception ex) {
            ex.printStackTrace();
            throw ex;
        }
    }

    public Object annulerObject(ClassMAPTable o) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            Object ob = annulerObject(o, c);
            c.commit();
            return ob;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public Object annulerObject(ClassMAPTable o, Connection c) throws Exception {
        if (testRestriction(u.getIdrole(), "ACT000005", o.getNomTable(), c) == 1) {
            throw new Exception("Erreur de droit");
        }
        try {
            o.setMode("modif");
            // this.updateEtat(o, ConstanteEtatAcade.getEtatAnnuler(),
            // CGenUtil.getValeurInsert(o, "id"),

            ClassEtat[] liste = (ClassEtat[]) CGenUtil.rechercher(o, null, null, c, "");
            if (liste.length == 0) {
                throw new Exception("Objet inexistante");
            }
            liste[0].annulerObject(u.getTuppleID(), c);
            // c.commit();
            return o;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        }
    }

    public void setEtat(ClassEtat o, Integer paramT) throws Exception {
        String nomChamp = "etat";
        o.setValChamp(nomChamp, paramT);
    }

    public Object createObject(ClassMAPTable o) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            o.setMode("modif");
            Object ob = createObject(o, c);
            c.commit();
            return ob;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }

    }

    public Object[] createObjectMultiple(ClassMAPTable[] o, Connection c) throws Exception {
        try {
            Object[] ret = new Object[o.length];
            for (int i = 0; i < o.length; i++) {
                ret[i] = createObject(o[i], c);
            }

            return ret;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        }

    }

    public Object[] createObjectMultiple(ClassMAPTable[] o) throws Exception {
        Connection c = null;
        Object[] ret = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            ret = createObjectMultiple(o, c);
            c.commit();
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return ret;
    }

    public void updateEtat(ClassMAPTable e, int valeurEtat, String id) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            updateEtat(e, valeurEtat, id, c);
            c.commit();
        } catch (Exception ex) {
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public void updateEtat(ClassMAPTable e, int valeurEtat, String id, String colid) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            updateEtat(e, valeurEtat, id, c, colid);
            c.commit();
        } catch (Exception ex) {
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public void updateEtat(ClassMAPTable e, int valeurEtat, String id, Connection c, String colid) throws Exception {
        Statement cmd = null;
        try {
            ClassMAPTable[] lobj = (ClassMAPTable[]) CGenUtil.rechercher(e, null, null, c,
                    String.format(" and upper(" + colid + ") like upper('%s') ", id));
            if (lobj.length == 0) {
                throw new Exception("Il n y a de donnees correspondants a cet id");
            }
            ClassMAPTable obj = lobj[0];
            obj.setValChamp("etat", valeurEtat);
            obj.controlerUpdate(c);
            String req = "update " + e.getNomTable() + " set etat='" + valeurEtat + "' where " + colid + " = '" + id
                    + "'";
            System.out.println(req);
            cmd = c.createStatement();
            cmd.executeUpdate(req);

            System.out.println("============shqfsgfq: " + req);
        } catch (Exception ex) {
            throw ex;
        } finally {
            if (cmd != null) {
                cmd.close();
            }
        }
    }

    public void updateEtat(ClassMAPTable e, int valeurEtat, String id, Connection c) throws Exception {
        Statement cmd = null;
        try {
            ClassMAPTable[] lobj = (ClassMAPTable[]) CGenUtil.rechercher(e, null, null, c,
                    String.format(" and upper(id) like upper('%s') ", id));
            if (lobj.length == 0) {
                throw new Exception("Il n y a de donnees correspondants a cet id");
            }
            ClassMAPTable obj = lobj[0];
            obj.setValChamp("etat", valeurEtat);
            obj.controlerUpdate(c);
            String req = "update " + e.getNomTable() + " set etat='" + valeurEtat + "' where id = '" + id + "'";
            cmd = c.createStatement();
            cmd.executeUpdate(req);

            System.out.println("============shqfsgfq: " + req);
        } catch (Exception ex) {
            throw ex;
        } finally {
            if (cmd != null) {
                cmd.close();
            }
        }
    }

    public int validerObjectMultiple(ClassEtat[] o, Connection c) throws Exception {
        try {
            for (int i = 0; i < o.length; i++) {
                ClassEtat map = ((ClassEtat[]) CGenUtil.rechercher(o[i], null, null, c, ""))[0];
                map.setMode("modif");
                setEtat(map, ConstanteEtatAcade.getEtatValider());
                map.updateToTableWithHisto(u.getTuppleID(), c);
            }
            return 1;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }

    public int viserObjectMultiple(ClassEtat o, String[] listeIdObjet, Connection c) throws Exception {
        try {

            String script = UtilitaireAcade.tabToString(listeIdObjet, "'", ",");
            String apw = " and " + o.getAttributIDName() + " in (" + script + " )";
            ClassEtat[] mapTableListe = (ClassEtat[]) CGenUtil.rechercher(o, null, null, c, apw);
            for (int i = 0; i < mapTableListe.length; i++) {
                mapTableListe[i].setMode("modif");
                mapTableListe[i].setNomTable(o.getNomTable());
                this.validerObject(mapTableListe[i], c);
            }
            return 1;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }

    public void notifierObjectMultiple(String[] ids, String classe) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            String idString = UtilitaireAcade.tabToString(ids, "'", ",");
            String where = " AND ID IN (" + idString + ")";

            c.commit();
        } catch (Exception e) {
            e.printStackTrace();
            if (c != null) {
                c.rollback();
            }
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public int viserObjectMultiple(ClassEtat o, String[] listeIdObjet) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            System.out.println("Tafiditra fct 1");
            int r = viserObjectMultiple(o, listeIdObjet, c);
            c.commit();
            return r;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    @Override
    public int retournerObjectMultiple(ClassEtat o, String[] listeIdObjet, String motif) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            int r = retournerObjectMultiple(o, listeIdObjet, motif, c);
            c.commit();
            return r;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    @Override
    public int recuObjectMultiple(ClassEtat o, String[] listeIdObjet) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            int r = recuObjectMultiple(o, listeIdObjet, c);
            c.commit();
            return r;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public int recuObjectMultiple(ClassEtat o, String[] listeIdObjet, Connection c) throws Exception {
        try {

            String script = UtilitaireAcade.tabToString(listeIdObjet, "'", ",");
            String apw = " and " + o.getAttributIDName() + " in (" + script + " )";

        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }

    public int retournerObjectMultiple(ClassEtat o, String[] listeIdObjet, String motif, Connection c)
            throws Exception {
        try {

            String script = UtilitaireAcade.tabToString(listeIdObjet, "'", ",");
            String apw = " and " + o.getAttributIDName() + " in (" + script + " )";

        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }

    public int rejeterObjectMultiple(ClassEtat o, String[] listeIdObjet, Connection c, String nomTableRejet,
            String nomTableCategorieRejet) throws Exception {
        try {
            String script = UtilitaireAcade.tabToString(listeIdObjet, "'", ",");
            ClassEtat[] mapTableListe = (ClassEtat[]) CGenUtil.rechercher(o, null, null, c,
                    " and upper(" + o.getAttributIDName() + ") in (" + script + " )");
            if (mapTableListe != null
                    && testRestriction(u.getIdrole(), "ACT000006", mapTableListe[0].getNomTable(), c) == 1) {
                throw new Exception("Erreur de droit");
            }
            TypeObjet to = new TypeObjet();
            to.setNomTable(nomTableCategorieRejet);
            TypeObjet toVal = (TypeObjet) CGenUtil.rechercher(to, null, null, c, "")[0];
            for (int i = 0; i < mapTableListe.length; i++) {
                mapTableListe[i].setMode("modif");
                // setEtat(mapTableListe[i], ConstanteEtatAcade.getEtatObjetRejeter());
                mapTableListe[i].updateToTableWithHisto(u.getTuppleID(), c);
                RejetTable rejet = new RejetTable(UtilitaireAcade.dateDuJourSql(), "rejet multiple", listeIdObjet[i],
                        "rejet multiple", toVal.getId());
                rejet.setNomTable(nomTableRejet);
                this.createObject(rejet, c);
            }
            return 1;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }

    public int rejeterObjectMultiple(ClassEtat o, String[] listeIdObjet, String nomTableRejet,
            String nomTableCategorieRejet) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            int r = rejeterObjectMultiple(o, listeIdObjet, c, nomTableRejet, nomTableCategorieRejet);
            c.commit();
            return r;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public int validerObjectMultiple(ClassEtat[] o) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            int r = validerObjectMultiple(o, c);
            c.commit();
            return r;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public String genererEnfantMatricule(String motherName, String sexe, Date dateNaissance, String nationalite,
            String numActe) throws Exception {
        try {
            System.out.println("----------------------motherName = " + motherName);
            String anneeDeNaissance = UtilitaireAcade.getAnnee(dateNaissance) + "";
            int moisDeNaissance = UtilitaireAcade.getMois(dateNaissance);
            String jour = UtilitaireAcade.getJour(UtilitaireAcade.datetostring(dateNaissance));

            String premierChiffreAnnee = anneeDeNaissance.substring(0, 1);
            String rangMoisLettre = "";
            String millenismeAnnee = anneeDeNaissance.substring(2, 4);
            int rangMoisNaissance;
            int rangJourNaissance;

            if (sexe.compareToIgnoreCase("0") == 0) { // 1989
                rangMoisLettre = UtilitaireAcade.getRangMoisLettre(moisDeNaissance + 12);
            } else {
                rangMoisLettre = UtilitaireAcade.getRangMoisLettre(moisDeNaissance);
            }

            if (nationalite.compareToIgnoreCase("1") == 0) { // 1989
                rangJourNaissance = Integer.parseInt(jour) + 40;
            } else {
                rangJourNaissance = Integer.parseInt(jour);
            }

            // System.out.println("premierChiffreAnnee == " + premierChiffreAnnee +
            // "millenismeAnnee = " + millenismeAnnee + " rangMoisLettre = " +
            // rangMoisLettre + " rangJourNaissance = " + rangJourNaissance + " numActe = "
            // + numActe);
            // System.out.println(premierChiffreAnnee + "" + millenismeAnnee + "" +
            // rangMoisLettre + "" + rangJourNaissance + "" + numActe);
            String temp = premierChiffreAnnee + "" + millenismeAnnee + "" + rangMoisLettre + ""
                    + String.format("%02d", rangJourNaissance) + "" + numActe;
            // cryptage du mere

            // dechifrer
            double nom_dechiffrer = UtilitaireAcade.dechiffrer(motherName);

            // System.out.println(" dechiffrement ========= " + nom_dechiffrer);
            String val_hex_nom = UtilitaireAcade.completerInt(6, (int) nom_dechiffrer);

            System.out.println(" valeur hexa ========= " + val_hex_nom);

            temp += val_hex_nom;
            return temp;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return "";
    }

    public String genererTravailleurMatricule(String idTravailleur, String sexe, Date dateNaissance) throws Exception {
        try {
            String anneeDeNaissance = UtilitaireAcade.getAnnee(dateNaissance) + "";
            int moisDeNaissance = UtilitaireAcade.getMois(dateNaissance);
            String jour = UtilitaireAcade.getJour(UtilitaireAcade.datetostring(dateNaissance));

            String millenismeAnnee = anneeDeNaissance.substring(2, 4);
            int rangMoisNaissance;
            int rangJourNaissance = Integer.parseInt(jour);
            String numeroSequence = idTravailleur.substring(6, 10);

            if (sexe.compareToIgnoreCase("0") == 0) { // 1989
                rangMoisNaissance = moisDeNaissance + 20;
            } else {
                rangMoisNaissance = moisDeNaissance;
            }

            rangMoisNaissance = Integer.parseInt(String.format("%02d", rangMoisNaissance));

            String numTemp = millenismeAnnee + "" + rangMoisNaissance + "" + String.format("%02d", rangJourNaissance)
                    + "" + numeroSequence;

            long randumNumber = Long.parseLong(numTemp) % 97;

            // System.out.println("millenismeAnnee = " + millenismeAnnee + "
            // rangMoisNaissance = " + rangMoisNaissance + " rangJourNaissance = " +
            // rangJourNaissance + " numeroSequence = " + numeroSequence + " randumNumber =
            // " + randumNumber);
            numTemp += randumNumber + "";

            return numTemp;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return "";
    }

    public Object finaliser(ClassMAPTable o, Connection c) throws Exception {
        try {
            o.setMode("modif");
            this.updateEtat(o, ConstanteEtatAcade.getConstanteEtatFinaliser(), o.getTuppleID(), c);

        } catch (Exception ex) {
            ex.printStackTrace();
            throw ex;
        }
        return null;
    }

    public Object finaliser(ClassMAPTable map) throws Exception {
        Connection c = null;
        try {
            c = (new UtilDB()).GetConn();
            Object ret = finaliser(map, c);
            // c.commit();
            return ret;
        } catch (Exception ex) {
            ex.printStackTrace();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public Object createObject(ClassMAPTable o, Connection c) throws Exception {
        /*
         * if (testRestriction(u.getIdrole(), "ACT000001", o.getNomTable(), c) == 1) {
         * throw new Exception("Erreur de droit");
         * }
         */
        try {
            return CreateObject.createObject(o, c, u, this, listeConfig);
        } catch (Exception ex) {
            ex.printStackTrace();
            if (c != null)
                c.rollback();
            throw ex;
        }
    }

    public Object updateObject(ClassMAPTable o) throws Exception {
        Connection c = null;

        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            o.setMode("modif");
            updateObject(o, c);
            c.commit();
            return o;
        } catch (Exception ex) {
            c.rollback();
            ex.printStackTrace();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public void testUpdate(ClassMAPTable o, Connection c) throws Exception {
        try {
            if (o.getClass().getSuperclass().getSimpleName().compareToIgnoreCase("ClassEtat") == 0) {
                String id = o.getValInsert("id");
                System.out.println("affichage id : " + id);
                ClassMAPTable cl = (ClassMAPTable) Class.forName(o.getClassName()).newInstance();
                ClassMAPTable[] liste = (ClassMAPTable[]) CGenUtil.rechercher(cl, null, null, c,
                        " and id = '" + id + "'");
                if (UtilitaireAcade.stringToInt(liste[0].getValInsert("etat")) == ConstanteEtatAcade.getEtatAnnuler()) {
                    throw new Exception(" Impossible de modifier. Objet annul?");
                }
                if (UtilitaireAcade.stringToInt(liste[0].getValInsert("etat")) >= ConstanteEtatAcade.getEtatValider()) {
                    // throw new Exception(" Impossible de modifier. Objet d�j� vis�");
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    public Object updateObject(ClassMAPTable o, Connection c) throws Exception {
        // Connection c=null;
        // System.out.println("ato updateObject");
        if (testRestriction(u.getIdrole(), ConstanteUtilisateur.acteUpdate, o.getNomTable(), c) == 1) {
            throw new Exception("Erreur de droit");
        }
        testUpdate(o, c);
        try {
            return UpdateObject.updateObject(o, c, u, this);
        } catch (Exception ex) {
            c.rollback();
            ex.printStackTrace();
            throw ex;
        }

    }

    public void testDelete(ClassMAPTable o, Connection c) throws Exception {
        try {
            // System.out.println("miditra delete");
            if (o.getClass().getSuperclass().getSimpleName().compareToIgnoreCase("ClassEtat") == 0) {
                String id = o.getValInsert("id");
                ClassMAPTable[] liste = (ClassMAPTable[]) CGenUtil.rechercher(o, null, null, c, "");
                // System.out.println("ffffffffffffffffffffff=="+liste[0].getValInsert("etat"));
                if (liste.length == 0) {
                    throw new Exception("Objet inexistant");
                }
                if (UtilitaireAcade.stringToInt(liste[0].getValInsert("etat")) >= ConstanteEtatAcade.getEtatValider()) {
                    throw new Exception("Impossible de supprimer. Objet d?j? vis?");
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    public void deleteObjetFille(ClassMAPTable o) throws Exception {
        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);
            deleteObjetFille(o, conn);
            conn.commit();
        } catch (Exception ex) {
            if (conn != null) {
                conn.rollback();
            }
            ex.printStackTrace();
            throw ex;
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
    }

    public void deleteObjetFille(ClassMAPTable o, Connection conn) throws Exception {
        try {
            o.deleteToTableWithHisto(u.getTuppleID(), conn);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void deleteObject(ClassMAPTable o) throws Exception {
        Connection c = null;
        try {
            /*
             * if (u.isSuperUser() == false) { throw new Exception("Pas de
             * droit"); }
             */
            c = new UtilDB().GetConn();
            boolean defaultDelete = true;
            c.setAutoCommit(false);
            // testFk(o, c);
            if (testRestriction(u.getIdrole(), "ACT000003", o.getNomTable(), c) == 1) {
                throw new Exception("Erreur de droit");
            }
            testDelete(o, c);
            ClassMAPTable[] liste = (ClassMAPTable[]) CGenUtil.rechercher(o, null, null, c, "");
            if (liste.length > 0) {
                if (defaultDelete) {
                    liste[0].deleteToTableWithHisto(u.getTuppleID(), c);
                }
            } else {
                throw new Exception("Erreur durant la suppression, Objet introuvable");
            }

            c.commit();
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        } catch (Exception ex) {
            if (c != null) {
                c.rollback();
            }
            ex.printStackTrace();
            System.out.println("tokony hisy alert");
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    @Override
    public void updateOneColonneMultiple(String nomTable, String colonne, String colonneCritere, String[] valeurCritere,
            Object valeur) throws Exception {
        Connection c = null;
        Object ret = null;
        System.out.println("-tafiditra updateOneColonneMultiple");
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            for (int i = 0; i < valeurCritere.length; i++) {
                System.out.println("-ato");
                System.out.println(nomTable);
                System.out.println(colonne);
                System.out.println(colonneCritere);
                System.out.println(valeurCritere[i]);
                System.out.println(valeur);
                System.out.println("-anomboka update");
                updateOneColonneGen(nomTable, colonne, colonneCritere, valeurCritere[i], valeur, c);
                System.out.println("-fin update");
            }
            c.commit();
            System.out.println("-apresc$ commit");
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public void updateOneColonneGen(String nomTable, String colonne, String colonneCritere, String valeurCritere,
            Object valeur, Connection c) throws Exception {
        PreparedStatement pst = null;
        try {
            String sql = "UPDATE " + nomTable + " SET " + colonne + "=? WHERE " + colonneCritere + "=?";
            pst = c.prepareStatement(sql);
            System.out.println("type " + valeur.getClass().getName());
            if (valeur.getClass().getName().compareToIgnoreCase("java.lang.String") == 0) {
                pst.setString(1, (String) valeur);
            }
            if (valeur.getClass().getName().compareToIgnoreCase("java.sql.Date") == 0) {
                pst.setDate(1, (java.sql.Date) valeur);
            }
            if (valeur.getClass().getName().compareToIgnoreCase("double") == 0) {
                pst.setDouble(1, ((Double) valeur).doubleValue());
            }
            if (valeur.getClass().getName().compareToIgnoreCase("int") == 0) {
                pst.setInt(1, ((Integer) valeur).intValue());
            }
            if (valeur.getClass().getName().compareToIgnoreCase("java.lang.Integer") == 0) {
                pst.setInt(1, ((Integer) valeur).intValue());
            }
            pst.setString(2, valeurCritere);
            pst.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (pst != null) {
                pst.close();
            }
        }
    }

    public void updateOneColonne(String nomTable, String colonne, String colonneCritere, String valeurCritere,
            String valeur, Connection c) throws Exception {
        PreparedStatement pst = null;
        try {
            String sql = "UPDATE " + nomTable + " SET " + colonne + "=? WHERE " + colonneCritere + "=?";
            pst = c.prepareStatement(sql);
            pst.setString(1, valeur);
            pst.setString(2, valeurCritere);
            pst.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (pst != null) {
                pst.close();
            }
        }
    }

    public boolean isSuperUser() {
        return u.isSuperUser();
    }

    @Override
    public int testRestriction(String user, String permission, String table, Connection con) throws Exception {
        try {
            GestionRole g = new GestionRole();
            return g.testRestriction(user, permission, table, u.getAdruser(), con);
        } catch (Exception ex) {
            ex.printStackTrace();
            throw ex;
        }
    }

    @Override
    public String[] getAllTable() throws Exception {
        Connection con = null;
        try {
            con = new UtilDB().GetConn();
            GestionRole g = new GestionRole();
            return g.getAllTAble(con);
        } catch (Exception e) {
            throw e;
        } finally {
            if (con != null) {
                con.close();
            }
        }
    }

    @Override
    public void ajoutrestriction(String[] val, String idrole, String act, String direc) throws Exception {
        Connection con = null;
        try {
            con = new UtilDB().GetConn();
            ajoutrestriction(val, idrole, act, direc, con);
            con.commit();
        } catch (Exception e) {
            con.rollback();
            throw e;
        } finally {
            if (con != null) {
                con.close();
            }
        }
    }

    @Override
    public void ajoutrestriction(String[] val, String idrole, String act, String direc, Connection c) throws Exception {
        try {
            GestionRole g = new GestionRole();
            g.ajoutrestriction(val, idrole, act, direc, c);
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    @Override
    public config.Table[] getListeTable(String role, String adr) throws Exception {
        try {
            GestionRole g = new GestionRole();
            return g.getListeTable(role, adr);
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    @Override
    public int deletePJ(String idDossier, String idPj) throws Exception {
        return 0;
    }

    @Override
    public int deletePJ(String idDossier, String idPj, Connection con) throws Exception {
        return 0;
    }

    @Override
    public int ajouterPJInfo(String info_valeur, String pieces_id, String info_id, String info_ok) throws Exception {
        return 0;
    }

    public int ajouterPJInfo(String info_valeur, String pieces_id, String info_id, String info_ok, Connection con)
            throws Exception {
        return 0;
    }

    @Override
    public int ajouterPJTiers(String idPiece, List<String[]> listeTiers) throws Exception {
        Connection con = null;
        try {
            con = new UtilDB().GetConn();
            con.setAutoCommit(false);
            int ret = ajouterPJTiers(idPiece, listeTiers, con);
            con.commit();
            return ret;
        } catch (Exception e) {
            e.printStackTrace();
            con.rollback();
            throw e;
        } finally {
            if (con != null) {
                con.close();
            }
        }
    }

    @Override
    public int ajouterPJTiers(String idPiece, List<String[]> listeTiers, Connection con) throws Exception {

        return 1;
    }

    @Override
    public int detacherTiers(String idtiers) throws Exception {

        return -1;
    }

    @Override
    public void createUploadedPj(String nomtable, String nomprocedure, String libelle, String chemin, String mere)
            throws Exception {
        Connection con = null;
        try {
            con = new UtilDB().GetConn();
            UploadPj fichier = new UploadPj(nomtable, nomprocedure, "FLE", libelle, chemin, mere);
            fichier.construirePK(con);
            fichier.insertToTableWithHisto(u.getTuppleID(), con);
            con.commit();
        } catch (Exception ex) {
            ex.printStackTrace();
            con.rollback();
            throw ex;
        } finally {
            if (con != null) {
                con.close();
            }
        }
    }

    public Object dupliquerObject(ClassMAPTable o, String mapFille, String nomColonneMere, Connection c)
            throws Exception {
        if (testRestriction(u.getIdrole(), "ACT000010", o.getNomTable(), c) == 1) {
            throw new Exception("Erreur de droit");
        }
        try {
            o.setMode("modif");
            String id = o.getValInsert("id");

        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        }
        return null;
    }

    public Object dupliquerObject(ClassMAPTable o, String mapFille, String nomColonneMere) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            Object ob = dupliquerObject(o, mapFille, nomColonneMere, c);
            c.commit();
            return ob;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    @Override
    public void annulerVisa(ClassMAPTable o) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            this.annulerVisa(o, c);
            c.commit();
        } catch (Exception e) {
            c.rollback();
            throw e;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public void testAnnulerVisaEtat(ClassMAPTable o, Connection c) throws Exception {
        try {
            String id = o.getValInsert("id");
            ClassMAPTable cl = (ClassMAPTable) Class.forName(o.getClassName()).newInstance();
            ClassMAPTable[] liste = (ClassMAPTable[]) CGenUtil.rechercher(cl, null, null, c, " and id = '" + id + "'");
            if (liste.length == 0) {
                throw new Exception("Objet inexistante");
            }
            if (o.getClass().getSuperclass().getSimpleName().compareToIgnoreCase("ClassEtat") == 0) {
                if (UtilitaireAcade.stringToInt(liste[0].getValInsert("etat")) == ConstanteEtatAcade.getEtatCreer()) {
                    throw new Exception("Impossible d annuler, l objet n est pas vis�.");
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
    }

    public void annulerVisa(ClassMAPTable o, Connection c) throws Exception {
        try {
            if (/*
                 * testRestriction(u.getIdrole(), "ACT000009",
                 * o.getNomTable(), c) == 1
                 */u.getRang() < ConstanteUser.rangDir) {
                throw new Exception("Erreur de droit");
            }
            boolean defaultVisa = true;
            testAnnulerVisaEtat(o, c);
            String id = o.getValInsert("id");
            o.setValChamp("id", id);
            ClassMAPTable[] liste = (ClassMAPTable[]) CGenUtil.rechercher(o, null, null, c, "");
            // Control avant update

            // Update etat
            if (defaultVisa) {
                this.updateEtat(o, ConstanteEtatAcade.getEtatCreer(), id, c);
            }

        } catch (Exception e) {
            throw e;
        }
    }

    public String mapperMereToFilleMetier(String nomtableMappage, String nomProcedure, String suffixeMap, String idMere,
            String[] idFille, String rem, String montant, String etat, Connection c) throws Exception {
        try {
            for (int i = 0; i < idFille.length; i++) {
                UtilitaireMetier.mapperMereToFilleMetier(nomtableMappage, nomProcedure, suffixeMap, idMere, idFille[i],
                        rem, montant, u.getTuppleID(), etat, c);
            }
        } catch (Exception e) {
            throw e;
        }
        return null;
    }

    @Override
    public String mapperMereToFilleMetier(ClassMAPTable e, String nomTable, String idMere, String[] idFille, String rem,
            String montant, String etat) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            String nomProcedure = "getSeq" + UtilitaireAcade.convertDebutMajuscule(nomTable);
            String indicePK = nomTable.substring(0, 3).toUpperCase();

            mapperMereToFilleMetier(nomTable, nomProcedure, indicePK, idMere, idFille, rem, montant, etat, c);
            c.commit();
        } catch (Exception ex) {
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return null;
    }

    @Override
    public String mapperMereToFilleMetier(ClassMAPTable e, String idMere, String[] idFille, String rem, String montant,
            String etat) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            mapperMereToFilleMetier(e.getNomTable(), e.getNomProcedureSequence(), e.getINDICE_PK(), idMere, idFille,
                    rem, montant, etat, c);
            c.commit();
        } catch (Exception ex) {
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return null;
    }

    public Object[] createObjectMultiple(ClassMAPTable[] o, String colonneMere, String idmere, Connection c)
            throws Exception {
        try {
            Object[] ret = new Object[o.length];
            for (int i = 0; i < o.length; i++) {
                o[i].setValChamp(colonneMere, idmere);
                ret[i] = createObject(o[i], c);
            }
            return ret;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        }

    }

    @Override
    public Object createObjectMultiple(ClassMAPTable mere, String colonneMere, ClassMAPTable[] fille) throws Exception {
        Connection c = null;
        Object ret = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            Object idmere = createObject(mere, c);
            System.out.println(" ((ClassMAPTable)idmere).getTuppleID() === " + ((ClassMAPTable) idmere).getTuppleID());
            ret = createObjectMultiple(fille, colonneMere, ((ClassMAPTable) idmere).getTuppleID(), c);
            ret = idmere;
            c.commit();
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return ret;
    }

    @Override
    public void createUploadedPjService(String iddossier, HashMap<String, String> listeVal, Iterator it,
            String nomtable, String nomprocedure, String mere) throws Exception {
        try {
            service.UploadService.createUploadedPj(iddossier, u.getTuppleID(), listeVal, it, nomtable, nomprocedure,
                    mere);
        } catch (Exception ex) {
            ex.printStackTrace();
            throw ex;
        }
    }

    @Override
    public Object createUploadedPjServiceRetour(String iddossier, HashMap<String, String> listeVal, Iterator it,
            String nomtable, String nomprocedure, String mere) throws Exception {
        try {
            Object obj = (Object) service.UploadService.createUploadedPjRetour(iddossier, u.getTuppleID(), listeVal, it,
                    nomtable, nomprocedure, mere);
            return obj;
        } catch (Exception ex) {
            ex.printStackTrace();
            throw ex;
        }
    }

    @Override
    public void deleteUploadedPj(String nomtable, String id) throws Exception {
        Connection con = null;
        try {
            con = new UtilDB().GetConn();
            con.setAutoCommit(false);
            UploadPj up = new UploadPj(nomtable);
            UploadPj[] fichiers = (UploadPj[]) CGenUtil.rechercher(up, null, null, con, " AND ID = '" + id + "'");
            UtilitaireAcade.deleteFileFromCdn(fichiers[0].getChemin());
            MapHistorique h = new MapHistorique(nomtable, "delete", u.getTuppleID(), id);
            h.setObjet("bean.UploadPj");
            fichiers[0].deleteToTable(con);
            con.commit();
        } catch (Exception ex) {
            ex.printStackTrace();
            con.rollback();
            throw ex;
        } finally {
            if (con != null) {
                con.close();
            }
        }
    }

    public Object updateObjectSansTest(ClassMAPTable o) throws Exception {
        Connection c = null;

        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            o.setMode("modif");
            updateObjectSansTest(o, c);
            c.commit();
            return o;
        } catch (Exception ex) {
            c.rollback();
            ex.printStackTrace();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    public Object updateObjectSansTest(ClassMAPTable o, Connection c) throws Exception {
        try {
            return UpdateObject.updateObject(o, c, u, this);
        } catch (Exception ex) {
            c.rollback();
            ex.printStackTrace();
            throw ex;
        }

    }

    public void setDoublon(ClassEtat t) throws Exception {
        try {
            setDoublon(t, null);
        } catch (Exception exc) {
            throw exc;
        }
    }

    public void setDoublon(ClassEtat t, Connection c) throws Exception {
        int verif = 0;
        try {
            if (c == null) {
                c = new UtilDB().GetConn();
                c.setAutoCommit(false);
                verif = 1;
            }
            // this.updateEtat(t, ConstanteEtatAcade.etatDoublon, t.getValInsert("id"), c);
            if (verif == 1) {
                c.commit();
            }
        } catch (Exception exc) {
            throw exc;
        } finally {
            if (c != null & verif == 1) {
                c.close();
            }
        }
    }

    public void enAttenteMultiple(ClassMAPTable o, String nomtable, String[] id, Connection c) throws Exception {
        int verif = 0;
        try {
            if (c == null) {
                c = new UtilDB().GetConn();
                c.setAutoCommit(false);
                verif = 1;
            }
            for (String i : id) {
                this.enAttente(o, nomtable, i, c);
            }
            if (verif == 1) {
                c.commit();
            }
        } catch (Exception ex) {
            c.rollback();
            ex.printStackTrace();
            throw ex;
        } finally {
            if (c != null & verif == 1) {
                c.close();
            }
        }
    }

    public void enAttente(ClassMAPTable o, String nomtable, String id, Connection c) throws Exception {
        int verif = 0;
        try {
            if (c == null) {
                c = new UtilDB().GetConn();
                c.setAutoCommit(false);
                verif = 1;
            }
            // this.updateEtat(o, ConstanteEtatAcade.etatEnAttente, id, c);
            if (verif == 1) {
                c.commit();
            }
        } catch (Exception ex) {
            c.rollback();
            ex.printStackTrace();
            throw ex;
        } finally {
            if (c != null & verif == 1) {
                c.close();
            }
        }
    }

    public int validerObjetMereFille(ClassEtat mere, ClassEtat fille, String idmere, String nomcolonneidmere,
            Connection c) throws Exception {
        int verif = 0;
        try {
            if (c == null) {
                c = new UtilDB().GetConn();
                verif = 1;
            }
            c.setAutoCommit(false);
            int result = ValiderObject.validerObjetMultiple(mere, fille, idmere, nomcolonneidmere, c, this);
            if (verif == 1) {
                c.commit();
            }
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            c.rollback();
            throw e;
        } finally {
            if (c != null & verif == 1) {
                c.close();
            }
        }
    }

    @Override
    public ResultatEtSomme getDataPageMaxSansRecap(ClassMAPTable e, String[] colInt, String[] valInt, int numPage,
            String apresWhere, String[] nomColSomme, Connection c, int npp) throws Exception {
        e.setMode("select");
        if (ListeColonneTable.getChamp(e, "iduser", c) != null) {
            ClassUser temp = (ClassUser) e;
            apresWhere = testRangUser(e, c) + apresWhere;
        }
        // System.out.println("apres where vaovao oooo "+apresWhere+ "user vaovao
        // ooo"+u.getTuppleID());
        return CGenUtil.rechercherPageMaxSansRecap(e, colInt, valInt, numPage, apresWhere, nomColSomme, c, npp);
    }

    @Override
    public HashMap<String, String> getMapAutoComplete() {
        return mapAutoComplete;
    }

    @Override
    public void setMapAutoComplete(HashMap<String, String> mapAutoComplete) {
        this.mapAutoComplete = mapAutoComplete;
    }

    public Object[] updateObjectMultiple(ClassMAPTable[] o, Connection c) throws Exception {
        try {
            Object[] ret = new Object[o.length];
            System.out.println("o.length = " + o.length);
            for (int i = 0; i < o.length; i++) {
                ret[i] = updateObject(o[i], c);
            }
            return ret;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        }

    }

    public Object[] updateObjectMultiple(ClassMAPTable[] o) throws Exception {
        Connection c = null;
        Object[] ret = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            ret = updateObjectMultiple(o, c);
            c.commit();
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return ret;
    }

    public Object[] updateInsertObjectMultiple(ClassMAPTable[] o, Connection c) throws Exception {
        try {
            // Object[] ret = new Object[o.length];
            if (o.length == 0) {
                return null;
            }
            Object[] ret = (Object[]) java.lang.reflect.Array.newInstance(o[0].getClass().newInstance().getClass(),
                    o.length);
            for (int i = 0; i < o.length; i++) {
                if (!o[i].getTuppleID().equals("")) {
                    ret[i] = updateObject(o[i], c);
                } else {
                    ret[i] = createObject(o[i], c);
                }
            }
            return ret;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        }

    }

    @Override
    public Object[] updateInsertObjectMultiple(ClassMAPTable[] o) throws Exception {
        Connection c = null;
        Object[] ret = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            ret = updateInsertObjectMultiple(o, c);
            c.commit();
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return ret;
    }

    @Override
    public void createTypeObjetMultiple(String nomTable, String proc, String pref, String[] typ, String[] desc)
            throws Exception {
        Connection c = null;
        int verif = 0;
        try {
            if (c == null) {
                c = new UtilDB().GetConn();
                c.setAutoCommit(false);
                verif = 1;
            }
            for (int i = 0; i < typ.length; i++) {
                this.createTypeObjet(nomTable, proc, pref, typ[i], desc[i], c);
            }
        } catch (Exception e) {
            if (c != null && verif == 1) {
                c.rollback();
            }
            throw e;
        } finally {
            if (c != null && verif == 1) {
                c.close();
            }
        }
    }

    @Override
    public String createTypeObjet(String nomTable, String proc, String pref, String typ, String desc, Connection c)
            throws Exception {
        try {
            if (u.getRang() >= 4) {
                if (typ.compareTo("") == 0) {
                    throw new Exception("Le champs Libelle est obligatoire");
                }
                TypeObjet to = new TypeObjet(nomTable, proc, pref, typ, desc);
                String refuser = u.getTuppleID();
                if (refuser != null && refuser.contains("/")) {
                    String[] g = UtilitaireAcade.split(u.getTuppleID(), "/");
                    refuser = g[0];
                }

                MapHistorique histo = new MapHistorique(nomTable, "Insertion par " + u.getTuppleID(), refuser,
                        to.getId());
                histo.setObjet("bean.TypeObjet");
                to.insertToTable(histo, c);
                String s = to.getId();
                return s;
            } else {
                throw new Exception("ERREUR DE DROIT");
            }
        } catch (Exception ex) {
            throw ex;
        }
    }

    @Override
    public void deleteMultiple(String[] ids, String classe, String nomtable, Connection c) throws Exception {
        boolean connectionOuvert = false;
        try {
            if (c == null) {
                c = new UtilDB().GetConn();
                c.setAutoCommit(false);
                connectionOuvert = true;
            }
            ClassMAPTable t = null;
            for (String id : ids) {
                t = (ClassMAPTable) (Class.forName(classe).newInstance());
                t.setValChamp(t.getAttributIDName(), id);
                if (nomtable != null && !nomtable.isEmpty()) {
                    t.setNomTable(nomtable);
                }
                deleteObject(t, c);
            }
            if (connectionOuvert)
                c.commit();
        } catch (Exception e) {
            if (c != null && connectionOuvert)
                c.rollback();
            throw e;
        } finally {
            if (c != null && connectionOuvert) {
                c.close();
            }
        }
    }

    public void deleteObject(ClassMAPTable o, Connection c) throws Exception {

        try {
            /*
             * if (u.isSuperUser() == false) { throw new Exception("Pas de
             * droit"); }
             */

            boolean defaultDelete = true;
            ClassMAPTable crt = (ClassMAPTable) Class.forName(o.getClassName()).newInstance();
            crt.setTuppleId(o.getTuppleID());
            crt.setNomTable(o.getNomTable());
            o = crt;

            ClassMAPTable[] liste = (ClassMAPTable[]) CGenUtil.rechercher(o, null, null, c, "");
            if (liste.length > 0) {
                liste[0].testDelete(c);
                if (defaultDelete) {
                    crt.deleteToTableWithHisto(u.getTuppleID(), c);
                }
            } else {
                throw new Exception("Erreur durant la suppression, Objet introuvable");
            }
        } catch (Exception ex) {
            if (c != null) {
                c.rollback();
            }
            ex.printStackTrace();
            throw ex;
        }
    }

    @Override
    public Object updateObjectMultiple(ClassMAPTable mere, String colonneMere, ClassMAPTable[] fille) throws Exception {
        Connection c = null;
        Object ret = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            Object idmere = updateObject(mere, c);
            ret = updateObjectMultiple(fille, colonneMere, ((ClassMAPTable) idmere).getTuppleID(), c);
            ret = idmere;

            c.commit();
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return ret;
    }

    public Object[] updateObjectMultiple(ClassMAPTable[] o, String colonneMere, String idmere, Connection c)
            throws Exception {
        try {
            Object[] ret = new Object[o.length];
            /*
             * if(o.length>0)
             * {
             * o[0].deleteToTable(colonneMere+"='"+idmere+"'", c);
             * }
             */
            for (int i = 0; i < o.length; i++) {
                o[i].setValChamp(colonneMere, idmere);
                if (!o[i].getTuppleID().equals("")) {
                    ret[i] = updateObject(o[i], c);
                } else {
                    ret[i] = createObject(o[i], c);
                }
            }
            return ret;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        }

    }

    @Override
    public Object[] getData(ClassMAPTable e, String req, Connection c) throws Exception {
        e.setMode("select");
        return CGenUtil.rechercher(e, req, c);
    }
}
