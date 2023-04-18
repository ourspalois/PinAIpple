#include "fraise.h"
#include "dev_access.h"

void fraise_turn_on_off(int on_off)
{
  int a =0; 
  if (on_off <= 1){
    a += 1 ;
    *(volatile uint32_t *)(FRAISE_MODE_REG) = on_off ;
    a += 1 ;
  } 
}

void fraise_write_obs(int obs, int obs_number) {
  if (obs <= (1<<9)-1) {
    DEV_WRITE(FRAISE_BASE_OBS + obs_number, obs);
  }
}