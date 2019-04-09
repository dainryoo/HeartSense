class Ring {
  float rpm;
  int bpm;
  int gsr;
  float percentage;

  Ring(float breath, int heart, int sweat, float percent) {
    rpm = breath;
    bpm = heart;
    gsr = sweat;
    percentage = percent;
  }
}

void drawRing(Ring r, int screen) {
  float p = r.percentage;
  color c = getColor(r.gsr);
  noFill();
  stroke(c);

  int flowerCenterX = 0; 
  int flowerCenterY = 0; 
  int flowerMaxRadius = 0;

  if (screen == 4) {
    flowerCenterX = (leftX + boxWidth/2); 
    flowerCenterY = (boxY + boxWidth/2); 
    flowerMaxRadius = boxWidth/2-50; // padding of 100 around the flower
  } else if (screen == 3) {
    flowerCenterX = flowerAreaW/2 + flowerAreaX;
    flowerCenterY = flowerAreaH/2 + flowerAreaY;
    flowerMaxRadius = flowerAreaH/2 - 20;
  } else {
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
      angleOffset = 0;//(TWO_PI * p);
    }
    float angle = (i/ (numPetals/2.0)) * PI + angleOffset;
    float x1 = flowerCenterX + (radius * cos(angle)); // x-coord of one end of bezier curve
    float y1 = flowerCenterY + (radius * sin(angle)); // y-coord of one end of bezier curve

    float nextAngle = ((i+1)/ (numPetals/2.0)) * PI + angleOffset;
    float x2 = flowerCenterX + (radius * cos(nextAngle)); // x-coord of other end of bezier curve
    float y2 = flowerCenterY + (radius * sin(nextAngle)); // y-coord of other end of bezier curve

    // Petal height depends on RPM
    float petalHeight = (MAX_PETAL_HEIGHT * p) * (r.rpm-MIN_IBI)/(MAX_IBI-MIN_IBI) * IBI_HEIGHT_EFFECT;
    if (screen < 3) {
      petalHeight *= 6;
    }
    float control1X = flowerCenterX + cos(angle) * (radius+petalHeight); // curve control point 1
    float control1Y = flowerCenterY + sin(angle) * (radius+petalHeight);
    float control2X = flowerCenterX + cos(nextAngle) * (radius+petalHeight); // curve control point 2
    float control2Y = flowerCenterY + sin(nextAngle) * (radius+petalHeight); 

    beginShape();
    noFill();
    strokeWeight(1.5);
    color petalColor = color(red(c), blue(c), green(c), 70);
    fill(color(petalColor, 10));
    strokeWeight(1.5);
    stroke(c);
    if (screen < 3) {
      strokeWeight(3);
      stroke(c, 20);
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
