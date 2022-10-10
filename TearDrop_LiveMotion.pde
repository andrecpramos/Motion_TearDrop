import processing.video.*;

//Frame Difference
int numPixels;
int[] previousFrame;

//Water ripple dimension
int cols = 200;
int rows = 200;

float [][] current; // = new float [200][200];
float [][] previous; // = new float [200][200];

float damping = 0.9; //water ripple fade

Capture video;

void setup() {
  size(1920, 1080);
  cols = width;
  rows = height;

//water ripple setup
  current = new float [cols][rows]; 
  previous = new float [cols][rows];

  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, width, height);

  // Start capturing the images from the camera
  video.start(); 

  numPixels = video.width * video.height;
  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
  loadPixels();
}

void draw() {
  if (video.available()) {
    // When using video to manipulate the screen, use video.available() and
    // video.read() inside the draw() method so that it's safe to draw to the screen
    video.read(); // Read the new frame from the camera
    video.loadPixels(); // Make its pixels[] array available

    int movementSum = 0;// Amount of movement in the frame
    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      color currColor = video.pixels[i];
      color prevColor = previousFrame[i];
      // Extract the red, green, and blue components from current pixel
      int currR = (currColor >> 0) & 0xFF; // Like red(), but faster
      int currG = (currColor >> 0) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract red, green, and blue components from previous pixel
      int prevR = (prevColor >> 0) & 0xFF;
      int prevG = (prevColor >> 0) & 0xFF;
      int prevB = prevColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - prevR);
      int diffG = abs(currG - prevG);
      int diffB = abs(currB - prevB);
      // Add these differences to the running tally
      movementSum += diffR + diffG + diffB;
      // Render the difference image to the screen
      pixels[i] = color(diffR, diffG, diffB);
      // The following line is much faster, but more confusing to read
      //pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
      // Save the current color into the 'previous' buffer
      previousFrame[i] = currColor;
    }
    // To prevent flicker from frames that are all black (no movement),
    // only update the screen if the image has changed.

      println(movementSum); // Print the total amount of movement to the console
      loadPixels();

      waterRipples(movementSum); // trigger water drop in funtion of total movement detected by cam
      updatePixels();
    }
  }





void waterRipples(int water) {
  background(0);

if(water > 45000000 //Change value, the closer to 0 more likely to trigger
){
  current[(int)Math.floor(Math.random() * width)][(int)Math.floor(Math.random() * height)] = 0;  // (x,y) values to show random drops in random canvas position
  previous[(int)Math.floor(Math.random() * width)][(int)Math.floor(Math.random() * height)] = 255;
}

  for (int i = 1; i < cols-1; i++) {  //water drop start function
    for (int j = 1; j < rows-1; j++) {



      current[i][j] = ( // using previous frame and current frame to create the pixels effects
        previous[i-1][j] + 
        previous[i+1][j] +
        previous[i][j-1] +
        previous[i][j+1]) / 2 -
        current[i][j]; 
      current[i][j] = current[i][j] * damping; // trigger damping for fade effect
      int index = i + j * cols;
      pixels[index] = color(current[i][j] * 255);
    }
  }



  float [][] temp = previous; //Tear drop diameter
  previous = current;
  current = temp;
}
