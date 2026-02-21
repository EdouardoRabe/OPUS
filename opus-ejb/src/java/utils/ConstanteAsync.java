package utils;

/**
 * Constantes pour les fonctionnalites async et IA du projet OPUS.
 * Configurer les cles API et URLs ici.
 */
public class ConstanteAsync {

    // --- Configuration IA (Gemini) ---
    public static final String API_KEY = "";
    public static final String API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=" + API_KEY;
    public static final String ADK_URL = "http://localhost:8000";
    public static final String AI_CONTEXT = "Application OPUS";
    public static final String AI_DEFINITIONS = "";

    // --- Couleurs pour les graphiques ---
    public static final String[] couleurs = {
        "#FF5733", "#33FF57", "#3357FF", "#F1C40F", "#8E44AD", "#1ABC9C", "#E74C3C", "#2ECC71", "#3498DB", "#9B59B6",
        "#34495E", "#16A085", "#27AE60", "#2980B9", "#D35400", "#C0392B", "#BDC3C7", "#7F8C8D", "#FFB6C1", "#00CED1",
        "#FFD700", "#7FFF00", "#DC143C", "#4B0082", "#FF8C00", "#20B2AA", "#FF69B4", "#FF6347", "#40E0D0", "#6A5ACD",
        "#00FA9A", "#CD5C5C", "#9370DB", "#48D1CC", "#F08080", "#E9967A", "#8FBC8F", "#4169E1", "#800000", "#191970",
        "#FFA07A", "#FF4500", "#ADFF2F", "#00BFFF", "#DAA520", "#B22222", "#00FF7F", "#D8BFD8", "#008080", "#BDB76B"
    };
}
