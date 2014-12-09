package gg;

import java.awt.Color;
import java.io.IOException;
import java.io.OutputStream;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.gridgain.grid.Grid;
import org.gridgain.grid.GridRichNode;
import org.gridgain.grid.typedef.G;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.plot.XYPlot;
import org.jfree.data.time.Second;
import org.jfree.data.time.TimeSeries;
import org.jfree.data.time.TimeSeriesCollection;
import org.jfree.data.xy.XYDataset;

/*
 * Servlet Chart - generuje PNG obrazok s grafom vytazenia uzla zadaneho ako http parameter 'nod'
 */
@WebServlet("/Chart")
public class Chart extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	final static private SimpleDateFormat format = new SimpleDateFormat("dd.MM.yyyy HH:mm.ss");
	
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
    
    public Chart() {
        super();
    }

    // hlavna funkcia na vygenerovanie grafu, musi byt nastaveny request parameter 'nod' s ID uzla
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (request.getParameter("nod") == null) {
			return;
		}
		OutputStream out = response.getOutputStream();
		
		try {
			//ziskame pristup ku gridu
			Grid grid = G.grid();
			//najdem nod podla ID
			GridRichNode node = grid.node(UUID.fromString(request.getParameter("nod")));
			
			//vytvorim zoznam hodnot pre graf
			final TimeSeries series = new TimeSeries("CPU load");			
	        if (node.hasMeta("history")) { //ak nod ma zaznamy o vytazeni cpu
	        	List<String> history = node.meta("history");
	        	if (history != null) {
	                for (String h: history) { // kazdy zaznam je v tvare cas;vytazanie
	              		String[] values = h.split(";"); //rozdelim zaznam na 2 casti
	              		if (values != null && values.length > 1) {
	              			//ulozim do zoznamu hodnot grafu novy bod (cas,vytazenie)
	              			series.add(new Second(format.parse(values[0])),Double.parseDouble(values[1].replaceAll(",", ".")));
	              		}
	                }
	        	}
	        }
	        final XYDataset dataset = new TimeSeriesCollection(series);	        
	        
	        //vytvorim graf - nadpis, oznacenie osi, zoznam hodnot
	        JFreeChart chart = ChartFactory.createTimeSeriesChart("Nod: " + encodeHTML(request.getParameter("nod")), "time", "cpu load", dataset, true, false, false);
	        XYPlot plot = (XYPlot) chart.getPlot();
	        NumberAxis numberAxis =(NumberAxis) plot.getRangeAxis();
	        numberAxis.setNumberFormatOverride(new DecimalFormat("#.##")); //nastavim format cisel vytazenia na 2 desatinne miesta
	        //numberAxis.setRange(0d, 100d);

			chart.setBackgroundPaint(Color.white);
		
			response.setContentType("image/png"); //odpoved servletu bude vo formate obrazka
		    ChartUtilities.writeChartAsPNG(out, chart, 500, 300); //vygenerujem obrazok a poslem ho na vystup servletu		
		  }
		  catch (Exception e)
		  {
			  e.printStackTrace();
		  }
		  finally
		  {
		     out.close();
		  }
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}

