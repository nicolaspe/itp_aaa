import processing.video.*;

Capture video;
PImage img;
boolean capturing;
float timer, start;
int photos;

void setup() {
  fullScreen();
  background(255);
  smooth();
  frameRate(30);
  noStroke();
  textSize(60);
  textAlign(CENTER);
  
  colorMode(HSB, 255, 255, 255, 255);
  
  // variables
  img = createImage(1920, 1080, RGB);
  capturing = false;
  timer = 0;
  start = 0.;
  photos = 0;
  
  // video capture
  String[] cameras = Capture.list();
  println("CAMERAS ===");
  for(int i=0; i<cameras.length; i++){
    //println(cameras[i]);
  }
  video = new Capture(this, 1920, 1080, cameras[15]);
  video.start();
  
  println("width: "+ width);
  println("height: " +height);
}


void draw() {
  if(video.available() == true){
    background(0);
    // read & show cam feed
    video.read();
    img = video;
    image(img, 0, 0);
    
    // black bars to crop image
    int hei = height;
    int posX = floor( (width-height)/2. );
    fill(0);
    rect(0, 0, posX, hei);
    rect(width-posX, 0, posX, hei);
    
    // show instructions if you're not capturing
    if(!capturing){
      fill(0, 220);
      rect(0, 0, width, height);
      
      fill(random(255), 255, 255, 255);
      textSize(60);
      text("PRESS ENTER TO BEGIN", 0, hei*4/8, width, hei*2/3);
      fill(255);
      textSize(40);
      text("Wanna be a part of our\n *SUPER COOL*\n generative model?", 
      0, hei/6, width, hei/3);
      textSize(40);
      text("and take pictures for 5 seconds!", 
      0, hei*10/13, width, hei*5/6);
    } else {
      // timer
      fill(255);
      float now = millis();
      float timeleft = floor((start+5800.-now)/100.)/10.;
      textSize(40);
      text(str(timeleft), width-posX*2/3, hei/8, posX/3., hei/6.);
      if(now-timer >= 200){
        saveImg();
        timer = now;
        photos++;
      }
      if(photos >= 25){
        capturing = false;
      }
    }
  }
}


/* ===================================
 * function that saves a square image
 * =================================== */
void saveImg(){
  int hei = height;
  int posX = floor( (width-height)/2. );
  PImage toSave = get(posX, 0, hei, hei);
  
  String file =  String.valueOf(day())+
                 String.valueOf(month())+ 
                 "_"+ hour()+ minute()+
                 second()+ millis()+ ".jpg";
  toSave.save(file);
}

// ========================
void keyPressed(){
  switch(keyCode){
    case ENTER:
      timer = millis();
      start = millis();
      photos= 0;
      capturing = true;
  }
}