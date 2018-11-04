/* 
 * Ring:
 * Object representing one "layer" of the visualization
 * Holds the values for RPM, BPM, and GSR at that point in time
 */

int MAX_PETAL_HEIGHT = 100;  // Height of the tallest petal (arbitrary)
int MAX_NUM_RINGS = 250;     // Number of rings/layers we want to show up (arbitrary)

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
  currRPM = (int) random(5, 15);
  currBPM = (int) random(50, 140);
  currGSR = (int) random(300, 900);
  Ring newRing = new Ring(currRPM, currBPM, currGSR, counter); // Create an instance of a ring to represent the user's data at this time
  rings.add(newRing);
  //System.out.println("RPM: " + currRPM + "    - BPM: " + currBPM + "     - GSR: " + currGSR);
  drawRing(newRing, rings.size()-1); // draw this new layer
}

void drawRing(Ring r, int index) {
  int rpm = r.rpm;
  int bpm = r.bpm;
  int gsr = r.gsr;
  int frame = r.time;

  // Circular base of the ring has radius based on index (the more recent the ring, the greater its index in the ArrayList, and the greater its radius)
  //float radius = width*(video.time()/video.duration()); // 6 is arbitrary
  float radius = index*10;
  float cx = width/2.0;  // center of circle
  float cy = height/2.0; // center of circle
  // ellipse(cx, cy, radius, radius);

  // Frequency of "petals" along the circumference depends on bpm
  // The x1,y1, x2,y2 coordinates represent the ends of the bezier curves that make up the ring
  // So the more dots, the more bezier curves on this ring
  int numPetals = 20;
  //ellipse(cx, cy, radius, radius);
  for (int i = 0; i < numPetals; i++) {
    float angle = (i * TWO_PI / numPetals) + frame/100; 
    // index*0.1 is purely for aesthetics: adds an extra bit to the angle so that all the petals don't all start at the same angle 
    float x1 = cx + cos(angle) * radius; // one end of curve
    float y1 = cy + sin(angle) * radius; 

    float nextAngle;
    if (i == numPetals) {
      nextAngle = TWO_PI / numPetals + frame/100;
    } else {
      nextAngle = (i+1) * TWO_PI / numPetals + frame/100;
    }
    float x2 = cx + cos(nextAngle) * radius; // other end of curve
    float y2 = cy + sin(nextAngle) * radius;


    // Petal height depends on RPM
    float petalHeight = MAX_PETAL_HEIGHT * frame/MAX_NUM_RINGS;
    float control1X = cx + cos(angle) * (radius+petalHeight); // curve control point
    float control1Y = cy + sin(angle) * (radius+petalHeight);
    float control2X = cx + cos(nextAngle) * (radius+petalHeight); // curve control point
    float control2Y = cy + sin(nextAngle) * (radius+petalHeight); 

    // Petal color depends on GSR
    beginShape();
    noFill();
    //fill(color(255, 255, 255), 255*0.01);
    color petalColor = getColor(gsr);
    //fill(petalColor, 255*0.03);
    stroke(petalColor);
    strokeWeight(1);
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
