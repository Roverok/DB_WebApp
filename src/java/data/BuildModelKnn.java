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
import org.jbowl.data.Instances;
import org.jbowl.data.processing.InstanceInputStream;
import org.jbowl.model.supervised.knn.kNNSettings;

import org.jbowl.task.BuildModelTask;
import org.jbowl.task.Connection;
import org.jbowl.task.ConnectionFactory;
import org.jbowl.task.ExecutionHandler;
import org.jbowl.task.executor.TaskExecutor;
import testing.KlasifikaciaTask;

//import testing.KlasifikaciaTask;
public class BuildModelKnn extends HttpServlet {

//    public static void main(String[] args) throws Exception {
    public void main(int k, HttpServletRequest request, HttpServletResponse response)
            throws GridException, Exception, ServletException, IOException {

        final Grid grid = G.grid();
        Context env = (Context) new InitialContext().lookup("java:comp/env");
        String filePath = (String) env.lookup("file-upload");
        String meno = request.getParameter("vstupne_data");
        String zlozka = meno.replaceAll("\\.", "_");

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        long start = System.currentTimeMillis();
        // čas začiatku vytvárania modelu

        Instances instances = new Instances(new InstanceInputStream(filePath + "/" + zlozka + "/" + "train-instances"));
        int numOfCategories = instances.numOfCategories();

        out.println("<p class='nadpis'>nastavenie parametrov algoritmu:</p><hr/><p class='nadpis'>...model bol vytvorený</p>");

        BuildModelTask task = new BuildModelTask();

        task.setAlgorithm("org.jbowl.model.supervised.knn.kNNAlgorithm");

        kNNSettings settings = new kNNSettings();
        settings.setK(k);
        task.setBuildSettings(settings);
        task.setBuildData(new InstanceInputStream(filePath + "/" + zlozka + "/" + "train-instances"));

        task.setModelName(filePath + "/" + zlozka + "/" + "/model");
        Connection conn = ConnectionFactory.createFactory().getConnection();     /* ZĂ­ska sa prepojenie na vykonĂˇvacĂ­ objekt*/

        ExecutionHandler handler = conn.execute(task);                          /* Iniciuje sa vykonanie Ăşlohy na vytvorenie klasifikaÄŤnĂ©ho modelu*/

        handler.waitForCompletion();                                            /* ÄŚakĂˇ sa na dokonÄŤenie tvorby klasifikaÄŤnĂ©ho modelu */

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
