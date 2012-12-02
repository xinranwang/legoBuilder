////// KINECT START
import SimpleOpenNI.*;

SimpleOpenNI  context;
//float        zoomF =0.5f;
//float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
//                                   // the data from openni comes upside down
//float        rotY = radians(0);
boolean      handsTrackFlag = false;
PVector      handVec = new PVector();
ArrayList    handVecList = new ArrayList();
int          handVecListSize = 30;
String       lastGesture = "";
float kinectTrackingSpeed = 1.3;
////// KINECT END


int pixelSize = 2;

int brickHeight = 13 * pixelSize;
int brickR = 3 * pixelSize;
int brickCylinderHeight = 3 * pixelSize;

int brickNamer = 0;

color[] colors = new color[0];

PVector pBaseLocation = new PVector();

boolean movingTogetherFlag = false;
ArrayList<lego> legoMovingTogether;

ArrayList<lego> allBricks;

ArrayList<lego> myLegos;

void setup() {
  size(1024, 768, OPENGL);

  ////// KINECT START
  context = new SimpleOpenNI(this);

  // enable depthMap generation 
  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // enable skeleton generation for all joints
  //context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  // enable hands + gesture generation
  context.enableGesture();
  context.enableHands();

  // add focus gestures  / here i do have some problems on the mac, i only recognize raiseHand ? Maybe cpu performance ?
  context.addGesture("Wave");
  context.addGesture("Click");
  context.addGesture("RaiseHand");

  // set how smooth the hand capturing should be
  //context.setSmoothingHands(.5);

  smooth();
  ////// KINECT END


  noStroke();
  initColors();

  allBricks = new ArrayList<lego>();

  myLegos = new ArrayList<lego>();
  for (int i = 0; i < 5; i++) {
    myLegos.add(new lego(6, 2, 6));
  }

  //allBricks.addAll(myLegos);

  lego base = new lego(10, 10, 3);
  allBricks.add(base);
  base.setLocation(width / 2, height - 100 * pixelSize, 0);

  lego testLego = new lego(2, 2, 1);
  allBricks.add(testLego);
  testLego.isMovingWithKinect = true;
  //testLego.isMovingWithMouse = true;
  testLego.brickY = base.brickY - brickHeight;
}

void draw() {
  background(20);
  lights();

  ////// KINECT START
  // update the cam
  context.update();

  if (handsTrackFlag) {
    stroke(255, 0, 0);
    strokeWeight(4);
    point(handVec.x, handVec.y, handVec.z);
    //println(handVec.x + ":" + handVec.y + ":" + handVec.z);
  }
  ////// KINECT END


  for (int i = 0; i < allBricks.size(); i++) {
    if (allBricks.get(i).isMovingWithMouse == true) {
      allBricks.get(i).brickX = mouseX;
      allBricks.get(i).brickZ = mouseY;
    }

    if (allBricks.get(i).isMovingWithKinect == true) {
      allBricks.get(i).brickX = width / 2 - (int)(handVec.x * kinectTrackingSpeed);
      allBricks.get(i).brickY = height / 2 - (int)(handVec.y * kinectTrackingSpeed);
      allBricks.get(i).brickZ = (int)(handVec.z * kinectTrackingSpeed) - 1000;
    }
  }

  if (movingTogetherFlag == true) {
    if (legoMovingTogether != null && legoMovingTogether.size() > 0) {
      float offsetX = legoMovingTogether.get(0).brickX - pBaseLocation.x;
      float offsetY = legoMovingTogether.get(0).brickY - pBaseLocation.y;
      float offsetZ = legoMovingTogether.get(0).brickZ - pBaseLocation.z;

      println(offsetX+", "+offsetY+", "+offsetZ);

      for (int i = 1; i < legoMovingTogether.size(); i++) {

        legoMovingTogether.get(i).brickX += offsetX;
        legoMovingTogether.get(i).brickY += offsetY;
        legoMovingTogether.get(i).brickZ += offsetZ;
      }
    }
  }

  //if(magnetFlag == true)
  if (allBricks.size() > 1) {
    for (int i = 0; i < allBricks.size(); i++) {
      for (int j = 1; j < allBricks.size(); j++) {
        if (i != j) {
          magnet(allBricks.get(i), allBricks.get(j));
        }
      }
    }
    //magnet(base, testLego);
  }

  for (int i = 0; i < allBricks.size(); i++) {
    allBricks.get(i).drawBrick();
  }


  for (int i = 0; i < myLegos.size(); i++) {
    myLegos.get(i).setLocation(i * width / myLegos.size(), height / 2, -100);
    myLegos.get(i).isRotatingWithMouse = true;
    myLegos.get(i).drawBrick();
  }



  pBaseLocation.set(allBricks.get(0).brickX, allBricks.get(0).brickY, allBricks.get(0).brickZ);
  //println(pBaseLocation.x+", "+pBaseLocation.y+", "+pBaseLocation.z);
}


