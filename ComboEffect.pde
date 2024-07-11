class ComboEffect
{
  int value;
  float yPos;
  boolean active;
  
  public ComboEffect( int v )
  {
    value = v;
    yPos = height*0.9;
    active = true;
  }
  
  public void moveUp()
  {
    text( "+" + value, width/2, yPos );
    
    yPos -= height*0.002;
    
    if( yPos <= height*0.8 )
    {
      score += value;
      active = false;
    }
  }
}
