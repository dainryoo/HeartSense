
// Written by Øyvind Nydal Dahl
//// www.build-electronic-circuits.com
//// August 2016
//
//
//
//// Radar constants
const unsigned char xt_start = 0x7D;
const unsigned char xt_stop = 0x7E;
const unsigned char xt_escape = 0x7F;

const unsigned char xts_spc_appcommand = 0x10;
const unsigned char xts_spc_mod_setmode = 0x20;
const unsigned char xts_spc_mod_loadapp = 0x21;
const unsigned char xts_spc_mod_reset = 0x22;
const unsigned char xts_spc_mod_setledcontrol = 0x24;

const unsigned char xts_spca_set = 0x10;

const unsigned char xts_spr_appdata = 0x50;
const unsigned char xts_spr_system = 0x30;
const unsigned char xts_spr_ack = 0x10;

const unsigned char xts_spc_dir_command = 0x90;
const unsigned char xts_sdc_app_setint = 0x71;
const unsigned char xts_sdc_comm_setbaudrate = 0x80;

const unsigned long xts_id_detection_zone = 0x96a10a1c;
const unsigned long xts_id_sensitivity = 0x10a5112b;

const unsigned long xts_id_app_resp = 0x1423a2d6;
const unsigned long xts_id_app_sleep = 0x00f17b17;
const unsigned long xts_id_resp_status = 0x2375fe26;
const unsigned long xts_id_sleep_status = 0x2375a16c;

const unsigned long xts_id_baseband_iq = 0x0000000c;
const unsigned long xts_id_baseband_amplitude_phase = 0x0000000d;

const unsigned long xts_sacr_outputbaseband = 0x00000010;
const unsigned long xts_sacr_id_baseband_output_off = 0x00000000;
const unsigned long xts_sacr_id_baseband_output_amplitude_phase = 0x00000002;

const unsigned char xts_sm_run = 0x01;
const unsigned char xts_sm_normal = 0x10;
const unsigned char xts_sm_idle = 0x11;

const unsigned char xts_sprs_booting = 0x10;
const unsigned char xts_sprs_ready = 0x11;


#define BASEBAND_NUM_OF_BINS_MAX 52
#define RX_BUF_LENGTH 512
#define TX_BUF_LENGTH 48


//#define XTS_ID_SLEEP_STATUS                             (uint32_t)0x2375a16c
//#define XTS_ID_RESP_STATUS                              (uint32_t)0x2375fe26
//#define XTS_ID_RESPIRATION_MOVINGLIST                   (uint32_t)0x610a3b00
//#define XTS_ID_RESPIRATION_DETECTIONLIST                (uint32_t)0x610a3b02
//#define XTS_ID_APP_RESPIRATION_2                        (uint32_t)0x064e57ad
//#define XTS_ID_DETECTION_ZONE                           (uint32_t)0x96a10a1c
//#define XTS_ID_SENSITIVITY                              (uint32_t)0x10a5112b

#define XTS_VAL_RESP_STATE_BREATHING      0x00 // Valid RPM sensing
#define XTS_VAL_RESP_STATE_MOVEMENT       0x01 // Detects motion, but can not identify breath
#define XTS_VAL_RESP_STATE_MOVEMENT_TRACKING  0x02 // Detects motion, possible breathing soon
#define XTS_VAL_RESP_STATE_NO_MOVEMENT      0x03 // No movement detected
#define XTS_VAL_RESP_STATE_INITIALIZING     0x04 // Initializing sensor
#define XTS_VAL_RESP_STATE_ERROR        0x05 // Sensor has detected some problem. StatusValue indicates problem.
#define XTS_VAL_RESP_STATE_UNKNOWN        0x06 // Undefined state.

unsigned char recv_buf[RX_BUF_LENGTH]; // Buffer for receiving data from radar
unsigned char send_buf[TX_BUF_LENGTH]; // Buffer for sending data to radar

typedef struct xtDatamsgBasebandAP_header
{
  uint32_t frameCtr;
  uint32_t numOfBins;
  float binLength;
  float samplingFrequency;
  uint32_t carrierFrequency;
  float rangeOffset;
  // Amplitude buffer, numOfBins length.
  // Phase buffer, nomOfBins length.
} xtDatamsgBasebandAP_header_t;

