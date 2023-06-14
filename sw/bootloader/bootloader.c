#include "pinaipple_system.h"
#include "timer.h"
#include "fraise.h"

/*
 * Interupt function for the accelerator
*/
void test_fraise_irq(void) __attribute__((interrupt)) ;

volatile uint32_t result = 0 ; 
volatile int res_valid ; 

void test_fraise_irq(void){
  result = fraise_get_result() ;
  res_valid = 1 ;
}

void convert_uint32_to_bits(uint32_t value, char* string) ;
void print_fraise_content() ;

int main(void){
  *((volatile uint32_t*)GPIO_OUT) = 0x1 ; // led on 
  
  putchar('t') ;
  putchar('e') ;
  putchar('s') ;
  putchar('t') ;
  putchar('\n') ;

  print_fraise_content() ;
  
  char string[33] ;
  convert_uint32_to_bits(result, string) ; 
  int i = 0 ;
  while(string[i] != '\0'){
    putchar(string[31-i++]) ;
  }
  putchar('\n') ;
  
  return 0;
}

void convert_uint32_to_bits(uint32_t value, char * string) {
  int i ; 
  for(i=0;i<32;i++){
    if(((value >> i) & 1) == 1) {
      string[i] = '1' ; 
    } else {
      string[i] = '0' ;
    }
  }
  string[32] = '\0' ;
}



uint32_t fraise_read(uint32_t addr) {
  return *((volatile uint32_t*)(FRAISE_MEM_ARRAY_START + addr*4)) ;
}

void print_fraise_content() {
  uint32_t array[16*2] ; 
  uint32_t line ;
  uint32_t col ;
  
  for(col=0;col<4;col++){
    for(line=0;line<4;line++){
      array[8*col + 2*line] = 0 ; //fraise_read(8*col + 2*line) ;
      array[8*col + 2*line + 1] = 0; // fraise_read(8*col + 2*line + 1) ;
    }
  } 

  putchar('\n') ;
  int array_col ;
  int array_line ;
  for(array_line=0;array_line<4;array_line++){
    for(line=0;line<8;line++){
      for(array_col=0;array_col<4;array_col++){
        putchar('|') ;
        for(col=0;col<8;col++){
          if(line < 4){
            putchar((array[8*array_col + 2*array_line] & (1 << (line * 8 + (7-col)))) ? '1' : '0') ; 
          } else {
            putchar((array[8*array_col + 2*array_line + 1] & (1 << ((line-4) * 8 + (7-col)))) ? '1' : '0') ;
          }
          putchar('|') ; 
        }
        putchar(' ') ;
      }
      putchar('\n') ;
    }
    putchar('\n') ; 
  }
}