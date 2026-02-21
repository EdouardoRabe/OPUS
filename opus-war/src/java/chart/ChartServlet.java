/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package chart;

import affichage.ObjectChart;
import affichage.PageGraph;
import bean.CGenUtil;
import bean.ClassMAPTable;
import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import web.mg.cnaps.servlet.etat.UtilitaireImpression;
import net.sf.jasperreports.engine.JRException;
import reporting.ReportingCdn;
import utilitaireAcade.UtilitaireAcade;

/**
 *
 * @author nyamp
 */
@WebServlet(name = "ChartServlet", urlPatterns = {"/ChartServlet"})
public class ChartServlet extends HttpServlet {
    String nomJasper = "";
    ReportingCdn.Fonctionnalite fonctionnalite = ReportingCdn.Fonctionnalite.RECETTE;
    
    public String getNomJasper() {
        return nomJasper;
    }

    public void setNomJasper(String nomJasper) {
        this.nomJasper = nomJasper;
    }
    
     @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (JRException ex) {
            ex.printStackTrace();
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (JRException ex) {
            ex.printStackTrace();
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

      /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, Exception {
        chart(request,response);

    }
    
     private void chart(HttpServletRequest request, HttpServletResponse response) throws IOException, JRException, Exception {
        
        Map param = new HashMap();
        param.put("titre", request.getParameter("titre"));
        param.put("entete", request.getParameter("entete"));
        List dataSource = new ArrayList();
        dataSource.addAll(this.transformeData(request.getParameter("data")));
            System.out.println(dataSource.toString());
        for(int i=0;i<dataSource.size();i++){
            ObjectChart o=(ObjectChart) dataSource.get(i);
            System.out.println("x="+o.getX() +" \t y="+o.getY() +"\t key="+o.getKey());
        }
        setNomJasper(request.getParameter("chart"));
        UtilitaireImpression.imprimer(request, response, request.getParameter("chart"), param, dataSource, getReportPath());
    }
 
    
    public String getReportPath() throws IOException {
        return getServletContext().getRealPath(File.separator + "report" + File.separator +"chart" + File.separator + getNomJasper() + ".jasper");
    }
    
    private List<ObjectChart> transformeData(String data) throws ParseException{
        List<ObjectChart> liste=new ArrayList();
        String[] listedata=data.split( ";");
        System.out.println("data==  " + data);
        String x,y,key;
        for(int i=0;i<listedata.length;i+=3){
            if(i<listedata.length){
                x=listedata[i];
            }
            else{
                x=null;
            }
            if(i+1<listedata.length){
                y=listedata[i+1];
            }
            else{
                y=null;
            }
            if(i+2<listedata.length){
                key=listedata[i+2];
            }
            else{
                key=null;
            }
            
            liste.add(new ObjectChart(x,y,key));
            System.out.println("");
        }
        return liste;
    }
}
