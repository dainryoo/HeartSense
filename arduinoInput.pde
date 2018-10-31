import processing.serial.*;

Serial port;  // Create object from Serial class
int Sensor;   // Pulse sensor data from Arduino
int lf = 10;  // ASCII linefeed
String IBI;
int oldGSR = 261;

boolean setupPort() {
  try {
    for (int i=0; i<Serial.list().length; i++)
    {
      println(Serial.list()[i]);
    }
    String portName = Serial.list()[0]; // Port usually seems to be 0, but maybe try 1 or 2 or etc. if it doesn't work?
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
  
  try {
    String data = port.readStringUntil('\n'); // ... read it and store it in data

    if (data.charAt(0) == 'R')
    {
      //print("Data: ");
      //println(data);
      data = data.substring(1);
      int tempRPM = (int)parseFloat(data);
      if (tempRPM<50 && tempRPM>0)
        currRPM = tempRPM; 
      //print("RPM: ");
      //println(currRPM);
    } else if (split(data, ",").length>1)
    {
      String[] sensorValues = (split(data, ",")); // cut off white space (carriage return);
      //currIBI = (int)parseFloat(sensorValues[2]);

      int tempBPM = parseInt(sensorValues[0]);
      if (tempBPM>40 && currBPM<180)
        currBPM = tempBPM; 

      int tempGSR = parseInt(sensorValues[1]);
      if (!(tempGSR==362 || tempGSR == 600))
      {
        currGSR =(int)(0.8*currGSR + 0.2*tempGSR);
        //currGSR = tempGSR;
      }
    } 
    else
    {
      println(data);
    }


    //System.out.println(IBI);
    //if (data.charAt(0) == 'S') { // leading 'S' means Pulse Sensor data packet
    //  data = data.substring(1); // cut off the leading 'S'
    //  Sensor = int(data); // convert String to int
    //}
    //if (data.charAt(0) == 'B') { // leading 'B' for BPM data
    //  //println(data);
    //  data = data.substring(1); // cut off the leading 'B'
    //  currBPM = int(data); // convert String to int
    //}
    //if (data.charAt(0) == 'Q') { // leading 'Q' means IBI data
    //  data = data.substring(1); // cut off the leading 'Q'
    //  currIBI = int(data); // convert String to int
    //}
    //if (data.charAt(0) == 'G') { // leading 'G' means GSR data
    //  data = data.substring(1); // cut off the leading 'G'
    //  currGSR = int(data); // convert String to int

    // equation from http://wiki.seeedstudio.com/Grove-GSR_Sensor/
    // Human Resistance = ((1024+2*Serial_Port_Reading)*10000)/(512-Serial_Port_Reading)
    // unit is ohm, Serial_Port_Reading is the value display on Serial Port(between 0~1023)
    // Human Resistance range is [300, 100,000]
    //GSR = ((1024+2*GSR)*10000)/(512-GSR);
    //}
  } 
  catch(Exception e) {
    System.out.println(e.toString());
  }
}
