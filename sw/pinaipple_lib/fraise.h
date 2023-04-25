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
#define FRAISE_WRITE_SET_RESET_REG FRAISE_BASE_REG + 0x24
#define FRAISE_MEM_ARRAY_START  FRAISE_BASE_ADDR + 0x800
#define FRAISE_MEM_ARRAY_END    FRAISE_BASE_ADDR + 0xFFF 

typedef enum {
    SET,
    RESET,
} fraise_write_mode_t ;

void fraise_turn_on_off(int);
void fraise_write_obs(uint16_t *, int);
void fraise_run(void);
void fraise_write_seed(char);
int fraise_get_result();
void fraise_write_mode(int);
void fraise_irq_enable();
void fraise_irq_disable();
#endif