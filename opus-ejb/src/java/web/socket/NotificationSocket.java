package web.socket;

import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * WebSocket pour les notifications en temps reel.
 * Chaque session peut s'identifier avec son userId via un message "register:userId".
 * broadcast() envoie a tous, broadcastToUser() cible un utilisateur specifique.
 */
@ServerEndpoint("/ws/notifications")
public class NotificationSocket {
    private static Set<Session> sessions = ConcurrentHashMap.newKeySet();
    // Map userId -> Set de sessions (un user peut avoir plusieurs onglets)
    private static Map<String, Set<Session>> userSessions = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session) {
        sessions.add(session);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        // Le client envoie "register:<userId>" pour s'identifier
        if (message != null && message.startsWith("register:")) {
            String userId = message.substring("register:".length()).trim();
            session.getUserProperties().put("userId", userId);
            userSessions.computeIfAbsent(userId, k -> ConcurrentHashMap.newKeySet()).add(session);
        }
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session);
        String userId = (String) session.getUserProperties().get("userId");
        if (userId != null) {
            Set<Session> userSet = userSessions.get(userId);
            if (userSet != null) {
                userSet.remove(session);
                if (userSet.isEmpty()) {
                    userSessions.remove(userId);
                }
            }
        }
    }

    /**
     * Broadcast a tous les clients connectes.
     */
    public static void broadcast(String message) {
        for (Session session : sessions) {
            if (session.isOpen()) {
                session.getAsyncRemote().sendText(message);
            }
        }
    }

    /**
     * Envoyer un message a un utilisateur specifique (toutes ses sessions/onglets).
     */
    public static void broadcastToUser(String userId, String message) {
        Set<Session> userSet = userSessions.get(userId);
        if (userSet != null) {
            for (Session session : userSet) {
                if (session.isOpen()) {
                    session.getAsyncRemote().sendText(message);
                }
            }
        }
    }
}
