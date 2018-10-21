color colors[] = {
  color(139, 0, 0), // dark red (-inf, 50)
  color(234, 35, 0), // red [50, 60)
  color(255, 105, 3), // orange [60, 70)
  color(255, 202, 30), // yellow [70, 80)
  color(108, 242, 50), // yellow-green [80, 90)
  color(6, 214, 23), // green [90, 100)
  color(13, 216, 186), // green-blue [100, 110)
  color(66, 201, 255), // light blue [110, 120)
  color(33, 90, 211), // dark blue [120, 130)
  color(81, 7, 198) // purple [130, inf)
};

color getColor(int gsr) {
  color colorIndex = 0;
  float distFromMidValue = 0.0;
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
}
