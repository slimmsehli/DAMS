#include "cli_parser.h"
#include "simcore.h"
#include <iostream>
#include <exception>

int main(int argc,char* argv[]) {
    auto config = parse_arguments(argc, argv);
    if (!config) {
        std::cerr << "Error: Failed to parse command-line arguments.\n";
        return 1;
    }else {
        std::cout << "[INFO] Parsed arguments successfully.\n";
    }
    if (config->show_help) {
        print_help();
        return 0; // Zero exit code indicates success
    }
    try {
        simcore sim(*config);
        sim.run();
    } catch (const std::exception& e) {
        std::cerr << "Fatal error during simulation: " << e.what() << '\n';
        return 1;
    }

    return 0;
}