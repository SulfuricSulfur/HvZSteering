
//MAY TAKE A WHILE TO LOAD UP BECAUSE OF ALL THE TEXTURES!

//creating the arrayList of objects
ArrayList<Human> humans;
ArrayList<Zombie> zombies;

//IMAGES FOR BACKGROUND
PImage dirt;
PImage grass;
PImage antiImage;//antivirus image
//arralist of antiviruses to turn zombies to humans
ArrayList<PVector> antiV;//takes in the location that the user clicked and makes that the location for the anitvirus
//array of obstacles
Obstacle[] obs;
int numObs;//the number of obstacles
int humanNum;//number of humans

Boolean debugOn;//tells if debug mode is on
void setup() {
  size(1000, 1000);
//implamenting background textures
grass = loadImage("grass.png");
dirt= loadImage("BackgroundDirt.jpg");

  //setting up the array of obstacles
  numObs = int(random(4, 11));
  obs = new Obstacle[numObs];
  for (int i =0; i<numObs; i++) {
    obs[i] = new Obstacle(random(180, width-181), random(180, height-181));  
    //set the known location of obstacles for humans and zombies in another loop
  }
  //setting up arraylist of antivirus, starts out with nothing in it.
  antiV = new ArrayList<PVector>();
  antiImage = loadImage("antivirus.png");

  //setting up arraylist for humans
  humans = new ArrayList<Human>();
  humanNum = int(random(7, 17));
  for (int i = 0; i < humanNum; i++) {
    PVector tempLoc = new PVector(random(250, width-100), random(250, height-100));
    //making sure that the humans don't spawn ontop of any obstacles
    for (int k =0; k < numObs; k++) {
      float dist = PVector.dist(tempLoc, obs[k].Pos());//finding the distance(giving space between object and human)
      float otherRad = obs[k].Rad();
      otherRad = otherRad*.8;
      //checking to see if they spawn ontop of eachother
      if (dist < otherRad + obs[k].Rad()) {
        tempLoc.x =random(250, width-10);
        tempLoc.y = random(250, height-100);
      }
    }
    //creating the human and adding it to the arraylist
    Human humanses = new Human(tempLoc.x, tempLoc.y, 15, random(2.9, 4.7), 0.56, numObs, 6);
    humans.add(humanses);
  }

  //doing the same but for the first zombie
  //THE ZOMBIE APOCALYPSE HAS BEGUN. HAIL CTHULHU.
  zombies = new ArrayList<Zombie>();
  PVector tempLoc = new PVector(random(100, width-100), random(100, height-100));
  //making sure that the humans don't spawn ontop of any obstacles
  for (int k =0; k < numObs; k++) {//looping through the obstacles
    for (int f = 0; f< humanNum; f++) {//looping through the human array
      //used for checking with obstacles so the zombie
      //doesnt spawn ontop of an obstacle.
      float dist = PVector.dist(tempLoc, obs[k].Pos());
      float otherRad = obs[k].Rad();
      otherRad = otherRad*.8;

      //setting up a collision to see if the zombie spawning in is intersecting a human
      float disH = PVector.dist(tempLoc, humans.get(f).Loc());
      float radH = humans.get(f).Radius();
      //checking to see if the first zombie is ontop of a human
      if (disH < radH + humans.get(f).Radius()) {
        tempLoc.x =random(100, width-100);
        tempLoc.y = random(100, height-100);
      }
      //checking to see if the first zombie is ontop of an obstacle
      if (dist < otherRad + obs[k].Rad()) {
        tempLoc.x =random(100, width-100);
        tempLoc.y = random(100, height-100);
      }
    }
  }
  Zombie pZero = new Zombie(tempLoc.x, tempLoc.y, 15, random(.9, 2.6), 0.19, numObs, 8);//spawning patient zerp
  zombies.add(pZero);//adding to the array list

  //instantiating the array of objects so that the humans and zombies can check for obstacle avoidence
  //seeting it up for the humans
  for (int i =0; i < humans.size(); i++) {
    for (int f = 0; f < numObs; f++) {
      humans.get(i).ObSet(obs[f].Rad(), obs[f].Pos());
    }
  }
  //setting it for the zombie(the one there is so far)
  for (int i =0; i < zombies.size(); i++) {

    for (int f = 0; f < numObs; f++) {
      zombies.get(i).ObSet(obs[f].Rad(), obs[f].Pos());
    }
  }

  //by default, debug mode is off
  debugOn = false;
}

