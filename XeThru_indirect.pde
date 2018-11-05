//-------------------------------------Get Latest XeThru Recording (CSV file path)-------------------------------

float[] time;
float[] respirationRealTime; //this is a relative value compared to the average RPM
float[] averageRPM;
float initialMinute, initialSeconds, initialHour;
float lastMinute, lastSeconds, lastHour;
//int missedSeconds;
String folderPath = "";
String csvFilePath = "";
void getDataFromCSVFile()
{
  File f = new File(sketchPath("data/xethru"));
  String[] xethruFolders = f.list();

  long latestDate = 0;

  //Get filepath for latest XeThru recording folder 
  for (int i=0; i<xethruFolders.length; i++)
  {
    //Example folder name: xethru_recording_20181025_195200_dd504dcc-390d-4045-b060-7caad6b60e79
    String[] folderNameSegments = split(xethruFolders[i], "_");

    //Skip names of hidden files, only consider those file names that begin with "xethru"
    if (folderNameSegments[0].equals("xethru")) 
    {
      long date = Long.parseLong(folderNameSegments[2]+""+folderNameSegments[3]);
      if (latestDate<=date)
      {
        folderPath = xethruFolders[i];
        latestDate = date;
      }
    }
  }
  //Get csv file from latest folder (found above)
  File f2 = new File(sketchPath("data/xethru/"+folderPath));
  String[] xethruFolderFiles = f2.list();
  for (int i=0; i<xethruFolderFiles.length; i++)
  {
    //File we are looking for: xethru_log_Respiration_XethruX2M200_20181025_195200.csv
    String[] fileNameSegments = split(xethruFolderFiles[i], ".");

    //Skip names of hidden files, only consider those file names that begin with "x" (from "xethru")
    if (fileNameSegments[0].substring(0, 1).equals("x")) 
    {
      if (fileNameSegments[1].equals("csv"))
      {
        csvFilePath = "data/xethru/" + folderPath + "/" + xethruFolderFiles[i];
        break;
      }
    }
  }
  println("Path: "+ csvFilePath);

  //-------------------------------------Get Data from CSV file-------------------------------


  println("Time: Respiration (RPM)");

  String[] allLines = loadStrings(csvFilePath);
  ArrayList<String> dataLines = new ArrayList<String>();

  //Get Rid of extra lines in the beginning of csv file
  for (int i = 0; i < allLines.length; i++) {

    if (allLines[i].substring(0, 1).equals("#") || allLines[i].substring(0, 1).equals("T"))
      continue;  
    else
      dataLines.add(allLines[i]);
  }

  time = new float[dataLines.size()];
  respirationRealTime = new float[dataLines.size()];
  averageRPM = new float[dataLines.size()];
  initialHour = 0;
  initialMinute = 0;
  initialSeconds = 0;

  //Get time and respiration data (RPM) from csv file (can use ObjectMovement for respiration if more dynamic response is needed)
  for (int i=0; i<dataLines.size(); i++)
  {

    /*Sample data line from XeThru csv file:
     TimeStamp;              State;  RPM;   ObjectDistance;   ObjectMovement;  SignalQuality
     2018-10-25T19:52:00.468-05:00;    0;     27;     1.03174;           1.53782;         10
     */
    String[] list = splitTokens(dataLines.get(i), "; : T -");

    /*XeThru doesn't start recording time from 0, so we get the initial minutes and seconds it recorded 
     and then substract them from later minutes and seconds to get the time from the start of recording*/
    if (i==0)
    {
      initialHour = parseFloat(list[3]);
      initialMinute = parseFloat(list[4]);
      initialSeconds = parseFloat(list[5]);
    }
    if (i==dataLines.size()-1)
    {
      lastHour = parseFloat(list[3]);
      lastMinute = parseFloat(list[4]);
      lastSeconds = parseFloat(list[5]);
    }
    time[i] = (parseFloat(list[3])-initialHour)*3600 + (parseFloat(list[4])-initialMinute)*60 + parseFloat(list[5])-initialSeconds;  //Add time in minutes to time in seconds
    respirationRealTime[i] = parseFloat(list[11]); //RPM is list[9], ObjectMovement is list[11]
    averageRPM[i] = parseFloat(list[9]);
    //println("Average RPM:"+averageRPM[i]);
  }

  TimeSync();
}