void drawCylinder( int sides, float r1, float r2, float h)
{
  float angle = 360 / sides;
  float halfHeight = h / 2;
  // top
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r1;
    float y = sin( radians( i * angle ) ) * r1;
    vertex( x, y, -halfHeight);
  }
  endShape(CLOSE);
  // bottom
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r2;
    float y = sin( radians( i * angle ) ) * r2;
    vertex( x, y, halfHeight);
  }
  endShape(CLOSE);
  // draw body
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 1; i++) {
    float x1 = cos( radians( i * angle ) ) * r1;
    float y1 = sin( radians( i * angle ) ) * r1;
    float x2 = cos( radians( i * angle ) ) * r2;
    float y2 = sin( radians( i * angle ) ) * r2;
    vertex( x1, y1, -halfHeight);
    vertex( x2, y2, halfHeight);
  }
  endShape(CLOSE);
}

// BUILD THE COLOR ARRAY
void initColors() {
  colors = (color[])append(colors, color(0)); // BLACK
  colors = (color[])append(colors, color(255)); // WHITE
  colors = (color[])append(colors, color(234, 0, 0)); // RED
  colors = (color[])append(colors, color(7, 149, 0)); // GREEN
  colors = (color[])append(colors, color(0, 63, 245)); // BLUE
  colors = (color[])append(colors, color(255, 230, 0)); // YELLOW
  colors = (color[])append(colors, color(255, 128, 0)); // ORANGE
  colors = (color[])append(colors, color(162, 89, 0)); // BROWN
  colors = (color[])append(colors, color(148, 234, 0)); // LIGHT GREEN
}

void rotateWithMouse() {
  rotateX(map(mouseY, 0, height, -PI, PI));
  rotateY(map(mouseX, 0, width, -PI, PI));
}

void mousePressed() {
  combine();
  legoMovingTogether = moveAsAWhole(allBricks.get(0));
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    combine();
    legoMovingTogether = moveAsAWhole(allBricks.get(0));
  }

  if (key == 'k' || key == 'K') {
    allBricks.get(0).isMovingWithKinect = true;
    allBricks.get(0).isMovingWithMouse = false;
    movingTogetherFlag = !movingTogetherFlag;
  }
  if (key == 'm' || key == 'M') {
    allBricks.get(0).isMovingWithKinect = false;
    allBricks.get(0).isMovingWithMouse = true;
    movingTogetherFlag = !movingTogetherFlag;
  }
}

