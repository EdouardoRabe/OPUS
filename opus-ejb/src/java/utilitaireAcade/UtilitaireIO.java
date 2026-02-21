/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package utilitaireAcade;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import org.xml.sax.helpers.DefaultHandler;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

/**
 *
 * @author Amboara
 */
public class UtilitaireIO {    
    
    public static String readResponse(HttpURLConnection con) throws Exception {
        return readResponse(con.getInputStream());
    }
    
    public static String readResponse(InputStream inp) throws Exception {
        BufferedReader in = new BufferedReader(new InputStreamReader(inp));
        String inputLine;
        StringBuffer content = new StringBuffer();
        while ((inputLine = in.readLine()) != null) {
            content.append(inputLine);
        }
        in.close();
        return content.substring(0);
    }
    
    public static void parseXML(InputStream inputStream, DefaultHandler handler) throws Exception {        
        SAXParserFactory factory = SAXParserFactory.newInstance();
        SAXParser saxParser = factory.newSAXParser();
        saxParser.parse(inputStream, handler); 
    }
}
