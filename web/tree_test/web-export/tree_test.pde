
Node[] nodes;                               // deklarácia Node[]
PFont f;                                    // definovanie triedy písma

String[] loadtree = new String[0];          // load file in .js
String[][] treeTable = new String[0][0];
String[] parse;

int lvls = 1;
int num = 1;
int nodeX, oldX;
int nodeY, oldY;
int lvl;
String name;
int leafX = nodeX+200;                      // začiatočná pozícia listového uzla - os x
int leafY = nodeY;                          // začiatočná pozícia listového uzla - os y



// Setup the Processing Canvas ------------------------------------------------

void setup() {
  size(700, 500);  // veľkosť hlavnáho okna

  // nacitanie suborov
  loadtree = loadStrings("treeOut.txt");             // file defined in javascript
  printFile();
  splitFile();
  getLevel();  // lvls - vrati pocet urovni stromu
  nodesCount();  // num - vrati pocet uzlov


  nodeX = width/2;
  nodeY = height/(lvls);

  nodes = new Node[num];                    // definovanie počtu uzlov
  f = createFont("Arial", 16, true);        // definovanie písma;

  drawTree();
}


// Main draw loop -------------------------------------------------------------

void draw() {
  background(#e9e9e9);
  ellipseMode(CENTER);
  close();
  for (int i=0; i<num; i++) {
    textFont(f, 5);
    fill(0);
    nodes[i].update();
    nodes[i].display();
  }
}

void close() {
  stroke(#dddddd);
  line(width-4, 4, width-16, 16);
  line(width-16, 4, width-4, 16);
  if (mouseX > (width - 20) & mouseX < (width-1) & mouseY < 20 & mouseY > 0) {
    stroke(#aaaaaa);
    line(width-4, 4, width-16, 16);
    line(width-16, 4, width-4, 16);
  }
}

void drawTree() {
  for (int j=0; j<num; j++) {
    lvl = treeTable[0][j];
    nextlvl = treeTable[0][j+1];
    name = treeTable[1][j];
    val = treeTable[2][j];
    oldX = nodeX;
    oldY = nodeY*lvl;
    nodes[j] = new Node(nodeX, nodeY*lvl, 30, name, val, nodes);

    if (nextlvl > lvl) {
      nodeX = nodeX - (width/pow(2, nextlvl));
      //line();
      //println("level"+nextlvl+" je vacsi ako"+lvl +" -->"+ nodeX);
    } 
    if (nextlvl <= lvl) {
      int pom = lvl - nextlvl;
      int pom2 = lvl;
      for (int i=0; i<pom; i++) {
        nodeX = nodeX - (width/pow(2, pom2));
        //println("pomocna premenna x " + nodeX);
        pom2--;
      }
      nodeX = nodeX + 2*(width/pow(2, nextlvl));
      //println("level"+nextlvl+" je mensi/rovny ako"+lvl +" -->"+ nodeX);
    }
  }
}

void drawLines() {
  for (int j=0; j<num; j++) {
    lvl = treeTable[0][j];
    nextlvl = treeTable[0][j+1];
    name = treeTable[1][j];
    val = treeTable[2][j];
    //nodes[j] = new Node(nodeX, nodeY*lvl, 30, name, val, nodes);

    if (nextlvl > lvl) {
      //nodeX = nodeX - (width/pow(2, nextlvl));
      //println("level"+nextlvl+" je vacsi ako"+lvl +" -->"+ nodeX);
    } 
    if (nextlvl <= lvl) {
      int pom = lvl - nextlvl;
      int pom2 = lvl;
      for (int i=0; i<pom; i++) {
        //nodeX = nodeX - (width/pow(2, pom2));
        //println("pomocna premenna x " + nodeX);
        pom2--;
      }
      //nodeX = nodeX + 2*(width/pow(2, nextlvl));
      //println("level"+nextlvl+" je mensi/rovny ako"+lvl +" -->"+ nodeX);
    }
  }
}

void mouseReleased() {
  for (int i=0; i<num; i++) {
    nodes[i].releaseEvent();
  }
}

void mousePressed() {
  if (mouseX > (width - 20) & mouseY < 20) {
    println("klikol si na tlacidlo 'close'");
  }
}


class Node {

  int x, y;
  int moveX, moveY;
  int posX;
  int posY;
  int size, minsize;
  String meno, meno2;
  int value;
  boolean over;
  boolean press;
  boolean locked = false;
  boolean otherslocked = false;
  Node[] others;

  Node(int ix, int iy, int is, String m, int v, Node[] o) {
    x = ix;
    y = iy;
    oldX = ix;
    oldY = iy;
    size = is;
    minsize = size;
    meno = m;
    value = v;
    moveX = x+posX;
    moveY = y+posY;
    others = o;
  }


  void update() {
    moveX = x+posX;
    moveY = y+posY;

    for (int i=0; i<others.length; i++) {
      if (others[i].locked == true) {
        otherslocked = true;
        break;
      } 
      else {
        otherslocked = false;
      }
    }

    if (otherslocked == false) {
      overEvent();
      pressEvent();
    }

    if (press) {
      posX = lock(mouseX-x, -(x)+size/2, width-x-(size/2)-1);
      posY = lock(mouseY-y, 0-y+size/2, height-y-size/2);
    }
  }


  void overEvent() {
    if (overNode(moveX-size/2, moveY-size/2, size, size)) {
      over = true;
    } 
    else {
      over = false;
    }
  }


  void pressEvent() {
    if (over && mousePressed || locked) {
      press = true;
      locked = true;
      size=size+10;
    } 
    else {
      press = false;
    }
  }


  void releaseEvent() {
    locked = false;
    if (over && size>minsize) {
      size=size-10;
    }
  }


  void display() {
    //line(nodeX, nodeY, x+posX, y+posY);                      // čiara medzi uzlami
    textFont(f, 16);                    // zadefinovanie textu - (font f, size 16)

    stroke(#dddddd);
    line(0, 0, moveX, moveY);

    noStroke();
    fill(000, 200, 255, 20);
    ellipse(moveX, moveY, size+10, size+10);
    fill(000, 200, 255, 70);
    ellipse(moveX, moveY, size, size);
    fill(0);                      // farba textu
    if ((meno=="false") || (meno=="true")) {
      fill(0);
      text(meno2, moveX-5, moveY+5);
      //text(value, moveX-5, moveY+35);
      if (meno=="false") {
        meno2 = "F";
      }
      if (meno=="true") {
        meno2 = "T";
      }
    } 
    else {
      text(meno, moveX+15, moveY-15);      // obsah textu, pozícia x, pozícia y
    }

    if (over || press) {
      fill(#333333);
      text(value, moveX-5, moveY+35);
      fill(255);
      ellipse(moveX, moveY, size, size);
      fill(0);
      text(meno2, moveX-5, moveY+5);
    }
  }
}


boolean overNode(int x, int y, int width, int height) {
  if (mouseX > x && mouseX < x+width && 
    mouseY > y && mouseY < y+height) {
    return true;
  } 
  else {
    return false;
  }
}


int lock(int val, int minv, int maxv) { 
  return  min(max(val, minv), maxv);
}

// ---------------------------- FILE ----------------------------

void printFile() {
  println("súbor má " + loadtree.length + " riadkov");
  for (int i=0; i < loadtree.length; i++) {
    println(loadtree[i]);
  }
  println("--------------------------------");
}


void splitFile() {
  treeTable = new String[loadtree.length][0];
  for (int j=0; j < loadtree.length; j++) {
    parse = split(loadtree[j], ' ');
    for (int i=0; i < parse.length; i++) {
      treeTable[i][j] = parse[i];
      //println(parse[i]); // vypis vsetkych prvkov tabulky
    }
  }
  //printTable(); // vypise tabulku do konzoly
}

void printTable() {
  for (int j=0; j < loadtree.length; j++) {
    for (int i=0; i < parse.length; i++) {
      print(treeTable[i][j]+ "\t");
    }
    println("");
  }
}

int nodesCount() {
  num = 0;
  int pom = 0;
  for (int j=0; j < loadtree.length; j++) {
    num++;
  }
  return num;
}

int getLevel() {
  int pom = 0;
  lvls = 0;
  for (int j=0; j < loadtree.length; j++) {
    pom = (int) treeTable[0][j];
    if (lvls < pom) {
      lvls = pom;
    }
  }
  lvls++;
  return lvls;
}


