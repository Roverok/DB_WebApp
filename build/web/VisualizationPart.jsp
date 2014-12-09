<%@page import="org.jbowl.model.supervised.tree.DecisionTree"%>
<%@page import="org.jbowl.model.supervised.tree.TreeClassifier"%>
<%@page import="org.jbowl.model.supervised.tree.TreeNode"%>
<%@page import="examples.task.Utils"%>
<%@page import="org.jbowl.util.IndexedSet"%>
<%@page import="java.io.File"%>
<%@page import="sun.net.www.content.audio.x_aiff"%>
<%@page import="org.apache.tomcat.util.http.fileupload.util.Streams"%>
<%@page import="java.io.InputStream"%>
<%@page import="org.apache.tomcat.util.http.fileupload.FileItemStream"%>
<%@page import="org.apache.tomcat.util.http.fileupload.FileItemIterator"%>
<%@page import="org.apache.tomcat.util.http.fileupload.servlet.ServletFileUpload"%>
<%@page import="org.apache.tomcat.jni.OS"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="data" class="data.EntryData" scope="session"/>
<jsp:useBean id="read" class="data.ReadModel" scope="session"/>
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
        <script src="processing.js" type="text/javascript"></script>
        <script type="text/javascript">
            // convenience function to get the id attribute of generated sketch html element
            function getProcessingSketchId () { return 'treetest'; }
            var file = "treeOut.txt";
        </script>

    </head>

    <body>
        <div id="all">

            <header>
                <div id="menu">
                    <a href="mainApp.jsp" class="home"></a>
                    <a href="BuildModelPart.jsp" class="build"></a>
                    <a href="VisualizationPart.jsp" class="visual active"></a>
                </div>
                <h1><img src="cloudApp.png"/>DataMining Cloud App</h1>
            </header>


            <div id="formular">
                <form name="predspracovanie" method="POST" action="VisualizationPart.jsp">




                    <div id="trees">
                        <p>vyberte si kategóriu (0 - <% out.println(read.range()); %>):
                            <%
                            out.println("<input type=\"number\" name=\"indexCat\" value=\"\" min=\"0\" max=\""+read.range()+"\">");   
                            %>
                            
                            <input type="submit" name="submit" value="submit">
                        </p>




                        <p> pracujete s množinou: <%= data.getFile()%> </p>

                        <script type="text/javascript">
                            var index = <%data.getIndexCat();%>;
                        </script>

                        <%
                            //if (data.getIndexCat() != null) {
                            if (1==1) {
                                out.println("<p> vizualizujete rozhodovací strom pre: "
                                        + data.getIndexCat() + ".kategóriu:  </p>");

                                read.main(data.getIndexCat(), request, response);
                        %>

                        <p> rozhodovací strom (textová podoba):</p>
                        <div class="out">
                            <%= read.printTree(data.getIndexCat())%>
                            --------------------------<br/>
                            <%@include file="treeOut.txt" %>
                        </div>

                        <%
                            } else {
                                out.println("<p> nevybrali ste kategóriu</p>");
                            }
                            session.invalidate();


                        %>


                    </div>


                    <div id="visualization">
                        <canvas id="treetest" data-processing-sources="tree_test.pjs" 
                                width="700" height="500">
                            <p>Your browser does not support the canvas tag.</p>
                            <!-- Note: you can put any alternative content here. -->
                        </canvas>

                        <noscript>
                        <p>JavaScript is required to view the contents of this page.</p>
                        </noscript>
                    </div>



                    <!--<div id="textOut">
                        <h3>info:</h3>
                        <div id="result" class="info">
                            <h3>tu sa budú zobrazovať informácie <br/> (po kliknutí na list)</h3>
                        </div>
                        <a href="tree_test/web-export/index.html" target="blank" class="button" title="vizualizacia">:: processing output ::</a>
                        
                    </div>-->



                </form>
            </div>

            <footer>© kacio 2012</footer>

        </div>

    </body>
</html>
