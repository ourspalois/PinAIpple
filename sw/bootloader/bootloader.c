#include "pinaipple_system.h"
#include "timer.h"
#include "fraise.h"

/*
 * Interupt function for the accelerator
*/
void test_fraise_irq(void) __attribute__((interrupt)) ;

volatile uint32_t result ; 
volatile int res_valid ; 

void test_fraise_irq(void){
  result = fraise_get_result() ;
  res_valid = 1 ;
}

void convert_int_to_char(uint32_t integer, char* string){
  int i = 0 ; 
  uint32_t j = integer ;
  if(j != 0) {
    while(j != 0){
      string[i] = (j % 10) + 0x30 ;
      j /= 10 ;
      i++ ;
    }
  } else {
    string[i] = '0' ;
    i++ ;
  }
  string[i] = 0 ;
}

char get_char(void){
  char c ;
  do {
    c = getchar() ;
  } while(c == 0) ;
  putchar(c) ;
  return c ;
}

int main(void){
  *((volatile uint32_t*)GPIO_OUT) = 0x1 ; // led on
  char received_char ; 
  while(1){
    received_char = get_char() ;
    if(received_char == 'a') {
      *((volatile uint32_t*)GPIO_OUT) = 0x1 ; // led on
    } else if (received_char == 'e') {
      *((volatile uint32_t*)GPIO_OUT) = 0x0 ; // led off
    }
  }

  /*
  *((volatile uint32_t*)GPIO_OUT) = 0x1 ; // leds on

  uint8_t observations [4] = {0x02, 0x00, 0x00, 0x00} ;
  fraise_write_obs(observations) ;
  fraise_irq_enable() ; 
  bypass_comparator() ;

  uint8_t array_1 [4] = {0x01, 0x3, 0x7, 0x0F} ;

  fraise_sel_write_inference(Writing) ;
  fraise_write_set_reset(1) ; 
  write_line_block(array_1, 0, 0) ;
  fraise_write_set_reset(0) ;
  write_line_block(array_1, 0, 0) ;
  fraise_sel_write_inference(Inference) ;
  
  fraise_run() ;
  asm("wfi") ;

  convert_int_to_char(result , string) ;
  int i = 0 ; 
  while(string[i] != 0){
    putchar(string[i]) ;
    i++ ;
  }
  putchar('\n') ;

  char string[10] ;
  result = *(volatile uint32_t *)(FRAISE_MEM_ARRAY_START) ;
  convert_int_to_char(result , string) ;
  int i = 0 ; 
  while(string[i] != 0){
    putchar(string[i]) ;
    i++ ;
  }
  putchar('\n') ; 
  */
  return 0;
}