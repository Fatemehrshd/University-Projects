/*
    Implementing FCFS CPU scheduling algorithm using C++
                
    --- Fatemeh Rashidi -- 610399131 
        Dr. Fatemeh Halataei -- Winter 2023 ---
*/

#include <iostream>
using namespace std;

void initialization(float *arr, int size) {
    for (int i = 0 ; i < size; i++)
        arr[i] = 0;
    return;
}

void initializeFinishingTime(float *finishingTime, float *arrivalTime,
                             float *burstTime, float *waitingTime,
                            int index) {
        finishingTime[index] = 
        arrivalTime[index] + waitingTime[index] + burstTime[index];
    return;
}

void computeWaitingTime(float *waitingTime, float *turnAroundTime,
                float *arrivalTime, float *busrtTime,
                float *finishingTime, int index) {

    if (index == 0) {
        waitingTime[index] = 0;
    }
    else {
        float tmp = arrivalTime[index] - finishingTime[index-1];
        if (tmp > 0) {
                waitingTime[index] = 0;
        } else {
            waitingTime[index] = -1.0 * tmp;
        }
    }
    return;
}

void computeTurnAroundTime(float *watingTime, float *burstTime, 
                           float *turnAroundTime, int index) {
        turnAroundTime[index] = watingTime[index] + burstTime[index];
    return;
}


float averageTime(float *time, int size) {
    float sum = 0;
    for (int i = 0; i  < size; i++) {
        sum += time[i];
    }
    return sum / (float)size;
}


int main() {
    // Get number of processes from user
    int numberOfProcesses;
    cout << "Enter number of processes: \n"; 
    cin >> numberOfProcesses;

    int *processes = new int[numberOfProcesses];
    float *arrivalTime = new float[numberOfProcesses];
    float *burstTime = new float[numberOfProcesses];
    float * finishingTime = new float[numberOfProcesses];

    for (int i = 0 ; i < numberOfProcesses ; i++) {
        cout << "Enter process's id, arrival time , and its busrt time: \n";
        cin >> processes[i] >> arrivalTime[i] >> burstTime[i];
    }

    // -------------------------------------------------------------- //

    float *waitingTime = new float[numberOfProcesses];
    float *turnAroundTime = new float[numberOfProcesses];


    // Make all members of watingTime and turnAroundTime arrays zero.
    initialization(waitingTime, numberOfProcesses);
    initialization(turnAroundTime, numberOfProcesses);

    // Initialize first element of finishing time array with 0
    finishingTime[0] = burstTime[0];

    // Compute wating time, turnaround time, and 
    // finishing time for each process
    for (int i = 0; i < numberOfProcesses ; i++) {
        computeWaitingTime(waitingTime, turnAroundTime, 
                           arrivalTime, burstTime, finishingTime, i);
        computeTurnAroundTime(waitingTime, burstTime, turnAroundTime, i);
        initializeFinishingTime(finishingTime, arrivalTime, 
                                burstTime, waitingTime, i);
        // finishingTime[i] = arrivalTime[i] + waitingTime[i] + burstTime[i];
    }

    // Compute wating time and turn around time for all processes.

    for (int i = 0 ; i < numberOfProcesses ; i++) {
        cout << "Processes\tArrival Time\tBurst Time\tWating Time"
        "\tTurn Around Time\tFinishing Time\n";
        cout << "\t" << processes[i] << "\t\t" << arrivalTime[i] 
        << "\t\t" << burstTime[i] 
        << "\t\t" << waitingTime[i] << "\t\t\t" << turnAroundTime[i] <<
        "\t\t" << finishingTime[i] << "\n";
    }

    // Compute average wating time and average turn around time 
    // for all processes in FCFS algorithm
    cout << "\nAverage wating time is: " << 
    averageTime(waitingTime, numberOfProcesses) <<"\n";

    cout << "Average turn around time: " << 
    averageTime(turnAroundTime, numberOfProcesses);

    return 0;

} // end main