package data;

import org.gridgain.grid.*;
import org.gridgain.grid.logger.GridLogger;
import org.gridgain.grid.resources.GridLoggerResource;
import org.ajbowl.data.Instances;
import org.ajbowl.model.unsupervised.HierarchicalModel;
import org.ajbowl.model.unsupervised.ghsom.*;

import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import org.ajbowl.util.math.Similarity;
import static org.ajbowl.util.math.Similarity.*;

/**
 * trieda sluzi na vytvorenie gsom mapy (mapa 1. urovne) a na vytvorenie
 * ciastkovych modelov
 * @author Zdeno
 */
public class GHSOMTask extends GridTaskSplitAdapter<GHSOMWrapper, List<HierarchicalModel>> {

    @GridLoggerResource
    private GridLogger log = null;

    @Override
    protected Collection<? extends GridJob> split(final int gridSize, final GHSOMWrapper gw) {

        Instances instances = gw.getInstances();
        String filePath = gw.getFilePAth();
        String zlozka = gw.getMenoZlozka();

        //mapa GSOM
        GSOMAlgorithm gsomAlgorithm = new GSOMAlgorithm();
        GSOMSettings gsomSettings = new GSOMSettings();
        final GHSOMSettings ghsomSettings = new GHSOMSettings();
        
        //nastavenia GSOM mapy
        gsomSettings.setExpandCycles(gw.getExpandCycles());
        gsomSettings.setInitLearnRate(gw.getInitLearnRate());
        gsomSettings.setInitNeighbourhood(gw.getInitNeighbourhood());
        if (gw.getMetoda() == "dotProduct") {
            gsomSettings.setSimilarity(dotProduct);
        } else {
            gsomSettings.setSimilarity(cosineSimilarity);
        }
        gsomSettings.setStartingColumns(gw.getStartingColumns());
        gsomSettings.setStartingRows(gw.getStartingRows());
        gsomSettings.setTau1(gw.getTau1());
        
        //nastavenia GHSOM
        ghsomSettings.setExpandCycles(gw.getExpandCycles());
        ghsomSettings.setInitLearnRate(gw.getInitLearnRate());
        ghsomSettings.setInitNeighbourhood(gw.getInitNeighbourhood());
        ghsomSettings.setMaxDepth(gw.getHlbkaGHSOM());
        ghsomSettings.setMinNumberOfInstances(gw.getMinNumberOfInstances());
        if (gw.getMetoda() == "dotProduct") {
            ghsomSettings.setSimilarity(dotProduct);
        } else {
            ghsomSettings.setSimilarity(cosineSimilarity);
        }
        ghsomSettings.setStartingColumns(gw.getStartingColumns());
        ghsomSettings.setStartingRows(gw.getStartingRows());
        ghsomSettings.setTau1(gw.getTau1());
        ghsomSettings.setTau2(gw.getTau2());

        long time = System.currentTimeMillis();
        //vytvorenie mapy 1. urovne
        GSOMModel gsomModel = gsomAlgorithm.build(instances, gsomSettings);
        System.out.println("GSOM Model created, time taken: " + (System.currentTimeMillis() - time) / 1000f);

        //ulozenie mapy prvej urovne        
        try {
            UtilsGHSOM.writeObject(gsomModel, filePath + "/" + zlozka + "/" + "gsom");
        } catch (IOException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }

        /*
         //este z bakalarskej prace, pre rychlejsie tesotvanie gridgainu
         GSOMModel gsomModel = null;
         try {
         gsomModel = (GSOMModel) UtilsGHSOM.readObject("temp/gsom");
         } catch (IOException e) {
         e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
         } catch (ClassNotFoundException e) {
         e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
         }
         */
        //label expandable clusters
        double tau2 = ghsomSettings.getTau2();
        double defaultMQE = gsomModel.getDefaultMQE();
        double clustersMQE[] = gsomModel.getClustersMQE();
        int counts[] = gsomModel.getCounts();

        //naje expandovatelne neurony
        boolean expand[] = new boolean[gsomModel.numOfClusters()];

        for (int i = 0; i < clustersMQE.length; i++) {
            if (tau2 * defaultMQE < clustersMQE[i] && counts[i] >= ghsomSettings.getMinNumberOfInstances()) {
                expand[i] = true;
            }
        }

        //spocita expandovatelne neurony
        int expandableClusterCount = 0;
        for (int i = 0; i < expand.length; i++) {
            if (expand[i]) {
                expandableClusterCount++;
            }
        }

        //priradi instancie expandovatelnym neurom
        int clusters[] = new int[instances.size()];
        for (int i = 0; i < instances.size(); i++) {
            clusters[i] = gsomModel.classify(instances.get(i)).first();
        }

        int jobCount = expandableClusterCount;

        //System.out.println("ExpandableClusterCount " + expandableClusterCount);

        List<GridJob> jobs = new ArrayList<GridJob>(jobCount);

        for (int i = 0; i < jobCount; i++) {
            Instances filteredInstances = new Instances(counts[i]);

            for (int j = 0; j < instances.size(); j++) {
                if (clusters[j] == i) {
                    filteredInstances.add(instances.get(j));
                }
            }
            
            //priraduje ulohy na zhluky
            jobs.add(new GridJobAdapterEx(new NodeExecutionData(filteredInstances, i)) {

                //@Nullable
                @Override
                public HierarchicalModel execute() {
                    NodeExecutionData exData = ((NodeExecutionData) this.argument(0));
                    Instances localInstances = exData.getInstances();
                    Integer clusterNumber = exData.getNumberOfCluster();

                    long start = System.currentTimeMillis();

                    //System.out.println("Creating GHSOM model.");
                    //System.out.println("Cluster number " + clusterNumber);

                    //System.out.println("Documents " + localInstances.size());
                    GHSOMAlgorithm algorithm = new GHSOMAlgorithm();
                    //vytvara ciastkove modely
                    HierarchicalModel<GHSOMSettings> build = algorithm.build(localInstances, ghsomSettings);

                    System.out.println("\nModel from cluster " + clusterNumber + " created, time taken: " 
                            + (System.currentTimeMillis() - start) / 1000f + "s\n");

                    return build;
                }
            });
        }
        return jobs;
    }

    /**
     * pomocna trieda, posuva potrebne udaje na tvorenie ciastkoych map
     */
    public static class NodeExecutionData implements Serializable {

        public Instances getInstances() {
            return instances;
        }

        public Integer getNumberOfCluster() {
            return numberOfCluster;
        }

        private Instances instances;
        private Integer numberOfCluster;

        private NodeExecutionData(Instances instances, int numberOfCluster) {
            this.instances = instances;
            this.numberOfCluster = numberOfCluster;
        }
    }

    /**
     * MapReduce, vracia ciastkove modely
     * @param results
     * @return ciastkove modely
     * @throws GridException 
     */
    @Override
    public List<HierarchicalModel> reduce(List<GridJobResult> results) throws GridException {
        List<HierarchicalModel> finalList = new ArrayList<HierarchicalModel>();
        for (GridJobResult res : results) {
            if (res.getData() != null) {
                HierarchicalModel model = res.getData();
                finalList.add(model);
            }
        }
        return finalList;
    }
}
