/*
 * -------------------------------
 *      INSTRUCTIONS PAGE:
 *     General Instructions
 * -------------------------------
 */

String[] instructions1Text = {
  "1. Plug in the XeThru to your laptop's USB port", 
  "2. Plug in the Arduino Due in the socket closest to the Arduino's power port", 
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

String[] instructions2Text = {
  "1. MAKE SURE XETHRU SENSOR IS PLUGGED IN",
  "2. UNPLUG AND REPLUG ARDUINO",
  "3. START XETHRU RECORDING"
};

boolean mouseOverStartVideoBtn = false;
int startVideoBtnX = WIDTH/2 + 70;
int startVideoBtnY = HEIGHT-160;
int startVideoBtnW = 270;
int startVideoBtnH = 50;

boolean portSetupSuccessful = false;

void instructions() {
  background(c_background);
  // Background visualization
  for (int i = 0; i < introRings.size(); i++) {
    drawRing(introRings.get(i), 2);
  }
  drawTitle();

  textAlign(LEFT);
  fill(c_text);
  textSize(titleTextSize);
  text("Setup Instructions:", titleX, titleY + 100);

  textSize(bodyTextSize);
  text("PART 1: FOR FIRST TIME USERS", titleX, titleY + 150);
  for (int i = 0; i < instructions1Text.length; i++) {
    text(instructions1Text[i], titleX, titleY + 180 + (i*bodyTextSize*2));
  }

  stroke(color(160));
  line(WIDTH/2, titleY + 120, WIDTH/2, HEIGHT-90);

  text("PART 2", startVideoBtnX, titleY + 150);
  for(int i = 0; i < instructions2Text.length; i++) {
    text(instructions2Text[i], WIDTH/2 + 70, titleY + 180 + (i*bodyTextSize*2));
  }

  drawButton("startVideo");
  if (mousePressed && mouseOverStartVideoBtn && currentState != 2) {
      clearMouseOvers();
      currentState = 2;
      rings = new ArrayList<Ring>();
      
      if (!portSetupSuccessful) {
        portSetupSuccessful = setupPort();
      }
      
      setupVideo();
      resetMinMax();
  }
}
