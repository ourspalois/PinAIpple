#ifndef FRAISE_H__
#define FRAISE_H__

#define FRAISE_BASE_ADDR 0x80003000
#define FRAISE_BASE_REG FRAISE_BASE_ADDR 
#define FRAISE_MODE_REG FRAISE_BASE_REG + 0x0

#define FRAISE_BASE_OBS FRAISE_BASE_ADDR + 0x1000

void fraise_turn_on_off(int) ;
void fraise_write_obs(int, int) ;

#endif