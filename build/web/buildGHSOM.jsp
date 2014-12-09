<%-- 
    Document   : build_GHSOM.jsp
    Created on : Mar 27, 2014, 11:41:00 AM
    Author     : Zdeno
--%>

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
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<jsp:useBean id="data" class="data.EntryData" scope="session"/>
<jsp:setProperty name="data" property="*"/>

<!DOCTYPE html>
<html>
    <head>
        <title>DataMining Cloud App | GHSOM Algorithm</title>
        <meta name="description" content="DataMining Cloud App | Zdeno Ulbrík">
        <meta name="author" content="Zdeno Ulbrík">
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
            String prava = (String) session.getAttribute("prava");
        %>
        <div id="all">
            <%
                if (prava == "admin" || prava == "user") {
            %>
            <header>
                <div id="menu">
                    <%
                        if (prava == "admin") {
                    %>
                    <a href="Upload.jsp" class="upload"></a>
                    <%
                        }
                    %>
                    <a href="mainApp.jsp" class="home"></a>
                    <a href="BuildModelPart.jsp" class="build"></a>
                    <a href="buildGHSOM.jsp" class="zhlukovanie active"></a>
                    <a href="Evaluate.jsp" class="evaluate"></a>
                    <%
                        if (prava == "admin") {
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
                <form name="predspracovanie" method="POST" action="buildGHSOM.jsp">
                    <div id="lPart">
                        <div id="dataset">
                            <%
                                Context env = (Context) new InitialContext().lookup("java:comp/env");
                                String filePath = (String) env.lookup("file-upload");
                                File zoznam = new File(filePath);
                                File[] contents = zoznam.listFiles();
                                int j;
                                String extension = "";
                            %>

                            <select name="vstupne_data">

                                <%
                                    for (int i = 0; i < contents.length; i++) {
                                        if (contents[i].isFile()) {
                                            j = contents[i].getName().lastIndexOf(".");
                                            if (j > 0) {
                                                extension = contents[i].getName().substring(j + 1);
                                            }
                                            if (extension.equals("xml")) {
                                                out.println("<option value=\"" + contents[i].getName() + "\">" + contents[i].getName() + "</option>");
                                            }
                                        }
                                    }
                                %>

                            </select>
                        </div>
                        <div class="action_button">
                            <%
                                if (data.getReset() != null) {
                                    session.invalidate();
                                }
                            %>
                            <button name="reset" class="reset" value=" " title="reset nastavení"></button>
                        </div>
                        <div id="settings">
                            <div class="algSettings">
                                <h3>Nastavenie parametrov algoritmu - GHSOM:</h3>
                                <div class="part">

                                    <p>Maximálna hĺbka GHSOM:                                        
                                        <input type="number" name="hlbkaGHSOM" value="5" min="1"/>
                                        <label title="maximálna hĺbka"></label></p>
                                    <p>Minimálny počet inštancií:
                                        <input type="number" name="minNumberOfInstances" value="20" min="1"/>
                                        <label title="minNumberOfInstances"></label></p>
                                    <p>Počet začiatočných riadkov:
                                        <input type="number" name="startingRows" value="2" min="1"/>
                                        <label title="startingRows"></label></p>
                                    <p>Počet začiatočných stĺpcov:
                                        <input type="number" name="startingColumns" value="2" min="1"/>
                                        <label title="startingColumns"></label></p>
                                    <p>initNeighbourhood:
                                        <input type="number" name="initNeighbourhood" value="2" min="1"/>
                                        <label title="initNeighbourhood"></label></p>
                                    <p>expandCycles:
                                        <input type="number" name="expandCycles" value="5" min="1"/>
                                        <label title="expandCycles"></label></p>
                                    <p>InitLearnRate:
                                        <input type="number" name="initLearnRate" value="0.8" min="0" step="0.1" max="1"/>
                                        <label title="initLearnRate"></label></p>  
                                    <p>Tau 2:
                                        <input type="number" name="tau2" value="0.2" min="0" step="0.1" max="1"/>
                                        <label title="Čím vyššia hodnota, tým viac úrovni bude mať mapa"></label></p>
                                    <p>Tau 1:
                                        <input type="number" name="tau1" value="0.3" min="0" step="0.1" max="1"/>
                                        <label title="Čím vyššia hodnota, tým menšie sú mapy"></label></p>
                                    <p>Similarity:
                                        <input type="radio" id="r19" name="metoda" value="dotProduct" checked="" />
                                        <label for="r19" title="dotProduct"><span></span>dotProduct</label>

                                        <input type="radio" id="r20" name="metoda" value="cosineSimilarity" />
                                        <label for="r20" title="cosineSimilarity"><span></span>cosineSimilarity</label></p>                                   
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
                            <jsp:include page="buildGHSOMModel.jsp"/>
                        </div>
                        <a id="vizualizacia" href="VisualizationGHSOM.jsp" class="next" title="ďalší krok: vizualizácia"></a>  
                    </div>
                </form>
            </div>
            <footer>© Zdeno 2014</footer>
                <%
                } else {
                %>    
            <strong>Pristup zamietnuty</strong>
            <%
                }
            %>   
        </div>
    </body>
</html>
