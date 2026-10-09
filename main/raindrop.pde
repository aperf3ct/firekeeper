class drop {
  float x, y, z;
  
  // Constructor
  drop(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  void update() {
    // map depth to speed: closer drops fall faster (10) and farther ones slower (4)
    float spd = map(z, 0, 5, 10, 4); 
    y = y + spd;
    
    // if the drop has fallen past the bottom, send it back above the top
    if(y > height + 10) {
      y = - 10;
      x = random(width); // random x to avoid looking repetitive
    }
  }
  
  void show() {
    // closer drops get a thicker, longer streak (10), farther ones are thin (2)
    float t = map(z, 0, 5, 10, 2);
  
    strokeWeight(t);
    line(x, y, x, y + t * 2); // extends line length (t * 2) so bigger drops also look longer

  }
  
}
