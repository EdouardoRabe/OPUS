/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package user;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import utilitaire.UtilDB;

/**
 *
 * @author Jetta
 */
@WebServlet(name = "Restriction", urlPatterns = {"/Restriction"})
public class Restriction extends HttpServlet {

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
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        Connection con = null;
        try {
            String ida = request.getParameter("idacti");
            String nt = request.getParameter("nomt");
            String idr = request.getParameter("idro");
            String departe = request.getParameter("direction");
            utilisateurAcade.Restriction pr = new utilisateurAcade.Restriction();
            pr.setIdrole(idr);
            pr.setIdaction(ida);
            pr.setTablename(nt);
            String req = "delete from restriction where 3>1 ";
            if (idr != null && idr.compareToIgnoreCase("") != 0) {
                req += "and idrole='" + idr + "'";
            }
            if (nt != null && nt.compareToIgnoreCase("") != 0) {
                req += " and tablename='" + nt + "'";
            }
            if (ida != null && ida.compareToIgnoreCase("") != 0) {
                req += " and idaction='" + ida + "'";
            }
             if (departe != null && departe.compareToIgnoreCase("") != 0) {
                req += " and iddirection='" + departe + "'";
            }
            out.print(req);
            con = new UtilDB().GetConn();
            con.setAutoCommit(false);
            Statement stat = con.createStatement();
            stat.executeUpdate(req);
            con.commit();
            response.getWriter().write(req);
        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }

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
