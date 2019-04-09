/*
 * -------------------------------
 *          VIDEO PAGE:
 *     Just the video plays
 *      for the first time
 * -------------------------------
 */

int flowerBtnX = WIDTH/2 - 140;
int flowerBtnY = HEIGHT/2 + 100;
int flowerBtnW = 280;
int flowerBtnH = 50;

int resetBtnX = flowerBtnX;
int resetBtnY = flowerBtnY + flowerBtnH + 20;
int resetBtnW = flowerBtnW;
int resetBtnH = flowerBtnH;

boolean mouseOverFlowerBtn = false;
boolean mouseOverResetBtn = false;
boolean videoOver = false;

int videoWidth = 0;
int videoHeight = 0;

void resizedFrame(int screenWidth, int screenHeight, int screenX, int screenY) {
  // https://stackoverflow.com/questions/6565703/math-algorithm-fit-image-to-screen-retain-aspect-ratio
  PImage videoFrame = video.get();

  float videoResolution = videoWidth*1.0/videoHeight;
  float screenResolution = screenWidth/screenHeight;

  int newWidth = 0;
  int newHeight = 0;

  if (screenResolution > videoResolution) { // portrait
    newWidth = (int)(videoWidth * (screenHeight*1.0/videoHeight));
    newHeight = screenHeight;
  } else { // landscape
    newWidth = screenWidth;
    newHeight = (int)(videoHeight * (screenWidth*1.0/videoWidth));
  }
  videoFrame.resize(newWidth, newHeight);
  int newX = (screenWidth-newWidth)/2 + screenX;
  int newY = (screenHeight-newHeight)/2 + screenY;
  image(videoFrame, newX, newY);
}

float lastSavedFrame = 0;

int videoAreaX = 175;
int videoAreaY = titleY + 80;
int videoAreaW = WIDTH-350;
int videoAreaH = HEIGHT-270;

void playVideo() {
  // VIDEO
  // add a ring if an appropriate amount of time has passed
  float currVideoPercent = video.time()/video.duration();
  if (Math.abs(currVideoPercent-lastSavedFrame) > (1.0/MAX_RINGS)) {
    lastSavedFrame = currVideoPercent;
    //Ring newRing = new Ring((int)random(MIN_IBI, MAX_IBI), (int)random(MIN_BPM, MAX_BPM), (int)random(MIN_GSR, MAX_GSR), video.time()/video.duration());
    Ring newRing = new Ring(curr_ibi, curr_bpm, curr_gsr, video.time()/video.duration());
    if (curr_ibi < MIN_IBI) {
      MIN_IBI = curr_ibi;
    }
    if (curr_ibi > MAX_IBI) {
      MAX_IBI = curr_ibi;
    }
    if (curr_bpm < MIN_BPM) {
      MIN_BPM = curr_bpm;
    }
    if (curr_bpm > MAX_BPM) {
      MAX_BPM = curr_bpm;
    }

    if (curr_gsr < MIN_GSR) {
      MIN_GSR = curr_gsr;
    }
    if (curr_gsr > MAX_GSR) {
      MAX_GSR = curr_gsr;
    }
    rings.add(newRing);
  }

  if (video.available()) {
    background(c_background);
    drawTitle();

    fill(c_black);
    rect(videoAreaX, videoAreaY, videoAreaW, videoAreaH);
    video.read();
    if (videoWidth == 0 || videoHeight == 0) {
      videoWidth = video.width;
      videoHeight = video.height;
    } else {
      resizedFrame(videoAreaW, videoAreaH, videoAreaX, videoAreaY);
    }
  } else if (videoOver) {
    fill(c_white);
    rect(videoAreaX, videoAreaY, videoAreaW, videoAreaH);

    textAlign(CENTER);
    fill(c_text);
    textSize(subtitleTextSize);
    text("Video complete", WIDTH/2, flowerBtnY-80);
    text("Please make sure you have stopped XeThru recording.", WIDTH/2, flowerBtnY - 50);

    drawButton("reset");
    if (mouseOverResetBtn && mousePressed && currentState != 1) {
      clearMouseOvers();
      currentState = 1;
    }

    drawButton("flower");
    if (mouseOverFlowerBtn && mousePressed && currentState != 3) {
      clearMouseOvers();
      currentState = 3;

      fill(c_white);
      rect(flowerAreaX, flowerAreaY, flowerAreaW, flowerAreaH);
    }
  }
}
