package gg;


import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.gridgain.grid.*;
import org.gridgain.grid.typedef.G;
import org.jetbrains.annotations.Nullable;

@GridTaskName("RestartNodUloha")
public class RestartNodUloha extends GridTaskSplitAdapter<String, Object> {
	private static final long serialVersionUID = 1L;

	@Override protected Collection<? extends GridJob> split(int gridSize, final String arg) throws GridException {
        Collection<GridJob> jobs = new ArrayList<GridJob>(gridSize);

        for (int i = 0; i < gridSize; i++) {
            jobs.add(new GridJobAdapterEx() {
				private static final long serialVersionUID = 1L;

				@Nullable
                @Override public Serializable execute() {
                    String prijate_id=G.grid().localNode().id().toString();
                    
                    System.out.println(">>>Poziadavka na restartovanie nodu s id:"+arg);
             
                    if (prijate_id.equals(arg))
                    {
                    	System.out.println(">>>Tento nod bude restartovany");
                    	G.restart(false, false);
                    }
                    
 
                    // This job does not return any result.
                    return null;
                }
            });
        }

        return jobs;
    }

    @Override public Object reduce(List<GridJobResult> results) throws GridException {
        return null;
    }
}
