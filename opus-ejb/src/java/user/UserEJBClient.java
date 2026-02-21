// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3)
// Source File Name:   UserEJBClient.java
package user;

import java.util.Properties;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

// Referenced classes of package user:
//            UserEJBHome, UserEJBLocal
public class UserEJBClient {

    public static UserEJBRemote lookupUserEJBBeanRemote() {
        try {
            Properties properties = new Properties();
            properties.put(Context.INITIAL_CONTEXT_FACTORY, "org.jboss.naming.remote.client.InitialContextFactory");
            properties.put(Context.PROVIDER_URL, "remote://127.0.0.1:4447");
            properties.put(Context.SECURITY_PRINCIPAL, "opus");
            properties.put(Context.SECURITY_CREDENTIALS, "opus123");
            properties.put("jboss.naming.client.ejb.context", true);
            final Context context = new InitialContext(properties);
            return (UserEJBRemote) context.lookup("opus/opus-ejb/UserEJBBean!user.UserEJBRemote");
        } catch (NamingException ne) {
            throw new RuntimeException(ne);
        }
    }
    
    public static UserEJB lookupUserEJBBeanLocal() {
        try {
            Context c = new InitialContext();
            return (UserEJB) c.lookup("java:module/UserEJBBean!user.UserEJB");
        } catch (NamingException ne) {
//            Logger.getLogger(getClass().getName()).log(Level.SEVERE, "exception caught", ne);
            throw new RuntimeException(ne);
        }
    }
}
