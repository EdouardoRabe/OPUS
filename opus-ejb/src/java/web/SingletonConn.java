package web;

import utilitaire.UtilDB;

import java.sql.Connection;

public class SingletonConn {
    private static SingletonConn instance;
    private Connection connection;


    private SingletonConn() {
        try {
            this.connection = new UtilDB().GetConn();
        } catch (Exception ex) {
            System.err.println(ex.getMessage());
        }
    }

    public static SingletonConn getInstance() throws Exception {
        if (instance == null || instance.getConnection().isClosed()) {
            instance = new SingletonConn();
        }
        return instance;
    }

    public Connection getConnection() {
        return connection;
    }
}
