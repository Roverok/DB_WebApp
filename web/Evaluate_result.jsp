<%-- 
    Document   : Evaluate_result
    Created on : 19.4.2013, 19:08:50
    Author     : sasi
--%>

<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.naming.InitialContext"%>
<%@page import="javax.naming.Context"%>
<jsp:useBean id="eval" class="testing.EvaluateModel" scope="session"/>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
           <%     String meno=request.getParameter("vstupne_data");
                  Context env = (Context)new InitialContext().lookup("java:comp/env");
                  String filePath = (String)env.lookup("file-upload");              
                          
if(meno!=null) {
    boolean kontrola = true;
    String zlozka=meno.replaceAll("\\.", "_");
   if(!new File(filePath+"/"+zlozka+"/test-instances").exists()){
       out.println("neexistuje testovacia zlozka");
       kontrola = false;
          }
    
   if(!new File(filePath+"/"+zlozka+"/model").exists()){
       out.println("neexistuje model");
       kontrola = false;
             }
       if(kontrola)
     eval.main(filePath+"/"+zlozka, request, response);
}
else{
        out.println("Vyberte data");
    }
%>
    </body>
</html>
