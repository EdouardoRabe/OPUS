package servlet;

import utilitaire.*;
import utilitaireAcade.UtilitaireAcade;

import java.sql.*;
import java.io.*;
import java.util.Date;
import java.text.SimpleDateFormat;
import bean.ClassMAPTable;
import java.lang.reflect.Field;
import bean.CGenUtil;
import affichage.TableauRecherche;
import com.itextpdf.text.Document;
import com.itextpdf.text.html.simpleparser.HTMLWorker;
import com.itextpdf.text.pdf.PdfWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.itextpdf.text.PageSize;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * <p>
 * Title: Gestion des recettes </p>
 * <p>
 * Description: </p>
 * <p>
 * Copyright: Copyright (c) 2005</p>
 * <p>
 * Company: </p>
 *
 * @author unascribed
 * @version 1.0
 */
@WebServlet(name = "ServletDownloadGroupe", urlPatterns = {"/downloadGroupe"})
public class ServletDownloadGroupe extends HttpServlet {

    protected void doPost(HttpServletRequest arg0, HttpServletResponse arg1)
            throws ServletException, IOException {
        OutputStream os = arg1.getOutputStream();
        try {
            String ext = arg0.getParameter("ext");
            //zString donn=arg0.getParameter("donnee");
            String awhere = arg0.getParameter("awhere");
            if (awhere == null) {
                awhere = "";
            }
            arg1.setContentType("text/plain");
            SimpleDateFormat fd = new SimpleDateFormat("yyyy-MM-dd");
            String d = fd.format(new Date());
            String fileName = arg0.getParameter("titre")+"-" + d + "." + ext;
            arg1.setHeader("Content-Disposition", "attachment;filename="+fileName);

            String type = arg0.getParameter("donnee");
            String logo = getServletContext().getRealPath(File.separator + "dist" + File.separator + "img" + File.separator + "logo.jpg");
            String logo_min = getServletContext().getRealPath(File.separator + "dist" + File.separator + "img" + File.separator + "logo_min.jpg");

            if (type.compareTo("0") == 0) {
                String htmlStringBasPage = "";
                if (arg0.getParameter("recap") != null && arg0.getParameter("nombreEncours") != null) {
                    int nombre = UtilitaireAcade.stringToInt(arg0.getParameter("nombreEncours"));
                    double montant = UtilitaireAcade.stringToDouble(arg0.getParameter("recap"));
                    htmlStringBasPage = UtilitaireFormat.generateBasPage(nombre, montant);
                }
                if (ext.compareTo("xls") == 0) {
                    arg1.setContentType("application/vnd.ms-excel");
                    String htmlStringEntete = UtilitaireFormat.generateEntete(arg0.getParameter("titre"), logo_min);
                    os.write((htmlStringEntete + "" + arg0.getParameter("table").replace('*', '"') + "" + htmlStringBasPage).getBytes());
                }
                if (ext.compareTo("pdf") == 0) {
                    int estPaysage = 0;
                    Document document = null;
                    if(arg0.getParameter("orientation").equals("1")) estPaysage = 1;
                    arg1.setContentType("application/pdf");
                    File fichier = new File(getServletContext().getRealPath("") + fileName);

                    String htmlStringEntete = UtilitaireFormat.generateEntete(arg0.getParameter("titre"), logo);
                    htmlStringEntete += arg0.getParameter("table").replace('*', '"') + "</body></html>";

                    String fileNameWithPath = getServletContext().getRealPath("") + fileName;
                    OutputStream file = new FileOutputStream(new File(fileNameWithPath));
                    if(estPaysage == 1){
                        document = new Document(PageSize.A4.rotate());
                    }else{
                        document = new Document();
                    }
                    try {
                        PdfWriter.getInstance(document, file);
                        document.open();
                        HTMLWorker htmlWorker = new HTMLWorker(document);
                        htmlWorker.parse(new StringReader(htmlStringEntete));
                        htmlWorker.parse(new StringReader(htmlStringBasPage));
                        document.close();
                        file.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    System.out.println("PDF Created!");

                    // This should send the file to browser
                    OutputStream out = arg1.getOutputStream();
                    FileInputStream in = new FileInputStream(fileNameWithPath);

                    byte[] buffer = new byte[4096];
                    int length;
                    while ((length = in.read(buffer)) > 0) {
                        out.write(buffer, 0, length);
                    }
                    in.close();
                    out.flush();
                    fichier.delete();
                } else {
                    String donnee = arg0.getParameter(ext);
                    //System.out.println(donnee);
                    os.write((donnee).replace('*', '"').getBytes());
                    os.flush();
                }

            } else if (type.compareTo("1") == 0) {
                String htmlStringBasPage = "";

                

                String[] entete = UtilitaireAcade.split(arg0.getParameter("entete"), ";");
                String[] entetelibelle = UtilitaireAcade.split(arg0.getParameter("entetelibelle"), ";");

                String colDefaut = arg0.getParameter("colDefaut");
                String[] lcD = null;
                String somDefaut = arg0.getParameter("somDefaut");
                String[] lsD = null;
                String ordre = arg0.getParameter("ordre");
                if (somDefaut.compareTo("") != 0 || somDefaut != null) {
                    lsD = UtilitaireAcade.split(somDefaut, ",");
                }
                if (colDefaut.compareTo("") != 0 || colDefaut != null) {
                    lcD = UtilitaireAcade.split(colDefaut, ",");
                }
                ClassMAPTable o = (ClassMAPTable) arg0.getSession().getAttribute("critere");

                Connection con = (new UtilDB()).GetConn();

                bean.ResultatEtSomme cx = (bean.ResultatEtSomme) CGenUtil.rechercherGroupe(o, lcD, lsD, null, null, awhere, lsD, ordre, con);
                con.close();
                ClassMAPTable[] c = (ClassMAPTable[]) cx.getResultat();
                TableauRecherche tr = new TableauRecherche(c, entete);
                tr.setLibelleAffiche(entetelibelle);
                tr.makeHtmlPDF();
                if (arg0.getParameter("recap") != null) {
                    int nombre = tr.getData().length;
                    double montant = UtilitaireAcade.stringToDouble(arg0.getParameter("recap"));
                    htmlStringBasPage = UtilitaireFormat.generateBasPage(nombre, montant);
                }
                
                
                if (ext.compareToIgnoreCase("xml") == 0) {
                    os.write(tr.getExpxml().getBytes());
                } else if (ext.compareToIgnoreCase("csv") == 0) {
                    os.write(tr.getExpcsv().getBytes());

                } else if (ext.compareToIgnoreCase("xls") == 0) {
                    arg1.setContentType("application/vnd.ms-excel");
                    String htmlStringEntete = UtilitaireFormat.generateEntete(arg0.getParameter("titre"), logo_min);
                    os.write((htmlStringEntete + "" + tr.getHtml() + "" + htmlStringBasPage).getBytes());
                    ;
                } else if (ext.compareToIgnoreCase("pdf") == 0) {
                    tr.makeHtmlPDF();
                    //System.out.println(body);
                    int estPaysage = 0;
                    Document document = null;
                    if(arg0.getParameter("orientation").equals("1")) estPaysage = 1;
                    arg1.setContentType("application/pdf");
                    File fichier = new File(getServletContext().getRealPath("") + fileName);

                    String htmlStringEntete = UtilitaireFormat.generateEntete(arg0.getParameter("titre"), logo);
                    htmlStringEntete += tr.getHtmlPDF();


                    String fileNameWithPath = getServletContext().getRealPath("") + fileName;
                    OutputStream file = new FileOutputStream(new File(fileNameWithPath));
                    if(estPaysage == 1){
                        document = new Document(PageSize.A4.rotate());
                    }else{
                        document = new Document();
                    }
                    try {
                        PdfWriter.getInstance(document, file);
                        document.open();
                        HTMLWorker htmlWorker = new HTMLWorker(document);
                        htmlWorker.parse(new StringReader(htmlStringEntete));
                        htmlWorker.parse(new StringReader(htmlStringBasPage));

                        document.close();
                        file.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    System.out.println("PDF Created!");

                    // This should send the file to browser
                    OutputStream out = arg1.getOutputStream();
                    FileInputStream in = new FileInputStream(fileNameWithPath);

                    byte[] buffer = new byte[4096];
                    int length;
                    while ((length = in.read(buffer)) > 0) {
                        out.write(buffer, 0, length);
                    }
                    in.close();
                    out.flush();
                    fichier.delete();
                }
                os.flush();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            os.close();
        }
    }

    protected void doGet(HttpServletRequest arg0, HttpServletResponse arg1)
            throws ServletException, IOException {
    }
}
