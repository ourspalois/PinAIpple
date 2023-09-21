#include "pinaipple_system.h"
#include "timer.h"
#include "fraise.h"

/*
 * Interupt function for the accelerator
*/
void test_fraise_irq(void) __attribute__((interrupt)) ;

volatile int result ; 
volatile int res_valid ; 

void test_fraise_irq(void){
  result = fraise_get_result_stoch() ;
  res_valid = 1 ;
}

int main (void){
  uint32_t cmptr = 0; 
  uint32_t output = 1 ;
  while(1){
    cmptr = cmptr + 1 ; 
    if (cmptr == 50000000){
      cmptr = 0 ;
       output = 1 - output ; 
       *((volatile uint32_t*)GPIO_OUT) = output ;
    }
  }
  /*
  //install_exception_handler(FRAISE_IRQ_NUM, &test_fraise_irq) ; 

  uint8_t observations [4] = {0x00, 0x00, 0x00, 0x00} ;
  
  fraise_turn_on_off(0) ; 
  fraise_sel_write_inference(Inference) ; 
  fraise_write_obs(observations) ;
  fraise_irq_enable() ; 
  bypass_comparator() ; 

  // test log mode 
  fraise_run() ;
  asm("wfi") ;
  
  uint8_t array_1 [8] = {0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01} ;

  //write_distribution(array, 0, 0) ; 
  fraise_sel_write_inference(Writing) ;
  fraise_write_set_reset(1) ; 
  write_line_block(array_1, 0, 0) ;
  write_line_block(array_1, 1, 0) ;
  write_line_block(array_1, 2, 0) ;
  write_line_block(array_1, 3, 0) ;
  fraise_write_set_reset(0) ; 
  write_line_block(array_1, 0, 0) ;
  write_line_block(array_1, 1, 0) ;
  write_line_block(array_1, 2, 0) ;
  write_line_block(array_1, 3, 0) ;
  fraise_sel_write_inference(Inference) ;
  // so we have only ones everywhere. 
  
  fraise_sel_write_inference(Inference) ; 

  // log test
  fraise_run() ;
  asm("wfi") ;

  return 0 ; */
}