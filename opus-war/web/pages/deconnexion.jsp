<%@ page import="user.*" %>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%
        try
        {
          if(session.getAttribute("u")!=null)
          {
            session.removeAttribute("u");
            session.removeAttribute("lien");
            session.removeAttribute("dir");
            session.removeAttribute("dirlib");
            session.removeAttribute("menu");
            session.invalidate();
          }
        }
        catch (Exception e)
        {
            // ignore cleanup errors
        }
        // Always redirect to the login page
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
%>