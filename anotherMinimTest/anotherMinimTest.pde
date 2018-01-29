// g.w.lemasters
// thursday,
// the early 21st century

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;  
AudioPlayer tuneful;
FFT fftLog;
float wH,hH;

float spectrumScale = 7;
float graphicReduction = 0.125;
float multiplier = spectrumScale * graphicReduction;
// just speeding up the process later.

void setup() {
  size(512, 480, FX2D); // FX2D is the NEW renderer
  // in processing.  LOOKS GREAT.  SO SMOOTH.
  wH = width * 0.5;
  hH = height*0.5;
  smooth(8);
  colorMode(HSB, 255, 255, 255);
  rectMode(CENTER);

  minim = new Minim(this);
  tuneful = minim.loadFile("STE.mp3", 1024);
  // lo, is that a jaunty Star Trek tune I hear?
  // it is indeed, friend.  it is indeed.
  
  tuneful.play();

  fftLog = new FFT( tuneful.bufferSize(), tuneful.sampleRate() );
  fftLog.logAverages( 120, 6);
  // Yeah, I know:  I've been over this repeatedly and I'm
  // not sure I completely understand how this log() function
  // works...  In my case, I think I've specified minimum 120Hz 
  // bands of 6 octaves each -- but I'm not entirely sure
  // what "octave" means in this case... surely not 
  // a musical octave?
}


void draw() {
  fill(0, 64);
  noStroke();
  rect(wH, hH, width, height);
  // instead of blanking the screen, just fade it out a bit.

  fill(255);
  fftLog.forward( tuneful.mix );


  float neuBands = fftLog.avgSize() * 0.75;
  float colorModifier = 255/neuBands;
  int squares = int(sqrt(neuBands));
  
  // do background of similar data as our circles
  // just portrayed differently
  float sqSize = int(width / squares);
  float sqOffset = sqSize * 0.5;
  int bandNumber = 0;
  for (int y = 0; y<squares; y++) {
    for (int x = 0; x<squares; x++) {
      float amplitude = fftLog.getAvg(bandNumber)*spectrumScale*0.2;
      // effectively arbitrary -- just a way to 
      // get amplitude to fit roughly within the frame
      // of a single square.
      pushMatrix();
      translate(sqOffset+(sqSize*x), sqOffset+(sqSize*y));
      fill(colorModifier * bandNumber, 250, amplitude*20,amplitude*20);
      // Here I do something I usually hate when I see it elsewhere:
      // mapping the same bit of data across two or more different
      // visualizations simultaneously.  In this case, I've
      // used amplitude to determine both the brightness
      // of the color (HSB) AND its alpha (transparency).  No
      // real point to doing so, but I'd definitely clean that
      // up later if I were to publish this, etc.
      
      ellipse(0, 0, amplitude, amplitude);
      popMatrix();
      bandNumber++;
      // instead of using a for() loop, I increment
      // bandNumber with each increase in x or y;
      // so if I'm counting x and y from 0  to <5:
      // x 0 y 0 b 0
      // x 1 y 0 b 1
      // x 2 y 0 b 2
      // x 3 y 0 b 3
      // x 4 y 0 b 4
      // x 0 y 1 b 5
      // x 1 y 2 b 6 etc
    }
  }
  
  // now do the circular amplitude display

  float bandDegs = 360.0 / neuBands;
  pushMatrix();
  translate(wH, hH);
  fill(255, 5);
  ellipse(0, 0, 320, 320);
  rotate(radians(-90));
  // put 0 at Noon, rather than at 3o'clock.
  
  for (int i = 0; i < neuBands; i++) {
    fill(i*colorModifier, 240, 240);
    float r = radians(i * bandDegs);
     // we'll spin around the circle's perimeter
     // according to which one of our averaged bands
     // we're graphing...
    pushMatrix();
    ellipse(0, 0, 70, 70);
    rotate(r); // implement that spin now...
    translate(0, 40);
    int neuBandAmplitude = int(fftLog.getAvg(i)*multiplier);
    //reduce amplitude to a specific integer, 
    // which is arbitrarily here from probably 0 to 12 (?),
    // representing levels of amplitude.
    
    // this part plots each "average bandwidth" total
    // amplitude, pictured as stacked circles radiating outward.
    for (int j = 0; j<neuBandAmplitude; j++) {
      translate(0, 9); // move another 9 pixels out with each level
      // since I don't "popMatrix" after the translate,
      // and since draw() doesn't restart in between,
      // the translations are cumulative...
      ellipse(0, 0, 6, 6);
    }
    popMatrix();
  }
  popMatrix();
}