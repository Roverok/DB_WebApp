package data;

import examples.task.Utils;
import java.io.IOException;
import java.io.PrintWriter;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.jbowl.data.processing.InstanceOutputStream;
import org.jbowl.data.processing.Statistics;
import org.jbowl.data.processing.TFIDFFilter;
import org.jbowl.document.processing.DocumentAnalyzer;
import org.jbowl.document.processing.DocumentIndexer;
import org.jbowl.document.xml.XMLDocumentIndexer;
import org.jbowl.util.IndexedSet;

public class IndexTestingSet {

    //static final String TFIDF_SCHEME = IndexTrainingSet.TFIDF_SCHEME;

    @SuppressWarnings("unchecked")
//    public static void main(String[] args) throws Exception {
    public static void main(String[] args, HttpServletRequest request, HttpServletResponse response)
        throws Exception, ServletException, IOException {
        
        // výstup na web
        response.setContentType("text/html");
        String meno=request.getParameter("vstupne_data");
        String zlozka=meno.replaceAll("\\.", "_");
        Context env = (Context)new InitialContext().lookup("java:comp/env");
        String filePath = (String)env.lookup("file-upload");
        
        PrintWriter out = response.getWriter();

        
        String TFIDF_SCHEME = args[2];
        IndexedSet<String> terms = (IndexedSet<String>)Utils.readObject(
                filePath+"/"+zlozka+"/term-dictionary");
        IndexedSet<String> categories = (IndexedSet<String>)Utils.readObject(
                filePath+"/"+zlozka+"/category-dictionary");
        Statistics trainStats = (Statistics)Utils.readObject(
                filePath+"/"+zlozka+"/train-stats");

        Statistics testStats = new Statistics(
                new TFIDFFilter(TFIDF_SCHEME, trainStats,
                new Utils.ProgressLogger(
                new InstanceOutputStream(filePath+"/"+zlozka+"/test-instances"))));

        XMLDocumentIndexer indexer = new XMLDocumentIndexer(
                new DocumentAnalyzer(IndexTrainingSet.createTextAnalyzer(new String[] {args[3], args[4], args[5]}),
                new DocumentIndexer(terms, categories, testStats)));

        System.out.println("indexing testing set:");
        System.out.println("'" + TFIDF_SCHEME + "' term weighting scheme:");

        indexer.indexFile(filePath+"/"+meno);
        indexer.close();

        Utils.writeObject(testStats, filePath+"/"+zlozka+"/test-stats");
        Utils.printTermStats(testStats, terms, filePath+"/"+zlozka+"/term-test-stats.txt");
        Utils.printCategoryStats(testStats, categories, filePath+"/"+zlozka+"/category-test-stats.txt");

        System.out.println("testing documents: " + testStats.numOfInstances());
        out.println("<hr/>testing documents: " + testStats.numOfInstances() + "<hr/>");
    }
}
