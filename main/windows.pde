/*
  Compute the speed, and accuracy 
  Utlises sliding windows to take the most recent inputs
  Each sliding window removes on its own interval
*/

void computeSpeed(){
  
  int numCorrect = 0;
  for(KeystrokeEvent e : keystrokes){
    if(e.wasCorrect()) numCorrect += 1;
  }
  
  rawSpeed = numCorrect / (windowSize / 1000.0); // num of keystrokes per second
  smoothedSpeed = lerp(smoothedSpeed, rawSpeed, smoothingFactor);
}

void computeAccuracy(){
  if(accuracyWindow.size() == 0) return;
  
  // count num of correct keystrokes in queue
  float numCorrect = 0.0;
  for(KeystrokeEvent e : accuracyWindow){
    if(e.wasCorrect()) numCorrect += 1;
  }
  
  float accuracyRatio = numCorrect / (float) accuracyWindow.size();
  smoothedAccuracy = lerp(smoothedAccuracy, accuracyRatio, 0.01);
}

void removeOldTimestamps(int currentTime){
  if(keystrokes.peek() == null) return;
  
  // check for old timestamps
  int cutOffPeriod = currentTime - windowSize;
  while(keystrokes.peek() != null && keystrokes.peek().getTime() < cutOffPeriod){
    keystrokes.poll();
  }
}

void removeOldAccuracyTimestamps(int currentTime){
  if(accuracyWindow.peek() == null) return;
  
  // check for old timestamps
  int cutoffPeriod = currentTime - accuracyWindowSize;
  while(accuracyWindow.peek() != null && accuracyWindow.peek().getTime() < cutoffPeriod){
    accuracyWindow.poll();
  }
}
