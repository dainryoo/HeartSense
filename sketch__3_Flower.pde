/*
 * -------------------------------
 *          FLOWER PAGE:
 *     Shows video and flower
 *         side by side
 * -------------------------------
 */

boolean paused = false;

ArrayList<Ring> rings;

int MAX_RINGS = 60;
int MIN_PETALS = 15;
int MAX_PETALS = 40;

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

void flower() {

  noStroke();
  fill(c_black);
  rect(rightX, boxY, boxWidth, boxHeight);
  drawVideo();

  drawFlower();

  drawPlayBtn();
  drawSlider();
  drawButton("restart");

  // check if button clicked
  if (mouseOverRestartBtn && mousePressed && currentState != 2) {
    clearMouseOvers();
    video.volume(1);
    video.pause();
    setupVideo();
    currentState = 2;
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
  allowButtonLogic = true;
}

// spacebar pause/play toggle
void keyReleased() {
  if (key == ' ' && video != null) {
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
    video.volume(0);
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

void drawRing(Ring r, int screen) {
  float p = r.percentage;
  color c = getColor(r.gsr);
  noFill();
  stroke(c);

  int flowerCenterX = (leftX + boxWidth/2); 
  int flowerCenterY = (boxY + boxWidth/2); 
  int flowerMaxRadius = boxWidth/2-50; // padding of 100 around the flower

  if (screen < 4) {
    flowerCenterX = WIDTH-100;
    flowerCenterY = HEIGHT-100;
    flowerMaxRadius = WIDTH/2;
  }

  float radius = (flowerMaxRadius*p);
  //ellipse(flowerCenterX, flowerCenterY, radius*2, radius*2);

  // frequency of petals around the circumference
  // https://rosettacode.org/wiki/Map_range
  int numPetals = MIN_PETALS + (r.bpm-MIN_BPM)*(MAX_PETALS-MIN_PETALS)/(MAX_BPM-MIN_BPM);
  for (int i = 0; i < numPetals; i++) {
    float angleOffset = 0;
    if (screen < 3) {
      angleOffset = (frameCount*PI*p*0.001);
    } else {
      angleOffset = (TWO_PI * p);
    }
    float angle = (i/ (numPetals/2.0)) * PI + angleOffset;
    float x1 = flowerCenterX + (radius * cos(angle)); // x-coord of one end of bezier curve
    float y1 = flowerCenterY + (radius * sin(angle)); // y-coord of one end of bezier curve

    float nextAngle = ((i+1)/ (numPetals/2.0)) * PI + angleOffset;
    float x2 = flowerCenterX + (radius * cos(nextAngle)); // x-coord of other end of bezier curve
    float y2 = flowerCenterY + (radius * sin(nextAngle)); // y-coord of other end of bezier curve

    // Petal height depends on RPM
    float petalHeight = (100 * p) * (r.rpm-MIN_RPM)/(MAX_RPM-MIN_RPM) * 0.3; // 100*p is the max height, 0.5 is the effect of the rpm on height
    if (screen < 3) {
      petalHeight *= 6;
    }
    float control1X = flowerCenterX + cos(angle) * (radius+petalHeight); // curve control point 1
    float control1Y = flowerCenterY + sin(angle) * (radius+petalHeight);
    float control2X = flowerCenterX + cos(nextAngle) * (radius+petalHeight); // curve control point 2
    float control2Y = flowerCenterY + sin(nextAngle) * (radius+petalHeight); 

    beginShape();
    noFill();
    strokeWeight(1);
    stroke(c);
    if (screen < 3) {
      strokeWeight(3);
      stroke(c, 10);
    }
    bezier(x1, y1, control1X, control1Y, control2X, control2Y, x2, y2);
    endShape();
    strokeWeight(1);
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
