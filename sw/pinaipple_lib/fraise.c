#include "fraise.h"
#include "dev_access.h"
#include "pinaipple_system.h"

void fraise_turn_on_off(int on_off)
{
  *(volatile uint32_t *)(FRAISE_ON_OFF_REG) = on_off ;
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

void fraise_write_seed(uint32_t seed){
  *(volatile uint32_t *)(FRAISE_SEED_REG) = seed ;
}

void fraise_write_mode(int mode) { // 0 stochastic 1 logarithmic 
  *(volatile uint32_t *)(FRAISE_MODE_REG) = mode ;
}

void fraise_irq_enable(){
  enable_interrupts(FRAISE_IRQ);
  set_global_interrupt_enable(1);
  *(volatile uint32_t *)(FRAISE_IRQ_ENABLE_REG) = 1 ;
}

void fraise_irq_disable(){
  *(volatile uint32_t *)(FRAISE_IRQ_ENABLE_REG) = 0 ;
  disable_interrupts(FRAISE_IRQ);
}

void set_comp_precision(int precision) {
  *(volatile uint32_t *)(FRAISE_COMP_PRECISION_REG) = precision ;
}

void set_reference(uint8_t* array){ // a 32 bits array of the 4 RHS of the comparator
  *(volatile uint32_t *)(FRAISE_COMP_REFERENCE) = (uint32_t) &array ;
}

void set_comp_instr(comp_instr_t instr) {
  *(volatile uint32_t *)(FRAISE_COMP_INSTR_REG) = (int) instr ;
}

uint8_t get_decision_result() {
  return (uint8_t)*(volatile uint32_t *)(FRAISE_COMP_RESULT_REG) ;
}

void bypass_comparator() {
  *(volatile uint32_t *)(FRAISE_COMP_BYPASS_REG) = 1 ;
}

void enable_comparator() {
  *(volatile uint32_t *)(FRAISE_COMP_BYPASS_REG) = 0 ;
}

void fraise_sel_write_inference(write_inference_t value){
  *(volatile uint32_t *)(FRAISE_INFERENCE_WRITE_REG) = (int) value ;
}

void write_half_line(uint8_t * values, uint8_t addr_col, uint8_t addr_line) {
  *(volatile uint32_t *)(FRAISE_MEM_ARRAY_START + (addr_col << 8) + addr_line) = ~(*(uint32_t*)values) ; 
}

void fraise_write_set_reset(int set_reset){
  *(volatile uint32_t *)(FRAISE_WRITING_SET_RESET_REG) = set_reset ;
}

void write_line(uint8_t * values, uint8_t addr_col_array, uint8_t addr_line) {
  write_half_line(values, (addr_col_array << 1) , addr_line);
  write_half_line(values+4, (addr_col_array << 1) + 1, addr_line);
}

void write_distribution(uint8_t * values, uint8_t addr_col_array, uint8_t addr_row_array){
  fraise_sel_write_inference(Writing) ;
  fraise_write_set_reset(1) ; 
  int line ; 
  for(line = 0 ; line < 64 ; line ++){
    write_line(values + (line << 3), addr_col_array, (addr_row_array << 6) + line);
  }
  fraise_write_set_reset(0) ;
  for(line = 0 ; line < 64 ; line ++){
    write_line(values + (line << 3), addr_col_array, (addr_row_array << 6) + line);
  }
  fraise_sel_write_inference(Inference) ;
}
