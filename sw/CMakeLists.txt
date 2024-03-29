cmake_minimum_required(VERSION 3.10)
project(pinaipple_system_sw)

option(SIM_CTRL_OUTPUT
       "Send string output to simulator control rather than UART")

if(SIM_CTRL_OUTPUT)
  add_compile_definitions(SIM_CTRL_OUTPUT)
endif()

set(COMMON_DIR "${CMAKE_CURRENT_LIST_DIR}/pinaipple_lib")
set(LINKER_SCRIPT "${COMMON_DIR}/link.ld")
set(CMAKE_C_COMPILER riscv32-unknown-elf-gcc)
set(CMAKE_EXE_LINKER_FLAGS "-nostartfiles -T${LINKER_SCRIPT}")
set(CMAKE_C_FLAGS "-O1 -march=rv32imc -mabi=ilp32 -static -mcmodel=medany -Wall -g \
  -fvisibility=hidden -ffreestanding")

add_subdirectory(pinaipple_lib)

function(add_prog prog_name srcs)
  add_executable(${prog_name} ${srcs} $<TARGET_OBJECTS:pinaipple_lib>)
  target_include_directories(${prog_name} PRIVATE $<TARGET_PROPERTY:pinaipple_lib,INCLUDE_DIRECTORIES>)
endfunction()

add_subdirectory(demo)
add_subdirectory(blank)