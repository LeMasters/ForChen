import ddf.minim.*;
import ddf.minim.analysis.*;

Minim myMinim;
AudioPlayer mySound;
FFT myFFT;
PFont myFont;
boolean isolateBand; 

// HOLD MOUSE BUTTON to see
// only TWO bands from the entire sound spectrum.

// Note that this code focuses on the sounds
// in the bottom quarter of the sound spectrum, where
// they are the most visible.  The variable verticalZoom
// controls how much we actually see in the window.

// ON THE RIGHT OF THE SCREEN is a color chart to link
// to amplitude.  Amplitude ("volume") of zero is at the bottom
// in red (0) and continues to the top (blue and then magenta).
// I wanted to label these, but simply ran out of time.


void setup() {
  size(800, 600);

  isolateBand = false;
  myFont = loadFont("SansSerif-24.vlw");
  textFont(myFont, 13);

  colorMode(HSB, 255, 255, 255);
  stroke(0, 0, 0);
  frameRate(60);

  myMinim = new Minim(this);
  mySound = myMinim.loadFile("mercury.mp3", 512);

  // sound file from the film 
  // *Sunshine* (UK, 2007) (Dir. Danny Boyle)
  // music (c) 2007 by Underworld and John Murphy

  mySound.play();
  int bS = mySound.bufferSize();
  float sR = mySound.sampleRate();
  myFFT = new FFT(bS, sR);
}


void draw() {
  if (mousePressed==true) {
    isolateBand = true;
  } else {
    isolateBand = false;
  }
  background(0);

  int emphasisOption;
  myFFT.forward(mySound.mix);
  // how big is our spectrum?
  int spectrumSize = myFFT.specSize();

  // and therefore, what is the size
  // of each band within that spectrum?
  float bandWidth = myFFT.getBandWidth();

  // this just calculates the height of each
  // graphic depiction of a single band, in order
  // to display on the screen.
  float bandSize = height / spectrumSize; 
  float verticalZoom = 11.0;

  // draw key to intensity of amplitude
  int blockHeight = int(verticalZoom * bandSize);
  fill(255,0,255);
  for (int c=0; c<height; c = c + blockHeight) {
    
    int ampColor = int(map(c, 0, height, 0, 255));
    
    fill(ampColor, 240, 240);
    rect(width - (1.25*blockHeight), height - c, blockHeight, blockHeight);
  }

  // Just calculates the amount we'll add to x
  // with every new frame of animation.  Mostly
  // an arbitrary number that happens to have worked well.
  float timeSlice = width / 512.0;

  // now go from the beginning of the spectrum to the end;
  for (int i=0; i<spectrumSize; i++) {

    // this sets a transparency value for use when
    // I isolate one spectrum band (later).

    if (isolateBand == true && i != 9 && i !=14) {
      emphasisOption = 24;
    } else {
      emphasisOption = 255;
    }    

    float bandValue = myFFT.getBand(i);

    // a band is a group of contiguous wavelengths, like
    // 80Hz - 90Hz, or 409Hz - 499Hz.  Here, we have
    // asked myFFT to report the AMPLITUDE (volume) of the
    // specific band that we are looking at (i is really
    // the "band number" or the "band index").

    // it turns out that the value of each band (the
    // amplitude) ranges between 0 and 20, roughly.
    // so let's change that range into a bigger range in
    // order to emphasize more colors...

    float rainbowHueVolume = map(bandValue, 0, 20, 5, 250);
    fill(rainbowHueVolume, 240, 240, emphasisOption); 

    float prepY = i * bandSize; 
    float zoomY = prepY * verticalZoom;
    float invertY = height - zoomY;

    float x = timeSlice * frameCount * 0.179;

    if ((i!=9 && i!=14)|| isolateBand == false) {
      rect(x, invertY, 4, -bandSize*verticalZoom);
    }

    fill(rainbowHueVolume, 240, 240, 40); 
    // remember:
    // we've set COLOR to describe the AMPLITUDE of
    // each BAND in the SPECTRUM.

    // now fade out those colors so that we can
    // put some labels on top of them to associate
    // them visually with the bands to which they refer.
    // (essentially:  make colored labels).

    rect(x - 150, invertY-1, 200, -bandSize*verticalZoom, 4); // 4 here is a rounded corner
    fill(255, emphasisOption);

    text(i, x+16, invertY-3); // label each band with its frequency range
    int rLow = round(i * bandWidth); // start of band in Hertz
    int rHi = round((i+1) * bandWidth)-1; // start of next band in Hertz
    // then make this top value one less than the next bottom value
    String desc = rLow + "–" + rHi + " Hz";
    text(desc, x-112, invertY-4);

    // here we display an ellipse as an abstract
    // representation of band 8's amplitude
    // if isolateBand has been set to true.

    // if this code is a bit idiosyncratic, it is
    // because it really isn't that important to showing
    // you how minim works.  But if you need something
    // clarified here, let me know.

    if (isolateBand == true && (i==14 || i == 9)) {
      int bandValueBarCount = int(map(bandValue, 0, 19, 1, 8))+1;
      fill(rainbowHueVolume, 240, 240);
      for (int LED = 1; LED < bandValueBarCount; LED++) {
        float LEDYPosition = invertY - (LED * 5);
        rect(x-9, LEDYPosition, 18, 5);
      }
    }
  }
}