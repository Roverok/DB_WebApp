<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="data.EntryData"%>
<jsp:useBean id="data" class="data.EntryData" scope="session"/>
<jsp:useBean id="buildGHSOM" class="data.BuildModelGHSOM" scope="session"/>
<jsp:setProperty name="data" property="*"/>

<%-- 
    Document   : buildGHSOMModel
    Created on : Apr 5, 2014, 4:12:43 PM
    Author     : Zdeno
--%>

<!DOCTYPE html>
<html>
    <head>
        <title> vysledky </title>
        <link rel="stylesheet" href="style.css" type="text/css">
    </head>
    <body>
        <div>
            <%
                out.println("<p class='nadpis'>Vytváranie GHSOM modelu môže trvať dlhšie, po kliknutí na spracuj počkajte chvíľu.</p>");
                Integer hlbkaGHSOM = data.getHlbkaGHSOM();
                Integer minNumberOfInstances = data.getMinNumberOfInstances();
                Integer startingRows = data.getStartingRows();
                Integer startingColumns = data.getStartingColumns();
                Integer expandCycles = data.getExpandCycles();
                Integer initNeighbourhood = data.getInitNeighbourhood();
                double tau2 = data.getTau2();
                double tau1 = data.getTau1();
                double initLearnRate = data.getInitLearnRate();
                
                //metoda = similarity
                String metoda = data.getMetoda();
                String submit = data.getSubmit();
                
                //ked sa klikne na tlacitko spracuj
                if (submit != null) {
                    long start = System.currentTimeMillis();
                    out.println("<p class='nadpis'>Nastavenie parametrov algoritmu:</p>"
                            + " -- hĺbka: " + hlbkaGHSOM
                            + "<br/> -- minimálny počet inštancií: " + minNumberOfInstances
                            + "<br/> -- počet začiatočných riadkov: " + startingRows + ", stĺpcov: " + startingColumns
                            + "<br/> -- expand cycles: " + expandCycles
                            + "<br/> -- init neighbourhood: " + initNeighbourhood
                            + "<br/> -- tau2: " + tau2 + ", tau1: " + tau1
                            + "<br/> -- init learn rate: " + initLearnRate
                            + "<br/> -- podobnosť: " + metoda
                            + "<hr/><p class='nadpis'>...model bol vytvorený</p>");
                    buildGHSOM.main(hlbkaGHSOM, minNumberOfInstances, tau2, startingRows, startingColumns,
                            expandCycles, initNeighbourhood, tau1, initLearnRate, metoda, request, response);
                    out.println("Čas vytvárania: " + (System.currentTimeMillis() - start) / 1000f +" s.");
                    data.setSubmit(null);
                }
            %>
        </div>
    </body>
</html>
