/*
 * Methods for displaying and drawing onto screen
*/

void drawMenu(){
  background(255,20,0);
  push();
  
  noStroke();
  textFont(menuFont);
  textAlign(CENTER);
  textSize(80);
  
  fill(0);
  text("F l a m e  K e e p e r", width/2, height/2);
  textFont(font);
  text("Press [SPACE] to Start", width/2, height/2 + 100);
  
  pop();
}

void drawBackground(){
  background(0,0,15);
  image(nightSky, 0, 0, width, 500);
  tint(155,0,100);
  image(treesBack, 0, height/4, width, height/2);
  tint(0,0,255);
  image(treesFront, 0, height/4, width, height/2);
  tint(255);
}

void drawGameOver(){
  background(0);
  fill(255);
  textAlign(CENTER);
  text("You lost :(", width/2, height/2);
  text("Press [SPACE] to restart", width/2, height/2 + 60);
}

void drawWin(){
  temperature = 8500;
  drawFire();
  
  if(currentLevel == 2) {
    drawRain();
  }
  
  textAlign(CENTER);
  fill(255);
  
  text("YOU WIN!", width/2, 100);
  textSize(46);
  text("Press [SPACE] to continue", width/2, 700);
}

ArrayList<FireParticle> particles = new ArrayList<>();

boolean isAllUpperCase(String str) {
  if (str == null || str.isEmpty()) {
      return false;
  }
  return str.equals(str.toUpperCase());
}

void displayUserInput(){
  textAlign(LEFT);
  stroke(100);
  strokeWeight(5);
  fill(0);
  rect(textX1, textY1, textX2, textY2);
  
  fill(255); // font colour
  if(isAllUpperCase(typedText)){
    fill(255, 165, 0); // fuel word colour
    text(typedText, textX1 + 5, textY1 + 10, textX2, textY2);
  }else if(indexOfBadChar == -1){
    text(typedText, textX1 + 5, textY1 + 10, textX2, textY2); // User input
  }
  else{
    String badChars = typedText.substring(indexOfBadChar);
    String goodChars = typedText.substring(0, indexOfBadChar);
    float goodCharsWidth = textWidth(goodChars);
    
    text(goodChars, textX1 + 5, textY1 + 10, textX2, textY2);
    
    fill(255, 0, 0);
    text(badChars, textX1 + 5 + goodCharsWidth, textY1 + 10, textX2, textY2);
    fill(255);
  }
}

float successThreshold = 10000; // milliseconds
float successTime = 0;

void drawInfo(){
  drawFire();
  
  if (temperature < 7500) {
    successTime = 0; // reset timer when temperature drops below time
    return;
  } 

  if (successTime == 0) {
    successTime = millis(); // player has crossed success threshold here
  }
  
  float elapsed = millis() - successTime;

  if (elapsed >= successThreshold) {
    currentState = State.WIN;
    successTime = 0; // reset
  }
}

float wordY = height/8;
float highestFireParticleY = 800;

void drawCurrentWord(){
  fill(255);
  textAlign(CENTER);
  text(currentWord, width/2, height/8); // Word user needs to type
}

void drawFallingWord(){
  fill(255);
  textAlign(CENTER);
  wordY = wordY+20; // draw the target word falling down screen
  text(currentWord, width/2, wordY);
}

float respawnWidth = 40;
float respawnWordX = 0 + respawnWidth;
float respawnWordSpeed = random(8, 10);

void drawRespawnWord(){
  respawnWordX += respawnWordSpeed;
  
  if(respawnWordX + respawnWidth > width || respawnWordX - respawnWidth < 0){
    respawnWordSpeed = -respawnWordSpeed;
  }
  
  ellipse(respawnWordX, height/8, 40, 40);
}

void drawRain(){
  stroke(74,101,220,90);
  for(int i = 0; i < d.length; i++) {
    d[i].show();
    d[i].update();
  }
}

float fuelX = 0;

void spawnFuelWord(float speed){
  if(fuelX - textWidth(fuelWord) > width){
    resetFuelWord(); // fuel word moved off the screen
  }
  push();
  
  fill(255, 165, 0);
  textSize(32);
  textAlign(RIGHT);
  
  text(fuelWord, fuelX, height - 25);
  fuelX += speed;
  
  pop();
}

/*
 * Title: Flames that change with temperature
 * Author: Add
 * Source: https://openprocessing.org/@u525660/2635271
 * License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 (CC BY-NC-SA 3.0)
 * License Terms: https://creativecommons.org/licenses/by-nc-sa/3.0
 */


void drawFire(){
  noStroke();
  
  // DRAW ROCKS
  fill(80);
  ellipse(width/2 - 40, 610, 20, 20);
  ellipse(width/2 - 20, 620, 18, 22);
  ellipse(width/2, 625, 25, 20);
  ellipse(width/2 + 25, 620, 20, 20);
  ellipse(width/2 + 40, 610, 15, 20); 
  
  colorMode(HSB, 100);
   ArrayList<FireParticle> nextParticles = new ArrayList<>();
  
  for(int i = 0; i < particles.size(); i++){
    FireParticle particle = particles.get(i);
    
    if(particle.temperature > 0) particle.drawParticle(); // don't draw if temp < 0
    
    // save particles for next frame
    if(particle.pos.y >= -particle.radius){
      nextParticles.add(particle);
    }
  }
  // add new fire particles to fire
  int numFireParticles = 100;
  for(int i = 0; i < numFireParticles; i++){
    float radius = random(10) * sq(random(1));
    nextParticles.add(new FireParticle(width/2, 600, radius, temperature));
  }
  particles = nextParticles;
  
  colorMode(RGB, 255, 255, 255);
}

float[] tempColor(float temperature) {
  float alphaStandard = 100;
  if (temperature < 1000) { // RED
    return new float[] {0, 100, 100, alphaStandard * (temperature - 200) / 1000};
  } else if (temperature < 3000) { // ORANGE
    return new float[] {100 * (1.0 / 12) * ((temperature - 1000) / 2000), 100, 100, alphaStandard};
  } else if (temperature < 6500) { // YELLOW
    return new float[] {100 * (1.0 / 12), 100 * (1 - (temperature - 3000) / 3500), 100, alphaStandard};
  } else if (temperature < 10000) { // WHITE
    return new float[] {100 * (7.0 / 12), 100 * (temperature - 6500) / 3500, 100, alphaStandard};
  } else { // BLUE
    return new float[] {100 * (7.0 / 12), 100, 100, alphaStandard};
  }
}
