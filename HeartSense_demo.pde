int IBI;      // Time between heartbeats from Arduino
int BPM;      // Heart Rate value from Arduino
int GSR;      // GSR value from Arduino

class Ring {
  float ibi;
  int bpm;
  int gsr;

  Ring(float heartVariability, int heart, int sweat) {
    ibi = heartVariability;
    bpm = heart;
    gsr = sweat;
  }
}

// Holds rings from earliest -> most recent
ArrayList<Ring> rings = new ArrayList<Ring>();

void setup() {
  size(640, 640);
  frameRate(30);
  setupPort();
}

void draw() {
  // Every 40 frames, until frame 900, create a new ring and add it to the rings ArrayList
  if (frameCount%40 == 0 && frameCount < 900) {
    // Limit IBI to [10, 100]
    IBI = max(IBI, 10);
    IBI = min(IBI, 100);

    // Limit BPM to [40, 200]
    BPM = max(BPM, 40);
    BPM = min(BPM, 200);

    // Limit GSR to [0, 1023]
    GSR = max(GSR, 0);
    GSR = min(GSR, 1023);

    System.out.println("IBI: " + IBI + "      - BPM: " + BPM + "          - GSR: " + GSR); 
    Ring newRing = new Ring(IBI, BPM, GSR);

    rings.add(newRing);
  }

  // Draw white background
  background(255);
  // Set shapes as no-fill (only stroke)
  noFill();

  // Draw each ring in the rings ArrayList
  for (int i = 0; i < rings.size(); i++) {
    // Get the current ring
    Ring currRing = rings.get(i);
    // Draw the current ring
    // TODO
  }
}
