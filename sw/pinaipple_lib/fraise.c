#include "fraise.h"
#include "dev_access.h"
#include "pinaipple_system.h"

void fraise_turn_on_off(int on_off)
{
  *(volatile uint32_t *)(FRAISE_ON_OFF_REG) = on_off ;
}

// input : observations, coded on 16 bits (2 bytes)
// input : obs_id, id of the observation
void fraise_write_obs_col(uint8_t observations_col1, uint8_t observations_col2, uint8_t observations_col3, uint8_t observations_col4){
  uint32_t to_write = (uint32_t)observations_col1 | (uint32_t)(observations_col2<<8) | (uint32_t)(observations_col3<<16) | (uint32_t)(observations_col4<<24) ;
  *(volatile uint32_t *)(FRAISE_OBS_COL) = to_write ; 
  
}

void fraise_write_obs_row( uint8_t observations_row1, uint8_t observations_row2, uint8_t observations_row3, uint8_t observations_row4){
  uint32_t to_write = (uint32_t)observations_row1 | (uint32_t)(observations_row2<<8) | (uint32_t)(observations_row3<<16) | (uint32_t)(observations_row4<<24) ;
  *(volatile uint32_t *)(FRAISE_OBS_ROW) = to_write ; 
  
}
void fraise_sel_write_inference(write_inference_t value){
  *(volatile uint32_t *)(FRAISE_INFERENCE) = (int) value ;
}


void fraise_run(void){
  *(volatile uint32_t *)(FRAISE_LAUNCH_INF) = 1 ;
}

uint32_t fraise_get_result_stoch(){
  return *(volatile uint32_t *)(FRAISE_RECUP_RES) ;
}

uint32_t fraise_get_result_power_c(){
  return *(volatile uint32_t *)(FRAISE_RECUP_RES_2) ;
}
uint32_t fraise_get_result_log(){
  return *(volatile uint32_t *)(FRAISE_RECUP_RES_3) ;
}

uint32_t fraise_read(uint32_t addr) {
  return *((volatile uint32_t*)(FRAISE_MEM_ARRAY_START + addr)) ;
}

void fraise_prog(uint32_t prog_active){
  *(volatile uint32_t *)(FRAISE_PROG) = prog_active ;
}

void fraise_write_set_reset(int set_reset){
  *(volatile uint32_t *)(FRAISE_WRITING_SET_RESET_REG) = set_reset ;
}

void write_line_block(uint32_t values, uint8_t addr_col_array, uint8_t addr_line, uint8_t side) {
  *(volatile uint32_t *)((FRAISE_MEM_ARRAY_START) + (uint32_t)((((uint32_t) (addr_col_array & 3)) << 3) | (((uint32_t) (addr_line & 255)) << 5) | ((uint32_t) (side & 1)<<2))) = ~((uint32_t)values) ;
}
