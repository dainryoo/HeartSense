/*
 * -------------------------------
 *         PLAYBACK PAGE:
 *     Shows video and flower
 *          side by side
 * -------------------------------
 */

boolean paused = false;

ArrayList<Ring> rings;

int MAX_RINGS = 90;
int MIN_PETALS = 15;
int MAX_PETALS = 40;
int MAX_PETAL_HEIGHT = 100;
float IBI_HEIGHT_EFFECT = 0.25; // how much the RPM effects height

int boxWidth = videoAreaW/2;
int paddingBetweenBoxes = 0;
int leftX = videoAreaX;
int rightX = videoAreaX + boxWidth + paddingBetweenBoxes;
int boxY = videoAreaY;
int boxHeight = videoAreaH;

int sliderX = leftX + 30;
int sliderY = 10 + boxY + boxHeight;
int sliderWidth = boxWidth*2 + paddingBetweenBoxes - 30;
int sliderHeight = 20;

float currPos = sliderX;
float currPercentage = 0;
int grabberWidth = 12;
int grabberHeight = sliderHeight+10;

boolean mouseOverGrabber = false;
boolean mouseOverSlider = false;

int playBtnW = 25;
int playBtnH = sliderHeight;
int playBtnX = leftX;
int playBtnY = sliderY;

int playIconW = playBtnW/3;
int playIconH = playBtnH/2;
int playIconX = playBtnX + (int)(playBtnW/3);
int playIconY = playBtnY + (int)(playBtnH/4);

boolean mouseOverPlayBtn = false;
boolean allowButtonLogic = true;

int restartBtnW = 180;
int restartBtnH = 50;
int restartBtnX = WIDTH-355;
int restartBtnY = titleY-20;

boolean mouseOverRestartBtn = false;

void playback() {

  noStroke();
  fill(c_black);
  rect(rightX, boxY, boxWidth, boxHeight);
  drawVideo();
  drawFlower();

  drawPlayBtn();
  drawSlider();
  
  drawButton("restart");
  if (mouseOverRestartBtn && mousePressed && currentState != 1) {
    clearMouseOvers();
    video = null;
    currentState = 1;
    rings = new ArrayList<Ring>();
  }
}

void drawPlayBtn() {
  mouseOverPlayBtn = mouseOver(playBtnX, playBtnY, playBtnX+playBtnW, playBtnY+playBtnW);

  if (mouseOverPlayBtn) {
    fill(c_white);
  } else {
    fill(c_background);
  }
  stroke(c_gray);
  rect(playBtnX, playBtnY, playBtnW, playBtnH);

  // icon
  noStroke();
  fill(c_gray);
  if (!paused) {
    rect(playIconX, playIconY, playIconW*0.4, playIconH);
    rect(playIconX+(playIconW*0.75), playIconY, playIconW*0.4, playIconH);
  } else {
    triangle(playIconX, playIconY, playIconX+playIconW+3, playIconY+playIconH/2, playIconX, playIconY+playIconH);
  }

  // press button to toggle pause/play
  if (mousePressed && mouseOverPlayBtn && allowButtonLogic) {
    if (paused) {
      paused = false;
      video.play();
    } else {
      paused = true;
      video.pause();
    }
    allowButtonLogic = false;
    video.jump(video.duration() * currPercentage);
  }
}

void mouseReleased() {
  if (currentState == 4) {
    allowButtonLogic = true;
  }
}

// spacebar pause/play toggle
void keyReleased() {
  if (currentState == 4 &&  key == ' ' && video != null) {
    paused = !paused;
    if (paused) {
      video.pause();
    } else {
      video.play();
    }
    video.jump(video.duration() * currPercentage);
  }
}

void drawVideo() {
  if (video.available()) {
    video.read();
  }
  currPercentage = video.time()/video.duration();
  currPos = sliderWidth * currPercentage + sliderX;
  resizedFrame(boxWidth, boxWidth, rightX, boxY);
}

void drawSlider() {
  noStroke();
  // background behind slider
  fill(c_background);
  rect(sliderX, sliderY-10, sliderWidth+grabberWidth, sliderHeight+20);
  // slider
  fill(color(230));
  rect(sliderX, sliderY, sliderWidth, sliderHeight);

  mouseOverGrabber = mouseOver((int)currPos, sliderY, (int)(currPos + grabberWidth), sliderY+grabberHeight);
  mouseOverSlider = mouseOver(sliderX, sliderY, sliderX + sliderWidth, sliderY+sliderHeight);

  if (mouseOverSlider && mousePressed) {
    // dragging of the slider grabber
    currPos = mouseX;
    // keep the grabber within bounds of the slider
    currPos = Math.max(currPos, sliderX);
    currPos = Math.min(currPos, sliderX+sliderWidth);

    // translate the grabber position into a percentage
    currPercentage = (currPos-sliderX)/(1.0*sliderWidth);
    video.jump(video.duration() * currPercentage);
  }

  // colored portion of slider
  fill(c_btnFill);
  rect(sliderX, sliderY, currPos-sliderX, sliderHeight);

  if (mouseOverGrabber) {
    fill(c_text);
  } else {
    fill(c_gray);
  }

  // slider's grabber
  rect(currPos, sliderY-(grabberHeight/2.0)+(sliderHeight/2.0), grabberWidth, grabberHeight);
}

int drawnLastFrame = 0;
void drawFlower() {
  if (drawnLastFrame == 0) {
    noStroke();
    fill(c_white);
    rect(leftX, boxY, boxWidth, boxHeight);
  }
  int lastRingToDraw = (int)(currPercentage * rings.size());
  if (lastRingToDraw < drawnLastFrame) {
    noStroke();
    fill(c_white);
    rect(leftX, boxY, boxWidth, boxHeight);
    drawnLastFrame = 0;
  }
  for (int i = lastRingToDraw-1; i < rings.size() && i >= drawnLastFrame; i--) {
    drawRing(rings.get(i), 4);
  }
  drawnLastFrame = lastRingToDraw;
}
