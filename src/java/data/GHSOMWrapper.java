package data;

import org.ajbowl.data.Instances;
import org.ajbowl.util.HashIndexedSet;

/**
 * nesie potrebne udaje pre vytvorenie GHSOM modelu
 * @author Zdeno
 */
public class GHSOMWrapper {

    public String pathToFile;
    public String menoZlozka;
    public Instances instances;
    public HashIndexedSet dictionary;

    public void setPathToFile(String pathToFile) {
        this.pathToFile = pathToFile;
    }

    public void setMenoZlozka(String menoZlozka) {
        this.menoZlozka = menoZlozka;
    }

    public void setInstances(Instances instances) {
        this.instances = instances;
    }

    public void setDictionary(HashIndexedSet dictionary) {
        this.dictionary = dictionary;
    }

    public String getPathToFile() {
        return pathToFile;
    }

    public String getMenoZlozka() {
        return menoZlozka;
    }

    public Instances getInstances() {
        return instances;
    }

    public HashIndexedSet getDictionary() {
        return dictionary;
    }

    public void setFilePAth(String filePAth) {
        this.pathToFile = filePAth;
    }

    public void setZlozka(String zlozka) {
        this.menoZlozka = zlozka;
    }

    public String getFilePAth() {
        return pathToFile;
    }

    public String getZlozka() {
        return menoZlozka;
    }

    Integer hlbkaGHSOM;
    Integer minNumberOfInstances;
    Integer startingRows;
    Integer startingColumns;
    Integer expandCycles;
    Integer initNeighbourhood;
    double tau2;
    double tau1;
    double initLearnRate;
    String metoda;

    public String getMetoda() {
        return metoda;
    }

    public void setMetoda(String metoda) {
        this.metoda = metoda;
    }
    
    public void setExpandCycles(Integer expandCycles) {
        this.expandCycles = expandCycles;
    }

    public void setInitNeighbourhood(Integer initNeighbourhood) {
        this.initNeighbourhood = initNeighbourhood;
    }

    public void setTau1(double tau1) {
        this.tau1 = tau1;
    }

    public void setInitLearnRate(double initLearnRate) {
        this.initLearnRate = initLearnRate;
    }

    public Integer getExpandCycles() {
        return expandCycles;
    }

    public Integer getInitNeighbourhood() {
        return initNeighbourhood;
    }

    public double getTau1() {
        return tau1;
    }

    public double getInitLearnRate() {
        return initLearnRate;
    }

    public void setStartingRows(Integer startingRows) {
        this.startingRows = startingRows;
    }

    public void setStartingColumns(Integer startingColumns) {
        this.startingColumns = startingColumns;
    }

    public Integer getStartingRows() {
        return startingRows;
    }

    public Integer getStartingColumns() {
        return startingColumns;
    }

    public void setTau2(double tau2) {
        this.tau2 = tau2;
    }

    public double getTau2() {
        return tau2;
    }

    public void setMinNumberOfInstances(Integer MinNumberOfInstances) {
        this.minNumberOfInstances = MinNumberOfInstances;
    }

    public Integer getMinNumberOfInstances() {
        return minNumberOfInstances;
    }

    public void setHlbkaGHSOM(Integer value) {
        hlbkaGHSOM = value;
    }

    public Integer getHlbkaGHSOM() {
        return hlbkaGHSOM;
    }
}
