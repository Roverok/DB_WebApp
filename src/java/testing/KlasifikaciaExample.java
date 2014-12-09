package testing;

import org.gridgain.grid.Grid;
import org.gridgain.grid.GridException;
import org.gridgain.grid.typedef.G;
import org.jbowl.data.Instances;
import org.jbowl.data.processing.InstanceInputStream;
import org.jbowl.task.BuildModelTask;

public final class KlasifikaciaExample{

    public static void main(String[] args) throws GridException, Exception{

         Grid grid = args.length == 0 ? G.start() : G.start(args[0]);

            BuildModelTask task = new BuildModelTask();

            // temp-reuters/train-instances - indexovana datova mnozina Reuters
            // temp-medline/train-instances - indexovana datova mnozina MEDLINE
            // temp-medline/model - ciel pre ulozenie vektorovej reprezentacie kolekcie MEDLINE
            // temp-reuters/model - ciel pre ulozenie vektorovej reprezentacie kolekcie Reuters
			
            task.setAlgorithm("org.jbowl.model.supervised.tree.TreeAlgorithm");
            task.setBuildData(new InstanceInputStream("web_temp/train-instances"));
            task.setModelName("web_temp/model");

            Instances instances = new Instances (new InstanceInputStream ("web_temp/train-instances"));
            int numOfCategories = instances.numOfCategories();

        try {

            System.out.println("\nPocet kategorii je: " + numOfCategories);

            grid.execute(KlasifikaciaTask.class, instances).get();

            System.out.println("\n>>> Koniec klasifikacie <<<");
        }
        finally {
            G.stop(grid.name(),true);
        }
    }
}