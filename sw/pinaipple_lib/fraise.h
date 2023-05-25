#ifndef FRAISE_H__
#define FRAISE_H__

#include "stdint.h"

#define FRAISE_BASE_ADDR        0x70000000
#define FRAISE_BASE_REG         FRAISE_BASE_ADDR + 0x10
#define FRAISE_ON_OFF_REG       FRAISE_BASE_REG + 0x0
#define FRAISE_OBS0_REG         FRAISE_BASE_REG + 0x8
#define FRAISE_LAUNCH_REG       FRAISE_BASE_REG + 0x10
#define FRAISE_RES_VALID_REG    FRAISE_BASE_REG + 0x14
#define FRAISE_RES_REG          FRAISE_BASE_REG + 0x18
#define FRAISE_IRQ_ENABLE_REG   FRAISE_BASE_REG + 0x20
#define FRAISE_COMP_PRECISION_REG FRAISE_BASE_REG + 0x24
#define FRAISE_COMP_INSTR_REG FRAISE_BASE_REG + 0x28
#define FRAISE_COMP_REFERENCE FRAISE_BASE_REG + 0x2C
#define FRAISE_COMP_RESULT_REG FRAISE_BASE_REG + 0x30
#define FRAISE_COMP_BYPASS_REG FRAISE_BASE_REG + 0x34 
#define FRAISE_INFERENCE_WRITE_REG FRAISE_BASE_REG + 0x38
#define FRAISE_WRITING_SET_RESET_REG FRAISE_BASE_REG + 0x3C

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

typedef enum {
    Inference, 
    Writing
} write_inference_t ;

void fraise_turn_on_off(int);
void fraise_write_obs(uint8_t *);
void fraise_run(void);
int fraise_get_result();
void fraise_irq_enable();
void fraise_irq_disable();
void fraise_sel_write_inference(write_inference_t);

void bypass_comparator();
void enable_comparator();
void set_comp_precision(int); 
void set_reference(uint8_t *);
void set_comp_instr(comp_instr_t) ;
uint8_t get_decision_result() ;

//writing 

// arg1 : a 4 * 8 bit array
void fraise_write_set_reset(int set_reset) ; 
void write_line_block(uint8_t * values, uint8_t addr_col_array , uint8_t addr_line) ;

void test_fraise_irq(void) __attribute__((interrupt)) ;

#endif