// Setting default argument for receive data
int receive_data(bool print_data = false);

int rpm;
float dis, mov;

//---------------PULSE AND GSR SENSOR INITIALIZATION--------------------

#define USE_ARDUINO_INTERRUPTS false
#include <PulseSensorPlayground.h>

/*
   The format of our output.

   Set this to PROCESSING_VISUALIZER if you're going to run
    the Processing Visualizer Sketch.
    See https://github.com/WorldFamousElectronics/PulseSensor_Amped_Processing_Visualizer

   Set this to SERIAL_PLOTTER if you're going to run
    the Arduino IDE's Serial Plotter.
*/
const int OUTPUT_TYPE = SERIAL_PLOTTER;

/*
   Pinout:
     PULSE_INPUT = Analog Input. Connected to the pulse sensor
      purple (signal) wire.
     PULSE_BLINK = digital Output. Connected to an LED (and 220 ohm resistor)
      that will flash on each detected pulse.
     PULSE_FADE = digital Output. PWM pin onnected to an LED (and resistor)
      that will smoothly fade with each pulse.
      NOTE: PULSE_FADE must be a pin that supports PWM.
       If USE_INTERRUPTS is true, Do not use pin 9 or 10 for PULSE_FADE,
       because those pins' PWM interferes with the sample timer.
*/
const int PULSE_INPUT = A0;
const int PULSE_BLINK = 13;    // Pin 13 is the on-board LED
const int PULSE_FADE = 5;
const int THRESHOLD = 550;   // Adjust this number to avoid noise when idle

/*
   samplesUntilReport = the number of samples remaining to read
   until we want to report a sample over the serial connection.

   We want to report a sample value over the serial port
   only once every 20 milliseconds (10 samples) to avoid
   doing Serial output faster than the Arduino can send.
*/
byte samplesUntilReport;
const byte SAMPLES_PER_SERIAL_SAMPLE = 10;

/*
   All the PulseSensor Playground functions.
*/
PulseSensorPlayground pulseSensor;


//
//
//
///*********************
//
//  SETUP FUNCTION
//
//********************/
//
void setup (void)
{

  // Setup USB serial for debug communication. Will wait for you to connect to Serial on your computer
  Serial.begin(115200);
  while (!Serial);

  // Setup serial connection to radar (Serial1 is RX/TX pins on Arduino Zero)
  Serial1.begin(115200);

  // Change baudrate of radar module
  Serial.println("Changing baudrate of module to 115200...");
  setBaudRate(115200);

  // Change baudrate of Arduino's serial communication with radar
  Serial1.flush ();    // wait for send buffer to empty
  delay (100);         // let last characters be sent
  Serial1.end ();      // close serial

  // Restart serial with new baud rate
  Serial1.begin(115200);
  delay(2000);

  // Reset module
  empty_serial_buffer();
  Serial.println("Resetting module...");
  send_command(&xts_spc_mod_reset, 1);

  // Receive system status messages
  Serial.println("Waiting for system status messages...");
  while (!radar_ready()) {
    Serial.println("Not ready, trying another reset...");
    empty_serial_buffer();
    send_command(&xts_spc_mod_reset, 1);
  }

  // Load module profile - Sleep (provides 2m radar frame length)
  Serial.println("Loading sleep app...");
  load_sleep_app();

  // Turn on baseband (raw data) output.
  Serial.println("Turning on raw data...");
  enable_raw_data();

  // Set detection zone (0.4 - 2.0 gives radar frame 0.3 - 2.3)
  Serial.println("Setting detection zone...");
  setDetectionZone(0.4, 1.0);

  // Set high sensitivity.
  Serial.println("Setting sensitivity...");
  setSensitivity(5);

  // Start the app
  Serial.println("Starting the app...");
  execute_app();

  Serial.println("Waiting for sensor to detect respiration...");

  pulseSensor.analogInput(PULSE_INPUT);
  pulseSensor.blinkOnPulse(PULSE_BLINK);
  pulseSensor.fadeOnPulse(PULSE_FADE);

  pulseSensor.setSerial(Serial);
  pulseSensor.setOutputType(OUTPUT_TYPE);
  pulseSensor.setThreshold(THRESHOLD);

  // Skip the first SAMPLES_PER_SERIAL_SAMPLE in the loop().
  samplesUntilReport = SAMPLES_PER_SERIAL_SAMPLE;

  // Now that everything is ready, start reading the PulseSensor signal.
  if (!pulseSensor.begin()) {
    /*
       PulseSensor initialization failed,
       likely because our Arduino platform interrupts
       aren't supported yet.

       If your Sketch hangs here, try changing USE_PS_INTERRUPT to false.
    */
    for (;;) {
      // Flash the led to show things didn't work.
      digitalWrite(PULSE_BLINK, LOW);
      delay(50);
      digitalWrite(PULSE_BLINK, HIGH);
      delay(50);
    }
  }

}

