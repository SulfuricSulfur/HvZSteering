//the seeker class
class Zombie extends Vehicle {
  //images for spookies
  PImage pumpkin;
  PImage spookySkeleton;
  PImage zomble;
  //choosing a random texture
  int imgTexture;

  //attributes
  //target
  PVector target = null;

  //steering force for the seeker
  PVector steerForce;
  PVector humanLoc;//the location of nearby human

  float rad;//the radius 

  PVector antiVir;//the location of antivirus
  //zombie
  PShape zombieS;
  int numbAnti;//the number of antiviruses
  Boolean chasingHuman;//tells if zombie is currently chasing human
  float closeDist;//the closer distance of the humans
  PVector chaseHuman;//the pvector that is closer to the zombie
  //used for obstacle avoidence
  int numObjs;//number of object in tha rraylist/array of radius and positions
  ArrayList<PVector> obPos;//the arrayList of the obstacles
  float[] obRad;//the radius of the obstacles

  PVector velHuman;


  //constructor
  Zombie(float x, float y, float r, float ms, float mf, int numOb, float ma) {//pass in the number of objects in the obstacle arra
    //passing arguments up to vehicle
    super(x, y, r, ms, mf, ma);
    rad = r;
    humanLoc = new PVector();//will change when human is  nearby
    
    //loading in image
    pumpkin = loadImage("pumpkin.png");
    spookySkeleton = loadImage("SpookySkeleton.png");
    zomble = loadImage("Zombie.png");
    imgTexture = int(random(1,4));//choosing one of the random textures to use

    steerForce = new PVector(0, 0);
    zombieS = createShape(TRIANGLE, 0, 0, -radius, -radius, -radius, radius);
    //size of zombie is based on radius
    //instantiating the obstacle avoidence
    obPos = new ArrayList<PVector>();
    obRad = new float[numOb];
    numObjs = 0;
    numbAnti =0;
    //used for determining which human is closer
    closeDist =216;//setting it to the max distance before zombie detects human
    chaseHuman = new PVector();
    chasingHuman = false;
    antiVir= new PVector();
    velHuman = new PVector();
  }

  // float Radius(){
  //return rad; 
  //}
  Boolean ChasingH() {
    return chasingHuman;
  }

  void SwitchChaseTrue() {
    chasingHuman = true;
  }
  void SwitchChaseFalse() {
    chasingHuman = false;
  }

  //used for setting the obstacles in the arra
  void ObSet(float rad, PVector obpos) {
    obRad[numObjs] = rad;
    numObjs++;
    obPos.add(obpos);
  }


  //takes the location of the nearest human, and set it as
  //a vector to be used to calculat forces
  void HumanSeek(PVector humanDis) {
    humanLoc = humanDis;
  }



  void SetSight(ArrayList<Human> humans) {
    float dist = 216;
    //check the array and determin distance
    for (int i = 0; i < humans.size(); i++) {
      dist = abs(PVector.dist(loc, humans.get(i).Loc()));
      //if the distance is less than or equal to 250, human is within range
      if (dist <= 215) {
        chasingHuman = true;
        //if the distance is closer than the other on, make it the new human to chase
        if (dist < closeDist) {
          closeDist = abs(dist);
          velHuman = humans.get(i).Vel();
          chaseHuman = humans.get(i).Loc();
        }
      }
    }
    //if no humans are close enough, then will wander
    if ( dist > 215) {
      chasingHuman = false;
      closeDist =216;
    }
  }


  //setting up the location and number of anti-viruses present
  void GoForAntivirus(PVector antiLoc, int numAnti) {
    antiVir = antiLoc;
    numbAnti = numAnti;
  }


  void ChaseReset() {//resets the chaseHuman if the human is caught
    closeDist= 216;//setting it to the max dist till zombie notices human.
    velHuman = null;
    chaseHuman = null;
    //if the distance is greater than 215, zombie will wander
  }


  //debug vector
  void debugChase() {
    if (debug == true) {
      stroke(#FFE600);
      line(loc.x, loc.y, chaseHuman.x, chaseHuman.y);
      noStroke();
    }
  }



  //abstract methods
  //calculates steering forces and applies to acceleration
  //humanLoc is the location of the closest human
  void calcSteerForces() {
    //gets steering force returned from calling seek
    //target will be humans

    PVector inBounds = OutBounds();
    PVector seekAntiV = new PVector();//force driving to seek out antiviruses
    PVector avoidForce = new PVector(); //the force used for going around obstacles
    //checkign to see if inbounds
    PVector seekHuman = new PVector();
    PVector wanderYonder = new PVector();
    //if there is an antivirus present, zombie will meander towards it more
    if (numbAnti != 0) {
      seekAntiV = seek(antiVir);
      seekAntiV.mult(3.5);
      steerForce.add(seekAntiV);
    }
    //checking for obstacle avoidence
    for (int i =0; i < numObjs; i++) {
      avoidForce = avoidObstacle(obPos.get(i), obRad[i], 100);//SOMETHING IS WRONG HERE
      avoidForce.mult(7);
      steerForce.add(avoidForce);
    }
    //multiplying the forces so the urdge to go back in bounds is slightly more
    //if human is within range, chase the human
    float dis =216;
    //if there is a human present and there is a human within range
    if (chaseHuman != null) {
      dis = PVector.dist(chaseHuman, loc);
    }
    //if a human is within range, CHASE IT!
    if (dis <= 215 && chaseHuman != null) {
      seekHuman = Pursue(chaseHuman, velHuman);
      seekHuman.mult(10.5);
      steerForce.add(seekHuman);
      //steerForce.add(seekHuman);
    } 
    //if there is no human within range(null vector for location)
    if (dis > 215 || chaseHuman == null) {//if human without of range, wander yo

      wanderYonder = Wander();
      wanderYonder.mult(6.5);
      steerForce.add(wanderYonder);
    }


    //adding the urdge to seek the center to the steerignforce
    //(if seekbounds is 0 then within bounds)

    steerForce.limit(maxFor);
    inBounds.mult(5.8);
    ApplyForce(inBounds);


    //applying to acceleratiom
    ApplyForce(steerForce);

    //resetting to 0
    steerForce.mult(0);
  }

  //displaying the zombie
  void display() {
    //translating the direction of the current velocity
    float angle = vel.heading();

    //translating and rotating the zombie
    pushMatrix();
    translate(loc.x, loc.y);
    rotate(angle);
    if(imgTexture== 1){//zombie
      zomble.resize(30,30);
      image(zomble,-15,-15);
      
    }
    else if(imgTexture==2){//SPOOKY SCARY SKELETONS SEND SHIVERS DOWN YOUR SPINE.
      spookySkeleton.resize(30,30);
      image(spookySkeleton,-15,-15);
      
    }
    else{//PUMPKIN TIME
      pumpkin.resize(30,30);
      image(pumpkin,-15,-15);
      
    }
    popMatrix();
  }


  void ChaseH() {
    PVector seekHuman = Pursue(chaseHuman, velHuman);
    seekHuman.mult(8.5);
    steerForce.add(seekHuman);
  }

  void ZWander() {
    PVector wanderYonder = Wander();
    steerForce.add(wanderYonder);
  }
}