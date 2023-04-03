// Copyright INTEGNANO University of Paris Saclay 2023
// written by:  Théo Ballet 

#include "Vpinaipple_system.h"
#include "verilated.h"

int main(int argc, char **argv){
    VerilatedContext *contextp = new VerilatedContext;

    contextp->commandArgs(argc, argv);

    Vpinaipple_system *top = new Vpinaipple_system{contextp};

    while (!contextp->gotFinish()) {
        top->eval();
    }

    delete top;
    delete contextp;
    return 0;
}