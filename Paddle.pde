class Paddle
{
  float xPos, yPos;
  float xSize, ySize;
  
  public Paddle()
  {
    yPos = 800;
    xSize = 300;
    ySize = 50;
  }
  
  void movePaddle()
  {
    xPos = mouseX;
  }
  
  void drawPaddle()
  {
    stroke(200);
    fill(100);
    rect( xPos, yPos, xSize, ySize);
  }
  
  public float top()
  {
    return yPos-ySize/2;
  }
  public float bottom()
  {
    return yPos+ySize/2;
  }
  public float right()
  {
    return xPos+xSize/2;
  }
  public float left()
  {
    return xPos-xSize/2;
  }
}
