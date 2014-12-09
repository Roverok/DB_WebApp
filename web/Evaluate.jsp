<%@page import="org.apache.commons.fileupload.FileUploadException"%>
<%@page import="java.io.File"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="java.util.*"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.FileItemFactory"%>
<%@page import="javax.naming.InitialContext"%>
<%@page import="javax.naming.Context"%>

<%@ page import="javax.servlet.*,java.text.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="data" class="data.EntryData" scope="session"/>
<jsp:setProperty name="data" property="*"/>

<!DOCTYPE html>
<html>
<head>
    <title>DataMining Cloud App | Upload</title>
    <meta name="description" content="DataMining Cloud App | Tomáš Kačur">
    <meta name="author" content="Tomáš Kačur">
    <link rel="stylesheet" href="style.css" type="text/css">
    <link rel="stylesheet" href="check_radio_style.css" type="text/css">
    <link rel="stylesheet" href="scrollbar.css" type="text/css">
    
    
    <script src="js/jquery-1.8.2.min.js"></script>
    <script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.8.1/jquery.validate.min.js"></script>
    <script src="js/reloading.js"></script>
    
   

</head>

<body>
    <%
Context env = (Context)new InitialContext().lookup("java:comp/env");
String filePath = (String)env.lookup("file-upload");

String prava=(String) session.getAttribute("prava");

if (prava=="user" || prava=="admin") {   
    %>
<div id="all">
        
        <header>
            <div id="menu">
                <%
                if (prava=="admin") {
                %>
                <a href="Upload.jsp" class="upload"></a>
                <%
                }
                %>
                <a href="mainApp.jsp" class="home"></a>
                <a href="BuildModelPart.jsp" class="build"></a>
                <a href="" class="zhlukovanie"></a>
                <a href="Evaluate.jsp" class="evaluate active"></a>
                <%
                if (prava=="admin") {
                %>
                <a href="Monitoring.jsp" class="monitoring"></a>
<%
                }
                %>
                <a href="mainApp.jsp?logout" class="logout"></a>

                <a href="mainApp.jsp?logout"></a>
            </div>
            <h1><img src="cloudApp.png"/>DataMining Cloud App</h1>
        </header>

        
         <div id="formular">
             <div id="dataset">
             <h3>Vyberte testovaciu mnozinu</h3>
             <form action="Evaluate.jsp" method="post">
               
             
              <select name="vstupne_data">
               <%   File zoznam = new File ( filePath );
        		       File[] contents = zoznam.listFiles();
                               int j;
       	                       String extension = "";
                               
               		       for ( int i = 0; i < contents.length ; i++ ) {
        
                                if (contents[i].isFile())
                                {
                                j = contents[i].getName().lastIndexOf(".");
                                if (j > 0) {
                                            extension = contents[i].getName().substring(j+1);
                                            }
                                if (extension.equals("xml")) 
                                {
                                    out.println("<option value=\""+contents[i].getName()+"\">"+contents[i].getName()+"</option>");
                                    
                                }                                           
                                }
                               }
                               %>
                               </select>
                               <br>
                               <input type="submit" name="eval_submit" value="Odoslat">
                               </form>
             </div>
                                <div id="textOut">
                                     <h3>Výstup:</h3>
                               <div id="results">
                                  <jsp:include page="Evaluate_result.jsp" />
                      

                    </div>
                                </div>
   
         </div>
             
                
                

         <footer>
            <div style="float:left;">
            <%
             Date dNow = new Date( );
            SimpleDateFormat ft =  new SimpleDateFormat ("dd.MM.yyyy hh:mm");
            out.print( "" + ft.format(dNow) + "");
             %>
            </div><div style="float:right;">
            © kacio 2012
            </div>
        </footer>
        
    </div> 
<%
}      
else
{
%>    
<strong>Pristup zamietnuty</strong>
<%
}
%>  
</body>
</html>