//
//
//
///*********************
//
//  MAIN LOOP
//
//********************/
//
void loop (void)
{

  get_pulse_data();
  // If the arduino is not fast enough to receive all the data from the radar
  // we need to empty the buffer of old data to avoid lagging and overflow
  empty_serial_buffer();
  //
  //    // Get data
  int len = receive_data(true);   // receive_data() fills recv_buf with a data package
  //
  //    // Process data
  //    if (len > 0) {
  //      handleProtocolPacket(recv_buf + 1, len); //recv_buf+1 to skip the start byte
  /*
    See if a sample is ready from the PulseSensor.

    If USE_INTERRUPTS is true, the PulseSensor Playground
    will automatically read and process samples from
    the PulseSensor.

    If USE_INTERRUPTS is false, this call to sawNewSample()
    will, if enough time has passed, read and process a
    sample (analog voltage) from the PulseSensor.
  */


}

void get_pulse_data()
{
  if (pulseSensor.sawNewSample()) {
    /*
       Every so often, send the latest Sample.
       We don't print every sample, because our baud rate
       won't support that much I/O.
    */
    if (--samplesUntilReport == (byte) 0) {
      samplesUntilReport = SAMPLES_PER_SERIAL_SAMPLE;

      pulseSensor.outputSample();

      /*
         At about the beginning of every heartbeat,
         report the heart rate and inter-beat-interval.
      */
      if (pulseSensor.sawStartOfBeat()) {
        pulseSensor.outputBeat();
      }
    }

    /*******
      Here is a good place to add code that could take up
      to a millisecond or so to run.
    *******/

  }
}
//
//
//
//
///*************************************
//
//  SEND / RECEIVE / SERIAL COMMANDS
//
//*************************************/
//
//
/**
  Reads one character from the serial RX buffer.
  Blocks until a character is available.
*/
unsigned char serial_read_blocking()
{
  while (Serial1.available() < 1) {
    get_pulse_data();
    delay(1);
  }
  return Serial1.read();
}


/**
  Checks if the RX buffer is overflowing.
  The Arduino RX buffer is only 64 bytes,
  so this happens a lot with fast data rates
*/
bool check_overflow()
{
  if (Serial1.available() >= SERIAL_BUFFER_SIZE - 1) {
    return true;
  }

  return false;
}


// Empties the Serial RX buffer
void empty_serial_buffer()
{
  while (Serial1.available() > 0)
    Serial1.read();  // Remove one byte from the buffer
}


/**
  Sends a command
*/
void send_command(const unsigned char * cmd, int len) {

  // Calculate CRC
  char crc = xt_start;
  for (int i = 0; i < len; i++)
    crc ^= cmd[i];


  // Add escape bytes if necessary
  for (int i = 0; i < len; i++) {
    if (cmd[i] == 0x7D || cmd[i] == 0x7E || cmd[i] == 0x7F)
    {
      //TODO: Implement escaping
      Serial.write("CRC Escaping needed for send:buf! Halting...");
      while (1) {}
    }
  }

  // Send xt_start + command + crc_string + xt_stop
  Serial1.write(xt_start);
  Serial1.write(cmd, len);
  Serial1.write(crc);
  Serial1.write(xt_stop);
  Serial1.flush();
}


