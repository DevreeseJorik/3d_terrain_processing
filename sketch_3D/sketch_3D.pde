
int cols,rows;
int scl = 20;
float smoothness = 0.1;
int w = 2800;
int h = 1600;
float mapy = 0;
float mapx = 0;
float speed = 0;

int celestialX = -800;

float[][] terrain;
String keyheld;
color terrainclr;

int sphereZ = 20;
int sphereY = 650;

Terrain mountainTop;
Terrain mountain;
Terrain grassland;
Terrain sea;
Terrain cloud;

TimeEvent day;
TimeEvent night;
TimeEvent currentTime;


void setup() {
  size(1800,1000,P3D);
  cols = w/scl;
  rows = h/scl;
  terrain = new float[cols][rows];
 
  createTerrain();
  createTimeEvents();
  
  frameRate(60);

}

void createTimeEvents () {
  day = new TimeEvent();
  day.celBodySize = 30;
  day.skyBrightness = 0;
  day.addedHue = "R";
  day.removedHue = "B";
  
  night = new TimeEvent();
  night.celBodySize = 20;
  night.skyBrightness = -0x80;
  night.addedHue = "none";
  night.removedHue = "none";
  
  currentTime = day;
}

TimeEvent changeTime() {
   if (currentTime == day) {
   return night;
   }
   return day;
}

void createTerrain() {
    mountainTop = new Terrain();
    mountainTop.material = #E5D9CE;
    mountainTop.maxheight = 2000;
    mountainTop.texture = loadImage("snow.png");
  
  
   mountain = new Terrain();
   mountain.material = #32231d;
   mountain.maxheight = 130;
   mountain.texture = loadImage("mountain.png");
   
   grassland = new Terrain();
   grassland.material = #22AA11;
   grassland.maxheight = 80;
   grassland.texture = loadImage("grassland.png");
   
   sea = new Terrain();
   sea.material = #35A6F1;
   sea.maxheight = 60;
   sea.texture = loadImage("sea.png");
   
   cloud = new Terrain();
   cloud.material = 0xFFFFFF;
   cloud.maxheight = 100;
   cloud.texture = loadImage("snow.png");
}

color getMaterial(float h,float h2) {
  if ((h <= sea.maxheight) & (h2 <= sea.maxheight)) {
    return sea.material;
  }
 if ((h <= mountain.maxheight) & (h2 <= mountain.maxheight)) {
    return mountain.material;
  }
  return mountainTop.material;
}

color getSkyColor(float h, float h2) {
   if ((h <= cloud.maxheight) & (h2 <= cloud.maxheight)) {
    return cloud.material;
  }
  return color(0x35,0xA6,0xF1);

}

float fixedHeight(float h) {
  if (h < sea.maxheight) {
    return sea.maxheight;
  }
  return h;
}

void keyPressed() {
  if (keyCode == LEFT) {
    keyheld = "LEFT";
  }
  if (keyCode == RIGHT) {
    keyheld = "RIGHT";
  }
  if (keyCode == UP) {
    keyheld = "UP";
  }
  if (keyCode == DOWN) {
    keyheld = "DOWN";
  }
  
   /*if (key == 'j' || key == 'J') {
      celBodySize +=20;
   }
   
   if (key == 'k' || key == 'K') {
      celBodySize -=20;
   }
   
   println("CelbodySize:" + celBodySize);*/
}

void keyReleased() {
  if (keyCode == LEFT) {
    if (keyheld == "LEFT") {keyheld = "";}
  }
  if (keyCode == RIGHT) {
    if (keyheld == "RIGHT") {keyheld = "";}
  }
  if (keyCode == UP) {
    if (keyheld == "UP") {keyheld = "";}
  }
  if (keyCode == DOWN) {
    if (keyheld == "DOWN") {keyheld = "";}
  }
  
}

