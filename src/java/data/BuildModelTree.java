package data;

import examples.task.Utils;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.concurrent.TimeUnit;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.gridgain.grid.Grid;
import org.gridgain.grid.GridException;
import org.gridgain.grid.typedef.G;
import org.gridgain.grid.GridFactory;
import org.jbowl.data.Instances;
import org.jbowl.data.processing.InstanceInputStream;
import org.jbowl.model.supervised.rule.ImpurityMeasure;
import org.jbowl.model.supervised.tree.TreeSettings;
import org.jbowl.task.BuildModelTask;
import org.jbowl.task.Connection;
import org.jbowl.task.ConnectionFactory;
import org.jbowl.task.ExecutionHandler;
import org.jbowl.task.executor.TaskExecutor;
import testing.KlasifikaciaTask;

//import testing.KlasifikaciaTask;
public class BuildModelTree extends HttpServlet {

//    public static void main(String[] args) throws Exception {
    public void main(Integer hlbka, String metoda, boolean bin, HttpServletRequest request, HttpServletResponse response)
            throws GridException, Exception, ServletException, IOException {

        final Grid grid = G.grid();
        Context env = (Context) new InitialContext().lookup("java:comp/env");
        String filePath = (String) env.lookup("file-upload");
        String meno = request.getParameter("vstupne_data");
        String zlozka = meno.replaceAll("\\.", "_");

        //Grid grid = args.length == 0 ? G.start() : G.start(args[0]);
        // if (args.length == 0) { G.start(); } else { G.start(args[0]); }
//            String meno = args[0];
//            String cesta = args[1];
//            String TFIDF_SCHEME = args[2];
//            cesta = ("D:/_DP/projects/DP_WebApp/data/Reuters-21578 ModApte/"+meno);
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        long start = System.currentTimeMillis();
        // čas začiatku vytvárania modelu

        Instances instances = new Instances(new InstanceInputStream(filePath + "/" + zlozka + "/" + "train-instances"));
        int numOfCategories = instances.numOfCategories();

        out.println("<p class='nadpis'>nastavenie parametrov algoritmu:</p>"
                //                + "<br/> pocet kategorii je: " + numOfCategories
                + "<br/> -- hĺbka generovaného stromu: " + hlbka
                + "<br/> -- miera variability: " + metoda
                + "<br/> -- binárna hodnota: " + bin
                + "<hr/><p class='nadpis'>...model bol vytvorený</p>");

        BuildModelTask task = new BuildModelTask();

        task.setAlgorithm("org.jbowl.model.supervised.tree.TreeAlgorithm");
        task.setBuildData(new InstanceInputStream(filePath + "/" + zlozka + "/" + "train-instances"));
        TreeSettings settings = new TreeSettings();
        settings.setMaxDepth(hlbka);
        if ("foil".equals(metoda)) {
            settings.setImpurityMeasure(ImpurityMeasure.foil);
        } else if ("gini".equals(metoda)) {
            settings.setImpurityMeasure(ImpurityMeasure.gini);
        } else {
            settings.setImpurityMeasure(ImpurityMeasure.entropy);
        }

        settings.setBinaryValues(bin);

        task.setBuildSettings(settings);
        task.setModelName(filePath + "/" + zlozka + "/" + "/model");

        Connection conn = ConnectionFactory.createFactory().getConnection();
        ExecutionHandler handler = conn.execute(task);
        handler.waitForCompletion();

        //TaskExecutor.shutdown();
        // start gridgain
//        try {
//
//            System.out.println("\nPocet kategorii je: " + numOfCategories);
//            out.println("\nPocet kategorii je: " + numOfCategories);
//
//            grid.execute(KlasifikaciaTask.class, instances).get();
//
//            System.out.println("\n>>> Koniec klasifikacie <<<");
//        }
//        finally {
//            G.stop(grid.name(),true);
//        }
        // stop gridgain
        try {
            grid.deployTask(KlasifikaciaTask.class);
            grid.execute("KlasifikaciaTask", instances).get();
            grid.undeployTask("KlasifikaciaTask");
        } catch (GridException e) {
            e.printStackTrace();
        }

        long totalTime = (System.currentTimeMillis() - start);
        long min = TimeUnit.MILLISECONDS.toMinutes(totalTime);
        long sec = TimeUnit.MILLISECONDS.toSeconds(totalTime) - min * 60;
        long ms = TimeUnit.MILLISECONDS.toMillis(totalTime) - sec * 1000;

        out.println("<br/>čas vytvorenia modelu: " + min + "min " + sec + "." + ms + "s</p>");
        // start gridgain
        System.out.println("\nPocet kategorii je: " + numOfCategories);
        out.println("\nPocet kategorii je: " + numOfCategories);

        System.out.println("\n>>> Koniec klasifikacie <<<");

    }

}
