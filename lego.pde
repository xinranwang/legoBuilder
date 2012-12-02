class lego {
  String brickName;
  
  color brickColor;
  int colorIndex;
  int brickXSize;
  int brickYSize;
  
  int brickX = width / 2;
  int brickY = height / 2;
  int brickZ = -100;
  
  float brickRotateX = 0;
  float brickRotateY = 0; // changable with HALF_PI
  float brickRotateZ = 0;
  
  boolean isRotatingWithMouse = false;
  boolean isMovingWithMouse = false;
  
  boolean isRotatingWithKinect = false;
  boolean isMovingWithKinect = false;
  //boolean isAttached = false;
  
  ArrayList<lego> attachedLegoList = new ArrayList<lego>();
  //List<AttachedLegoBean> attachedLegoList = new ArrayList<AttachedLegoBean>();

  lego(int a, int b, int c) {
    brickName = "brick" + brickNamer;
    brickNamer++;
    
    brickXSize = a;
    brickYSize = b;
    brickColor = colors[c];
  }
  
  void setLocation(int x, int y, int z) {
    brickX = x;
    brickY = y;
    brickZ = z;
  }

  void drawBrick() {
    noStroke();
    fill(brickColor);
    
    pushMatrix();
    
//    if(isMovingWithMouse == true) {
//      brickX = mouseX;
//      brickZ = mouseY;
//    }
    
    translate(brickX, brickY, brickZ);
    
    if(isRotatingWithMouse == true) {
      //rotateWithMouse();
      brickRotateX = map(mouseY, 0, height, -PI, PI);
      brickRotateY = map(mouseX, 0, width, -PI, PI);
    }
    
    rotateX(brickRotateX);
    rotateY(brickRotateY);
    rotateZ(brickRotateZ);
    
    box(10 * pixelSize * brickXSize, brickHeight, 10 * pixelSize * brickYSize);

    pushMatrix();
    translate(- pixelSize * 5 * (brickXSize - 1), - brickHeight / 2, - pixelSize * 5 * (brickYSize - 1));
    rotateX(PI / 2);

    drawCylinder(360, brickR, brickR, brickCylinderHeight);
    for (int i = 2; i <= brickXSize; i++) {
      translate(10 * pixelSize, 0);
      drawCylinder(360, brickR, brickR, brickCylinderHeight);
    }

    for (int j = 2; j <= brickYSize; j++) {
       translate(- (brickXSize - 1) * 10 * pixelSize, 10 * pixelSize, 0);
      drawCylinder(360, brickR, brickR, brickCylinderHeight);
      for (int i = 2; i <= brickXSize; i++) {
        translate(10 * pixelSize, 0);
        drawCylinder(360, brickR, brickR, brickCylinderHeight);
      }
    }

    popMatrix();
    popMatrix();
  }
}