void updateMapPos() {
  if (keyheld == "LEFT") {
    mapx -= 0.2;
    //sphereY -= 20;
  }
  
  if (keyheld == "RIGHT") {
    mapx += 0.2;
    //sphereY += 20;
  }
  
    if (keyheld == "UP") {
    mapy -= 0.2;
    //sphereZ += 20;
  }
  
  if (keyheld == "DOWN") {
    mapy += 0.2;
    //sphereZ -= 20;
  } 
  //println("Y:" + sphereY);
  //println("Z:" + sphereZ);
  
}

void getTerrain() {
  float yoff = mapy;
  for (int y = 0; y < rows; y++) {
    float xoff = mapx;
    for (int x = 0; x < cols; x++) {
        terrain[x][y] = map(noise(xoff,yoff),0,1,0,240);
        xoff += smoothness;
    }
    yoff += smoothness;
  }
}

void drawTerrain() {
    for (int y = 0; y< rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols-1; x++) {
      float z = terrain[x][y];
      float znext = terrain[x][y+1];
      z = fixedHeight(z);
      znext = fixedHeight(znext);
      terrainclr = getMaterial(z,znext);
      
      terrainclr = addHue(terrainclr,(rows-y)*2,currentTime.addedHue);
      fill(terrainclr);
      stroke(brightenColor(terrainclr,-0x30));
      vertex(x*scl,y*scl, z);
      vertex(x*scl,(y+1)*scl,znext);

    }
    endShape();

  }
}

void drawSkybox() {
    for (int y = 0; y< rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols-1; x++) {
      float z = terrain[x][y];
      float znext = terrain[x][y+1];
      z = fixedHeight(z);
      znext = fixedHeight(znext);
      terrainclr = brightenColor(getSkyColor(z,znext),currentTime.skyBrightness);
      terrainclr = addHue(terrainclr,(rows-y)*6,currentTime.addedHue);
      terrainclr = addHue(terrainclr,(rows-y)*-2,currentTime.removedHue);
      
      if (z <= cloud.maxheight-20) {z = 0;}
      z /= 20;
      if (znext <= cloud.maxheight-20) {znext = 0;}
      znext /= 20;
      
      fill(terrainclr);
      stroke(brightenColor(terrainclr,-0x30));
      //fill(0);
      //stroke(terrainclr);
      vertex(x*scl*4,y*scl*2, z);
      vertex(x*scl*4,(y+1)*scl*2,znext);

    }
    endShape();
  }
}

color makeTransparent(int hue, int alpha) {
  int r = (hue >> 16) & 0xFF;
  int g = (hue >> 8) & 0xFF;
  int b = hue & 0xFF;
  return color(r,g,b,alpha);

}

color brightenColor(color hue,int amount) {
  int r = (hue >> 16) & 0xFF;
  int g = (hue >> 8) & 0xFF;
  int b = hue & 0xFF;
  return color(r+amount,g+amount,b+amount);

}


color addHue(color hue,int amount,String clr) {
  int r = (hue >> 16) & 0xFF;
  int g = (hue >> 8) & 0xFF;
  int b = hue & 0xFF;
  
  if (clr == "R")
  {
    r += amount;
  }
  
   if (clr == "G")
  {
    b += amount;
  }
  
    if (clr == "B")
  {
    b += amount;
  }
  
   return color(r,g,b);

}

void draw() {
  celestialX += 15;
  if (celestialX >= 800) {
    celestialX = -800;
    currentTime = changeTime();
  }
  
  background(0);
  fill(0);
  
  updateMapPos();
  getTerrain();
  translate(width/2,height/2);

  rotateX(PI/2.5);
  translate(-w/2,-h/2,-100);
  
  drawTerrain();

  rotateX(PI/10);
  translate(-2200,-2140,240);
  drawSkybox();
  
  translate(3600 + celestialX,2400,-30 - pow(celestialX/50.1,2));
  stroke(#ffffff);
  noFill();
  sphere(currentTime.celBodySize);

}

class Terrain {
  color material;
  int maxheight;
  PImage texture;
}

class Time {
  int hour;
  int minute;
  int second;
}

class TimeEvent {
  Time startTime;
  int celBodySize;
  int skyBrightness;
  color bodyColor; 
  String addedHue;
  String removedHue;
}