/**
  Receives one data package from Serial buffer
  Returns the length of the data received.
*/
int receive_data(bool print_data)
{
  int last_char = 0;
  int recv_len = 0;  //Number of bytes received
  unsigned char cur_char;

  //Wait for start character
  while (1)
  {
    get_pulse_data();
    
    // Check if buffer is overflowed
    if (check_overflow())
      empty_serial_buffer();

    // Get one byte from radar
    cur_char = serial_read_blocking();

    if (cur_char == xt_escape)
    {
      // Check if buffer is overflowed
      if (check_overflow()) {
        return -1;
      }

      // If it's an escape character –
      // ...ignore next character in buffer
      serial_read_blocking();
    }
    else if (cur_char == xt_start)
    {
      // If it's the start character –
      // ...we fill the first character of the buffer and move on
      recv_buf[0] = xt_start;
      recv_len = 1;
      break;
    }
  }

  // Start receiving the rest of the bytes
  while (1)
  {
    get_pulse_data();
    // Check if buffer is overflowed
    if (check_overflow()) {
      return -1;
    }

    // read a byte
    cur_char = serial_read_blocking();  // Get one byte from radar
    //    Serial.print(recv_len);
    //    Serial.print(" : ");
    //    Serial.println(cur_char);
    if (cur_char == xt_escape)
    {
      // Check if buffer is overflowed
      if (check_overflow()) {
        return -1;
      }

      // If it's an escape character –
      // fetch the next byte from serial
      cur_char = serial_read_blocking();

      // Make sure to not overwrite receive buffer
      if (recv_len >= RX_BUF_LENGTH)
        return -1;

      // Fill response buffer, and increase counter
      recv_buf[recv_len] = cur_char;
      recv_len++;
    }

    else if (cur_char == xt_start)
    {
      get_pulse_data();
      // If it's the start character, something is wrong
      return -1;
    }

    else
    {
      get_pulse_data();
      // Make sure not overwrite receive buffer
      if (recv_len >= RX_BUF_LENGTH)
        break;

      // Fill response buffer, and increase counter
      recv_buf[recv_len] = cur_char;
      recv_len++;

      // is it the stop byte?
      if (cur_char == xt_stop) {
        break;  //Exit this loop
      }
    }
  }


  // Calculate CRC
  char crc = 0;
  char escape_found = 0;

  // CRC is calculated without the crc itself and the stop byte, hence the -2 in the counter
  for (int i = 0; i < recv_len - 2; i++)
  {
    crc ^= recv_buf[i];
    escape_found = 0;
  }


  // Print the received data
  if (print_data) {
    get_respiration_data();
  }


  // Check if calculated CRC matches the recieved
  if (crc == recv_buf[recv_len - 2])  {
    return recv_len;  // Return length of data packet upon success
  }
  else {
    //Serial.println("[Error]: CRC check failed!");
    return -1; // Return -1 upon crc failure
  }

}



/*********************

  PROTOCOL COMMANDS

*********************/

/**
  Check if the packet is an acknowledge packet
*/
void check_ack()
{
  if (recv_buf[1] == xts_spr_system) {
    Serial.println("Last received was XTS_SPR_SYSTEM message, trying new receive...");
    receive_data(true);
  }

  if (recv_buf[1] != xts_spr_ack) {
    Serial.println("ACK not received! Halting...");
    while (1) {}
  }
}



/**
  Waiting for radar to become ready in the bootup sequence
*/
bool radar_ready()
{
  // Try receiving xts_sprs_ready signal up to 5 times
  for (int i = 0; i < 5; i++) {
    receive_data(true);
    if (recv_buf[2] == xts_sprs_ready) {
      return true;
    }
    delay(500);
  }

  return false;
}


/**
  Execute application
*/
void execute_app()
{
  //Fill send buffer
  send_buf[0] = xts_spc_mod_setmode;
  send_buf[1] = xts_sm_run;

  // Send the command
  send_command(send_buf, 2);

  // Get response
  receive_data(true);
}


/**
  Load sleep app
*/
void load_sleep_app()
{
  //Fill send buffer
  send_buf[0] = xts_spc_mod_loadapp;
  memcpy(send_buf + 1, &xts_id_app_sleep, 4);

  //Send the command
  send_command(send_buf, 5);

  //Get response
  receive_data(true);

  // Check if acknowledge was received
  check_ack();

}


