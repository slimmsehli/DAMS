#pragma once
#include <optional>
#include <string>
#include <utility>
#include <vector>

// struct to hold the argument passed by the user
struct config {
    bool show_help = false;
    std::string netlist;
    std::string simulation_time;
    std::vector<std::pair<std::string, std::string>> options;
};

// parsing argv and argc into the config struct, this return null point if it fails
std::optional<config> parse_arguments(int argc, char* argv[]);

void print_help();

