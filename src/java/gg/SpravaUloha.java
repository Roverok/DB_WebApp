package gg;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.swing.JOptionPane;

import org.gridgain.grid.GridException;
import org.gridgain.grid.GridJob;
import org.gridgain.grid.GridJobAdapterEx;
import org.gridgain.grid.GridJobResult;
import org.gridgain.grid.GridTaskName;
import org.gridgain.grid.GridTaskSplitAdapter;
import org.gridgain.grid.typedef.G;
import org.jetbrains.annotations.Nullable;

@GridTaskName("SpravaUloha")


public class SpravaUloha extends GridTaskSplitAdapter<String, Object> {
	private static final long serialVersionUID = 1L;	

	@Override
	public Object reduce(List<GridJobResult> results) throws GridException {
		return null;
	}

	@Override
	protected Collection<? extends GridJob> split(int gridSize, final String arg) throws GridException {
	       Collection<GridJob> jobs = new ArrayList<GridJob>(gridSize);

	        for (int i = 0; i < gridSize; i++) {
	            jobs.add(new GridJobAdapterEx() {
					private static final long serialVersionUID = 1L;

					@Nullable
	                @Override public Serializable execute() {
	                    String prijate_id=G.grid().localNode().id().toString();
	                    int rozdelovac = arg.indexOf(";");	                   
	                    String nodId = null;
	                    String message = null;
	                    if (rozdelovac >= 0) {
	                    	nodId = arg.substring(0,rozdelovac);
	                    	message = arg.substring(rozdelovac+1);
	                    }
	                    
	                    System.out.println(">>>Sprava pre nod s id:"+nodId);
	             
	                    if (prijate_id.equals(nodId))
	                    {
	                    	System.out.println(">>>Sprava pre tento nod: "+message);
	                    	List<String> spravy = G.grid().localNode().meta("spravy");
	                    	if (spravy == null) {
	                    		spravy = new ArrayList<String>();
	                    	}
	                    	spravy.add(message);
	                    	G.grid().localNode().addMeta("spravy", spravy);	                    	
	                    	final String m = new String(message);
	                        new Thread(new Runnable() {
	                            public void run() {
	                                JOptionPane.showMessageDialog(null, m, "Sprava", JOptionPane.INFORMATION_MESSAGE);
	                            }
	                        }).start();	                    	
	                    }
	                    
	 
	                    // This job does not return any result.
	                    return null;
	                }
	            });
	        }

	        return jobs;
	}

}
