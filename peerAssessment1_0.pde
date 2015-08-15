import controlP5.FrameRate;
import java.util.Iterator;
import java.awt.Color;

//moving buildings animation
//Backgound music used from the source : https://www.freesound.org/people/UncleSigmund/sounds/30149/

int baseHeight, baseWidth; //dimensions of building
float buildingSpawnDuration,cloudSpawnDuration; //duration after which new building or cloud will be generated
float buildingSpawnTimer,cloudSpawnTimer;  //timer to count the number of frames after the last spawn
float timerIncrement;  //the value with which the timer will be incremented
int marginOfRandomness;  //randomness in the dimensions of the building, windows, size of cloud etc.
float speed;  //current speed of playback and the speed of animation
int volume;  //current volume of playback
Maxim maxim;    
AudioPlayer player;
ArrayList<Building> buildings;
ArrayList<Cloud> clouds;

Color buildingColorDay;
Color buildingColorNight;
Color buildingColor;
Color backgroundColorDay;
Color backgroundColorNight;
Color backgroundColor;
Color cloudColor;
Color windowColorDay;
Color windowColorNight;
Color windowColor;
Color sunColor;
Color moonColor;
Color sunOrMoonColor;

boolean day;

void setup()
{  
  noStroke();
  day=true;
  speed=25;volume=50;
  maxim = new Maxim(this);
  player = maxim.loadFile("music.wav");
  player.setLooping(true);
  player.speed(map(speed,0,100,1,2));
  player.volume(map(volume,0,100,0,1));
  player.play();  
  buildingColorDay=new Color(255,255,255,255);
  buildingColorNight=new Color(100,100,100,255);
  buildingColor=new Color(255,255,255,255);
  backgroundColorDay=new Color(105,214,250,255);
  backgroundColorNight=new Color(0,0,0,255);
  backgroundColor=new Color(105,214,250,255);
  cloudColor=new Color(175,175,175,200);
  windowColor=new Color(0,0,0,255);
  windowColorDay=new Color(50,50,50,255);  
  windowColorNight=new Color(255,255,255,255);
  sunColor=new Color(255,255,0,255);
  moonColor=new Color(255,255,255,255);
  sunOrMoonColor=new Color(255,255,0,255);
  timeChanged();  //if user clicks on the sun/moon the time changes from day to night or vice versa
  size(400,400);
  baseHeight=100;
  baseWidth=50;
  marginOfRandomness=10;
  buildingSpawnDuration=30;
  cloudSpawnDuration=300;
  timerIncrement=1;
  buildingSpawnTimer=cloudSpawnTimer=0;
  buildings=new ArrayList<Building>();
  clouds=new ArrayList<Cloud>();
}

void mouseClicked()
{
  if(overCircle(100,150,50))  //check if the sun/moon was clicked
  {
    day=!day;
    timeChanged();
  }
}
void mouseDragged()
{
  int val=overSlider(10,10,100,15);  //check if the speed slider was dragged
  if(val!=-1)
  {    
    speed=val;    
    timerIncrement=map(speed,0,100,0,4);
    player.speed(map(speed,0,100,1,2));    
  }
  val=overSlider(width-110,10,100,15);  //check if the volume slider was dragged
  if(val!=-1)
  {    
    volume=val;
    baseHeight=100+(volume-50);
    player.volume(map(volume,0,100,0,1));
  }
}
void draw()
{      
  background(backgroundColor.getRed(),backgroundColor.getGreen(),backgroundColor.getBlue(),backgroundColor.getAlpha());
  drawSunOrMoon(sunOrMoonColor);
  drawSlider(10,10,(int)speed);
  drawSlider(width-110,10,volume);
  buildingSpawnTimer+=timerIncrement;
  cloudSpawnTimer+=timerIncrement;
  if(buildingSpawnTimer>=buildingSpawnDuration)
  {
    buildingSpawnTimer=0;
    Building b=new Building(baseHeight,baseWidth,width,height);
    b.generateRandom(marginOfRandomness);
    buildings.add(b);
  }
  if(cloudSpawnTimer>=cloudSpawnDuration)
  {
    cloudSpawnTimer=0;
    Cloud c=new Cloud();
    c.generateCloud();    
    clouds.add(c);
  }
  Iterator<Building> iBuilding = buildings.iterator();
  while (iBuilding.hasNext()) {
    Building building = iBuilding.next();    
    building.x-=2*(speed/25);
    building.drawBuilding();
    if ((building.x+building.w)<=-10){
        iBuilding.remove();
    }
  }
  
  Iterator<Cloud> iCloud = clouds.iterator();
  while (iCloud.hasNext()) {
    Cloud cloud = iCloud.next();
    cloud.updateCentres();
    cloud.drawCloud();
    if ((cloud.centres[0][0])<=-100){
        iCloud.remove();
    }
  }
}