/**
  Enable Raw Data
*/
void enable_raw_data()
{
  long data_length = 1;

  //Fill send buffer
  send_buf[0] = xts_spc_dir_command;
  send_buf[1] = xts_sdc_app_setint;

  memcpy(send_buf + 2, &xts_sacr_outputbaseband, 4);
  memcpy(send_buf + 6, &data_length, 4);
  memcpy(send_buf + 10, &xts_sacr_id_baseband_output_amplitude_phase, 4);

  //Send the command
  send_command(send_buf, 14);

  //Get response
  receive_data(true);

  // Check if acknowledge was received
  check_ack();
}


/**
  Set the detection zone of the radar
*/
void setDetectionZone(float start_zone, float end_zone)
{
  send_buf[0] = xts_spc_appcommand;
  send_buf[1] = xts_spca_set;

  memcpy(send_buf + 2, &xts_id_detection_zone, 4);
  memcpy(send_buf + 6, &start_zone, 4);
  memcpy(send_buf + 10, &end_zone, 4);

  //Send the command
  send_command(send_buf, 14);

  //Get response
  receive_data(true);

  // Check if acknowledge was received
  check_ack();
}


/**
  Set sensitivity
*/
void setSensitivity(long sensitivity)
{
  send_buf[0] = xts_spc_appcommand;
  send_buf[1] = xts_spca_set;

  memcpy(send_buf + 2, &xts_id_sensitivity, 4);
  memcpy(send_buf + 6, &sensitivity, 4);

  //Send the command
  send_command(send_buf, 10);

  //Get response
  receive_data(true);

  // Check if acknowledge was received
  check_ack();

}


/**
  Change baud rate of radar serial interface
*/
void setBaudRate(uint32_t baudrate)
{
  //Fill send buffer
  send_buf[0] = xts_spc_dir_command;
  send_buf[1] = xts_sdc_comm_setbaudrate;
  memcpy(send_buf + 2, &baudrate, 4);

  //Send the command
  send_command(send_buf, 6);
}





/************************
  Higher-level commands
***********************/


/**
  Processes the data packet
*/
void handleProtocolPacket(const unsigned char * data, unsigned int length)
{
  unsigned long pcontentId;
  float arrayAmplitude[52];

  if (data[0] == xts_spr_appdata)
  {
    // Get ID of the content
    memcpy(&pcontentId, data + 1, 4);

    //Check ID of content
    if (pcontentId == xts_id_resp_status)
    {
      //Serial.println("Respiration status data");
      // Todo: Could process complete respiration message here.
    }
    else if (pcontentId == xts_id_sleep_status)
    {
      //Serial.println("Sleep status data");
      // Todo: Could process complete sleep message here.
    }
    else if (pcontentId == xts_id_baseband_amplitude_phase)
    {
      //Serial.println("Baseband Amplitude Data");
      xtDatamsgBasebandAP_header_t basebandHeader;
      memcpy(&basebandHeader, data + 5, sizeof(xtDatamsgBasebandAP_header_t));

      if (basebandHeader.numOfBins != 52) {
        Serial.print("[Error]: numOfBins = ");
        Serial.println(basebandHeader.numOfBins);
      }

      memcpy(arrayAmplitude, data + 5 + sizeof(xtDatamsgBasebandAP_header_t), basebandHeader.numOfBins * sizeof(float));
      onDatamsgBasebandAP(&basebandHeader, arrayAmplitude);
    }
    else
    {
      //Serial.println("Unknown data");
    }
  }
}