//////
void magnet(lego brick1, lego brick2) {
  if (brick1.brickY - brick2.brickY < 2 * brickHeight && brick1.brickY - brick2.brickY > 0) {

    if (abs(brick1.brickRotateX - brick2.brickRotateX) % TWO_PI < HALF_PI
      && abs(brick1.brickRotateZ - brick2.brickRotateZ) % TWO_PI < HALF_PI) {

      // overlapping
      if (abs(brick1.brickX - brick2.brickX) < (brick1.brickXSize + brick2.brickXSize) / 2 * 10 * pixelSize
        && abs(brick1.brickZ - brick2.brickZ) < (brick1.brickYSize + brick2.brickYSize) / 2 * 10 * pixelSize) {

        brick2.brickY = brick1.brickY - brickHeight;
        brick2.brickRotateX = brick1.brickRotateX;
        brick2.brickRotateZ = brick1.brickRotateZ;

        if ((brick1.brickXSize - brick2.brickXSize) % 2 == 0) {
          if ((brick2.brickX - brick1.brickX) % (10 * pixelSize) > 5 * pixelSize) {
            brick2.brickX += 10 * pixelSize - (brick2.brickX - brick1.brickX) % (10 * pixelSize);
          }
          else {
            brick2.brickX -= (brick2.brickX - brick1.brickX) % (10 * pixelSize);
          }
        }
        else {
          if ((brick2.brickX - brick1.brickX) % (10 * pixelSize) > 2.5 * pixelSize) {
            brick2.brickX += 10 * pixelSize - (brick2.brickX - brick1.brickX) % (10 * pixelSize);
            brick2.brickX -= 5 * pixelSize;
          }
          else {
            brick2.brickX -= (brick2.brickX - brick1.brickX) % (10 * pixelSize);
            brick2.brickX -= 5 * pixelSize;
          }
        }

        if ((brick1.brickYSize - brick2.brickYSize) % 2 == 0) {
          if ((brick2.brickZ - brick1.brickZ) % (10 * pixelSize) > 5 * pixelSize) {
            brick2.brickZ += 10 * pixelSize - (brick2.brickZ - brick1.brickZ) % (10 * pixelSize);
          }
          else {
            brick2.brickZ -= (brick2.brickZ - brick1.brickZ) % (10 * pixelSize);
          }
        }
        else {
          if ((brick2.brickZ - brick1.brickZ) % (10 * pixelSize) > 2.5 * pixelSize) {
            brick2.brickZ += 10 * pixelSize - (brick2.brickZ - brick1.brickZ) % (10 * pixelSize);
            brick2.brickZ -= 5 * pixelSize;
          }
          else {
            brick2.brickZ -= (brick2.brickZ - brick1.brickZ) % (10 * pixelSize);
            brick2.brickZ -= 5 * pixelSize;
          }
        }
        //      else if (abs(brick1.brickX - brick2.brickZ) < (brick1.brickXSize + brick2.brickYSize) / 2 * 10 * pixelSize
        //        && abs(brick1.brickZ - brick2.brickX) < (brick1.brickYSize + brick2.brickXSize) / 2 * 10 * pixelSize) {
        //        //
        //        println("mag");
        //      }
      }
    }

    if ((brick2.brickY - brick1.brickY) < 2 * brickHeight && (brick2.brickY - brick1.brickY) > 0) {

      if (abs(brick1.brickRotateX - brick2.brickRotateX) % TWO_PI < HALF_PI
        && abs(brick1.brickRotateZ - brick2.brickRotateZ) % TWO_PI < HALF_PI) {

        // overlapping
        if (abs(brick1.brickX - brick2.brickX) < (brick1.brickXSize + brick2.brickXSize) / 2 * 10 * pixelSize
          && abs(brick1.brickZ - brick2.brickZ) < (brick1.brickYSize + brick2.brickYSize) / 2 * 10 * pixelSize) {

          brick2.brickY = brick1.brickY + brickHeight;
          brick2.brickRotateX = brick1.brickRotateX;
          brick2.brickRotateZ = brick1.brickRotateZ;

          if ((brick1.brickXSize - brick2.brickXSize) % 2 == 0) {
            if ((brick2.brickX - brick1.brickX) % (10 * pixelSize) > 5 * pixelSize) {
              brick2.brickX += 10 * pixelSize - (brick2.brickX - brick1.brickX) % (10 * pixelSize);
            }
            else {
              brick2.brickX -= (brick2.brickX - brick1.brickX) % (10 * pixelSize);
            }
          }
          else {
            if ((brick2.brickX - brick1.brickX) % (10 * pixelSize) > 2.5 * pixelSize) {
              brick2.brickX += 10 * pixelSize - (brick2.brickX - brick1.brickX) % (10 * pixelSize);
              brick2.brickX -= 5 * pixelSize;
            }
            else {
              brick2.brickX -= (brick2.brickX - brick1.brickX) % (10 * pixelSize);
              brick2.brickX -= 5 * pixelSize;
            }
          }

          if ((brick1.brickYSize - brick2.brickYSize) % 2 == 0) {
            if ((brick2.brickZ - brick1.brickZ) % (10 * pixelSize) > 5 * pixelSize) {
              brick2.brickZ += 10 * pixelSize - (brick2.brickZ - brick1.brickZ) % (10 * pixelSize);
            }
            else {
              brick2.brickZ -= (brick2.brickZ - brick1.brickZ) % (10 * pixelSize);
            }
          }
          else {
            if ((brick2.brickZ - brick1.brickZ) % (10 * pixelSize) > 2.5 * pixelSize) {
              brick2.brickZ += 10 * pixelSize - (brick2.brickZ - brick1.brickZ) % (10 * pixelSize);
              brick2.brickZ -= 5 * pixelSize;
            }
            else {
              brick2.brickZ -= (brick2.brickZ - brick1.brickZ) % (10 * pixelSize);
              brick2.brickZ -= 5 * pixelSize;
            }
          }
          //      else if (abs(brick1.brickX - brick2.brickZ) < (brick1.brickXSize + brick2.brickYSize) / 2 * 10 * pixelSize
          //        && abs(brick1.brickZ - brick2.brickX) < (brick1.brickYSize + brick2.brickXSize) / 2 * 10 * pixelSize) {
          //        //
          //        println("mag");
          //      }
        }
      }
    }
  }
}
//////
void combine() {
  if (allBricks.size() > 1) {
    for (int i = 0; i < allBricks.size(); i++) {
      for (int j = 0; j < allBricks.size(); j++) {
        if (i < j) {
          magnet(allBricks.get(i), allBricks.get(j));

          lego brick1 = allBricks.get(i);
          lego brick2 = allBricks.get(j);

          // height difference
          if (brick1.brickY == brick2.brickY + brickHeight || brick1.brickY == brick2.brickY - brickHeight) { 

            // coodination difference
            if ((brick1.brickX - brick2.brickX) % (10 * pixelSize) == 0
              && (brick1.brickZ - brick2.brickZ) % (10 * pixelSize) == 0) {
              // rotation difference
              if ((brick1.brickRotateX - brick2.brickRotateX) % TWO_PI == 0
                && (brick1.brickRotateZ - brick2.brickRotateZ) % TWO_PI == 0) {

                // overlapping in same direction
                if (abs(brick1.brickX - brick2.brickX) < (brick1.brickXSize + brick2.brickXSize) / 2 * 10 * pixelSize
                  && abs(brick1.brickZ - brick2.brickZ) < (brick1.brickYSize + brick2.brickYSize) / 2 * 10 * pixelSize
                  && (brick1.brickRotateY - brick2.brickRotateY) % PI == 0) {
                  //do sth
                  //brick2.brickX, brick2.brickZ remains same
                  //          int xOffset = brick2.brickX - brick1.brickX;
                  //          int zOffset = brick2.brickZ - brick1.brickZ;
                  //          int yOffset = brickHeight;

                  brick2.isMovingWithMouse = false;
                  brick2.isMovingWithKinect = false;



                  if (!brick1.attachedLegoList.contains(brick2)) brick1.attachedLegoList.add(brick2);
                  if (!brick2.attachedLegoList.contains(brick1)) brick2.attachedLegoList.add(brick1);

                  println("Combined");

                  lego newBrick = new lego((int)random(1, 7), (int)random(1, 7), (int)random(0, 9));
                  newBrick.isMovingWithKinect = true;
                  //newBrick.isMovingWithMouse = true;
                  newBrick.brickY = allBricks.get(allBricks.size() - 1).brickY - brickHeight;
                  allBricks.add(newBrick);


                  //          println(_brickBean2.offsetX+":"+_brickBean2.offsetY+":"+ _brickBean2.offsetZ);
                  //          println(_brickBean1.offsetX+":"+_brickBean1.offsetY+":"+ _brickBean1.offsetZ);
                }
                // overlapping in right angle
                //                else if (abs(brick1.brickX - brick2.brickZ) < (brick1.brickXSize + brick2.brickYSize) / 2 * 10 * pixelSize
                //                  && abs(brick1.brickZ - brick2.brickX) < (brick1.brickYSize + brick2.brickXSize) / 2 * 10 * pixelSize
                //                  && (brick1.brickRotateY - brick2.brickRotateY) % HALF_PI == 0) {
                //                  //do sth
                //                }
              }
            }
          }
        }
      }
    }
  }
}


ArrayList moveAsAWhole(lego brick) {
  pBaseLocation.set(brick.brickX, brick.brickY, brick.brickZ);
  //println(pBaseLocation.x+", "+pBaseLocation.y+", "+pBaseLocation.z);
  ArrayList<lego> wholeBricks = new ArrayList<lego>();
  wholeBricks.add(brick);
  ////
  wholeBricks = getWhole(brick, wholeBricks);
  //brick.isMovingWithMouse = true;

  return wholeBricks;
}


ArrayList getWhole(lego currentLego, ArrayList wholeList) {

  if (currentLego.attachedLegoList != null && currentLego.attachedLegoList.size() > 0) {
    for (int i = 0; i < currentLego.attachedLegoList.size(); i++) {
      lego conBrick = currentLego.attachedLegoList.get(i);
      if (!wholeList.contains(conBrick)) {
        wholeList.add(conBrick);
        getWhole(conBrick, wholeList);
      }
    }
  }
  //println(wholeList.size());
  return wholeList;
}

