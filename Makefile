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
APP_ELF = sw/build/demo/test_fraise/demo
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
ifneq ($(wildcard ./sw/build/demo/test_fraise/demo),)
	@echo "Application already compiled"
else 
	@echo "Compiling application"
	@mkdir sw/build
	@cd sw/build ;cmake ../ ; make 
endif
	@echo "Memory utilization"
	$(SIZE) $(APP_ELF)

# -----------------------------------------------------------------------------
# convert to binary
# -----------------------------------------------------------------------------

app.bin: $(APP_ELF) 
	@echo "Generating binary image..."
	@$(OBJCOPY) -I elf32-little $< -j .text   -O binary text.bin
	@$(OBJCOPY) -I elf32-little $< -j .rodata -O binary rodata.bin
	@$(OBJCOPY) -I elf32-little $< -j .data   -O binary data.bin
	@cat text.bin rodata.bin data.bin > $@
	@rm text.bin rodata.bin data.bin

# write assembly for more readable code

asm.log: $(APP_ELF) 
	@echo "Generating assembly log..."
	@$(OBJDUMP) -D $< > $@

# -----------------------------------------------------------------------------
# write to rtl
# -----------------------------------------------------------------------------

write_image: app.bin $(IMAGE_GENERATOR)
	@echo "Writing image to rtl..."
	@$(IMAGE_GENERATOR) -bld_img $< $(BOOT_IMAGE)

load_image: asm.log write_image
	@echo "Done"
	@ rm app.bin

compile_rtl: load_image
	@echo "Compiling RTL..."
	@/usr/bin/time fusesoc --cores-root=. --log-file fusesoc.log run --target=synth --setup --build integnano:pinaipple:pinaipple_system

program_apollo:
	@echo "Programming FPGA..."
	@cd build/integnano_pinaipple_pinaipple_system_0/synth-quartus/; quartus_pgm -c "Apollo Agilex" -m "jtag" -o "p;integnano_pinaipple_pinaipple_system_0.sof" 

clean : 
	@rm -r sw/build
	@rm -r build
