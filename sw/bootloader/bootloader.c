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

uint32_t fraise_read(int addr) {
  return *((volatile uint32_t*)(FRAISE_BASE + addr)) ;
}

void print_fraise_content() {
  uint32_t array[16*2] ; 
  int line ;
  int col ;
  for(col=0;col<4;col++){
    for(line=0;line<4;line++){
      array[8*col + 2*line ] = fraise_read(8*col + 2*line) ;
      array[8*col + 2*line + 1] = fraise_read(8*col + 2*line + 1) ;
    }
  }
  putchar('\n') ;
  int array_col ;
  int array_line ;
  for(array_line=0;array_line<4;array_line++){
    for(line=0;line<8;line++){
      for(array_col=0;array_col<4;array_col++){
        putchar("|") ;
        for(col=0;col<8;col++){
          putchar('0') ; 
          putchar('|') ; 
        }
        putchar(' ') ;
      }
      putchar('\n') ;
    }
    putchar('\n') ;
  }
}

int main(void){
  *((volatile uint32_t*)GPIO_OUT) = 0x1 ; // led on
  
  print_fraise_content() ;
  
  return 0;
}