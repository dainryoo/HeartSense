import java.io.*;
import processing.video.*;

int currBPM = 0;         // Heart Rate value from Arduino
int currGSR = 0;         // GSR value from Arduino
int currRPM = 0;         // Average respiration from Arduino

int videoLength;         // Number of frames in the video 
int videoFrameRate = 30; // Frame rate the video plays at
String videoName = "";   // Name of the video playing

Movie video;             // The randomly selected video to play
VideoPlayer videoPlayer; // Custom video player object

ArrayList<Integer> heartRate = new ArrayList<Integer>();
ArrayList<Integer> GSR = new ArrayList<Integer>();

boolean videoEnded;
float maxRadius;
int counter;             // Frame# that's currently playing


// Holds rings from earliest -> most recent
ArrayList<Ring> rings;

void settings() {
  size(1000, 1000);
  maxRadius = width/2;
}

void setup() {
  /*
  if (!setupPort()) { // something went wrong with Arduino
   System.out.println("WARNING: Arduino Error");
   }*/

  setupProcessing();
}


void setupProcessing() {
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
      if (fileNameSegments[1].equalsIgnoreCase("mov")) {
        videoName = videoList[randomVideoNumber];
        break;
      }
    }
  }

  System.out.println("Video chosen: " + videoName);
  video = new Movie(this, videoName) {
    @Override public void eosEvent() {
      super.eosEvent();
      myEoS();
    }
  };
  counter = 0;

  frameRate(videoFrameRate);

  video.play();
  video.jump(0);
  video.pause(); // Pausing the video at the first frame so that we can save duration

  videoLength = (int) video.duration() * videoFrameRate; // video duration (seconds) * frameRate (frames per second) = total number of frames
  videoPlayer = new VideoPlayer();
}

void draw() {
  if (!videoEnded) {
    if (video.available()) {
      video.read();
    }

    if (counter < videoLength) {
      if (counter%((int)(videoLength/MAX_NUM_RINGS))== 0) {
        addNewRing(); // add a new layer and draw it
      }
    } else {
      if (!videoEnded) {
        println("Press R to restart...");
        videoEnded = true;
        saveFrame("Flowers/flower-######-"+videoName+".jpg");
      }
    }
    counter++;
  }

  if (videoEnded) {
    if (keyPressed && (key == 'R' || key == 'r')) {
      setupProcessing();
    }
  }
}
