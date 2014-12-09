<%@ page import="java.io.File" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="org.apache.tomcat.util.http.fileupload.util.Streams" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="org.apache.tomcat.util.http.fileupload.FileItemStream" %>
<%@ page import="org.apache.tomcat.util.http.fileupload.FileItemIterator" %>
<%@ page import="org.apache.tomcat.util.http.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.tomcat.jni.OS" %>
<%@ page import="data.EntryData"%>
<%@ page import="javax.servlet.*,java.text.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>

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
    <title>DataMining Cloud App | Tree Algorithm</title>
    <meta name="description" content="DataMining Cloud App | ">
    <meta name="author" content="">
    <link rel="stylesheet" href="style.css" type="text/css">

    
    
    <script src="js/jquery-1.8.2.min.js"></script>
    <script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.8.1/jquery.validate.min.js"></script>
    <script src="js/reloading.js"></script>
    
   

</head>

<body>
    <%
Context env = (Context)new InitialContext().lookup("java:comp/env");
String filePath = (String)env.lookup("file-upload");
String user_login = (String)env.lookup("user_login");
String user_pass = (String)env.lookup("user_pass");
String admin_login = (String)env.lookup("admin_login");
String admin_pass = (String)env.lookup("admin_pass");
String prava=null;

if (request.getParameter("logout")=="") session.setAttribute("prava", null);


if (request.getParameter("login_submit")!=null) 
{
    session.setAttribute("prava", null);
    if (request.getParameter("login").equals(user_login))
    {
        if (request.getParameter("password").equals(user_pass))
        {
        session.setAttribute("prava", "user");
        }
    }
    if (request.getParameter("login").equals(admin_login))
    {
        if (request.getParameter("password").equals(admin_pass))
        {
        session.setAttribute("prava", "admin");
        %>
        <script type="text/javascript">window.localStorage.clear();</script>
        <%
        }
    }
    prava=(String) session.getAttribute("prava");
    if (prava==null) {
        Thread.sleep(3000);
        %>
        <strong>Nespravne prih. </strong>
        <%
    }
 }

prava=(String) session.getAttribute("prava");

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
                <a href="mainApp.jsp" class="home active"></a>
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
       <form name="predspracovanie" method="POST" action="mainApp.jsp">
            
                
            <div id="lPart">
                
                <div id="dataset">
                    <%
