#include "pinaipple_system.h"
#include "timer.h"
#include "fraise.h"

void test_fraise_irq(void) __attribute__((interrupt)) ;

volatile int result ; 
volatile int res_valid ; 

void test_fraise_irq(void){
  result = fraise_get_result() ;
  res_valid = 1 ;
}

int main (void){
  install_exception_handler(FRAISE_IRQ_NUM, &test_fraise_irq) ; 

  uint16_t observations_1 [2] ;
  observations_1[0] = 0x0000 ;
  observations_1[1] = 0x0000 ; 
  uint16_t observations_2 [2] ;
  observations_2[0] = 0x0000 ;
  observations_2[1] = 0x0000 ;
  
  fraise_turn_on_off(0) ; 
  fraise_sel_write_inference(Inference) ; 
  fraise_write_obs(observations_1, 0) ;
  fraise_write_obs(observations_2, 1) ;
  fraise_irq_enable() ; 
  bypass_comparator() ; 

  // test stochastic mode
  fraise_write_mode(0) ; 
  fraise_run() ;
  asm("wfi") ;

  // test log mode 
  fraise_write_mode(1) ;
  fraise_run() ;
  asm("wfi") ;

  int row, line ; 
  uint8_t array [64* 8] ; 
  for (line = 0 ; line < 64 ; line++) {
    for (row = 0 ; row < 8 ; row++) {
      array[line*8+row] = 0x01 ;
    }
  } 

  //write_distribution(array, 0, 0) ; 
  fraise_sel_write_inference(Writing) ;
  fraise_write_set_reset(1) ; 
  write_line(array, 0, 0) ; 
  write_line(array, 1, 0) ; 
  write_line(array, 2, 0) ;
  write_line(array, 3, 0) ;
  fraise_write_set_reset(0) ; 
  write_line(array, 0, 0) ; 
  write_line(array, 1, 0) ; 
  write_line(array, 2, 0) ;
  write_line(array, 3, 0) ;
  fraise_sel_write_inference(Inference) ;
  // so we have only ones everywhere. 
  
  
  fraise_write_mode(0) ; 
  fraise_write_seed(0xebfb7f5c) ;
  fraise_sel_write_inference(Writing_seeds) ; 
  fraise_sel_write_inference(Inference) ; 


  fraise_write_mode(1) ; //TODO: change for a log/ stoch enum 
  fraise_run() ;
  asm("wfi") ;


  return 0 ;
}