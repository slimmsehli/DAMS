#include "simcore.h"
#include <iostream>


simcore::simcore(const config& config1) : cfg(config1) {}

void simcore::run(){
    std::cout << "[INFO]" << " Starting simulation \n\n";
    step1_initialize();
    step2_hiearchy_analysis();
    step3_boundries();
    step4_sim();
};

void simcore::step1_initialize() {
    std::cout << "[INFO] Step 1: Initializing simulation...\n";
    // Implementation for parsing netlist digital and analog
};
void simcore::step2_hiearchy_analysis() {
    std::cout << "[INFO] Step 2: Performing hierarchy analysis...\n";
    // Implementation for hierarchy analysis and determining the dig/ana partitions
};
void simcore::step3_boundries() {
    std::cout << "[INFO] Step 3: Detecting boundaries and adding IE...\n";
    // Implementation for detecting boundaries and adding IE
};
void simcore::step4_sim() {
    std::cout << "[INFO] Step 4: Starting simulation...\n";
    // Implementation for starting the simulation
};