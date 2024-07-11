/***********************************************
*                                              *
*                 Breakout                     *
*                                              *
*  Designed to assist with a student project.  *
* Sounds are time-limited; there will be a     *
* minimum time delay between each sound to     *
* avoid sound-skipping.                        *
*                                              *
***********************************************/
import processing.sound.*;

ArrayList<Ball> balls = new ArrayList<Ball>();
ArrayList<Brick> bricks = new ArrayList<Brick>();
ArrayList<PowerUp> powerups = new ArrayList<PowerUp>();
//Ball ball = new Ball(600,700);
Paddle paddle = new Paddle();

//Balloon data
PImage balloonPic, balloonPic2;
Balloon balloon = new Balloon();
int nextBalloon = 30000;

//Game Data
int level = 1;
int lives = 5;
float speedMultiplier = 1;
color currentTint = color(255), newTint = color(0,0,150);
int tintProgress = 2000;
boolean gameOver = false;

//Display Data
int ballType = 0; //for later
int brickType = 0; //for later
PImage back;

//Sound Data
SoundFile [] sfx = new SoundFile[8];
int soundDelay = 100;  // <- a compromise to avoid sound skipping

//For when new bricks spawn
boolean readyForNewLevel = false;

//Combo system
int score = 0;
int combo = 0;
float scoreMulti = 1;
int comboMulti = 0;
float scoreAngle = 0;
ComboEffect ce;
color comboColor = color(random(255),random(255),random(255)), newComboColor = color(random(255),random(255),random(255));
PImage burst;
float burstSize = 0;
int comboCountDown;

//Powerups
int nextPowerup = 10;
int powerDownTimer = 250;
int powerUp[] = {0,0,0};
boolean charging[] = {false,false,false};
color [] powColor = {color(150,0,0),color(100,100,100),color(200,170,0)};
PImage powBall[] = new PImage[6];
float angle;
PImage powBrick[] = new PImage[3];
String powText[] = {"LAVA","DRILL","PLASMA"};

void setup()
{
  size(1100,900);
  rectMode(CENTER);
  imageMode(CENTER);
  
  //Initial bricks
  addRowOfBricks( 0,4 );
  addRowOfBricks( 1,5 );
  addRowOfBricks( 2,5 );
  addRowOfBricks( 3,5 );
  addRowOfBricks( 4,4 );
  addBonusToBricks();
  
  sfx[0] = new SoundFile(this, "0.wav" );
  sfx[1] = new SoundFile(this, "1.wav" );
  sfx[2] = new SoundFile(this, "2.wav" );
  sfx[3] = new SoundFile(this, "3.wav" );
  sfx[4] = new SoundFile(this, "4.wav" );
  sfx[5] = new SoundFile(this, "pop.wav" ); sfx[5].amp(0.8);
  sfx[6] = new SoundFile(this, "click.wav" );
  sfx[7] = new SoundFile(this, "wall.wav" );
  
  back = loadImage("backdrop.png"); back.resize(width,0);
  burst = loadImage("burstClean.png"); burst.resize(400,300);
  
  powBall[0] = loadImage("lavaBall.png"); powBall[0].resize(50,0);
  powBall[1] = loadImage("plasma1.png");  powBall[1].resize(100,0);
  powBall[2] = loadImage("plasma2.png");  powBall[2].resize(100,0);
  powBall[3] = loadImage("plasma3.png");  powBall[3].resize(100,0);
  powBall[4] = loadImage("plasma4.png");  powBall[4].resize(100,0);
  powBall[5] = loadImage("spike-1.png");   powBall[5].resize(60,0);
  
  powBrick[0] = loadImage("lavaBrick.png");  powBrick[0].resize(100,0);
  powBrick[1] = loadImage("multiBrick.png"); powBrick[1].resize(100,0);
  
  balloon.popped = true;
  balloonPic = loadImage("b2.png");      balloonPic.resize(100,0);
  balloonPic2 = loadImage("b1.png");   balloonPic2.resize(100,0);
  
  balls.add( new Ball(600,700) );
  noCursor();
  
  ce = new ComboEffect(0); //floating numbers
  ce.active = false;
}

