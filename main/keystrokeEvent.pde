class KeystrokeEvent{
  private int time;
  private boolean correct;
  
  // Constructor
  KeystrokeEvent(int time, boolean correct){
    this.time = time;
    this.correct = correct;
  }
  
  int getTime(){
    return time;
  }
  
  boolean wasCorrect(){
    return correct;
  }
  
}
