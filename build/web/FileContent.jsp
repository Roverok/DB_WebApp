
<%@page contentType="text/html" pageEncoding="UTF-8" import="java.io.*, java.net.*"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>File</title>
    <style>
        textarea{
            background-color:#e9e9e9;
            width:800px;
            height:600px;
        }
    </style>
    </head>
    <body>
     
        <%
        
ServletContext context = pageContext.getServletContext();
String path = context.getInitParameter("file-upload");
String fileName = request.getParameter("file");
//File file = new File(path+fileName);
System.out.println(path+fileName);
BufferedReader input = new BufferedReader(new FileReader(path+fileName));
String line = "";
input.mark(1024*128);
int count = 1;
while ((line = input.readLine()) != null)
{
 for (int i = 0; i < line.length(); i++) {
            if (line.charAt(i) == '>') {
                count++;
            }
 }
}

%>
<textarea disabled rows="<% out.print(count); %>" cols="100" style="border:none;">
<% 
input = new BufferedReader(new FileReader(path+fileName));

while ((line = input.readLine()) != null)
{
out.println(line.replaceAll("<","&lt;").replaceAll(">","&gt;"));
}

input.close();
%>
</textarea>
    </body>
</html>
