#include "fraise.h"
#include "dev_access.h"

void fraise_turn_on_off(int on_off)
{
    *(volatile uint32_t *)(FRAISE_MODE_REG) = on_off ;
}

// input : observations, coded on 16 bits (2 bytes)
// input : obs_id, id of the observation
void fraise_write_obs(uint16_t *observations, int obs_id){
  uint32_t to_write = (uint32_t)observations[0] | (uint32_t)(observations[1]<<16) ;
  if(obs_id == 0) {
    *(volatile uint32_t *)(FRAISE_OBS0_REG) = to_write ; 
  } else if (obs_id == 1) {
    *(volatile uint32_t *)(FRAISE_OBS1_REG) = to_write ;
  }
}

void fraise_run(void){
  *(volatile uint32_t *)(FRAISE_LAUNCH_REG) = 1 ;
}

int fraise_get_result(){
  while(*(volatile uint32_t *)(FRAISE_RES_VALID_REG) == 0){
    // wait for the result to be valid
  }
  return *(volatile uint32_t *)(FRAISE_RES_REG) ;
}

void fraise_write_seed(char seed){
  *(volatile uint32_t *)(FRAISE_SEED_REG) = seed ;
}