void draw()
{
  //Score section behind background
  drawScore();
  
  //Background image(s)
  tint(currentTint);
    imageMode(CORNER);
  image(back,0,0);
  if( tintProgress < height )
  {
    tintProgress+=10;
    tint(newTint);
    image(back.get(0,0,width,tintProgress),0,0);
    if(tintProgress>=height)
    {
      currentTint=newTint;
    }
  }
  imageMode(CENTER);
  noTint();
  
  //Lives and upgrades
  drawHUD();
  
  //Ball(s)
  angle+=0.1; //for sawblades
  for(Ball b: balls)
    b.moveAndDraw();
  for( int i = 0; i < balls.size(); i++ )
    if( balls.get(i).dead )
      balls.remove(i);
  checkForNoBalls(); // <- edge case for if all balls lost at once
  
  //Bricks
  for(Brick b: bricks)
    b.drawBrick();
   
  //Ball-brick collisions
  for( int i = 0; i < bricks.size(); i++ )
  {
    for( int j = 0; j < balls.size(); j++ )
    {
      int hitState = bricks.get(i).hitBy( balls.get(j) );
  
      balls.get(j).bounce( char(hitState+48), bricks.get(i).strength );
  
      if( hitState != 0 )
      {
        addCombo();
        balls.get(j).hitBrick(bricks.get(i));//.strength--;
        break;
      }
    }
  }
  
  //Clean bricks
  for( int i = 0; i < bricks.size(); i++ )
    if( bricks.get(i).strength<=0 )
    {
      addPoint();
      nextPowerup--;
      if( bricks.get(i).bonus > -1 )
      {
        powerups.add( new PowerUp(bricks.get(i).xPos, bricks.get(i).yPos, bricks.get(i).bonus ) );
      }
      else if( nextPowerup <= 0 )
      {
        nextPowerup = int(random(30,45));
        powerups.add( new PowerUp(bricks.get(i).xPos,bricks.get(i).yPos, int(random(4))) );
      }
      bricks.remove(i);
    }
  
  //Reset
  if( bricks.size() == 0 )
    readyForNewLevel = true;
    
  //Powerups
  for( PowerUp p: powerups )
    p.moveAndDraw();
  for( int i = 0; i < powerups.size(); i++ )
  {
    if( powerups.get(i).hitPaddle() )
    {
      if( powerups.get(i).type != 3 )
      {
        powerUp[powerups.get(i).type] = max(0,powerUp[powerups.get(i).type]); //<>//
        charging[powerups.get(i).type]=true;
      }
      else if( powerups.get(i).type == 3 )
      {
        if( balls.size()<9 ) balls.add( new Ball() );
        if( balls.size()<9 ) balls.add( new Ball() );
      }
      powerups.remove(i);
      i--;
    }
  }
  
  //Powerup Counters
  if( millis() > powerDownTimer )
  {
    powerDownTimer = millis()+250;
    powerUp[0]--;
    powerUp[1]--;
    powerUp[2]--;
  }
  
  //Power Charge
  for(int i = 0; i < charging.length; i++ )
  {
    if( charging[i] )
      powerUp[i]+=2;
    if( powerUp[i] >= 100 )
      charging[i] = false;
  }
  
  //Next Balloon
  if( millis() > nextBalloon )
  {
    nextBalloon += 30000;
    balloon = new Balloon();
  }
  
  //Combo Counter
  if( millis() > comboCountDown )
  {
    if( comboMulti > 0 )
      ce = new ComboEffect( combo*comboMulti );
    combo = 0;
    comboMulti = 0;
    burstSize = 0;
  }
  
  paddle.movePaddle();
  paddle.drawPaddle();
  
  balloon.moveAndDraw();
}

void addPoint()
{
  score+=scoreMulti;
  //combo++;
  //comboCountDown = millis() + 1500;
  //burstSize+=40;
  //if( burstSize >= 400 )
  //{
  //  burstSize = 0;
  //  comboMulti++;
  //  comboColor = newComboColor;
  //  newComboColor = color(random(255),random(255),random(255));
  //}
}

void addCombo()
{
  //score+=scoreMulti;
  combo++;
  comboCountDown = millis() + 1500;
  burstSize+=40;
  if( burstSize >= 400 )
  {
    burstSize = 0;
    comboMulti++;
    comboColor = newComboColor;
    newComboColor = color(random(255),random(255),random(255));
  }
}

boolean soundReady()
{
  if( soundDelay < millis() )
  {
    soundDelay =  millis() + 100;
    return true;
  }
  return false;
}

void checkForNoBalls()
{
  if( balls.size() == 0 )
    balls.add( new Ball(mouseX,700) );
}

void drawScore() //behind background
{
  //Score Area
  fill(0);
  noStroke();
  circle(width/2,height*0.8,400);
    
  //Level
  fill(200);
  textAlign(CENTER);
  textSize(35);
  text( "Level: "+level, width/2, height*0.63 );
  
  //Combo burst
  if(comboMulti > 0)
  {
    tint(comboColor);
    image(burst, width/2, height*0.89);
    tint(newComboColor);
    image( burst, width/2, height*0.89, burstSize, burstSize*3/4 );
  }
  
  
  //Combo Effect (ghost numbers)
  if(ce.active)
    ce.moveUp();
  
  //Score
  textSize(35+(score/5000.0*35));  //from 35 to 35
  text( score, width/2, height*0.77 );
  
  //Multiplier
  textSize(35);
  text( "Multiplier: "+int(scoreMulti), width/2, height*0.67 );
  
  //Combo
  fill(0);
  if( comboMulti > 0 )
    text( "Combo: "+combo + "x" +comboMulti, width/2, height*0.9 );
}

