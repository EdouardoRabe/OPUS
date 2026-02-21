// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3)
// Source File Name:   UtilitaireAcade.java
package utilitaireAcade;

import bean.CGenUtil;
import bean.ClassMAPTable;
import bean.TypeObjet;
import bean.ValeurEtiquette;
import utilitaire.Utilitaire;

import java.io.InputStream;
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.*;
import java.util.*;
//import java.time.LocalDate;
import static java.util.Calendar.DATE;
import static java.util.Calendar.MONTH;
import static java.util.Calendar.YEAR;

import java.util.concurrent.TimeUnit;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpVersion;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.InputStreamBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.CoreProtocolPNames;

public class UtilitaireAcade extends Utilitaire {

    public UtilitaireAcade() {

    }
    final static char[] listSeparator = {' ', '-', '_', ',', '/', ';'};

    public static java.sql.Time heureCouranteTime() {
        Calendar a = Calendar.getInstance();
        String retour = null;
        int hour = new Integer(completerInt(2, a.get(11))).intValue();
        int min = new Integer(completerInt(2, a.get(12))).intValue();
        int sec = new Integer(completerInt(2, a.get(13))).intValue();

        return new java.sql.Time(hour, min, sec);
    }    
    
    public static java.util.Date convertToUtilDate(java.sql.Date daty,java.sql.Time temps){
        java.util.Date dd = new java.util.Date(daty.getTime());
        dd.setHours(temps.getHours());
        dd.setMinutes(temps.getMinutes());
        dd.setSeconds(temps.getSeconds());
        return dd;
    }

    public static String nettoyerNomFichier(String input) {
        // Supprimer les accents (é → e)
        String normalized = Normalizer.normalize(input, Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "");

        // Supprimer ou remplacer les caractères spéciaux
        StringBuilder sb = new StringBuilder();
        for (char c : normalized.toCharArray()) {
            if (Character.isLetterOrDigit(c) || c == '_' || c == '-') {
                sb.append(c);
            } else {
                sb.append('_');
            }
        }

        return sb.toString();
    }

    public static String toHtmlInputDateValue(Date date) {
        if (date == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(date);
    }

    public static String getTodayAsHtmlInputDate() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(new Date(System.currentTimeMillis()));
    }

