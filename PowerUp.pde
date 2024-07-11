class PowerUp
{
  float xPos, yPos;
  int type;
  
  public PowerUp( float x, float y, int t )
  {
    xPos = x;
    yPos = y;
    type = t;
  }
  
  void moveAndDraw()
  {
    switch( type )
    {
      case 0: fill(150,0,0);     break;  //Lava Ball
      case 1: fill(100,100,100); break;  //Breakthrough
      case 2: fill(200,170,0);   break;  //Plasma Ball
      case 3: fill(0,0,200);     break;  //Multi-ball
      default: fill(0);
    }
    yPos+=5;
    
    rect(xPos, yPos, 50, 30, 20 );
  }
  
  boolean hitPaddle()
  {
    if( yPos >= paddle.top() && yPos < paddle.bottom() && xPos > paddle.left() && xPos < paddle.right() )
    {
      return true;
    }
    return false;
  }
}
