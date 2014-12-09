<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>

<%

   File file ;
   int maxFileSize = 256 * 1024 * 1024; //Max velkost suborov 256MB
   int maxMemSize = 256 * 1024 * 1024; //Max velkost suborov 256MB
   ServletContext context = pageContext.getServletContext();
   String filePath = context.getInitParameter("file-upload");
 
   
   String contentType = request.getContentType();
   if ((contentType.indexOf("multipart/form-data") >= 0)) {


       
      DiskFileItemFactory factory = new DiskFileItemFactory();
      factory.setSizeThreshold(maxMemSize);
      factory.setRepository(new File("c:\\temp"));

      ServletFileUpload upload = new ServletFileUpload(factory);
      upload.setSizeMax( maxFileSize );
   
      try{ 
    	  

         List fileItems = upload.parseRequest(request);

         Iterator i = fileItems.iterator();

         while ( i.hasNext () ) 
         {
            FileItem fi_ = (FileItem)i.next();
            if ( fi_.isFormField () )	
            {
                
                if(fi_.getFieldName().equalsIgnoreCase("fID")){
                
                   FileItem fi = (FileItem) session.getAttribute("CACHE_FILE_"+fi_.getString());     
                   String fileName = fi.getName();
            boolean isInMemory = fi.isInMemory();
            long sizeInBytes = fi.getSize();
    
            if( fileName.lastIndexOf("\\") >= 0 ){
            file = new File( filePath + 
            fileName.substring( fileName.lastIndexOf("\\"))) ;
            }else{
            file = new File( filePath + 
            fileName.substring(fileName.lastIndexOf("\\")+1)) ;
            }
            fi.write( file ) ;
			out.println("DATA-STATE-C / "+file.getAbsolutePath());
                 }
            }
         }

      }catch(Exception ex) {
              out.println("DATA-STATE-E-SZ");
         System.out.println(ex);
      }
   }
   

%>