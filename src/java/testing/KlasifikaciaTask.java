package testing;

import org.gridgain.grid.*;
import java.io.IOException;
import java.util.*;
import org.gridgain.grid.logger.GridLogger;
import org.gridgain.grid.resources.GridJobContextResource;
import org.gridgain.grid.resources.GridLoggerResource;
import org.gridgain.grid.util.gridify.GridifyJobAdapter;
import org.jbowl.data.Instances;
import org.jbowl.model.BuildSettings;
import org.jbowl.model.supervised.MultiLabelModel;
import org.jbowl.model.supervised.tree.DecisionTree;
import org.jbowl.model.supervised.tree.TreeSettings;
import org.jbowl.task.BuildModelTask;
import org.jetbrains.annotations.Nullable;

@GridTaskName("KlasifikaciaTask")

public class KlasifikaciaTask extends GridTaskSplitAdapter<Instances, Integer> {
    /** Auto-injected grid logger. */
    @GridLoggerResource
    private GridLogger log = null;

     public int c = 0;
     public int zac = 0;
     public int kon = 0;
    
     public Collection<? extends GridJob> split(final int gridSize, final Instances instances) {

        //final List<GridJob> jobs = new ArrayList<GridJob>(gridSize);
    	List<GridJobAdapterEx> jobs = new ArrayList<GridJobAdapterEx>(gridSize);
    	 
    	
        final int numOfCategories = instances.numOfCategories();
        final int categoriesPerTask = numOfCategories / gridSize;
        final TreeSettings settings = new TreeSettings();
        System.out.println("pocet uzlov: "+gridSize);
        System.out.println("pocet jobov na uzol: cca "+categoriesPerTask);
        
        BuildModelTask task = new BuildModelTask();

        task.setAlgorithm("org.jbowl.model.supervised.tree.TreeAlgorithm");
        
        
        for (c = 0; c < gridSize; c++) {

        	System.out.println("C: "+c);
        	zac = categoriesPerTask * (c) + 1;
            kon = gridSize - (c) == 1 ? numOfCategories : categoriesPerTask * (c + 1);
                    	
            jobs.add(new GridJobAdapterEx(c) {
            	            	
            	@Override 
                public List execute() throws GridException {
            		
                    KlasifikaciaImpl objekt = new KlasifikaciaImpl();
                    return (List) objekt.buildModel(instances, settings, zac, kon);
					                  
                    
                    }
            });
        }
        return jobs;
    }
    
    public Integer reduce(List<GridJobResult> results) throws GridException {
        for (GridJobResult res : results) {
            if (res.getData() != null) {
                res.getData();
            	return null;
            	            }
        }
        return null;
    }
}