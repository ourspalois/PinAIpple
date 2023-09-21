#include "verilated_toplevel.h"
#include "verilator_memutil.h"

class PinaippleSystem {
 public:
  PinaippleSystem(const char *ram_hier_path, int ram_size, const char *data_ram_hier_path, int data_ram_size);
  virtual ~PinaippleSystem() {}
  virtual int Main(int argc, char **argv);


 protected:
  pinaipple_system _top;
  VerilatorMemUtil _memutil;
  MemArea _rom;
  MemArea _ram;

  virtual int Setup(int argc, char **argv, bool &exit_app);
  virtual void Run();
  virtual bool Finish();
};