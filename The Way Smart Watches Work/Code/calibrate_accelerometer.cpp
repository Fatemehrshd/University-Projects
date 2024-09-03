#include <iostream>
#include <Arduino.h>
using namespace std;

// Define x, y, an z pin numbers globally
int xpin, ypin, zpin;

void calibrate_accelerometer() {

    // Define number of samples(here, 100 samples)
    const int numSamples = 100;

    // Define arrays to store x, y, and z values 
    // in each iteration
    float xval[numSamples];
    float yval[numSamples];
    float zval[numSamples];

    float sumx = 0.0;
    float sumy = 0.0;
    float sumz = 0.0;

    for (int i = 0; i < numSamples; i++) {
        xval[i] = float(analogRead(xpin) - 345);
        sumx += xval[i];
        
        yval[i] = float(analogRead(ypin) - 346);
        sumy += yval[i];
        
        zval[i] = float(analogRead(zpin) - 416);
        sumz += zval[i];
    }

    // Cumpute dynamic threshold
    float xavg = sumx / numSamples;
    float yavg = sumy / numSamples;
    float zavg = sumz / numSamples;
}
