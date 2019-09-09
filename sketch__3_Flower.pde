/*
 * -------------------------------
 *          Flower PAGE:
 *     Just the flower plays
 *      for the first time
 * -------------------------------
 */

int flowerAreaX = videoAreaX;
int flowerAreaY = videoAreaY;
int flowerAreaW = videoAreaW;
int flowerAreaH = videoAreaH;

int replayBtnW = 200;
int replayBtnH = 50;
int replayBtnX = flowerAreaX+flowerAreaW-replayBtnW-10;
int replayBtnY = flowerAreaY+flowerAreaH-(replayBtnH*2)-20;

int playbackBtnW = replayBtnW;
int playbackBtnH = replayBtnH;
int playbackBtnX = replayBtnX;
int playbackBtnY = replayBtnY + replayBtnH + 10;

int saveBtnW = replayBtnW;
int saveBtnH = replayBtnH;
int saveBtnX = replayBtnX;
int saveBtnY = replayBtnY + replayBtnH + 30;

boolean mouseOverReplayBtn = false;
boolean mouseOverPlaybackBtn = false;
boolean mouseOverSaveBtn = false;
boolean flowerOver = false;

int currRing = 0;

void playFlower() {
  // FLOWER
  if (!flowerOver) {
    drawRing(rings.get(currRing), 3);
    currRing++;
    if (currRing >= rings.size()) {
      flowerOver = true;
    }
  } else {
    drawButton("replay");
    drawButton("playback");
    drawButton("print");
    
    if (mouseOverReplayBtn && mousePressed) {
      clearMouseOvers();
      fill(c_white);
      rect(videoAreaX, videoAreaY, videoAreaW, videoAreaH);
      currRing = 0;
      flowerOver = false;
    } else if (mouseOverPlaybackBtn && mousePressed && currentState != 4) {
      /*getDataFromCSVFile();
      while(!gotXethruData){
        //wait till we are done reading the XeThru data file
      }*/
      int imageLeftCoord = 450;
      int imageTopCoord = 175;
      PImage heartImage = get(imageLeftCoord,imageTopCoord,(flowerAreaH), (flowerAreaH));
      String imageName = String.format("%02d", month())
                    + String.format("%02d", day())
                    + "_"
                    + String.format("%02d", hour())
                    + String.format("%02d", minute());
      heartImage.save("/flowers/" + imageName + ".jpg");
      
      clearMouseOvers();
      currRing = 0;
      currPos = sliderX; // put grabber at the beginning of the slider
      drawnLastFrame = 0;
      currentState = 4;
      video.playbin.setVolume(0);      
      video.jump(0);
      paused = false;
    }
  }
}
