/* 
 * Ring:
 * Object representing one "layer" of the visualization
 * Holds the values for RPM, BPM, and GSR at that point in time
 */

int MAX_PETAL_HEIGHT = 120;  // Height of the tallest petal (arbitrary)
int MAX_NUM_RINGS = 70;     // Number of rings/layers we want to show up (arbitrary)

class Ring {
  int rpm;
  int bpm;
  int gsr;
  int time;

  Ring(int breathing, int heart, int sweat, int timeStamp) {
    rpm = breathing;
    bpm = heart;
    gsr = sweat;
    time = timeStamp;
  }
}

void addNewRing() {
  //currRPM = (int) random(5, 15);
  //currBPM = (int) random(50, 140);
  //currGSR = (int) random(300, 900);
  Ring newRing = new Ring(currRPM, currBPM, currGSR, counter); // Create an instance of a ring to represent the user's data at this time
  rings.add(newRing);
  System.out.println("RPM: " + currRPM + "    - BPM: " + currBPM + "     - GSR: " + currGSR);
  drawRing(newRing, rings.size()-1); // draw this new layer
}

void drawRing(Ring r, int index) {
  int rpm = r.rpm;
  int bpm = r.bpm;
  int gsr = r.gsr;
  int frame = r.time;

  // Circular base of the ring has radius based on index (the more recent the ring, the greater its index in the ArrayList, and the greater its radius)
  float radius = width/2.0 * index/MAX_NUM_RINGS;
  float cx = width/2.0;  // center of circle
  float cy = height/2.0; // center of circle
  float angleOffset = (index*1.0/MAX_NUM_RINGS) * PI; // add so that not all layers have first petal starting at the same angle
  color petalColor = getColor(gsr);

  // Frequency of "petals" along the circumference depends on bpm
  // The x1,y1, x2,y2 coordinates represent the ends of the bezier curves that make up the ring
  // So the more dots, the more bezier curves on this ring
  int numPetals = (int) bpm/5;
  for (int i = 0; i < numPetals; i++) {
    float angle = (i/ (numPetals/2.0)) * PI + angleOffset;
    float x1 = cx + (radius * cos(angle)); // x-coord of one end of bezier curve
    float y1 = cy + (radius * sin(angle)); // y-coord of one end of bezier curve

    float nextAngle = ((i+1)/ (numPetals/2.0)) * PI + angleOffset;
    float x2 = cx + (radius * cos(nextAngle)); // x-coord of other end of bezier curve
    float y2 = cy + (radius * sin(nextAngle)); // y-coord of other end of bezier curve

    // Petal height depends on RPM
    float petalHeight = MAX_PETAL_HEIGHT * index/MAX_NUM_RINGS * currRPM/15.0;
    float control1X = cx + cos(angle) * (radius+petalHeight); // curve control point 1
    float control1Y = cy + sin(angle) * (radius+petalHeight);
    float control2X = cx + cos(nextAngle) * (radius+petalHeight); // curve control point 2
    float control2Y = cy + sin(nextAngle) * (radius+petalHeight); 

    beginShape();
    //noFill();
    fill(color(petalColor, 10));
    strokeWeight(1);
    stroke(petalColor);
    bezier(x1, y1, control1X, control1Y, control2X, control2Y, x2, y2);
    endShape();
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
