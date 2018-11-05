boolean ended;

class VideoPlayer extends PApplet {
  VideoPlayer() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void setup() {
    ended = false;
    frameRate(30);
    video.play();
    while (video.width == 0 | video.height == 0)  delay(10);
    surface.setSize(video.width, video.height);
  }  

  void draw() {
    if (!ended)  background(video);
    //else background(0);
  }
}


void movieEvent(final Movie m) {
  m.read();
}

void myEoS() {
  //ended = true;
}
