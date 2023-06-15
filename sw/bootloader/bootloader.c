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
uint32_t fraise_read(uint32_t addr) ;

int main(void){
  *((volatile uint32_t*)GPIO_OUT) = 0x1 ; // led on 
  
  putchar('t') ;
  putchar('e') ;
  putchar('s') ;
  putchar('t') ;
  putchar('\n') ;

  asm("fence.i") ; 

  print_fraise_content(1) ;

  asm("fence.i") ; 

  putchar('e');
  putchar('n');
  putchar('d');
  putchar('\n');
  
  *((volatile uint32_t*)GPIO_OUT) = 0x2 ; // led on 

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

// this function reads the content of the memory array. for simplicity the accel has a word size of 4 Bytes (32 bits). you CANNOT perform non aligned accesses.
// input :
//  - addr : the address of the 32 bits word to read.
//  - it can be decomposed as : 8*array_col + 2*array_line + 0(resp. 1) if you want the lines 0 to 3(resp. 4 to 7) of the array. 
// output :
//  - the 32 bits word read from the memory array. (in adress order, little endian)
uint32_t fraise_read(uint32_t addr) {
  return *((volatile uint32_t*)(FRAISE_MEM_ARRAY_START + addr*4)) ;
}

void print_fraise_content(int array_line) {
  uint32_t array[8]; 
  uint32_t line = array_line;
  uint32_t col ;
  
  for(col=0;col<4;col++){
    array[2*col    ] = fraise_read(8*col + 2*line) ;
    array[2*col + 1] = fraise_read(8*col + 2*line + 1) ;
  } 

  putchar('\n') ;
  int array_col ;
    for(line=0;line<8;line++){
      for(array_col=0;array_col<4;array_col++){
        putchar('|') ;
        for(col=0;col<8;col++){
          if(line < 4){
            putchar((array[2 * array_col ] & (1 << (line * 8 + (7-col)))) ? '1' : '0') ; 
          } else {
            putchar((array[2 * array_col + 1] & (1 << ((line-4) * 8 + (7-col)))) ? '1' : '0') ;
          }
          putchar('|') ; 
        }
        putchar(' ') ;
      }
      putchar('\n') ;
    }
    putchar('\n') ; 
}