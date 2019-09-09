/* 
 *  THE ARDUINO LAYOUT:
 *  
 *  Heart Sensor:
 *      - red: 5V
 *      - black: GND
 *      - purple: A1
 *  
 *  LEDs: (breadboard -> Arduino)
 *      - red wire: a14 -> ~11
 *      - blue wire: a21 -> ~6
 *      - black wire: +18 (on the right side of breadboard) -> GND (on the right side of Arduino)
 *    
 *        (breadboard -> breadboard)
 *      - weird blue spidery wire: c14 -> g14
 *      - weird blue spidery wire: c21 -> h21
 *      - red LED: i14 -> +15 (right side)
 *      - blue LED: i21 -> +24 (right side)
 */

#define USE_ARDUINO_INTERRUPTS true    // Set-up low-level interrupts for most acurate BPM math.
#include <PulseSensorPlayground.h>     // Includes the PulseSensorPlayground Library.   

//  Variables
const int PulseWire = 1;       // PulseSensor PURPLE WIRE connected to ANALOG PIN 1
//const int LED_PIN = 11;          // The on-board Arduino LED, close to PIN 11
const int BLUE_LED = 6;
const int RED_LED = 11;
int Threshold = 550;           // Determine which Signal to "count as a beat" and which to ignore.
// Use the "Gettting Started Project" to fine-tune Threshold Value beyond default setting.
// Otherwise leave the default "550" value.

PulseSensorPlayground pulseSensor;  // Creates an instance of the PulseSensorPlayground object called "pulseSensor"

int prevBPM;
int changeBPM;

int brightness;
int fadeAmount = 5;    // how many points to fade the LED by



void setup() {
  Serial.begin(9600);          // For Serial Monitor

  // Configure the PulseSensor object, by assigning our variables to it.
  pulseSensor.analogInput(PulseWire);
  //pulseSensor.blinkOnPulse(LED_PIN);       //auto-magically blink Arduino's LED with heartbeat.
  pulseSensor.setThreshold(Threshold);

  // Double-check the "pulseSensor" object was created and "began" seeing a signal.
  if (pulseSensor.begin()) {
    Serial.println("We created a pulseSensor Object !");  //This prints one time at Arduino power-up,  or on Arduino reset.
  }

  prevBPM = -1;
  changeBPM = 0;

  //pinMode(LED_PIN, OUTPUT);
  pinMode(BLUE_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);

  brightness = 140;
}

// the loop routine runs over and over again forever:
void loop() {
  int myBPM = pulseSensor.getBeatsPerMinute();  // Calls function on our pulseSensor object that returns BPM as an "int".

  if (pulseSensor.sawStartOfBeat()) {
    if (prevBPM != -1) {
      changeBPM = myBPM - prevBPM;
    }
    Serial.print("Change in BPM: ");
    Serial.println(changeBPM);
    prevBPM = myBPM;
  } else {
    changeBPM = 0;
  }

  //Serial.print("  Change in brightness:");
  //Serial.print(brightness);

  int changeBrightness = changeBPM * 10;
  if (brightness + changeBrightness >= 0 && brightness + changeBrightness <= 255) {
    brightness = brightness + changeBrightness;
  }

  //analogWrite(LED_PIN, brightness);
  if (changeBPM < 0) {
    analogWrite(BLUE_LED, 255);
    analogWrite(RED_LED, 0);
  } else if (changeBPM > 0) {
    analogWrite(RED_LED, 255);
    analogWrite(BLUE_LED, 0);
  } else {
    analogWrite(RED_LED, 0);
    analogWrite(BLUE_LED, 0);
  }

  //Serial.print(" ->  ");
  //Serial.println(brightness);


  // wait for 30 milliseconds to see the dimming effect
  delay(1000);
}
