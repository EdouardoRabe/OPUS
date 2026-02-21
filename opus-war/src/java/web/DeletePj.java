/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package web;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import user.UserEJB;

/**
 *
 * @author NERD
 */
@WebServlet(name = "DeletePj", urlPatterns = {"/DeletePj"})
public class DeletePj extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idtodelete = request.getParameter("idpj");
        String nomtable = request.getParameter("nomtable");
        String procedure = request.getParameter("procedure");
        String but = request.getParameter("but");
        String bute = request.getParameter("bute");
        String id = request.getParameter("id");
        String enfant= request.getParameter("enfant");
        UserEJB u = null;
        try {
            u = (UserEJB) request.getSession().getAttribute("u");
            u.deleteUploadedPj(nomtable, idtodelete);
            String lien = request.getSession().getAttribute("lien").toString();
            response.sendRedirect("/opus/pages/" + lien + "?but="+but+"&bute="+bute+"&id=" + id+"&nomtable="+nomtable+"&procedure="+procedure+"&enfant="+enfant);
        } catch (Exception ex) {
            ex.printStackTrace();
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
