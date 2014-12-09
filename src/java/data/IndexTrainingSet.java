package data;

import examples.task.Utils;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.concurrent.TimeUnit;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.ajbowl.process.InstanceProcess;
import org.jbowl.analysis.AnnotatedText;
import org.jbowl.analysis.tokens.*;
import org.jbowl.data.Instance;
import org.jbowl.data.processing.InstanceInputStream;
import org.jbowl.data.processing.InstanceOutputStream;
import org.jbowl.data.processing.Statistics;
import org.jbowl.data.processing.TFIDFFilter;
import org.jbowl.document.processing.DocumentAnalyzer;
import org.jbowl.document.processing.DocumentIndexer;
import org.jbowl.document.xml.XMLDocumentIndexer;
import org.jbowl.process.DataTarget;
import org.jbowl.util.HashIndexedSet;
import org.jbowl.util.IndexedSet;

public class IndexTrainingSet extends HttpServlet {

    //pridane kvoli jbowlu pre GHSOM
    /*
    static org.ajbowl.process.TextProcess createTextAnalyzer2(String[] param) {
        String tokenizer = param[0];
        String stopfilter = param[1];
        String stemmer = param[2];

        org.ajbowl.analysis.tokens.Tokenizer tk = null;

        if ("SimpleTokenizer".equals(tokenizer)) {
            if ("StopFilter".equals(stopfilter)) {
                if ("PorterStemmer".equals(stemmer)) {
                    tk = new org.ajbowl.analysis.tokens.SimpleTokenizer(
                            new org.ajbowl.analysis.tokens.StopFilter(new org.ajbowl.analysis.tokens.PorterStemmer()));
                } else {
                    tk = new org.ajbowl.analysis.tokens.SimpleTokenizer(
                            new org.ajbowl.analysis.tokens.StopFilter());
                }
            } else {
                tk = new org.ajbowl.analysis.tokens.SimpleTokenizer();
            }
        } else if ("RegExTokenizer".equals(tokenizer)) {
            if ("StopFilter".equals(stopfilter)) {
                if ("PorterStemmer".equals(stemmer)) {
                    tk = new org.ajbowl.analysis.tokens.SimpleTokenizer(
                            new org.ajbowl.analysis.tokens.StopFilter(new org.ajbowl.analysis.tokens.PorterStemmer()));
                } else {
                    tk = new org.ajbowl.analysis.tokens.SimpleTokenizer(
                            new org.ajbowl.analysis.tokens.StopFilter());
                }
            } else {
                tk = new org.ajbowl.analysis.tokens.SimpleTokenizer();
            }
        } else if ("WhitespaceTokenizer".equals(tokenizer)) {
            if ("StopFilter".equals(stopfilter)) {
                if ("PorterStemmer".equals(stemmer)) {
                    tk = new org.ajbowl.analysis.tokens.WhitespaceTokenizer(
                            new org.ajbowl.analysis.tokens.StopFilter(new org.ajbowl.analysis.tokens.PorterStemmer()));
                } else {
                    tk = new org.ajbowl.analysis.tokens.WhitespaceTokenizer(
                            new org.ajbowl.analysis.tokens.StopFilter());
                }
            } else {
                tk = new org.ajbowl.analysis.tokens.WhitespaceTokenizer();
            }
        }
        return tk;
    }
    */
    
    static DataTarget<AnnotatedText> createTextAnalyzer(String[] param) {
        String tokenizer = param[0];
        String stopfilter = param[1];
        String stemmer = param[2];

        DataTarget<AnnotatedText> pom = null;

        if ("SimpleTokenizer".equals(tokenizer)) {
            if ("StopFilter".equals(stopfilter)) {
                if ("PorterStemmer".equals(stemmer)) {
                    pom = new SimpleTokenizer(new StopFilter(new PorterStemmer()));
                } else {
                    pom = new SimpleTokenizer(new StopFilter());
                }
            } else {
                pom = new SimpleTokenizer();
            }
        } else if ("RegExTokenizer".equals(tokenizer)) {
            if ("StopFilter".equals(stopfilter)) {
                if ("PorterStemmer".equals(stemmer)) {
                    pom = new RegExTokenizer(new StopFilter(new PorterStemmer()));
                } else {
                    pom = new RegExTokenizer(new StopFilter());
                }
            } else {
                pom = new RegExTokenizer();
            }
        } else if ("WhitespaceTokenizer".equals(tokenizer)) {
            if ("StopFilter".equals(stopfilter)) {
                if ("PorterStemmer".equals(stemmer)) {
                    pom = new WhitespaceTokenizer(new StopFilter(new PorterStemmer()));
                } else {
                    pom = new WhitespaceTokenizer(new StopFilter());
                }
            } else {
                pom = new WhitespaceTokenizer();
            }
        }
        return pom;
    }

