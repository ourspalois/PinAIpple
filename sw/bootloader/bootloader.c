#include "pinaipple_system.h"
#include "timer.h"
#include "fraise.h"

/*
 * Interupt function for the accelerator
*/
void test_fraise_irq(void) __attribute__((interrupt)) ;

volatile uint32_t result ; 
volatile int res_valid ; 

void convert_uint32_to_bits(uint32_t value, char * string) {
  int i ; 
  for(i=0;i<32;i++){
    if(((value >> i) & 1) == 1) {
      string[i] = '1' ; 
    } else {
      string[i] = '0' ;
    }
  }
}

void test_fraise_irq(void){
  result = fraise_get_result() ;
  res_valid = 1 ;
}

char get_char(void){
  char c ;
  do {
    c = getchar() ;
  } while(c == 0x00 || c == 0xff) ;
  return c ;
}

int main(void){
  *((volatile uint32_t*)GPIO_OUT) = 0x1 ; // led on
  
  
  char string[32] ;
  uart_out(DEFAULT_UART, 'a') ;

  result = *(volatile uint32_t *)(FRAISE_MEM_ARRAY_START) ; 
  convert_uint32_to_bits(result, string) ; 
  int i ; 
  uart_out(DEFAULT_UART, '|') ; 
  for (i=0;i<32;i++){
    uart_out(DEFAULT_UART, string[i]) ; 
    uart_out(DEFAULT_UART, '|') ; 
  }
  
  return 0;
}