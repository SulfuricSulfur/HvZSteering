
//the fleeing class that runs away from the zombies
class Human extends Vehicle {

  //attributes
  //image for human
  PImage humanPic;
  //Pshape for humans
  PShape humanS;
  PVector steeringForce;
  //pvector location of zombies
  PVector fleeZombie;
  float rad;//the radius
  Boolean isAlive;//usef for seeing if the human collided with a zombie
PVector zombieVel;
  //used for obstacle avoidence
  int numObjs;//number of object in tha rraylist/array of radius and positions
  ArrayList<PVector> obPos;//the arrayList of the obstacles
  float[] obRad;//the radius of the obstacles

  //constructor
  Human(float x, float y, float r, float ms, float mf, int numOb, float ma) {
    super(x, y, r, ms, mf,ma); 
    steeringForce = new PVector(0, 0);
    //settiing human image
    humanPic = loadImage("human.png");
    humanS = createShape(TRIANGLE, 0, 0, -radius, -radius, -radius, radius);
    fleeZombie = new PVector();
    rad = r;
    isAlive = true;
    //instantiating the obstacle avoidence
    obPos = new ArrayList<PVector>();
    obRad = new float[numOb];
    numObjs = 0;
    zombieVel = new PVector();
  }

  // float Radius(){
  //return rad; 
  //}
  //returns the isAlive in order to access in the main class


  //used for setting the obstacles in the arra
  void ObSet(float rad, PVector obpos) {
    obRad[numObjs] = rad;
    numObjs++;
    obPos.add(obpos);
  }


  //takes in the closest zombie within a range and flees from it
  void FleeZombie(PVector zombie,PVector zomVel) {
    fleeZombie = zombie;
    zombieVel = zomVel;
  }

  //calculating all the forces
  void calcSteerForces() {
    PVector avoidForce = new PVector();
    PVector inBounds = OutBounds();

    //used for calculating and applying the urdge to avoid an obstacle to the steering force
    for (int i =0; i < numObjs; i++) {
      avoidForce = avoidObstacle(obPos.get(i), obRad[i], 160);
      avoidForce.mult(7.2);
      steeringForce.add(avoidForce);
    }
    //multiplying the forces so the urdge to go back in bounds is slightly more
    //fleeing.mult(5.4);
    //steeringForce.add(seekBounds);
    float dist = PVector.dist(fleeZombie, loc);
    //if zombie is nearby, flee
    if(dist <= 300){
   
        PVector fleeing = Evade(fleeZombie, zombieVel);
        fleeing.mult(10.5);
    steeringForce.add(fleeing);
    }
    else if( dist > 300){
      PVector wanderYonder = Wander();
      steeringForce.add(wanderYonder);
    }


    //the erdge to stay in bounds
    inBounds.mult(4.1);


    steeringForce.limit(maxFor);
    ApplyForce(steeringForce);
    ApplyForce(inBounds);


    steeringForce.mult(0);
  }

  void display() {
    //translating the direction of the current velocity
    float angle = vel.heading();

    //translating and rotating the zombie
    pushMatrix();
    translate(loc.x, loc.y);
    rotate(angle);
        humanPic.resize(30,30);
    image(humanPic,-15,-15);

    //basic zombie
    //humanS.setFill(color(100, 0, 0));
    //shape(humanS, 0, 0);
    popMatrix();
  }
}