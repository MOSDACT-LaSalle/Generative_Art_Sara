import processing.sound.*;

import com.jsyn.engine.SynthesisEngine;
import com.jsyn.unitgen.ChannelOut;

void setup() {

  // print audio device information to the console
  Sound.list();

  // to improve support for USB audio interfaces on Windows, it is possible to 
  // use the PortAudio bindings, which are however not enabled by default. The 
  // listing above might therefore not have given accurate input/output channel 
  // numbers. The Sound library automatically loads PortAudio drivers when it 
  // determines that it is unable to use a device correctly with the default 
  // drivers, but you can always force loading PortAudio (on both Windows and 
  // Mac) using MultiChannel.usePortAudio():
  if (MultiChannel.usePortAudio()) {
    // if PortAudio was loaded successfully, the id's and names of the sound 
    // devices (and possibly their number of input/output channels) will have 
    // changed!
    Sound.list();
  }

  // the Sound.status() method prints some general information about the current 
  // memory and CPU usage of the library to the console
  Sound.status();

  // to get programmatic access to the same information (and more), you can get 
  // and inspect the JSyn Synthesizer class yourself:
  SynthesisEngine s = Sound.getSynthesisEngine();
  println("Current CPU usage: " + s.getUsage());

  // with direct access to the SynthesisEngine, you can always create and add 
  // your own JSyn unit generator chains. if you want to connect them to audio 
  // output, you can connect them to the ChannelOut units automatically 
  // generated by the library:
  ChannelOut[] outputs = MultiChannel.outputs();

  // if you want to mess
  SinOsc sin = new SinOsc(this);
  JSynCircuit circuit = sin.getUnitGenerator();
}


// sketches without a draw() method won't get updated in the loop, and synthesis 
// won't continue
void draw() {
}


// a useful callback method when you are debugging a sound sketch
void mouseClicked() {
  Sound.status();
}
