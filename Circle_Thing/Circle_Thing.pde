import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;

Context context;
SensorManager manager;
Sensor sensor;
AccelerometerListener listener;
float ax, ay, az;

float airResistence = 0.0;
boolean move = false;
boolean stop = false;
float timeStarted;
float explosion;
int moveSpeed = 5;

int maxCircleSize;

int[] circles = new int[15];
boolean[] growing  = new boolean[circles.length];
float[] x = new float[circles.length];
float[] y = new float[circles.length];
float[] xSpeed = new float[circles.length];
float[] ySpeed = new float[circles.length];
boolean[] finished = new boolean[circles.length];
//PImage[] images = new PImage[6];
//int[] imgNumChosen = new int[circles.length];
float[] xSpeedMouse = new float[circles.length];
float[] ySpeedMouse = new float[circles.length];

int[] r = new int[circles.length];
int[] g = new int[circles.length];
int[] b = new int[circles.length];

int[] rInc = new int[circles.length];
int[] gInc = new int[circles.length];
int[] bInc = new int[circles.length];

int[] ogChoice = new int[circles.length];

void start() {
  orientation(PORTRAIT);
  context = getActivity();
  manager = (SensorManager)context.getSystemService(Context.SENSOR_SERVICE);
  sensor = manager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
  listener = new AccelerometerListener();
  manager.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_GAME);

  //images[0] = loadImage("Soccer.png");
  //images[1] = loadImage("Basketball.png");
  //images[2] = loadImage("p3.png");
  //images[3] = loadImage("Beach.png");
  //images[4] = loadImage("Jason.png");
  //images[5] = loadImage("Ben.png");

  maxCircleSize = min(width/5, height/5, 250);

  for (int i = 0; i < circles.length; i++) {
    ogChoice[i] = floor(random(0.5, 6.5));

    circles[i] = round(random(maxCircleSize));
    growing[i] = true;
    if (ogChoice[i] == 1) {
      r[i] = 255;
      g[i] = 0;
      b[i] = 0;
    } else if (ogChoice[i] == 2) {
      r[i] = 255;
      g[i] = 255;
      b[i] = 0;
    } else if (ogChoice[i] == 3) {
      r[i] = 0;
      g[i] = 255;
      b[i] = 0;
    } else if (ogChoice[i] == 4) {
      r[i] = 0;
      g[i] = 255;
      b[i] = 255;
    } else if (ogChoice[i] == 5) {
      r[i] = 0;
      g[i] = 0;
      b[i] = 255;
    } else {
      r[i] = 255;
      g[i] = 0;
      b[i] = 255;
    }
    x[i] = random(0, width);
    y[i] = random(0, height);
    xSpeed[i] = random(-1, 1);
    ySpeed[i] = random(-1, 1);
    finished[i] = false;
    //imgNumChosen[i] = round(random(-0.5, images.length - .5000000001));
    xSpeedMouse[i] = 0;
    ySpeedMouse[i] = 0;
  }
}

void setup() {
  textSize(20);
  fullScreen();
  //size(1000, 900);
  frameRate(60);
  strokeWeight(2);
  start();
}

