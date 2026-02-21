package web.socket;

import javax.json.Json;
import javax.json.JsonObject;
import javax.websocket.OnClose;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint("/ws/alarm")
public class AlarmSocket {
    private static Set<Session> sessions = ConcurrentHashMap.newKeySet();

    @OnOpen
    public void onOpen(Session session) {
        sessions.add(session);
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session);
    }

    public static void broadcast(String refUsr, String message) {
        JsonObject json = Json.createObjectBuilder()
                .add("refUser", refUsr)
                .add("message", message)
                .build();

        String jsonString = json.toString();

        for (Session session : sessions) {
            if (session.isOpen()) {
                session.getAsyncRemote().sendText(jsonString);
            }
        }
    }
}

