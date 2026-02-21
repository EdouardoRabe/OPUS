package utils;

public class StringUtils {
    public static String setMajStart(String str) {
        str = str.substring(0,1).toUpperCase()+str.substring(1);
        return str;
    }

}