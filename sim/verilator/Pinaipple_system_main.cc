// Copyright INTEGNANO University of Paris Saclay 2023
// written by:  Théo Ballet 

#include "Pinaipple_system.h"
#include <iostream>

int main(int argc, char **argv){
    PinaippleSystem testsystem(
        "TOP.pinaipple_system.u_ram.u_ram.gen_generic.u_impl_generic",
      1024 * 1024);
    std::cout << "Pinaipple system created" << std::endl ;
    return testsystem.Main(argc, argv);
}