    public static void main(String[] args, boolean test, HttpServletRequest request, HttpServletResponse response)
            throws Exception, ServletException, IOException {

        response.setContentType("text/html");
        Context env = (Context) new InitialContext().lookup("java:comp/env");
        String filePath = (String) env.lookup("file-upload");

        String meno = args[0];
        String cesta = args[1];
        String TFIDF_SCHEME = args[2];
        String tokenizer = args[3];
        String stopfilter = args[4];
        String stemmer = args[5];
        //cesta = ("D:/_DP/projects/DP_WebApp/data/Reuters-21578 ModApte/"+meno);
        cesta = (filePath + "/" + meno);
        String zlozka = meno.replaceAll("\\.", "_");

        long start = System.currentTimeMillis();
        // čas začiatku indexácie

        // výstup na web
        PrintWriter out = response.getWriter();
        out.println("<p class='nadpis'>predspracovanie: </p>");

        if (!new File(filePath + "/" + zlozka).exists()) {
            new File(filePath + "/" + zlozka).mkdir();
        }

        File tmp = File.createTempFile("tmp", null);
        tmp.deleteOnExit();

        IndexedSet<String> terms = new HashIndexedSet<String>();
        IndexedSet<String> categories = new HashIndexedSet<String>();

        Statistics trainStats = new Statistics(
                new Utils.ProgressLogger(
                        new InstanceOutputStream(tmp)));

        XMLDocumentIndexer indexer = new XMLDocumentIndexer(
                new DocumentAnalyzer(createTextAnalyzer(new String[]{tokenizer, stopfilter, stemmer}),
                        new DocumentIndexer(terms, categories, trainStats)));

        System.out.println("indexing training set:<br/>");
        out.println("<p><b>indexovaná trénovacia množina:</b><br/>" + meno + "</p>");
        indexer.indexFile(cesta);
        indexer.close();

        System.out.println("'" + TFIDF_SCHEME + "' vahovacia schema termov:");
        out.println("<p><b>váhovacia schéma termov:</b> '" + TFIDF_SCHEME + "'</p>");
        new InstanceInputStream(tmp).processAll(
                new TFIDFFilter(TFIDF_SCHEME, trainStats,
                        new Utils.ProgressLogger(
                                new InstanceOutputStream(filePath + "/" + zlozka + "/train-instances"))));
        Utils.writeObject(trainStats, filePath + "/" + zlozka + "/train-stats");
        Utils.writeObject(terms, filePath + "/" + zlozka + "/term-dictionary");
        Utils.writeObject(categories, filePath + "/" + zlozka + "/category-dictionary");
        Utils.printTermStats(trainStats, terms, filePath + "/" + zlozka + "/term-train-stats.txt");
        Utils.printCategoryStats(trainStats, categories, filePath + "/" + zlozka + "/category-train-stats.txt");
        System.out.println("terms:" + trainStats.numOfTerms());
        System.out.println("categories:" + trainStats.numOfCategories());
        System.out.println("training documents:" + trainStats.numOfInstances());
        out.println("<p>počet termov: " + trainStats.numOfTerms());
        out.println("<br/>počet kategoríi: " + trainStats.numOfCategories());
        out.println("<br/>počet trénovacích dokumentov: " + trainStats.numOfInstances());
        //tu bol povodne casovy vypis

        if (test != false) {
            IndexTestingSet.main(args, request, response);
        }

        ////////////////////////////////////////////////////////////////////////
        /*jbowl 09_08 a jbowl s GHSOMom indexuju data inac, pre ghsom
         nemozno pozuit tie iste data, preto sa data indexuju 2x, podla
         jbowlu 09_08 a podla jbowlu s GHSOMOM:
         */
        
        
        /*
        System.out.println("Indexujem pre GHSOM");
        File tmp2 = File.createTempFile("tmp2", null);
        tmp2.deleteOnExit();

        org.ajbowl.util.IndexedSet<String> terms2 = new org.ajbowl.util.HashIndexedSet<String>();
        org.ajbowl.util.IndexedSet<String> categories2 = new org.ajbowl.util.HashIndexedSet<String>();

        org.ajbowl.data.processing.Statistics trainStats2 = new org.ajbowl.data.processing.Statistics(
                (org.ajbowl.process.InstanceProcess) new UtilsGHSOM.ProgressLogger(
                        new org.ajbowl.data.processing.InstanceOutputStream(tmp2)));

        org.ajbowl.document.xml.XMLDocumentIndexer indexer2
                = new org.ajbowl.document.xml.XMLDocumentIndexer(
                        new org.ajbowl.document.processing.DocumentAnalyzer(
                                createTextAnalyzer2(new String[]{tokenizer, stopfilter, stemmer}), new org.ajbowl.document.processing.DocumentIndexer(
                                        terms2, categories2, trainStats2)));

        indexer2.indexFile(cesta);
        indexer2.close();

        new org.ajbowl.data.processing.InstanceInputStream(tmp2).processAll(
                new org.ajbowl.data.processing.TFIDFFilter(
                        TFIDF_SCHEME, trainStats2, new UtilsGHSOM.ProgressLogger(
                                new org.ajbowl.data.processing.InstanceOutputStream(
                                        filePath + "/" + zlozka + "/GHSOM-instances"))));

        UtilsGHSOM.writeObject(trainStats2, filePath + "/" + zlozka + "/GHSOM-stats");
        UtilsGHSOM.writeObject(terms2, filePath + "/" + zlozka + "/GHSOM-dictionary");
        */
                
                
        long totalTime = (System.currentTimeMillis() - start);
        long min = TimeUnit.MILLISECONDS.toMinutes(totalTime);
        long sec = TimeUnit.MILLISECONDS.toSeconds(totalTime) - min * 60;
        long ms = TimeUnit.MILLISECONDS.toMillis(totalTime) - sec * 1000;
        System.out.println("DONE");
        out.println("<br/><hr>čas indexácie: " + min + "min " + sec + "." + ms + "s</p>");
    }
}
