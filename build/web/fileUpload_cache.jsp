<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>

<%

   File file ;
   int maxFileSize = 256 * 1024 * 1024; //Max velkost suborov 128MB
   int maxMemSize = 256 * 1024 * 1024; //Max velkost suborov 128MB
   ServletContext context = pageContext.getServletContext();
   String filePath = context.getInitParameter("file-upload");
 
   
   String contentType = request.getContentType();
   if ((contentType.indexOf("multipart/form-data") >= 0)) {


       
      DiskFileItemFactory factory = new DiskFileItemFactory();
      factory.setSizeThreshold(maxMemSize);
      factory.setRepository(new File("c:\\temp"));

      ServletFileUpload upload = new ServletFileUpload(factory);
      upload.setSizeMax( maxFileSize );
      int fID=0;
      FileItem fiT=null;
      try{ 
    	  

         List fileItems = upload.parseRequest(request);

         Iterator i = fileItems.iterator();

         while ( i.hasNext () ) 
         {
            
            FileItem fi = (FileItem)i.next();
            if ( fi.isFormField () )	
            {
                
            String fieldName = fi.getFieldName();
            if(fieldName.equalsIgnoreCase("fID")){
                fID = Integer.parseInt(fi.getString());
          
            }
            
            }else{
                fiT=fi;
  
            }
            
         }
         
             session.setAttribute("CACHE_FILE_"+fID, fiT);
    

      }catch(Exception ex) {
         out.println("DATA-STATE-E-SZ");
         System.out.println(ex);
      }
   }
   

%>