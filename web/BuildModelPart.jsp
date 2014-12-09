<%@page import="javax.naming.InitialContext"%>
<%@page import="javax.naming.Context"%>
<%@page import="java.io.File"%>
<%@page import="org.apache.tomcat.util.http.fileupload.util.Streams"%>
<%@page import="java.io.InputStream"%>
<%@page import="org.apache.tomcat.util.http.fileupload.FileItemStream"%>
<%@page import="org.apache.tomcat.util.http.fileupload.FileItemIterator"%>
<%@page import="org.apache.tomcat.util.http.fileupload.servlet.ServletFileUpload"%>
<%@page import="org.apache.tomcat.jni.OS"%>
<%@page import="java.util.*"%>
<%@ page import="javax.servlet.*,java.text.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="data" class="data.EntryData" scope="session"/>
<jsp:setProperty name="data" property="*"/>
<!DOCTYPE html>
<html>
<head>
    <title>DataMining Cloud App | Tree Algorithm</title>
    <meta name="description" content="DataMining Cloud App | Tomáš Kačur">
    <meta name="author" content="Tomáš Kačur">
    <link rel="stylesheet" href="style.css" type="text/css">
    <link rel="stylesheet" href="check_radio_style.css" type="text/css">
    <link rel="stylesheet" href="scrollbar.css" type="text/css">
    
    
    <script src="js/jquery-1.8.2.min.js"></script>
    <script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.8.1/jquery.validate.min.js"></script>
    <script src="js/reloading.js"></script>
    <script src="js/main.js"></script>
    
    
</head>

<body>
    <%
        String prava=(String) session.getAttribute("prava");
        %>
    <div id="all">
        <%
        if (prava=="admin" || prava=="user")
        {
        %>
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
                <a href="BuildModelPart.jsp" class="build active"></a>
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
            <form name="predspracovanie" method="POST" action="BuildModelPart.jsp">
                                 

                <div id="lPart">

                    <div id="dataset">
                    <%
                   /*
                        if (data.getFile() != null) {
                        String meno = data.getFile();
                            out.println("<p style='padding-bottom: 10px;'>"
                                    + "pracujete množinou: "+ meno +"</p>");
                    }
                    else {
                    out.println("<p style='padding-bottom: 10px;'>"
                            + "vyberte vstupné dáta v 1. kroku"
                            + "</p>");               
                    }
                    */
                        
Context env = (Context)new InitialContext().lookup("java:comp/env");
String filePath = (String)env.lookup("file-upload");
                        
                       File zoznam = new File ( filePath );
        		       File[] contents = zoznam.listFiles();
                               int j;
       	                       String extension = "";
                               %>
                               <select name="vstupne_data">
                               <%
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
                               <%
                    %>  
                </div>
                <div class="action_button">
                    <%
                    if (data.getReset() != null){
                    session.invalidate();
                    }
                    %>
                    <button name="reset" class="reset" value=" " title="reset nastavení"></button>
                </div> 

                    <div id="settings">
                        <div class="algSettings">
                            <input type="radio" id="r60" name="algoritmus" value="tree" checked="checked" onclick="$('#alg2').hide();$('#alg1').show();$('#vizualizacia').show();" />
<label for="r60"><span></span></label>                            
<div class="alg_title">nastavenie parametrov algoritmu - rozhodovacie stromy:</div><br>
                            <div class="part"  id="alg1">
                                <p>maxDepth: 

                                    <input type="number" name="hlbka" value="-1" min="-1"/>
                                        <label title="maximálna hĺbka gen. stromu <1+> (default: -1 (neobmedzená hĺbka))"></label></p>
                                <p>impurity:
                                    <input type="radio" id="r19" name="metoda" value="entropy" checked="" />
                                        <label for="r19" title="entrópia"><span></span>entropy</label>
                                    <input type="radio" id="r20" name="metoda" value="gini" />
                                        <label for="r20" title="gini index"><span></span>gini</label>
                                    <input type="radio" id="r21" name="metoda" value="foil" />
                                        <label for="r21" title="informačný zisk + podmienky"><span></span>foil</label></p>
                                <p>binaryValues:
                                    <input type="radio" id="r22" name="bin" value="false" checked=""/>
                                        <label for="r22" title="false"><span></span>frekvencia termu</label>
                                    <input type="radio" id="r23" name="bin" value="true" />
                                        <label for="r23" title="true"><span></span>binárna hodnota</label>
                            </div>
                        </div>
                        
                        
                        <div class="algSettings">

<input type="radio" id="r61" name="algoritmus" value="knn" onclick="$('#alg1').hide();$('#alg2').show();$('#vizualizacia').hide();" />
<label for="r61"><span></span></label>                            
<div class="alg_title">nastavenie parametrov algoritmu - KNN:</div>
<br>
                            <div class="part" id="alg2">
                                <p>k:
                                    <input type="number" name="k" value="45" min="1"/>
                                </p>
                            </div>
                        </div>
                        
                        
                        
                    </div>
                    
                    <div class="check"></div>
                    
                    <div class="action_button">
                        <input type="submit" name="submit" class="spracuj" value=" " title="2.krok: vytvorenie modelu" />
                    </div>
                    
                </div>
                
                <div id="textOut">
                    <h3>Výstup:</h3>
                    <div id="results">
                        <jsp:include page="buildModel.jsp" />
                    </div>
                    <a id="vizualizacia" href="VisualizationPart.jsp" class="next" title="ďalší krok: vizualizácia"></a>
                </div>
                                
            </form>
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
     <%
     }
       else
    {
    %>    
    <strong>Pristup zamietnuty</strong>
    <%
    }
     %>   
    </div>

</body>
</html>
