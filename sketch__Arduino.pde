import processing.serial.*;

Serial port;  // Create object from Serial class
int Sensor;   // Pulse sensor data from Arduino
int lf = 10;  // ASCII linefeed

int currRPM = 10; // ARBITRARY values in case sensors don't work
int currBPM = 80;
int currGSR = 200;

float MIN_RPM = 0;
float MAX_RPM = 60;
int MIN_BPM = 30;
int MAX_BPM = 180;
int MIN_GSR = 100;
int MAX_GSR = 2100;


boolean setupPort() {
  try {
    String portName = Serial.list()[selectedPort]; 
    port = new Serial(this, portName, 115200);
    // Throw out the first reading, in case we started reading in the middle of a string from the sender.
    port.clear();
    port.bufferUntil(lf);
    return true;
  } 
  catch (Exception e) {
    System.out.println(e.toString());
    return false;
  }
}

void serialEvent(Serial port) {
  if (portSetupSuccessful) {
    try {
      String data = port.readStringUntil('\n'); // ... read it and store it in data
      if (data.charAt(0) == 'R') {
        data = data.substring(1);
        int tempRPM = (int)parseFloat(data);
        if (tempRPM <= MAX_RPM && tempRPM >= MIN_RPM) {
          currRPM = tempRPM;
        }
      } else if (split(data, ",").length>1) {
        String[] sensorValues = (split(data, ",")); // cut off white space (carriage return)
        int tempBPM = parseInt(sensorValues[0]);
        if (tempBPM <= MAX_BPM && tempBPM >= MIN_BPM) {
          currBPM = tempBPM;
        }

        int tempGSR = parseInt(sensorValues[1]);
        if (tempGSR <= MAX_GSR && tempGSR >= MIN_GSR) {
          currGSR = tempGSR;
        }
      } else {
        println(data);
      }
    } 
    catch(Exception e) {
      System.out.println(e.toString());
    }
  }
}
