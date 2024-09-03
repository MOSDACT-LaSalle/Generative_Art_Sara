/*---------------------------------
 Name: Sara Groborz
 Date: Sept 2024
 Tittle: "Sing to Me: The Soundscapes of Motion"
 
 Description:
 
 This project is an exploration of generative art, where the visual output 
 is dynamically influenced by real-time audio input. The code uses the Minim 
 library to capture live sound from a microphone, analyze its frequency 
 and amplitude, and translate this data into a visually compelling display 
 of moving lines and ripple effects. Each line in the display reacts to the 
 amplitude of the sound, with its movement and length being modulated by 
 Perlin noise to create smooth, organic motion. The colors shift gently in 
 response to detected beats, and ripple effects are generated at random points, 
 adding to the dynamic nature of the artwork.

 This project exemplifies the concept of generative art by leveraging algorithmic 
 processes and real-time data to create an ever-evolving visual experience. 
 I define the rules and parameters, such as how the lines respond to sound 
 frequencies and how ripples are generated, but the final outcome 
 is largely autonomous and unpredictable. This approach not only highlights 
 the interaction between sound and visuals but also demonstrates how complex, 
 aesthetically pleasing patterns can emerge from simple procedural rules. 
 The result is an engaging piece of art that continuously transforms in 
 response to its auditory environment, embodying the principles of generative design.
 -----------------------------------*/
 
 
 /* libraries*/
 
import ddf.minim.*;
import ddf.minim.analysis.*;
import java.util.ArrayList;

// Setup Variables
int numLines = 100; // Number of lines
float noiseStrength = 300; // Strength of noise for line movement
float noiseDetail = 0.005; // Detail level of noise
float[][] lineOffsets; // Line positions
boolean[] movingRight; // Line movement direction

Minim minim;
AudioInput mic;
FFT fft;
BeatDetect beat;
int bands = 16; // Frequency bands
float[] bandEnergies;

boolean beatDetected = false;
float pulseRadius = 0;
int baseColor = 255;

ArrayList<Ripple> ripples = new ArrayList<Ripple>();

float gradientX, gradientY;
boolean showGradient = false;

void setup() {
  size(800, 800);
  background(0);
  
  minim = new Minim(this);
  mic = minim.getLineIn(Minim.MONO, 256);
  
  fft = new FFT(mic.bufferSize(), mic.sampleRate());
  fft.logAverages(bands, 7);
  
  beat = new BeatDetect();
  beat.setSensitivity(200);
  
  bandEnergies = new float[bands];
  
  lineOffsets = new float[numLines][2];
  movingRight = new boolean[numLines];
  
  float spacing = height / float(numLines);

  for (int i = 0; i < numLines; i++) {
    lineOffsets[i][0] = random(width);
    lineOffsets[i][1] = i * spacing;
    movingRight[i] = random(1) > 0.5;
  }
}

void draw() {
  background(0, 20); // Transparent background to create a trailing effect
  
  fft.forward(mic.mix);
  beat.detect(mic.mix);
  
  if (beat.isOnset()) {
    beatDetected = true;
    pulseRadius = 150;
    baseColor = color(random(150, 255), random(150, 255), random(150, 255)); // Gentle color variation
    
    gradientX = random(width);
    gradientY = random(height);
    
    ripples.add(new Ripple(gradientX, gradientY));
    showGradient = random(1) > 0.5;
  } else {
    beatDetected = false;
  }
  
  for (int i = 0; i < bands; i++) {
    bandEnergies[i] = fft.getAvg(i);
  }
  
  float amplitude = mic.mix.level();
  
  float speed = map(amplitude, 0, 0.1, 0.5, 10);
  noiseStrength = map(amplitude, 0, 0.1, 100, 400); // Dynamic noise strength
  
  translate(gradientX, gradientY);
  scale(1 + pulseRadius / 500.0);
  translate(-gradientX, -gradientY);
  
  for (int i = 0; i < numLines; i++) {
    float x = lineOffsets[i][0];
    float y = lineOffsets[i][1];
    float lineLength = width * random(0.4, 0.7); // Slightly vary line lengths

    // Perlin noise for smooth, organic movement
    float noiseFactor = noise(i * 0.1, millis() * 0.0005);
    lineOffsets[i][0] += map(noiseFactor, 0.4, 0.6, -speed, speed);

    float lowFreqModulation = map(
      (bandEnergies[0] * 2 + bandEnergies[1] * 1.5 + bandEnergies[2] * 1.2 + bandEnergies[3]) / 5.7,
      0, 0.5,
      1.0, 1.5
    );

    // Drawing lines with slight wiggle
    for (int xOffset = 0; xOffset < width / 2; xOffset++) {
      float n = noise(xOffset * noiseDetail * lowFreqModulation, y * noiseDetail) * noiseStrength;
      stroke(lerpColor(baseColor, color(255, 0, 0), bandEnergies[5]));
      line(gradientX + n + xOffset, y, gradientX + n + xOffset + 1, y);
      line(gradientX - n - xOffset, y, gradientX - n - xOffset - 1, y);
    }

    // Make the lines move smoothly
    float targetX = movingRight[i] ? width - lineOffsets[i][0] : lineOffsets[i][0];
    lineOffsets[i][0] = lerp(lineOffsets[i][0], targetX, 0.05);

    // Move the lines right or left, and change direction when they hit the edge
    if (movingRight[i]) {
      lineOffsets[i][0] += speed;
      if (lineOffsets[i][0] > width) {
        movingRight[i] = false;
      }
    } else {
      lineOffsets[i][0] -= speed;
      if (lineOffsets[i][0] < 0) {
        movingRight[i] = true;
      }
    }
  }
  
  // Draw and update ripple effects
  for (int i = ripples.size() - 1; i >= 0; i--) {
    Ripple ripple = ripples.get(i);
    ripple.display();
    ripple.update();
    if (ripple.isFaded()) {
      ripples.remove(i);
    }
  }
  
  if (pulseRadius > 0) {
    pulseRadius -= 5;
  }
  
  if (showGradient) {
    drawCentralGradient(gradientX, gradientY, width / 4);
  }
}

void stop() {
  mic.close();
  minim.stop();
  super.stop();
}

class Ripple {
  float x, y;
  float radius;
  float alpha;
  
  Ripple(float x, float y) {
    this.x = x;
    this.y = y;
    this.radius = 0;
    this.alpha = 255; // Start with full color
  }
  
  void update() {
    radius += 8; // Make the ripple grow
    alpha -= 5; // Make the ripple fade out
  }
  
  void display() {
    noFill();
    stroke(255, alpha);
    
    // Draw lines that go out from the center of the ripple
    for (int i = 0; i < numLines; i++) {
      float angle = map(i, 0, numLines, 0, TWO_PI);
      float x1 = x + cos(angle) * radius;
      float y1 = y + sin(angle) * radius;
      line(x, y, x1, y1);
    }
  }
  
  boolean isFaded() {
    return alpha <= 0; // Check if the ripple is fully faded out
  }
}

void drawCentralGradient(float x, float y, float radius) {
  int steps = int(radius);  // More steps make a smoother gradient
  
  float time = millis() / 1000.0;
  float offset = sin(time) * 10;
  
  for (int r = 0; r < steps; r++) {
    float ratio = r / float(steps);
    float alpha = lerp(255, 0, ratio * ratio);
    
    pushMatrix();
    translate(x, y);
    rotate(time * 0.1);
    translate(-x, -y);
    
    stroke(255, alpha);
    noFill();
    
    ellipse(x + offset, y + offset, r * 1.1, r * 1.1);
    popMatrix();
  }
}