/*
 if (data.getFile() != null) {
                        String meno = data.getFile();
                            out.println("pracujete množinou: "+ meno);
                            out.println("<p> vyberte nové dáta: "
                                    + "<input type='file' id='file' name='file' />"
                                    + "</p>");
                    }
                    else {
                    out.println("<p style='padding-bottom: 10px;'>"
                            + "vyberte vstupné dáta: "
                            + "<input type='file' id='file' name='file' />"
                            + "</p>");               
                    }

                
                               File zoznam = new File ( filePath );
        		       File[] contents = zoznam.listFiles();
                               int j;
       	                       String extension = "";
                               %>
                             <!-- <select name="vstupne_data">
                               <%
                          /*     if(contents!=null){
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
                                                  }*/
                               %>
                               </select> -->
                               <%
        
                               
                               
                               
                    %>  
               
              
                    
        </div>
                          <script type="text/javascript">
                    if(localStorage.getItem("UPLOAD_LAST_FILE")!=null){
                        document.getElementById("dataset").innerHTML="Aktívny súbor: "+localStorage.getItem("UPLOAD_LAST_FILE");
                        var type = parseInt(localStorage.getItem("UPLOAD_LAST_FILE_TYPE"));
                        if(type!=null){
                            if(type==0){
                                 document.getElementById("dataset").innerHTML+="<p>Typ množiny: Trénovacia";
                            }else{
                                 document.getElementById("dataset").innerHTML+="<p>Typ množiny: Testovacia";
                            }
                        }
                       
                        document.getElementById("dataset").innerHTML+="<input type='hidden' name='vstupne_data' value='"+localStorage.getItem("UPLOAD_LAST_FILE")+"' />";
                        document.getElementById("dataset").innerHTML+="<input type='hidden' name='file_type' value='"+localStorage.getItem("UPLOAD_LAST_FILE_TYPE")+"' />";
                    }else{
                        document.getElementById("dataset").innerHTML="Nie je aktívny žiadny súbor.";
                    }   
                    </script>

                
                <div id="settings">
                    <div class="algSettings">
                        <h3>predspracovanie a jazyková analýza:</h3>
                        <div class="part">
                            <input type="radio" id="r1" name="tokenizer" value="SimpleTokenizer" checked=""/>
                                <label for="r1" title="rozdelí text podľa prázdnych znakov + lowercase"><span title=""></span>SimpleTokenizer<br/></label>
                            <input type="radio" id="r2" name="tokenizer" value="RegExTokenizer"/>
                                <label for="r2" title="rozdelí text podľa regulárnych výrazov"><span></span>RegExTokenizer<br/></label>
                            <input type="radio" id="r3" name="tokenizer" value="WhitespaceTokenizer"/>
                                <label for="r3" title="rozdelí text podľa prázdnych znakov"><span></span>WhitespaceTokenizer<br/></label>
                        </div>
                        <div class="part">
                            <input type="checkbox" id="c1" name="tokenizer2" value="StopFilter" checked=""/>
                                <label for="c1" title="StopFilter"><span></span>odstránenie STOP slov<br/></label>
                            <input type="checkbox" id="c2" name="tokenizer3" value="PorterStemmer" checked=""/>
                                <label for="c2" title="PorterStemmer"><span></span>úprava na základný tvar</label>
                        </div>
                    </div>

                    <div class="algSettings">
                        <h3>váhovanie a normovanie:</h3>

                        <div class="part">
                            <p>typ TF schémy:</p>
                            <input type="radio" id="r4" name="tf" value="a" />
                                <label for="r4"><span></span>.5 + .5 * ( tf / maxtf )<br/></label>
                            <input type="radio" id="r5" name="tf" value="n" />
                                <label for="r5" title="jednoduché tf váhovanie"><span></span>tf <br/></label>
                            <input type="radio" id="r6" name="tf" value="b" />
                                <label for="r6" title="binárne váhovanie"><span></span>1 <br/></label>
                            <input type="radio" id="r7" name="tf" value="m" />
                                <label for="r7"><span></span>tf / maxtf<br/></label>
                            <input type="radio" id="r8" name="tf" value="s" />
                              <label for="r8"><span></span>tf * tf<br/></label>
                            <input type="radio" id="r9" name="tf" value="l" checked="" />
                              <label for="r9"><span></span>log(tf) + 1<br/></label>
                        </div>
                        <div class="part">
                            <p>typ IDF schémy:</p>
                            <input type="radio" id="r10" name="idf" value="n" />
                                <label for="r10" title="bez inverznej dokumentovej frekvencie"><span></span>1 <br/></label>
                            <input type="radio" id="r11" name="idf" value="t" checked="" />
                                <label for="r11" title="inverzná dokumentová frekvencia"><span></span>log(N / df)<br/></label>
                            <input type="radio" id="r12" name="idf" value="p" />
                                <label for="r12"><span></span>log(N - df)<br/></label>
                            <input type="radio" id="r13" name="idf" value="s" />
                                <label for="r13"><span></span>1 / df<br/></label>
                            <input type="radio" id="r14" name="idf" value="s" />
                                <label for="r14"><span></span>log(N / df)^2<br/></label>
                        </div>
                        <div class="part">
                            <p>normovanie:</p>
                            <input type="radio" id="r15" name="norm" value="n" />
                                <label for="r15"><span></span>bez normalizácie<br/></label>
                            <input type="radio" id="r16" name="norm" value="s" />
                                <label for="r16"><span></span>sumou zložiek vektora<br/></label>
                            <input type="radio" id="r17" name="norm" value="c" checked="" />
                                <label for="r17"><span></span>na 1 dĺžku vektora<br/></label>
                            <input type="radio" id="r18" name="norm" value="m" />
                                <label for="r18"><span></span>max. hodn. vo vektore<br/></label>
                        </div>
                    </div>
                </div>
                    
                <div class="check">
                    <hr/>
                    <p>
                    <input type="checkbox" id="c3" name="idTest" value="true"/>
                    <label for="c3" title="indexovať testovaciu množinu"><span></span>indexovať testovaciu množinu</label>
                    </p>
                </div>
                    
                <div class="action_button">
                    <input type="submit" name="submit" class="spracuj" value=" " title="1.krok: indexacia" />
                </div>
                    
            </div>
                
                <div id="textOut">
                    <h3>Výstup:</h3>
                    <div id="results">
                        <jsp:include page="indexFile.jsp" />
                    </div>
                    <a href="BuildModelPart.jsp" class="next" title="vytvorenie modelu"></a>
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
        
    </div>
<%
}  
else
{
%>
<div id="prihlasenie"> 
      <h2>Prihlásenie:</h2>
      <br>
<form method="post" action="">
    <strong>Login</strong><input type="text" name="login"/><br />
    <strong>Heslo</strong><input type="password" name="password" /><br />
<input type="submit" name="login_submit" value="Prihlásiť" />
</form>
      <br>
 </div>
<%
}
%>
</body>
</html>
