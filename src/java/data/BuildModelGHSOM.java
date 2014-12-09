package data;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.ajbowl.data.Instances;
import org.ajbowl.data.processing.InstanceInputStream;
import org.ajbowl.model.Model;
import org.ajbowl.model.unsupervised.HierarchicalModel;
import org.ajbowl.model.unsupervised.ghsom.GHSOMAlgorithm;
import org.ajbowl.model.unsupervised.ghsom.GHSOMSettings;
import org.ajbowl.model.unsupervised.ghsom.GSOMModel;
import org.ajbowl.util.HashIndexedSet;
import org.ajbowl.util.math.Similarity;
import org.gridgain.grid.Grid;
import org.gridgain.grid.GridException;
import org.gridgain.grid.typedef.G;

/**
 *
 * @author Zdeno
 */
public class BuildModelGHSOM extends HttpServlet {    
    /**
     * Hlavna metoda, vytvara model GHSOM a jeho xml reprezentaciu
     * @param hlbkaGHSOM
     * @param minNumberOfInstances
     * @param tau2
     * @param startingRows
     * @param startingColumns
     * @param expandCycles
     * @param initNeighbourhood
     * @param tau1
     * @param initLearnRate
     * @param metoda
     * @param request
     * @param response
     * @throws GridException
     * @throws Exception
     * @throws ServletException
     * @throws IOException 
     */
    public void main(Integer hlbkaGHSOM, Integer minNumberOfInstances, double tau2,
            Integer startingRows, Integer startingColumns,
            Integer expandCycles, Integer initNeighbourhood,
            double tau1, double initLearnRate, String metoda,
            HttpServletRequest request, HttpServletResponse response)
            throws GridException, Exception, ServletException, IOException {
                
        System.out.println("\nCreating GHSOM model...\n");
        System.out.println("----------------------------------------------------------");
        final Grid grid = G.grid();
        Context env = (Context) new InitialContext().lookup("java:comp/env");
        String filePath = (String) env.lookup("file-upload");
        String meno = request.getParameter("vstupne_data");
        String zlozka = meno.replaceAll("\\.", "_");
        
        if (!new File(filePath + "/" + zlozka + "/" + "ghsom/").exists()) {
            new File(filePath + "/" + zlozka + "/" + "ghsom/").mkdir();
        }
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        long start = System.currentTimeMillis();
        Instances instances = new Instances(new InstanceInputStream(
                filePath + "/" + zlozka + "/" + "GHSOM-instances"));
        HashIndexedSet dictionary
                = (org.ajbowl.util.HashIndexedSet)
                UtilsGHSOM.readObject(filePath + "/" + zlozka + "/" + "GHSOM-dictionary");
        /**
         * gw v sebe nesie potrebné parametre o mape a o zlozke, kde sa ma ukladat
         */
        GHSOMWrapper gw = new GHSOMWrapper();
        gw.setFilePAth(filePath);
        gw.setZlozka(zlozka);
        gw.setDictionary(dictionary);
        gw.setInstances(instances);
        gw.setHlbkaGHSOM(hlbkaGHSOM);
        gw.setMinNumberOfInstances(minNumberOfInstances);
        gw.setStartingRows(startingRows);
        gw.setStartingColumns(startingColumns);
        gw.setExpandCycles(expandCycles);
        gw.setInitNeighbourhood(initNeighbourhood);
        gw.setTau1(tau1);
        gw.setTau2(tau2);
        gw.setInitLearnRate(initLearnRate);
        gw.setMetoda(metoda);        
        
        //hlavna cast
        try {
            grid.deployTask(GHSOMTask.class);
            List<HierarchicalModel> hierarchicalModelList = grid.execute(GHSOMTask.class, gw).get();
            grid.undeployTask("GHSOMTask");

            for (int i = 0; i < hierarchicalModelList.size(); i++) {
                UtilsGHSOM.writeObject(hierarchicalModelList.get(i), filePath + "/" + zlozka + "/" + "ghsom/ghsom-" + i);
            }
            //metoda na spajanie modelov
            uniteModels(filePath, zlozka);
        } catch (GridException e) {
            e.printStackTrace();
        }
        System.out.println("Printing Stats to xml file...");
        //metoda vytva xml reprezentaciu modelu ghsom
        PrintStatsToXml.printGHSOMModelStatistics
        (instances, dictionary, (HierarchicalModel) UtilsGHSOM.readObject(filePath + "/" + zlozka + "/" + "GHSOM-model"), zlozka, filePath);   
        System.out.println("\nDone.");
    }
/**
 * Metoda spaja ciastkove modely do jedneho, aby bolo mozne vytvorit xml reprezentaciu
 * @param filePath  cesta k suboru
 * @param zlozka    cesta k suboru
 * @throws IOException
 * @throws ClassNotFoundException 
 */
    private static void uniteModels(String filePath, String zlozka) throws IOException, ClassNotFoundException {
        //nacitanie mapy prvej urovne
        GSOMModel gsom = (GSOMModel) UtilsGHSOM.readObject(filePath + "/" + zlozka + "/" + "gsom");
        //zistenie poctu neronov na mape 1. urovne
        HierarchicalModel.Node children[] = new HierarchicalModel.Node[gsom.numOfClusters()];
        HierarchicalModel hModelPart = null;
        int numOfFiles = new File(filePath + "/" + zlozka + "/" + "ghsom/").listFiles().length;
        
        for (int i = 0; i < numOfFiles; i++) {
            hModelPart = (HierarchicalModel) UtilsGHSOM.readObject(filePath + "/" + zlozka + "/" + "ghsom/ghsom-" + i);
            children[i] = hModelPart.getRoot();
        }
        HierarchicalModel.Node root = new HierarchicalModel.Node(null, gsom);
        //nastavi referenciu mape 1. urovne na detske mapy
        root.setChildren(children);
        //nastavi referencie podmapam na mapu 1. urovne
        for (int i = 0; i < numOfFiles; i++) {
            children[i].setParent(root);
        }
        
        //vymaze po sebe subory, kvoli setreniu miesta
        for(int i=0; i<numOfFiles; i++){
            boolean file = new File (filePath + "/" + zlozka + "/" + "ghsom/ghsom-" + i).delete();
        }
        boolean file = new File(filePath + "/" + zlozka + "/" + "ghsom/").delete();
        
        HierarchicalModel hModel = new HierarchicalModel(root);
        //ulozi model
        UtilsGHSOM.writeObject(hModel, filePath + "/" + zlozka + "/" + "GHSOM-model");
    }
}
