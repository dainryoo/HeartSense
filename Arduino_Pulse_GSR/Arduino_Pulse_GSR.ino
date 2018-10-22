/*
  PulseSensor Tutorial: https://pulsesensor.com/pages/getting-advanced
  GSR Arduino code by Chris Smith
*/

#define USE_ARDUINO_INTERRUPTS true // tells the library to use interrupts to automatically read and process PulseSensor data.
#include <PulseSensorPlayground.h>
const int OUTPUT_TYPE = PROCESSING_VISUALIZER; // The format of our output.
/*
  PULSE_INPUT = Analog Input. Connected to the pulse sensor purple (signal) wire.
  PULSE_BLINK = digital Output. Connected to an LED (and 220 ohm resistor) that will flash on each detected pulse.
  PULSE_FADE = digital Output. PWM pin onnected to an LED (and resistor) that will smoothly fade with each pulse. 
  NOTE: PULSE_FADE must be a pin that supports PWM. Do not use pin 9 or 10, because those pins' PWM interferes with the sample timer.
*/
const int PULSE_INPUT = A0;
const int PULSE_BLINK = 13; // Pin 13 is the on-board LED
const int PULSE_FADE = 5;
const int THRESHOLD = 550; // Adjust this number to avoid noise when idle
PulseSensorPlayground pulseSensor;

const int GSR_INPUT = A3; // GSR signal

void setup() {
  Serial.begin(115200); // Use 115200 baud because that's what the Processing Sketch expects to read, and because that speed provides about 11 bytes per millisecond.
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
      // Flash the led to show things didn't work.
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
  if (pulseSensor.sawStartOfBeat()) { // If a beat has happened since we last checked, ...
    // ... write the per-beat information to Serial.
    pulseSensor.outputBeat();
  }

  delay(100); // added delay because Serial output of pulse and GSR might be affecting each other?
  int gsrSignal = analogRead(GSR_INPUT);
  Serial.println('G' + String(gsrSignal)); // Send to processing in the form of G + the signal
}
