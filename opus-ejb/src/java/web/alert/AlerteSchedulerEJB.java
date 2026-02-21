package web.alert;

import bean.CGenUtil;
import web.SingletonConn;
import web.socket.AlarmSocket;

import javax.ejb.Schedule;
import javax.ejb.Singleton;
import javax.ejb.Startup;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

@Singleton
@Startup
public class AlerteSchedulerEJB {

    private Connection connection;

    public AlerteSchedulerEJB() {
        try {
            connection = SingletonConn.getInstance().getConnection();
        } catch (Exception e) {
            System.err.println(e.getMessage());
        }
    }

    @Schedule(second = "0", minute = "*", hour = "*", persistent = false)
    public void verifierAlertes() throws Exception {
        if (connection == null) return;
        if (connection.isClosed()) {
            connection = SingletonConn.getInstance().getConnection();
        }

    }


}
