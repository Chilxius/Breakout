class Balloon
{
  float xPos, yPos;
  float speed;
  int type;
  boolean popped;
  
  public Balloon()
  {
    type=int(random(4));
    
    if(int(random(2))==1)
    {
      xPos = -100;
      speed = 4;
    }
    else
    {
      xPos = width+100;
      speed = -4;
    }
    yPos = 50;
  }
  
  void moveAndDraw()
  {
    if(popped)
      return;
      
    xPos+=speed;
    
    tint(pickColor());
    if( speed > 0 )
      image(balloonPic,xPos,yPos);
    else
      image(balloonPic2,xPos,yPos);
    noTint();
  }
  
  color pickColor()
  {
    switch(type)
    {
      case 0: return color(150,0,0);
      case 1: return color(100,100,100);
      case 2: return color(200,170,0);
      case 3: return color(0,0,200);
      default: return color(0);
    }
  }
}