    public static boolean estHeureFormat(String heure) {
        if (heure == null || heure.trim().isEmpty()) {
            return false;
        }

        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
        sdf.setLenient(false);

        try {
            sdf.parse(heure);
            return true;
        } catch (ParseException e) {
            return false;
        }
    }


//     public static String genererChampReturnMultiple(String champRet, int numeroLingne){
//         String[] retTab = champRet.split(";");
//         String retour = "";
//         for(int i = 0; i < retTab.length; i++){
//             retour += retTab[i] + "_" + numeroLingne + ";";
//         }
//         return retour;
//     }
//      public static int doubleToInt(String s) {
//         Double d = new Double(s);
//         int i = d.intValue();
//         return i;
//     }
//     public static String[] formerTableauGroupe(String[] val) throws Exception {
//         String retour[] = null;
//         Vector r = new Vector();
//         for (int i = 0; i < val.length; i++) {
//             if (val[i] != null && val[i].compareToIgnoreCase("") != 0 && val[i].compareToIgnoreCase("-") != 0) {
//                 r.add(val[i]);
//             }
//         }
//         if (r.size() > 0) {
//             retour = new String[r.size()];
//             r.copyInto(retour);
//         }
//         return retour;
//     }

// //    public double calculAppoint(double montant) throws Exception {
// //        double[] ret = new double[2];
// //        try{
// //            
// //        }catch(Exception ex){
// //            ex.printStackTrace();
// //            throw new Exception(ex.getMessage());
// //        }
// //    }
//     public static int getNumeroPage(int indice, int n) {
//         int k = 1;
//         while (k > 0) {
//             if (indice < k * n) {
//                 return k + 1;
//             }
//             k++;
//         }
//         return 2;
//     }

//     public static int genererNouveauNumero(int indice, int n) {
//         int k = 1;
//         while (k > 0) {
//             if (indice < k * n) {
//                 return k * n + 2;
//             }
//             k++;
//         }
//         return 2;
//     }

//     public static String getRangMoisLettre(int rangMois) {
//         String[] r = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
//         return r[rangMois - 1];
//     }

//     public static String findSeparator(String text) {
//         String ret = " ";
//         for (int i = 0; i < text.length(); i++) {
//             if (isSeparator(text.charAt(i))) {
//                 ret = text.charAt(i) + "";
//             }
//         }
//         return ret;
//     }

//     public static boolean isSeparator(char caractere) {
//         for (int k = 0; k < listSeparator.length; k++) {
//             if (caractere == listSeparator[k]) {
//                 return true;
//             }
//         }
//         return false;
//     }

//     public static int valeurCharEnChiffre(String caract) {
//         String[] r = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", " ", "-", "\""};

//         for (int i = 0; i < r.length; i++) {
//             if (caract.compareToIgnoreCase(caract) == 0) {
//                 return i + 1;
//             }
//         }
//         return 30;
//     }

//     public static String getAnneeEnCours() {
//         String daty = UtilitaireAcade.dateDuJour();
//         String an = UtilitaireAcade.getAnnee(daty);
//         return an;
//     }
    public static String formatDate(Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat("dd MMMM yyyy", Locale.FRANCE);
        return sdf.format(date);
    }
    
//     public static String getParametreAnnee(){
//         Connection conn = null;
//         try{
//             conn = (new UtilDB()).GetConn();
//             TypeObjet o = new TypeObjet();
//             o.setNomTable("configuration");
//             TypeObjet[] list = (TypeObjet[])CGenUtil.rechercher(o, null, null, conn, " AND ID = 'PRM00001'");
//             if(list != null && list.length != 0){
//                 return list[0].getVal();
//             } 
//         } catch(Exception ex){
//             ex.printStackTrace();
//         } finally {
//             if(conn != null){
//                 try{
//                     conn.close();
//                 } catch(Exception e){
//                     e.printStackTrace();
//                 }
//             }
//         }
//         return getAnneeEnCours();
//     }

//     public static String secondesToTime(int msecondes) {
//         int secondes = 0;
//         int minutes = 0;
//         int heures = 0;

//         secondes = msecondes % 60;
//         msecondes = msecondes / 60;
//         minutes = msecondes % 60;
//         msecondes = msecondes / 60;
//         heures = msecondes;
//         return heures + ":" + minutes + ":" + secondes;
//     }

//     public static int timeToMillisecondes(String time) {

//         int secondes = 0;
//         int minutesMS = 0;
//         int heuresMS = 0;

//         int sec = 0;
//         if (time != null || time.compareToIgnoreCase("") != 0) {
//             String[] splt = time.split(":");
//             if (splt.length > 2) {
//                 secondes = stringToInt(splt[2]);
//                 minutesMS = stringToInt(splt[1]) * 60;
//                 heuresMS = stringToInt(splt[0]) * 3600;
//             } else {
//                 minutesMS = stringToInt(splt[1]) * 60;
//                 heuresMS = stringToInt(splt[0]) * 3600;
//             }

//             sec = secondes + minutesMS + heuresMS;
//         }
//         return sec;
//     }

//     public static int diffDeuxheures(String heuredebut, int seconde) {
//         //une fonction qui calcule la difference de deux heures en secondes
//         int result = 0;

//         String[] debut = split(heuredebut, ":");

//         int hmsd = UtilitaireAcade.stringToInt(debut[0]) * 3600;
//         int mmsd = UtilitaireAcade.stringToInt(debut[1]) * 60;

//         result = (hmsd + mmsd) + seconde;
//         return result;
//     }

//     public static int diffDeuxheures(String heuredebut, String heurefin) {
//         //une fonction qui calcule la difference de deux heures en secondes
//         int result = 0;

//         String[] debut = split(heuredebut, ":");
//         String[] fin = split(heurefin, ":");

//         int hmsd = UtilitaireAcade.stringToInt(debut[0]) * 3600;
//         int mmsd = UtilitaireAcade.stringToInt(debut[1]) * 60;

//         int hmsf = UtilitaireAcade.stringToInt(fin[0]) * 3600;
//         int mmsf = UtilitaireAcade.stringToInt(fin[1]) * 60;

//         result = (hmsf + mmsf) - (hmsd + mmsd);
//         return result;
//     }

//     public static double dechiffrer(String caractere) {
//         int var_long;
//         String var_car_act = "";
//         int var_val_act;
//         int var_coeff;
//         double var_total = 0;
//         String temp = caractere.trim();
//         var_long = temp.length();

//         for (int i = 0; i < var_long; i++) {
//             var_car_act = temp.substring(i, (i + 1));
//             var_val_act = valeurCharEnChiffre(var_car_act);
//             var_coeff = var_long - i;
//             var_total += var_coeff * var_val_act;
//         }

//         return var_total * var_long;
//     }

//     public static java.util.Date convertFromSQLDateToUtilDate(java.sql.Date sqlDate) {
//         java.util.Date javaDate = null;
//         if (sqlDate != null) {
//             javaDate = new Date(sqlDate.getTime());
//         }
//         return javaDate;
//     }

//     public static String getLastDayOfDate(String daty) {
//         String ret = "";
//         try {
//             Date dt = stringDate(daty);
//             ret = getLastDayOfDate(dt);
//         } catch (Exception ex) {
//             ex.printStackTrace();
//         }
//         return ret;
//     }

//     public static int getTrimestre(java.sql.Date d) {
//         int month = d.getMonth();
//         //System.out.println("month="+month);
//         int reste = (month + 1) % 3;
//         if (reste != 0) {
//             //System.out.println("1="+((month + 1) / 3) + 1);
//             return (((month + 1) / 3) + 1);
//         }
//         if (reste == 0) {
//             //System.out.println("2="+(month + 1) / 3);
//             return ((month + 1) / 3);
//         }
//         return 0;
//     }

//     public static String getDateFinAPartirTrimestre(int trimestre, int annee) {
//         int mois = trimestre * 3;
//         if (mois == 12) {
//             return "31/" + mois + "/" + annee;
//         }
//         if (mois == 9) {
//             return "30/" + mois + "/" + annee;
//         }
//         if (mois == 6) {
//             return "30/" + mois + "/" + annee;
//         }
//         if (mois == 3) {
//             return "31/" + mois + "/" + annee;
//         }
//         return "";
//     }

//     public static Date getLastDateInTrimestre(java.sql.Date d) {
//         if (d.after(stringDate("01/01/" + getAnnee(d))) && d.before(stringDate("31/03/" + getAnnee(d)))) {
//             d = stringDate("31/03/" + getAnnee(d));
//         }
//         if (d.after(stringDate("01/04/" + getAnnee(d))) && d.before(stringDate("30/06/" + getAnnee(d)))) {
//             d = stringDate("30/06/" + getAnnee(d));
//         }
//         if (d.after(stringDate("01/07/" + getAnnee(d))) && d.before(stringDate("30/09/" + getAnnee(d)))) {
//             d = stringDate("30/09/" + getAnnee(d));
//         }
//         if (d.after(stringDate("01/10/" + getAnnee(d))) && d.before(stringDate("31/12/" + getAnnee(d)))) {
//             d = stringDate("31/12/" + getAnnee(d));
//         }
//         return d;
//     }

//     public static String getTrimestreAnnee(java.sql.Date d, String separateur) {
//         int trim = getTrimestre(d);
//         int annee = getAnnee(d);
//         return trim + separateur + annee;
//     }

//     public static String getLastDateInTrimestre(String trimAnnee, String separateur) {
//         String[] g = split(trimAnnee, separateur);
//         return getDateFinAPartirTrimestre(stringToInt(g[0]), stringToInt(g[1]));
//     }

//     public static int getLastJourInMonth(int year, int month, int day) {
//         Calendar calendar = Calendar.getInstance();
//         calendar.set(year, month, day);
//         int maxDay = calendar.getActualMaximum(Calendar.DAY_OF_MONTH);
//         return maxDay;
//     }

//     public static int getLastJourInMonth(java.sql.Date d) {
//         int year = d.getYear() + 1900;
//         int month = d.getMonth();
//         int day = d.getDate();
//         return getLastJourInMonth(year, month, day);
//     }

//     public static int dayOfDate(Date daty) {

//         Calendar cal = Calendar.getInstance();
//         cal.setTime(daty);
//         int day = cal.get(Calendar.DAY_OF_WEEK);

// //        switch (day) {
// //            case 1:
// //                return "Dimanche";
// //            case 2:
// //                return "Lundi";
// //            case 3:
// //                return "Mardi";
// //            case 4:
// //                return "Mercredi";
// //            case 5:
// //                return "Jeudi";
// //            case 6:
// //                return "Vendredi";
// //            case 7:
// //                return "Samedi";
// //        }
//         return day;
//     }

//     public static String getJourDate(Date daty) {

//         Calendar cal = Calendar.getInstance();
//         cal.setTime(daty);
//         int day = cal.get(Calendar.DAY_OF_WEEK);

//         switch (day) {
//             case 1:
//                 return "Dimanche";
//             case 2:
//                 return "Lundi";
//             case 3:
//                 return "Mardi";
//             case 4:
//                 return "Mercredi";
//             case 5:
//                 return "Jeudi";
//             case 6:
//                 return "Vendredi";
//             case 7:
//                 return "Samedi";
//         }
//         return null;
//     }

//     public static String getLastDayOfDate(Date daty) {
//         String ret = "";
//         try {
//             java.util.Date dt = convertFromSQLDateToUtilDate(daty);

//             Calendar calendar = Calendar.getInstance();
//             calendar.setTime(dt);

//             calendar.add(Calendar.MONTH, 1);
//             calendar.set(Calendar.DAY_OF_MONTH, 1);
//             calendar.add(Calendar.DATE, -1);
//             java.util.Date lastDayOfMonth = calendar.getTime();
//             java.text.DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//             // System.out.println("Date            : " + sdf.format(dt));
//             //System.out.println("Last Day of Month: " + sdf.format(lastDayOfMonth));

//             return sdf.format(lastDayOfMonth);
//         } catch (Exception ex) {
//             ex.printStackTrace();
//         }
//         return ret;
//     }

//     public static java.sql.Date getLastDayOfDateSQL(Date daty) {
//         java.sql.Date ret = null;
//         try {
//             java.util.Date dt = convertFromSQLDateToUtilDate(daty);

//             Calendar calendar = Calendar.getInstance();
//             calendar.setTime(dt);

//             calendar.add(Calendar.MONTH, 1);
//             calendar.set(Calendar.DAY_OF_MONTH, 1);
//             calendar.add(Calendar.DATE, -1);
//             java.util.Date lastDayOfMonth = calendar.getTime();
//             ret = new java.sql.Date(lastDayOfMonth.getTime());
//             return ret;
//         } catch (Exception ex) {
//             ex.printStackTrace();
//         }
//         return ret;
//     }

//     public static int getMillenismeAnnee(String annee) {
//         return stringToInt(annee.substring(2));
//     }

//     public static String decimalToHexa(double number) {
//         int puissance = 1;
//         String petit_hexa = "";
//         String val_prov;
//         double nombre_dec1;

//         while (1 < 2) {
//             if (number / (Math.pow(16, puissance)) >= 16) {
//                 puissance++;
//             } else {
//                 break;
//             }
//         }

//         nombre_dec1 = number;
//         while (1 < 2) {

//             double temp = nombre_dec1 / (Math.pow(16, puissance));
//             val_prov = String.valueOf(temp);
//             nombre_dec1 = number % (Math.pow(16, puissance));

//             if (val_prov.compareToIgnoreCase("10") == 0) {
//                 val_prov = "A";
//             } else if (val_prov.compareToIgnoreCase("11") == 0) {
//                 val_prov = "B";
//             } else if (val_prov.compareToIgnoreCase("12") == 0) {
//                 val_prov = "C";
//             } else if (val_prov.compareToIgnoreCase("13") == 0) {
//                 val_prov = "D";
//             } else if (val_prov.compareToIgnoreCase("14") == 0) {
//                 val_prov = "E";
//             } else {
//                 val_prov = "F";
//             }

//             petit_hexa = petit_hexa + val_prov;
//             puissance--;

//             if (puissance < 0) {
//                 break;
//             }
//         }

//         return petit_hexa;
//     }

//     public static boolean isStringNumeric(String str) {
//         if (str == null || str.compareTo("") == 0) {
//             return false;
//         }
//         DecimalFormatSymbols currentLocaleSymbols = DecimalFormatSymbols.getInstance();
//         char localeMinusSign = currentLocaleSymbols.getMinusSign();

//         boolean isDecimalSeparatorFound = false;
//         char localeDecimalSeparator = currentLocaleSymbols.getDecimalSeparator();
// //        System.out.println("VALEUR : "+str);
//         for (char c : str.substring(1).toCharArray()) {
//             if (!Character.isDigit(c)) {
//                 if (c == localeDecimalSeparator && !isDecimalSeparatorFound && c != ' ') {
//                     isDecimalSeparatorFound = true;
//                     continue;
//                 }
//                 return false;
//             }
//         }
//         return true;

//     }

//     public static String[] formerTableauGroupe(String val1, String val2) throws Exception {
//         String retour[] = null;
//         if ((val1 == null || val1.compareToIgnoreCase("") == 0 || val1.compareToIgnoreCase("-") == 0) && (val2 != null && val2.compareToIgnoreCase("") != 0)) {
//             retour = new String[1];
//             retour[0] = val2;
//             return retour;
//         } else if ((val2 == null || val2.compareToIgnoreCase("") == 0) && (val1 != null && val1.compareToIgnoreCase("") != 0)) {
//             retour = new String[1];
//             retour[0] = val1;
//             return retour;
//         } else if ((val2 == null || val2.compareToIgnoreCase("") == 0) && (val1 == null || val1.compareToIgnoreCase("") == 0)) {
//             return null;
//         } else {
//             retour = new String[2];
//             retour[0] = val1;
//             retour[1] = val2;
//             return retour;
//         }
//     }

//     public static String convertDatyFormtoRealDatyFormat(String daty) {
//         if (daty == null || daty.compareToIgnoreCase("") == 0) {
//             return "";
//         }
//         String[] tableau = new String[3];
//         tableau = split(daty, "-");
//         String result = tableau[2] + "/" + tableau[1] + "/" + tableau[0];
//         return result;
//     }

//     public static String[] ajouterTableauString(String[] s1, String[] s2) {
//         String retour[] = new String[s1.length + s2.length];
//         int i = 0;
//         for (i = 0; i < s1.length; i++) {
//             retour[i] = s1[i];
//         }
//         for (int j = 0; j < s2.length; j++) {
//             retour[i + j] = s2[j];
//         }
//         return retour;
//     }

//     public static String getGenre(String sexe) {
//         if (sexe.compareTo("1") == 0) {
//             return "Femme";
//         }
//         if (sexe.compareTo("0") == 0) {
//             return "Homme";
//         }
//         return null;
//     }

//     public static String champNull(String nul) {
//         if (nul == null) {
//             return "";
//         } else if (nul.compareToIgnoreCase("null") == 0) {
//             return "";
//         } else if (nul.compareToIgnoreCase("") == 0) {
//             return "";
//         } else {
//             return nul;
//         }
//     }

//     public static String enleverEspace(String s) {
//         String ch = "";
//         int l = s.length();
//         char c;
//         for (int i = 0; i < l; i++) {
//             c = s.charAt(i);
//             if (c != ' ') {
//                 ch += c;
//             }
//         }
//         return ch;
//     }

//     public static String replaceChar(String s) {
// //        s = s.replace(''', '''');
//         s = s.replace('*', '%');
//         s = s.replace(',', '%');
//         return s;
//     }

//     public static String replaceChar(String text, String toReplace, String substitute) {
//         //s = s.replace(''', '''');
//         String ret = text.replace(toReplace.charAt(0), substitute.charAt(0));
//         return ret;
//     }

//     public static String diffDeuxheures(String[] heured, String[] heuref) {
//         String result = new String();
//         int minutes;
//         int hours;
//         String h;
//         String mn;
//         if (stringToInt(heured[1]) > stringToInt(heuref[1])) {
//             minutes = stringToInt(heured[1]) - stringToInt(heuref[1]);
//             hours = stringToInt(heuref[0]) - stringToInt(heured[0]) - 1;
//         } else {
//             minutes = stringToInt(heuref[1]) - stringToInt(heured[1]);
//             hours = stringToInt(heuref[0]) - stringToInt(heured[0]);
//         }
//         if (hours < 10) {
//             h = "0" + hours;
//         } else {
//             h = "" + hours;
//         }
//         if (minutes < 10) {
//             mn = "0" + minutes;
//         } else {
//             mn = "" + minutes;
//         }
//         result = "" + h + ":" + mn + "";
//         return result;
//     }

//     public static String sommeHeures(String[] heure) {
//         String result = new String();
//         int sommeh = 0;
//         int sommemn = 0;
//         String[] g;
//         String hours = "";
//         String mn = "";
//         for (int i = 0; i < heure.length; i++) {
//             g = split(heure[i], ":");
//             sommeh = sommeh + stringToInt(g[0]);
//             sommemn = sommemn + stringToInt(g[1]);
//         }
//         int x = sommemn / 60;
//         if (x > 0) {
//             sommeh = sommeh + x;
//             sommemn = sommemn % 60;
//         }
//         if (sommeh < 10) {
//             hours = "0" + sommeh;
//         } else {
//             hours = "" + sommeh;
//         }
//         if (sommemn < 10) {
//             mn = "0" + sommemn;
//         } else {
//             mn = "" + sommemn;
//         }
//         result = "" + hours + ":" + mn + "";
//         return result;
//     }

//     public static String getDebutAnnee(String annee) {
//         return "01/01/" + annee;
//     }

//     public static String[] split(String mot, String sep) {
//         java.util.StringTokenizer tokenizer = new java.util.StringTokenizer(mot, sep);
//         Vector v = new Vector();
//         while (tokenizer.hasMoreTokens()) {
//             v.add(tokenizer.nextToken());
//         }
//         String retour[] = new String[v.size()];
//         v.copyInto(retour);
//         return retour;
//     }

//     public static String getFinAnnee(String annee) {
//         return "31/12/" + annee;
//     }

//     public static String[] getDebutFinAnnee() {
//         Parametre.getParametre();
//         String[] retour = new String[2];
//         retour[0] = getDebutAnnee(String.valueOf(getAneeEnCours()));
//         retour[1] = getFinAnnee(String.valueOf(getAneeEnCours()));
//         return retour;
//     }

//     public static ClassMAPTable extraire(ClassMAPTable c[], int numCol, String val) {
//         try {
//             for (int i = 0; i < c.length; i++) {
//                 String valeur = String.valueOf(c[i].getValField(c[i].getFieldList()[numCol]));
//                 if (valeur.compareToIgnoreCase(val) == 0) {
//                     return c[i];
//                 }
//             }
//             return null;
//         } catch (Exception ex) {
//             ex.printStackTrace();
//         }
//         return null;
//     }

//     public static String[] remplacerNullParBlanc(String[] val, String remplacant) {
//         for (int i = 0; i < val.length; i++) {
//             if (val[i] == null) {
//                 val[i] = remplacant;
//             }
//         }
//         return val;
//     }

//     public static ClassMAPTable extraire(Vector v, int numCol, String val) {
//         try {
//             for (int i = 0; i < v.size(); i++) {
//                 ClassMAPTable c = (ClassMAPTable) v.elementAt(i);
//                 String valeur = (String) c.getValField(c.getFieldList()[numCol]);
//                 if (valeur.compareToIgnoreCase(val) == 0) {
//                     return c;
//                 }
//             }
//         } catch (Exception ex) {
//             ex.printStackTrace();
//         }
//         return null;
//     }

//     public static ClassMAPTable extraireMultiple(Vector v, int numColVect, int[] numCol, String[] val) {
//         try {
//             for (int i = 0; i < v.size(); i++) {
//                 ClassMAPTable c = (ClassMAPTable) v.elementAt(i);
//                 int test = 1;
//                 String[] valeurT = (String[]) (c.getValField(c.getFieldList()[numColVect]));
//                 for (int j = 0; j < numCol.length; j++) {
//                     String valeur = valeurT[j];
//                     if (valeur.compareToIgnoreCase(val[j]) != 0) {
//                         test = 0;
//                         break;
//                     }
//                 }
//                 if (test == 1) {
//                     return c;
//                 }
//             }
//         } catch (Exception ex) {
//             ex.printStackTrace();
//         }
//         return null;
//     }

//     public static int estIlDedans(ClassMAPTable c[], int numCol, String val) {
//         try {
//             for (int i = 0; i < c.length; i++) {
//                 String valeur = (String) c[i].getValField(c[i].getFieldList()[numCol]);
//                 if (valeur.compareToIgnoreCase(val) == 0) {
//                     return 1;
//                 }
//             }
//         } catch (Exception ex) {
//             ex.printStackTrace();
//         }
//         return 0;
//     }

//     public static String[] concatener(String[] t1, String[] t2) {
//         int taille = t1.length + t2.length;
//         String retour[] = new String[taille];
//         for (int i = 0; i < t1.length; i++) {
//             retour[i] = t1[i];
//         }
//         for (int j = t1.length; j < taille; j++) {
//             retour[j] = t2[j - t1.length];
//         }
//         return retour;
//     }

//     public static int estIlDedans(String test, String c[]) {
//         try {
//             if (c == null) {
//                 return -1;
//             }
//             for (int i = 0; i < c.length; i++) {
//                 if (c[i].compareToIgnoreCase(test) == 0) {
//                     return i;
//                 }
//             }
//         } catch (Exception ex) {
//             ex.printStackTrace();
//         }
//         return -1;
//     }

//     public static String convertDebutMajuscule(String autre) {
//         char[] c = autre.toCharArray();
//         c[0] = Character.toUpperCase(c[0]);
//         return new String(c);
//     }

//     public static String[] getvalCol(String nomTable, String col) {
//         UtilDB util = new UtilDB();
//         Connection c = null;
//         PreparedStatement cs = null;
//         ResultSet rs = null;
//         String[] retour = null;
//         try {
//             try {
//                 c = util.GetConn();
//                 cs = c.prepareStatement("select distinct(" + col + ") from " + nomTable);
//                 rs = cs.executeQuery();
//                 Vector v = new Vector();
//                 while (rs.next()) {
//                     v.add(rs.getString(1));
//                 }
//                 retour = new String[v.size()];
//                 v.copyInto(retour);
//                 return retour;
//             } catch (SQLException e) {
//                 e.printStackTrace();
//                 return null;
//             }
//         } finally {
//             try {
//                 if (c != null) {
//                     c.close();
//                 }
//                 if (cs != null) {
//                     cs.close();
//                 }
//                 if (rs != null) {
//                     rs.close();
//                 }
//                 util.close_connection();
//             } catch (SQLException e) {
//                 System.out.println("Erreur Fermeture SQL RechercheType ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//             }
//         }
//     }

//     public static int[] getBornePage(int page, Object list[]) {
//         int ret[] = new int[2];
//         ret[0] = (page - 1) * Parametre.getNbParPage();
//         if ((ret[0] + Parametre.getNbParPage()) - 1 < list.length) {
//             ret[1] = ret[0] + Parametre.getNbParPage();
//         } else {
//             ret[1] = list.length;
//         }
//         return ret;
//     }

//     public static int[] getBornePage(String page, Object list[]) {
//         return getBornePage(stringToInt(page), list);
//     }

//     public static int calculNbPage(double tailleObjet) {
//         int ret = 0;
//         Double d = new Double(tailleObjet);
//         ret = d.intValue() / Parametre.getNbParPage();
//         if (d.intValue() % Parametre.getNbParPage() > 0) {
//             ret++;
//         }
//         return ret;
//     }

//     public static int calculNbPage(double tailleObjet, int nbParPage) {
//         int ret = 0;
//         int nb = Parametre.getNbParPage();
//         if (nbParPage > 0) {
//             nb = nbParPage;
//         }
//         Double d = new Double(tailleObjet);
//         ret = d.intValue() / nb;
//         if (d.intValue() % nb > 0) {
//             ret++;
//         }
//         return ret;
//     }

//     public static int calculInitial(int i, int pageSize) {
//         int initial = 0;
//         if (i == 1) {
//             initial = 0;
//         } else {
//             initial = pageSize * (i - 1);
//         }
//         return initial;
//     }

//     public static String TraitementMots(String mots) {
//         String motsApres = "";
//         int longueurMots = mots.length();
//         int resteDivision = longueurMots % 4;
//         int nbDivision = (longueurMots / 4) + 1;
//         for (int i = 0; i < nbDivision; i++) {
//             if (resteDivision == 0 && i < (nbDivision - 1)) {
//                 motsApres = i == (nbDivision - 2) ? motsApres + "<div>" + mots.substring(i * 4, longueurMots) + "</div>" : motsApres + "<div>" + mots.substring(i * 4, i * 4 + 4) + "-</div>";
//             }
//             if (resteDivision > 0) {
//                 motsApres = i == (nbDivision - 1) ? motsApres + "<div>" + mots.substring(i * 4, i * 4 + resteDivision) + "</div>" : motsApres + "<div>" + mots.substring(i * 4, i * 4 + 4) + "-</div>";
//             }
//         }
//         return motsApres;
//     }

//     public static String TraitementMotsVerticale(String mots) {
//         String motsApres = "";
//         int longueurMots = mots.length();
//         int nbDivision = longueurMots / 4 + 1;
//         for (int i = 0; i < nbDivision; i++) {
//             motsApres += motsApres + "<div>" + mots.substring(i, i + 1) + "</div>";
//         }
//         return motsApres;
//     }

//     public static double[] calculValeur(double na, double nc, double ma, double mc) {
//         double[] coef = new double[2];
//         while (na > ma & nc < mc) {
//             nc = nc + 0.01;
//             na = na - 0.01;
//         }
//         coef[0] = na;
//         coef[1] = nc;
//         return coef;
//     }

//     public static int calculNbPage(Object list[]) {
//         return calculNbPage(list.length);
//     }

//     public static double calculSomme(String[] val) throws Exception {
//         double retour = 0;
//         for (int i = 0; i < val.length; i++) {
//             retour = retour + UtilitaireAcade.stringToDouble(val[i]);
//         }
//         return retour;
//     }

//     public static double calculSomme(double[] val) throws Exception {
//         double retour = 0;
//         for (int i = 0; i < val.length; i++) {
//             retour = retour + (val[i]);
//         }
//         return retour;
//     }

//     public static int stringToInt(String s) {
//         int j;
//         try {
//             Integer ger = new Integer(s);
//             int i = ger.intValue();
//             int k = i;
//             return k;
//         } catch (NumberFormatException ex) {
//             j = 0;
//         }
//         return j;
//     }

//     public static String remplacerNull(String valNull) {
//         if ((valNull == null) || valNull.compareToIgnoreCase("null") == 0) {
//             return "";
//         }
//         return valNull;
//     }

//     public static String getValPourcentage(String valeur) {
//         return null;
//     }

//     public static String remplacerUnderscore(String mot) {
//         String nouveau = new String(mot.toCharArray());
//         nouveau.replace('_', '-');
//         return nouveau;
//     }

//     /*public static String remplaceEspace(String valeur){
//      String retour="";
//      char val[] = new char[valeur.length()];
//      val = valeur.toCharArray();
//      for(int i=0;i<val.length;i++){
//      if(val[i]==' '){
//      retour=valeur.substring(0,i)+"%20"+valeur.substring(i+1,valeur.length());
//      }
//      }
//      System.out.print(retour);
//      return retour;
//      }*/
//     public static String remplaceMot(String valeur, String mot1, String mot2) {
//         StringBuffer result = new StringBuffer();
//         int startIdx = 0;
//         int idxOld = 0;
//         while ((idxOld = valeur.indexOf(mot1, startIdx)) >= 0) {
//             result.append(valeur.substring(startIdx, idxOld));
//             result.append(mot2);
//             startIdx = idxOld + mot1.length();
//         }
//         result.append(valeur.substring(startIdx));
//         return result.toString();
//     }

//     public static int getRang(char[] liste, char c) {
//         for (int i = 0; i < liste.length; i++) {
//             if (Character.toLowerCase(liste[i]) == Character.toLowerCase(c)) {
//                 return i;
//             }
//         }
//         return -1;
//     }

//     public static String coderPwd(String entree) {
//         char[] listeMot = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
//         char[] chiffre = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
//         char[] retr = new char[entree.length() + 1];
//         retr[0] = listeMot[entree.length() % 5];
//         char[] entr = entree.toCharArray();
//         for (int i = 0; i < entr.length; i++) {
//             int rL = getRang(listeMot, entr[i]);
//             int rC = getRang(chiffre, entr[i]);
//             if (rL > -1) {
//                 retr[i + 1] = listeMot[(listeMot.length - rL - i)];
//             } else if (rC > -1) {
//                 retr[i + 1] = chiffre[(chiffre.length + rC - i)];
//             } else {
//                 retr[i + 1] = entr[i];
//             }
//         }
//         return new String(retr);
//     }

//     public static String decode(String entree) {
//         char[] listeMot = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
//         char[] chiffre = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
//         return null;
//     }

//     public static String remplacePourcentage(String valeur) {
//         String retour = "";
//         if (valeur == null) {
//             return "";
//         }
//         char val[] = new char[valeur.length()];
//         val = valeur.toCharArray();
//         int taille = val.length;
//         if (valeur.compareToIgnoreCase("") == 0) {
//             return "";
//         }
//         if (valeur.compareToIgnoreCase("%") == 0 || valeur == null) {
//             return "%25";
//         }
//         /*if(val[0] == '%' && val[taille - 1] == '%')
//          {
//          retour = retour.concat("%25");
//          retour = retour.concat(valeur.substring(1, taille - 1));
//          retour = retour.concat("%25");
//          }
//          if(val[0] != '%' && val[taille - 1] == '%')
//          {
//          retour = valeur.substring(0, taille - 1);
//          retour = retour.concat("%25");
//          }
//          if(val[0] == '%' && val[taille - 1] != '%')
//          {
//          retour = retour.concat("%25");
//          retour = retour.concat(valeur.substring(1, taille));
//          }*/
//         retour = remplaceMot(valeur, "%", "%25");
//         retour = remplaceMot(retour, " ", "%20");
//         return retour;
//     }

//     public static String getDebutmot(String mot) {
//         String retour = "";
//         char motChar[] = new char[mot.length()];
//         motChar = mot.toCharArray();
//         retour = retour.concat(String.valueOf(motChar[0]));
//         int i = 0;
//         do {
//             if (i >= mot.length()) {
//                 break;
//             }
//             if (motChar[i] == ' ') {
//                 retour = retour.concat(String.valueOf(motChar[i + 1]));
//                 break;
//             }
//             i++;
//         } while (true);
//         return retour.toUpperCase();
//     }

//     public static String getDebutmot(String mot, int nombre) {
//         if (mot == null) {
//             return "";
//         }

//         if (nombre >= mot.length()) {
//             return mot.toUpperCase();
//         }

//         String retour = "";
//         if (nombre <= 0) {
//             return retour;
//         }

//         char motChar[] = new char[mot.length()];
//         motChar = mot.toCharArray();
//         //retour = retour.concat(String.valueOf(motChar[0]));

//         for (int n = 0; n < nombre; n++) {
//             if (motChar[n] == ' ') {
//                 retour = retour;
//                 System.out.println("retour=============" + retour + n);
//             } else {
//                 retour = retour.concat(String.valueOf(motChar[n]));
//                 System.out.println("retour=============" + retour + n);
//             }
//         }
//         return retour.toUpperCase();
//     }

//     /**
//      * Prend les 3 premieres lettres d'un String si c'est compose d'un seul mot,
//      * sinon prend les premieres lettres de chaque mot
//      *
//      */
//     public static String getDebutMots(String mot) {
//         String retour = "";
//         if (mot.compareTo("-") == 0) {
//             return "NON";
//         }
//         int multiple = 0;
//         int indice = 3;
//         if (mot.length() < 3) {
//             indice = 2;
//         }
//         char[] motChar = new char[mot.length()];
//         motChar = mot.toCharArray();
//         //retour=retour.concat(String.valueOf(motChar[0]));
//         for (int i = 0; i < mot.length(); i++) {
//             if (motChar[i] == ' ') {
//                 multiple = 1;
//                 break;
//             }
//         }
//         if (multiple == 1) {
//             retour = getDebutmot(mot);
//         } else {
//             for (int i = 0; i < indice; i++) {
//                 retour = retour.concat(String.valueOf(motChar[i]));
//             }
//         }
//         return retour.toUpperCase();
//     }

//     public static double getPvente(int pu, int marge) {
//         return (double) pu * ((double) 1 + (double) marge / (double) 100);
//     }

//     public static float stringToFloat(String s) {
//         float f1;
//         try {
//             Float ger = new Float(s);
//             float f = ger.floatValue();
//             return f;
//         } catch (NumberFormatException ex) {
//             f1 = 0.0F;
//         }
//         return f1;
//     }

//     public static String[] getBorneAnneeEnCours() {
//         return null;
//     }

//     public static String[] getBorneDatyMoisAnnee(String mois, String an) {
//         String retour[] = new String[2];
//         GregorianCalendar eD = new GregorianCalendar();
//         GregorianCalendar eD2 = new GregorianCalendar();
//         retour[0] = "01/" + mois + "/" + an;
//         Date daty1 = string_date("dd/MM/yyyy", retour[0]);
//         eD.setTime(daty1);
//         eD2.setTime(daty1);
//         eD2.add(5, 26);
//         do {
//             eD2.add(5, 1);
//         } while (eD.get(2) == eD2.get(2));
//         eD2.add(5, -1);
//         retour[1] = String.valueOf(String.valueOf(completerInt(2, eD2.get(5)))).concat("/");
//         retour[1] = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(retour[1])))).append(completerInt(2, eD2.get(2) + 1)).append("/")));
//         retour[1] = String.valueOf(retour[1]) + String.valueOf(completerInt(4, eD2.get(1)));
//         return retour;
//     }

//     public static int getAneeEnCours() {
//         Calendar a = Calendar.getInstance();
//         return a.get(1);
//     }

//     public static int compterCar(String lettre, char c) {
//         char[] mot = lettre.toCharArray();
//         int nb = 0;
//         for (int i = 0; i < mot.length; i++) {
//             if (mot[i] == c) {
//                 nb++;
//             }
//         }
//         return nb;
//     }

//     public static String[] split(String lettre, char sep) {
//         /*Vector v = new Vector();
//         char[] mot = lettre.toCharArray();
//         char part[] = new char[100];
//         int indicePart = 0;
//         for (int i = 0; i < mot.length; i++) {
//             if (mot[i] == sep) {
//                 indicePart = 0;
//                 v.add(String.valueOf(part).trim());
//                 part = new char[100];
//             } else {
//                 part[indicePart] = mot[i];
//                 indicePart++;
//             }
//             if (i == mot.length - 1) {
//                 v.add(String.valueOf(part).trim());
//             }
//         }
//         String[] retour = new String[v.size()];
//         v.copyInto(retour);
//         return retour;*/
//         char[] lc={sep};
//         return lettre.split(new String(lc));
//     }

//     public static boolean estIlDedans(char[] liste, char car) {
//         for (int i = 0; i < liste.length; i++) {
//             if (liste[i] == car) {
//                 return true;
//             }
//         }
//         return false;
//     }

//     public static String[] splitMultiple(String lettre) {
//         return (split(lettre, listSeparator));
//     }

//     public static String[] split(String lettre, char[] sep) {
//         Vector v = new Vector();
//         char[] mot = lettre.toCharArray();
//         char part[] = new char[100];
//         int indicePart = 0;
//         for (int i = 0; i < mot.length; i++) {
//             if (estIlDedans(sep, mot[i])) {
//                 indicePart = 0;
//                 v.add(String.valueOf(part).trim());
//                 part = new char[100];
//             } else {
//                 part[indicePart] = mot[i];
//                 indicePart++;
//             }
//             if (i == mot.length - 1) {
//                 v.add(String.valueOf(part).trim());
//             }
//         }
//         String[] retour = new String[v.size()];
//         v.copyInto(retour);
//         return retour;
//     }

//     public static String getAnnee(String daty) {
//         //daty.
//         //GregorianCalendar eD = new GregorianCalendar();
//         //eD.setTime(string_date("dd/MM/yyyy", daty));
//         //return String.valueOf(eD.get(1));
//         return split(daty, "/")[2];
//     }

//     public static String getAnnee(String daty, String separateur) {
//         //daty.
//         //GregorianCalendar eD = new GregorianCalendar();
//         //eD.setTime(string_date("dd/MM/yyyy", daty));
//         //return String.valueOf(eD.get(1));
//         return split(daty, separateur)[0];
//     }

//     public static int getAnnee(Date daty) {
//         GregorianCalendar eD = new GregorianCalendar();
//         eD.setTime(daty);
//         return eD.get(1);
//     }

//     public static int getMois(Date daty) {
//         GregorianCalendar eD = new GregorianCalendar();
//         eD.setTime(daty);
//         return eD.get(2) + 1;
//     }

//     public static String getMois(String daty) {
//         //GregorianCalendar eD = new GregorianCalendar();
//         //eD.setTime(string_date("dd/MM/yyyy", daty));
//         //return completerInt(2, eD.get(2) + 1);
//         return completerInt(2, split(daty, "/")[1]);
//     }

//     public static String getJour(String daty) {
//         //GregorianCalendar eD = new GregorianCalendar();
//         //eD.setTime(string_date("dd/MM/yyyy", daty));
//         //return completerInt(2, eD.get(5));
//         return completerInt(2, split(daty, "/")[0]);
//     }

//     public static int getMoisEnCours() {
//         Calendar a = Calendar.getInstance();
//         return a.get(2);
//     }

//     public static int getMoisEnCoursReel() {
//         Calendar a = Calendar.getInstance();
//         return a.get(2) + 1;
//     }

//     public static int compareDaty(Date supe, Date infe) {
//         GregorianCalendar eD = new GregorianCalendar();
//         GregorianCalendar eD2 = new GregorianCalendar();
//         Date sup = string_date("dd/MM/yyyy", formatterDaty(supe));
//         Date inf = string_date("dd/MM/yyyy", formatterDaty(infe));
//         eD.setTime(sup);
//         eD2.setTime(inf);
//         if (eD.getTime().getTime() > eD2.getTime().getTime()) {
//             return 1;
//         }
//         return eD.getTime().getTime() >= eD2.getTime().getTime() ? 0 : -1;
//     }

//     public static int diffJourDaty(Date dMaxe, Date dMine) {
//         GregorianCalendar eD = new GregorianCalendar();
//         GregorianCalendar eD2 = new GregorianCalendar();
//         Date dMax = string_date("dd/MM/yyyy", formatterDaty(dMaxe));
//         Date dMin = string_date("dd/MM/yyyy", formatterDaty(dMine));
//         eD.setTime(dMax);
//         eD2.setTime(dMin);
//         if (dMaxe.equals(dMine)) {
//             return 0;
//         }
//         double resultat = eD.getTime().getTime() - eD2.getTime().getTime();
//         BigDecimal result = new BigDecimal(String.valueOf(eD.getTime().getTime() - eD2.getTime().getTime()));
//         BigDecimal retour = result.divide(new BigDecimal(String.valueOf(0x5265c00)), 4);
//         return 1 + retour.intValue();
//     }
    
//     public static int diffJourDaty2(Date dMaxe, Date dMine) {
//         GregorianCalendar eD = new GregorianCalendar();
//         GregorianCalendar eD2 = new GregorianCalendar();
//         Date dMax = string_date("dd/MM/yyyy", formatterDaty(dMaxe));
//         Date dMin = string_date("dd/MM/yyyy", formatterDaty(dMine));
//         eD.setTime(dMax);
//         eD2.setTime(dMin);
//         if (dMaxe.equals(dMine)) {
//             return 1;
//         }
//         double resultat = eD.getTime().getTime() - eD2.getTime().getTime();
//         BigDecimal result = new BigDecimal(String.valueOf(eD.getTime().getTime() - eD2.getTime().getTime()));
//         BigDecimal retour = result.divide(new BigDecimal(String.valueOf(0x5265c00)), 4);
//         return 1 + retour.intValue();
//     }
    
//     public static int diffMoisDaty(Date dMaxe, Date dMine) {
//         int result = 0, diffAnnee = 0, yMax = 0, yMin = 0, mMax = 0, mMin = 0;
//         GregorianCalendar calMax, calMin;
//         if (dMaxe.getTime() < dMine.getTime()) {
//             Date temp = dMaxe;
//             dMaxe = dMine;
//             dMine = temp;
//         }
//         calMax = new GregorianCalendar();
//         calMin = new GregorianCalendar();
//         calMin.setTime(dMine);
//         calMax.setTime(dMaxe);
//         mMin = calMin.get(GregorianCalendar.MONTH);
//         mMax = calMax.get(GregorianCalendar.MONTH);
//         yMin = calMin.get(GregorianCalendar.YEAR);
//         yMax = calMax.get(GregorianCalendar.YEAR);
//         diffAnnee = yMax - yMin;
//         if (mMax < mMin) {
//             diffAnnee--;
//             result = 12 - (mMin - mMax);
//         } else {
//             result = mMax - mMin;
//         }
//         result += diffAnnee * 12;
//         return result;
//     }

//     public static int diffJourDaty(String dMax, String dMin) {
//         return diffJourDaty(string_date("dd/MM/yyyy", dMax), string_date("dd/MM/yyyy", dMin));
//     }

//     public static int diffMoisDaty(String dMax, String dMin) {
//         return diffMoisDaty(string_date("dd/MM/yyyy", dMax), string_date("dd/MM/yyyy", dMin));
//     }

//     public static String replaceVirgule(String s) {

//         //s = s.replace('\'', '\''');
//         s = s.replace(',', '.');

//         return s;
//     }

//     public static String supprimerEspace(String s) {

//         //s = s.replace('\'', '\''');
//         s = s.trim();

//         return s;
//     }

//     public static String[] splitPeriode(String periode) {
//         String[] ret = new String[2];
//         ret[0] = periode.substring(0, 4);
//         ret[1] = periode.substring(4);
//         return ret;
//     }

//     public static String enleverEspaceDoubleBase(String montantBase) {
//         String montant = "";
//         for (int i = 0; i < montantBase.length(); ++i) {
//             char c = montantBase.charAt(i);
//             int j = (int) c;
//             //System.out.println("ASCII value of " + c + " is " + j + ".");
//             if (j != 160) {
//                 montant += c;
//             }
//         }
//         return montant;
//     }

//     public static double stringToDouble(String s) {
//         double d1;
//         try {
//             String ns = replaceVirgule(s);
//             ns = enleverEspace(ns);
//             //ns=ns.trim();
//             Double ger = new Double(ns);
//             double d = ger.doubleValue();
//             return d;
//         } catch (NumberFormatException ex) {
//             d1 = 0.0D;
//             //System.out.println(" ============== D1 ====== " + d1);
//         }
//         return d1;
//     }

//     public static long stringToLong(String s) {
//         try {
//             Long ger = new Long(s);
//             long l = ger.longValue();
//             return l;
//         } catch (NumberFormatException ex) {
//             ex.printStackTrace();
//         }
//         long l1 = 0L;
//         return l1;
//     }

//     public static int[] findUniteDizaine(int nb) {
//         try {
//             int[] ret = new int[2];
//             ret[0] = nb % 10;
//             ret[1] = (nb - ret[0]);
//             return ret;
//         } catch (NumberFormatException ex) {
//             ex.printStackTrace();
//         }
//         return null;
//     }

//     public static String formaterAr(String montant) {
//         return formaterAr(stringToDouble(montant));
//     }

//     public static String doubleWithoutExponential(double val) {
//         String vals = String.format(Locale.FRENCH,"%.2f", val);
//         String[] temp = vals.split(",");
//         if (temp.length>1 && temp[1].compareToIgnoreCase("00") == 0) {
//             vals = temp[0];
//         } else if (temp.length>1 && temp[1].endsWith("0")) {
//             vals = temp[0] + "," + temp[1].substring(0, 1);
//         }
//         return UtilitaireAcade.replaceChar(vals, ",", ".");
//     }

//     public static String formaterAr(double montant) {
//         try {
//             if (montant == 0) {
//                 return "0";
//             }
//             NumberFormat nf = NumberFormat.getInstance(Locale.FRENCH);
//             //nf = new DecimalFormat("### ###,##");
//             //nf.setMaximumFractionDigits(2);
//             nf.setMinimumFractionDigits(2);
//             String s = nf.format(montant);
//             return s;
//         } catch (Exception e) {
//             e.printStackTrace();
//         }
//         return null;
//     }

//     public static String formaterSansVirgule(double montant) {
//         try {
//             if (montant == 0) {
//                 return "0";
//             }
//             NumberFormat nf = NumberFormat.getInstance(Locale.FRENCH);
//             //nf = new DecimalFormat("### ###,##");
//             //nf.setMaximumFractionDigits(2);
//             nf.setMinimumFractionDigits(0);
//             String s = nf.format(montant);
//             return s;
//         } catch (Exception e) {
//             e.printStackTrace();
//         }
//         String s1 = null;
//         return s1;
//     }

//     ///
//     public static String formaterAr(long montant) {
//         return formaterAr(String.valueOf(montant));
//     }

//     public static String formatterDaty(String daty) {
//         if ((daty == null) || (daty.compareToIgnoreCase("null") == 0) || (daty.compareToIgnoreCase("") == 0)) {
//             return "";
//         }
//         String valiny = (daty.substring(8, 10) + "/" + (daty.substring(5, 7)) + "/" + (daty.substring(0, 4)));
//         return valiny;
//     }

//     public static Date getDateRentreSemestre() throws Exception {
//         Connection c = null;
//         UtilDB util = new UtilDB();
//         Statement sta = null;
//         ResultSet rs = null;
//         Date max = null;
//         try {
//             c = util.GetConn();
//             String param = "Select MAX(RENTRE) FROM RENTRESEMESTRE";
//             sta = c.createStatement();
//             rs = sta.executeQuery(param);
//             rs.next();
//             max = rs.getDate(1);
//         } catch (SQLException e) {
//             System.out.println("getNbTuple : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         } finally {
//             if (sta != null) {
//                 sta.close();
//             }
//             if (rs != null) {
//                 rs.close();
//             }
//             util.close_connection();
//         }
//         return max;
//     }

//     public static String getTomorowDate() {
//         Calendar calendar = Calendar.getInstance();
//         calendar.add(calendar.DAY_OF_MONTH, 1);
//         return format(calendar.getTime());
//     }

//     public static String format(java.util.Date date) {

//         SimpleDateFormat fmt = new SimpleDateFormat("dd/MMM/yyyy");
//         String dateFormatted = fmt.format(date);

//         return dateFormatted;
//     }

//     public static double arrondir(double a, int apr) {
//         double d;
//         try {
//             NumberFormat nf = NumberFormat.getInstance(Locale.GERMAN);
//             nf.setMaximumFractionDigits(apr);
//             Number retour = nf.parse(nf.format(a));
//             double d1 = retour.doubleValue();
//             return d1;
//         } catch (Exception e) {
//             d = 1.0D;
//         }
//         return d;
//     }

//     public static String formatterDaty(Date daty) {
//         String retour = null;
//         return formatterDaty(String.valueOf(daty));
//     }

//     public static String formatterDatySql(java.sql.Date daty) {
//         String retour = null;
//         return formatterDaty(String.valueOf(daty));
//     }

//     public static Date ajoutJourDateOuvrable(Date aDate, int nbDay) {
//         try {
//             Date date = string_date("dd/MM/yyyy", ajoutJourDateStringOuvrable(aDate, nbDay));
//             return date;
//         } catch (Exception e) {
//             System.out.println("Error string_date :".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         Date date1 = null;
//         return date1;
//     }

//     public static String ajoutJourDateStringOuvrable(Date aDatee, int nbDay) {
//         try {
//             GregorianCalendar eD = new GregorianCalendar();
//             Date aDate = string_date("dd/MM/yyyy", formatterDaty(aDatee));
//             eD.setTime(aDate);
//             int offset = 1;
//             int offsetSunday = 1;
//             int offsetSaturday = 2;
//             if (nbDay < 0) {
//                 offset = -1;
//                 offsetSunday = -2;
//                 offsetSaturday = -1;
//             }
//             for (int i = 1; i <= Math.abs(nbDay); i++) {
//                 eD.add(5, offset);
//                 if (eD.get(7) == 7) {
//                     eD.add(5, offsetSaturday);
//                     continue;
//                 }
//                 if (eD.get(7) == 1) {
//                     eD.add(5, offsetSunday);
//                 }
//             }

//             String retour = null;
//             retour = String.valueOf(String.valueOf(completerInt(2, eD.get(5)))).concat("/");
//             retour = String.valueOf(retour) + String.valueOf(completerInt(2, String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(eD.get(2) + 1)))).append("/")))));
//             retour = String.valueOf(retour) + String.valueOf(completerInt(4, eD.get(1)));
//             String s1 = retour;
//             return s1;
//         } catch (Exception e) {
//             System.out.println("Error string_date :".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         String s = null;
//         return s;
//     }

//     public static String ajoutMoisDateString(Date aDatee, int nbMois) {
//         try {
//             GregorianCalendar eD = new GregorianCalendar();
//             GregorianCalendar eD2 = new GregorianCalendar();
//             Date aDate = string_date("dd/MM/yyyy", formatterDaty(aDatee));
//             eD.setTime(aDate);
//             int offset = 1;
//             int offsetSunday = 1;
//             int offsetSaturday = 2;
//             if (nbMois < 0) {
//                 offset = -1;
//                 offsetSunday = -2;
//                 offsetSaturday = -1;
//             }
//             for (int i = 1; i <= Math.abs(nbMois); i++) {
//                 eD.add(2, offset);
//             }

//             eD2.setTime(eD.getTime());
//             if (eD.get(2) == eD2.get(2) && testFinDuMois(aDate)) {
//                 do {
//                     eD2.add(5, 1);
//                 } while (eD.get(2) == eD2.get(2));
//                 eD2.add(5, -1);
//             }
//             String retour = null;
//             retour = String.valueOf(String.valueOf(completerInt(2, eD2.get(5)))).concat("/");
//             retour = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(retour)))).append(completerInt(2, eD2.get(2) + 1)).append("/")));
//             retour = String.valueOf(retour) + String.valueOf(completerInt(4, eD2.get(1)));
//             String s1 = retour;
//             return s1;
//         } catch (Exception e) {
//             System.out.println("Error string_date :".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         String s = null;
//         return s;
//     }

//     public static boolean testFinDuMois(Date aDatee) {
//         GregorianCalendar eD = new GregorianCalendar();
//         Date aDate = string_date("dd/MM/yyyy", formatterDaty(aDatee));
//         eD.setTime(aDate);
//         GregorianCalendar eD2 = new GregorianCalendar();
//         eD2.setTime(eD.getTime());
//         eD2.add(5, 1);
//         return eD.get(2) != eD2.get(2);
//     }

//     public static double getMaxListeDouble(double[] liste) {
//         double max = liste[0];
//         for (int i = 1; i < liste.length; i++) {
//             if (liste[i] >= max) {
//                 max = liste[i];
//             }
//         }
//         return max;
//     }

//     public static String ajoutJourDateString(Date aDatee, int nbDay) {
//         try {
//             GregorianCalendar eD = new GregorianCalendar();
//             Date aDate = string_date("dd/MM/yyyy", formatterDaty(aDatee));
//             eD.setTime(aDate);
//             int offset = 1;
//             int offsetSunday = 1;
//             int offsetSaturday = 2;
//             if (nbDay < 0) {
//                 offset = -1;
//                 offsetSunday = -2;
//                 offsetSaturday = -1;
//             }
//             for (int i = 1; i <= Math.abs(nbDay); i++) {
//                 eD.add(5, offset);
//             }

//             String retour = null;
//             retour = String.valueOf(String.valueOf(completerInt(2, eD.get(5)))).concat("/");
//             retour = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(retour)))).append(completerInt(2, eD.get(2) + 1)).append("/")));
//             retour = String.valueOf(retour) + String.valueOf(completerInt(4, eD.get(1)));
//             String s1 = retour;
//             return s1;
//         } catch (Exception e) {
//             System.out.println("Error ajoutJourDateString :".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         String s = null;
//         return s;
//     }

//     public static String soustraireJourDate(int nbDay) {
//         try {
//             Calendar cal = Calendar.getInstance();
//             cal.add(Calendar.DATE, -nbDay);
//             return UtilitaireAcade.datetostring(cal.getTime());
//         } catch (Exception e) {
//             System.out.println("Error ajoutJourDate :".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         String date1 = "";
//         return date1;
//     }

//     public static Date ajoutJourDate(Date aDate, int nbDay) {
//         try {
//             Date date = string_date("dd/MM/yyyy", ajoutJourDateString(aDate, nbDay));
//             return date;
//         } catch (Exception e) {
//             System.out.println("Error ajoutJourDate :".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         Date date1 = null;
//         return date1;
//     }

//     public static Date ajoutMoisDate(Date aDate, int nbMois) {
//         try {
//             Date date = string_date("dd/MM/yyyy", ajoutMoisDateString(aDate, nbMois));
//             return date;
//         } catch (Exception e) {
//             System.out.println("Error ajoutMoisDate :".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         Date date1 = null;
//         return date1;
//     }

//     public static Date ajoutJourDate(String daty, int jour) {
//         try {
//             Date date = ajoutJourDate(string_date("dd/MM/yyyy", daty), jour);
//             return date;
//         } catch (Exception e) {
//             System.out.println("Error ajoutJourDate :".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         Date date1 = null;
//         return date1;
//     }

//     public static Date string_date(String patterne, String daty) {
//         try {
//             if (daty == null || daty.compareTo("") == 0) {
//                 return null;
//             }
//             SimpleDateFormat formatter = new SimpleDateFormat(patterne);
//             formatter.applyPattern(patterne);
//             formatter.setTimeZone(TimeZone.getTimeZone("EUROPE"));
//             String annee = getAnnee(daty);
//             int anneecours = getAneeEnCours();
//             int siecl = anneecours / 100;
//             if (annee.toCharArray().length == 2) {
//                 annee = String.valueOf(siecl) + annee;
//             }
//             daty = getJour(daty) + "/" + getMois(daty) + "/" + annee;
//             Date hiredate = new Date(formatter.parse(daty).getTime());
//             Date date1 = hiredate;
//             return date1;
//         } catch (Exception e) {
//             System.out.println("Error string_date wawawawa :" + e.getMessage());
//         }
//         Date date = dateDuJourSql();
//         return date;
//     }

//     public static java.util.Date stringToDate(String pattern, String daty) {
//         try {
//             //System.out.println("DATY UTILITAIRE ".concat(String.valueOf(String.valueOf(pattern))));
//             SimpleDateFormat formatter = new SimpleDateFormat(pattern);
//             java.util.Date hiredate = formatter.parse(daty);
//             java.util.Date date1 = hiredate;
//             return date1;
//         } catch (Exception e) {
//             System.out.println("Error stringTodate :".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         java.util.Date date = null;
//         return date;
//     }

//     public int randomizer(int max) {
//         int retour;
//         for (retour = 0; retour <= 0; retour = r.nextInt(max));
//         return retour;
//     }

//     public String randomizer_daty(int annee) {
//         int mois = r.nextInt(13);
//         int jour = r.nextInt(31);
//         String retour = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(jour)))).append("/").append(mois).append("/").append(annee)));
//         return retour;
//     }

//     public static int getNbTuple(String nomTable) {
//         Connection c = null;
//         UtilDB util = new UtilDB();
//         try {
//             try {
//                 c = util.GetConn();
//                 String param = "select count(*) from ".concat(String.valueOf(String.valueOf(nomTable)));
//                 Statement sta = c.createStatement();
//                 ResultSet rs = sta.executeQuery(param);
//                 rs.next();
//                 int i = rs.getInt(1);
//                 return i;
//             } catch (SQLException e) {
//                 System.out.println("getNbTuple : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//             }
//             int j = 0;
//             return j;
//         } finally {
//             util.close_connection();
//         }
//     }

//     public static int getNbEliminatoire(String nomTable, String critere, String apwhere) {
//         Connection c = null;
//         UtilDB util = new UtilDB();
//         try {
//             try {
//                 c = util.GetConn();
//                 String param = String.valueOf(String.valueOf((new StringBuffer("select count(")).append(critere).append(") from ").append(nomTable).append(" where ").append(apwhere)));
//                 //System.out.print(param);
//                 Statement sta = c.createStatement();
//                 ResultSet rs = sta.executeQuery(param);
//                 rs.next();
//                 int i = rs.getInt(1);
//                 return i;
//             } catch (SQLException e) {
//                 System.out.println("getNbTuple : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//             }
//             int j = 0;
//             return j;
//         } finally {
//             util.close_connection();
//         }
//     }

//     public static int getMaxColonneFactFin(String daty) {
//         UtilDB util = new UtilDB();
//         Connection c = null;
//         PreparedStatement cs = null;
//         ResultSet rs = null;
//         try {
//             try {
//                 ///System.out.println("sasa MIDITRA");
//                 String an = getAnnee(daty);
//                 c = null;
//                 c = util.GetConn();
//                 //System.out.println("sasa ");
//                 cs = c.prepareStatement(String.valueOf(String.valueOf((new StringBuffer("select * from  seqFact where daty<='31/12/")).append(an).append("' and daty>='01/01/").append(an).append("'"))));
//                 rs = cs.executeQuery();
//                 //System.out.println("sasa sasaa");
//                 int i = 0;
//                 if (rs.next()) {
//                     i++;
//                 }
//                 //System.out.println("sasa ".concat(String.valueOf(String.valueOf(i))));
//                 if (i == 0) {
//                     int k = 0;
//                     return k;
//                 }
//                 int l = (new Integer(rs.getString(1))).intValue();
//                 return l;
//             } catch (SQLException e) {
//                 System.out.println("getMaxSeq : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//             }
//             int j = 0;
//             return j;
//         } finally {
//             try {
//                 if (c != null) {
//                     c.close();
//                 }
//                 if (cs != null) {
//                     cs.close();
//                 }
//                 if (rs != null) {
//                     rs.close();
//                 }
//                 util.close_connection();
//             } catch (SQLException e) {
//                 System.out.println("Erreur Fermeture SQL RechercheType ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//             }
//         }
//     }

//     public static int getMaxSeq(String nomProcedure, Connection c) throws Exception {
//         CallableStatement cs = null;
//         ResultSet rs = null;
//         try {
//             //System.out.print("SSSSSSSSSQQQQQQQQQQQQQLLLLLLLLLL="+(new StringBuffer("select ")).append(nomProcedure).append(" from dual"));
//             //cs = c.prepareCall(String.valueOf(String.valueOf((new StringBuffer("select ")).append(nomProcedure).append(" from dual"))));
//             //niova -> postgres
//             cs = c.prepareCall(String.valueOf(String.valueOf((new StringBuffer("select ")).append(nomProcedure).append("()"))));
//             rs = cs.executeQuery();
//             rs.next();
//             int i = rs.getInt(1);
//             return i;
//         } catch (Exception e) {
//             throw e;
//         } finally {
//             if (rs != null) {
//                 rs.close();
//             }
//             if (cs != null) {
//                 cs.close();
//             }
//         }
//     }

//     public static int getMaxSeq(String nomProcedure) {
//         UtilDB util = new UtilDB();
//         Connection c = null;
//         try {
//             c = util.GetConn();
//             return getMaxSeq(nomProcedure, c);
//         } catch (Exception eu) {
//             eu.printStackTrace();
//         } finally {
//             try {
//                 if (c != null) {
//                     c.close();
//                 }
//             } catch (Exception e) {
//                 e.printStackTrace();
//             }
//         }
//         return 0;
//     }

//     public static int getMaxNum(String nomTable, String nomColonne, String where) throws Exception {
//         Connection c = null;
//         UtilDB util = new UtilDB();
//         Statement sta = null;
//         ResultSet rs = null;
//         try {
//             try {
//                 c = util.GetConn();

//                 String param = "select max(" + nomColonne + ") from " + nomTable + " where " + where;
//                 System.out.println(param);
//                 sta = c.createStatement();
//                 rs = sta.executeQuery(param);
//                 int i = 0;
//                 if (rs.next()) {
//                     i = rs.getInt(1);
//                 }
//                 return i;
//             } catch (SQLException e) {
//                 System.out.println("getNbTuple : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//             }
//             int j = 0;
//             return j;
//         } finally {
//             if (sta != null) {
//                 sta.close();
//             }
//             if (rs != null) {
//                 rs.close();
//             }
//             util.close_connection();
//         }
//     }

//     public static int getMaxNum(String nomTable, String nomColonne) throws Exception {
//         Connection c = null;
//         UtilDB util = new UtilDB();
//         Statement sta = null;
//         ResultSet rs = null;
//         try {
//             try {
//                 c = util.GetConn();
//                 String param = String.valueOf(String.valueOf((new StringBuffer("select max(")).append(nomColonne).append(") from ").append(nomTable)));
//                 sta = c.createStatement();
//                 rs = sta.executeQuery(param);
//                 rs.next();
//                 int i = 1 + rs.getInt(1);
//                 return i;
//             } catch (SQLException e) {
//                 System.out.println("getNbTuple : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//             }
//             int j = 0;
//             return j;
//         } finally {
//             if (sta != null) {
//                 sta.close();
//             }
//             if (rs != null) {
//                 rs.close();
//             }
//             util.close_connection();
//         }
//     }

//     public static String getMaxColonne(String nomTable, String nomColonne, String nomCritere, String attributCritere) throws Exception {
//         Connection c = null;
//         UtilDB util = new UtilDB();
//         Statement sta = null;
//         ResultSet rs = null;
//         String max = "";
//         try {
//             c = util.GetConn();
//             String param = String.valueOf(String.valueOf((new StringBuffer("select max(")).append(nomColonne).append(") from ").append(nomTable).append(" where ").append(nomCritere).append("='").append(attributCritere).append("'")));
//             //System.out.println(param);
//             sta = c.createStatement();
//             rs = sta.executeQuery(param);
//             rs.next();
//             max = rs.getString(1);
//         } catch (SQLException e) {
//             System.out.println("getNbTuple : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         } finally {
//             if (sta != null) {
//                 sta.close();
//             }
//             if (rs != null) {
//                 rs.close();
//             }
//             util.close_connection();
//         }
//         return max;
//     }

//     public static String getMaxColonneMultiCritere(String nomTable, String nomColonne, String whereCritereContact) throws Exception {
//         Connection c = null;
//         UtilDB util = new UtilDB();
//         Statement sta = null;
//         ResultSet rs = null;
//         String max = "";
//         try {
//             c = util.GetConn();
//             String param = String.valueOf(String.valueOf((new StringBuffer("select max(")).append(nomColonne).append(") from ").append(nomTable).append(whereCritereContact)));
//             sta = c.createStatement();
//             //System.out.print("param: "+param);
//             rs = sta.executeQuery(param);
//             rs.next();
//             max = rs.getString(1);
//         } catch (SQLException e) {
//             System.out.println("getNbTuple : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         } finally {
//             if (sta != null) {
//                 sta.close();
//             }
//             if (rs != null) {
//                 rs.close();
//             }
//             util.close_connection();
//         }
//         return max;
//     }

//     public static String updateColonne(String nomTable, String nomColonne, String critere, String val, String valCritere) throws Exception {
//         Connection c = null;
//         UtilDB util = new UtilDB();
//         Statement sta = null;
//         int rs = 0;
//         String max = "";
//         try {
//             c = util.GetConn();
//             c.setAutoCommit(false);
//             String param = String.valueOf(String.valueOf((new StringBuffer("update ")).append(nomTable).append(" set ").append(nomColonne).append("='").append(val).append("' where ").append(critere).append("='").append(valCritere).append("'")));
//             sta = c.createStatement();
//             //System.out.print("param: " + param);
//             rs = sta.executeUpdate(param);
//             c.commit();
//         } catch (SQLException e) {
//             System.out.println("getNbTuple : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         } finally {
//             if (sta != null) {
//                 sta.close();
//             }
//             if (c != null) {
//                 c.close();
//             }
//         }
//         return max;
//     }

//     public static int getSommeColonneMultiCritere(String nomTable, String nomColonne, String whereCritereContact) throws Exception {
//         Connection c = null;
//         UtilDB util = new UtilDB();
//         Statement sta = null;
//         ResultSet rs = null;
//         int sum = 0;
//         try {
//             c = util.GetConn();
//             String param = String.valueOf(String.valueOf((new StringBuffer("select sum(")).append(nomColonne).append(") from ").append(nomTable).append(" where ").append(whereCritereContact)));
//             //System.out.print("param3333:"+param);
//             sta = c.createStatement();
//             rs = sta.executeQuery(param);
//             rs.next();
//             sum = rs.getInt(1);
//         } catch (SQLException e) {
//             System.out.println("getNbTuple : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         } finally {
//             if (sta != null) {
//                 sta.close();
//             }
//             if (rs != null) {
//                 rs.close();
//             }
//             util.close_connection();
//         }
//         return sum;
//     }

//     public static int getNombreJourMois(String mois, String an) {
//         try {
//             String datyInf = getBorneDatyMoisAnnee(mois, an)[0];
//             String datySup = getBorneDatyMoisAnnee(mois, an)[1];
//             int j = diffJourDaty(datySup, datyInf);
//             return j;
//         } catch (Exception e) {
//             System.out.println("getNombreJourMois : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         int i = 0;
//         return i;
//     }

//     public static int getNombreJourMois(String daty) {
//         try {
//             String mois = getMois(daty);
//             String an = getAnnee(daty);
//             int j = getNombreJourMois(mois, an);
//             return j;
//         } catch (Exception e) {
//             System.out.println("getNombreJourMois : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         int i = 0;
//         return i;
//     }

//     public static java.sql.Date stringDate(String daty) {
//         if (daty == null || daty.compareTo("") == 0) {
//             return null;
//         }
//         java.sql.Date sqlDate = null;
//         try {
//             SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
//             java.util.Date date = sdf.parse(daty);
//             sqlDate = new Date(date.getTime());
//         } catch (Exception e) {
//             System.out.println("Error stringDate :" + e.getMessage());
//         }
//         return sqlDate;
//     }

//     public static String completerInt(int longuerChaine, int nombre) {
//         String zero = null;
//         zero = "";
//         for (int i = 0; i < longuerChaine - String.valueOf(nombre).length(); i++) {
//             zero = String.valueOf(String.valueOf(zero)).concat("0");
//         }

//         return String.valueOf(zero) + String.valueOf(String.valueOf(nombre));
//     }

//     public static String completerInt(int longuerChaine, String nombre2) {
//         int nombre = stringToInt(nombre2);
//         return completerInt(longuerChaine, nombre);
//     }

//     public static String heureCourante() {
//         Calendar a = Calendar.getInstance();
//         String retour = null;
//         retour = String.valueOf(String.valueOf(completerInt(2, a.get(11) + 1))).concat(":");
//         retour = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(retour)))).append(completerInt(2, a.get(12))).append(":")));
//         retour = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(retour)))).append(completerInt(2, a.get(13))).append(":")));
//         retour = String.valueOf(retour) + String.valueOf(completerInt(2, a.get(14) / 10));
//         return retour;
//     }

//     public static String heureCouranteHMS() {
//         Calendar a = Calendar.getInstance();
//         String retour = null;
//         retour = String.valueOf(String.valueOf(completerInt(2, a.get(11)))).concat(":");
//         retour = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(retour)))).append(completerInt(2, a.get(12))).append(":")));
//         retour = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(retour)))).append(completerInt(2, a.get(13)))));
//         return retour;
//     }

//     public static String heureCouranteHM() {
//         Calendar a = Calendar.getInstance();
//         String retour = null;
//         retour = String.valueOf(String.valueOf(completerInt(2, a.get(11)))).concat(":");
//         retour = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(retour)))).append(completerInt(2, a.get(12)))));
//         return retour;
//     }

//     public static String dateDuJour() {
//         Calendar a = Calendar.getInstance();
//         String retour = null;
//         retour = String.valueOf(String.valueOf(completerInt(2, a.get(5)))).concat("/");
//         retour = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(retour)))).append(completerInt(2, a.get(2) + 1)).append("/")));
//         retour = String.valueOf(retour) + String.valueOf(completerInt(4, a.get(1)));
//         return retour;
//     }

//     public static Date dateDuJourSql() {
//         return string_date("dd/MM/yyyy", dateDuJour());
//     }

//     public static String annulerZero(int nombre) {
//         if (nombre == 0) {
//             return " ";
//         } else {
//             return String.valueOf(nombre);
//         }
//     }

//     public static Vector intersecter(ClassMAPTable objet1[], ClassMAPTable objet2[]) {
//         Vector retour = new Vector();
//         int dim1 = objet1.length;
//         int dim2 = objet2.length;
//         int nbEgaux = 0;
//         for (int i = 0; i < dim1; i++) {
//             String cle1 = objet1[i].getTuppleID();
//             for (int j = 0; j < dim2; j++) {
//                 String cle2 = objet2[j].getTuppleID();
//                 if (cle1.compareTo(cle2) == 0) {
//                     retour.add(nbEgaux, objet2[j]);
//                     nbEgaux++;
//                 }
//             }

//         }
//         return retour;
//     }

//     public static Vector intersecter(Vector objet1, Vector objet2) {
//         Vector retour = new Vector();
//         int dim1 = objet1.size();
//         int dim2 = objet2.size();
//         int nbEgaux = 0;
//         for (int i = 0; i < dim1; i++) {
//             ClassMAPTable temp = (ClassMAPTable) objet1.elementAt(i);
//             String cle1 = temp.getTuppleID();
//             for (int j = 0; j < dim2; j++) {
//                 ClassMAPTable temp2 = (ClassMAPTable) objet2.elementAt(j);
//                 String cle2 = temp2.getTuppleID();
//                 if (cle1.compareTo(cle2) == 0) {
//                     retour.add(nbEgaux, temp2);
//                     nbEgaux++;
//                 }
//             }

//         }

//         return retour;
//     }

//     public static boolean intersecterIgnoreCase(String nomChamp, String valeur, ClassMAPTable objet1[]) {
//         int dim1 = objet1.length;
//         int nbEgaux = 0;
//         for (int i = 0; i < dim1; i++) {
//             String cle1 = objet1[i].getTuppleID();
//             if (ref.compareTo(cle1) == 0) {
//                 return true;
//             }
//         }

//         return false;
//     }

//     public static boolean intersecter(String ref, ClassMAPTable objet1[]) {
//         int dim1 = objet1.length;
//         int nbEgaux = 0;
//         for (int i = 0; i < dim1; i++) {
//             String cle1 = objet1[i].getTuppleID();
//             if (ref.compareTo(cle1) == 0) {
//                 return true;
//             }
//         }

//         return false;
//     }

//     public static boolean intersecter(String ref, Vector objet1) {
//         int dim1 = objet1.size();
//         int nbEgaux = 0;
//         if (objet1 != null) {
//             for (int i = 0; i < dim1; i++) {
//                 ClassMAPTable temp = (ClassMAPTable) objet1.elementAt(i);
//                 String cle1 = temp.getTuppleID();
//                 if (ref.compareTo(cle1) == 0) {
//                     return true;
//                 }
//             }

//         }
//         return false;
//     }

//     public static Object[] toArray(Vector v) {
//         Object retour[] = new Object[v.size()];
//         for (int i = 0; i < v.size(); i++) {
//             retour[i] = v.elementAt(i);
//         }

//         return retour;
//     }

//     public static String getRequest(String temp) {
//         if (temp == null || temp.compareTo("") == 0) {
//             return "";
//         } else {
//             return temp;
//         }
//     }

//     public static String getValeurNonNull(String temp) {
//         if (temp == null || temp.compareTo("") == 0) {
//             return "%";
//         } else {
//             return temp;
//         }
//     }

//     public static String makePK(int longPK, String indPk, String nomProcedureSequence) throws Exception {
//         int maxSeq = getMaxSeq(nomProcedureSequence);
//         String nombre = completerInt(longPK, maxSeq);
//         return String.valueOf(indPk) + String.valueOf(nombre);
//     }

//     public static String[] getNomColonne(Object a) {
//         String retour[] = null;
//         Field f[] = a.getClass().getDeclaredFields();
//         retour = new String[f.length];
//         for (int i = 0; i < f.length; i++) {
//             retour[i] = f[i].getName();
//         }

//         return retour;
//     }

//     public static String[] getNomColonne(Object a, String typ) {
//         String retour[] = null;
//         Field f[] = a.getClass().getFields();
//         Vector v = new Vector();
//         for (int i = 0; i < f.length; i++) {
//             if (typ.compareToIgnoreCase("nombre") == 0) {
//                 if ((f[i].getType().getName().compareToIgnoreCase("int") == 0) || (f[i].getType().getName().compareToIgnoreCase("double") == 0) || (f[i].getType().getName().compareToIgnoreCase("float") == 0) || (f[i].getType().getName().compareToIgnoreCase("short") == 0)) {
//                     v.add(f[i].getName());
//                 }
//             }
//             if (typ.compareToIgnoreCase("chaine") == 0) {
//                 if (f[i].getType().getName().compareToIgnoreCase("String") == 0) {
//                     v.add(f[i].getName());
//                 }
//             }
//         }
//         retour = new String[v.size()];
//         v.copyInto(retour);
//         return retour;
//     }

//     public static String cryptWord(String mot) {
//         int niveau = (int) Math.round(Math.random() * 10);
//         int sens = (int) Math.round(Math.random());
//         if (niveau == 0) {
//             niveau = -5;
//         }
//         return (cryptWord(mot, niveau, sens));
//     }

//     public static String cryptWord(String mot, int niveauCrypt, int croissante) {
//         if (croissante == 0) {
//             return cryptWord(mot, niveauCrypt, true);
//         } else {
//             return cryptWord(mot, niveauCrypt, false);
//         }
//     }

//     public static String cryptWord(String mot, int niveauCrypt, boolean croissante) {
//         char[] ar = mot.toCharArray();
//         char[] retour = new char[ar.length];

//         if (croissante) {
//             for (int i = 0; i < ar.length; i++) {
//                 int k = Character.getNumericValue(ar[i]);
//                 if (k < (Character.MAX_RADIX - niveauCrypt)) {
//                     retour[i] = Character.forDigit(k + niveauCrypt, Character.MAX_RADIX);
//                 } else {
//                     retour[i] = ar[i];
//                 }
//             }
//         } else {
//             for (int i = 0; i < ar.length; i++) {
//                 int k = Character.getNumericValue(ar[i]);
//                 if (k > (niveauCrypt - 1)) {
//                     retour[i] = Character.forDigit(k - niveauCrypt, Character.MAX_RADIX);
//                 } else {
//                     retour[i] = ar[i];
//                 }
//             }
//         }

//         return new String(retour);
//     }

//     public static String unCryptWord(String mot, int niveauCrypt, boolean croissante) {
//         char[] ar = mot.toCharArray();
//         char[] retour = new char[ar.length];

//         if (croissante) {
//             for (int i = 0; i < ar.length; i++) {
//                 int k = Character.getNumericValue(ar[i]);
//                 if (k < (Character.MAX_RADIX - niveauCrypt)) {
//                     retour[i] = Character.forDigit(k - niveauCrypt, Character.MAX_RADIX);
//                 } else {
//                     retour[i] = ar[i];
//                 }
//             }
//         } else {
//             for (int i = 0; i < ar.length; i++) {
//                 int k = Character.getNumericValue(ar[i]);
//                 if (k > (niveauCrypt - 1)) {
//                     retour[i] = Character.forDigit(k + niveauCrypt, Character.MAX_RADIX);
//                 } else {
//                     retour[i] = ar[i];
//                 }
//             }
//         }
//         return new String(retour);
//     }

//     public static int[] transformerMoisAnnee(int mois, int annee) {
//         int[] retour = new int[2];
//         retour[1] = annee + mois / 12;
//         retour[0] = mois % 12;
//         if (retour[0] == 0) {
//             retour[0] = 12;
//             retour[1] = retour[1] - 1;
//         }
//         return retour;
//     }

//     public static String nbToMois(int nombre) {
//         String mois = null;
//         switch (nombre) {
//             case 1: // '\001'
//                 mois = "janvier";
//                 break;

//             case 2: // '\002'
//                 mois = "fevrier";
//                 break;

//             case 3: // '\003'
//                 mois = "mars";
//                 break;

//             case 4: // '\004'
//                 mois = "avril";
//                 break;

//             case 5: // '\005'
//                 mois = "mai";
//                 break;

//             case 6: // '\006'
//                 mois = "juin";
//                 break;

//             case 7: // '\007'
//                 mois = "juillet";
//                 break;

//             case 8: // '\b'
//                 mois = "ao�t";
//                 break;

//             case 9: // '\t'
//                 mois = "septembre";
//                 break;

//             case 10: // '\n'
//                 mois = "octobre";
//                 break;

//             case 11: // '\013'
//                 mois = "novembre";
//                 break;

//             case 12: // '\f'
//                 mois = "decembre";
//                 break;

//             default:
//                 mois = null;
//                 break;
//         }
//         return mois;
//     }

//     public static Date getDatePayementEcolage() throws Exception {
//         Connection c = null;
//         UtilDB util = new UtilDB();
//         Statement sta = null;
//         ResultSet rs = null;
//         Date max = null;
//         try {
//             c = util.GetConn();
//             String param = "Select MAX(DATEFINPAYMENTECOLAGE2TRANCHE) FROM RENTRESEMESTRE";
//             sta = c.createStatement();
//             rs = sta.executeQuery(param);
//             rs.next();
//             max = rs.getDate(1);
//         } catch (SQLException e) {
//             System.out.println("getNbTuple : ".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         } finally {
//             if (sta != null) {
//                 sta.close();
//             }
//             if (rs != null) {
//                 rs.close();
//             }
//             util.close_connection();
//         }
//         return max;
//     }

//     public static String datetostring(java.sql.Date d) {
//         String daty = null;
//         SimpleDateFormat dateJava = new SimpleDateFormat("dd/MM/yyyy");
//         daty = dateJava.format(d);
//         return daty;
//     }

//     public static String datetostring(java.util.Date d) {
//         String daty = null;
//         SimpleDateFormat dateJava = new SimpleDateFormat("dd/MM/yyyy");
//         daty = dateJava.format(d);
//         return daty;
//     }

//     public static String datedujourlettre(String dat) {
//         String jour = getJour(dat);
//         String mois = convertDebutMajuscule(nbToMois(UtilitaireAcade.stringToInt(UtilitaireAcade.getMois(dat))));
//         String annee = getAnnee(dat);
//         String daty = jour + " " + mois + " " + annee;
//         return daty;
//     }

//     public static String getIdByCb(String cb) {
//         char[] dd = cb.toCharArray();
//         char[] id = new char[9];
//         int j = 8;
//         for (int i = cb.length() - 1; i > cb.length() - 10; i--) {
//             id[j] = dd[i];
//             j--;
//         }
//         String idString = new String(id);
//         return idString;
//     }

//     public static String getIdByCbEns(String cb) {
//         //2PROFENS2
//         return cb.substring(5, cb.length());
//     }
//     static Random r = new Random();

//     public static String getAnneeParam(String param, String daty) {
//         String annee = daty.split(param)[0];
//         return annee;
//     }

//     public static String getJourParam(String param, String daty) {
//         return completerInt(2, split(daty, param)[2]);
//     }

//     public static String getMoisParam(String param, String daty) {
//         return completerInt(2, split(daty, param)[1]);
//     }

//     public static Date string_dateParam(String param, String patterne, String daty) {
//         try {
//             SimpleDateFormat formatter = new SimpleDateFormat(patterne);
//             formatter.applyPattern(patterne);
//             formatter.setTimeZone(TimeZone.getTimeZone("EUROPE"));
//             String annee = getAnneeParam(param, daty);
//             int anneecours = getAneeEnCours();
//             int siecl = anneecours / 100;
//             if (annee.toCharArray().length == 2) {
//                 annee = String.valueOf(siecl) + annee;
//             }
//             daty = getJourParam(param, daty) + "/" + getMoisParam(param, daty) + "/" + annee;
//             Date hiredate = new Date(formatter.parse(daty).getTime());
//             Date date1 = hiredate;
//             return date1;
//         } catch (Exception e) {
//             System.out.println("Error string_date :".concat(String.valueOf(String.valueOf(e.getMessage()))));
//         }
//         Date date = dateDuJourSql();
//         return date;
//     }

//     public static String verifNumerique(String s) {
//         String res = s;
//         res = res.replace(',', '.');
//         String[] temp = split(res, ' ');
//         res = "";
//         for (int i = 0; i < temp.length; i++) {
//             res += temp[i];
//         }
//         try {
//             Float.valueOf(res);
//             return res;
//         } catch (Exception e) {
//             return s;
//         }

//     }

// //    public static void uploadFileToCdn(InputStream f, String filename) throws Exception {
// //        try {
// //            MultipartEntity entity = new MultipartEntity();
// //            entity.addPart("text", new StringBody(filename));
// //            entity.addPart("file", new InputStreamBody(f, filename));
// //            java.util.Properties prop = configuration.CynthiaConf.load();
// //            HttpPost request = new HttpPost(prop.getProperty("cdnUri"));
// //            System.out.println("VALERA = "+prop.getProperty("cdnUri"));
// //            request.setEntity(entity);
// //            HttpClient client = new DefaultHttpClient();
// //            HttpResponse response = client.execute(request);
// //        } catch (Exception ex) {
// //            ex.printStackTrace();
// //            throw ex;
// //        }
// //    }
//     public static void uploadFileToCdn(InputStream f, String filename) throws Exception {
//         try {
//             HttpClient httpclient = new DefaultHttpClient();
//             httpclient.getParams().setParameter(CoreProtocolPNames.PROTOCOL_VERSION, HttpVersion.HTTP_1_1);
//             java.util.Properties prop = configuration.CynthiaConf.load();
//             HttpPost httppost = new HttpPost(prop.getProperty("cdnUri"));

//             MultipartEntity entity = new MultipartEntity();
//             entity.addPart("nom", new StringBody(filename));
//             entity.addPart("fichiers", new InputStreamBody(f, filename));
//             httppost.setEntity(entity);

//             System.out.println("EXECUTING REQUEST : " + httppost.getRequestLine());
//             HttpResponse response = httpclient.execute(httppost);
//             HttpEntity resEntity = response.getEntity();
//             System.out.println(response.getStatusLine());

//             if (resEntity != null) {
//                 resEntity.consumeContent();
//             }

//             httpclient.getConnectionManager().shutdown();
//         } catch (Exception ex) {
//             ex.printStackTrace();
//         }
//     }

//     public static void deleteFileFromCdn(String filename) {
//         try {
//             HttpClient httpclient = new DefaultHttpClient();
//             httpclient.getParams().setParameter(CoreProtocolPNames.PROTOCOL_VERSION, HttpVersion.HTTP_1_1);
//             java.util.Properties prop = configuration.CynthiaConf.load();
//             HttpPost httppost = new HttpPost(prop.getProperty("cdnDeleteUri"));

//             MultipartEntity entity = new MultipartEntity();
//             entity.addPart("filename", new StringBody(filename));
//             httppost.setEntity(entity);
//             System.out.println("EXECUTING REQUEST : " + httppost.getRequestLine());
//             HttpResponse response = httpclient.execute(httppost);
//             HttpEntity resEntity = response.getEntity();
//             System.out.println(response.getStatusLine());

//             if (resEntity != null) {
//                 resEntity.consumeContent();
//             }
            
//             httpclient.getConnectionManager().shutdown();
//         } catch (Exception ex) {
//             ex.printStackTrace();
//         }
//     }

//     public static String getExtensionFichier(String nomfichier) {
//         String text = nomfichier;
//         String[] val = text.split("\\.");
//         return val[val.length - 1];
//     }

//     public static String testHeureValide(String heure) throws Exception {
//         if (heure.contains(":")) {
//             return transformeHeure(heure);
//         }
//         if (heure.contains("H")) {
//             String replace = heure.replace("H", ":");
//             if (replace.contains("M")) {
//                 replace = replace.replace("M", "");
//             }
//             return transformeHeure(replace);
//         }
//         if (heure.contains("h")) {
//             String replace = heure.replace("h", ":");
//             if (replace.contains("m")) {
//                 replace = replace.replace("m", "");
//             }
//             return transformeHeure(replace.toString());
//         }
//         throw new Exception("Heure non valide.");
//     }

//     public static String transformeHeure(String heure) throws Exception {
//         String[] str = heure.split(":");
//         if (str == null || str.length < 2) {
//             throw new Exception("Heure non valide.");
//         } else {
//             int hr = -1;
//             int min = -1;
//             try {
//                 hr = Integer.parseInt(str[0]);
//                 min = Integer.parseInt(str[1]);
//             } catch (Exception e) {
//                 throw new Exception("Heure non valide.");
//             }
//             if (hr >= 24 || hr < 0 || min < 0 || min >= 60) {
//                 throw new Exception("Heure non valide.");
//             }

//             for (int i = 0; i < str.length; i++) {
//                 if (str[i].length() < 2) {
//                     str[i] = "0" + str[i];
//                 }
//             }
//             heure = str[0] + ":" + str[1];
//         }
//         return heure;
//     }

//     public static String tabToString(String[] s, String quote, String virgule) {
//         String res = "";
//         try {
//             res = quote + s[0] + quote;
//             for (int i = 1; i < s.length; i++) {
//                 res = res + virgule + quote + s[i] + quote;
//             }
//         } catch (NumberFormatException ex) {
//             ex.printStackTrace();
//         }
//         return res;
//     }

//     public static String[] stringToTab(String text, String separateur) {
//         String temps = text.trim();
//         String[] ret = split(temps, separateur.charAt(0));
//         return ret;
//     }

//     public static boolean isPeriodString(String value, String toReplace) {
//         boolean ret = false;

//         try {
            
//             String tempp = replaceChar(value, toReplace, "1");
// //            System.out.println("22222av===========" + tempp + "=========");
//             int val = stringToInt(tempp.trim());
// //            System.out.println("3av===========" + val + "=========");
//             if (val > 0) {
// //                System.out.println("3===========" + val + "=========");
//                 ret = true;
//             }
//         } catch (Exception ex) {
//             ret = false;
//             ex.printStackTrace();
//         }
//         return ret;
//     }

//     public static java.sql.Date dateMax(java.sql.Date d1, java.sql.Date d2) {
//         if (d1 == null && d2 == null) {
//             return null;
//         }
//         if (d1 == null) {
//             return d2;
//         }
//         if (d2 == null) {
//             return d1;
//         }
//         return (d1.after(d2)) ? d1 : d2;
//     }

//     public static java.sql.Date dateMin(java.sql.Date d1, java.sql.Date d2) {
//         if (d1 == null && d2 == null) {
//             return null;
//         }
//         if (d1 == null) {
//             return d2;
//         }
//         if (d2 == null) {
//             return d1;
//         }
//         return (d1.before(d2)) ? d1 : d2;
//     }

//     public static String dateMax(String d1, String d2) {
//         java.sql.Date retour = dateMax(stringDate(d1), stringDate(d2));
//         return datetostring(retour);
//     }

//     public static String dateMin(String d1, String d2) {
//         java.sql.Date retour = dateMin(stringDate(d1), stringDate(d2));
//         return datetostring(retour);
//     }

//     public static String getHeureFromTimestamp(java.sql.Timestamp heure) {
//         String ora = completerInt(2, heure.getHours());
//         String min = completerInt(2, heure.getMinutes());
//         String sec = completerInt(2, heure.getSeconds());
//         return ora + ":" + min + ":" + sec;
//     }

//     public static int getDiffYears(Date first, Date last) {
//         Calendar a = getCalendar(first);
//         Calendar b = getCalendar(last);
//         int diff = b.get(YEAR) - a.get(YEAR);
//         if (a.get(MONTH) > b.get(MONTH)
//                 || (a.get(MONTH) == b.get(MONTH) && a.get(DATE) > b.get(DATE))) {
//             diff--;
//         }
//         return diff;
//     }

//     public static Calendar getCalendar(Date date) {
//         Calendar cal = Calendar.getInstance(Locale.US);
//         cal.setTime(date);
//         return cal;
//     }

//     public static String getAnneePeriode(String periode) throws Exception {
//         if (periode.length() != 6) {
//             throw new Exception("Format periode invalide");
//         }
//         return periode.substring(0, 4);
//     }

//     public static String getMoisPeriode(String periode) throws Exception {
//         if (periode.length() != 6) {
//             throw new Exception("Format periode invalide");
//         }
//         return periode.substring(4, 6);
//     }
    
//     public static String getPeriode(Date daty){
//         int mois = getMois(daty);
//         String periode = "";
//         if(mois >= 1 && mois <= 3)
//             periode += getAnnee(daty)+"01";
//         if(mois >= 4 && mois <= 6)
//             periode += getAnnee(daty)+"02";
//         if(mois >= 7 && mois <= 9)
//             periode += getAnnee(daty)+"03";
//         if(mois >= 10 && mois <= 12)
//             periode += getAnnee(daty)+"04";
//         return periode;
//     }
    
//     public static String[] getMoisPeriode2(String periode){
//         String[] ret = new String[3];
//         String trimestre = periode.substring(4);
//         switch (trimestre) {
//             case "01":
//                 ret[0] = "01";
//                 ret[1] = "02";
//                 ret[2] = "03";
//                 break;
//             case "02":
//                 ret[0] = "04";
//                 ret[1] = "05";
//                 ret[2] = "06";
//                 break;
//             case "03":
//                 ret[0] = "07";
//                 ret[1] = "08";
//                 ret[2] = "09";
//                 break;
//             case "04":
//                 ret[0] = "10";
//                 ret[1] = "11";
//                 ret[2] = "12";
//                 break;
//         }
//         return ret;
//     }

//     public static int comparerHeure(String heureDebut, String heureFin) throws Exception {
//         int h1, h2;
//         String[] HMDebut, HMFin;
//         testHeureValide(heureDebut);
//         testHeureValide(heureFin);
//         HMDebut = heureDebut.split(":");
//         HMFin = heureFin.split(":");
//         h1 = Integer.valueOf(HMDebut[0] + HMDebut[1]);
//         h2 = Integer.valueOf(HMFin[0] + HMFin[1]);
//         if (h1 < h2) {
//             return 1;
//         }
//         if (h2 < h1) {
//             return -1;
//         }
//         return 0;
//     }

//     public static int ajoutMoisPeriode(int periode, int diff) throws Exception {
//         String daty = "01/" + getMoisPeriode(String.valueOf(periode)) + "/" + getAnneePeriode(String.valueOf(periode));
//         java.sql.Date datySql = stringDate(daty);
//         java.sql.Date dt = ajoutMoisDate(datySql, diff);
//         String annee = getAnnee(datetostring(dt));
//         String mois = getMois(datetostring(dt));
//         int retour = stringToInt(annee + mois);
//         return retour;
//     }

//     public static String ajoutMoisPeriode(String periode, int diff) throws Exception {
//         int retour = ajoutMoisPeriode(stringToInt(periode), diff);
//         return String.valueOf(retour);
//     }

//     public static String incrementLettre(char[] lettreInit) {
//         char[] lettre = lettreInit;
//         for (int i = lettre.length - 1; i >= 0; i--) {
//             for (char j = 'a'; j <= 'z'; j++) {
//                 //System.out.println("char : "+j);
//                 if (lettre[i] == j && j == 'z') {
//                     lettre[i] = 'a';
//                 } else if (lettre[i] == j && j < 'z') {
//                     char tmp = j;
//                     tmp = (char) (tmp + 1);
//                     lettre[i] = tmp;
//                     return new String(lettre);
//                 }
//             }
//         }
//         return null;
//     }

//     public static int calculeAge(java.sql.Date naissance) {
//         int age = getAneeEnCours() - getAnnee(naissance);
//         java.sql.Date temp = new java.sql.Date(naissance.getYear(), naissance.getMonth(), naissance.getDay());
//         temp.setYear(getAneeEnCours() - 1900);
// //        System.out.println("date temp = "+temp);
//         if (dateDuJourSql().compareTo(temp) < 0) {
// //            System.out.println("miditra before");
//             age--;
//         }
//         return age;
//     }

//     public static int calculeAge(String date) {
//         return calculeAge(stringDate(date));
//     }

//     public static boolean possedeDoublon(String[] input) {
//         for (int i = 0; i < input.length; i++) {
//             for (int j = 0; j < input.length; j++) {
//                 if (input[i].equals(input[j]) && i != j) {
//                     return true;
//                 }
//             }
//         }
//         return false;
//     }

//     public static int getTrimestreByMois(int mois) {
//         if (mois <= 3) {
//             return 1;
//         } else if (mois > 3 && mois <= 6) {
//             return 2;
//         } else if (mois > 6 && mois <= 9) {
//             return 3;
//         } else if (mois > 9 && mois <= 12) {
//             return 4;
//         }
//         return 0;
//     }

//     public static String[] enleverNulouVide(String[] array) {
//         List<String> list = new ArrayList<String>();
//         for (String s : array) {
//             if (s != null && s.length() > 0) {
//                 list.add(s);
//             }
//         }
//         array = list.toArray(new String[list.size()]);
//         return array;
//     }

//     /* Calcul hormis jour ferrier */
//     public static int calculNbreJourOuvrable(String mois, String annee) {

//         java.util.Date startDate = new java.util.Date(Integer.valueOf(annee) - 1900, Integer.valueOf(mois) - 1, 1);
//         String dates = utilitaireAcade.UtilitaireAcade.getLastDayOfDate("01/" + mois + "/" + annee);
//         java.util.Date endDate = utilitaireAcade.UtilitaireAcade.stringToDate("yyyy-MM-dd", dates);

//         Calendar startCal = Calendar.getInstance();
//         startCal.setTime(startDate);

//         Calendar endCal = Calendar.getInstance();
//         endCal.setTime(endDate);

//         int workDays = 0;

//         if (startCal.getTimeInMillis() > endCal.getTimeInMillis()) {
//             startCal.setTime(endDate);
//             endCal.setTime(startDate);
//         }

//         do {
//             startCal.add(Calendar.DAY_OF_MONTH, 1);
//             if (startCal.get(Calendar.DAY_OF_WEEK) != Calendar.SATURDAY && startCal.get(Calendar.DAY_OF_WEEK) != Calendar.SUNDAY) {
//                 workDays++;
//             }
//         } while (startCal.getTimeInMillis() <= endCal.getTimeInMillis());

//         return workDays;
//     }

//     public static Date getDateAvant(Date d, int ajout) {
//         GregorianCalendar c = new GregorianCalendar(d.getYear() + 1900, d.getMonth(), d.getDate());
//         c.set(GregorianCalendar.DATE, c.get(GregorianCalendar.DATE) + ajout);
//         java.util.Date dt = c.getTime();
//         return new Date(dt.getTime());
//     }

//     public static java.sql.Date[] convertIntervaleToListDate(java.sql.Date dmin, java.sql.Date dmax) {
//         Vector v = new Vector();
//         int i = 0;
//         while (1 < 2) {
//             Date d1 = getDateAvant(dmin, i);
//             if (UtilitaireAcade.compareDaty(d1, dmax) != 0) {
//                 v.add(d1);
//                 i++;
//             } else {
//                 v.add(dmax);
//                 break;
//             }
//         }
//         Date[] res = new Date[v.size()];
//         v.copyInto(res);
//         return res;
//     }

//     public static int getEcheance(int mois) {
//         int ret = 0;
//         if (mois == 1 || mois == 4 || mois == 7 || mois == 10) {
//             ret = 1;
//         } else if (mois == 2 || mois == 5 || mois == 8 || mois == 11) {
//             ret = 2;
//         } else if (mois == 3 || mois == 6 || mois == 9 || mois == 12) {
//             ret = 3;
//         }
//         return ret;
//     }

//     public static String dateEnFrancais(Date date) {
//         DateFormat format = DateFormat.getInstance();
//         DateFormat format_fr
//                 = DateFormat.getDateInstance(DateFormat.FULL, Locale.FRENCH);
//         return format_fr.format(date);
//     }

//     public static boolean comparerObjet(Object[] liste) {
//         boolean ret = true;
//         for (int i = 0; i < liste.length; i++) {
//             if (!liste[0].equals(liste[i])) {
//                 ret = false;
//                 break;
//             }
//         }
//         return ret;
//     }

//     public static boolean validerHeureMinute(String timeString) {
//         if (timeString.length() != 5) {
//             return false;
//         }
//         if (!timeString.substring(2, 3).equals(":")) {
//             return false;
//         }
//         int hour = validateNumber(timeString.substring(0, 2));
//         int minute = validateNumber(timeString.substring(3, 5));
//         if (hour < 0 || hour >= 24) {
//             return false;
//         }
//         if (minute < 0 || minute >= 60) {
//             return false;
//         }
//         return true;
//     }

//     private static int validateNumber(String numberString) {
//         try {
//             int number = Integer.valueOf(numberString);
//             return number;
//         } catch (NumberFormatException e) {
//             return -1;
//         }
//     }

//     public static int calculeAgeDate(java.sql.Date naissance, java.sql.Date dateRepere) {
//         int age = getAneeEnCours() - getAnnee(naissance);
//         java.sql.Date temp = new java.sql.Date(naissance.getYear(), naissance.getMonth(), naissance.getDay());
//         temp.setYear(getAneeEnCours() - 1900);
// //        System.out.println("date temp = "+temp);
//         if (dateRepere.compareTo(temp) < 0) {
// //            System.out.println("miditra before");
//             age--;
//         }
//         return age;
//     }

//     public static double truncateDouble(double number, int numDigits) {
//         double result = number;
//         String arg = "" + number;
//         int idx = arg.indexOf('.');
//         if (idx != -1) {
//             if (arg.length() > idx + numDigits) {
//                 arg = arg.substring(0, idx + numDigits + 1);
//                 result = Double.parseDouble(arg);
//             }
//         }
//         return result;
//     }

//     public static double arrondirDecimalWithMode(double a, String pattern, RoundingMode mode) {//pattern deux chffires apr�s la virgule #.##
//         DecimalFormat df = new DecimalFormat(pattern);
//         df.setRoundingMode(mode); //RoundingMode.HALF_UP, RoundingMode.HALF_DOWN
//         String format = df.format(a).replace(",", ".");
//         return Double.valueOf(format);
//     }
    
//     public static String convertJour8hEnJourHeureMinute(double jour){
//         String result = "";
//         if(jour > 0){
//             int j_part_ent = (int)jour;
//             result = j_part_ent + "j";
//             double j_part_dec = jour - j_part_ent;
//             double heure = j_part_dec * 8;
//             int h_part_ent = (int)heure;
//             result = result + " " + h_part_ent + "h";
//             double h_part_dec = heure - h_part_ent;
//             double minute = h_part_dec * 60;
//             int m_part_ent = (int)minute;
//             result = result + " " + m_part_ent + "min";
//         }
//         return result;
//     }
//     public static Timestamp convertStringToTimestampHour(String val, String separator)throws Exception{
//         String[] tab = val.split(separator);
//         if(tab.length<3)throw new Exception("Format heure invalide");
//         int hour = Integer.valueOf(tab[0]);
//         int min = Integer.valueOf(tab[1]);
//         int sec = Integer.valueOf(tab[2]);
//         return new Timestamp(0, 0, 0, hour, min, sec, 0);
//     }
//     public static String getCurrentHeure(){
//         Calendar cal = Calendar.getInstance();
//         SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
//         //System.out.println( sdf.format(cal.getTime()) );
//         String ret = sdf.format(cal.getTime()).toString();
//         return ret;
//     }
    
    
//     public static boolean testMemeMois(java.sql.Date d1, java.sql.Date d2){
//         return UtilitaireAcade.getMois(d1) == UtilitaireAcade.getMois(d2) && UtilitaireAcade.getAnnee(d1) == UtilitaireAcade.getAnnee(d2);
//     }
//     public static String getDateSansSeparateur(String daty){
//         String jour=getJour(daty);
//         String mois=getMois(daty);
//         String annee=getAnnee(daty);
//         return jour+mois+annee;
//     }
//     public static String getDateEnLettre(String daty){
//         String jour=getJour(daty);
//         jour=ChiffreLettre.convertIntToString(Integer.valueOf(jour)).toUpperCase();
//         String mois =nbToMois(Integer.valueOf(getMois(daty))).toUpperCase();
//         String annee = getAnnee(daty);
//         return jour + " " + mois + " " + annee;
//     }
//     public static String getHeureLettre(String heure){
//         String[] heuresplit = heure.split(":");
//         if(heuresplit[0].compareToIgnoreCase("01")==0 || heuresplit[0].compareToIgnoreCase("00")==0) heuresplit[0] = ChiffreLettre.convertIntToString(Integer.valueOf(heuresplit[0])).toUpperCase()+"E HEURE ";
//         else if(heuresplit[0].compareToIgnoreCase("21")==0) heuresplit[0] = ChiffreLettre.convertIntToString(Integer.valueOf(heuresplit[0])).toUpperCase()+"E HEURES ";
//         else heuresplit[0] = ChiffreLettre.convertIntToString(Integer.valueOf(heuresplit[0])).toUpperCase()+" HEURES ";
//         if(heuresplit[1].compareToIgnoreCase("00")==0) heuresplit[1] ="";
//         else if(heuresplit[1].compareToIgnoreCase("01")==0) heuresplit[1] ="ET " + ChiffreLettre.convertIntToString(Integer.valueOf(heuresplit[1])).toUpperCase()+"E MINUTE";
//         else heuresplit[1] ="ET "+ChiffreLettre.convertIntToString(Integer.valueOf(heuresplit[1])).toUpperCase()+" MINUTES";
//         return heuresplit[0]+heuresplit[1];
//     }
//     public static double arrondiInf(double k){
//         return arrondirDecimalWithMode(k, "#", RoundingMode.DOWN);
//     }
    
//     public static java.util.Date castString2Date(String dateString) throws ParseException{
//         DateFormat formatter = new SimpleDateFormat("d-MM-yyyy");
//         java.util.Date date = formatter.parse(dateString);
//         return date;
//     }
    
//     public static long getDateDiff(java.util.Date date1, java.util.Date date2, TimeUnit timeUnit) {
//         long diffInMillies = date2.getTime() - date1.getTime();
//         return timeUnit.convert(diffInMillies,TimeUnit.MILLISECONDS);
//     }
    
//     public static java.util.Date modifyDate(String inputDate) throws Exception{
        
//         java.util.Date date = new SimpleDateFormat("yyyy-MM-dd").parse(inputDate);
//         return date;
//     }
    
//     public static String splitDate(String date){
//         String [] split = date.split("/");
//         return split[2] + "-" + split[1] + "-" + split[0];
//     }
    
//     public static ArrayList<String> getListDateBetween2Date(String date1,String date2) throws Exception{
        
//         ArrayList<String> result = new ArrayList<>();
//         java.util.Date fromDate = modifyDate(splitDate(date1));
//         java.util.Date toDate = modifyDate(splitDate(date2));
        
//         System.out.println("From " + fromDate);
//         System.out.println("To " + toDate);

//         Calendar cal = Calendar.getInstance();
//         cal.setTime(fromDate);
//         result.add(date1);
//         while (cal.getTime().before(toDate)) {
//             cal.add(Calendar.DATE, 1);
//             //System.out.println(cal.getTime());
//             if (cal.get(Calendar.DAY_OF_WEEK)  != Calendar.SATURDAY && cal.get(Calendar.DAY_OF_WEEK)  != Calendar.SUNDAY) {
//                 result.add(new SimpleDateFormat("dd/MM/yyyy").format(cal.getTime()));
//             }
//         }
//         return result;
//     }
    
//     public  static String [] listJours(){
//         return new String [] {"Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi","Dimanche"};
//     }
    
//     public static String champNullToTiret(String nul) {
//         if (nul == null) {
//             return "-";
//         } else if (nul.compareToIgnoreCase("null") == 0) {
//             return "-";
//         } else if (nul.compareToIgnoreCase("") == 0) {
//             return "-";
//         } else {
//             return nul;
//         }
//     }
    
//     public static String anneeSuivantDateDuJour()
//     {
//         String daty = UtilitaireAcade.dateDuJour();
//         String[] split = daty.split("/");
//         int anneeSuiv = Integer.parseInt(split[2])+1;
//         String val = split[0]+"/"+split[1]+"/"+anneeSuiv;
//         return val;
//     }
    
//     public static double convertirM3enLitre(String q) {
//         if (q.contains("mc")) {
//             String[] val = UtilitaireAcade.split(q, "mc");
//             if (val.length >= 1) {
//                 return UtilitaireAcade.stringToDouble(val[0]) * 1000;
//             }
//            // System.out.println("en mettre cube  ");
//         }

//         return UtilitaireAcade.stringToDouble(q);
//     }
    
//     public static String escapeSQLString(String s) {
//         if (s == null) {
//             return null;
//         }
//         StringBuilder escapedText = new StringBuilder();
//         char currentChar;
//         for (int i = 0; i < s.length(); i++) {
//             currentChar = s.charAt(i);
//             switch (currentChar) {
//                 case '\'':
//                     escapedText.append("''");
//                     break;
//                 default:
//                     escapedText.append(currentChar);
//             }
//         }
//         return escapedText.toString();
//     }
    
//     public static void main(String[] args) {
//         String temp = "hello'nem";
// //select * from INSCRIPTION_ANNULE where nom like 'RANDRIA\''
//         System.out.println(temp);
//         System.out.println(escapeSQLString(temp));
//     }
    
//     public static String separateurMillier(String valeur){
//         return separateurMillier(' ', valeur);
//     }
    
//     public static String separateurMillier(char separateur, String valeur){
//         double val = 0;
//         if(valeur.matches("\\p{Digit}+")){
//             val  = Double.valueOf(valeur);
//         }else {
//             System.out.println("Ce n'est pas un nombre: "+valeur);
//             return valeur;
//         }
//         DecimalFormat format = new DecimalFormat("000,000"); // c'est pas necessaire de mettre 3 blocs mais je me rappelle plus la syntaxe exacte
//         DecimalFormatSymbols s = format.getDecimalFormatSymbols();
//         s.setGroupingSeparator(separateur);
//         format.setDecimalFormatSymbols(s);
//         return format.format(val);
//     }
    
//     public static int getDiffMoisPrecis(Date dateMax, Date dateMin)throws Exception{
//         try{
//             int moisdifference = diffMoisDaty(dateMax, dateMin);
// //            LocalDate localDateMax = dateMax.toLocalDate();
// //            LocalDate localDateMin = dateMin.toLocalDate();
//             Calendar cal = Calendar.getInstance();
//             cal.setTime(dateMax);
//             int dayMax = cal.get(Calendar.DAY_OF_MONTH);
//             cal.setTime(dateMin);
//             int dayMin = cal.get(Calendar.DAY_OF_MONTH);
//             int jour = dayMax-dayMin;
//             System.out.println("Nombre de jour: "+jour);
//             if(jour <= 0){
//                 //moisdifference--;
//             }
//             return moisdifference;
//         }catch(Exception e){
//             throw e;
//         }
//     }
    
//     public static String splitClassName(String arg)throws Exception{
//         try{
//             String[] res = arg.split("\\.");
//             return res[res.length - 1];
//         }catch(Exception e){
//             throw e;
//         }
//     }
    
//     public static ArrayList<String> genererDatesEntre(String date1, String date2) throws Exception{
        
//         String[] jourFerie = {};
//         Date startdate =  new java.sql.Date((UtilitaireAcade.stringToDate("dd/MM/yyyy",date1)).getTime());
//         Date enddate = new java.sql.Date((UtilitaireAcade.stringToDate("dd/MM/yyyy",date2)).getTime());
//         Calendar enddateone = Calendar.getInstance();
//         enddateone.setTime(enddate);
//         enddateone.add(Calendar.DATE, 1);
        
//         List<Date> jourFerieDate = new ArrayList<Date>();
//         for(int i = 0;i< jourFerie.length;i++){
//             jourFerieDate.add(new java.sql.Date((UtilitaireAcade.stringToDate("dd/MM/yyyy",jourFerie[i])).getTime()));
//         }
//         List<Date> dates = new ArrayList<Date>();
//         Calendar calendar = new GregorianCalendar();
//         calendar.setTime(startdate);
//         while (calendar.getTime().before(enddateone.getTime()))
//         {
//             java.util.Date result = calendar.getTime();
//             java.sql.Date dateToAdd = new java.sql.Date(result.getTime());
//             if(UtilitaireAcade.dayOfDate(dateToAdd) != 1 && UtilitaireAcade.dayOfDate(dateToAdd) != 7 && !jourFerieDate.contains(dateToAdd) ){
//                 dates.add(dateToAdd);
//             }
//             calendar.add(Calendar.DATE, 1);
//         }
//         ArrayList<String> listResult = new ArrayList<String>();
//         for(int i = 0;i< dates.size();i++){
//             listResult.add(UtilitaireAcade.formatterDaty(dates.get(i)));
//         }
//         return listResult;
//     }
    
//     public static String getAWhereIn(String[] val, String column)throws Exception{
//         String query = "";
//         try{
//             if(val.length == 0) throw new Exception("La valeur de la selection multiple est vide.");
//             query += " AND "+column+" IN (";
//             query += "'"+val[0]+"'";
//             for(int i = 1; i < val.length; i++){
//                 query += ",'"+val[i]+"'";
//             }
//             query += ") ";
//         }catch(Exception exc){
//             throw exc;
//         }
//         return query;
//     }
    
//     public static boolean estJourOuvrable(Date daty) throws Exception {
//         boolean result = false;
//         if(UtilitaireAcade.dayOfDate(daty) != 1 && UtilitaireAcade.dayOfDate(daty) != 7){
//             result = true;
//         }
//         return result;
//     }
    
//     public String getJourDeLaSemaineDate(String daty) throws Exception {
//         try{
//             Date d = this.stringDate(daty);
//             int jourdelasemaine = d.getDay();
//             String result = "-";
//             switch (jourdelasemaine){
//                 case 1:
//                  result = "Lundi";
//                  break;
//                 case 2:
//                  result = "Lundi";
//                  break;
//                 case 3:
//                  result = "Lundi";
//                  break;
//                 case 4:
//                  result = "Lundi";
//                  break;
//                 case 5:
//                  result = "Lundi";
//                  break; 
//             }
//             return result;
//         }catch(Exception exc){
//             exc.printStackTrace();
//             throw exc;
//         }
//     }
       
//     public static Date getDateAnneeProchaine(Date arg) throws Exception {
//         Date result = null;
//         try{
//             Calendar cal = Calendar.getInstance();
//             cal.setTime(arg);
//             int day = cal.get(Calendar.DAY_OF_MONTH);
//             int year = cal.get(Calendar.YEAR);
//             int mois = UtilitaireAcade.getMoisEnCoursReel();
//             String date_s = (day-1)+"/"+mois+"/"+(year+1);
//             result = UtilitaireAcade.string_date("dd/MM/yyyy",date_s);
//         }catch(Exception exc){
//             throw exc;
//         }
//         return result;
//     }
    
//     public static String formatDateRecherche(String date){
//         String result = "";
//         if(date.contains("/") & stringDate(date) != null){
//             String[] split = date.split("/");
//             result = split[2]+"-"+split[1]+"-"+split[0];
//             return result;
//         }else return date;
//     }
    
//     public static boolean checkNumber(String requested) throws Exception {
//         boolean numeric = true;
//         try {
//             Double num = Double.parseDouble(requested);
//         } catch (NumberFormatException e) {
//             numeric = false;
//         }
//         return numeric;
//     }
    
//     public static String getStringAC(String ac){
//         String finals  = "";
//         if(ac.indexOf("_")>0){
//             String[] tab = ac.split("_");
//             for(int i = 0;i<tab.length-1;i++){
//                 finals+=tab[i]+"_";
//             }
//         }
//         return finals;
//     }
    
//     public static boolean isValidDate(String input, String format) {
//         boolean valid = false;
//         try {
//             if (!input.isEmpty()) {
//                 SimpleDateFormat dateFormat = new SimpleDateFormat(format);
//                 java.util.Date output = dateFormat.parse(input);
//                 valid = dateFormat.format(output).equals(input);
//             }
//         } catch (Exception ex) {
//             valid = false;
//         }
//         return valid;
//     }
    
    
    public static String getbackGroundColor(int etat)
    {
        String color="#cce5ff";
        if(etat==0)
            color="#f4959e";
        if (etat==11)
            color="#d4edda";
        return color;
    }

