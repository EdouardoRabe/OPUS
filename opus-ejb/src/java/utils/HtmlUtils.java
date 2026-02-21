package utils;

public class HtmlUtils {

    public static String escapeHtmlAccents(String input) {
        if (input == null) return null;

        String[][] accents = {
                {"à", "&agrave;"}, {"â", "&acirc;"}, {"ä", "&auml;"}, {"á", "&aacute;"}, {"ã", "&atilde;"}, {"å", "&aring;"},
                {"è", "&egrave;"}, {"é", "&eacute;"}, {"ê", "&ecirc;"}, {"ë", "&euml;"},
                {"ì", "&igrave;"}, {"í", "&iacute;"}, {"î", "&icirc;"}, {"ï", "&iuml;"},
                {"ò", "&ograve;"}, {"ó", "&oacute;"}, {"ô", "&ocirc;"}, {"ö", "&ouml;"}, {"õ", "&otilde;"}, {"ø", "&oslash;"},
                {"ù", "&ugrave;"}, {"ú", "&uacute;"}, {"û", "&ucirc;"}, {"ü", "&uuml;"},
                {"ç", "&ccedil;"}, {"ñ", "&ntilde;"},

                {"À", "&Agrave;"}, {"Â", "&Acirc;"}, {"Ä", "&Auml;"}, {"Á", "&Aacute;"}, {"Ã", "&Atilde;"}, {"Å", "&Aring;"},
                {"È", "&Egrave;"}, {"É", "&Eacute;"}, {"Ê", "&Ecirc;"}, {"Ë", "&Euml;"},
                {"Ì", "&Igrave;"}, {"Í", "&Iacute;"}, {"Î", "&Icirc;"}, {"Ï", "&Iuml;"},
                {"Ò", "&Ograve;"}, {"Ó", "&Oacute;"}, {"Ô", "&Ocirc;"}, {"Ö", "&Ouml;"}, {"Õ", "&Otilde;"}, {"Ø", "&Oslash;"},
                {"Ù", "&Ugrave;"}, {"Ú", "&Uacute;"}, {"Û", "&Ucirc;"}, {"Ü", "&Uuml;"},
                {"Ç", "&Ccedil;"}, {"Ñ", "&Ntilde;"},

                {"’", "&rsquo;"}, {"‘", "&lsquo;"},
                {"“", "&ldquo;"}, {"”", "&rdquo;"},
                {"–", "&ndash;"}, {"—", "&mdash;"},
                {"…", "&hellip;"}
        };

        for (String[] pair : accents) {
            input = input.replace(pair[0], pair[1]);
        }

        return input;
    }

}
