# company : INTEGNANO
# author : ourspalois (Théo BALLET)

# Compiler toolchain RISCV
RISCV_PREFIX ?= riscv32-unknown-elf-

# Compiler tools
CC      = $(RISCV_PREFIX)gcc
OBJDUMP = $(RISCV_PREFIX)objdump
OBJCOPY = $(RISCV_PREFIX)objcopy
SIZE    = $(RISCV_PREFIX)size
GDB     = $(RISCV_PREFIX)gdb

# Host native compiler
CC_X86 = g++ -Wall -O2 -g

# output files
APP_ELF = sw/build
BOOT_IMAGE = rtl/system/rom_1p.sv

# image generator
IMAGE_GENERATOR = sw/image_gen/image_gen

# -----------------------------------------------------------------------------
# Image generator targets
# -----------------------------------------------------------------------------

$(IMAGE_GENERATOR): sw/image_gen/image_gen.c
	@echo "Compiling image generator..."
	@$(CC_X86) $< -o $@

# -----------------------------------------------------------------------------
# Application targets
# -----------------------------------------------------------------------------

$(APP_ELF):
	@echo "Build application"
ifneq ($(wildcard ./sw/build/),)
	@echo "Application already compiled"
	@echo "Cleaning application"
	@rm -r sw/build
endif 
	@echo "Compiling application"
	@mkdir sw/build
	@cd sw/build ;cmake ../ ; make 
	@echo "Memory utilization of bootloader:"
	$(SIZE) $(APP_ELF)/bootloader/bootloader
	@echo "Memory utilization of application:"
	$(SIZE) $(APP_ELF)/demo/test_fraise/demo

BOOT_ELF = $(APP_ELF)/bootloader/bootloader

$(BOOT_ELF): $(APP_ELF)

# -----------------------------------------------------------------------------
# convert to binary
# -----------------------------------------------------------------------------

app.bin: $(BOOT_ELF) 
	@echo "Generating binary image..."
	@$(OBJCOPY) -I elf32-little $< -j .text   -O binary text.bin
	@$(OBJCOPY) -I elf32-little $< -j .rodata -O binary rodata.bin
	@$(OBJCOPY) -I elf32-little $< -j .data   -O binary data.bin
	@cat text.bin rodata.bin data.bin > $@
	@rm text.bin rodata.bin data.bin

# write assembly for more readable code

asm.log: $(BOOT_ELF) 
	@echo "Generating assembly log..."
	@$(OBJDUMP) -D $< > $@

# -----------------------------------------------------------------------------
# write to rtl
# -----------------------------------------------------------------------------
.PHONY : write_boot_image gen_asm compile_rtl program_fpga_quartus clean compile_sim
write_boot_image: app.bin $(IMAGE_GENERATOR)
	@echo "Writing image to rtl..."
	@$(IMAGE_GENERATOR) -bld_img $< $(BOOT_IMAGE)

gen_asm: asm.log write_boot_image
	@echo "Done"
	@rm app.bin

compile_rtl_quartus: gen_asm
	@echo "Compiling RTL..."
	@/usr/bin/time fusesoc --cores-root=. --log-file fusesoc.log run --target=synth --setup --build integnano:pinaipple:pinaipple_system

compile_rtl_vivado: gen_asm
	@echo "Compiling RTL..."
	@/usr/bin/time fusesoc --cores-root=. --log-file fusesoc.log run --target=synth_vivado --setup --build integnano:pinaipple:pinaipple_system

compile_sim: gen_asm
	@echo "Compiling RTL..."
	@/usr/bin/time fusesoc --cores-root=. --log-file fusesoc.log run --target=sim --tool=verilator --setup --build integnano:pinaipple:pinaipple_system

program_fpga_quartus: 
	@echo "Programming FPGA..."
	@cd build/integnano_pinaipple_pinaipple_system_0/synth-quartus/; quartus_pgm -c "Apollo Agilex" -m "jtag" -o "p;integnano_pinaipple_pinaipple_system_0.sof" 

program_fpga_vivado:
	@echo "Programming FPGA..."
	@make -C ./build/integnano_pinaipple_pinaipple_system_0/synth_vivado-vivado/ pgm

clean : 
ifneq ($(wildcard ./sw/build/),)
	@rm -r sw/build
endif
ifneq ($(wildcard ./build/),)
	@rm -r build
endif
ifneq ($(wildcard ./fusesoc.log),)
	@rm fusesoc.log
endif
ifneq ($(wildcard ./asm.log),)
	@rm asm.log
endif
ifneq ($(wildcard ./pinaipple_system_pcount.csv),)
	@rm pinaipple_system_pcount.csv
endif