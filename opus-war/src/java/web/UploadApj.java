package web;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import user.UserEJB;
import utilitaireAcade.UtilitaireAcade;

/**
 *
 * @author NERD
 */
@WebServlet(name = "UploadApj", urlPatterns = {"/UploadApj"})
public class UploadApj extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //fin
        HashMap<String, String> listeVal = new HashMap<String, String>();
        HashMap<String, String> fichiers = new HashMap<String, String>();
        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);

        UserEJB u = null;
        try {
            List items = upload.parseRequest(request);
            Iterator i = items.iterator();
            while (i.hasNext()) {
                String filename = null;
                FileItem item = null;
                item = (FileItem) i.next();
                if (item.isFormField()) {
                    listeVal.put(item.getFieldName(), item.getString());
                } else if (item.getName() != null && !item.getName().isEmpty()) {
                    if (filename == null) {
                        filename = item.getName();
                    }
                    filename = UtilitaireAcade.heureCourante() + UtilitaireAcade.dateDuJour() + filename;
                    filename = filename.replace(":", "");
                    filename = filename.replace("/", "-");
                    filename = filename.trim();
                    filename = filename.replace(" ", "");
                    utilitaireAcade.UtilitaireAcade.uploadFileToCdn(item.getInputStream(), filename);
                    fichiers.put(filename,item.getFieldName());
                }
            }
            String nomTable = listeVal.get("nomtable");
            String procedure = listeVal.get("procedure");
            String bute = listeVal.get("bute");
            String enfant = listeVal.get("enfant");
            String natureDuDossierchoix = listeVal.get("natureDuDossierchoix");
            String lienenf="";
            if(natureDuDossierchoix!=null)lienenf+="&natureDuDossierchoix="+natureDuDossierchoix;
            if(enfant!=null){
                
                lienenf += "&enfant=yes";
            }
//            System.out.println("----- BUTE = "+bute);
            String id = listeVal.get("id");
            u = (UserEJB) request.getSession().getAttribute("u");
            String lien = request.getSession().getAttribute("lien").toString();
            Iterator it = fichiers.entrySet().iterator();
            //u.createUploadedPjService(listeVal, it, nomTable, procedure, id);
//            while (it.hasNext()) {
//                Map.Entry item = (Map.Entry)it.next();
//                String key = item.getKey().toString();
//                String value = item.getValue().toString();
//                String valI = value.substring(8, value.length());
//                String libelle = listeVal.get("libelle"+valI);
////                System.out.println("LIBELLE : " + libelle+" | CHEMIN : "+key);
//                u.createUploadedPj(nomTable, procedure, libelle, key, id);
//            }
            response.sendRedirect("/pask-war/pages/" + lien + "?but=" + bute + "&id=" + id+lienenf);
        } catch (Exception ex) {
            ex.printStackTrace();
            System.out.println("Exception : " + ex.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }

}
