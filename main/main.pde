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
 
State currentState = State.WIN;
int currentLevel = 2;

String typedText = "";
Map<String, Object> wordsRules; 
String currentWord;
String dangerWord;
float nextDangerSpawn = random(5000, 15000);
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

// BACKGROUNDS
PImage treesBack;
PImage treesFront;
PImage nightSky;

PFont menuFont;
PFont font;

int numOfRain = 200;
drop[] d;

void setup() {
  size(800, 800);
  frameRate(30);
  textSize(50);
  textAlign(LEFT);
  rectMode(CORNERS);
  
  wordsRules = new HashMap();
  wordsRules.put("maxLength", 8);
  currentWord = RiTa.randomWord(wordsRules);
  dangerWord = RiTa.randomWord(wordsRules).toUpperCase();
  
  textX1 = width/2 - 150;
  textY1 = height - 150;
  textX2 = width / 2 + 150;
  textY2 = height - 90;

  keystrokes = new ArrayDeque<>();
  accuracyWindow = new ArrayDeque<>();
  
  treesFront = loadImage("PineForestParallax/MorningLayer1.png");
  treesBack = loadImage("PineForestParallax/MorningLayer2.png");
  nightSky = loadImage("night.png");
  font = createFont("Slabo27px-Regular.ttf", 50);
  menuFont = createFont("Beside Horizon.otf", 50);
  textFont(font);
  
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
        spawnDangerWord(currentLevel * 3.5);
      }
      
      removeOldTimestamps(millis());
      removeOldAccuracyTimestamps(millis());
      
      computeSpeed();
      computeAccuracy();
      
      updateTemperature();
      //fill(255, 255, 255);
      //text(temperature + "°C", 10, 50);
      drawInfo();
      if(currentLevel != 3){
        drawCurrentWord();
      }else{
        text("yo", 400, 400);
      }
      
      displayUserInput();
      
      if(currentLevel == 2) drawRain();
      
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
    currentState = State.LEVEL;
  }
  
  else if(currentState == State.GAMEOVER && key == ' '){
    resetLevel();
    currentState = State.LEVEL;
  }
  
  else if(currentState == State.WIN && key == ' '){
    resetLevel();
    
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
      boolean isCorrect = checkDangerWord();
      if(isCorrect) resetDangerWord();
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
    
    else if(isCorrect && typedText.length() != 0){
      indexOfBadChar = -1;
    }
  }
}

boolean typedIsCorrect(){
  if(!typedText.equals(currentWord)) {
    return false;
  }
  //println("correct");
  return true;
}

boolean keystrokeIsCorrect(){
  int typedSize = typedText.length();
  
  if (typedSize == 0)  return true;
  else if(typedSize > currentWord.length()) return false; // prevents index out of bound exception
  else if(typedText.equals(currentWord.substring(0, typedSize))) return true;
  else { return false; }
}

boolean checkDangerWord(){
  if(!typedText.equals(dangerWord)) return false;
  return true;
}

void resetLevel(){
  resetDangerWord();
  updateWord();
  temperature = 4500;
  smoothedSpeed = 1;
  smoothedAccuracy = 1;
  indexOfBadChar = -1;
  particles.clear();
}

void resetDangerWord(){
  typedText = "";
  dangerX = 0;
  dangerWord = RiTa.randomWord(wordsRules).toUpperCase();
  nextDangerSpawn = millis() + random(5000, 15000);
}

void updateWord(){
  typedText = ""; // reset user inputted string
  currentWord = RiTa.randomWord(wordsRules);
}

void updateTemperature(){
  constrain(temperature, 0, 10000);
  
  temperature *= 0.994; // decay
  temperature += 16 * smoothedSpeed * smoothedAccuracy;
  
  if(temperature <= 1600) currentState = State.GAMEOVER;
}
