import java.io.*;
import processing.video.*;

int currBPM = 0;      // Heart Rate value from Arduino
int currGSR = 0;      // GSR value from Arduino
int currRPM = 0;

int maxNumRings = 250; // 60 looks good, but is arbitrary
int videoLength; // number of frames in the video 
int videoFrameRate = 30; // frameRate the video plays at
String videoName = "";

Movie video; // the randomly selected video to play
VideoPlayer videoPlayer;

ArrayList<Integer> heartRate = new ArrayList<Integer>();
ArrayList<Integer> GSR = new ArrayList<Integer>();

boolean videoEnded;
float maxRadius;
int counter;

boolean plotLater = false;
boolean gotXethruData;
boolean finishedPlot;

int ringCounter;

float startTime, endTime;
String startTimeString;

// Holds rings from earliest -> most recent
ArrayList<Ring> rings;

void settings() {
  size(1000, 1000);
  maxRadius = width/2;
}

void setup() {
  /*if (!setupPort()) { // something went wrong with Arduino
    System.out.println("WARNING: Arduino Error");
  }*/

  startProcessing();
}


void startProcessing()
{
  startTime = hour()*3600+minute()*60+second();
  startTimeString =  hour()+":"+minute()+":"+second();
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
    while (true) {
      int randomVideoNumber = (int)random(videoList.length);
      String[] fileNameSegments = split(videoList[randomVideoNumber], ".");

      //Skip names of hidden files, only consider those file names that end with .mov
      if (fileNameSegments.length>1) {
        if (fileNameSegments[1].equalsIgnoreCase("mov") || fileNameSegments[1].equalsIgnoreCase("mp4")) {
          videoName = videoList[randomVideoNumber];
          break;
        }
      }
    }
  }


  //String videoName = videoList[(int) random(videoList.length)];

  System.out.println("Video chosen: " + videoName);
  video = new Movie(this, videoName) {
    @Override 
    public void eosEvent() {
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
  videoPlayer = new VideoPlayer();

  ringCounter = 0;
  gotXethruData = false;
  finishedPlot =false;
}

void draw() {

  if (!videoEnded) {

    if (video.available()) {
      video.read();
    }

    if (counter < videoLength) {
      if (counter%(videoLength/MAX_NUM_RINGS)== 0) {
        addNewRing(); // add a new layer and draw it
      }
    } else {
      if (!videoEnded) {
        //println("Press R to restart...");
        videoEnded = true;
        endTime = hour()*3600+minute()*60+second();
        println("Press y if stopped Xethru recording");
      }
    }
    counter++;
  }


  //----------When video has ended--------
  if (videoEnded) {
    if (!plotLater) {
      saveFrame("Flowers/flower-######-"+videoName+".jpg");
    }

    if (keyPressed && (key == 'R' || key == 'r')) {
      startProcessing();
    }

    if (plotLater) {
      if (!gotXethruData) {
        //Make sure to stop Xethru recording first
        if (keyPressed && (key == 'Y' || key == 'y')) {
            getDataFromCSVFile();
        }
      } else {
        if (ringCounter<rings.size()) {
          drawRing(rings.get(ringCounter), ringCounter); // draw this new layer
          ringCounter++;
        }
      }

      //Save AFTER plot has finished drawing
      if (ringCounter >= rings.size() && !finishedPlot) {
        finishedPlot = true;
        saveFrame("Flowers/flower-######-"+videoName+".jpg");
        postInit();
      }

      if (finishedPlot) {
        ProgressBar();
      }
    }
  }
}
