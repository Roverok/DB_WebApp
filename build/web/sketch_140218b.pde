XML xml, xml2; //<>//
ArrayList<Map> mapa;  //v tomto zozname su informacie o jednotlivych mapach
ArrayList<Neuron> neur;  //v tomto su uz info o konkretnych neuronoch na danej mape
ArrayList<Integer> nodesInLevelList;    //v zozname je ulozeny pocet map v kazdej urovni
ArrayList<Integer> mfx;  //vzdialenost uzla na osi x od mysi
ArrayList<Integer> mfy;  //vzdialenost uzla na osi y od mysi
PFont f;  // vytvorenie fontu
int diameter = 40;  //priemer kruhu reprezentujuceho mapu
int menuRight = 70; //menu panel vpravo
int menuLeft = 330; //menu vlavo, kde sa vypisu info o clastri
int numberOfMaps = 0;  //pocet vsetkych map, naplni sa podla map
int ml = 0;  //maximalny level, teda hlbka
int showLevel = 0;  //premena nesie v sebe udaj, kolko urovni mapy sa zobrazuje, potom sa prestavi na realnu hodnotu, nikdy nie je vacsia ako maxlevel
int zoom = 1; //zoom
int zoomLevel = 0;
int z = 0;
//mapa, ktora sa hybe; ...; ...; mapa, ktora bola kliknuta; clickedNeuronI je mapa, na ktoru sa prejde, ci hore ci dole
int clickedMapL, clickedX, clickedY, clickedMapR, clickedNeuronI;
//vlajky o pohybe jedneho alebo celho; ci zavriet konkretnu mapu
boolean movingOne = false;  
boolean movingAll = false;
boolean closeDirectMap, openDirectMap = false;
boolean clickedNeuron = false;  // klik na neuron na directmap
int cc; //kolko je stlpcov pri direct map

void setup() {
  size(1200, 550);  //velkost platna
  f = createFont("Arial", 16, true);    //vytvorenie fontu
  mapa = new ArrayList<Map>(); //zoznam map
  neur = new ArrayList<Neuron>();   //zoznam neuronov
  nodesInLevelList = new ArrayList<Integer>();  
  mfx = new ArrayList<Integer>();   //zoznamy pre pohyb
  mfy = new ArrayList<Integer>();

//nacitanie obrazkov
  reload = loadImage("reload.png");
  zoomin = loadImage("zoom-in.png");
  zoomout = loadImage("zoom-out.png");
  lvlMinus = loadImage("lvl-minus.png");
  lvlPlus = loadImage("lvl-plus.png");
  colnode = loadImage("colnode.png");
  expnode = loadImage("tree-view.png");
  fillMaps();   //naplnenie map
  showLevel = maxLevel();   //zobrazuju sa vsetky levely
  nodesInLevel();  //zistenie poctu map v levely
  ellipsePositions();  //sluzi na prvotne vykreslenie modelu, je v setup() aby sa zavolala len raz; je hned prekreslena v draw, ale aspon ulozi pozicie map
  rect(0, 0, menuLeft, height); //obdlznik, ktory bude prekresleny info panelom, musi sa najprv nakreslit, inak bude prazdna oblast na platne, kym sa na nieco neklikne
}

