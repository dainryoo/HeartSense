#define USE_ARDUINO_INTERRUPTS true 
#include <PulseSensorPlayground.h>
const int OUTPUT_TYPE = PROCESSING_VISUALIZER; 
// const int OUTPUT_TYPE = SERIAL_PLOTTER;

const int PULSE_INPUT = A1; // PURPLE WIRE
const int PULSE_BLINK = 13; // Pin 13 is the on-board LED
const int PULSE_FADE = 5;
const int THRESHOLD = 550; // Adjust this number to avoid noise when idle
PulseSensorPlayground pulseSensor;

const int GSR_INPUT = A3; // GSR signal

void setup() {
  Serial.begin(115200); // Use 115200 baud because that's what the Processing Sketch expects to read
  pinMode(GSR_INPUT, INPUT); // from GSR code..

  // Configure the PulseSensor manager.
  pulseSensor.analogInput(PULSE_INPUT);
  pulseSensor.blinkOnPulse(PULSE_BLINK);
  pulseSensor.fadeOnPulse(PULSE_FADE);

  pulseSensor.setSerial(Serial);
  pulseSensor.setOutputType(OUTPUT_TYPE);
  pulseSensor.setThreshold(THRESHOLD);

  // Start reading the PulseSensor signal.
  if (!pulseSensor.begin()) { // PulseSensor initialization failed, likely because right now interrupts aren't supported
    // If Sketch hangs here, try PulseSensor_BPM_Alternative.ino, which doesn't use interrupts.
    for(;;) {
      digitalWrite(PULSE_BLINK, LOW);
      delay(50);
      digitalWrite(PULSE_BLINK, HIGH);
      delay(50);
    }
  }
}

void loop() {
  
  delay(20); // Wait a bit. Don't output every sample, because our baud rate won't support that much I/O.
  // Write the latest sample to Serial.
  pulseSensor.outputSample();
  if (pulseSensor.sawStartOfBeat()) {
    pulseSensor.outputBeat();
  }
  
  delay(100);
  int gsrSignal = analogRead(GSR_INPUT);
  Serial.println('G' + String(gsrSignal)); // Send to processing in the form of G + the signal
}
