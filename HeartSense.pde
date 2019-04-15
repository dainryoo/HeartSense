import processing.video.*;

int currentState; 
// 0 = welcome
// 1 = instructions
// 2 = video
// 4 = playback

int HEIGHT = 800;
int WIDTH = 1440;

ArrayList<Ring> introRings;

Movie video;
PImage logo;

color c_background = color(250, 250, 250);
color c_text = color(60);
color c_white = color(255, 255, 255);
color c_black = color(0, 0, 0);
color c_gray = color(200);
color c_red = color(251, 114, 86);

int titleTextSize = 24;
int subtitleTextSize = 20;
int bodyTextSize = 12;
int buttonTextSize = 18;

color c_btnFill = color(92, 107, 192);
color c_btnHover = color(108, 124, 216);
color c_btnText = c_white;
float buttonRounding = 6;

//float serialListLength=0;
String[] serialListOld; 

void setup() {
  size(1440, 800);
  surface.setIcon(loadImage("logo_color.png"));
  logo = loadImage("logo.png");
  logo.resize(100, 100);
  currentState = 0;
  serialListOld = Serial.list();

  resetMinMax();
  makeIntroRings();
}

void makeIntroRings() {
  introRings = new ArrayList<Ring>();
  int numIntroRings = 15;
  for (int i = 1; i <= numIntroRings; i++) {
    Ring newRing = new Ring((int)random(fake_min_ibi, fake_max_ibi), (int)random(fake_min_bpm, fake_max_bpm), (int)random(fake_min_gsr, fake_max_gsr), 1.0*i/numIntroRings);
    introRings.add(newRing);
  }
}

void exit() {
  video = null;
  super.exit();
}

void setupVideo() {
  video = new Movie(this, randomVideo()) {
    @Override public void eosEvent() {
      super.eosEvent();
      videoEndEvent();
    }
  };
  video.play();
  videoOver = false;
  lastSavedFrame = 0;
}

void videoEndEvent() {
  videoOver = true;
}

void clearMouseOvers() {
  // 0: Welcome
  mouseOverStartBtn = false;

  // 1: Instructions
  mouseOverStartVideoBtn = false;

  // 2: Video
  mouseOverFlowerBtn = false;
  videoOver = false;

  // 3: Flower
  mouseOverReplayBtn = false;
  mouseOverPlaybackBtn = false;
  flowerOver = false;

  // 4: Playback
  mouseOverGrabber = false;
  mouseOverSlider = false;
  mouseOverPlayBtn = false;
  allowButtonLogic = true;
  mouseOverRestartBtn = false;
}

/*
 * Returns the name of a randomly selected video
 */
String randomVideo() {
  String videoName = "";
  File f = new File(sketchPath("data"));
  String[] videoList = f.list();
  if (videoList.length < 1) { // if no videos
    System.out.println("NO VIDEOS TO CHOOSE FROM! Add a video to the data folder");
  } else {
    int attempts = videoList.length; // attempt to find a video file videoList.length times
    while (attempts > 0 && videoName.equals("")) {
      int randomVideoNumber = (int)random(videoList.length);
      String[] fileNameSegments = split(videoList[randomVideoNumber], ".");
      if (fileNameSegments.length > 1 && (fileNameSegments[1].equalsIgnoreCase("mov") || fileNameSegments[1].equalsIgnoreCase("mp4"))) {
        videoName = videoList[randomVideoNumber];
      }
    }
  }
  //return videoName;
  return "cat.mp4";
}

void draw() {
 
  switch(currentState) {
  case 0:
    welcome();
    break;
  case 1:
    findArduinoPort();
    instructions();
    break;
  case 2:
    playVideo();
    break;
  case 3:
    playFlower();
    break;
  case 4:
    playback();
    break;
  default:
    background(0);
    break;
  }
}

int selectedPort = -1;

void findArduinoPort()
{
  boolean dissimilar = false;
  if(serialListOld.length<Serial.list().length)
  {
    for(int i=0;i<serialListOld.length;i++)
    {
      if(!serialListOld[i].equals(Serial.list()[i]))
      {
        selectedPort = i;
        dissimilar = true;
        break;
      }
    }
    if(!dissimilar)
      selectedPort = Serial.list().length-1;
    
    println(selectedPort);
    
  }
  serialListOld = Serial.list();
  
}

