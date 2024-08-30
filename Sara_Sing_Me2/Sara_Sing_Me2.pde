import ddf.minim.*;
import ddf.minim.analysis.*;
import java.util.ArrayList;

// We are setting up some basic things for the drawing
int numLines = 100; // How many lines we want to draw from the center
float noiseStrength = 300; // How wiggly we want the lines to be
float noiseDetail = 0.005; // How detailed the wiggles are
float[][] lineOffsets; // Where the lines start (their x and y positions)
boolean[] movingRight; // Keeps track of whether each line is moving right or left

// Setting up tools to listen to the microphone and analyze the sound
Minim minim;
AudioInput mic;
FFT fft;
BeatDetect beat;
int bands = 16; // Breaking the sound into 16 parts to study it
float[] bandEnergies; // Remembering how loud each part of the sound is

// Setting up some things for detecting beats in the music and making effects
boolean beatDetected = false;
float pulseRadius = 0; // How big the "boom" effect gets when a beat is detected
int baseColor = 255; // The main color we're using for the lines

// List to keep track of the ripple effects (like waves on water)
ArrayList<Ripple> ripples = new ArrayList<Ripple>();

// Variables to keep track of where the gradient and ripple effects happen
float gradientX, gradientY;
boolean showGradient = false; // Decides if we should show the gradient or not

void setup() {
  size(800, 800); // Setting the size of our drawing window
  background(0); // Making the background black
  
  // Setting up the microphone to listen for sound
  minim = new Minim(this);
  mic = minim.getLineIn(Minim.MONO, 256); // Listening with a smaller buffer for quicker response
  
  // Setting up FFT to analyze the sound
  fft = new FFT(mic.bufferSize(), mic.sampleRate());
  fft.logAverages(bands, 7); // Breaking the sound into 16 parts to study
  
  // Setting up BeatDetect to listen for beats (like drum hits)
  beat = new BeatDetect();
  beat.setSensitivity(200); // Making it more sensitive to detect beats better
  
  bandEnergies = new float[bands]; // Remembering the loudness of each sound part
  
  // Setting up the starting positions and directions for the lines
  lineOffsets = new float[numLines][2]; // X and Y positions for each line
  movingRight = new boolean[numLines]; // Which way each line is moving (right or left)
  
  // Spacing out the lines evenly
  float spacing = height / float(numLines);

  // Setting up where each line starts and whether it moves right or left
  for (int i = 0; i < numLines; i++) {
    lineOffsets[i][0] = random(width);  // Starting at a random spot on the left or right
    lineOffsets[i][1] = i * spacing; // Spacing the lines evenly up and down
    movingRight[i] = random(1) > 0.5; // Randomly deciding if the line starts moving right or left
  }
}

