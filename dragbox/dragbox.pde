import java.util.ArrayList;
import java.util.Collections;

int trialCount = 10; //this will be set higher for the bakeoff
final float screenPPI = 126; //what is the Pixels Per Inch of the screen you are using 

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float windowPadding = 0; //some padding from the sides of window, set later
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500; //global variable for the X position of the logo
float logoY = 500; //global variable for the Y position of the logo
float logoS = 50f; //global variable for the Size position of the logo
float logoR = 0; //global variable for the Rotation position of the logo

float centerDisplaceX = 0;
float centerDisplaceY = 0;
boolean drag = false;
float angleDisplace = 0;
float radiusDisplace = 0;
boolean rotate = false;

PFont smallFont;
PFont largeFont;

int prevClick = -250;
int prevDoubleClick = -250;

private class Destination
{
  float x = 0; //the X position of this destination square
  float y = 0; //the Y position of this destination square
  float s = 0; //the Size position of this destination square
  float r = 0;//the Rotation position of this destination square
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1200, 800);
  rectMode(CENTER);
  largeFont = createFont("Arial", inchToPix(.3f)); //sets the font to Arial that is 0.3" tall
  smallFont = createFont("Arial", inchToPix(.1f)); //sets the font to Arial that is 0.3" tall
  
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //Don't change this! 
  windowPadding = inchToPix(2f); //stops destination squares generating with centers/corners outside this area

  //create a bunch of random destination squares. Don't change this!
  for (int i=0; i<trialCount; i++) 
  {
    Destination d = new Destination();
    d.x = random(windowPadding, width-windowPadding); //set a random x with some padding
    d.y = random(windowPadding, height-windowPadding); //set a random y with some padding
    d.r = random(0, 360); //random rotation between 0 and 360
    d.s = inchToPix((float)random(1,12)/4.0f); //increasing size from 0.25" up to 3.0" 
    destinations.add(d);
    //println("created destination with values: " + d.x + "," + d.y + "," + d.r + "," + d.s);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}

void draw() {
  background(40); //background is dark grey. Can't change this.
  noStroke();
  
  //next two lines are just for testing if your PPI is set correctly. It should be 1x1" on your screen if correct. This can be removed for the Bakeoff.
  //fill(200,200,200);
  //rect(width/2,height/2, inchToPix(1f), inchToPix(1f)); 
  
  fill(200);
  textFont(largeFont);
  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.r)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.s, d.s);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoR)); //rotate using the logo square as the origin
  noStroke();
  if (mouseInsideSquare() && !mouseInsideHandle(0.5 * logoS * sqrt(2), 45)){
    fill(60, 100, 255, 192);
    if (millis() - prevDoubleClick < 250) {
      stroke(255);
    }
  }
  else fill(60, 60, 192, 192);
  rect(0, 0, logoS, logoS);
  noStroke();
  fill(255);
  textFont(smallFont);
  text("LOGO",0,0);
  ellipseMode(CENTER);
  if (mouseInsideHandle(0.5 * logoS * sqrt(2), 45)) fill(255, 255, 60, 192);
  else fill(60, 192, 60, 192);
  ellipse(logoS * 0.5, logoS * 0.5, inchToPix(0.1), inchToPix(0.1));
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  textFont(largeFont);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  text("Double click to submit", width/2, height - inchToPix(.4f));
}

//my example design for control, which is a terrible design
void scaffoldControlLogic()
{
  if (mousePressed && drag) {
    logoX = mouseX + centerDisplaceX;
    logoY = mouseY + centerDisplaceY;
  }
  if (mousePressed && rotate) {
    centerDisplaceX = logoX - mouseX;
    centerDisplaceY = logoY - mouseY;
    logoS = max((radiusDisplace + sqrt(centerDisplaceX * centerDisplaceX + centerDisplaceY * centerDisplaceY)) * sqrt(2.0), logoS * 0.5 * sqrt(2));
    logoR = degrees(atan2(-centerDisplaceY, -centerDisplaceX)) - 45 + angleDisplace;
  }
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  centerDisplaceX = logoX - mouseX;
  centerDisplaceY = logoY - mouseY;
  radiusDisplace = 0.5 * logoS * sqrt(2) - sqrt(centerDisplaceX * centerDisplaceX + centerDisplaceY * centerDisplaceY);
  angleDisplace = (logoR + 45 - degrees(atan2(-centerDisplaceY, -centerDisplaceX)));
  println("angleDisplace " + angleDisplace);
  if (mouseInsideSquare() && !mouseInsideHandle(0.5 * logoS * sqrt(2), 45)) drag = true;
  if (mouseInsideHandle(0.5 * logoS * sqrt(2), 45)) rotate = true;
}

void mouseReleased()
{
  drag = false;
  rotate = false;
  //check to see if user clicked middle of screen within 1 inches, which this code uses as a submit button. This is a terrible design you should probably replace.
  if (millis() - prevClick < 250 && mouseInsideSquare() && !mouseInsideHandle(0.5 * logoS * sqrt(2), 45)) {
    prevDoubleClick = millis();
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
  prevClick = millis();
}

public boolean mouseInsideSquare() {
  float v1x = cos(radians(logoR));
  float v1y = sin(radians(logoR));
  float v2x = v1y;
  float v2y = -1 * v1x;
  float dotProd1 = v1x * (mouseX - logoX) + v1y * (mouseY - logoY);
  float dotProd2 = v2x * (mouseX - logoX) + v2y * (mouseY - logoY);
  return (abs(dotProd1) < (logoS * 0.5) && abs(dotProd2) < (logoS * 0.5));
}

public boolean mouseInsideHandle(float r, float theta) {
  float x = logoX + (r * cos(radians(theta + logoR)));
  float y = logoY + (r * sin(radians(theta + logoR)));
  float dx = mouseX - x;
  float dy = mouseY - y;
  //if (mousePressed) println("Distance: (" + dx + ", " + dy + ") -> " + sqrt(dx * dx + dy * dy));
  return sqrt(dx * dx + dy * dy) < inchToPix(0.1);
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.r, logoR)<=5;
  boolean closeSize = abs(d.s - logoS)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.r, logoR)+")");
  println("Close Enough Size: " +  closeSize + " (logo Z = " + d.s + ", destination Z = " + logoS +")");
  println("Close enough all: " + (closeDist && closeRotation && closeSize));

  return closeDist && closeRotation && closeSize;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
