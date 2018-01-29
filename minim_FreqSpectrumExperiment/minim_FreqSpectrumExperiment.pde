import ddf.minim.*;
import ddf.minim.analysis.*;

Minim myMinim;
AudioPlayer mySound;
FFT myFFT;

void setup()
{
  size(800, 600);
  colorMode(HSB,255,255,255); // see way below for reason..
  noStroke();
  frameRate(60);
  // You must always start Minim first!
  // Start it by "instantiating" your object:
  // myMinim = new Minim(this);
  // (Again, don't worry about "this", just use it).
  // If you start Minim too late:  Nothing will work.
  // All the other classes depend on
  // this first class.

  myMinim = new Minim(this);

  // specify 512 for the length of the sample buffers
  // the default buffer size is 1024.
  // you probably will always use either 512 or 1024;
  // maybe 256 (but that is risky:  lotsa clicks
  // and glitches).  Occasionally 2048 in a game you're
  // building, etc.  But stick with 512, or 1024.
  // Again:  Its just the size of a buffer used to
  // store data that streams, like video or audio.
  // If your data were encoded onto a rope that you
  // were using to carefully lower a friend down the
  // side of a mountain, the "buffer" would be
  // 512 cm or 1024 cm of slack rope.

  // same as before!
  mySound = myMinim.loadFile("mercury.mp3", 512);
  mySound.play();

  // to instantiate our fast fourier transform object,
  // I need to tell it two things:
  // how much slack do I have in my rope (the
  // size of the audio buffer; see metaphor above)
  // and
  // the sample rate at which your mp3 or wav
  // file was originally encoded (usually
  // around 44.1kHz or 48kHz, which is about 2x
  // the range of human hearing, which is usually
  // from a rumbling, low pitch of 20Hz to an ear-piercing
  // pitch at around 21kHz.  That range, 21kHz, gets
  // doubled in order to convert analog sounds
  // to digital signals:  For more info, Google
  // "Nyquist Theorem."

  // Now we already know the first requirement,
  // the buffer size, since we were the ones
  // who set it.  But we're going
  // to have to depend on our new object,
  // mySound, built from the class AudioPlayer,
  // in order to get that second number from
  // inside our MP3 file.  We'll use the
  // AudioPlayer class's method (custom function)
  // called "sampleRate()" in order to find
  // that number.

  // Just to illustrate this from several angles,
  // here are a few ways to do this:

  /* (these lines commented out because
   you only need to instantiate myFFT once).
   
   myFFT = new FFT(mySound.bufferSize(), mySound.sampleRate());
   
   OR
   
   myFFT = new FFT(512, mySound.sampleRate());
   
   OR
   */

  int bS = mySound.bufferSize();
  float sR = mySound.sampleRate();
  myFFT = new FFT(bS, sR);

  // again, when long lines of code look
  // overwhelming, break them down into their
  // component steps and turn one long
  // confusing line into several short, easy-
  // to-understand lines.

  // Done.  Really short!  My notes 
  // make it look like a lot of work,
  // but it isn't!
  background(0);
}

