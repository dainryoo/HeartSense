import java.io.*;
import processing.video.*;

int currIBI;      // Time between heartbeats from Arduino
int currBPM;      // Heart Rate value from Arduino
int currGSR;      // GSR value from Arduino

int maxNumRings = 60; // 60 looks good, but is arbitrary
int videoLength; // number of frames in the video 
int videoFrameRate = 30; // frameRate the video plays at

Movie video; // the randomly selected video to play
VideoPlayer videoPlayer;

class Ring {
  int ibi; // how much variation there is in your heartbeats within a certain interval (heart irregularity)
  // factors like stress can lead to increased heart rate and lowered heart rate variability
  // lower HRV associated with pressure, emotional strain, and anxiety
  // 
  int bpm;
  int gsr;
  int timeStamp;

  Ring(int interbeat, int heart, int sweat, int time) {
    ibi = interbeat;
    bpm = heart;
    gsr = sweat;
    timeStamp = time;
  }
}

// Holds rings from earliest -> most recent
ArrayList<Ring> rings = new ArrayList<Ring>();

void setup() {
  if (!setupPort()) { // something went wrong with Arduino
    System.out.println("WARNING: Arduino Error");
  }

  File f = new File(sketchPath("data"));
  String[] videoList = f.list();
  if (videoList.length < 1) { // if no videos
    System.out.println("NO VIDEOS TO CHOOSE FROM! Add a video to the data folder");

    // If for some reason, no videos can play, just let the simulation run for 2000 frames
    videoLength = 2000;
  } else {
    String videoName = videoList[(int) random(videoList.length)];
    System.out.println("Now playing " + videoName);
    video = new Movie(this, videoName) {
      @Override public void eosEvent() {
        super.eosEvent();
        myEoS();
      }
    }; 
    frameRate(videoFrameRate);
    // Pausing the video at the first frame so that we can save duration
    video.play();
    video.jump(0);
    video.pause();
    // multiply length of video (seconds) by frameRate (number of frames per second) to get total number of frames
    videoLength = (int) video.duration() * videoFrameRate; 
  }
  size(640, 640); 

  videoPlayer = new VideoPlayer();
}

void draw() {
  if (video.available()) {
    video.read();
  }

  // Every # of frames, until frame #videoLength, create a new ring and add it to the rings ArrayList
  if (frameCount%((int)(videoLength/maxNumRings))== 0 && frameCount <= videoLength) {
    addNewRing();
  }

  // Draw white background
  background(255);
  // Draw each ring in the rings ArrayList
  for (int i = rings.size()-1; i >= 0; i--) {
    // Get the current ring
    Ring currRing = rings.get(i);
    // Draw the current ring
    drawRing(currRing, i);
  }
}

void addNewRing() {
  // Limit IBI to [100, 1200] (not really sure if this is a good range)
  currIBI = max(currIBI, 100);
  currIBI = min(currIBI, 1200);

  // Limit BPM to nothing for now
  

  // Limit GSR to [100, ?]
  currGSR = max(currGSR, 100);
  //currGSR = min(currGSR, 292);

  // Create an instance of a ring to represent the user's data at this time 
  Ring newRing = new Ring(currIBI, currBPM, currGSR, frameCount);
  rings.add(newRing);
  System.out.println("IBI: " + currIBI + "      - BPM: " + currBPM + "          - GSR: " + currGSR);
}

void drawRing(Ring r, int index) {
  int ibi = r.ibi;
  int bpm = r.bpm;
  int gsr = r.gsr;

  // Circular base of the ring has radius based on index (the more recent the ring, the greater its index in the ArrayList, and the greater its radius)
  float radius = index*6.0; // 6 is arbitrary
  float cx = width/2.0;  // center of circle
  float cy = height/2.0; // center of circle
  // ellipse(cx, cy, radius, radius);

  // Frequency of "petals" along the circumference depends on bpm
  // The x1,y1, x2,y2 coordinates represent the ends of the bezier curves that make up the ring
  // So the more dots, the more bezier curves on this ring
  int numPetals = (int) (bpm/7); // 7 is arbitrary

  for (int i = 0; i < numPetals; i++) {
    float angle = (i * TWO_PI / numPetals) + r.timeStamp/100; 
    // index*0.1 is purely for aesthetics: adds an extra bit to the angle so that all the petals don't all start at the same angle 
    float x1 = cx + cos(angle) * radius; // one end of curve
    float y1 = cy + sin(angle) * radius; 

    float nextAngle;
    if (i == numPetals) {
      nextAngle = TWO_PI / numPetals + r.timeStamp/100;
    } else {
      nextAngle = (i+1) * TWO_PI / numPetals + r.timeStamp/100;
    }
    float x2 = cx + cos(nextAngle) * radius; // other end of curve
    float y2 = cy + sin(nextAngle) * radius;

    // Petal height depends on IBI
    // 30-100 petal height looks pretty good (arbitrary once again)
    // IBI seems to be around 100-1200
    float petalHeight = ibi/6.0; // 6 is arbitrary
    float control1X = cx + cos(angle) * (radius+petalHeight); // curve control point
    float control1Y = cy + sin(angle) * (radius+petalHeight);
    float control2X = cx + cos(nextAngle) * (radius+petalHeight); // curve control point
    float control2Y = cy + sin(nextAngle) * (radius+petalHeight); 

    // Petal color depends on GSR
    beginShape();
    //noFill();
    fill(color(255, 255, 255), 255*0.5);
    color petalColor = getColor(gsr);
    stroke(petalColor);
    strokeWeight(1);
    bezier(x1, y1, control1X, control1Y, control2X, control2Y, x2, y2);
    endShape();

    // Uncomment to view control points for bezier curves
    /*
    noFill();
     stroke(color(100, 140, 200));
     ellipse(x1, y1, 2, 2);
     ellipse(x2, y2, 2, 2);
     stroke(color(200, 100, 100));
     ellipse(control1X, control1Y, 2, 2);
     ellipse(control2X, control2Y, 2, 2);
     */
  }
}
