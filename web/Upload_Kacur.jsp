<%@page import="javax.naming.InitialContext"%>
<%@page import="javax.naming.Context"%>
<%@page import="org.apache.tomcat.util.http.fileupload.util.Streams"%>
<%@page import="java.io.InputStream"%>
<%@page import="org.apache.tomcat.util.http.fileupload.FileItemStream"%>
<%@page import="org.apache.tomcat.util.http.fileupload.FileItemIterator"%>
<%@page import="org.apache.tomcat.util.http.fileupload.servlet.ServletFileUpload"%>
<%@page import="org.apache.tomcat.jni.OS"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>

<%@page import="java.util.*"%>
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

String prava=(String) session.getAttribute("prava");

if (prava=="admin") {   
    %>
<div id="all">
        
        <header>
            <div id="menu">
                <a href="mainApp.jsp" class="home active"></a>
                <a href="BuildModelPart.jsp" class="build"></a>
                <a href="VisualizationPart.jsp" class="visual"></a>
                <%
                if (prava=="admin") {
                %>
                <a href="Upload.jsp">[Upload]</a>
                <%
                }
                %>
                <a href="mainApp.jsp?logout">[Logout]</a>
            </div>
            <h1><img src="cloudApp.png"/>DataMining Cloud App</h1>
        </header>

        
         <div id="formular">

             
             
             
        <FORM  ENCTYPE="multipart/form-data" ACTION="Upload.jsp" METHOD=POST>
                <INPUT NAME="F1" TYPE="file">
                <INPUT TYPE="submit" VALUE="Send File" >      
     </FORM>
       
             
 <%
        //to get the content type information from JSP Request Header
        String contentType = request.getContentType();
        //here we are checking the content type is not equal to Null and as well as the passed data from mulitpart/form-data is greater than or  equal to 0
        
        if ((contentType != null) && (contentType.indexOf("multipart/form-data") >= 0)) 
        {
                DataInputStream in = new DataInputStream(request.
getInputStream());
                //we are taking the length of Content type data
                int formDataLength = request.getContentLength();
                byte dataBytes[] = new byte[formDataLength];
                int byteRead = 0;
                int totalBytesRead = 0;
                //this loop converting the uploaded file into byte code
                while (totalBytesRead < formDataLength) {
                        byteRead = in.read(dataBytes, totalBytesRead, 
formDataLength);
                        totalBytesRead += byteRead;
                        }
                                        String file = new String(dataBytes);
                //for saving the file name
                String saveFile = file.substring(file.indexOf("filename=\"") + 10);
                saveFile = saveFile.substring(0, saveFile.indexOf("\n"));
                saveFile = saveFile.substring(saveFile.lastIndexOf("\\")
 + 1,saveFile.indexOf("\""));
                int lastIndex = contentType.lastIndexOf("=");
                String boundary = contentType.substring(lastIndex + 1,
contentType.length());
                int pos;
                //extracting the index of file 
                pos = file.indexOf("filename=\"");
                pos = file.indexOf("\n", pos) + 1;
                pos = file.indexOf("\n", pos) + 1;
                pos = file.indexOf("\n", pos) + 1;
                int boundaryLocation = file.indexOf(boundary, pos) - 4;
                int startPos = ((file.substring(0, pos)).getBytes()).length;
                int endPos = ((file.substring(0, boundaryLocation))
.getBytes()).length;
                // creating a new file with the same name and writing the content in new file
                FileOutputStream fileOut = new FileOutputStream(saveFile);
                fileOut.write(dataBytes, startPos, (endPos - startPos));
                fileOut.flush();
                fileOut.close();
                                %>
                                
                                <Br><table border="2"><tr><td><b>You have successfully
 upload the file by the name of:</b>
                <% out.println(saveFile); %></td></tr></table> <%
                }
%>

             
             
         </div>
             
                
                

        <footer>© kacio 2012</footer>
        
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
