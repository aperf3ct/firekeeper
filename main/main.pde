import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Map;
import rita.*;

// STATES
enum State{
  MENU,
  LEVEL,
  WIN,
  GAMEOVER
}
 
State currentState = State.MENU;
int currentLevel = 1;

String typedText = "";
Map<String, Object> wordsRules; 
String currentWord;
String fuelWord;
float nextDangerSpawn = random(10000, 15000);
int indexOfBadChar = -1;

// TEXT BOX x AND y VALUES
float textX1;
float textY1;
float textX2;
float textY2;

// SPEED
Queue<KeystrokeEvent> keystrokes;
int windowSize = 10000; // sliding window size
float smoothedSpeed = 1;
float smoothingFactor = 0.01;
float rawSpeed;

// ACCURACY
Queue<KeystrokeEvent> accuracyWindow;
int accuracyWindowSize = 10000;
float smoothedAccuracy = 1;

int temperature = 4500;

boolean drawingRespawn = false;

// BACKGROUNDS
PImage treesBack;
PImage treesFront;
PImage nightSky;

PFont menuFont;
PFont font;

drop[] d;

void setup() {
  size(800, 800);
  frameRate(30);
  textSize(50);
  pixelDensity(1);
  textAlign(LEFT);
  rectMode(CORNERS);
  
  // RiTA library rules
  wordsRules = new HashMap();
  wordsRules.put("maxLength", 8);
  
  currentWord = RiTa.randomWord(wordsRules);
  fuelWord = RiTa.randomWord(wordsRules).toUpperCase();
  
  // Set text box coords
  textX1 = width/2 - 150;
  textY1 = height - 150;
  textX2 = width / 2 + 150;
  textY2 = height - 90;

  keystrokes = new ArrayDeque<>();
  accuracyWindow = new ArrayDeque<>();
  
  // Intialise external files - images and fonts
  treesFront = loadImage("PineForestParallax/MorningLayer1.png");
  treesBack = loadImage("PineForestParallax/MorningLayer2.png");
  nightSky = loadImage("night.png");
  font = createFont("Slabo27px-Regular.ttf", 50);
  menuFont = createFont("Beside Horizon.otf", 50);
  textFont(font);
  
  // Create array filled with raindrop objects
  int numOfRain = 200;
  d = new drop[numOfRain];
  for(int i = 0; i < d.length; i ++) {
    d[i] = new drop(random(width), random(0, 800), random(5));
  }
}

void draw() {
  switch(currentState){
    case MENU:
      drawMenu();
      break;
      
    case LEVEL:
      drawBackground();
      
      if(millis() >= nextDangerSpawn){
        spawnFuelWord(currentLevel * 3);
      }
      
      removeOldTimestamps(millis());
      removeOldAccuracyTimestamps(millis());
      
      computeSpeed();
      computeAccuracy();
      
      updateTemperature();
      
      // DEBUG TEMPERATURE
      //fill(255, 255, 255);
      //text(temperature + "°C", 10, 50);
      
      drawInfo();
      
      // LEVEL 3 LOGIC
      if(currentLevel != 3){
        drawCurrentWord();
      }else{
        if(!wordBurnt()){
          drawFallingWord();
          drawingRespawn = false;
        }else{
          drawRespawnWord();
          drawingRespawn = true;
        }
      }
      
      displayUserInput();
      // LEVEL 2 LOGIC
      if(currentLevel == 2) drawRain(); // drawn last to cover info
      
      if(typedIsCorrect()) updateWord();
      
      break;
      
    case GAMEOVER:
      drawGameOver();
      break;
      
    case WIN:
      drawBackground();
      drawWin();
      break;
  }
}


void keyTyped() {
  if(currentState == State.MENU && key == ' '){
    currentState = State.LEVEL; // start game
  }
  
  else if(currentState == State.GAMEOVER && key == ' '){
    resetLevel();
    currentState = State.LEVEL; // restart from death
  }
  
  else if(currentState == State.WIN && key == ' '){
    resetLevel();
    // switch levels on win
    if(currentLevel == 1){
      currentState = State.LEVEL;
      currentLevel = 2;
    } else if(currentLevel == 2){
      currentState = State.LEVEL;
      currentLevel = 3;
    }else{
      currentState=State.MENU;
      currentLevel = 1;
    }
  }
  
  else if (key == BACKSPACE) {
    if (typedText.length() > 0) {
      typedText = typedText.substring(0, typedText.length() - 1);
    }
    // check if bad chars have been deleted
    if(typedText.length() <= indexOfBadChar){
      indexOfBadChar = -1;
    }
  } 
  
  else if (key >= 32 && key <= 122) {
    // append printable ASCII characters
    typedText += key;
    
    if(Character.isUpperCase(key)){
      boolean isCorrect = checkFuelWord();
      if(isCorrect){
        temperature += 1500;
        typedText = "";
        resetFuelWord();
      }
      return;
    }
    
    boolean isCorrect =  keystrokeIsCorrect();
   
    KeystrokeEvent event = new KeystrokeEvent(millis(), isCorrect);
    keystrokes.offer(event);
    accuracyWindow.offer(event);
    
    // log the index of first incorrect keystroke
    if(!isCorrect && indexOfBadChar == -1){
      indexOfBadChar = typedText.length() - 1;
    }
  }
}

void mousePressed(){
  if(drawingRespawn == false) return;
  
  float respawnWordY = height/8;
  
  // bounding box collision check: mouse coords against circle  coords
  if(mouseX >= respawnWordX - respawnWidth && mouseX <= respawnWordX + respawnWidth &&
     mouseY >= respawnWordY - respawnWidth && mouseY <= respawnWordY + respawnWidth){
      wordY = height/8;
    }
  
}

boolean typedIsCorrect(){
  if(!typedText.equals(currentWord)) {
    return false;
  }
  return true;
}

boolean keystrokeIsCorrect(){
  int typedSize = typedText.length();
  
  if (typedSize == 0)  return true;
  else if(typedSize > currentWord.length()) return false; // prevents index out of bound exception
  else if(typedText.equals(currentWord.substring(0, typedSize))) return true;
  else return false; 
}

boolean checkFuelWord(){
  if(!typedText.equals(fuelWord)) return false;
  return true;
}

boolean wordBurnt(){
  if(wordY >= highestFireParticleY) {
    return true;
  }
  return false;
}

void resetLevel(){
  resetFuelWord();
  updateWord();
  
  temperature = 4500;
  smoothedSpeed = 1;
  smoothedAccuracy = 1;
  indexOfBadChar = -1;
  particles.clear();
}

void resetFuelWord(){
  fuelX = 0;
  fuelWord = RiTa.randomWord(wordsRules).toUpperCase();
  nextDangerSpawn = millis() + random(10000, 15000);
}

void updateWord(){
  typedText = ""; // reset user inputted string
  currentWord = RiTa.randomWord(wordsRules);
  wordY = height/8; // reset level 3 word height
  highestFireParticleY = 800; 
}

void updateTemperature(){
  constrain(temperature, 0, 10000);
  
  temperature *= 0.994; // decay
  temperature += 16 * smoothedSpeed * smoothedAccuracy; // rate of growth
  
  if(temperature <= 1600) currentState = State.GAMEOVER;
}
