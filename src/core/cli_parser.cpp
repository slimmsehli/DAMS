#include "cli_parser.h"
#include <iostream>
#include <vector>

void print_help() {
    std::cout << "Simulation CLI Tool v1.0\n"
              << "Usage: simulator [options]\n\n"
              << "Options:\n"
              << "  -h        Show this help message and exit\n"
              << "  -n <arg>  Set the analog circuit netlist (*.cir, *.spi, ...)\n"
              << "  -t <arg>  Set the simulation time to run (by default time extracted from netlist)\n";
}

std::optional<config> parse_arguments(int argc, char* argv[]) {
    config cfg;
    // converts c array into a c++ vector strings for iterations
    std::vector<std::string> args(argv+1, argv+argc);
    if (args.size() == 0) {
        std::cerr << "Error: No argument provided\n";
        cfg.show_help = true;
        return cfg;
    }

    for (size_t i = 0; i < args.size(); ++i) {
        const std::string& flag = args[i];

        if (flag == "-h" || flag == "--help") {
            cfg.show_help = true;
            return cfg;
        }

        if (flag == "-n" || flag == "-t") {
            if (i + 1 >= args.size()) {
                std::cerr << "Error: Missing argument for switch '" << flag << "'\n";
                return std::nullopt;
            }

            const std::string value = args[i + 1];
            std::cout << "[INFO] argument for " << flag << " is " << value << "\n";
            cfg.options.emplace_back(flag, value);

            if (flag == "-n") {
                cfg.netlist = value;
            } else if (flag == "-t") {
                cfg.simulation_time = value;
            }

            ++i; // Skip the next argument since it is the value for this switch
        } else {
            std::cerr << "Error: Unknown switch '" << flag << "'\n";
            return std::nullopt;
        }
    }

    return cfg;
}


