/*---------------------------------
 Name: Donec dignissim elementum
 Date: Sept 2024
 Tittle:  Sed laoreet dolor eu ur
 Description:
 
 It was popularised in the 1960s with the release of
 Letraset sheets containing Lorem Ipsum passages,
 and more recently with desktop publishing
 software like Aldus PageMaker including versions
 of Lorem Ipsum
 Links:
 https://www.lipsum.com/feed/html
 https://www.lipsum.com/feed/html
 -----------------------------------*/
 
 
 
 /* libraries*/
 
import peasy.PeasyCam; //https://mrfeinberg.com/peasycam/
PeasyCam cam;

// Setup Variables
int cols, rows; // These are the number of columns and rows in our grid.
int scl = 12; // This is the size of each square in the grid.
int w = 3000; // This is the width of our virtual grid (not the screen size).
int h = 4000; // This is the height of our virtual grid (not the screen size).
float[][] terrain; // This is where we'll store the heights of the grid squares.
float[][] offset; // This is where we'll store some small adjustments for the positions.
float angle = 0; // This is the angle for rotating things.
float roundingFactor = 0.1;  // This is a small number to help round the corners of shapes.

// Lighting and Rotation
void setup() {
  
  
  size(800, 800, P3D); // Set up window size and enable 3D mode.
   cam = new PeasyCam(this, 1000); //setup 3D CAM
  cursor(CROSS); //Alba:more elegant see https://processing.org/reference/cursor_.html
  cols = w / scl; // Calculate how many columns I need based on grid width and square size.
  rows = h / scl; // Calculate how many rows I need based on grid height and square size.
  terrain = new float[cols][rows]; // Create an empty grid to store the heights.
  offset = new float[cols][rows]; // Create an empty grid to store small position adjustments.
  noStroke(); // Removes the outlines from all shapes.
  smooth(100); // Make everything look smoother.
}

// Where the Magic Happens
void draw() {
  background(0); // Paint the background black at the start of every frame. //Alba if you disable its super interesing!
  
  lights(); // Turn on the lights to see the 3D shapes.

  // Calculates how much influence the mouse's X position has on the shapes.
  float mouseInfluence = map(mouseX, 0, width, -100, 100);

  // This loop goes through each row and column in our grid.
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      // Calculate how far the current grid square is from the center.
      float distX = abs(x - cols / 2);
      float distY = abs(y - rows / 2);
      float distance = distX * distX + distY * distY; // The distance squared.

      // Small adjustments to the positions based on distance and angle.
      offset[x][y] = map(sin(distance * 0.05 + angle), -1, 1, -50, 50);

      // Height of each square based on distance, angle, and mouse influence.
      terrain[x][y] = map(sin(distance * 0.05 + angle + mouseInfluence), -1, 1, -50, 50);
    }
  }

  // Move and rotate the entire grid to see it from an angle.
  translate(width / 2 + 50, height / 2 + 50); // Move to the center of the screen.
  rotateX(PI / 4); // Tilt the view downwards by 45 degrees.
  rotateZ(angle * 0.1); // Slowly rotate the view around the Z-axis.
  translate(-w / 2, -h / 2); // Move the grid back to the top-left corner.

  // Lighting effects
  directionalLight(250, 250, 250, 1, 0, -1); // A white light shining from the front.
  ambientLight(80, 80, 80); // A soft ambient light.
  specular(100); // Make the material shiny.
  shininess(100); // Shine level.

  // 3D Ferrofluid Spikes
  for (int y = 0; y < rows - 1; y++) {
    beginShape(TRIANGLE_STRIP); // Start drawing a strip of triangles.
    for (int x = 0; x < cols; x++) {
      float h1 = terrain[x][y]; // The height of the current square.
      float h2 = terrain[x][y + 1]; // The height of the next square down.
      float o1 = offset[x][y]; // The offset for the current square.
      float o2 = offset[x][y + 1]; // The offset for the next square down.

      // Apply rounding effect by slightly modifying the vertex positions
      float modifiedX1 = x * scl + o1 + roundingFactor * (cols / 2 - abs(x - cols / 2));
      float modifiedY1 = y * scl + o1 + roundingFactor * (rows / 2 - abs(y - rows / 2));
      
      float modifiedX2 = x * scl + o2 + roundingFactor * (cols / 2 - abs(x - cols / 2));
      float modifiedY2 = (y + 1) * scl + o2 + roundingFactor * (rows / 2 - abs(y + 1 - rows / 2));

      // Set the color based on the height, and draw the current triangle.
      fill(map(h1, -50, 0, 50, 100), map(h1, -50, 0, 50, 100), map(h1, -50, 0, 60, 120));  // Gunmetal silver color.
      vertex(modifiedX1, modifiedY1, h1);
fill(139, 0, 0);  // Dark red color for h1
       vertex(modifiedX2, modifiedY2, h2);
    }
    endShape(); // Stop drawing the strip of triangles.
  }
  
  angle += 0.01; // Slowly increase the angle for the next frame.
}

void mousePressed() {
  scl = int(random(15, 25)); // When the mouse is pressed, randomly change the size of the grid squares.
}

void mouseDragged() {
  float mouseEffect = map(mouseY, 0, height, -200, 200); // Calculate an effect based on mouse Y position.
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      float distX = abs(x - cols / 2);
      float distY = abs(y - rows / 2);
      float distance = distX * distX + distY * distY;
      terrain[x][y] += map(sin(distance * 0.05 + angle + mouseEffect), -1, 1, -50, 50); // Adjust the height of the terrain based on the mouse drag.
    }
  }
}
