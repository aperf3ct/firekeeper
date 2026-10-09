/*
 * Title: Flames that change with temperature
 * Author: Add
 * Source: https://openprocessing.org/@u525660/2635271
 * License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 (CC BY-NC-SA 3.0)
 * License Terms: https://creativecommons.org/licenses/by-nc-sa/3.0
 */

class FireParticle {
  PVector pos;
  PVector vel = new PVector(2,0).rotate(random(2*PI));
  float radius;
  int temperature;
  
  // Constructor
  FireParticle(float x, float y, float radius, int temp){
    pos = new PVector(x, y);
    this.radius = radius;
    temperature = temp;
  }
  
  void drawParticle(){
    noStroke();
    float[] c = tempColor(temperature);
    fill(c[0], c[1], c[2], c[3]);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
    // update position
    PVector acc = new PVector(random(-0.5, 0.5), -0.2);
    vel.add(acc);
    pos.add(vel);
    
    if(pos.y < highestFireParticleY && temperature > 1000){
      highestFireParticleY = pos.y; // fire height logic for level 3
    }
    
    // temperature decay
    temperature -= 100;
    temperature -= (600 - pos.y) / 2;
    
  }
}