void TimeSync()
{
  float xethruStartTime = (initialHour*3600 + initialMinute*60 + initialSeconds);  //absolute time in seconds 
  float xethruEndTime = (lastHour*3600 + lastMinute*60 + lastSeconds); //absolute time in seconds, e.g., 18045s

  float missedSecondsStart = (startTime-xethruStartTime); //number of seconds that xethru recorded extra before video started
  float missedSecondsEnd = (xethruEndTime-endTime); //numbed of seconds that xethru recorded extra after the video ended
  float videoTime = endTime-startTime; 

  ArrayList<Float> correctedTime = new ArrayList<Float>();
  ArrayList<Float> correctedData = new ArrayList<Float>();

  for (int i=0; i<time.length; i++)
  {
    /* Since Xethru records extra both in the beginning and end, those seconds must be removed
     "missedSecondsStart" gives us the starting time of the video relative to Xethru (i.e., how many seconds after recording did we start the video?)
     */

    if (time[i]>=missedSecondsStart && time[i]<=missedSecondsStart+videoTime) 
    {
      correctedData.add(respirationRealTime[i]+averageRPM[i]);
      correctedTime.add(time[i]-missedSecondsStart);
      //println((time[i]-missedSecondsStart)+": "+(respirationRealTime[i]+averageRPM[i]));
    }
  }
  //println("Seconds missed at start: "+missedSecondsStart);  
  //println("Seconds missed at end: "+missedSecondsEnd);
  //println("Xethru start time:"+time[0]);
  //println("Xethru end time:"+time[time.length-1]);
  //println("Ending Second:"+videoTime);
  //println("Rows in XeThru time array:"+correctedTime.size());
  //println("Rows in Processing time array:"+rings.size());

  int ringCounter = 0, xethruCounter = 0;

  //Align Xethru and Arduino time and respiration data
  while (ringCounter<rings.size()-1)
  {
    //println("Xethru time: "+correctedTime.get(xethruCounter)+"   Arduino time: "+rings.get(ringCounter).timeStamp/frameRate);

    if (correctedTime.get(xethruCounter)>=(rings.get(ringCounter).time/frameRate))
    {
      if (correctedData.get(xethruCounter)==0)
      {
        if (ringCounter>0)
          rings.get(ringCounter).rpm = rings.get(ringCounter-1).rpm;
      } else
        rings.get(ringCounter).rpm = correctedData.get(xethruCounter);

      //println("Time: "+(rings.get(ringCounter).timeStamp/frameRate)+"    - RPM: " + rings.get(ringCounter).rpm  + "      - BPM: " + rings.get(ringCounter).bpm  + "          - GSR: " + rings.get(ringCounter).gsr);
      ringCounter++;
    } else
    {
      rings.get(ringCounter).rpm = correctedData.get(xethruCounter);
      xethruCounter++;
    }
  }

  for (int i=rings.size()-2; i>=0; i--)
  {
    if (rings.get(i).bpm == 0)
    {
      //rings.get(i).bpm = 90; //For debugging purposes
      rings.get(i).bpm = rings.get(i+1).bpm;
    }
  }
  for (int i=0; i<rings.size()-1; i++)
  {

    println("Time: "+(rings.get(i).time/frameRate)+"    - RPM: " + rings.get(i).rpm  + "      - BPM: " + rings.get(i).bpm  + "          - GSR: " + rings.get(i).gsr);
    //rings.get(i).rpm = correctedData.get(i); //not the same sizes
  }

  gotXethruData = true;
  //int[] correctedTime = new int[time.length-totalMissedSeconds];

  //println("Rows in XeThru time array:"+correctedTime.length);
  //println("Rows in Processing time array:"+rings.size());
}
