
//Controls:
//F: full sail, accelerated to max speed
//H: half sail, deccelerates to half speed
//O: steer left
//P: steer right
//A: fire starboard side cannon
//D: fire port side cannon


int scrX = 1280;
int scrY = 720;
int shipW = 70;
int shipH = 70;
float shipXV = 0;
float shipYV = 0;
int shipX = scrX/2;
int shipY = scrY/2;
ArrayList<CannonBall> cBalls = new ArrayList<CannonBall>();
ArrayList<Ship> enemies = new ArrayList<Ship>();
int enemyCooldownNum = 500;
int enemyFireCooldownNum = 100;
int enemyCooldown = 0;
int enemyFireCooldown = 100;

Ship player;
void setup() {
  size(1280, 720);
  strokeWeight(4);
  textSize(60);
  player = new Ship(25, 60, 1, 270*(PI/180));
}

void draw() {
    background(0);
  if(enemyCooldown == 0){ //enemy ship spwning
    int randX = (int)random(0, 1280);
    int randY = (int)random(0,720);
    if(randX>randY)
      randY = 0;
    else
      randX = 0;
    Ship e = new Ship(30, 90, 1, random(10, 80)*(PI/180));
    e.shipX = randX;
    e.shipY = randY;
    enemies.add(e);
    enemyCooldown = enemyCooldownNum;
  }else{
    enemyCooldown--;
  }
  
  //draw enemy ships
  if(enemyFireCooldown == 0){
    for(int i = 0; i<enemies.size(); i++){
      
      enemies.get(i).display(); 
      enemies.get(i).firePort();
      enemies.get(i).fireStarboard();
      enemyFireCooldown = enemyFireCooldownNum;
    }
  }
  else{
    for(int i = 0; i<enemies.size(); i++){
      enemies.get(i).display(); 
      enemyFireCooldown--;
    }
  }  
  
  
  player.display();
  for (int i=0; i<cBalls.size(); i++){
    cBalls.get(i).display();
    if(cBalls.get(i).ballX>scrX||cBalls.get(i).ballY>scrY||cBalls.get(i).ballX<0||cBalls.get(i).ballX<0){
      cBalls.remove(cBalls.get(i));}
  }
  
  shipControl();
}

void detectHits(){
  
}

void shipControl(){ //control script for player ship (this is where the arduino magic should happen)
  if(keyPressed==true){
    switch(key){
      case 'o': player.shipA-=0.005; break;
      case 'p': player.shipA+=0.005; break;
      case 'h': player.shipTV = 0.5; break; //set target velocity via controls
      case 'f': player.shipTV = 1; break;  //Target velocity was originally going to be controller via joystick vertically
      case 'a': player.firePort(); break; //originally to be large red pushbuttons
      case 'd': player.fireStarboard(); break;
    }

  }
}

class CannonBall{
  float ballX;
  float ballY;
  float ballXV; //balls fly at fixed speed
  float ballYV;
  CannonBall(float ballX, float ballY, float ballXV, float ballYV){ //initial conditions
    this.ballX = ballX;
    this.ballY = ballY;
    this.ballXV = ballXV;
    this.ballYV = ballYV;
  }
  void display(){ //update velocity
    fill(155);
    ellipse(ballX-10, ballY-10,10,10);
    ballX += ballXV;
    ballY += ballYV;
  }
}

class Ship{
  int shipW;
  int shipH; 
  float shipTV; //speed being deccelerated to
  float shipV; 
  float shipA; //ship angle
  float shipXV; 
  float shipYV;
  float shipX;
  float shipY;
  float accel; //high number is lower acceleration
  float accelholder;
  int cooldown; //fire cooldown frames
  int cooldownholder; //cooldown remaining
  Ship(int shipW, int shipH, float shipV, float shipA){ //ship size and heading
    this.shipW = shipW;
    this.shipH = shipH;
    this.shipTV = shipV;
    this.shipX = scrX/2;
    this.shipY = scrY/2;
    this.shipA = shipA;
    accel = 6; //higher is lower 
    cooldown = 40;
  }
  
  void display(){
    
    paintShip();
    float deltaV = 0.05;
    if(shipTV != shipV){//if not at target velocity
      if(accelholder==0){
        accelholder = accel;
        if(shipTV>shipV){
          //accel
          shipV+= deltaV; //vel cahnge every update, higher is faster accel, but lower resolution
        }else{
          //deccel
          shipV-= deltaV;
        }
      }else{
        accelholder--;
      }
    }
    shipX += getXV(shipV, shipA);
    shipY += getYV(shipV, shipA);
    
    //prevents ships from going off screen
    if(shipX>scrX){shipX = 0;}
    else if(shipX<0){shipX = scrX;}
    if(shipY>scrY){shipY = 0;}
    else if(shipY<0){shipY = scrY;}
    
    //cooldown
    if(cooldownholder>0){cooldownholder--;}
  }
  
  void paintShip(){
    noStroke();
    //draw ship here
    //every x seconds update shipXV and shipYV, shipX and shipY
    translate(shipX, shipY);
    rotate(shipA+90*(PI/180));
    translate(-shipX, -shipY);
    fill(random(120,150), random(120,150), random(120,150));
    rect(shipX-shipW/2, shipY-shipH/2, shipW, shipH);
    fill(random(80,190), random(80,190), random(80,190));
    triangle(shipX-shipW/2, shipY-shipH/2, shipX+shipW/2, shipY-shipH/2, shipX, shipY-100-shipH/2);
    translate(shipX, shipY);
    rotate(-(shipA+90*(PI/180)));
    translate(-shipX, -shipY);
    //square =  createShape(RECT, shipX-shipW/2, shipY-shipH/2, shipW, shipH);
    //square.draw();
  }
  
  float getXV(float vel, float ang){
    return cos(ang)*vel;
  }
  
  float getYV(float vel, float ang){
    return sin(ang)*vel;
  }
  
  float getRad(float deg){
    return deg*(PI/180);
  }
  
  void firePort(){
    //does this when firing (add cannonballs to arraylist)
    if (cooldownholder>0){
      return;}
    else{
      cooldownholder = cooldown;
      cBalls.add(new CannonBall(shipX, shipY, shipXV+getXV(5, shipA-getRad(90)), shipYV+getYV(5, shipA-getRad(90))));//shoots  port side
    }
  }
  
  void fireStarboard(){
    //does this when firing (add cannonballs to arraylist)
    if (cooldownholder>0){
      return;}
    else{
      cooldownholder = cooldown;
      cBalls.add(new CannonBall(shipX, shipY, shipXV+getXV(5, shipA+getRad(90)), shipYV+getYV(5, shipA+getRad(90))));//shoots  starboard side
    }
  }

  void anchor(){
    //changes internal params to stop ship
  }
   
}