void draw() {  
  background(#e9e9e9); //background musi byt nastaveny, aby prekreslil cele platno a neostavali tam objekty z predchadzajuceho cyklu

  for (int i = 0; i < mapa.size(); i++) {
    moveEllipse(i);  //pohyb celej mapy
    moveOneNode(i);  //pohyb jendej mapy
    connectInt(i);  //pospaja mapy
    displayMap(i);  //zobrazi celu mapu
  }

  highLight();
  //zobrazi konkretnu mapu a neurony na nej
  //je to ten isty for ako tento vyssie, ale je to osobitne, aby directMap bol vzdy navrchu, inac by celkova mapa prekreslovala tuto
  for (int j = 0; j < mapa.size(); j++) {    
    displayDirectMap(j);
  }  
  leftMenu();
  rightMenu();
  mover();
}

void rightMenu() {  //menu vpravo
  imageMode(CENTER);
  rectMode(CORNER);
  textAlign(CENTER, CENTER);
  fill(#cccccc);
  noStroke();
  rect(width - menuRight, 0, width, height);    //velkost menu
  for (int i=1; i<8; i++) {
    sepLine(i * menuRight); //kresli ciaru medzi buttonmu
  }
  fill(#333333);
  tint(#333333);
  int divader = height/8;
  image(reload, width - menuRight + menuRight/2, divader / 2);  //obrazky buttonov a ich pozicie
  image(zoomin, width - menuRight + menuRight/2, divader *  3 / 2);
  image(zoomout, width - menuRight + menuRight/2, divader * 5 / 2);
  image(lvlMinus, width - menuRight + menuRight/2, divader * 7 / 2);
  image(lvlPlus, width - menuRight + menuRight/2, divader * 9 / 2);
  image(colnode, width - menuRight + menuRight/2, divader * 11 / 2);
  image(expnode, width - menuRight + menuRight/2, divader * 13 / 2);
  textAlign(CENTER);
  text("Zoom: " + zoom*z, width - menuRight + menuRight/2, divader * 15 / 2);

  if (mouseX > width - menuRight) {
    // pohyblivy trojuholnik - podľa pozície myši
    noStroke();
    fill(#e9e9e9);
    triangle(width - menuRight, mouseY - 10, width - menuRight, mouseY + 10, width - 60, mouseY);
  }
  else {
    // ak myš neukazuje na panel - panel je zosvetlený
    noStroke();
    fill(255, 255, 255, 100);
    rect(width - menuRight, 0, width, height);
  }
}

void sepLine(int y) {   //linia medzi obrazkami praveho menu
  pushMatrix();
  stroke(#bbbbbb);
  strokeWeight(1);
  line(width - menuRight + 2, y, width - 2, y);
  stroke(#dddddd);
  line(width - menuRight + 2, y + 1, width - 2, y + 1);
  popMatrix();
}

void leftMenu() {   //lave menu
  strokeWeight(1);
  fill(#e9e9e9);
  stroke(#000000);
  rect(0, 0, menuLeft, height-1);   //do tohto obdlznika sa vypisuju info
  noFill();
  int i;
  if (openDirectMap) {  //info len o mape
    if (clickedNeuron == true) {
      i = clickedNeuronI;
    }
    else {
      i = clickedMapR;
    }

    fill(100, 100, 100);
    textAlign(LEFT);
    textSize(12);
    text("Level: " + mapa.get(i).getLevel(), 10, 20);
    text("Map: " + mapa.get(i).getId(), 10, 40);    
    text("Leaf: " + mapa.get(i).getLeaf(), 10, 60);
    text("# of children: " + mapa.get(i).getNumberOfChildren(), 10, 80);
    text("Default MQE: " + mapa.get(i).getDmqe(), 10, 100);

    //zistenie ID parenta, vypise sa az neskor
    String currentsParent = mapa.get(i).getParent();
    int parentsID = 0;
    for (int j = 0; j < mapa.size(); j++) {
      if (currentsParent == mapa.get(j).getCurrent()) {
        parentsID = j;
      }
    }
    //kolko je expandovatelnych
    int a, b = 0;
    for (int c = 0; c < mapa.get(i).getNumberOfChildren(); c++) {
      if (mapa.get(i).getChildren()[c] == "null") {
        a++;
      }
      else { 
        b++;
      }
    }
//vypisy o mape
    text("Expandable clusers: " + b, 10, 120);
    text("Not expandable clusers: " + a, 10, 140);
    text("Rows: " + mapa.get(i).getRows(), 10, 160);
    text("Columns: " + mapa.get(i).getColumns(), 10, 180);
    text("Total number of vectors in this node: " + mapa.get(i).getTnv(), 10, 200);
    text("Total number of instances in this node: " + mapa.get(i).getTni(), 10, 220);
    //cast o parentovi
    fill(000, 200, 255, 90);
    rect(0, height - 165, menuLeft, height);
    fill(#000000);
    textAlign(CORNER);
    textSize(12);
    if (currentsParent == "null") {
      text("Neuron is on top of Map, has no parent.", 10, height - 150);
    }   
    else {
      //zistenie, ktory neuron je dana mapa
      int neuron = 0;
      for (int children = 0; children < mapa.get(parentsID).getNumberOfChildren(); children++) {
        if (mapa.get(parentsID).getChildren()[children] == mapa.get(i).getCurrent()) {
          neuron = children;
        }
      }
      text("Parent Neuron:", 10, height - 150);
      text("Parent's map id: " + parentsID, 10, height - 135);
      text("Cluster: " + neuron, 10, height - 120);
      text("Cluster's MQE: ", 10, height - 105);
      text(mapa.get(parentsID).getClustersMqe()[neuron], 10, height - 90);
      text("Vectors: " + mapa.get(parentsID).getVectorsPerCluster()[neuron], 10, height - 75);
      String d = mapa.get(parentsID).getKlastre()[neuron].getContent();
      if (d != null) {
        String[] dd = split(d, ", ");
        text(dd[0], 10, height - 45);
        text(dd[1], 10, height - 30);  
        text(dd[2], 10, height - 15);
        text(dd[3], 80, height - 45);
        text(dd[4], 80, height - 30);  
        text(dd[5], 80, height - 15);
      }
    }
  }
}

//Zvyrazni na hlavnej mape (ta v pozadi) ktora mapa je otvorena, vytvori cestu z nej po zaciatocny
void highLight() {
  int i;
  if (openDirectMap) {  //info len o mape
    if (clickedNeuron) {
      i = clickedNeuronI;
    }
    else {
      i = clickedMapR;
    }
    fill(#FF030B);
//kruh ktory sa nakresli v mape na zvyraznenie
    ellipse(mapa.get(i).getX(), mapa.get(i).getY(), diameter*0.7, diameter*0.7);

    //vykreslenie cesty z aktualnej mapy do prvej mapy
    String currentsParent = mapa.get(i).getParent();
    int b = i;
    if (mapa.get(i).getLevel() == 0) {
      //nekresli sa
    }
    else {
      for (int a = 0; a < mapa.get(i).getLevel(); a++) {        
        int parentsID;
        for (int j = 0; j < mapa.size(); j++) {
          if (currentsParent == mapa.get(j).getCurrent()) {
            parentsID = j;
          }
        }
        //suradnice rodicovskej mapy
        int parentX = mapa.get(parentsID).getX();
        int parentY = mapa.get(parentsID).getY();

        stroke(#C6182C);
        strokeWeight(3);
        //spajacia ciara map, od kliknutej po najvyssiu
        line(mapa.get(b).getX(), mapa.get(b).getY(), parentX, parentY);
        b = parentsID;
        currentsParent = mapa.get(b).getParent();
      }
    }
  }
}

void displayMap(int i) {    //vykresli celu mapu, ale len po povoleny level (show level)
  textFont(f, 16);
  stroke(000, 200, 255);
  strokeWeight(1);
  if (showLevel >= mapa.get(i).getLevel()) {
    fill(000, 200, 255, 90);
    ellipse(mapa.get(i).getX(), mapa.get(i).getY(), diameter, diameter);
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textFont(f, 10);
    text(mapa.get(i).getId(), mapa.get(i).getX(), mapa.get(i).getY() + diameter);   //vypise id mapy na platne, pod kazdou mapou
  }
}

void moveOneNode(int i) {   //pohyb jednej mapy
  if (clickedMapL == i && mousePressed && movingOne==true && movingAll==false) {
    mapa.get(i).setX(mouseX - clickedX);
    mapa.get(i).setY(mouseY - clickedY);
  }
}

void displayDirectMap(int i) {  //zobrazenie konkretnej mapy na platne, ak sa na nejaku klikne pravym tlacidlom mysi
  if ((clickedMapR == i && openDirectMap==true)) {
    if (clickedNeuron == true) {
      i = clickedNeuronI;
    }
    leftMenu();
    neur.clear();  
    //max rows=5, max columns = 4
    int rows = mapa.get(i).getRows();
    int columns = mapa.get(i).getColumns();
    int xrect = menuLeft+50;  //x suradnica, kde je lavy horny roh
    int yrect = 50;           //y suradnica
    int hrect = 150;          //sirka
    int wrect = 100;          //vyska 
    int widthOfMap = (wrect + xrect) - xrect;
    int heightOfMap = (hrect + yrect) - yrect;
    boolean falseMap;
    fill(240, 240, 240);   
    int a = 0;

    //pokial ich je viac, vykresli ich mimo obrazovku
    if (rows < 6 && columns < 5) {
      for (int b = 0; b < columns; b++) {
        for (int c = 0; c < rows; c++) {
          boolean d;
          if (mapa.get(i).getChildren()[a] == "null") {
            fill(#BCFFD6);
            d = false;
          }         
          else {
            fill(#FFBCBC);
            d = true;
          }

          rect(xrect + hrect * b, yrect + wrect * c, hrect, wrect);
          neur.add(new Neuron(a, xrect + hrect * b, yrect + wrect * c));
          fill(#000000);
          textAlign(CORNER);
          textSize(10);
          text("Cluster: " + neur.get(a).getId(), xrect + hrect * b + 10, yrect + wrect * c + 10);
          text("Cluster's MQE: ", xrect + hrect * b + 10, yrect + wrect * c + 20);
          text(mapa.get(i).getClustersMqe()[a], xrect + hrect * b + 10, yrect + wrect * c + 30);  //zrezat string na kratsi, uz asi pri robeni substringu
          text("Vectors: " + mapa.get(i).getVectorsPerCluster()[a], xrect + hrect * b + 10, yrect + wrect * c + 40);
          text("Expandable: " + d, xrect + hrect * b + 10, yrect + wrect * c + 50);
          String s = mapa.get(i).getKlastre()[a].getContent();
          if (s != null) {
            String[] ss = split(s, ", ");
            text(ss[0], xrect + hrect * b + 10, yrect + wrect * c + 70);
            text(ss[1], xrect + hrect * b + 10, yrect + wrect * c + 80);
            text(ss[2], xrect + hrect * b + 10, yrect + wrect * c + 90);
            text(ss[3], xrect + hrect * b + 80, yrect + wrect * c + 70);
            text(ss[4], xrect + hrect * b + 80, yrect + wrect * c + 80);
            text(ss[5], xrect + hrect * b + 80, yrect + wrect * c + 90);
          }    
          a++;
        }
      }
    }
    else if ((rows > 5 || columns > 4) && (rows*columns <= 25)) {
      //v tomto pripade ich bude ukladat zaradom zprava do lava, po 4 do riadku, max 5 riadkov
      falseMap = true;
      columns = 0;
      int e = 0;
      for (int b = 0; b < 5; b++) {
        if (e != mapa.get(i).getNumberOfChildren()) {
          columns++;
        }
        for (int c = 0; c < 5; c++) {
          if (e != mapa.get(i).getNumberOfChildren()) {

            boolean d;
            if (mapa.get(i).getChildren()[a] == "null") {
              fill(#BCFFD6);
              d = false;
            }         
            else {
              fill(#FFBCBC);
              d = true;
            }
            rect(xrect + hrect * b, yrect + wrect * c, hrect, wrect);
            neur.add(new Neuron(a, xrect + hrect * b, yrect + wrect * c));
            fill(#000000);
            textAlign(CORNER);
            textSize(10);
            text("Cluster: " + neur.get(a).getId(), xrect + hrect * b + 10, yrect + wrect * c + 10);
            text("Cluster's MQE: ", xrect + hrect * b + 10, yrect + wrect * c + 20);
            text(mapa.get(i).getClustersMqe()[a], xrect + hrect * b + 10, yrect + wrect * c + 30);  //zrezat string na kratsi, uz asi pri robeni substringu
            text("Vectors: " + mapa.get(i).getVectorsPerCluster()[a], xrect + hrect * b + 10, yrect + wrect * c + 40);
            text("Expandable: " + d, xrect + hrect * b + 10, yrect + wrect * c + 50);
            String s = mapa.get(i).getKlastre()[a].getContent();
            if (s != null) {
              String[] ss = split(s, ", ");
              text(ss[0], xrect + hrect * b + 10, yrect + wrect * c + 70);
              text(ss[1], xrect + hrect * b + 10, yrect + wrect * c + 80);
              text(ss[2], xrect + hrect * b + 10, yrect + wrect * c + 90);
              text(ss[3], xrect + hrect * b + 80, yrect + wrect * c + 70);
              text(ss[4], xrect + hrect * b + 80, yrect + wrect * c + 80);
              text(ss[5], xrect + hrect * b + 80, yrect + wrect * c + 90);
            }
            e++;
          }
          a++;
        }
      }
    }
    else {
      //nestalo sa mi, aby bola mapa vacsia
      println("Map too big");
//      background(#000000);
//      resetCanvas();
//      break;
    }
  }
  fill(#0845C4);
  rectMode(CORNER);
  rect(xrect, 25, columns * 150, 25, 12, 12, 0, 0);
  fill(#FF0000);
  ellipse(xrect + 14, yrect - 12, 19, 19);  //tlacitko exit/close
  fill(0);
  ellipse(xrect + 14, yrect - 12, 9, 9);  
  //zeleny button vpravo (byvaly show parent node) teraz naznacuje, ze prvky neboli vykreslene podla ich pozicie na mape, ale zaradom
  if (falseMap == true) {
    fill(#09C100);
    ellipse(xrect - 14 + (columns * 150), yrect - 12, 19, 19);
  }
  cc = columns;
}


void mouseReleased() {  //co sa ma stat, ak boli pustene tlacidla mysi, po klinuti
  movingOne = false;
  movingAll = false;
  if (openDirectMap == false) {
    clickedNeuron = false;
    loop();
  }
  if (closeDirectMap==true) {
    clickedNeuron = false;
    loop();
    closeDirectMap=false;
  }
}

void increaseLevel() {  //zvysi pocet zobrazovanych urovni
  if (showLevel != maxLevel()) {
    showLevel = showLevel + 1;
  }
}

void decreaseLevel() {  //znizi pocet zobrazovanych urovni
  if (showLevel != 0) {
    showLevel = showLevel - 1;
  }
}

void lowerDiameter() {  //znizi polomer kruhov na mape, vhodne na prehladnost
  diameter  = diameter * 0.9;
}

void enlargeDiameter() {    //resetuje celu mapu, ale ponecha pocet zobrazenych urovni, polomery kruhov, vola sa tak, lebo mala inu funkciu
  int levels = (1 + +maxLevel());
  int[] nil = new int[nodesInLevelList.size()];  
  for (int i = 0; i < nodesInLevelList.size(); i++) {
    nil[i] = nodesInLevelList.get(i);
  } 
  int i = 1;
  int z = 0;
  while (i <= levels) {
    for (int o = 0; o < nil[i - 1]; o++) {
      //ulozenie novych koordinatov
      mapa.get(z).setX(menuLeft + (((width - menuLeft - menuRight) / (nil[i - 1] + 1)) * (o + 1)));
      mapa.get(z).setY((height / (levels + 1)) * i);
      z++;
    }
    i++;
  }
}

void mousePressed() {

  //prvy usek, ak sa kliko v pravom menu
  if ((width - menuRight) < mouseX && mouseX < width) {
    int divader = height/8 + 1;
    if (0 < mouseY && mouseY < divader) {
      resetCanvas();
    } 
    //zoom in  
    if (divader < mouseY && mouseY < divader * 2) {
      zoomIn();
    }
    //zoom out
    if (divader * 2 < mouseY && mouseY < divader * 3) {
      zoomOut();
    }
    //znizuje pocet zobrazenych urovni mapy
    if (divader * 3 < mouseY && mouseY < divader * 4) {
      decreaseLevel();
    }
    //zvysuje pocet zobrazenych urovni
    if (divader * 4 < mouseY && mouseY < divader * 5) {
      increaseLevel();
    }
    //znizuje polomer obrazku mapy
    if (divader * 5 < mouseY && mouseY < divader * 6) {
      lowerDiameter();
    }
    //zvysuje polomer obrazku mapy
    if (divader * 6 < mouseY && mouseY < divader * 7) {
      enlargeDiameter();
    }
  }  

  //zistenie, na ktory neuron sa kliklo
  if (openDirectMap == true) {
    if (clickedNeuron == true) {
      clickedMapR = clickedNeuronI;
    }
    for (int ab = 0; ab < mapa.get(clickedMapR).getNumberOfChildren(); ab++) {
      //150 reprezentuje sirku strany vykresleneho obdlznika, 100 je vyska strany obdlznika
      if (neur.get(ab).getX() < mouseX && mouseX < neur.get(ab).getX() + 150 && neur.get(ab).getY() < mouseY && mouseY < neur.get(ab).getY() + 100) {

        //stlacene lave tlacitko mysi, teda sa ide o uroven nizsie (na direct map)
        if (mouseButton == LEFT) {
          if (mapa.get(clickedMapR).getChildren()[ab] != "null") {
            //hlada sa od danej mapy vyssie
            int currentsId = mapa.get(clickedMapR).getId();
            for (currentsId; currentsId < mapa.size(); currentsId++) {
              if (mapa.get(clickedMapR).getChildren()[ab] == mapa.get(currentsId).getCurrent()) {                
                clickedNeuronI = mapa.get(currentsId).getId();
                //zavrie sa aktualna mapa prestavenim parametrov
                closeDirectMap = true;
                openDirectMap = false;
                clickedNeuron = false;
                //otvorenie novej mapy prestavenim parametrov spat, na otvorenu mapu
                closeDirectMap = false;
                openDirectMap = true;
                clickedNeuron = true;
                displayMap(clickedNeuronI);
                displayDirectMap(clickedNeuronI);
              }
            }
          }
        }
        //stlacenie praveho tlacitka, ide o uroven vyssie (na direct map)
        else {
          String currentsParent = mapa.get(clickedMapR).getParent();
          int parentsID = 0;
          for (int j = 0; j < mapa.size(); j++) {
            if (currentsParent == mapa.get(j).getCurrent()) {
              parentsID = j;
            }
          }
          clickedNeuronI = parentsID;
          //zavrie sa aktualna mapa prestavenim parametrov
          closeDirectMap = true;
          openDirectMap = false;
          clickedNeuron = false;
          //otvorenie novej mapy prestavenim parametrov spat, na otvorenu mapu
          closeDirectMap = false;
          openDirectMap = true;
          clickedNeuron = true;
          displayMap(clickedNeuronI);
          displayDirectMap(clickedNeuronI);
        }
      }
    }
  }

  //na zatvorenie directmap
  if ((sq(menuLeft+64 - mouseX) + sq(38 - mouseY) < sq(10)) && openDirectMap==true) {  
    closeDirectMap = true;
    openDirectMap = false;
    clickedNeuron = false;
  }

  //kliknutie na zeleny button, uz nema funkciu
  if ((sq((menuLeft + 35 + (cc * 150)) - mouseX) + sq(38 - mouseY) < sq(10)) && openDirectMap==true) {  
    //BODY
  }

  for (int i = 0; i < mapa.size(); i++) {  //zisti vzdialensoti mysi od uzlov
    mfx.add(i, mouseX - mapa.get(i).getX());
    mfy.add(i, mouseY - mapa.get(i).getY());

    if (sq(mapa.get(i).getX() - mouseX) + sq(mapa.get(i).getY() - mouseY) < sq(diameter/2)) {  //na zistenie, ci sa mys nachadza nad uzlom
      if (mousePressed && (mouseButton == LEFT)) {  //stlacenie laveho tlacitka mysi
        clickedMapL = i;
        clickedX = mouseX - mapa.get(i).getX();
        clickedY = mouseY - mapa.get(i).getY();
        movingOne = true;
        movingAll = false;
        break;
      }
      if (mousePressed && (mouseButton == RIGHT)) {  //a stalcenie praveho
        clickedMapR = i;
        movingOne = false;
        movingAll = false;
        openDirectMap = true;
        break;
      }
    }
    movingAll = true;
  }
}

void zoomIn() { //zoomin, meni aj suradnice mape, aby to vyzeralo, ze sa prizoomovalo na dane miesto
  if (zoomLevel < 10) {
    z = 1.25;
    diameter = diameter*z;
    for (int i = 0; i < mapa.size(); i++) {
      pomx = mapa.get(i).getX()/2 - mapa.get(i).getX()*z/2;
      pomy = mapa.get(i).getY()/2 - mapa.get(i).getY()*z/2;
      mapa.get(i).setX(mapa.get(i).getX() * z + pomx - menuRight);
      mapa.get(i).setY(mapa.get(i).getY() * z + pomy);
    }
    zoomLevel = zoomLevel + 1;
  }
}

void zoomOut() {    //opak zoomout
  if (zoomLevel > -10) {
    z = 0.8;
    diameter = diameter*z;  
    for (int i = 0; i < mapa.size(); i++) {
      pomx = mapa.get(i).getX()/2 - mapa.get(i).getX()*z/2;
      pomy = mapa.get(i).getY()/2 - mapa.get(i).getY()*z/2;
      mapa.get(i).setX(mapa.get(i).getX() * z + pomx + menuRight);
      mapa.get(i).setY(mapa.get(i).getY() * z + pomy);
    }
    zoomLevel = zoomLevel - 1;
  }
}

void resetCanvas() {    //zresetuje celu mapu a vsetky parametre, vyzera to ako ked uzivatel prvykrat spustil vizualizaciu
  mapa.clear();
  diameter = 40;
  neur.clear();
  fillMaps();
  ellipsePositions();
  background(#e9e9e9);
  //Nasledujuce vykreslenie map tu je len kvoli rychlosti, ak by tu nebolo vykreslenie trva troska dlhsie
  for (int i = 0; i < mapa.size(); i++) {
    displayMap(i);
  }
}

void moveEllipse(int i) {   //funkcia na pohyb celej mapy
  if (mousePressed && movingAll==true && movingOne==false) {
    pushMatrix();
    mapa.get(i).setX(mouseX - mfx.get(i));
    mapa.get(i).setY(mouseY - mfy.get(i));
    popMatrix();
  }
}

void connectInt(int i) {    //spaja mapy
  stroke(#000000);
  if (i != 0) {	//neriesi pre i=0, co je prva mapa
    if (showLevel >= mapa.get(i).getLevel()) {
      pushMatrix();
      int currentID = mapa.get(i).getId();
      int currentX = mapa.get(i).getX();
      int currentY = mapa.get(i).getY();

      //zistenie ID parenta
      String currentsParent = mapa.get(i).getParent();   
      int parentsID = 0;
      for (int j = 0; j < mapa.size(); j++) {
        if (currentsParent == mapa.get(j).getCurrent()) {
          parentsID = j;
        }
      }
      int parentX = mapa.get(parentsID).getX();
      int parentY = mapa.get(parentsID).getY();

      //Spajanie jednotlivych map ciarami
      fill(0);
      line(currentX, currentY, parentX, parentY);
      popMatrix();
    }
  }
}

public void ellipsePositions() {    //pozicie map na platne pri prvom vykresleni, zachovava pravidelen rozlozenie, medzi oba panely
  int levels = (1 + +maxLevel());
  int[] nil = new int[nodesInLevelList.size()];  
  for (int i = 0; i < nodesInLevelList.size(); i++) {
    nil[i] = nodesInLevelList.get(i);
  } 
  int i = 1;
  int z = 0;
  while (i <= levels) {
    for (int j = 0; j < nil[i - 1]; j++) {
      fill(000, 200, 255);
      ellipseMode(CENTER);
      ellipse(menuLeft + (((width - menuLeft - menuRight) / (nil[i - 1] + 1)) * (j + 1)), (height / (levels + 1)) * i, diameter, diameter);
    }
    for (int o = 0; o < nil[i - 1]; o++) {
      //ulozenie koordinatov jednotlivych kruhov
      mapa.get(z).setX(menuLeft + (((width - menuLeft - menuRight) / (nil[i - 1] + 1)) * (o + 1)));
      mapa.get(z).setY((height / (levels + 1)) * i);
      z++;
    }
    i++;
  }
}

void nodesInLevel() {   //zistuje pocet map v kazdej urovni
  int pom = 0;
  for (int i = 0; i < 1 + +maxLevel(); i++) {
    pom = i;
    int pom2 = 0;
    for (int j = 0; j < mapa.size(); j++) {
      if (pom == mapa.get(j).getLevel()) {
        pom2++;
      }
    }
    nodesInLevelList.add(pom2);
  }
} 

int maxLevel() {    //zisti hlbku
  int ml = 0;
  for (int i = 0; i < mapa.size(); i++) {
    if (mapa.get(i).getLevel() > ml) {
      ml = mapa.get(i).getLevel();
    }
  }  
  return ml;
}

int numberOfAllMaps() { //zisti pocet map nacitanim xml suboru a spocitanim nodov
  xml2 = loadXML("GHSOMStats.xml");
  XML[] map = xml2.getChildren("NODE");
  numberOfMaps = map.length;
  return numberOfMaps;
}


void fillMaps() {  //metoda naplni mapy  
  xml = loadXML("GHSOMStats.xml");
  XML[] maps = xml.getChildren("NODE");

  for (int i =0; i < maps.length; i++) { 
    //najprv sa nacitaju udaje z xml, potom su pretransformovane na jednotlive premenne
    XML level = maps[i].getChild("LEVEL");
    XML currentN = maps[i].getChild("CURRENT_NODE");
    XML parentN = maps[i].getChild("PARENT"); 
    XML columnsN = maps[i].getChild("COLUMNS");
    XML rowsN = maps[i].getChild("ROWS");
    XML childrenN = maps[i].getChild("CHILDREN");
    XML numOfChildrenN = maps[i].getChild("NUM_OF_CHILDREN");
    XML dmqN = maps[i].getChild("DEFAULT_MQE");
    XML leafN = maps[i].getChild("LEAF");
    XML clustersN = maps[i].getChild("CLUSTERS");   
    XML[] klastre = clustersN.getChildren("CLUSTER");
    XML clustersMqe = maps[i].getChild("CLUSTERS_MQE");
    XML vectorCountPC = maps[i].getChild("VECTOR_CNT_PC");
    XML tnv = maps[i].getChild("TNV");
    XML tni = maps[i].getChild("TNI");


    //tieto treba menit kvoli java modu...
    /* 
     int levelX = Integer.parseInt(level.getContent());
     int columnsX = Integer.parseInt(columnsN.getContent());
     int rowsX = Integer.parseInt(rowsN.getContent());
     int numOfChildrenX = Integer.parseInt(numOfChildrenN.getContent());
     boolean leafX = Boolean.parseBoolean(leafN.getContent());
     float dmqX = Float.parseFloat(dmqN.getContent());
     */
    int levelX = level.getContent();
    int columnsX = columnsN.getContent();
    int rowsX = rowsN.getContent();
    int numOfChildrenX = numOfChildrenN.getContent();
    boolean leafX = leafN.getContent();
    float dmqX = dmqN.getContent();

    //potial menit

    //transformacia udajov z xml na konkretne premenne
    int idX = maps[i].getInt("id");
    int tnvX = tnv.getContent();
    int tniX = tni.getContent();
    String currentX = currentN.getContent();
    String parentX = parentN.getContent();
    String childrenX = childrenN.getContent();
    String splitT = childrenX.substring(1, childrenX.length()-1);
    String[] splitS = split(splitT, ", ");
    String clustersMqeX = clustersMqe.getContent();
    String[] splitClustersMqe = split(clustersMqeX, ", ");
    String vectorCountPCX = vectorCountPC.getContent();
    String[] splitVectorCountPC = split(vectorCountPCX, ", ");

    //Prvotne suradnice x a y su 0, pre kazdu mapu
    mapa.add(new Map(levelX, 0, 0, idX, currentX, parentX, columnsX, rowsX, splitS, numOfChildrenX, klastre, dmqX, leafX, splitClustersMqe, splitVectorCountPC, tnvX, tniX));
  }
}



void mover() {  //kurzor mysi
  pushMatrix();
  fill(255);
  noCursor();
  translate(mouseX, mouseY);
  if (movingOne == true || movingAll == true) {
    if (mouseX < width - menuRight) {
      cursor_move();
    }
  }
  else { 
    if (mouseX > 0) {
      cursor_arrow();
    }
  }
  popMatrix();
}

void cursor_arrow() {
  pushMatrix();
  noStroke();
  fill(#333333);
  if (mouseX > width - menuRight) {
    fill(255, 100, 100);
  }
  beginShape();
  vertex(0, 0);
  vertex(0, 18);
  vertex(5, 12);
  vertex(12, 12);
  endShape(CLOSE);
  popMatrix();
}

void cursor_move() {
  pushMatrix();
  noStroke();
  fill(#333333);
  for (int i=1; i<5; i++) {
    triangle(5, -3, 5, 3, 8, 0);
    rotate(i*PI/2);
  }
  ellipse(0, 0, 4, 4);
  popMatrix();
}

//potial kurzor

class Neuron {  //trieda neuronu (neuron je cely jedne obdlznik, ktory je vykresleny)
  int id;
  int x, y;  //koordinaty, kde zacina kazda "sub-mapa", kvoli ohraniceniu pre mousePressesd()

  Neuron(int aid, int ax, int ay) {
    id = aid;
    x = ax;
    y = ay;
  }
  int getX() { 
    return x;
  }
  int getY() { 
    return y;
  }
  int getId() {
    return id;
  }
}

class Map { //trieda mapy, obsahuje vsetky udaje z xml suboru v elemente <NODE>
  int level;
  int x, y;  //suradnice mapy
  int id;    //id konkretnej mapy
  int columns, rows;  //pocet stlpcov a riadkov jednej mapy
  String current;  //nazov aktualneho nodu
  String parent;  //nazov parenta
  String[] children;  //pole deti
  int numberOfChildren;  //pocet neuronov na mape, takis rows*columns
  XML[] klastre;    //termy v neurone
  float DMQE;
  boolean leaf;
  String[] clustersMqe;
  String[] vectorsPerCluster;
  int tnv, tni;

  Map(int alevel, int ax, int ay, int aid, String acurrent, String aparent, int acolumns, int arows, 
  String[] achildren, int anumberOfChildren, XML[] aklastre, float aDMQE, boolean aleaf, String[] aclustersMqe, 
  String[] avectorsPerCluster, int atnv, int atni) {  //konstruktor
    level = alevel;
    x = ax;
    y = ay;
    id = aid;
    current = acurrent;
    parent = aparent;
    columns = acolumns;
    rows = arows;
    children = achildren;
    numberOfChildren = anumberOfChildren;
    leaf = aleaf;
    klastre = aklastre;
    DMQE = aDMQE;
    clustersMqe = aclustersMqe;
    vectorsPerCluster = avectorsPerCluster;
    tnv = atnv;
    tni = atni;
  }

    //settre a gettre
  int getTnv() {
    return tnv;
  }
  int getTni() {
    return tni;
  }
  String[] getClustersMqe() {
    return clustersMqe;
  }
  String[] getVectorsPerCluster() {
    return vectorsPerCluster;
  }
  boolean getLeaf() {
    return leaf;
  }
  float getDmqe() {
    return DMQE;
  }
  int getNumberOfChildren() {
    return numberOfChildren;
  }
  XML[] getKlastre() {
    return klastre;
  }
  String[] getChildren() {
    return children;
  }
  void setX(int x) {
    this.x = x;
  }
  void setY(int y) {
    this.y = y;
  }
  int getLevel() {
    return level;
  }
  int getId() {
    return id;
  }
  String getParent() {
    return parent;
  }
  String getCurrent() {
    return current;
  }
  int getX() {
    return x;
  }
  int getY() {
    return y;
  }
  int getRows() {
    return rows;
  }
  int getColumns() {
    return columns;
  }
}