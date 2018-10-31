import java.io.*;
import processing.video.*;

int currIBI=0;      // Time between heartbeats from Arduino
int currBPM=0;      // Heart Rate value from Arduino
int currGSR=0;      // GSR value from Arduino
int currRPM=0;


int maxNumRings=250; // 60 looks good, but is arbitrary
int videoLength; // number of frames in the video 
int videoFrameRate = 30; // frameRate the video plays at
String videoName = "";

Movie video; // the randomly selected video to play
VideoPlayer videoPlayer;

ArrayList<Integer> heartRate = new ArrayList<Integer>();
ArrayList<Integer> GSR = new ArrayList<Integer>();

boolean videoStarted, videoEnded;
float maxRadius;
int counter;

class Ring {
  //int ibi; // how much variation there is in your heartbeats within a certain interval (heart irregularity)
  // factors like stress can lead to increased heart rate and lowered heart rate variability
  // lower HRV associated with pressure, emotional strain, and anxiety
  // 
  int rpm;
  int bpm;
  int gsr;
  int timeStamp;

  Ring(int average_breathing_rate, int heart, int sweat, int time) {
    //ibi = interbeat;
    rpm = average_breathing_rate;
    bpm = heart;
    gsr = sweat;
    timeStamp = time;
  }
}

// Holds rings from earliest -> most recent
ArrayList<Ring> rings;

void settings() {
  size(1000, 1000);
  maxRadius = width/2;
}

void setup() {
  if (!setupPort()) { // something went wrong with Arduino
    System.out.println("WARNING: Arduino Error");
  }

  startProcessing();
}


void startProcessing()
{
  videoStarted = false;
  videoEnded = false;
  rings = new ArrayList<Ring>();

  background(255);
  File f = new File(sketchPath("data"));
  String[] videoList = f.list();
  if (videoList.length < 1) { // if no videos
    System.out.println("NO VIDEOS TO CHOOSE FROM! Add a video to the data folder");

    // If for some reason, no videos can play, just let the simulation run for 2000 frames
    videoLength = 2000;
  } else {



    while (true)
    {
      int randomVideoNumber = (int)random(videoList.length);
      String[] fileNameSegments = split(videoList[randomVideoNumber], ".");
      //println(fileNameSegments[1]);
      //Skip names of hidden files, only consider those file names that end with .mov
      if (fileNameSegments[1].equals("mov") || fileNameSegments[1].equals("MOV"))
      {
        videoName = videoList[randomVideoNumber];
        break;
      }
    }
  }


  //String videoName = videoList[(int) random(videoList.length)];
  
  System.out.println("Video chosen: " + videoName);
  video = new Movie(this, videoName) {
    @Override public void eosEvent() {
      super.eosEvent();
      myEoS();
    }
  };
}

void draw() {

  if (currRPM>0 && currBPM>0 && currBPM<160 && !videoStarted)
  //if (!videoStarted)
  {
    videoStarted=true;
    frameRate(videoFrameRate);
    // Pausing the video at the first frame so that we can save duration
    video.play();
    video.jump(0);
    video.pause();
    // multiply length of video (seconds) by frameRate (number of frames per second) to get total number of frames
    videoLength = (int) video.duration() * videoFrameRate;
    videoPlayer = new VideoPlayer();
    //videoPlayer.background(video);
    println(video.duration());
    //maxNumRings =
  }

  if (videoStarted && !videoEnded)
  {

    if (video.available()) {
      video.read();
    }

    // Every # of frames, until frame #videoLength, create a new ring and add it to the rings ArrayList
    //if (frameCount%((int)(videoLength/maxNumRings))== 0 && frameCount <= videoLength) {
    if (video.time()<video.duration())
    {
      //println(video.time()-video.duration());
      if (frameCount%((int)(videoLength/maxNumRings))== 0)
        addNewRing();
    } else
    {

      if (!videoEnded)
      {
        println("Press R to restart...");
        videoEnded = true;
        saveFrame("Flowers/flower-######-"+videoName+".jpg");
      }
    }
    //}

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

  if (videoEnded)
  {
    if (keyPressed) {
      if (key == 'R' || key == 'r') {
        startProcessing();
      }
    }
  }
}

//void keyPressed()
//{
//  if (videoEnded)
//  {
//    if (key == CODED) {
//      if (keyCode == KeyR) {
//        startProcessing();
//      }
//    }
//  }
//}

void addNewRing() {
  // Limit IBI to [100, 1200] (not really sure if this is a good range)

  //println(parseFloat(IBI));
  //currIBI = max(currIBI, 100);
  //currIBI = min(currIBI, 1200);

  // Limit BPM to nothing for now


  // Limit GSR to [100, ?]

  currGSR = max(currGSR, 300);
  currGSR = min(currGSR, 900);

  // Create an instance of a ring to represent the user's data at this time 
  Ring newRing = new Ring(currRPM, currBPM, currGSR, frameCount);
  rings.add(newRing);
  System.out.println("RPM: " + currRPM + "      - BPM: " + currBPM + "          - GSR: " + currGSR);
}

void drawRing(Ring r, int index) {
  //int ibi = r.ibi;
  int rpm = r.rpm;
  int bpm = r.bpm;
  int gsr = r.gsr;

  // Circular base of the ring has radius based on index (the more recent the ring, the greater its index in the ArrayList, and the greater its radius)
  //float radius = width*(video.time()/video.duration()); // 6 is arbitrary
  float radius = index*2;
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
    float petalHeight = rpm*6; // 6 is arbitrary
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
