//abstract vehicle class that zombies and humans will inherit
abstract class Vehicle {

  //attributes
  //vectors-------------------
  PVector loc, vel, acc, forward, right;
  //floats--------------------
  float maxSpd, maxFor, radius, mass;

  //boolean for deturmining if the debug should be on
  Boolean debug;

//vectors for determining future positions of target of thing to evade
  PVector futureP;
  PVector avoid;
  
  float wAngle;//the wander angle


  //constructor
  Vehicle(float x, float y, float r, float ms, float mf, float ma) {
    //setting up the vectors
    acc = new PVector(0, 0);
    vel = new PVector(0, 0);
    loc = new PVector(x, y);
    forward = new PVector(0, 0);
    right = new PVector(0, 0);

    //setting up the floats
    radius = r;
    maxSpd = ms;
    maxFor = mf;
    mass = ma;
    debug = false;//default it is off
    futureP = new PVector();
    avoid = new PVector();
    wAngle = 0.0;

  }

  float Radius() {//self explanitory
    return radius;
  }
  //the location/position
  PVector Loc() {
    return loc;
  }

  Boolean Debug() {//used for turning off/on debug lines

    return debug;
  }

  PVector Vel() {

    return vel;
  }



  //abstract methods
  abstract void calcSteerForces();
  abstract void display();

  //used for determining if the vehicle is out of bounds(go back in bounds)
  PVector OutBounds() {
    PVector toCenter = new PVector(width/2, height/2);//the center
    PVector seekBounds = new PVector(0, 0);
    float backSpd = 1.8;
    //checkign to see if inbounds
    //if object is off to the left side
    if (loc.x < 80) {
      PVector pos = PVector.sub(loc, toCenter);
      pos.normalize();
      pos.mult(backSpd);
      seekBounds = PVector.sub(vel, pos);
    }
    //if objects if off the right side
    else if (loc.x > width-80) {
      PVector pos = PVector.sub(loc, toCenter);
      pos.normalize();
      pos.mult(backSpd);
      seekBounds = PVector.sub(vel, pos);
    }
    //if object is up
    if (loc.y < 80) {
      PVector pos = PVector.sub(loc, toCenter);
      pos.normalize();
      pos.mult(backSpd);
      seekBounds = PVector.sub(vel, pos);
    }
    //if object is down
    else if (loc.y > height-80) {
      PVector pos = PVector.sub(loc, toCenter);
      pos.normalize();
      pos.mult(backSpd);
      seekBounds = PVector.sub(vel, pos);
    }
    //if object is inbounds
    if ((loc.y >= 80 && loc.y <= height - 80 ) && (loc.x >= 80 && loc.x <= width -80)) {
      seekBounds.mult(.7);//setting it to .7. Currently in bounds.
    }
    return seekBounds;
  }

  //used for avoiding obstacles in the object's path
  PVector avoidObstacle(PVector pos, float rad, float safeDist) {
    PVector desiredVel = new PVector();
    PVector steer = new PVector(0, 0); 
    PVector vecCenter = PVector.sub(pos, loc);
    float dist = loc.dist(pos);
    //if obstacle is without of reach, then safe
    if (dist > safeDist) {
      return new PVector(0, 0);
    }
    //if obstacles in behind object, then safe
    if (vecCenter.dot(forward) < 0) {
      return new PVector(0, 0);
    }
    float dotDist = vecCenter.dot(right);
    float dotDistAbsolute = abs(dotDist);
    //if obstacle is farther off to the side, then safe
    if ((radius + rad) <dotDistAbsolute) {
      return new PVector(0, 0);
    }
    //calculating what irection to go in 
    if (dotDist > 0) {//on right, steer to left
      PVector negRight = PVector.mult(right, -1);
      desiredVel = PVector.mult(negRight, maxSpd);
      steer= PVector.sub(desiredVel, vel);
      steer.mult(safeDist/dist);
    } else if (dotDist < 0) {//on the left, steer to right
      desiredVel = PVector.mult(right, maxSpd);  
      steer= PVector.sub(desiredVel, vel);
      steer.mult(safeDist/dist);
    }
    //returns the vector for it to steer awa from object
    return steer;
  }


  //used for updating the steering forces, applying movement, and zeroing out acc
  void Update() {
    //calculating all steering forces
    calcSteerForces();
    //adjusting position 
    acc.limit(1);
    vel.add(acc);
    vel.limit(maxSpd);
    loc.add(vel);

    //calculating forward
    forward = vel.copy();
    forward.normalize();
    //calculating right
    right = forward.copy();
    right.rotate(PI/2);

    //resetting acceleration
    acc.mult(0);
  }


