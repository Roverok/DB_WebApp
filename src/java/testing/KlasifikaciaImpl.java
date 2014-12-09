package testing;


import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import org.jbowl.data.Instances;
import org.jbowl.model.Algorithm;
import org.jbowl.model.IncrementalBuildSettings;
import org.jbowl.model.supervised.FunctionSolver;
import org.jbowl.model.supervised.MultiLabelModel;
import org.jbowl.model.supervised.tree.DecisionTree;
import org.jbowl.model.supervised.tree.TreeInducer;
import org.jbowl.model.supervised.tree.TreeSettings;
import org.jbowl.util.matrix.DoubleFactory1D;
import org.jbowl.util.matrix.DoubleMatrix1D;

public class KlasifikaciaImpl implements Algorithm<MultiLabelModel<DecisionTree, TreeSettings>, TreeSettings> {

    protected FunctionSolver<DecisionTree, TreeSettings> solver;

    protected static final Logger log = Logger.getLogger(
            "org.jbowl.model.supervised");

    KlasifikaciaImpl() {
        this.solver = new TreeInducer();
    }

      
    public MultiLabelModel<DecisionTree, TreeSettings> build(Instances instances, TreeSettings settings) {
        List<DecisionTree> functions = solve(instances, settings);

        if (settings instanceof IncrementalBuildSettings) {
            MultiLabelModel<DecisionTree, TreeSettings> inputModel =
                    ((IncrementalBuildSettings<MultiLabelModel<DecisionTree, TreeSettings>>)settings).
                    getInputModel();
            if (inputModel != null) {
                inputModel.setDecisionFunctions(functions);
                return inputModel;
            }
        }


        return new MultiLabelModel<DecisionTree, TreeSettings>(functions, settings);
    }

    protected List<DecisionTree> solve(Instances instances, TreeSettings settings) {
        int numOfCategories = instances.numOfCategories();

        List<DecisionTree> functions = new ArrayList<DecisionTree>(numOfCategories);
        DoubleMatrix1D y = DoubleFactory1D.indicatorMatrix(
                instances.size(), 1, -1);

        for (int c = 0; c < numOfCategories; c++) {
            log.info((c + 1) + "/" + numOfCategories);

            for (int i = 0; i < instances.size(); i++) {
                y.setQuick(i, instances.get(i).containsCategory(c) ? 1 : -1);
            }
            functions.add(solver.solve(c, instances, y, settings));
        }

        return functions;
    }


    public List<DecisionTree> buildModel(Instances instances, TreeSettings settings, int zac, int kon) {

        int numOfCategories = instances.numOfCategories();
        
        List<DecisionTree> functions = new ArrayList<DecisionTree>(numOfCategories);
        DoubleMatrix1D y = DoubleFactory1D.indicatorMatrix(
                instances.size(), 1, -1);

        long start = System.currentTimeMillis();
        
        // zac-1 a kon-1 pretoze kategorie su zaindexovane 0-89
        for (int c = zac-1; c<=kon-1; c++){

            log.info((c+1) + "/" + numOfCategories);

            long part = System.currentTimeMillis();

            for (int i = 0; i < instances.size(); i++) {
                y.setQuick(i, instances.get(i).containsCategory(c) ? 1 : -1);
            }
            functions.add(solver.solve(c, instances, y, settings));
            
            long partTime = System.currentTimeMillis() - part;
            System.out.println("\n>>> Cas spracovania kategorie " + (c+1) + ": " + partTime + " ms\n");
        }
        long totalTime = System.currentTimeMillis() - start;

        System.out.println("\n>>> Spracovane kategorie na tejto stanici: " + zac + " - " + kon + " z celkoveho poctu " +numOfCategories);
        System.out.println("\n>>> Cas trvania ulohy na tejto stanici: " + totalTime + " ms\n");
        return functions;
    }
    
}