import processing.serial.*;

Serial port;  // Create object from Serial class
int Sensor;   // Pulse sensor data from Arduino
int lf = 10;  // ASCII linefeed

boolean setupPort() {
  try {
    for (int i = 0; i < Serial.list().length; i++) {
      println(Serial.list()[i]);
    }
    String portName = Serial.list()[0]; // Port usually seems to be 0, but maybe try 1 or 2 or etc. if it doesn't work?
    port = new Serial(this, portName, 115200);
    // Throw out the first reading, in case we started reading in the middle of a string from the sender.
    port.clear();
    port.bufferUntil(lf);
    return true;
  } catch (Exception e) {
    System.out.println(e.toString());
    return false;
  }
}

void serialEvent(Serial port) {
  try {
    String data = port.readStringUntil('\n'); // ... read it and store it in data
    if (data.charAt(0) == 'R') {
      //print("Data: ");
      //println(data);
      data = data.substring(1);
      int tempRPM = (int)parseFloat(data);
      if (tempRPM<50 && tempRPM>0)
        currRPM = tempRPM; 
      //print("RPM: ");
      //println(currRPM);
    } else if (split(data, ",").length > 1) {
      String[] sensorValues = (split(data, ",")); // cut off white space (carriage return

      int tempBPM = parseInt(sensorValues[0]);
      if (tempBPM>40 && currBPM<180)
        currBPM = tempBPM; 

      int tempGSR = parseInt(sensorValues[1]);
      if (!(tempGSR==362 || tempGSR == 600)) {
        currGSR =(int)(0.8*currGSR + 0.2*tempGSR);
      }
    } else {
      println(data);
    }
  } catch(Exception e) {
    System.out.println(e.toString());
  }
}
