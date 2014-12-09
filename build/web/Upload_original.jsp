<%@page import="org.apache.commons.fileupload.FileUploadException"%>
<%@page import="java.io.File"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="java.util.*"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.FileItemFactory"%>
<%@page import="javax.naming.InitialContext"%>
<%@page import="javax.naming.Context"%>



<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="data" class="data.EntryData" scope="session"/>
<jsp:setProperty name="data" property="*"/>

<!DOCTYPE html>
<html>
<head>
    <title>DataMining Cloud App | Upload</title>
    <meta name="description" content="DataMining Cloud App">
    <meta name="author" content="">
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

if (prava=="admin") {   
    %>
<div id="all">
        
        <header>
            <div id="menu">
                <%
                if (prava=="admin") {
                %>
                <a href="Upload.jsp" class="upload active"></a>
                <%
                }
                %>
                <a href="mainApp.jsp" class="home"></a>
                <a href="BuildModelPart.jsp" class="build"></a>
                <a href="" class="zhlukovanie"></a>
                <a href="Evaluate.jsp" class="evaluate"></a>
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

       <form name="form1" id="form1" action="Upload.jsp" method="post" enctype="multipart/form-data">
       <br><input type="file" name="file1">
       <br/><input type="submit" value="Upload"></form>     
             <%
             File file; 
                FileItemFactory factory = new DiskFileItemFactory();
                ServletFileUpload upload = new ServletFileUpload(factory);
                try {
                        List<FileItem> fields = upload.parseRequest(request);
                        Iterator<FileItem> it = fields.iterator();
                        while (it.hasNext()) {
                                FileItem fileItem = it.next();
                                boolean isFormField = fileItem.isFormField();
                        
 out.println(fileItem.getContentType());
                        
if (!fileItem.getContentType().equals("text/xml"))        
{
    out.println("Nespravny typ");
}
else
{

                                if (!isFormField) {
                                        out.println("Súbor: " + fileItem.getName() +
                                                        "<br/>Typ: " + fileItem.getContentType() +
                                                        "<br/>Velkost (BYTES): " + fileItem.getSize());
                                        String fileName = fileItem.getName();

                                        if( fileName.lastIndexOf("\\") >= 0 ){
                                       file = new File( filePath + fileName.substring( fileName.lastIndexOf("\\"))) ;
                                    }else{
                                       file = new File( filePath +
                                       fileName.substring(fileName.lastIndexOf("\\")+1)) ;
                                    }
                                        
                                        
                                        try {
                                    fileItem.write( file ) ;        
                                    
                                        } catch (Exception e) {
                                                // TODO Auto-generated catch block
                                                e.printStackTrace();
                                        }
                                        
                                        
                                }
                               }
                       }
                } catch (FileUploadException e) {
                        e.printStackTrace();
                }
                
                %>
             
         </div>
             
                
                

   
        
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