void draw() {

  background(#5D4242);
  image(dirt,0,0);
  grass.resize(860,860);
  image(grass,80,80);
  
  //rectMode(CORNERS);
 // stroke(#10831E);
  //the grass
  //fill(#008951);
  //noStroke();
  //the boundaries
  //rect(80, 80, width-80, height-80);

  //looping and checking the arraylist of humans

  //displaying obstacles
  for (int k =0; k < numObs; k++) {
    obs[k].DrawO();
  }
  
         if(antiV.size() != 0){//if there are antiviruses present
     for(int a = 0; a < antiV.size(); a++){//if zombie gets an antivirus
//stroke(#FF17E1);
//ellipseMode(CENTER);
//ellipse(antiV.get(a).x, antiV.get(a).y,10,10);
 //dawing the antivirus
 antiImage.resize(20,20);
 image(antiImage,antiV.get(a).x-10,antiV.get(a).y-10);
      
    }
     }
  //looping through the arraylist of zombies

  for (int z = 0; z < zombies.size(); z++) {
    zombies.get(z).SetSight(humans);
    zombies.get(z).display();
    zombies.get(z).Update();
    zombies.get(z).ChaseReset();
    zombies.get(z).DebugFROn();
    
    
    //for detecting antiviruses
       if(antiV.size() != 0){//if there are antiviruses present
     for(int a = 0; a < antiV.size(); a++){//if zombie gets an antivirus
zombies.get(z).GoForAntivirus(antiV.get(a),antiV.size());

      
    }
     }
    //}
  }


  for (int h = 0; h < humans.size(); h++) {
    for (int z = 0; z < zombies.size(); z++) {
      float dist = PVector.dist(zombies.get(z).Loc(), humans.get(h).Loc());
      if (dist < humans.get(h).Radius() +270) {
        //if the human is within a range of the zombie, the human will run away from it
        humans.get(h).FleeZombie(zombies.get(z).Loc(), zombies.get(z).Vel());
      }
    }
    //updating and displaying the humans
    humans.get(h).Update();
    humans.get(h).display();
    //debug right and forward lines for humans

    humans.get(h).DebugFROn();
  }
  CollDetect();//detecting collision
}


//a method to be called for detecting collision
//to turn humans into zombies
void CollDetect() {
  for (int z = 0; z < zombies.size(); z++) {

    for (int i = 0; i < humans.size(); i++) {
      float dist = PVector.dist(zombies.get(z).Loc(), humans.get(i).Loc());//calculating the distance for collision

      if (dist < humans.get(i).Radius()+zombies.get(z).Radius()) { 
        
          //setting the old location of the human equal to the new zombie
          float x =humans.get(i).Loc().x;
          float y = humans.get(i).Loc().y;
          Zombie zamble = new Zombie(x, y, humans.get(i).Radius(), random(.9, 2.6), 0.19, numObs, 8);//radiuses are all the same so doesnt matter
          //instantiating obstacle avoidence with newly converted zombie

          for (int l = 0; l < numObs; l++) {
            zamble.ObSet(obs[l].Rad(), obs[l].Pos());
          }

          //if debug mode is on while zombie converted, debg for that zombie will be on

          if (debugOn == true) {
            zamble.debugSwitch();
          }

          zombies.add(zamble);//adding the newly converted zombie to the arrayList
          humans.remove(i);//removing the human that was bitten
          //if one zombiues kills a human, all reset so they can chase new humans

          for (int f = 0; f < zombies.size(); f++) {
            zombies.get(f).ChaseReset();
            //zombies.get(f).SwitchChaseFalse();//setting so the zombies are not currently chasing because human was caught
          }
        
      }
    }
  }
  for(int i = 0; i < zombies.size(); i++){
   if(antiV.size() != 0){//if there are antiviruses present
     for(int a = 0; a < antiV.size(); a++){//if zombie gets an antivirus
    float dist = PVector.dist(antiV.get(a),zombies.get(i).Loc()); 
    if(dist < zombies.get(i).Radius()+ 10){
      PVector zomHum = zombies.get(i).Loc();
      //remove the antivirus from the arraylist
      antiV.remove(a);
      
      //making a new human
      Human newHuman = new Human(zomHum.x,zomHum.y,15, random(2.9, 4.7), 0.56, numObs, 6);
               for (int l = 0; l < numObs; l++) {
            newHuman.ObSet(obs[l].Rad(), obs[l].Pos());
          }
          //remove the old zombie and replace it with a new human in its location
          zombies.remove(i);
          humans.add(newHuman);
              if (debugOn == true) {
            newHuman.debugSwitch();
          }
 
    }
     }
   }
    
  }
}


void keyPressed() {
  //turning debug mode on
  //if (key == CODED) {
    if (keyCode == ENTER) {
      if ( debugOn == false) {
        for (int z = 0; z < zombies.size(); z++) {

          zombies.get(z).debugSwitch();
        }
        for (int h = 0; h < humans.size(); h ++) {

          humans.get(h).debugSwitch();
        }
        debugOn = true;
      }
      //truning debug mode off
      else if ( debugOn == true) {

        for (int z = 0; z < zombies.size(); z++) {
          //switching debug states for zombies
          zombies.get(z).debugSwitch();
        }
        for (int h = 0; h < humans.size(); h ++) {
          //switching states for humans
          humans.get(h).debugSwitch();
        }
        debugOn = false;
        noStroke();
      }
    }
  //}
}

void mouseClicked(){
 if(debugOn == true){
   //you can spawn an antivirus IF there is more than one zombie present
   if(zombies.size() > 1){
     if(antiV.size() < zombies.size()-1){//you cant spawn in more antiviruses than there are zombies
   PVector antiLoc = new PVector(mouseX,mouseY);
  antiV.add(antiLoc); 
     }
   }
   
 }
  
}

//NEED TO IMPLAMENT RIGHT CLICKING = DEBUG ON