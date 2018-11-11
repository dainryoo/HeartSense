class Ring {
  int rpm;
  int bpm;
  int gsr;
  float percentage;
  
  Ring(int breath, int heart, int sweat, float percent) {
    rpm = breath;
    bpm = heart;
    gsr = sweat;
    percentage = percent;
  }
}