    // ito cle / total (par defaut)
    public static Map<String, String[]> transformerEtiquetteToMapTotal(ValeurEtiquette[][] data) throws Exception{
        Map<String, String[]> map = new LinkedHashMap<>();
        try {
            ValeurEtiquette[][] val = data;
            for (int i = 0; i < val.length; i++) {
                String[] tabString = val[i][val[i].length - 1].getValeur().split("<BR>");

                for (int k = 0; k < tabString.length; k++) {
                    tabString[k] = tabString[k].replace(" ", "");
                }

                if (!val[i][0].getValeur().trim().isEmpty()) {
                    map.put(val[i][0].getValeur(), tabString);
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            throw new Exception("Erreur lors de la transformation");
        }
        return map;
    }

    // ra mis cle roa mitovy de ito no ampesaina
    public static Map<String, String[]> transformerEtiquetteToMapTotalMerge(ValeurEtiquette[][] data) throws Exception{
        Map<String, String[]> map = new LinkedHashMap<>();
        try {
            ValeurEtiquette[][] val = data;
            for (int i = 0; i < val.length; i++) {
                String[] tabString = val[i][val[i].length - 1].getValeur().split("<BR>");

                for (int k = 0; k < tabString.length; k++) {
                    tabString[k] = tabString[k].replace(" ", "");
                }

                if (!val[i][0].getValeur().trim().isEmpty()) {

                    String key = val[i][0].getValeur();
                    String[] nouveau = tabString;

                    if (map.containsKey(key)) {

                        System.out.println("cle = " + key);
                        String[] ancien = map.get(key);

                        int taille = Math.max(ancien.length, nouveau.length);

                        System.out.println("taille = " + taille);
                        String[] fusion = new String[taille];

                        for (int l = 0; l < taille; l++) {

                            double vAncien = 0;
                            double vNouveau = 0;

                            if (l < ancien.length) {
                                try { vAncien = parseNombreFrancais(ancien[l]); } catch(Exception e) {}
                            }

                            if (l < nouveau.length) {
                                try { vNouveau = parseNombreFrancais(nouveau[l]); } catch(Exception e) {}
                            }

                            double resultat = vAncien + vNouveau;

                            System.out.println("ancien = " + vAncien);
                            System.out.println("nouveau = " + vNouveau);
                            fusion[l] = String.valueOf(resultat);
                        }

                        map.put(key, fusion);

                    } else {
                        map.put(key, nouveau);
                    }
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            throw new Exception("Erreur lors de la transformation");
        }
        return map;
    }
    public static double parseNombreFrancais(String valeur) {
        if(valeur == null || valeur.trim().isEmpty())
            return 0;

        valeur = valeur.replace("\u00A0", "").replace(" ", "");

        valeur = valeur.replace(",", ".");

        return Double.parseDouble(valeur);
    }
}