<%@page import="javax.naming.InitialContext"%>
<%@page import="javax.naming.Context"%>
<%@page import="org.apache.catalina.Session"%>
<%@page import="org.jbowl.model.supervised.rule.ImpurityMeasure"%>
<%@page import="javax.jws.soap.SOAPBinding.Style"%>
<%@page import="data.IndexTrainingSet"%>
<%@page import="java.io.File"%>
<%@page import="data.EntryData"%>
<%@page import="org.apache.tomcat.jni.OS"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="data" class="data.EntryData" scope="session"/>
<jsp:useBean id="indexTrain" class="data.IndexTrainingSet" scope="session"/>
<jsp:useBean id="indexTest" class="data.IndexTestingSet" scope="session"/>
<jsp:setProperty name="data" property="*"/>

<!DOCTYPE html>
<html>
    <head>
        <title> Vysledky </title>
        <link rel="stylesheet" href="style.css" type="text/css">
    </head>
    <body>
        <div>
        <% 
        String meno=request.getParameter("vstupne_data");
        String type=request.getParameter("file_type");
        
        
        
        //String meno = data.getFile();
        String tfidf = data.getTfidf();
        String cesta = null;
        String tokenizer = data.getTokenizer();
        String stopfilter = data.getTokenizer2();
        String stemmer = data.getTokenizer3();
        
        //Integer hlbka = data.getHlbka();
        //String metoda = data.getMetoda();
        //boolean bin = data.getBin();
        
        boolean check = data.getIdTest();
        String submit = data.getSubmit();
        
        
        // nacitanie cesty k suboru
        if (submit != null) {
            if (meno != null) {
                File file = new File (meno);
                cesta = file.getAbsolutePath();

                out.println("<p><b>voľby predspracovania:</b></p>");
                out.println("členenie textu na slová: " + data.getTokenizer() + "<br/>");
                out.println("odstránenie STOP slov: ");
                    if (data.getTokenizer2() != null) out.println("áno<br/>");
                    else out.println("nie<br/>");
                out.println("úprava na základný tvar: ");
                    if (data.getTokenizer3() != null) out.println("áno<br/>");
                    else out.println("nie<br/>");
                if(type.equalsIgnoreCase("0")){
    indexTrain.main(new String[] {meno, cesta, tfidf, tokenizer, stopfilter, stemmer}, check, request, response);
    
       }else{
       indexTest.main(new String[] {meno, cesta, tfidf, tokenizer, stopfilter, stemmer}, request, response);
       }
                
            }
            else {  if(type.equalsIgnoreCase("0")){out.println("<p class='nadpis'>Chýbajú trénovacie dáta!</p>");}else{out.println("<p class='nadpis'>Chýbajú testovacie dáta!</p>");}
            }
        }
        else {out.println("<p class='nadpis'>Vyber vstupné dáta!</p>");
        }
        
        data.setIdf(null);
        data.setNorm(null);
        data.setTf(null);
        data.setTokenizer(null);
        data.setTokenizer2(null);
        data.setTokenizer3(null);
        //data.setFile(null);
        data.setSubmit(null);
        data.setIdTest(false);
        //session.invalidate();
        %>
        
        </div> 
    </body>
</html>
