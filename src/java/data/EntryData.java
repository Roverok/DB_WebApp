
package data;

//import org.ajbowl.util.math.Similarity;


public class EntryData {
    
    //--------------------------------------------------------------------------
    // Tieto premenne a ich gettre a settre patria ku GHSOM-u
//    Similarity similarity;    
    Integer hlbkaGHSOM;
    Integer minNumberOfInstances;
    Integer startingRows;
    Integer startingColumns;    
    Integer expandCycles;
    Integer initNeighbourhood;
    double tau2;
    double tau1;
    double initLearnRate;
    
//    public void setSimilarity(Similarity similarity) {this.similarity = similarity;}
//    public Similarity getSimilarity() {return similarity;}
    public void setExpandCycles(Integer expandCycles) {this.expandCycles = expandCycles;}
    public void setInitNeighbourhood(Integer initNeighbourhood) {this.initNeighbourhood = initNeighbourhood;}
    public void setTau1(double tau1) {this.tau1 = tau1;}
    public void setInitLearnRate(double initLearnRate) {this.initLearnRate = initLearnRate;}
    public Integer getExpandCycles() {return expandCycles;}
    public Integer getInitNeighbourhood() {return initNeighbourhood;}
    public double getTau1() {return tau1;}
    public double getInitLearnRate() {return initLearnRate;}
    public void setStartingRows(Integer startingRows) {this.startingRows = startingRows;}
    public void setStartingColumns(Integer startingColumns) {this.startingColumns = startingColumns;}
    public Integer getStartingRows() {return startingRows;}
    public Integer getStartingColumns() {return startingColumns;}
    public void setTau2(double tau2) {this.tau2 = tau2;}
    public double getTau2() {return tau2;}
    public void setMinNumberOfInstances(Integer MinNumberOfInstances) {this.minNumberOfInstances = MinNumberOfInstances;}
    public Integer getMinNumberOfInstances() {return minNumberOfInstances;}
    public void setHlbkaGHSOM (Integer value){hlbkaGHSOM = value;}    
    public Integer getHlbkaGHSOM() { return hlbkaGHSOM; } 
    //potial premenne a gettre a settre ku GHSOM
    //--------------------------------------------------------------------------    
    
    String tokenizer;
    String tokenizer2;
    String tokenizer3;
    String tf;
    String idf;
    String norm;
    String tfidf = getTfidf();
    String file;
    Integer i;
    Integer hlbka;
    String metoda;
    boolean bin;
    String submit;
    String reset;
    boolean idTest;
    Integer indexCat;
    
   
    public void setTokenizer( String value ) {
        tokenizer = value;
    }
    public void setTokenizer2( String value ) {
        tokenizer2 = value;
    }
    public void setTokenizer3( String value ) {
        tokenizer3 = value;
    }
    public void setTf( String value ) {
        tf = value;
    }
    public void setIdf( String value ) {
        idf = value;
    }
    public void setNorm( String value ) {
        norm = value;
    }
    public void setFile( String value ) {
        file = value;
    }
    public void setI( Integer value ) {
        i = value;
    }
    public void setHlbka( Integer value ) {
        hlbka = value;
    }
    public void setMetoda( String value ) {
        metoda = value;
    }
    public void setBin( boolean value ) {
        bin = value;
    }
    public void setSubmit( String value ) {
        submit = value;
    }
    public void setReset( String value ) {
        reset = value;
    }
    public void setIdTest( boolean value ) {
        idTest = value;
    }
    public void setIndexCat( Integer value ) {
        indexCat = value;
    }


    public String getTokenizer() { return tokenizer; }
    public String getTokenizer2() { return tokenizer2; }
    public String getTokenizer3() { return tokenizer3; }
    public String getTf() { return tf; }
    public String getIdf() { return idf; }
    public String getNorm() { return norm; }
    public String getFile() { return file; }
    public Integer getI() { return i; }
    public Integer getHlbka() { return hlbka; }
    public String getMetoda() { return metoda; }
    public boolean getBin() { return bin; }
    public String getSubmit() { return submit; }
    public String getReset() { return reset; }
    public boolean getIdTest() { return idTest; }
    public Integer getIndexCat() { return indexCat; }
    
    public String getTfidf() { 
        if (tf == null) tf = "l";
        if (idf == null) idf = "t";
        if (norm == null) norm = "c";
        
        tfidf = tf+idf+norm;
        return tfidf;
    }
    
}
