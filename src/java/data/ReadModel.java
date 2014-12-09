package data;

import examples.task.Utils;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLConnection;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.jbowl.model.supervised.tree.DecisionTree;
import org.jbowl.model.supervised.tree.TreeClassifier;
import org.jbowl.model.supervised.tree.TreeNode;
import org.jbowl.util.IndexedSet;

public class ReadModel extends TreeNode {

    int cnames;
    int maxrange;
    String id;
    String vypis = "";
    File file = new File("d:/diplomovka/upload/train_small_xml/treeOut.txt");

    public void main(int tree, HttpServletRequest request, HttpServletResponse response)
            throws Exception, ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        TreeClassifier tc = (TreeClassifier) Utils.readObject("d:/diplomovka/upload/train_small_xml/model");
        List<DecisionTree> list = tc.getDecisionFunctions();

        System.out.println("počet stromov (kategórií): " + list.size());
        //out.println("<div id='trees'>počet stromov (kategórií): " + list.size() + "</div>");

        TreeNode tn = list.get(tree).getRoot();
        printTree(tree);

    }

    public String printTree(int tree) throws IOException, ClassNotFoundException {
        TreeClassifier tc = (TreeClassifier) Utils.readObject("d:/diplomovka/upload/train_small_xml/model");
        List<DecisionTree> list = tc.getDecisionFunctions();
        TreeNode tn = list.get(tree).getRoot();

        if (file.exists()) {
            System.out.println("subor existuje a bude nahradeny");
            file.delete();
        }

        IndexedSet<String> categories = (IndexedSet<String>) Utils.readObject("d:/diplomovka/upload/train_small_xml/category-dictionary");

        System.out.println("------------------------------------\n"
                + "strom pre kategóriu " + tree + ": " + categories.get(tree));

        id = printNode(tn);
        vypis = "";
        return id;

    }

    public String printNode(TreeNode node) throws IOException, ClassNotFoundException {

        String pd = "";
        int level = 1;
        String pom, index;
        String term, znak, value;
        String[] pole;
        IndexedSet<String> terms = (IndexedSet<String>) Utils.readObject("d:/diplomovka/upload/train_small_xml/term-dictionary");

        FileWriter fw = new FileWriter("d:/diplomovka/upload/train_small_xml/treeOut.txt");

        for (int i = 0; i < node.getLevel(); i++) {
            pd += "\t";
            level++;
        }

        System.out.println(pd + level + ".uroveň: ");                           // vypis urovne stromu
        //System.out.println(pd + node.getPredicate());                           // vypis celej struktury stromu       

        if (!node.isLeaf()) {
            pom = node.getPredicate().toString();                               // zapis rozh.kriteria do pomocnej premennej
            pole = pom.split(" ");                                              // rozdelenie podla medzier
            index = pole[0].substring(1, pole[0].length() - 1);                   // index - odstranenie {}
            term = (String) terms.get(Integer.parseInt(index));                          // priradenie termu podla indexu
            znak = pole[1];
            value = pole[2];

            System.out.println(pd + term + " " + znak + " " + value);           // vypis uzlov: term > vaha
            vypis += (level + " " + term + " " + znak + value + " <br/>\n");           // vypis uzlov: term > vaha
            //output.write(vypis);
            fw.append(vypis);

            printNode(node.getLeftChild());
            printNode(node.getRightChild());
        } else {
            pom = node.getPredicate().toString();
            pole = pom.replace("(", " (").split(" ");                           // uprava + rozdelenie podla medzier

            System.out.println(pd + pole[0] + " " + pole[1]);                         // vypis listových uzlov: True/False + hodnota
            vypis += (level + " " + pole[0] + " " + pole[1] + " <br/>\n");                         // vypis listových uzlov: True/False + hodnota
            //output.write(vypis);
            fw.append(vypis);

        }

        fw.close();
        return vypis;
    }

    public String printCategories() throws IOException, ClassNotFoundException {
        String names = "";
        IndexedSet<String> categories = (IndexedSet<String>) Utils.readObject("d:/diplomovka/upload/train_small_xml/category-dictionary");

        for (int i = 0; i < 16; i++) {
            names += "<input type='radio' id='cat" + i + "' name='category' value='" + i + "' checked='' />"
                    + "<label for='cat" + i + "' title='" + i + "'><span></span>" + (String) categories.get(i) + "</label>";
        }
        return names;
    }

    public int range() throws IOException, ClassNotFoundException {
        IndexedSet<String> categories = (IndexedSet<String>) Utils.readObject("d:/diplomovka/upload/train_small_xml/category-dictionary");
        maxrange = categories.size();
        return maxrange;
    }
};