void draw() {
  background(222);

  //Display
  for (int i = 0; i < circles.length; i++) {
    fill(r[i], g[i], b[i], 100);
    stroke(0);
    ellipse(x[i], y[i], circles[i], circles[i]);
    //image(images[imgNumChosen[i]], x[i]-circles[i]/2, y[i]-circles[i]/2, circles[i], circles[i]);
  }

  //Update
  if (stop == false) {
    //Update size
    for (int i = 0; i < circles.length; i++) {
      if (circles[i] >= maxCircleSize) {
        growing[i] = false;
      } else if (circles[i] == 1) {
        growing[i] = true;
      }
      if (growing[i] == true) {
        circles[i]++;
      } else {
        circles[i]--;
      }

      //Update x position
      if (!move) {
        x[i] += xSpeed[i];
      }

      //x constraints
      if (x[i] < circles[i]/2) {
        x[i] = circles[i]/2 + 10;
        xSpeed[i] = -xSpeed[i]+airResistence;
      } else if (x[i] > width - circles[i]/2) {
        x[i] = width - circles[i]/2 - 10;
        xSpeed[i] = -xSpeed[i]+airResistence;
      }

      //Update xSpeed
      if (!move) {
        if (xSpeed[i] > 0) {
          xSpeed[i] -= (airResistence)*1;
        } else if (xSpeed[i] < 0) {
          xSpeed[i] += (airResistence)*1;
        }
      }

      //Stop if finished
      if (finished[i] == true) {
        y[i] = height - circles[i]/2;
        continue;
      }

      //Update y position
      if (!move) {
        y[i] += ySpeed[i];
      }


      //Constrain y
      if (y[i] > height - circles[i]/2) {
        y[i] = height-circles[i]/2 - 10;
        ySpeed[i] = -ySpeed[i];
      } else if (y[i] < circles[i]/2) {
        y[i] = circles[i]/2 + 10;
        ySpeed[i] = -ySpeed[i];
      }

      //Update ySpeed
      if (!move) {
        if (ax > 0.5 || ax < -0.5) {
          xSpeed[i] += ((circles[i]*0.003)-airResistence)*-ax;
        }
        if (ay > 0.5 || ay < -0.5) {
          ySpeed[i] += ((circles[i]*0.003)-airResistence)*ay;
        }
      }

      r[i] += rInc[i] * 5;
      g[i] += gInc[i] * 5;
      b[i] += bInc[i] * 5;

      if (r[i] >= 255 && g[i] >= 255 && b[i] <= 0) {
        rInc[i] = -1;
        gInc[i] = 0;
        bInc[i] = 0;
      } else if (r[i] <= 0 && g[i] >= 255 && b[i] <= 0) {
        rInc[i] = 0;
        gInc[i] = 0;
        bInc[i] = 1;
      } else if (r[i] <= 0 && g[i] >= 255 && b[i] >= 255) {
        rInc[i] = 0;
        gInc[i] = -1;
        bInc[i] = 0;
      } else if (r[i] <= 0 && g[i] <= 0 && b[i] >= 255) {
        rInc[i] = 1;
        gInc[i] = 0;
        bInc[i] = 0;
      } else if (r[i] >= 255 && g[i] <= 0 && b[i] >= 255) {
        rInc[i] = 0;
        gInc[i] = 0;
        bInc[i] = -1;
      } else if (r[i] >= 255 && g[i] <= 0 && b[i] <= 0) {
        rInc[i] = 0;
        gInc[i] = 1;
        bInc[i] = 0;
      }
      if (i == 0) {
      }
    }
  }

  if (move) {
    for (int i = 0; i < circles.length; i++) {
      finished[i] = false;
      xSpeedMouse[i] += map(abs(touches[0].x - x[i]), 0, width - circles[i]/2, 10, 0);
      ySpeedMouse[i] += map(abs(touches[0].x - x[i]), 0, width - circles[i]/2, 10, 0);
      if (x[i] < touches[0].x) {
        x[i]+= xSpeedMouse[i];
      } else if (x[i] > touches[0].x) {
        x[i]-= xSpeedMouse[i];
      }
      if (y[i] < touches[0].y) {
        y[i]+= ySpeedMouse[i];
      } else if (y[i] > touches[0].y) {
        y[i]-= ySpeedMouse[i];
      }
      if (abs(touches[0].y - y[i]) < abs(ySpeedMouse[i])) {
        y[i] = touches[0].y;
        ySpeedMouse[i] -= min(10, ySpeedMouse[i]);
      }
      if (abs(touches[0].x - x[i]) < abs(xSpeedMouse[i])) {
        x[i] = touches[0].x;
        xSpeedMouse[i] -= min(10, xSpeedMouse[i]);
      }
    }
  }
  fill(0);
}

/*//Start timer
 void mousePressed() {
 timeStarted = millis();
 }
 
 //End timer and move objects
 void mouseReleased() {
 explosion = sqrt(millis() - timeStarted)/5;
 
 for(int i = 0; i < circles.length; i++) {
 xSpeed[i] = random(-explosion * moveSpeed, explosion * moveSpeed);
 ySpeed[i] = random(-explosion * moveSpeed, explosion * moveSpeed);
 }
 }
 
 void backPressed() {
 //Restart
 if(key == 'r') {
 start();
 } else {
 print(keyCode);
 }
 }*/

void touchStarted() {
  timeStarted = millis();
  move = true;
  //xSpeed = new float[circles.length];
  //ySpeed = new float[circles.length];
}

void touchEnded() {
  explosion = sqrt(millis() - timeStarted)/5;

  for(int i = 0; i < circles.length; i++) {
    xSpeed[i] = random(-explosion * moveSpeed, explosion * moveSpeed);
    ySpeed[i] = random(-explosion * moveSpeed, explosion * moveSpeed);
    //xSpeed = xSpeedMouse;
    //ySpeed = ySpeedMouse;
  }

  xSpeedMouse = new float[circles.length];
  ySpeedMouse = new float[circles.length];
  move = false;
}
