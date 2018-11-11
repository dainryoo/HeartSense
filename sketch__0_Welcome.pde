/*
 * -------------------------------
 *         WELCOME PAGE:
 * User is greeted into HeartSense
 * -------------------------------
 */

int titleX = (int) (WIDTH * (0.065));
int titleY = (int) (HEIGHT * (0.12));

int startBtnX = (int) (WIDTH * (0.068));
int startBtnY = (int) (HEIGHT * (0.75));
int startBtnW = 240;
int startBtnH = 50;

boolean mouseOverStartBtn = false;
boolean mouseOverFirstTimeBtn = false;

String[] welcomeText = {
  "By creating, visualizing, and encouraging reflection on",
  "circumscribed datasets, we strive to approach physio-",
  "logical data for its capacity to inspire an alternative",
  "epistemological and experimental engagement from",
  "either standard scientific visualization or the quantified",
  "self.",
  "",
  "Ours is an object oriented feminist approach: \"in light",
  "of a specific and particular materiality to hand, what if",
  "we see the world like this?\""
};

void drawTitle() {
  textAlign(LEFT);
  fill(c_text);
  textSize(titleTextSize);
  text("Heart Sense", titleX, titleY);
  textSize(bodyTextSize);
  text("Reflections on Physiology and Embodiment", titleX, titleY+(titleTextSize));
  
  textAlign(RIGHT);
  textSize(11);
  text("© Design and Social Interaction Studio", WIDTH-35, HEIGHT-35);
  
  image(logo, WIDTH/2-(logo.width/2), titleY-(logo.height/2));
}

void welcome() {
  background(c_background);
  // Background visualization
  for (int i = 0; i < introRings.size(); i++) {
    drawRing(introRings.get(i), 0);
  }
  drawTitle();
  
  textAlign(LEFT);
  textSize(bodyTextSize);
  for (int i = 0; i < welcomeText.length; i++) {
    text(welcomeText[i], titleX, 240+(i*bodyTextSize*2));
  }
 
  // START BUTTON
  // check if touching Start button
  mouseOverStartBtn = mouseOver(startBtnX, startBtnY, startBtnX+startBtnW, startBtnY+startBtnH);

  // draw Start button
  drawButton("start");

  // check if button clicked
  if (mouseOverStartBtn && mousePressed && currentState != 1) {
    currentState = 1;
  }
}
