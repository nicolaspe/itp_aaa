import controlP5.*;
import oscP5.*;
import netP5.*;

String REMOTE_IP = "10.17.105.148";
String NAME = "nico";
int REMOTE_PORT = 12001;
int numValues = 5;

ControlP5 cp5;
OscP5 oscP5;
NetAddress location;
boolean ready;

void setup() {
  size(480, 480);
  frameRate(30);
  ready = false;

  oscP5 = new OscP5(this, 12000);
  location = new NetAddress(REMOTE_IP, REMOTE_PORT);

  cp5 = new ControlP5(this);
  for (int i=0; i<numValues; i++) {
    cp5.addSlider("value"+nfs(i, 3, 0)).setPosition(20,20+22*i).setRange(0,1).setWidth(400).setHeight(20);
  }

  register(); 
  ready = true;
}

void controlEvent(ControlEvent theEvent) {
  if (!ready) {
    return;
  }
  //println("id "+theEvent.getController().getId());
  sendOsc();
}

void draw() {
  background(0);  
}

void sendOsc() {
  OscMessage msg = new OscMessage("/shady/"+NAME);
  for (int i=0; i<numValues; i++) {
    float value = cp5.getController("value"+nfs(i, 3, 0)).getValue();
    msg.add(value);
  }
  oscP5.send(msg, location);
}

void register() {
  OscMessage msg = new OscMessage("/register");
  msg.add(NAME);
  oscP5.send(msg, location);
}

void oscEvent(OscMessage msg) {
  String address = msg.addrPattern();
  if (address.equals("/wek/outputs")) {
    for (int i=0; i<numValues; i++) {
      float value = msg.get(i).floatValue();
      cp5.getController("value"+nfs(i, 3, 0)).setValue(value);      
    }
  }
}