class Ball
{
  float xPos, yPos;
  float xSpd, ySpd;
  float size;
  boolean readyToLaunch;
  boolean dead;
  
  public Ball()
  {
    int randBall = int(random(balls.size()));
    xPos = balls.get(randBall).xPos;
    yPos = balls.get(randBall).yPos;
    size = 50;
    xSpd = balls.get(randBall).xSpd;
    ySpd = balls.get(randBall).ySpd;
    readyToLaunch = false;
  }  
  
  public Ball( float x, float y )
  {
    xPos = x;
    yPos = y;
    size = 50;
    readyToLaunch = true;
  }
  
  void moveAndDraw()
  {
    //Move
    if( readyToLaunch )
    {
      xPos = mouseX;
      yPos = paddle.top()-size/2;
    }
    else
    {
      xPos += xSpd*speedMultiplier;
      yPos += ySpd*speedMultiplier;
    }
    
    checkCollisions();
    
    //Draw
    if( powerUp[2] > 0 )
    {
      int frame = millis()%1000;
      if( frame < 250 )
        image(powBall[1],xPos,yPos,powerUp[2]+50,powerUp[2]+50);
      else if( frame < 500 )
        image(powBall[2],xPos,yPos,powerUp[2]+50,powerUp[2]+50);
      else if( frame < 750 )
        image(powBall[3],xPos,yPos,powerUp[2]+50,powerUp[2]+50);
      else
        image(powBall[4],xPos,yPos,powerUp[2]+50,powerUp[2]+50);
    }
    fill(120);
    stroke(220);
    circle(xPos,yPos,size);
    if( powerUp[0] > 0 )
      image(powBall[0],xPos,yPos);
    if( powerUp[1] > 0 )
    {
      translate(xPos,yPos);
      rotate(angle);
      image(powBall[5],0,0);
      rotate(-angle);
      translate(-xPos,-yPos);
    }
  }
  
  void bounce( char direction, int str )
  {
    if( powerUp[1] > 0 )
    {
      if( str == 1 )
        return;
      if( str <= 3 && powerUp[0] > 0 )
        return;
    }
    if( direction == '1' )
      ySpd = -abs(ySpd);
    if( direction == '2' )
      xSpd = -abs(xSpd);
    if( direction == '7' )
      ySpd = abs(ySpd);
    if( direction == '8' )
      xSpd = abs(xSpd);
    if( direction == '3' )
    {
      adjustHSpeed( xPos, xPos-50 );
      adjustVSpeed();
      ySpd = -abs(ySpd); //make speed negative
    }
    if( direction == '4' )
    {
      adjustHSpeed( xPos, xPos+50 );
      adjustVSpeed();
      ySpd = -abs(ySpd); //make speed negative
    }
    if( direction == '5' )
    {
      adjustHSpeed( xPos, xPos-50 );
      adjustVSpeed();
      ySpd = abs(ySpd); //make speed positive
    }
    if( direction == '6' )
    {
      adjustHSpeed( xPos, xPos+50 );
      adjustVSpeed();
      ySpd = abs(ySpd); //make speed positive
    }
  }
  
  void hitBrick( Brick b )
  {
    if(soundReady())
      sfx[ int(random(5)) ].play();
    if( powerUp[0] > 0 )
      b.strength-=2;
    if( powerUp[2] > 0 )
      for( Brick br: bricks )
      {
        if( br != b && dist( xPos, yPos, br.xPos, br.yPos ) < powerUp[2]+50 )
          br.strength--;
      }
    b.strength--;
    if(b.bonus>-1)
    {
      powerups.add( new PowerUp( b.xPos, b.yPos, b.bonus ) );
      b.bonus = -1;
    }
  }
  
  void checkCollisions()
  {
    //Right Wall
    if( xPos > width-size/2 )
    {
      xPos = width-size/2;
      xSpd = -xSpd;
      if(!readyToLaunch && soundReady())
        sfx[7].play();
    }
    
    //Left Wall
    if( xPos < size/2 )
    {
      xPos = size/2;
      xSpd = -xSpd;
      if(!readyToLaunch && soundReady())
        sfx[7].play();
    }
    
    //Top
    if( yPos < size/2 )
    {
      yPos = size/2;
      ySpd = -ySpd;
      if(!readyToLaunch && soundReady())
        sfx[7].play();
      if(readyForNewLevel)
        generateNewLevel();
    }
    
    //Paddle top
    if( yPos+size/2 >= paddle.top() && yPos+size/2 < paddle.bottom() && xPos > paddle.left() && xPos < paddle.right() )
    {
      yPos = paddle.top()-size/2;
      
      adjustHSpeed( xPos, paddle.xPos );
      adjustVSpeed();
      if(!readyToLaunch && soundReady())
        sfx[6].play();
      
      if(readyForNewLevel)
        generateNewLevel();
    }
    
    //Balloon
    if( !balloon.popped && dist( xPos, yPos, balloon.xPos, balloon.yPos ) < 50 )
    {
      balloon.popped = true;
      if(soundReady())
        sfx[5].play();
      powerups.add( new PowerUp( balloon.xPos, balloon.yPos, balloon.type ) );
    }
    
    //Miss
    if( yPos > height+size/2 )
    {
      if( balls.size() == 1 )
      {
        lives--;
        scoreMulti=1;
        readyToLaunch = true;
      }
      else
        dead = true;
    }
  }
  
  void adjustHSpeed( float bX, float pX )
  {
    float speed = ( bX - pX );
    xSpd = speed/15;
  }
  
  void adjustVSpeed()
  {
    ySpd = -(10-abs(xSpd)/5);
  }
}