class Building{  
  float h,w;
  float x,y;
  int numberOfWindowRows,numberOfWindowColumns;
  float windowWidth,windowHeight;
  int windowPadding;
  
  Building(int baseH,int baseW,int initialX,int initialY)
  {
    h=baseH;
    w=baseW;
    x=initialX;
    y=initialY;    
    numberOfWindowRows=(int)random(5,10);
    numberOfWindowColumns=(int)random(1,5);
    windowPadding=(int)random(4,8);    
  }
  void generateRandom(int marginOfRandomness)
  {
    h=randomize(h,marginOfRandomness*3);
    w=randomize(w,marginOfRandomness);
    windowWidth=(w-windowPadding*(numberOfWindowColumns+1))/numberOfWindowColumns;
    windowHeight=(h-windowPadding*(numberOfWindowRows+1))/numberOfWindowRows;    
  }
  
  void drawBuilding()
  {
    noStroke();
    fill(buildingColor.getRed(),buildingColor.getGreen(),buildingColor.getBlue(),buildingColor.getAlpha());
    rect(x,y-h,w,h);
    drawWindows();
  }
  void drawWindows()
  {
    float windowX=x+windowPadding,windowY=y-h+windowPadding;   
    fill(windowColor.getRed(),windowColor.getGreen(),windowColor.getBlue(),windowColor.getAlpha());    
    noStroke();
    for(int i=0;i<numberOfWindowColumns;i++)
    {
      windowY=y-h+windowPadding;
      for(int j=0;j<numberOfWindowRows;j++)
      {
        rect(windowX,windowY,windowWidth,windowHeight,0);        
        windowY+=windowHeight+windowPadding;
      }
      windowX+=windowWidth+windowPadding;      
    }    
  }
}

class Cloud
{
  int cloudSize;
  float[][] centres;  
  Cloud()
  {    
    cloudSize=(int)random(10,20);
  }   
  void generateCloud()
  {
     centres=new float[cloudSize][3];
     centres[0][0]=width+100;    //x
     centres[0][1]=(int)random(50,height/3); //y
     centres[0][2]=(int)random(20,40);    //radius
     for(int i=1;i<cloudSize;i++)
     {
       centres[i][0]=(int)randomize(centres[i-1][0],(int)centres[i-1][2]*3/4);
       centres[i][1]=(int)randomize(centres[i-1][1],(int)centres[i-1][2]*3/4);
       centres[i][2]=(int)random(20,40);       
     }
  }
  void drawCloud()
  {
    fill(cloudColor.getRed(),cloudColor.getGreen(),cloudColor.getBlue(),cloudColor.getAlpha());
    noStroke();
    ellipseMode(CENTER);
    for(int i=0;i<cloudSize;i++)
    {
      ellipse(centres[i][0],centres[i][1],centres[i][2],centres[i][2]);
    }    
  }
  void updateCentres()
  { 
    if(frameCount%2==0)
    {
      for(int i=0;i<cloudSize;i++)
      {
        centres[i][0]-=(speed/25);
      }
    }
  }
}

float randomize(float value,int marginOfRandomness) 
{
  int randomSign;    
  int[] signs = { 1,0,-1 };
  randomSign=signs[(int)random(3)];
  return value+(randomSign*random(marginOfRandomness));
}

void drawSunOrMoon(Color c)
{
  fill(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
  ellipseMode(CENTER);
  ellipse(100,150,50,50);
}
boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}
int overSlider(int x, int y, int w, int h)  {
  if (mouseX >= x && mouseX <= x+w && 
      mouseY >= y && mouseY <= y+h) {
    return mouseX-x;
  } else {
    return -1;
  }
}
void timeChanged()
{
  if(day)
  {
    sunOrMoonColor=sunColor;
    backgroundColor=backgroundColorDay;
    windowColor=windowColorDay;
    buildingColor=buildingColorDay;
  }
  else
  {
    sunOrMoonColor=moonColor;
    backgroundColor=backgroundColorNight;
    windowColor=windowColorNight;
    buildingColor=buildingColorNight;
  }
}
void drawSlider(int xPosition,int yPosition, int value)
{
  fill(255,255,255,200);
  rect(xPosition,yPosition,100,4);
  rectMode(CENTER);  
  rect(xPosition+value,yPosition+2,5,15);
  rectMode(CORNER);  
}
