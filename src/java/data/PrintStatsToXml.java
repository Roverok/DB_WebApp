package data;

/**
 * Trida na vytvaranie xml reprezentacie
 * @author Zdeno
 */
import org.ajbowl.data.Instances;
import org.ajbowl.model.unsupervised.HierarchicalModel;
import org.ajbowl.model.unsupervised.ghsom.GSOMModel;
import org.ajbowl.util.HashIndexedSet;
import org.ajbowl.util.IntSet;

import java.io.*;
import java.util.LinkedList;
import org.ajbowl.model.descriptive.LabelingModel;
import org.ajbowl.model.descriptive.labeling.TermEvalLabeling;
import org.ajbowl.model.descriptive.labeling.TermEvalLabelingSettings;

public class PrintStatsToXml {

    public static void printGHSOMModelStatistics(Instances instances, HashIndexedSet dictionary,
            HierarchicalModel hModel, String zlozka, String filePath)
            throws IOException, ClassNotFoundException {
        
        //premaze subor
        if (new File("C:/Users/Zdeno/SkyDrive/Diplomova_Praca/ZALOHA/DP_ULBRIK_ZDENO/program/DP_WebApp/build/web/GHSOMStats.xml").exists()) {
            File file = new File("C:/Users/Zdeno/SkyDrive/Diplomova_Praca/ZALOHA/DP_ULBRIK_ZDENO/program/DP_WebApp/build/web/GHSOMStats.xml");
            file.delete();
        }

        HierarchicalModel GHSOMmodel;
        GHSOMmodel = hModel;
        HierarchicalModel.Node root = GHSOMmodel.getRoot();
        //nastavenie pre informacny zisk, ziskavam len po 6 termov na kazdy neuron
        TermEvalLabelingSettings settings = new TermEvalLabelingSettings();
        settings.setMaxNumberOfTerms(6);

        GSOMModel gsomModel;
        IntSet clusters[] = new IntSet[instances.size()];
        LinkedList queue = new LinkedList();
        LinkedList instancesQueue = new LinkedList();
        queue.addLast(root);
        instancesQueue.addLast(instances);
        gsomModel = (GSOMModel) root.getModel();
        PrintWriter out = new PrintWriter(new FileWriter("C:/Users/Zdeno/SkyDrive/Diplomova_Praca/ZALOHA/DP_ULBRIK_ZDENO/program/DP_WebApp/build/web/GHSOMStats.xml")); 
            //xml subor musi mat deklaraciu
            out.println("<?xml version=\"1.0\"?>");
            out.println("<NODES>");
            
            int id = 0;
            while (queue.size() > 0) {
                //vzdy si berie len jednu mapu, ktora je typu GSOM a instancie, ktore jej patria
                HierarchicalModel.Node node = (HierarchicalModel.Node) queue.removeFirst();
                Instances filteredInstances = (Instances) instancesQueue.removeFirst();
                
                if (node.getModel() instanceof GSOMModel) {
                    gsomModel = (GSOMModel) node.getModel();
                    
                    out.println("<NODE id=\"" + id + "\">");
                    out.println("\t<LEVEL>" + node.getLevel() + "</LEVEL>");
                    out.println("\t<CURRENT_NODE>" + node + "</CURRENT_NODE>");
                    out.println("\t<PARENT>" + node.getParent() + "</PARENT>");
                    out.println("\t<CHILDREN>" + node.getChildren() + "</CHILDREN>");
                    out.println("\t<NUM_OF_CHILDREN>" + node.getChildren().size() + "</NUM_OF_CHILDREN>");
                    out.println("\t<ROWS>" + gsomModel.getRows() + "</ROWS>");
                    out.println("\t<COLUMNS>" + gsomModel.getColumns() + "</COLUMNS>");
                    out.println("\t<DEFAULT_MQE>" + gsomModel.getDefaultMQE() + "</DEFAULT_MQE>");
                    out.println("\t<LEAF>" + node.isLeaf() + "</LEAF>");
                    
                    out.print("\t<CLUSTERS_MQE>");
                    for (int i = 0; i < gsomModel.numOfClusters(); i++) {
                        out.print(gsomModel.getClustersMQE()[i] + ", ");
                    }
                    out.print("</CLUSTERS_MQE>\n");
                    
                    out.print("\t<VECTOR_CNT_PC>");
                    int vectorCount = 0;
                    for (int i = 0; i < gsomModel.getCounts().length; i++) {
                        out.print(gsomModel.getCounts()[i] + ", ");
                        vectorCount += gsomModel.getCounts()[i];
                    }
                    out.print("</VECTOR_CNT_PC>\n");
                    out.println("\t<TNV>" + vectorCount + "</TNV>");
                    out.println("\t<TNI>" + filteredInstances.size() + "</TNI>");
                    
                    for (int i = 0; i < filteredInstances.size(); i++) {
                        clusters[i] = gsomModel.classify(filteredInstances.get(i));
                    }
                    
                    out.println("\t<CLUSTERS>");
                    //Informacny zisk
                    settings.setInputModel(gsomModel);
                    //vzdy z jednej mapy spravy labeling model
                    LabelingModel model = new TermEvalLabeling().build(instances, settings);
                    
                    //numOFCategories predstavuje pocet neuronov na mape
                    for (int i = 0; i < model.numOfCategories(); i++) {
                        out.print("\t\t<CLUSTER num=\"" + i + "\">");
                        int[] pole = model.getSelectedTerms(i);
                        
                        for (int j = 0; j < pole.length; j++) {
                            out.print(dictionary.get(pole[j]) + ", ");
                        }
                        out.println("</CLUSTER>");
                    }
                    out.println("\t</CLUSTERS>");
                    out.println("</NODE>");
                }
                for (int i = 0; i < node.getChildren().size(); i++) {
                    Instances filteredInstancesTMP = new Instances();
                    
                    if (node.getChildren().get(i) != null) {
                        queue.addLast(node.getChildren().get(i));
                        
                        for (int n = 0; n < filteredInstances.size(); n++) {
                            if (clusters[n].first() == i) {
                                filteredInstancesTMP.add(filteredInstances.get(n));
                            }
                        }
                        instancesQueue.addLast(filteredInstancesTMP);
                    }
                }
                id++;
            }
            out.println("</NODES>");
            System.out.println("Model Printed");
        
    }
}