void draw() {
  background(0, 20); // Making the background a bit see-through to leave a trail
  
  // Analyzing the current sound coming in from the microphone
  fft.forward(mic.mix);
  
  // Checking if there's a beat (like a drum hit) in the sound
  beat.detect(mic.mix);
  
  // If a beat is detected, make some cool effects happen
  if (beat.isOnset()) {
    beatDetected = true;
    pulseRadius = 150; // Make the pulse effect bigger when a beat happens
    baseColor = color(random(255), random(255), random(255)); // Change the color on each beat
    
    // Pick a random spot for the gradient and ripple effect to happen
    gradientX = random(width);
    gradientY = random(height);
    
    // Add a ripple effect at the random spot when a beat is detected
    ripples.add(new Ripple(gradientX, gradientY));

    // Randomly decide if we should show the gradient effect
    showGradient = random(1) > 0.5; // 50% chance to show the gradient
  } else {
    beatDetected = false;
  }
  
  // Remember how loud each sound part is
  for (int i = 0; i < bands; i++) {
    bandEnergies[i] = fft.getAvg(i);
  }
  
  // Get the overall loudness of the sound to control how fast the lines move
  float amplitude = mic.mix.level();
  
  // Use the loudness to control the speed of the lines
  float speed = map(amplitude, 0, 0.1, 0.5, 10);
  noiseStrength = map(amplitude, 0, 0.1, 100, 600); // Make the wiggles stronger when it's louder
  
  // Making everything get bigger and then smaller like a pulse
  translate(gradientX, gradientY); // Move to the random spot
  scale(1 + pulseRadius / 500.0); // Scale the pulse effect based on its size
  translate(-gradientX, -gradientY); // Move back to the original spot
  
  // Drawing and moving each line
  for (int i = 0; i < numLines; i++) {
    float x = lineOffsets[i][0];
    float y = lineOffsets[i][1];
    float lineLength = width * random(0.3, 0.8); // Make each line a random length

    // Make the lines react more to the lower (bass) sounds
    float lowFreqModulation = map(
      (bandEnergies[0] * 2 + bandEnergies[1] * 1.5 + bandEnergies[2] * 1.2 + bandEnergies[3]) / 5.7, // Using the bass sounds
      0, 0.5, // Adjusting based on how loud the bass is
      1.0, 1.5 // Making the effect stronger
    );

    // Draw lines that wiggle, especially when the bass is strong
    for (int xOffset = 0; xOffset < width / 2; xOffset++) {
      float n = noise(xOffset * noiseDetail * lowFreqModulation, y * noiseDetail) * noiseStrength;
      stroke(lerpColor(baseColor, color(255, 0, 0), bandEnergies[5])); // Color the lines based on sound
      line(gradientX + n + xOffset, y, gradientX + n + xOffset + 1, y);
      line(gradientX - n - xOffset, y, gradientX - n - xOffset - 1, y);
    }

    // Add some colorful wiggles along the lines when the mid (middle) sounds are strong
    float midFreqModulation = map(bandEnergies[5], 0, 0.5, 0.8, 1.2);
    
    for (int j = 0; j < lineLength; j++) {
      float xOffset = random(width / 2);
      float n = noise(xOffset * noiseDetail * midFreqModulation, y * noiseDetail) * noiseStrength;
      stroke(random(255), random(255), random(255));
      line(gradientX + n + xOffset, y, gradientX + n + xOffset + 1, y);
      line(gradientX - n - xOffset, y, gradientX - n - xOffset - 1, y);
    }
    
    // Make the lines move smoothly
    float targetX = movingRight[i] ? width - lineOffsets[i][0] : lineOffsets[i][0];
    lineOffsets[i][0] = lerp(lineOffsets[i][0], targetX, 0.05); // Smoothly move towards the target
    
    // Move the lines right or left, and change direction when they hit the edge
    if (movingRight[i]) {
      lineOffsets[i][0] += speed; // Move to the right
      if (lineOffsets[i][0] > width) {
        movingRight[i] = false; // Go left when it reaches the right edge
      }
    } else {
      lineOffsets[i][0] -= speed; // Move to the left
      if (lineOffsets[i][0] < 0) {
        movingRight[i] = true; // Go right when it reaches the left edge
      }
    }
  }
  
  // Add more colorful wiggles when the high (treble) sounds are strong
  float highFreqModulation = map(bandEnergies[bands - 1], 0, 0.5, 0.5, 1.5);
  
  for (int i = 0; i < 10000 * highFreqModulation; i++) {
    float x = random(width);
    float y = random(height);
    stroke(random(255), random(255), random(255), random(50, 150));
    point(x, y); // Draw colorful dots for extra effect
  }

  // Draw some extra lines for a glitchy look when mid-high sounds are strong
  float midHighFreqModulation = map(bandEnergies[10], 0, 0.5, 0.8, 1.2);
  
  for (int i = 0; i < 50 * midHighFreqModulation; i++) {
    float y = random(height);
    stroke(255, 255, 255, random(100, 200)); // Semi-transparent white lines
    line(random(width), y, random(width), y); // Draw horizontal lines
  }
  
  // Draw and update the ripple effects
  for (int i = ripples.size() - 1; i >= 0; i--) {
    Ripple ripple = ripples.get(i);
    ripple.display(); // Show the ripple
    ripple.update(); // Make the ripple grow and fade
    if (ripple.isFaded()) {
      ripples.remove(i); // Remove the ripple when it's completely faded
    }
  }
  
  // Make the pulse effect get smaller over time
  if (pulseRadius > 0) {
    pulseRadius -= 5;
  }
  
  // Only draw the gradient if we decided to show it
  if (showGradient) {
    drawCentralGradient(gradientX, gradientY, width / 4);
  }
}

// Clean up when we're done
void stop() {
  mic.close(); // Turn off the microphone
  minim.stop(); // Stop listening to the sound
  super.stop(); // Stop the sketch
}

// Ripple class to create ripple effects (like waves)
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
    stroke(255, alpha); // Draw with white color that fades out
    
    // Draw lines that go out from the center of the ripple
    for (int i = 0; i < numLines; i++) {
      float angle = map(i, 0, numLines, 0, TWO_PI); // Angle for each line
      float x1 = x + cos(angle) * radius;
      float y1 = y + sin(angle) * radius;
      line(x, y, x1, y1); // Draw lines from the center of the ripple
    }
  }
  
  boolean isFaded() {
    return alpha <= 0; // Check if the ripple is fully faded out
  }
}

// Function to draw a radial gradient (like a glowing circle) that moves
void drawCentralGradient(float x, float y, float radius) {
  int steps = int(radius);  // More steps make a smoother gradient
  
  // Make the gradient move slightly over time
  float time = millis() / 1000.0; // Get the current time in seconds
  float offset = sin(time) * 10;  // Move the gradient back and forth
  
  for (int r = 0; r < steps; r++) {
    float ratio = r / float(steps); // How far we are from the center
    float alpha = lerp(255, 0, ratio * ratio); // Make the edge of the gradient fade out
    
    // Rotate the gradient a bit for a cool effect
    pushMatrix();
    translate(x, y);
    rotate(time * 0.1); // Slowly rotate the gradient
    translate(-x, -y);
    
    stroke(255, alpha); // Draw with white color that fades out
    noFill();
    
    // Apply some movement to the gradient radius
    ellipse(x + offset, y + offset, r * 1.1, r * 1.1); // Draw the gradient
    popMatrix();
  }
}