void drawHUD() //in foreground
{
  //Lives
  fill(150);
  for( int i = 0; i < lives; i++ )
    circle( (width-30)-(i*50), height-30, 35 );
  
  //Powerups
  textSize(20);
  stroke(200);
  strokeWeight(4);
  for( int i = 0; i < 3; i++ )
  {
    //println( i + ": " + powerUp[i] );
    fill(powColor[i]);
    arc( width/2+((i-1)*350), 0, 125, 70, PI-(PI*(powerUp[i]/100.0)), PI);
    
    noFill();
    ellipse(width/2+((i-1)*350), 0, 125, 70);
    text( powText[i], width/2+((i-1)*350), 20 );
  }
  strokeWeight(1);
  noStroke();
}

void addRowOfBricks( int row, int type )
{
  int yVal = 150+row*50;
  
  switch( type )
  {
    case 0:
    case 1: //===========
      for( int i = 50; i < width; i+=100)
        bricks.add( new Brick( i, yVal ) );
      break;
    case 2: //= = = = = = 
      for( int i = 50; i < width; i+=200)
        bricks.add( new Brick( i, yVal ) );
      break;
    case 3: // = = = = = 
      for( int i = 150; i < width; i+=200)
        bricks.add( new Brick( i, yVal ) );
      break;
    case 4: //===     ===
      for( int i = 50; i < width; i+=100)
        if( i < 300 || i > 800 )
          bricks.add( new Brick( i, yVal ) );
      break;
    case 5: //    ====    
      for( int i = 50; i < width; i+=100)
        if( i > 400 && i < 700 )
          bricks.add( new Brick( i, yVal ) );
      break;
    case 6: //==  ===  ==
      for( int i = 50; i < width; i+=100)
        if( i < 200 || i > 900 || ( i > 400 && i < 700 ) )
          bricks.add( new Brick( i, yVal ) );
      break;
    case 7: //     3     
      bricks.add( new Brick( 550, yVal ) );
      bricks.add( new Brick( 550, yVal ) );
      bricks.add( new Brick( 550, yVal ) );
      break;
    case 8: // 4        4
      bricks.add( new Brick( 150, yVal ) );
      bricks.add( new Brick( 150, yVal ) );
      bricks.add( new Brick( 150, yVal ) );
      bricks.add( new Brick( 150, yVal ) );
      bricks.add( new Brick( 950, yVal ) );
      bricks.add( new Brick( 950, yVal ) );
      bricks.add( new Brick( 950, yVal ) );
      bricks.add( new Brick( 950, yVal ) );
      break;
    case 9: //22222222222
      for( int i = 50; i < width; i+=100)
      {
        bricks.add( new Brick( i, yVal ) );
        bricks.add( new Brick( i, yVal ) );
        bricks.add( new Brick( i, yVal ) );
      }
      break;
  }
}

void addRowOfBricks( int row ) //row is y index
{
  addRowOfBricks( row, int(random(10)) );
}

void consolidateBricks()
{
  for( int i = 0; i < bricks.size()-1; i++ )
  {
    for( int j = 0; j < bricks.size(); j++ )
    {
      if( j != i && bricks.get(i).xPos == bricks.get(j).xPos && bricks.get(i).yPos == bricks.get(j).yPos )
      {
        bricks.get(i).strength += bricks.get(j).strength;
        bricks.remove(j);
        if( bricks.size() <= i ) //   <- to fix an overflow chrash
          return;
      }
    }
  }
}

void generateNewLevel()
{
  level+=1;
  speedMultiplier*=1.05;
  scoreMulti++;
  readyForNewLevel = false;
  for( int i = 0; i < level+2; i++ )
    addRowOfBricks( int(random(5)) );
  consolidateBricks();
  consolidateBricks(); //Sometimes needs a second run - fixes things for now
  addBonusToBricks();
  
  newTint = color( random(50,255), random(50,255), random(50,255) );
  tintProgress = -5;
}

void addBonusToBricks()
{
  for( Brick b: bricks )
    if( b.strength >= 10 )
      b.bonus = 0;
  for( int i = bricks.size()-1; i >= 0; i-=20 )
    bricks.get(i).bonus = 3;
}

//Checks to see if there is already a brick at this position, upgrades it if there is
boolean matchingBrick( Brick b1 )
{
  for( Brick b2: bricks )
  {
    if( b1.xPos == b2.xPos && b1.yPos == b2.yPos )
    {
      b2.strength++;
      return true;
    }
  }
  return false;
}

void mousePressed()
{
  for( Ball b: balls )
    if( b.readyToLaunch )
    { 
      b.readyToLaunch = false;
      b.xSpd = random(-10,10);
    }
    
  if( !balloon.popped && dist( mouseX, mouseY, balloon.xPos, balloon.yPos ) < 50 )
  {
    balloon.popped = true;
    if(soundReady())
      sfx[5].play();
    powerups.add( new PowerUp( balloon.xPos, balloon.yPos, balloon.type ) );
  }
}
