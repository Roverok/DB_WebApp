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
    <meta name="description" content="DataMining Cloud App">
    <meta name="author" content="">
    <link rel="stylesheet" href="style.css" type="text/css">
    <link rel="stylesheet" href="check_radio_style.css" type="text/css">
    <link rel="stylesheet" href="scrollbar.css" type="text/css">
    
    
    <script src="js/jquery-1.8.2.min.js"></script>
    <script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.8.1/jquery.validate.min.js"></script>
    <script src="js/reloading.js"></script>
    <script src="js/core.js"></script>
   

</head>

<body>
    <div id="fileContent_bg"><div id="fileContent_window"><button class="remove_button" onclick="javascript:UPLOAD_CORE.CLOSE()"></button><div id="fileContent_bg_if"></div></div></div>
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
             <div id="file_upload_content">
                 <form name='temp_file_f_up' method='post' enctype='multipart/form-data'></form>
             <div id="file_upload">
                 <div class="file_upload_c" id="file_upload_c_0">
                     
                     <table>
                     <tr><td width="400">
                     <form name='temp_file_upload_f' method='post' enctype='multipart/form-data'>
                     <input name='file' type='file'/>
                     </form>
                     </td><td width="470"> 
                     </td><td width="50">

                     <button class="add_button" type="button" onclick="javascript:UPLOAD_CORE.ADD_FILE();"/></button>
                     </td>
                 </table>
                 </div>
                 
             </div>
          <a href="mainApp.jsp" class="next"></a>
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
          
            </div>
        </footer>
                
    </div> 
                <script type="text/javascript">checkForData();</script>
             
                
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
