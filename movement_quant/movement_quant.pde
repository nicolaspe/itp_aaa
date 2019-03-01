import processing.video.*;

Capture video;
int thr0, thr1, thr2;
int cellSize;
int tolerance;
int fade;
color c0, c1, c2, c3;
int[] prevImg;
PImage procImg;
boolean style;
float multX, multY;
// controlling parameters
float counter, movement, bright, satur, red, gre, blu;


void setup() {
  // canvas
  int wid = 640;  int hei = 480;
  //size(640, 480);
  fullScreen();
  multX = width/wid;
  multY = 2.;
  print("scaling factors: " + multX + " - " + multY);
  background(255);
  
  // settings 
  noStroke();
  colorMode(HSB, 360, 100, 100, 100);
  smooth();
  frameRate(30);
  
  // parameters
  counter = 0.;
  movement = 0.;
  bright = 0.;
  satur =0.; 
  red = 0.; 
  gre = 0.;
  blu = 0.;
  
  // variables
  thr0 = 40;
  thr1 = 60;
  thr2 = 80;
  cellSize = 8;
  tolerance = 20;
  fade = 5;
  style = true;
  
  // colors 
  c0 = color(270, 79, 22, 100);
  c1 = color(190, 84, 75, 100);
  c2 = color(284, 49, 100, 100);
  c3 = color(0, 0, 100, 100);
  
  // init
  procImg = createImage(wid, hei, RGB);
  
  // video capture
  String[] cameras = Capture.list();
  video = new Capture(this, wid, hei, cameras[1]);
  video.start();
}


void draw() {
  if(video.available() == true){
    background(0);
    // read cam feed
    video.read();
    PImage img = video;
    // process image
    procImg = pixel_fade(procImg, img);
    // display
    //image(procImg, 0, 0);
    recalc(procImg);
    // update previous image
    prevImg = getBrightArray(img);
  }
}



PImage pixel_fade(PImage shown, PImage img){
  final int w = img.width;
  final int h = img.height;
  
  PImage result = new PImage(w, h);
  img.loadPixels();
  result.loadPixels();
  
  if(prevImg == null){
    result = img;
  } else { 
    for(int i=0; i<w; i++){
      for(int j=0; j<h; j++){
        int loc = i + j*w;
        int loc2 = (w-i-1) + j*w;
        // color info
        float hue = hue(img.pixels[loc]);
        float sat = saturation(img.pixels[loc]);
        float bri = brightness(img.pixels[loc]);
        // motion detection
        float br0 = prevImg[loc];  // prev brightness
        float diff = abs(bri-br0);
        // alpha value
        float a = constrain( alpha(shown.pixels[loc2])-fade, 0, 100 );
        if(diff > tolerance){ a = 100; }
        // final pixel
        result.pixels[loc2] = color(hue, sat, bri, a);
      }
    }
    result.updatePixels();
  }
  // return
  return result;
}

/* Method returns a 1D array of the brightness level of each pixel */
int[] getBrightArray(PImage img){
  int[] array = new int[img.width*img.height];  // Initialize array
  img.loadPixels();
  for(int x=0; x<img.width; x++){
    for(int y=0; y<img.height; y++){
      int loc = x +y*img.width;
      array[loc] = (int) brightness(img.pixels[loc]);  // save brightness
    }
  }
  return array;
}


void recalc(PImage img){  
  img.loadPixels();
  int cols = img.width/cellSize;  // Number of columns
  int rows = img.height/cellSize; // Number of rows
  
  // reset parameters
  counter = 0.;
  movement = 0.;
  bright = 0.;
  satur =0.; 
  red = 0.; 
  gre = 0.;
  blu = 0.;
  
  for(int i=0; i<cols; i++){
    for(int j=0; j<rows; j++){
      int x = i*cellSize;
      int y = j*cellSize;
      int loc = x + y*img.width;
      float h = hue(img.pixels[loc]);        // hue in location
      float s = saturation(img.pixels[loc]); // saturation in location
      float b = brightness(img.pixels[loc]); // brightness in location
      float a = alpha(img.pixels[loc]);      // alpha in location
      
      color c;
      
      if(style){
        if( b<=thr0 ) { 
          c = c0;
        } else if( b<=thr1 ) {
          c = c1;
        } else if( b<=thr2 ) {
          c = c2;
        } else {
          c = c3;
        }
      } else {
        c = color(h, s, b);
      }
      
      
      float size = map( a, 0, 100, cellSize*0.3, cellSize*1.2);
      
      pushMatrix();
      translate( multX*(x+cellSize/2), multY*(y+cellSize/2) );
      fill(c, a);
      ellipse(0, 0, multX*size, multY*size);
      popMatrix();
    }
  }
}


void keyPressed(){
  switch(key){
    case '+':
      cellSize++;
      break;
    case '-':
      if(cellSize>1){ cellSize--; }
      break;
    case 's':
      String file =  String.valueOf(day()) + String.valueOf(month()) + 
                    "_" + hour() + minute() + second() + ".jpg";
      save(file);
     case 'u':
       thr0++;
       break;
     case 'j':
       thr0--;
       break;
     case 'i':
       thr1++;
       break;
     case 'k':
       thr1--;
       break;
     case 'o':
       thr2++;
       break;
     case 'l':
       thr2--;
       break;
     case 'a':
       style = !style;
       break;
  }
}