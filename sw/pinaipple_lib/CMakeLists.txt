add_library(pinaipple_lib OBJECT pinaipple_system.c uart.c timer.c gpio.c crt0.S)
set_property(SOURCE crt0.S PROPERTY LANGUAGE C)
target_include_directories(pinaipple_lib PUBLIC "${CMAKE_CURRENT_LIST_DIR}")