  //applying forces
  void ApplyForce(PVector force) {
    acc.add(PVector.div(force, mass));
    acc.limit(.8);
  }


  //PURSUE
  //Takes in location of the target, and steps ahead a few frames to get future position
  //returns a vector to be used 
  //FIX THIS
  PVector Pursue(PVector target, PVector tarVel) {
    float dist = PVector.dist(target, loc);
    float pAhead = dist/6;
    PVector velAhead = tarVel.copy();
    velAhead.mult(pAhead);//will predict a little farther the father the human is from the zombie
    futureP = PVector.add(target,velAhead);


//if debug is on will show it as a black circle with a flesh color line around it
    if (debug== true) {
      stroke(#FFFFFF);//the color of the line that expresses me right now
      line(loc.x, loc.y, futureP.x, futureP.y);
      //center is future position
      ellipseMode(CENTER);
      //noFill();
      stroke(#E5B5C9);
      ellipse(futureP.x, futureP.y, 30, 30);
    }
    //passes the future position into seek so will move the zombie that way
    return seek(futureP);
  }



  //seeking the target's position
  PVector seek(PVector target) {
    PVector desiredVel = PVector.sub(target, loc);
    desiredVel.normalize();
    desiredVel.mult(maxSpd);
    PVector steer = PVector.sub(desiredVel, vel);


    //returning the steering vector
    return steer;
  }


//used for evading the future position of the zombie
PVector Evade(PVector zomLoc, PVector zomVel){
      float dist = PVector.dist(zomLoc, loc);
    float pAhead = dist/3;//frames to look ahead based on distance from the zombie
    PVector velAhead = zomVel.copy();
    
    velAhead.mult(pAhead);//will predict a little farther the father the human is from the zombie
    avoid = PVector.add(zomLoc,velAhead);

//if debug is on will show it as a black circle with a green around it
    if (debug== true) {
       stroke(#FFFFFF);
      line(loc.x, loc.y, avoid.x, avoid.y);
      //center is future position
       stroke(#49FF03);
      ellipseMode(CENTER);
      //noFill();
      ellipse(avoid.x, avoid.y, 30, 30);
    }
    
  return flee(avoid);
}


  //fleeing from target
  PVector flee(PVector target) {
    PVector desiredVel = PVector.sub(loc, target);
    PVector steer = new PVector();
    if (PVector.dist(loc, target) <= 250) {
      desiredVel.normalize();
      desiredVel.mult(maxSpd);
      steer = PVector.sub(desiredVel, vel);//for fleeing
    } else if (PVector.dist(loc, target) >250) {
      steer.mult(0);
    }

    //returning the steering vector
    return steer;
  }

//the object will wander in a semi-random direction based on angle
PVector Wander(){
  float angle = vel.heading();
 wAngle += random(-.2,.21);//the range of change will be small so it is more smooth
 PVector wanderLoc = vel.copy();//location to wander in the circle
 wanderLoc.normalize();
 wanderLoc.mult(100);//location of circle
 wanderLoc.add(loc);//adding the circle to the object's location
 PVector circleAngle = new PVector(50*cos(angle + wAngle), 50*sin(angle+wAngle));//the angle the object will wander in
 PVector wanderTo = PVector.add( circleAngle,wanderLoc);//adding the location vector from the angle to the object's location
 
 //if debug mode is on, show the circle of change
 if(debug==true){
  stroke(#00FCF6);
  ellipseMode(CENTER);
  ellipse(wanderLoc.x,wanderLoc.y, 50,50);
  line(wanderLoc.x,wanderLoc.y, wanderTo.x,wanderTo.y);
  stroke(#A9F702);
  line(loc.x,loc.y,wanderLoc.x,wanderLoc.y);
   
 }
 return seek(wanderTo);
 

}


  void DebugFROn() {//turns the right and forward lines on
    if (debug == true) {
      //displaying right
      stroke(#FF0000);
      strokeWeight(5);
      PVector tempLine = right.copy();//takes a temp copy of the right
      tempLine.mult(50);//used for sdisplaying a larger right vector
      line(loc.x, loc.y, loc.x + tempLine.x, loc.y + tempLine.y);
      PVector tempFLine = forward.copy();//takes a copy of the forward line used for debugging
      stroke(#000EFF);
      tempFLine.mult(50);
      line(loc.x, loc.y, loc.x + tempFLine.x, loc.y + tempFLine.y);
      noStroke();
    }
  }

  //switching debug on and off
  void debugSwitch() {
    if (debug== true) {
      debug= false;
    }
    //turning bedug on
    //hail the zombie overlord
    else if (debug == false) {
      debug = true;
    }
  }
}