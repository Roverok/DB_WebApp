
<%@page import="gg.StopNodUloha"%>
<%@page import="gg.RestartNodUloha"%>
<%@page import="gg.SpravaUloha"%>
<%@page import="org.gridgain.grid.GridException"%>
<%@page import="org.gridgain.grid.GridRichNode"%>
<%@page import="org.gridgain.grid.typedef.G"%>
<%@page import="org.gridgain.grid.Grid"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="javax.naming.InitialContext"%>
<%@page import="javax.naming.Context"%>


<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="data" class="data.EntryData" scope="session"/>
<jsp:setProperty name="data" property="*"/>

<!DOCTYPE html>
<html>
<head>
    <title>DataMining Cloud App | Upload</title>
    <meta name="description" content="DataMining Cloud App | Tomáš Kačur">
    <meta name="author" content="Tomáš Kačur">
    <link rel="stylesheet" href="style.css" type="text/css">
    <link rel="stylesheet" href="check_radio_style.css" type="text/css">
    <link rel="stylesheet" href="scrollbar.css" type="text/css">
    
    
    <script src="js/jquery-1.8.2.min.js"></script>
    <script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.8.1/jquery.validate.min.js"></script>
    <script src="js/reloading.js"></script>
    
   

</head>

<body>
<%!
final SimpleDateFormat format = new SimpleDateFormat("dd.MM.yyyy HH:mm.ss");
final DecimalFormat twoDForm = new DecimalFormat("#.##");	
boolean pingSuccess = false;
static final String RESTART_NOD = "RestartNodUloha";
static final String MESSAGE_TASK = "SpravaUloha";
static final String STOP_NOD = "StopNodUloha";

 	private static String PrevodBytov(long bytov){
		if((bytov/1000000000)>0){
			return (bytov/1000000000 + " GB");
		}
		else if((bytov/1000000)>0){
			return (bytov/1000000 + " MB");
		}
		else if((bytov/1000)>0){
			return (bytov/1024 + " kB");
		}
		else{
			return (bytov + " bytov");
		}
	}       

       	/*
	 * Pomocna funkcia na odstranenie html tagov z textu (pri vypise na stranku)
	 */
	private static String encodeHTML(String s)
	{
	    StringBuffer out = new StringBuffer();
	    for(int i=0; i<s.length(); i++)
	    {
	        char c = s.charAt(i);
	        if(c > 127 || c=='"' || c=='<' || c=='>')
	        {
	           out.append("&#"+(int)c+";");
	        }
	        else
	        {
	            out.append(c);
	        }
	    }
	    return out.toString();
	} 
        
       
     Grid grid = G.grid();   

