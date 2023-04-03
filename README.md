# PINAIPPLE 🍍 SYSTEM 

## install 
this projects depends on the ibex system, and it's fork of fusesoc. 
to install run 

``` pip3 install -U -r python-requirements.txt ```

you should have quartus (pro only) or vivado installed fo compilation 
you should also have ariscv toolchain for rv32imc (can get a release if you dont want to wait a few hours)

## run fusesoc test 
as a way to test the install of fusesoc run this cmd : 

``` fusesoc --cores-root=. --log-file fusesoc.log list-cores | grep integnano ```

You should see a few cores produced by our team. 

## run verilator 
You should install verilator to run this cmd
run the cmd : 

``` fusesoc --cores-root=. --log-file fusesoc.log run --target=sim --tool=verilator --setup --build integnano:pinaipple:pinaipple_system ```

