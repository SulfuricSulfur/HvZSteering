//the obstacles that humans and zombies will need to avoid
class Obstacle {

  //attributes
  PVector pos;
  float radius;

PImage spookyTree;
  //constructor
  Obstacle(float x, float y) {
    pos = new PVector(x, y);
    radius = 25;
    spookyTree = loadImage("tree.png");
    
  }
  //passing in so I can use the position and radius outside the class
  PVector Pos() {
    return pos;
  }
  float Rad() {

    return radius;
  }

  //drawing obstacles to screen
  void DrawO() {
    //ellipseMode(RADIUS);
    //fill(0);
    //ellipse(pos.x, pos.y, radius, radius);
    spookyTree.resize(50,50);
    image(spookyTree,pos.x-25,pos.y-25);
    
  }
}