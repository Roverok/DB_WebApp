<%@page import="org.jbowl.model.supervised.rule.ImpurityMeasure"%>
<%@page import="javax.jws.soap.SOAPBinding.Style"%>
<%@page import="data.IndexTrainingSet"%>
<%@page import="java.io.File"%>
<%@page import="data.EntryData"%>
<%@page import="org.apache.tomcat.jni.OS"%>
<%@page import="java.util.*"%>
<%@page import="org.gridgain.grid.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="data" class="data.EntryData" scope="session"/>
<jsp:useBean id="build1" class="data.BuildModelTree" scope="session"/>
<jsp:useBean id="build2" class="data.BuildModelKnn" scope="session"/>
<jsp:setProperty name="data" property="*"/>

<!DOCTYPE html>
<html>
    <head>
        <title> vysledky </title>
        <link rel="stylesheet" href="style.css" type="text/css">
    </head>
    <body>
        <div>
        <%
            
            Integer hlbka = data.getHlbka();
            String metoda = data.getMetoda();
            boolean bin = data.getBin();
            String submit = data.getSubmit();
            
            // nacitanie <include> po kliknuti na button(submit)
            if (submit != null) {
            // nacitanie cesty k suboru
if (request.getParameter("algoritmus")!=null)
{
if (request.getParameter("algoritmus").equals("tree"))
               {                
            build1.main(hlbka, metoda, bin, request, response);
                   //session.invalidate();
                        // zmaze premenne - nastavenia, cesty ...

            }
            else {out.println("<p class='nadpis'>Nastav parametre algoritmu!</p>");
            }
            data.setSubmit(null);
            
            }
            
            
            
            
 if (request.getParameter("algoritmus").equals("knn"))
              {
            if (submit != null) {
            // nacitanie cesty k suboru
                    int k = Integer.parseInt(request.getParameter("k"));
            
                build2.main(k,request, response);
                    //session.invalidate();
                        // zmaze premenne - nastavenia, cesty ...

            }
            else {out.println("<p class='nadpis'>Nastav parametre algoritmu!</p>");
            }
            //data.setSubmit(null);    
              }
            }
        %>
        
        </div> 
    </body>
</html>