%>
<%
 		boolean pingSuccess = false;
		// v pripade ze klient nastavil poziadavku pingnut uzol
		if (request.getParameter("ping_nod") != null) {
			//z lokalneho uzla vykonam ping a poznacim si vysledok, ktory zobrazim na stranke
			pingSuccess = grid.pingNode(UUID.fromString(request.getParameter("nod_id")));
		}

                		// v pripade ze klient nastavil poziadavku restartovat uzol
		if (request.getParameter("restart_nod") != null) {
	        try {
	        	//odoslem do gridu ulohu o restartovani nodu, v parametri ulohy bude ID cieloveho uzla
				grid.deployTask(RestartNodUloha.class);
				grid.execute(RESTART_NOD, request.getParameter("nod_id")).get();
				grid.undeployTask(RESTART_NOD);
			} catch (GridException e) {
				e.printStackTrace();
			}
		}
                		// v pripade ze klient nastavil poziadavku odpojit uzol
		
                if (request.getParameter("odpojit_nod") != null) {
	        try {
	        	//odoslem do gridu ulohu o zastaveni nodu, v parametri ulohy bude ID cieloveho uzla
				grid.deployTask(StopNodUloha.class);
				grid.execute(STOP_NOD, request.getParameter("nod_id")).get();
				grid.undeployTask(STOP_NOD);
			} catch (GridException e) {
				e.printStackTrace();
			}
		}

    		// v pripade ze klient nastavil textovu spravu
		if (request.getParameter("posli_spravu") != null) {
	        try {
	        	GridRichNode node = G.grid().node(UUID.fromString(request.getParameter("nod_id")));
				List<String> spravy = node.meta("spravy"); 
	        	if (spravy == null) {
            		spravy = new ArrayList<String>();
            	}
            	spravy.add(request.getParameter("sprava"));
            	node.addMeta("spravy", spravy); //poznamenam si spravu k danemu uzlu (pre zobrazenie v tabulke)

            	//odoslem do gridu ulohu o poslanej sprave, v parametri ulohy bude ID cieloveho uzla
				grid.deployTask(SpravaUloha.class);
				grid.execute(MESSAGE_TASK, request.getParameter("nod_id") + ";" + request.getParameter("sprava")).get();
				grid.undeployTask(MESSAGE_TASK);
			} catch (GridException e) {
				e.printStackTrace();
			}
		}
    
    
    
    
   Thread t = new Thread(new Runnable() {
            public void run() { 
            	//v nekonecnom cykle vlakno zbiera udaje
                for (;;) {
                	for (GridRichNode node : grid.nodes()) {
	            		List<String> history = node.meta("history");
	                	if (history == null) {
	                		history = new ArrayList<String>();
	                	}
	                	String data = format.format(new Date()); //vytvori zaznam o vytazeni uzla vo formate 'cas;vytazenie'
	                	data += ";";
	                	data += twoDForm.format(node.metrics().getAverageCpuLoad()*100);
	                	history.add(data);
	                	node.addMeta("history", history); // prilozi tento zaznam k uzlu
                	}
                    try {                                	
                        Thread.sleep(5000); // pocka 5 sekund a prejde na zaciatok cyklu
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
            	}
            }
        });
            
    t.setDaemon(true);// this makes the Thread die when your application exits
    t.start();    

Context env = (Context)new InitialContext().lookup("java:comp/env");
String filePath = (String)env.lookup("file-upload");

String prava=(String) session.getAttribute("prava");

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
                <a href="mainApp.jsp" class="home"></a>
                <a href="BuildModelPart.jsp" class="build"></a>
                <a href="" class="zhlukovanie"></a>
                <a href="Evaluate.jsp" class="evaluate"></a>
                 <%
                if (prava=="admin") {
                %>
                <a href="Monitoring.jsp" class="monitoring active"></a>
<%
                }
                %>
                <a href="mainApp.jsp?logout" class="logout"></a>

                <a href="mainApp.jsp?logout"></a>
            </div>
            <h1><img src="cloudApp.png"/>DataMining Cloud App</h1>
        </header>

        
         <div id="formular">
             <%
   
         if (request.getParameter("nod") != null) {
            out.println("<p><img src='Chart?nod="+encodeHTML(request.getParameter("nod"))+"' />");
            out.println("<p><span style='font-size:14px;'><a href='?nod="+encodeHTML(request.getParameter("nod"))+"'>[Aktualizovat]</a></span></p>");
		}               
      		//vytvorime samostatene vlakno
  
      
             
             
     	out.println("<table width='100%' border='1' cellpadding='2' cellspacing='0'>");
        out.print("<tr style='color:#FFF; background:#036'>");
    	out.print("<td>Nazov pocitaca</td>");
    	out.print("<td>Nazov uzivatela</td>");
    	out.print("<td>Java ver.</td>");
    	out.print("<td>GG ver.</td>");
    	out.print("<td>OS</td>");
    	out.print("<td>Arch.</td>");
    	out.print("<td>Pocet proc.</td><td>Beziace ulohy</td><td>Vytazenie CPU</td><td>Volne miesto na disku</td><td>Velkost pamate(VM)</td><td>Pouzita pamat</td><td>Spravy</td><td>IP adresa</td><td>Uloha</td>");
    	out.print("</tr>");
             
        for (GridRichNode node : G.grid().nodes()) {
        	out.println("<tr><td colspan='13'>Nod ID:<strong>" + node.id().toString()+"</strong> spusteny "+format.format(node.metrics().getStartTime())+"</td></tr>");
        	out.println("<tr>");
                out.println("<td>" +node.attribute("USERDOMAIN")+"</td>");
                out.println("<td>" +node.attribute("user.name")+"</td>");
                out.println("<td>" +node.attribute("java.specification.version")+"</td>");
                out.println("<td>" +node.attribute("org.gridgain.build.ver")+"</td>");
                out.println("<td>" +node.attribute("os.name").toString()+"</td>");
                out.println("<td>" +node.attribute("os.arch")+"</td>");
                out.println("<td>" +node.attribute("NUMBER_OF_PROCESSORS")+"</td>");               
                out.println("<td>" + node.metrics().getCurrentActiveJobs()+"</td>");
                out.println("<td>" + twoDForm.format(node.metrics().getAverageCpuLoad()*100)+"%<br>"); 
                out.println("<form method='GET'><input type='submit' value='GRAF'><input type='hidden' name='nod' value='"+node.id().toString()+"'></form>");
                out.println("</td>");
                out.println("<td>" + PrevodBytov(node.metrics().getFileSystemFreeSpace())+"</td>");
                out.println("<td>" + PrevodBytov(node.metrics().getHeapMemoryMaximum())+"</td>");
                out.println("<td>" + PrevodBytov(node.metrics().getHeapMemoryUsed())+"</td>");
                out.println("<td><pre>");
                //ak mam k uzlu poznacene spravy, vsetky ich vypisem
                if (node.hasMeta("spravy")) {
                	List<String> spravy = node.meta("spravy");
	                for (String sprava: spravy) {
	              		out.println(sprava);
	                }
                }
                //formular na posielanie sprav
                if (G.grid().localNode().id()!=node.id()) {
                	out.println("<form method='post'>");
                	out.println("<input type='text' name='sprava' value=''>");
                	out.println("<input type='submit' name='posli_spravu' value='POSLI SPRAVU'>");
                	out.println("<input type='hidden' name='nod_id' value='"+node.id().toString()+"'></form>");
            	}                
                out.println("</pre></td>");
                out.println("<td>" + node.externalAddresses().toString()+"</td>");
                //tlacidla na ping/restart/stop a vysledok pingu
                if (G.grid().localNode().id()!=node.id()) {
                	out.println("<td><form method='post'>");
                	out.println("<input type='submit' name='ping_nod' value='PING'><br>");
                    if (request.getParameter("ping_nod") != null) {
                    	if (pingSuccess) {
                    		out.println("<strong>Successfull</strong>");
                    	} else {
                    		out.println("<strong style='color:red'>Failed!</strong>");
                    	}
                    }                	
                	out.println("<input type='submit' name='restart_nod' value='RESTART'><br>");
                	out.println("<input type='submit' name='odpojit_nod' value='G.stop()'><br>");
                	out.println("<input type='hidden' name='nod_id' value='"+node.id().toString()+"'></form>");
                	out.println("</td>");
            	} else {
                	out.print("<td>N/A (lokalny nod)</td>");
                }
                out.println("</tr>");

        }             
        out.println("</table>");
   
             
             
             
             
             
             
             
             
             
             
                
              %>

         </div>
             
                
                

     <footer>© kacio 2012</footer>
        
    </div> 
<%
}      
else
{
%>    
<strong>Pristup zamietnuty</strong>
<%
}
%>  
</body>
</html>
