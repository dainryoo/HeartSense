/*
 * -------------------------------
 *      INSTRUCTIONS PAGE:
 *     General Instructions
 * -------------------------------
 */

String[] instructionsText = {
  "1. Plug in the XeThru to your laptop's USB port", 
  "2. Plug in the Arduino Due in the socket closest to the power port", 
  "3. Open XeThru Explorer", 
  "4. Select XeThru X2M200", 
  "5. Select Respiration", 
  "6. Change Respiration Settings as under:", 
  "    a. Sensitivity = 5", 
  "    b. LED Control = Full", 
  "    c. Breathing Pattern History = 20", 
  "7. Change Log Settings as under:", 
  "    If you are using the application in its raw form (i.e. if you are not using the .app), the file path", 
  "    under Log Settings should read as:/Users/yourname/Desktop/HeartSense/data/xethru", 
  "    a. Exclude Baseband A/P Output", 
  "    b. Include Breathing Pattern Output", 
  "    c. Wait for XeThru to initialize", 
  "8. If you are running the application in its raw form, open HeartSense.pde", 
  "9. Go to XeThru Explorer and start recording", 
  "10. Hit the Play button in the HeartSense.pde sketch in Processing"
};

void instructions() {
  background(c_background);
  // Background visualization
  for (int i = 0; i < introRings.size(); i++) {
    drawRing(introRings.get(i), 2);
  }
  drawTitle();

  // SUBTITLE
  textAlign(LEFT);
  fill(c_text);
  textSize(subtitleTextSize);
  text("Setup Instructions:", titleX, titleY + 100);

  textSize(bodyTextSize);
  text("PART 1: FOR FIRST TIME USERS", titleX, titleY + 150);
  for (int i = 0; i < instructionsText.length; i++) {
    text(instructionsText[i], titleX, titleY + 180 + (i*bodyTextSize*2));
  }

  stroke(color(160));
  line(WIDTH/2, titleY + 150, WIDTH/2, HEIGHT-100);

  text("PART 2", WIDTH/2 + 70, titleY + 150);
  displaySerialList();
  
  textAlign(CENTER);
  fill(c_text);
  text("MAKE SURE YOU HAVE STARTED XETHRU RECORDING", extraInstructionX-25, extraInstructionY, serialListItemW+50, serialListItemH);
  if (displayErrorMessage) {
    fill(c_red);
    text("Please select a port.", extraInstructionX, extraInstructionY+20, serialListItemW, serialListItemH);
  }

  // START VIDEO BUTTON
  // check if touching Start Video button
  mouseOverStartVideoBtn = mouseOver(startVideoBtnX, startVideoBtnY, startVideoBtnX+startVideoBtnW, startVideoBtnY+startVideoBtnH);
  // draw Back button
  drawButton("startVideo");
  // check if button clicked
  if (mousePressed && mouseOverStartVideoBtn && currentState != 2) {
    if (selectedPort == -1) {
      displayErrorMessage = true;
    } else {
      clearMouseOvers();
      currentState = 2;
      rings = new ArrayList<Ring>();

      if (!portSetupSuccessful) {
        //portSetupSuccessful = setupPort();
      }
      setupVideo();
    }
  }
}

String[] fake = {"fake_serial1", "fake_serial2", "fake_serial3", "fake_serial4"};
int selectedPort = -1;
boolean portSetupSuccessful = false;

boolean mouseOverStartVideoBtn = false;

int choosePortX = WIDTH/2 + 230;
int choosePortY = titleY + 180;
int choosePortW = 270;
int choosePortH = 50;
int serialListX = choosePortX;
int serialListY = choosePortY + choosePortH;
int serialListItemW = choosePortW;
int serialListItemH = 30;
int serialListH = serialListItemH*fake.length+20;
int serialPaddingX = 15;
int serialPaddingY = 10;

int extraInstructionX = choosePortX;
int extraInstructionY = serialListY+serialListH+40; 

int startVideoBtnX = choosePortX;
int startVideoBtnY = titleY + (instructionsText.length*bodyTextSize*2+120);
int startVideoBtnW = choosePortW;
int startVideoBtnH = choosePortH;

boolean displayErrorMessage = false;

void displaySerialList() {
  drawButton("port");
  textAlign(LEFT, CENTER);
  fill(c_gray);
  rect(serialListX+3, serialListY+3, serialListItemW, serialListH, buttonRounding);
  fill(c_white);
  stroke(color(250));
  rect(serialListX, serialListY, serialListItemW, serialListH, buttonRounding);
  textSize(bodyTextSize);
  noStroke();
  // CHANGE TO: for (int i = 0; i < Serial.list().length; i++) {
  for (int i = 0; i < fake.length; i++) {
    if (mouseOver(serialListX, serialListY+i*serialListItemH, serialListX+serialListItemW, serialListY+(i*serialListItemH)+serialListItemH)) {
      fill(c_background);
      if (mousePressed) {
        selectedPort = i;
        displayErrorMessage = false;
      }
    } else {
      noFill();
    }
    rect(serialListX, serialListY + (i*serialListItemH)+serialPaddingY, serialListItemW, serialListItemH);
    if (selectedPort == i) {
      fill(c_btnFill);
    } else {
      fill(c_text);
    }
    // CHANGE fake[i] TO Serial.list()[i]
    text(fake[i], serialListX+serialPaddingX, serialListY+(i*serialListItemH)+serialPaddingY, serialListItemW, serialListItemH);
  }
}
