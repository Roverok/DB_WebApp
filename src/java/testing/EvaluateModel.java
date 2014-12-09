package testing;

import examples.task.Utils;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.jbowl.data.processing.InstanceInputStream;
import org.jbowl.process.task.PrecisionRecall;
import org.jbowl.process.task.PrecisionRecallMetrics;
import org.jbowl.task.Connection;
import org.jbowl.task.ConnectionFactory;
import org.jbowl.task.EvaluateModelTask;
import org.jbowl.task.ExecutionHandler;
import org.jbowl.task.executor.TaskExecutor;

public class EvaluateModel {

    public static void main(String cesta, HttpServletRequest request, HttpServletResponse response) throws Exception {
        // create evaluation task
        EvaluateModelTask task = new EvaluateModelTask();

        // set task settings
        task.setEvaluationData(new InstanceInputStream(cesta+"/test-instances"));
        task.setModelName(cesta+"/model");
        task.setEvaluationMetricsName(cesta+"/model-eval-metrics");

        // get connection to mining engine with default credentials
        Connection conn = ConnectionFactory.createFactory().getConnection();
        // execute task
        ExecutionHandler handler = conn.execute(task);
        // wait for task completion
        handler.waitForCompletion();

        // load and print evaluation metrics
        PrecisionRecallMetrics metrics = (PrecisionRecallMetrics) Utils.readObject(
                task.getEvaluationMetricsName());

        PrecisionRecall micro = metrics.microAverage();
        PrecisionRecall macro = metrics.microAverage();
        PrintWriter out = response.getWriter();
        out.println("<b>"+"micro precision: "+"</b>" + micro.precision()+"<br>");
        out.println("<b>"+"micro recall: "+"</b>" + micro.recall()+"<br>");
        out.println("<b>"+"micro F1: "+"</b>" + micro.F1()+"<br>"+"<br>");

       out.println("<b>"+"macro precision: "+"</b>" + macro.precision()+"<br>");
       out.println("<b>"+"macro recall: "+"</b>" + macro.recall()+"<br>");
       out.println("<b>"+"macro F1: "+"</b>" + macro.F1()+"<br>");

        printAccuracyStats(metrics, cesta+"/model-eval-metrics.txt");

        TaskExecutor.shutdown();
    }

    static void printAccuracyStats(List<PrecisionRecall> stats, String file)
            throws IOException {
        PrintStream out = new PrintStream(new FileOutputStream(file));

        out.println("TP\tFP\tTN\tFN\tprecision\trecall\tF1");

        for (PrecisionRecall pr : stats) {
            if (pr != null) {
                out.print(pr.truePositive() + "\t");
                out.print(pr.falsePositive() + "\t");
                out.print(pr.trueNegative() + "\t");
                out.print(pr.falseNegative() + "\t");

                out.print(pr.precision() + "\t");
                out.print(pr.recall() + "\t");
                out.print(pr.F1() + "\t");
            } else {
                out.print("-\t-\t-\t-\t-\t-\t-");
            }
            out.println();
        }

        out.close();
    }

}