void drawButton(String s) {
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(buttonTextSize);

  if (s.equals("start")) {
    mouseOverStartBtn = mouseOver(startBtnX, startBtnY, startBtnX+startBtnW, startBtnY+startBtnH);
    if (mouseOverStartBtn) {
      fill(c_btnHover);
    } else {
      fill(c_btnFill);
    }
    rect(startBtnX, startBtnY, startBtnW, startBtnH, buttonRounding);
    fill(c_btnText);
    text("START", startBtnX, startBtnY, startBtnW, startBtnH);
  } else if (s.equals("startVideo")) {
    mouseOverStartVideoBtn = mouseOver(startVideoBtnX, startVideoBtnY, startVideoBtnX+startVideoBtnW, startVideoBtnY+startVideoBtnH);
    if (mouseOverStartVideoBtn) {
      fill(c_btnHover);
    } else {
      fill(c_btnFill);
    }
    rect(startVideoBtnX, startVideoBtnY, startVideoBtnW, startVideoBtnH, buttonRounding);
    fill(c_btnText);
    text("PLAY VIDEO", startVideoBtnX, startVideoBtnY, startVideoBtnW, startVideoBtnH);
  } else if (s.equals("flower")) {
    mouseOverFlowerBtn = mouseOver(flowerBtnX, flowerBtnY, flowerBtnX+flowerBtnW, flowerBtnY+flowerBtnH);
    if (mouseOverFlowerBtn) {
      fill(c_btnHover);
    } else {
      fill(c_btnFill);
    }

    rect(flowerBtnX, flowerBtnY, flowerBtnW, flowerBtnH, buttonRounding);
    fill(c_btnText);
    text("SHOW FLOWER", flowerBtnX, flowerBtnY, flowerBtnW, flowerBtnH);
  } else if (s.equals("reset")) {
    mouseOverResetBtn = mouseOver(resetBtnX, resetBtnY, resetBtnX+resetBtnW, resetBtnY+resetBtnH);
    if (mouseOverResetBtn) {
      fill(c_btnHover);
    } else {
      fill(c_btnFill);
    }
    rect(resetBtnX, resetBtnY, resetBtnW, resetBtnH, buttonRounding);
    fill(c_btnText);
    text("WATCH A NEW VIDEO", resetBtnX, resetBtnY, resetBtnW, resetBtnH);
  } else if (s.equals("replay")) {
    mouseOverReplayBtn = mouseOver(replayBtnX, replayBtnY, replayBtnX+replayBtnW, replayBtnY+replayBtnH);
    if (mouseOverReplayBtn) {
      fill(c_btnHover);
    } else {
      fill(c_btnFill);
    }
    rect(replayBtnX, replayBtnY, replayBtnW, replayBtnH, buttonRounding);
    fill(c_btnText);
    text("REPLAY FLOWER",replayBtnX, replayBtnY, replayBtnW, replayBtnH);
  } else if (s.equals("playback")) {
    mouseOverPlaybackBtn = mouseOver(playbackBtnX, playbackBtnY, playbackBtnX+playbackBtnW, playbackBtnY+playbackBtnH);
    if (mouseOverPlaybackBtn) {
      fill(c_btnHover);
    } else {
      fill(c_btnFill);
    }
    rect(playbackBtnX, playbackBtnY, playbackBtnW, playbackBtnH, buttonRounding);
    fill(c_btnText);
    text("FLOWER + VIDEO", playbackBtnX, playbackBtnY, playbackBtnW, playbackBtnH);
  }  else if (s.equals("restart")) {
    mouseOverRestartBtn = mouseOver(restartBtnX, restartBtnY, restartBtnX+restartBtnW, restartBtnY+restartBtnH);
    if (mouseOverRestartBtn) {
      fill(c_btnHover);
    } else {
      fill(c_btnFill);
    }
    rect(restartBtnX, restartBtnY, restartBtnW, restartBtnH, buttonRounding);
    fill(c_btnText);
    text("NEW DEMO", restartBtnX, restartBtnY, restartBtnW, restartBtnH);
  }
}

// returns whether mouse is within the bounds
boolean mouseOver(int x1, int y1, int x2, int y2) {
  return (mouseX>x1 && mouseX<x2 && mouseY>y1 && mouseY<y2);
}
