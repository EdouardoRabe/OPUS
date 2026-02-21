/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package upfiles;

import bean.UploadPj;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
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
 * @author rahar
 */
@WebServlet(name = "UploadDownloadFileServletDocs", urlPatterns = {"/UploadDownloadFileServletDocs"})
public class UploadDownloadFileServletDocs extends HttpServlet {
    private static final long              serialVersionUID = 1L;
    private              ServletFileUpload uploader         = null;

    private void createDir(String path) {
        File file = new File(path);
        if (!file.exists()) file.mkdirs();
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
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet UploadDownloadFileServletDocs</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet UploadDownloadFileServletDocs at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    
    @Override
    public void init() {
        DiskFileItemFactory fileFactory = new DiskFileItemFactory();
        File                filesDir    = (File) getServletContext().getAttribute(StringUtil.FILES_DIR_FILE);
        fileFactory.setRepository(filesDir);
        this.uploader = new ServletFileUpload(fileFactory);
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("---/*mididitra servlet docs");
        PrintWriter             out      = response.getWriter();
        HashMap<String, String> params   = new HashMap<>();
        HashMap<String, String> fichiers = new HashMap<>();
        try {
            if (!ServletFileUpload.isMultipartContent(request)) {
                throw new ServletException("Content type is not multipart/form-data");
            }
            //String dossier = request.getParameter(StringUtil.DOSS);
            String dossier = "docs";
            String path    = request.getServletContext().getAttribute(StringUtil.FILES_DIR) + File.separator + dossier;
            createDir(path);
            System.out.println(path);
            List<FileItem> fileItemsList = uploader.parseRequest(request);

            for (FileItem fileItem : fileItemsList) {
                if (fileItem.getName() != null && !fileItem.isFormField()) {
                    String name = UtilitaireAcade.heureCourante() + UtilitaireAcade.dateDuJour() + fileItem.getName();
                    String nameVal = name
                            .replace(":", "")
                            .replace("/", "-")
                            .replace(" ", "");

                    String dir  = path + File.separator + nameVal;
                    File   file = new File(dir);
                    fileItem.write(file);
                    fichiers.put(nameVal, fileItem.getFieldName());
                } else {
                    params.put(fileItem.getFieldName(), fileItem.getString());
                }
            }
            //AttacherFichier fichier
            String iddossier            = params.get("dossier");
            String natureDuDossierchoix = params.get("natureDuDossierchoix");
            String lienenf              = "";
            if (iddossier != null)
            { lienenf = "&iddossier=" + iddossier; }

            if (natureDuDossierchoix != null)
            { lienenf = "&natureDuDossierchoix=" + natureDuDossierchoix; }

            UserEJB  u    = (UserEJB) request.getSession().getAttribute("u");
            Iterator it   = fichiers.entrySet().iterator();

//            u.createUploadedPjService(iddossier, params, it, params.get("nomtable"), params.get("procedure"), params.get("id"));
            System.out.println("----but "+params.get("bute"));
            String mere=null;
            //String lienRedirection = "/opus/pages/module.jsp?but=" + params.get("bute");
            if(params.get("id")!=null){
                //lienRedirection += "&id=" + params.get("id");
                mere=params.get("id");
            }
            if(params.get("idDir")!=null){
                //lienRedirection += "&idDir=" + params.get("idDir");
                mere=params.get("idDir");
            }
            if(params.get("tab")!=null){
                //lienRedirection += "&tab=" + params.get("tab");
            }
            UploadPj file = (UploadPj)u.createUploadedPjServiceRetour(iddossier, params, it, params.get("nomtable"), params.get("procedure"), mere);
            //response.sendRedirect(lienRedirection);
            out.println(file.getChemin());
        } catch (Exception e) {
            e.printStackTrace();
            out.write("Exception in uploading file. Cause : " + e.getMessage());
            //throw e;
        } finally {
            if (out != null) out.close();
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
