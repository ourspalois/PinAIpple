# 🍍 PINAIPPLE  SYSTEM 🍍

## install

this projects depends on the ibex system, and it's fork of fusesoc.
to install run

``` pip3 install -U -r python-requirements.txt ```

you should have quartus (pro only) or vivado installed fo compilation
you should also have a riscv toolchain for rv32imc (can get a release if you dont want to wait a few hours)

## run fusesoc test

as a way to test the install of fusesoc run this cmd :

``` fusesoc --cores-root=. --log-file fusesoc.log list-cores | grep integnano ```

You should see a few cores produced by our team.

## build simulator using Verilator

You should install verilator to run this cmd
run the cmd  

``` time fusesoc --cores-root=. --log-file fusesoc.log run --target=sim --tool=verilator --setup --build integnano:pinaipple:pinaipple_system ```

## compile the testing software

Run the cmd

``` bash
mkdir sw/build/ 
pushd sw/build/
cmake ../
make 
popd

```

## compile bootloader

run the cmd

``` bash
make load_image
```

## Run the simulator with memory load (curently broken)

``` ./build/integnano_pinaipple_pinaipple_system_0/sim-verilator/Vpinaipple_system [-t] --meminit=ram,<your binary>,<type of your file> ```

the type of your bin file can be found using the cmd : ``` file <the file> ``` it should be an elf or vmem file.

for example to build the hello_world demo run :

``` ./build/integnano_pinaipple_pinaipple_system_0/sim-verilator/Vpinaipple_system -t --meminit=ram,./sw/build/demo/hello_world/demo,elf ```

to run the fraise demo :

``` ./build/integnano_pinaipple_pinaipple_system_0/sim-verilator/Vpinaipple_system -t --load-elf=./sw/build/demo/test_fraise/demo ```

## Run the simulator on rom only

``` ./build/integnano_pinaipple_pinaipple_system_0/sim-verilator/Vpinaipple_system -t ```

## Run code on the accel

The functions to use the accel ar in sw/pinaipple_lib/fraise.h

## build with quartus

``` time fusesoc --cores-root=. --log-file fusesoc.log run --target=synth --setup --build integnano:pinaipple:pinaipple_system ```

## program the card

``` bash
pushd build/integnano_pinaipple_pinaipple_system_0/synth-quartus/
quartus_pgm -c "Apollo Agilex" -m "jtag" -o "p;integnano_pinaipple_pinaipple_system_0.sof" 
popd
```
