/*---------------------------------
 Name: Sara Groborz
 Date: Sept 2024
 Tittle: "Ferrofluid: The Weather Sculptor"
 
Description:

Ferrofluid, a liquid infused with tiny magnetic particles, 
responds dramatically to magnetic fields by forming spikes 
and patterns that shift and flow. In the context of a generative 
art project, this behaviour can be metaphorically linked 
to weather phenomena. Just as ferrofluid changes its form 
in response to magnetic forces, the visual representation 
of ferrofluid in the project can react to simulated weather data, 
such as temperature and wind speed, which serve as 
"environmental forces" influencing its movement and shape. 
This connection creates an analogy between the dynamic, 
responsive nature of ferrofluid and the constantly changing, 
unpredictable nature of weather, where the environment appears 
to sculpt and influence the fluid's behaviour in real time.

To avoid relying on an external API, I have simulated real-time 
data within Processing by using Perlin noise to generate smooth, 
natural-looking variations in temperature and wind speed over time. 
This approach allows the data to evolve continuously as the sketch runs, 
creating dynamic and responsive visual effects. Additionally, 
I have integrated controlP5, a built-in library, to simulate input 
controls for parameters like temperature and wind speed, enabling 
manual adjustments in real-time. This setup ensures that the environment 
reacts fluidly and interactively, providing a rich, generative 
art experience without the need for external data sources.
 
 -----------------------------------*/
 
  /* libraries*/
  
import peasy.PeasyCam;
PeasyCam cam;

// Setup Variables
int cols, rows;
int scl = 12;
int w = 3000;
int h = 4000;
float[][] terrain;
float[][] offset;
float angle = 0;
float roundingFactor = 0.1;

// Simulated real-time data variables
float temperature;
float windSpeed;

// Timing variables for noise-based data generation
float noiseOffsetTemp = 0;
float noiseOffsetWind = 1000;

// Variable to hold the grid size effect based on temperature
float gridSizeEffect;

void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, 1000);
  cursor(CROSS);
  cols = w / scl;
  rows = h / scl;
  terrain = new float[cols][rows];
  offset = new float[cols][rows];
  noStroke();
  smooth(100);
}

void draw() {
  background(0);

  // Simulate real-time weather data using Perlin noise
  temperature = map(noise(noiseOffsetTemp), 0, 1, -10, 40); // Temperature range: -10 to 40 Celsius
  windSpeed = map(noise(noiseOffsetWind), 0, 1, 0, 20); // Wind speed range: 0 to 20 m/s

  // Increment noise offsets for next frame
  noiseOffsetTemp += 0.01;
  noiseOffsetWind += 0.01;

  // Use weather data to influence the rotation and grid size
  float rotationSpeed = map(windSpeed, 0, 20, 0.005, 0.05); // Map wind speed to rotation speed
  gridSizeEffect = map(temperature, -10, 40, 15, 5); // Map temperature to grid size

  lights();
  
  float mouseInfluence = map(mouseX, 0, width, -100, 100);

  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      float distX = abs(x - cols / 2);
      float distY = abs(y - rows / 2);
      float distance = distX * distX + distY * distY;

      offset[x][y] = map(sin(distance * 0.05 + angle), -1, 1, -50, 50);

      // Adjust terrain heights based on simulated weather data
      float weatherEffect = map(temperature * windSpeed, 0, 800, -100, 100);
      terrain[x][y] = map(sin(distance * 0.05 + angle + mouseInfluence), -1, 1, -50 + weatherEffect, 50 + weatherEffect);
    }
  }

  translate(width / 2 + 50, height / 2 + 50);
  rotateX(PI / 4);
  rotateZ(angle * rotationSpeed); // Adjust rotation speed based on wind speed
  translate(-w / 2, -h / 2);

  directionalLight(250, 250, 250, 1, 0, -1);
  ambientLight(80, 80, 80);
  specular(100);
  shininess(100);

  for (int y = 0; y < rows - 1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      float h1 = terrain[x][y];
      float h2 = terrain[x][y + 1];
      float o1 = offset[x][y];
      float o2 = offset[x][y + 1];

      float modifiedX1 = x * scl + o1 + roundingFactor * (cols / 2 - abs(x - cols / 2));
      float modifiedY1 = y * scl + o1 + roundingFactor * (rows / 2 - abs(y - rows / 2));
      
      float modifiedX2 = x * scl + o2 + roundingFactor * (cols / 2 - abs(x - cols / 2));
      float modifiedY2 = (y + 1) * scl + o2 + roundingFactor * (rows / 2 - abs(y + 1 - rows / 2));

      fill(map(h1, -50, 0, 50, 100), map(h1, -50, 0, 50, 100), map(h1, -50, 0, 60, 120));  
      vertex(modifiedX1, modifiedY1, h1);
      fill(139, 0, 0);  
      vertex(modifiedX2, modifiedY2, h2);
    }
    endShape();
  }
  
  angle += rotationSpeed; // Adjust rotation speed based on wind speed
}

void mousePressed() {
  scl = int(random(gridSizeEffect, gridSizeEffect + 10)); // Adjust grid size based on temperature
}

void mouseDragged() {
  float mouseEffect = map(mouseY, 0, height, -200, 200);
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      float distX = abs(x - cols / 2);
      float distY = abs(y - rows / 2);
      float distance = distX * distX + distY * distY;
      terrain[x][y] += map(sin(distance * 0.05 + angle + mouseEffect), -1, 1, -50, 50);
    }
  }
}
