/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package user;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Jetta
 */
@WebServlet(name = "Visa", urlPatterns = {"/Visa"})
public class Visa extends HttpServlet {

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
        processRequest(request, response);
        UserEJB us = (UserEJB) request.getSession().getAttribute("u");
        String rolefinale = request.getParameter("colonne");
        String direc = request.getParameter("direction");
        processRequest(request, response);
        String lien = (String) request.getSession().getValue("lien");
        try {
            
            if (request.getParameterValues("rejet") != null) {
                us.ajoutrestriction(request.getParameterValues("rejet"), rolefinale, "ACT000007", direc);
            }
            if (request.getParameterValues("visa") != null) {
                us.ajoutrestriction(request.getParameterValues("visa"), rolefinale, "ACT000006", direc);
            }
            if (request.getParameterValues("annul") != null) {
                us.ajoutrestriction(request.getParameterValues("annul"), rolefinale, "ACT000005", direc);
            }
            if (request.getParameterValues("cloture") != null) {
                us.ajoutrestriction(request.getParameterValues("cloture"), rolefinale, "ACT000008", direc);
            }

            request.setAttribute("colonne", rolefinale);
            request.setAttribute("direction", direc);
            request.getRequestDispatcher("/pages/module.jsp?but=utilisateur/restrictionvisa.jsp").forward(request, response);
        } catch (Exception ex) {
            ex.printStackTrace();
            throw new ServletException(ex.getMessage());
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
