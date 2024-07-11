//All bricks 100x50

class Brick
{
  float xPos, yPos; //of middle
  int strength;
  int bonus;
  
  public Brick( float x, float y )
  {
    xPos = x;
    yPos = y;
    strength = 1;
    bonus = -1;
  }
  
  public void drawBrick()
  {
    chooseColor();
    rect(xPos, yPos, 100,50,10);
    if( bonus == 0 )
      image( powBrick[0], xPos, yPos );
    if( bonus == 3 )
      image( powBrick[1], xPos, yPos );
  }
  
  private void chooseColor()
  {
    switch(strength)
    {
      case 1: fill(200,100,100); break;
      case 2: fill(100,100,200); break;
      case 3: fill(100,200,100); break;
      case 4: fill(200,200,100); break;
      case 5: fill(100,200,200); break;
      case 6: fill(250,150,0  ); break;
      case 7: fill(90 ,70 ,30 ); break;
      case 8: fill(255,0  ,200); break;
      case 9: fill(0); break;
      default: fill(255);
    }
  }
  
  public int hitBy( Ball b )
  {
    //Corners
    if( dist( b.xPos, b.yPos, xPos+50, yPos-25 ) < b.size/3 ) //top right
      return 3;
    if( dist( b.xPos, b.yPos, xPos-50, yPos-25 ) < b.size/3 ) //top left
      return 4;
    if( dist( b.xPos, b.yPos, xPos+50, yPos+25 ) < b.size/3 ) //bottom right
      return 5;
    if( dist( b.xPos, b.yPos, xPos-50, yPos+25 ) < b.size/3 ) //bottom left
      return 6;
    
    //Top and bottom
    if( b.xPos >= xPos-50 && b.xPos <= xPos+50 ) //is in horizontal bounds
    {
      if( b.yPos+b.size/2 >= yPos-25 && b.yPos <= yPos) //hit top
        return 1;
      if( b.yPos-b.size/2 <= yPos+25 && b.yPos >= yPos) //hit bottom
        return 7;
    }
    
    //Sides
    if( b.yPos >= yPos-25 && b.yPos <= yPos+25 ) //is in horizontal bounds
    {
      if( b.xPos+b.size/2 >= xPos-50 && b.xPos <= xPos) //left
        return 2;
      if( b.xPos-b.size/2 <= xPos+50 && b.xPos >= xPos) //right
        return 8;
    }
    
    return 0;
  }
}
