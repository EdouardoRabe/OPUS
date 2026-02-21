package upfiles;

import java.io.File;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class FileLocationContextListener implements ServletContextListener {

    public void contextInitialized(ServletContextEvent servletContextEvent) {
        ServletContext context   = servletContextEvent.getServletContext();

        File           file      = new File(StringUtil.PATH_DIR);
        if (!file.exists()) {
            file.mkdirs();
        }

        context.setAttribute(StringUtil.FILES_DIR_FILE, file);
        context.setAttribute(StringUtil.FILES_DIR, StringUtil.PATH_DIR);
    }

    public void contextDestroyed(ServletContextEvent servletContextEvent) {
    }
}
