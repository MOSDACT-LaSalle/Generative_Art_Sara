int numLines = 100; // Number of vertical lines
float noiseStrength = 300;
float noiseDetail = 0.005;
float[][] lineOffsets;
boolean[] movingRight; // Track direction of each line

void setup() {
  size(800, 800);
  background(0);
  lineOffsets = new float[numLines][2]; // Store x and y offsets for each line
  movingRight = new boolean[numLines]; // Store direction of each line
  
  float spacing = width / float(numLines); // Calculate even spacing between lines
  
  for (int i = 0; i < numLines; i++) {
    lineOffsets[i][0] = i * spacing;  // Evenly distributed initial x positions
    lineOffsets[i][1] = random(TWO_PI); // Initial noise offset
    movingRight[i] = random(1) > 0.5; // Randomly decide if the line starts moving right or left
  }
}

void draw() {
  background(0, 20); // Slightly transparent background for a trailing effect
  
  float speed = map(mouseX, 0, width, 0.5, 5); // Speed controlled by mouseX
  noiseStrength = map(mouseY, 0, height, 100, 600); // Noise strength controlled by mouseY
  
  for (int i = 0; i < numLines; i++) {
    float x = lineOffsets[i][0];
    float yOffset = lineOffsets[i][1];
    float lineLength = height * random(0.3, 0.8);

    // Draw moving glitchy vertical lines with noise
    for (int y = 0; y < height; y++) {
      float n = noise(x * noiseDetail, y * noiseDetail + yOffset) * noiseStrength;
      stroke(255);
      line(x + n, y, x + n, y + 1);
    }

    // Add some colorful noise along the line
    for (int j = 0; j < lineLength; j++) {
      float y = random(height);
      float n = noise(x * noiseDetail, y * noiseDetail + yOffset) * noiseStrength;
      stroke(random(255), random(255), random(255));
      line(x + n, y, x + n, y + 1);
    }
    
    // Move lines left or right and reverse direction at edges
    if (movingRight[i]) {
      lineOffsets[i][0] += speed; // Move right with variable speed
      if (lineOffsets[i][0] > width) {
        movingRight[i] = false; // Reverse direction
      }
    } else {
      lineOffsets[i][0] -= speed; // Move left with variable speed
      if (lineOffsets[i][0] < 0) {
        movingRight[i] = true; // Reverse direction
      }
    }
    
    // Increment the noise offset to make the movement dynamic
    lineOffsets[i][1] += 0.01;
  }
  
  // Add additional colored noise and distortion
  for (int i = 0; i < 10000; i++) {
    float x = random(width);
    float y = random(height);
    stroke(random(255), random(255), random(255), random(50, 150));
    point(x, y);
  }

  // Draw horizontal glitch lines
  for (int i = 0; i < 50; i++) {
    float y = random(height);
    stroke(255, 255, 255, random(100, 200));
    line(random(width), y, random(width), y);
  }
}