void draw()
{
  //background(100);
  // EVERY FRAME, we have to
  // ask our myFFT object to use its
  // forward() method to analyze
  // the current tiny fragment of music
  // we're about to hear (it listens "forward").
  // In this case, I'm telling that method
  // to check in mySound's "mix" buffer -- 
  // which is a place where mySound automatically
  // combines the sound from the LEFT channel
  // with the sound from the RIGHT channel.
  //
  // This is essentially a giant BLACK BOX, wherein
  // Processing and your laptop do a LOT of math
  // on the data emerging from your MP3 file.
  //
  // Again, if you want to know more, consider
  // Googling "Fast Fourier Transform" as well as
  // looking at the "MP3" compression standards.
  // Understanding FFT is a good idea:  CompSci
  // typically regards it as one of the ten most
  // important computer algorithms in our lives.

  // To recap:  We have the myFFT object
  // listen to the current moment of
  // music (stored in MIX), and then fast fourier transform
  // that data.  By default, it simply holds
  // onto all that information when its done.

  myFFT.forward(mySound.mix);

  // First question:  How much data did you get, myFFT?
  // There's a method() for that!

  int spectrumSize = myFFT.specSize();
  
  
  // We're ALMOST ALWAYS going to get back 
  // HALF of the value we used earlier,
  // since STEREO music means we have to use
  // half our buffer for one channel and then
  // half our buffer for the other.  So 512
  // would typically return to us about 256 
  // "bands" of spectrum data.  BUT REMEMBER THAT
  // THINGS ALWAYS ALWAYS ALWAYS BREAK,
  // so it is better to ask than to assume.

  // NOW: SOME GET CONFUSED when we organize
  // this data (a spectrum of values) horizontally,
  // as they would on the equalizer on your
  // bedroom stereo or on your car's digital
  // display.  When we do that, it tends to look like
  // VALUES OVER TIME.  But it ain't over time.
  // Instead, I THINK I can describe it as
  // a measurement of information density
  // at any particular moment.  In any event,
  // I'm going to display that information in
  // the form of a vertical line in order
  // to minimize (do you see what I did there?)
  // your potential confusion.
  
  float bandSize = height / spectrumSize; 
  float verticalZoom = 8;
  
  float timeSlice = width / 512;
  
  // each band of the sonic spectrum (displayed 
  // vertically) should be how tall?  
  // We'll use this to calculate height of blocks, below.
  // The "verticalZoom" will help us zoom in on
  // the first half of the spectrum, where the data
  // is interesting.  FEEL FREE TO CHANGE THAT
  // VALUE AND WATCH WHAT HAPPENS.

  for (int i=0; i<spectrumSize; i++) {
    
    // myFFT normalizes the sonic spectrum data it
    // receives -- that is, the value of each band
    // across the bandwidth ranges exclusively
    // from -1.0 to 1.0.
    // SO I'm going to "creatively misread"
    // that data, making use of the fact
    // that using HSB color mode
    // (Hue, Saturation, Brightness)
    // instead of RGB (Red, Green, Blue)
    // gives us automatic rainbows as
    // we count from 0 (-1.0) up to 255 (1.0).
    // We'll calculate that color value with
    // the awesome MAP function.
    // MAP arguments are:
    // 1. number to transform,
    // 2. lowest value that number 1 could have been;
    // 3. highest value that number 1 could have been;
    // 4. lowest value your new number COULD be;
    // 5. highest value your new number COULD be;
    
    // Use a 4.0-style grade to percentage-style grade
    // conversion as a way of understanding this.
    
    // float myFinalGPA = map(3.9,0,4.0,0,100);
    // Which makes myFinalGPA equal to 97.5 (good work!)
    
    // note that to make a better result, I'd
    // actually calculate the MIN and MAX of values
    // across the spectrum... if it is a very quiet
    // song, for example, with very low frequency
    // instruments, the values will tend to stay
    // around -0.75 to -0.5, or below 65 after
    // mapping from 0 - 255.  That's a lot of unused
    // "headroom".  I'll fix that problem with a 
    // quick workaround below, but if this were
    // something of greater significance, we'd take
    // the time to do that math...
    
    float bandValue = myFFT.getBand(i);
    float rainbowHue = map(bandValue,-1.0,1.0,320,0);
    
    // now color my world
    
    fill(rainbowHue,240,240,40); // H, S, B, ALPHA
    
    // using 20 as my Alpha (transparency)
    // lets me layer my 
    // differently-colored rectangles,
    // building up several pixels of color and 
    // generating slightly more complex outcomes.
    
    // So:  Now, as we read i from the start of the 
    // spectrum to its end (which we are
    // doing at least 30 times every second), 
    // we'll need to derive
    // a value for "y" (since we are
    // displaying this sound spectrum
    // as data across our Y axis.
    
    // Some arbitrary decisions I have
    // made in order to make things look
    // a certain way... (ARBITRARY CHOICES
    // ARE THE MOST IMPORTANT PART OF
    // DATA VISUALIZATION; THEY ARE WHAT
    // MAKE DATA VIZ A KIND OF POLITICAL
    // RHETORIC INSTEAD OF A KEY TO
    // KNOWING ALL THINGS.  In spite of
    // what many believe, it is impossible
    // to commit a single data point to 
    // the screen without making several
    // choices beforehand.  Those choices,
    // like all choices in design or code, are
    // ALWAYS POLITICAL.
    
    // I'll add an arbitrary zoom to emphasize
    // the bottom of the spectrum, because the
    // top is mostly empty (which is true of most
    // of the music to which we listen).  I'll also
    // subtract my final "y" value from HEIGHT, in
    // order to flip my spectrum upside-down, putting
    // the lowest values at the bottom of the screen
    // where "y" is actually at its maximum :(

    float prepY = i * bandSize; 
    // spectrum is now evenly spaced across height
    
    float zoomY = prepY * verticalZoom;
    // with zoomY, we'll forced much of the boring stuff 
    // off the screen, and make the lower numbers take
    // up more space in the process ("verticalZoom" times more space,
    // or 8 times more space).
    
    float invertY = height - zoomY;
    // finally, things are flipped upside-down
    // by subtracting our calculated y-position from
    // the maximum y-position.
    
    // NOTE that if you pay attention to the 
    // red squares, you'll see they roughly
    // correspond to the notes played (on this guitar: 
    // https://www.facebook.com/photo/download/?fbid=160542607848
    // ) in the MP3.  That's because we've peered into
    // the sound spectrum generated over time.  Horizontal
    // axis is time, almost always.  For us, now, vertical
    // axis is the sound spectrum, with low notes at the bottom
    // and high notes at the top (roughly).  Additionally,
    // when a band of the spectrum is silent, the background
    // is bluish.  When there is a strong voice from that
    // band, it shifts across the color spectrum from blue to red.
    // a red blotch = (roughly) a loud note at that frequency.
    
    float x = timeSlice * frameCount * 0.24;
    rect(x, invertY, 3, 12);
  }
}