/**
  Processes Baseband Amplitude data
*/
void onDatamsgBasebandAP( xtDatamsgBasebandAP_header_t *basebandHeader , float *arrayAmplitude)
{
  float triggerThreshold = 1.5;
  float adaptiveCluttermapWeight = 0.05;
  static float arrayCluttermap[BASEBAND_NUM_OF_BINS_MAX];
  float arrayAmplitudeFiltered[BASEBAND_NUM_OF_BINS_MAX];

  int index;
  float ampMax;
  float distance;
  static float distanceFiltered;
  float distanceFilterWeight = 0.3;
  //static uint32_t detectionTimeout = 0;
  static long last_detection = 0;

  // Check for strange values
  for (int i = 0; i < basebandHeader->numOfBins; i++) {
    if (abs(arrayAmplitude[i]) > 1000.0) {
      //      Serial.println("Suspicious frame. Ignoring...");
      return;
    }
  }


  // Adaptive cluttermap filtering
  for (int i = 0; i < basebandHeader->numOfBins; i++)
  {
    arrayCluttermap[i] = arrayCluttermap[i] * (1 - adaptiveCluttermapWeight) + arrayAmplitude[i] * adaptiveCluttermapWeight;
    arrayAmplitudeFiltered[i] = abs(arrayAmplitude[i] - arrayCluttermap[i]);
  }

  // Get index of max value
  index = get_max(arrayAmplitudeFiltered, basebandHeader->numOfBins, &ampMax);


  // Simple threshold, two different values based on distance.
  if (index > basebandHeader->numOfBins / 2)
    triggerThreshold = 1.5;
  else
    triggerThreshold = 3;

  // Detection
  if ((ampMax > triggerThreshold) && (ampMax < 1000))
  {
    last_detection = basebandHeader->frameCtr;

    distance = basebandHeader->rangeOffset + index * basebandHeader->binLength;
    distanceFiltered = distanceFiltered * (1 - distanceFilterWeight) + distance * distanceFilterWeight;
    //    get_respiration_data();
    //         Serial.print("Detection at ");
    //         Serial.println((int)distanceFiltered);
    //     Serial.print(".");
    //     Serial.println((int)( (distanceFiltered - (int)distanceFiltered)*10));
    //     Serial.print(" amplitude: ");
    //     Serial.println(ampMax);
  }
  //else if (detectionTimeout++ > 20*5) // 5 seconds
  else if (basebandHeader->frameCtr - last_detection > 100) // 5 seconds
  {
    Serial.print("No detection. ampMax: ");
    Serial.println(ampMax);
  }
}


/**
  Finds the highest amplitude in float array.
  Returns position of highest amplitude.
*/
int get_max(float * data, int length, float * ampMax)
{
  float amax = 0.0;
  int idx = 0;

  for (int i = 0; i < length; i++) {
    if (data[i] > amax) {
      amax = data[i];
      idx = i;
    }
  }

  // Fill the incoming float point with the max amplitude
  *ampMax =  amax;

  return idx;
}



/**
  Function for printing a float array
  Used for debugging.
*/

void get_respiration_data() {

  //   if (receive_data() < 1)
  //    return;

  //
  // Check that it's a sleep message.
  // If it's not, ignore (although this shouldn't happen if the output control is set correctly)
  //

  // Combine bytes 2 to 5 into a unsigned integer
  uint32_t xirs_recv = (uint32_t)recv_buf[2] | ((uint32_t)recv_buf[3] << 8) | ((uint32_t)recv_buf[4] << 16) | ((uint32_t)recv_buf[5] << 24);

  // Compare to XTS_ID_SLEEP_STATUS
  //  if (xirs_recv != xts_id_sleep_status)
  //  {
  //    Serial.print("Message not xts_id_sleep_status: ");
  //    return;
  //  }


  // Print out information about the current state
  static unsigned char last_state_code = 0;   // For saving last state
  unsigned char state_code = recv_buf[10];    // For the current state


  //  if (last_state_code != state_code) {

  switch (state_code) {
    case XTS_VAL_RESP_STATE_BREATHING:
      {

        //          Serial.println("Received Buffer data: ");
        //          for (int i = 0; i < 32; i++)
        //          {
        //            Serial.print(i);
        //            Serial.print(": ");
        //            Serial.println(recv_buf[i]);
        //          }


        int *rpm_ptr = (int*)&recv_buf[14];
        // Get float value from pointer and print it out to user:
        rpm = *rpm_ptr;

        float *dis_ptr = (float*)&recv_buf[18];
        // Get float value from pointer and print it out to user:
        dis = *dis_ptr;



        float *mov_ptr = (float*)&recv_buf[22];
        // Get float value from pointer and print it out to user:
        mov = *mov_ptr;


        Serial.print("R");
        Serial.println(rpm);
//        Serial.print("\t");
//        Serial.print("Distance: ");
//        Serial.print(dis);
//        Serial.print("\t");
//        Serial.print("Movement: ");
//        Serial.println(mov);


        break;
      }

    default:
      {
        break;
      }

  }

  // Update current state
  last_state_code = state_code;
  //  }



}

