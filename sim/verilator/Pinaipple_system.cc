
#include <cassert>
#include <fstream>
#include <iostream>

#include "Vpinaipple_system__Syms.h"
#include "ibex_pcounts.h"
#include "Pinaipple_system.h"
#include "verilated_toplevel.h"
#include "verilator_memutil.h"
#include "verilator_sim_ctrl.h"

PinaippleSystem::PinaippleSystem(const char *ram_hier_path, int ram_size)
    : _ram(ram_hier_path, ram_size, 4) {}

int PinaippleSystem::Main(int argc, char **argv)
{
    std::cout << "Pinaipple System" << std::endl
              << "================" << std::endl
              << std::endl;
    bool exit_app;
    int ret_code = Setup(argc, argv, exit_app);

    if (exit_app)
    {
        return ret_code;
    }

    Run();

    if (!Finish())
    {
        return 1;
    }

    return 0;
}

int PinaippleSystem::Setup(int argc, char **argv, bool &exit_app)
{
    VerilatorSimCtrl &simctrl = VerilatorSimCtrl::GetInstance();

    simctrl.SetTop(&_top, &_top.clk_sys_in, &_top.rst_sys_in,
                   VerilatorSimCtrlFlags::ResetPolarityNegative);

    _memutil.RegisterMemoryArea("ram", 0x0, &_ram);
    simctrl.RegisterExtension(&_memutil);

    exit_app = false;
    return simctrl.ParseCommandArgs(argc, argv, exit_app);
}

void PinaippleSystem::Run()
{
    VerilatorSimCtrl &simctrl = VerilatorSimCtrl::GetInstance();

    std::cout << "Simulation of Pinaipple System" << std::endl
              << "==============================" << std::endl
              << std::endl;

    simctrl.RunSimulation();
}

bool PinaippleSystem::Finish()
{
    VerilatorSimCtrl &simctrl = VerilatorSimCtrl::GetInstance();

    if (!simctrl.WasSimulationSuccessful())
    {
        return false;
    }

    svSetScope(svGetScopeFromName("TOP.pinaipple_system"));

    std::cout << "\nPerformance Counters" << std::endl
            << "====================" << std::endl;
    std::cout << ibex_pcount_string(false); // where are my pcounters

    std::ofstream pcount_csv("pinaipple_system_pcount.csv") ; 
    pcount_csv << ibex_pcount_string(true) ;

    return true;
}
