// garrison winfield lemasters
// georgetown 2014
// minim library experiment 4
// includes song fragment 
// Mercury, from the film Sunshine

import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer song;
FFT fft;
float xPos, yPos;

void setup() {
    size(900, 900, FX2D);
    smooth();
    minim=new Minim(this);
    song=minim.loadFile("mercury.mp3", 1024);
    song.play();
    fft=new FFT(song.bufferSize(), song.sampleRate());
    fft.forward(song.mix);
    noStroke();
    background(14,10,16);
}

void draw() {
    translate(width*0.5, height*0.5);
    rotate(radians(frameCount*0.11225));
    translate(50,0);
    fft.forward(song.mix);
    int i=0;
    fill(255,200,60,20);
    float adjust = 68;
    float endAdjust;
    while (i<32) {
        pushMatrix();
        translate(xPos, 0);
        endAdjust = (adjust+i)*0.01;
        ellipse(0, 0, fft.getBand(i)*(2.0+i/7.5)*endAdjust, fft.getBand(i)*(2.0+i/7.5)*endAdjust);
        popMatrix();
        i=i+2;
        xPos=xPos+22;
    }
    xPos = 0;
}