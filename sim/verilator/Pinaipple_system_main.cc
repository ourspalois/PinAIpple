// Copyright INTEGNANO University of Paris Saclay 2023
// written by:  Théo Ballet 

#include "Vpinaipple_system.h"
#include "verilated.h"
#include <iostream>

int main(int argc, char **argv){
    VerilatedContext *contextp = new VerilatedContext;
    
    contextp->commandArgs(argc, argv);

    Vpinaipple_system *top = new Vpinaipple_system{contextp};
    std::cout << "Starting simulation" << std::endl;
    while (!contextp->gotFinish()) {
        top->eval();
    }
    std::cout << "Simulation ended" << std::endl;

    delete top;
    delete contextp;
    return 0;
}