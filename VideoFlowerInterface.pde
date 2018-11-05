
boolean barDrawn = false;
PShape progressBar, slider;
float sliderPosX;
float barWidth;
int postCounter;
boolean postPlaying;
float barHeight=20, barStartY=950, barStartX = 10;

void postInit()
{
  barWidth = width-20;
  sliderPosX = barStartX + barWidth; //see VideoFlowerInterface Tab
  strokeWeight(1.5);
  stroke(color(0, 0, 0, 100));
  fill(color(0, 0, 0, 100));
  rect(barStartX, barStartY, barWidth, barHeight);
  line(sliderPosX, 935, sliderPosX, 985);
  postCounter = rings.size()-1;
  postPlaying = false;
}

void ProgressBar()
{


  if (mousePressed == true) {
    if (mouseButton == LEFT) {

      if (mouseY>barStartY && mouseY<barStartY+barHeight)
      {
        //redraw whole plot each time!
        background(255);

        sliderPosX = Math.max(barStartX, mouseX);
        sliderPosX = Math.min(barWidth, mouseX);
        float sliderTime = GetSliderTime();
        for (int i=0; i<rings.size(); i++)
        {
          if (rings.get(i).time/frameRate<=sliderTime)
          {
            drawRing(rings.get(i), i);
            postCounter = i;
          } else
            break;
        }

        video.play();
        video.jump(sliderTime);
        video.pause();

        strokeWeight(1.5);
        stroke(color(0, 0, 0, 100));
        fill(color(0, 0, 0, 100));
        rect(barStartX, barStartY, barWidth, barHeight);
        line(sliderPosX, 945, sliderPosX, 975);
      }
    }
  }




  if (postPlaying)
  {
    video.play();
    if (postCounter<rings.size())
    {
      if (rings.get(postCounter).time/videoFrameRate<=video.time())
      {
        drawRing(rings.get(postCounter), postCounter);
        postCounter++;
        strokeWeight(1.5);
        stroke(color(0, 0, 0, 40));
        sliderPosX = (barStartX+barWidth)*(video.time()/video.duration());
        line(sliderPosX, 950, sliderPosX, 970);

        //println("Post counter: "+postCounter+"    Rings size: "+rings.size());
      }
    }
  } else
  {
    video.pause();
  }
}

void keyReleased()
{

  if (key == ' ') {
    postPlaying = !postPlaying;
  }
}

float GetSliderTime()
{
  return video.duration()*((sliderPosX-barStartX)/barWidth);
}
