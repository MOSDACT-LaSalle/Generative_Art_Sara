int rots;
float time = 0;
float sz = 0.1;
boolean colorToggle = false;

void setup() {
  size(800, 800, P3D);
  noStroke();
}

void draw() {
  background(0);
  ambientLight(50, 50, 50);
  directionalLight(255, 255, 255, -1, 1, -1);
  pointLight(200, 100, 255, width / 2, height / 2, 200);

  translate(width / 2, height / 2, 0);
  
  // Adjust rotation speed based on mouseX
  float rotationSpeed = map(mouseX, 0, width, 0.01, 0.1);
  
  // Adjust sphere size based on mouseY
  float sizeMultiplier = map(mouseY, 0, height, 0.1, 0.5);
  
  // Increase number of layers
  for (int j = 0; j < 5; j++) {
    float layerOffset = map(j, 0, 5, -150, 150);
    
    for (int i = 0; i < 100; i++) {  // Increase number of spheres per layer
      float angle = map(i, 0, 100, 0, TWO_PI);
      pushMatrix();
      rotateZ(angle + time * rotationSpeed + j * 0.2);  // Use rotationSpeed
      translate(200 + 100 * noise(i * 0.1f + j * 0.1f, time), 0, layerOffset);
      
      // Use noise to create some organic variation in size and color
      float n = noise(i * 0.1f + time + j * 0.1f);
      float r = map(n, 0, 1, 40, 120) * (1.0 - j * 0.15) * sizeMultiplier;  // Use sizeMultiplier
      
      // Change color on mouse press
      if (colorToggle) {
        fill(255 * (1 - n), 80, 255 * n, 200);  // Alternate color scheme
      } else {
        // Metallic and chrome-like pink color
        fill(255 * n, 80 + 175 * n, 255, 200);
      }
      
      specular(255);
      shininess(100);  // Increase shininess for a more reflective look
      
      // Draw the sphere with some displacement
      sphere(r * 0.25);  // Adjust sphere size
      popMatrix();
    }
  }
  
  time += 0.005;  // Slow down time increment for smoother animation
}

// Toggle color scheme on mouse press
void mousePressed() {
  colorToggle = !colorToggle;
}
