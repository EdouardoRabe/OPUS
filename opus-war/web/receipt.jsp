<%@page import="java.util.Enumeration"%>

<% 
    Enumeration<String> parameterNames = request.getParameterNames();

    while (parameterNames.hasMoreElements()) {
        String paramName = parameterNames.nextElement();
        System.out.println(paramName);
        String[] paramValues = request.getParameterValues(paramName);
        for (int i = 0; i < paramValues.length; i++) { 
            String paramValue = paramValues[i]; 
            System.out.println("t" + paramValue);
            System.out.println("");
        } 
    } 
%>