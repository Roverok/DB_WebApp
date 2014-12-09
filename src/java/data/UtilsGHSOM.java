package data;

import org.ajbowl.data.Instance;
import org.ajbowl.data.processing.InstanceInputStream;
import org.ajbowl.data.processing.Statistics;
import org.ajbowl.document.Descriptor;
import org.ajbowl.document.Document;
import org.ajbowl.process.DocumentFilter;
import org.ajbowl.process.DocumentProcess;
import org.ajbowl.process.InstanceProcess;
import org.ajbowl.process.ProcessingException;
import org.ajbowl.util.IndexedSet;
import org.ajbowl.util.math.IntDoubleFunction;
import org.ajbowl.util.matrix.DoubleMatrix1D;

import java.io.*;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

public class UtilsGHSOM {

    public static class CategoryFilter extends DocumentFilter {

        protected Set<String> descriptors;

        public CategoryFilter(String file, DocumentProcess out)
                throws IOException {
            super(out);

            descriptors = new HashSet<String>();
            BufferedReader reader = new BufferedReader(new InputStreamReader(
                    new FileInputStream(file), "UTF-8"));

            String desc;
            while ((desc = reader.readLine()) != null) {
                desc = desc.trim();
                if (desc.length() != 0) {
                    descriptors.add(desc);
                }
            }
        }

        public Document doProcess(Document document) throws ProcessingException {
            Iterator<Descriptor> desc = document.getDescriptors().iterator();

            while (desc.hasNext()) {
                if (!descriptors.contains(desc.next().getQualifiedName())) {
                    desc.remove();
                }
            }
            return super.doProcess(document);
        }

        public Document process(Document document) throws ProcessingException {
            return null;  //To change body of implemented methods use File | Settings | File Templates.
        }

        public void close() throws IOException {
            //To change body of implemented methods use File | Settings | File Templates.
        }
    }

    public static class ProgressLogger extends org.ajbowl.process.InstanceFilter {

        protected int numOfProcessed = 0;
        protected int numOfInstances = -1;

        private static final String DOT = ".";
        private static final long DOT_RATE = 1000;
        private static final int DOTS_PER_LINE = (int)(60000 / DOT_RATE);

        private int dotCount = 0;
        private long timeStamp = System.currentTimeMillis();

        public ProgressLogger(InstanceProcess out) {
            super(out);
        }

        public ProgressLogger(int numOfInstances, InstanceProcess out) {
            super(out);
            this.numOfInstances = numOfInstances;
        }

        public Instance doProcess(Instance instance) throws ProcessingException {
            numOfProcessed++;
            long now = System.currentTimeMillis();

            if ((now - DOT_RATE) > timeStamp) {
                timeStamp = now;
                System.out.print(DOT);

                if (++dotCount == DOTS_PER_LINE) {
                    if (numOfInstances < 0) {
                        System.out.println("#: " + numOfProcessed);
                    } else {
                        System.out.println((int)(numOfProcessed * 100f)/
                                numOfInstances + "%");
                    }
                    dotCount = 0;
                }
            }

            return super.doProcess(instance);
        }

        public void finish() throws ProcessingException {
            if (dotCount != 0) {
                System.out.println();
            }
            System.out.println("#: " + numOfProcessed);
            super.finish();
        }

    }

    public static Object readObject(String file) throws IOException,
            ClassNotFoundException {
        Object obj;
        ObjectInputStream s = new ObjectInputStream(new FileInputStream(file));

        try {
            obj = s.readObject();
        } finally {
            s.close();
        }
        return obj;
    }

    public static void writeObject(Object obj, String file) throws IOException {
        ObjectOutputStream s = new ObjectOutputStream(new FileOutputStream(file));
        s.writeObject(obj);
        s.close();
    }

    public static void printDictionary(IndexedSet set, String file) throws
            IOException {
        PrintStream out = new PrintStream(new FileOutputStream(file));

        for (int i = 0; i < set.size(); i++) {
            out.println(i + "\t" + set.get(i));
        }
        out.close();
    }

    public static void printTermStats(Statistics stats, IndexedSet terms,
                                      String file) throws IOException {
        PrintStream out = new PrintStream(new FileOutputStream(file));

        for (int i = 0; i < stats.numOfTerms(); i++) {
            out.println(i + "\t" + stats.termFrequency(i) + "\t" +
                    terms.get(i));
        }
        out.close();
    }

    public static void printCategoryStats(Statistics stats, IndexedSet categories,
                                          String file) throws IOException {
        PrintStream out = new PrintStream(new FileOutputStream(file));

        for (int i = 0; i < stats.numOfCategories(); i++) {
            out.println(i + "\t" + stats.categoryFrequency(i) + "\t" +
                    categories.get(i));
        }
        out.close();
    }


    public static void dumpVectors(String file, String outFile)
            throws Exception {
        org.ajbowl.data.processing.InstanceReader in = new InstanceInputStream(file);
        final PrintStream ps = new PrintStream(new FileOutputStream(outFile));

        in.processAll(new org.ajbowl.process.InstanceFilter() {
            public Instance doProcess(Instance instance) throws
                    ProcessingException {
                dumpVector(instance, ps);
                return super.doProcess(instance);
            }
        });

        in.close();
    }

    private static void dumpVector(DoubleMatrix1D vector, final PrintStream out) {
        vector.forEachNonZero(new IntDoubleFunction() {
            public double apply(int index, double value) {
                out.print(index + ":" + value + " ");
                return value;
            }
        });

        if (vector instanceof Instance) {
            out.print("[");
            int categories[] = ((Instance)vector).categories().toArray();

            for (int i = 0; i < categories.length; i++) {
                if (i > 0) {
                    out.print(" ");
                }
                out.print(categories[i]);
            }
            out.print("]");
        }
        out.println();
    }
}
