#ifndef FRAISE_H__
#define FRAISE_H__

#include "stdint.h"

#define FRAISE_BASE_ADDR        0x70000000
#define FRAISE_BASE_REG         FRAISE_BASE_ADDR + 0x10
#define FRAISE_ON_OFF_REG       FRAISE_BASE_REG + 0x0
#define FRAISE_PROG             FRAISE_BASE_REG + 0x8
#define FRAISE_READ             FRAISE_BASE_REG + 0xC
#define FRAISE_INFERENCE        FRAISE_BASE_REG + 0x10
#define FRAISE_LAUNCH_INF       FRAISE_BASE_REG + 0x14
#define FRAISE_RECUP_RES        FRAISE_BASE_REG + 0x18
#define FRAISE_RECUP_RES_2      FRAISE_BASE_REG + 0x1C
#define FRAISE_RECUP_RES_3      FRAISE_BASE_REG + 0x20
#define FRAISE_OBS_COL          FRAISE_BASE_REG + 0x24
#define FRAISE_OBS_ROW          FRAISE_BASE_REG + 0x28
#define FRAISE_WRITING_SET_RESET_REG FRAISE_BASE_REG + 0x2C

#define FRAISE_MEM_ARRAY_START  FRAISE_BASE_ADDR + 0x00100
#define FRAISE_MEM_ARRAY_END    FRAISE_BASE_ADDR + 0x200FF 

typedef enum {
    SET,
    RESET,
} fraise_write_mode_t ;


typedef enum {
    Stochastic, 
    Logarithmic
} write_inference_t ;

void fraise_turn_on_off(int);
void fraise_write_obs_col(uint8_t observations_col1, uint8_t observations_col2, uint8_t observations_col3, uint8_t observations_col4);
void fraise_write_obs_row(uint8_t observations_row1, uint8_t observations_row2, uint8_t observations_row3, uint8_t observations_row4);
void fraise_run(void);
void fraise_prog(uint32_t prog_active);
uint32_t fraise_get_result_stoch(void);
uint32_t fraise_get_result_power_c(void);
uint32_t fraise_get_result_log(void);
void fraise_sel_write_inference(write_inference_t);
uint32_t fraise_read(uint32_t addr) ;
//writing 

// arg1 : a 4 * 8 bit array
void fraise_write_set_reset(int set_reset) ; 
void write_line_block(uint32_t values, uint8_t addr_col_array, uint8_t addr_line, uint8_t side);
void test_fraise_irq(void) __attribute__((interrupt)) ;

#endif