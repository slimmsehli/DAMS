#pragma once
#include "cli_parser.h"



class simcore {
    public:
        explicit simcore(const config& config1);
        void run();
    private:
        config cfg;

        void step1_initialize(); // this for parsing netlist digital and analog
        void step2_hiearchy_analysis(); // this for hiearchy analysis and determine the dig/ana partitions
        void step3_boundries(); // this for detecting boundries and adding IE
        void step4_sim(); // start simulation

    };

