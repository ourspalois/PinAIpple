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
  observations_1[0] = 0x1234 ;
  observations_1[1] = 0x5678 ; 
  uint16_t observations_2 [2] ;
  observations_2[0] = 0x9abc ;
  observations_2[1] = 0xdef0 ;
  
  fraise_turn_on_off(0) ; 
  fraise_write_seed(0xAA) ;
  fraise_write_obs(observations_1, 0) ;
  fraise_write_obs(observations_2, 1) ;
  fraise_irq_enable() ; 
  fraise_write_mode(0) ; 
  fraise_run() ;

  while(res_valid == 0){

  }
  res_valid = 0 ;
  puthex(result) ;

  asm("wfi") ;

  return 0 ;
}