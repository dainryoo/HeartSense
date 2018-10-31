/*color colors[] = {
  color(139, 0, 0), // dark red (-inf, 50)
  color(234, 35, 0), // red [50, 60)
  color(255, 105, 3), // orange [60, 70)
  color(255, 202, 30), // yellow [70, 80)
  color(108, 242, 50), // yellow-green [80, 90)
  color(6, 214, 23), // green [90, 100) (120ish)
  color(13, 216, 186), // green-blue [100, 110)
  color(66, 201, 255), // light blue [110, 120)
  color(33, 90, 211), // dark blue [120, 130)
  color(81, 7, 198) // purple [130, inf)
};*/


color colors[] = 
{
  color(0,0,143.4375),
  color(0,0,159.375),
  color(0,0,175.3125),
  color(0,0,191.25),
  color(0,0,207.1875),
  color(0,0,223.125),
  color(0,0,239.0625),
  color(0,0,255),
  color(0,15.9375,255),
  color(0,31.875,255),
  color(0,47.8125,255),
  color(0,63.75,255),
  color(0,79.6875,255),
  color(0,95.625,255),
  color(0,111.5625,255),
  color(0,127.5,255),
  color(0,143.4375,255),
  color(0,159.375,255),
  color(0,175.3125,255),
  color(0,191.25,255),
  color(0,207.1875,255),
  color(0,223.125,255),
  color(0,239.0625,255),
  color(0,255,255),
  color(15.9375,255,239.0625),
  color(31.875,255,223.125),
  color(47.8125,255,207.1875),
  color(63.75,255,191.25),
  color(79.6875,255,175.3125),
  color(95.625,255,159.375),
  color(111.5625,255,143.4375),
  color(127.5,255,127.5),
  color(143.4375,255,111.5625),
  color(159.375,255,95.625),
  color(175.3125,255,79.6875),
  color(191.25,255,63.75),
  color(207.1875,255,47.8125),
  color(223.125,255,31.875),
  color(239.0625,255,15.9375),
  color(255,255,0),
  color(255,239.0625,0),
  color(255,223.125,0),
  color(255,207.1875,0),
  color(255,191.25,0),
  color(255,175.3125,0),
  color(255,159.375,0),
  color(255,143.4375,0),
  color(255,127.5,0),
  color(255,111.5625,0),
  color(255,95.625,0),
  color(255,79.6875,0),
  color(255,63.75,0),
  color(255,47.8125,0),
  color(255,31.875,0),
  color(255,15.9375,0),
  color(255,0,0),
  color(239.0625,0,0),
  color(223.125,0,0),
  color(207.1875,0,0),
  color(191.25,0,0),
  color(175.3125,0,0),
  color(159.375,0,0),
  color(143.4375,0,0),
  color(127.5,0,0)
};

// map GSR from 261-517 to color (0-63) // TODO
color getColor(int gsr) {
  return colors[(int) (((gsr-300) / 10))];
  //return colors[0];
}

/*color getColor(int gsr) {
  color colorIndex = 0;
  float distFromMidValue = 0.0;
  gsr = gsr/3;
  if (gsr < 50) {
    colorIndex = 0;
  } else if (gsr < 60) {
    colorIndex = 1;
    distFromMidValue = (gsr - 55);
  }  else if (gsr < 70) {
    colorIndex = 2;
    distFromMidValue = (gsr - 65);
  }  else if (gsr < 80) {
    colorIndex = 3;
    distFromMidValue = (gsr - 75);
  }  else if (gsr < 90) {
    colorIndex = 4;
    distFromMidValue = (gsr - 85);
  }  else if (gsr < 100) {
    colorIndex = 5;
    distFromMidValue = (gsr - 95);
  }  else if (gsr < 110) {
    colorIndex = 6;
    distFromMidValue = (gsr - 105);
  }  else if (gsr < 120) {
    colorIndex = 7;
    distFromMidValue = (gsr - 115);
  }  else if (gsr < 130) {
    colorIndex = 8;
    distFromMidValue = (gsr - 125);
  } else {
    colorIndex = 9;
  }
  color finalColor = colors[colorIndex];
  if (distFromMidValue < 0) {
    finalColor = getColorWeightedAvg(colors[colorIndex-1], 
    colors[colorIndex], 1+(distFromMidValue/10.0)); 
  } else if (distFromMidValue > 0) {
    finalColor = getColorWeightedAvg(colors[colorIndex], 
    colors[colorIndex+1], distFromMidValue/10.0); 
  }
  return finalColor;
}

color getColorWeightedAvg(color c1, color c2, float weight) {
  float r1 = (c1 >> 16) & 0xFF;
  float g1 = (c1 >> 8) & 0xFF;
  float b1 = c1 & 0xFF; 
  float r2 = (c2 >> 16) & 0xFF;
  float g2 = (c2 >> 8) & 0xFF;
  float b2 = c2 & 0xFF;
  float r = (r1 * weight) + (r2 * (1-weight));
  float g = (g1 * weight) + (g2 * (1-weight));
  float b = (b1 * weight) + (b2 * (1-weight)); 
  return color(r, g, b);
}*/
