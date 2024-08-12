int cols, rows;
int scl = 20;
float zoff = 0;

void setup() {
  size(800, 800);
  cols = width / scl;
  rows = height / scl;
  noStroke();
}

void draw() {
  background(0);
  float yoff = 0;
  
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      float noiseValue = noise(xoff, yoff, zoff);
      float brightnessValue = map(noiseValue, 0, 1, 50, 255);
      float sizeValue = map(noiseValue, 0, 1, 10, 30);
      
      // Calculate colors using a mix of silvery-ruby red tones
      float r = map(noiseValue, 0, 1, 150, 255);  // Intense red for ruby color
      float g = map(noiseValue, 0, 1, 50, 70);    // Low green to deepen the red
      float b = map(noiseValue, 0, 1, 70, 90);    // Low blue to avoid pink tones and enhance ruby effect

      pushMatrix();
      translate(x * scl, y * scl);
      
      // Draw multiple ellipses to create a blurred edge effect
      for (int i = 5; i >= 0; i--) {
        fill(r, g, b, 50 + i * 10);  // Adjust transparency
        ellipse(0, 0, sizeValue + i * 2, sizeValue + i * 2);  // Increase size slightly
      }
      
      popMatrix();
      
      xoff += 0.1;
    }
    yoff += 0.1;
  }
  
  zoff += 0.02;
}
