#ifndef FRAISE_H__
#define FRAISE_H__

#include "stdint.h"

#define FRAISE_BASE_ADDR        0x70000000
#define FRAISE_BASE_REG         FRAISE_BASE_ADDR + 0x10
#define FRAISE_ON_OFF_REG       FRAISE_BASE_REG + 0x0
#define FRAISE_SEED_REG         FRAISE_BASE_REG + 0x4
#define FRAISE_OBS0_REG         FRAISE_BASE_REG + 0x8
#define FRAISE_OBS1_REG         FRAISE_BASE_REG + 0xc
#define FRAISE_LAUNCH_REG       FRAISE_BASE_REG + 0x10
#define FRAISE_RES_VALID_REG    FRAISE_BASE_REG + 0x14
#define FRAISE_RES_REG          FRAISE_BASE_REG + 0x18
#define FRAISE_MODE_REG         FRAISE_BASE_REG + 0x1c
#define FRAISE_IRQ_ENABLE_REG   FRAISE_BASE_REG + 0x20
#define FRAISE_COMP_PRECISION_REG FRAISE_BASE_REG + 0x24
#define FRAISE_COMP_INSTR_REG FRAISE_BASE_REG + 0x28
#define FRAISE_COMP_REFERENCE FRAISE_BASE_REG + 0x2C
#define FRAISE_COMP_RESULT_REG FRAISE_BASE_REG + 0x30
#define FRAISE_COMP_BYPASS_REG FRAISE_BASE_REG + 0x34 

#define FRAISE_MEM_ARRAY_START  FRAISE_BASE_ADDR + 0x800
#define FRAISE_MEM_ARRAY_END    FRAISE_BASE_ADDR + 0xFFF 

typedef enum {
    SET,
    RESET,
} fraise_write_mode_t ;

typedef enum {
    min,
    max, 
    inf, 
    if_or_eq, 
    eq,
    sup_or_eq,
    sup,
    neq
} comp_instr_t ;

void fraise_turn_on_off(int);
void fraise_write_obs(uint16_t *, int);
void fraise_run(void);
void fraise_write_seed(char);
int fraise_get_result();
void fraise_write_mode(int);
void fraise_irq_enable();
void fraise_irq_disable();

void bypass_comparator();
void enable_comparator();
void set_comp_precision(int); 
void set_reference(uint8_t *);
void set_comp_instr(comp_instr_t) ;
uint8_t get_decision_result() ;

#endif