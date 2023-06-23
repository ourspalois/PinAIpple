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
void print_fraise_content(uint32_t array_line) ;
uint32_t fraise_read(uint32_t addr) ;
char convert_uint32_to_char(uint32_t, int) ;

void print_serial(char* string) {
  int i ;
  for(i=0;string[i]!='\0';i++){
    putchar(string[i]) ;
  }
}

void get_serial(char* string){
  int i ;
  for(i=0;i<32;i++){
    string[i] = getchar() ;
    if(string[i] == '\n'){
      string[i] = '\0' ;
      return ;
    }
  }
  string[31] = '\0' ;
}

int main(void){
  //uint8_t array[4] = {0x18, 0x3C, 0x7E, 0xDB} ;
  //uint8_t array_1[4] = {0xFF, 0x3C, 0x7E, 0xA5} ; 
  uint8_t array[4] = {0x01, 0x00, 0x00, 0x00} ;
  uint8_t array_1[4] = {0x00, 0x00, 0x00, 0x00} ;

  *((volatile uint32_t*)GPIO_OUT) = 0x1 ; // led on   
  
  print_serial("Hello World!\n") ;
  print_serial("This is the bootloader.\n") ;
  
  if(*((volatile uint32_t*)GPIO_IN) & 0x1){
    print_serial("write mode enabled\n") ;
    print_serial("please change the voltages for SET programming\n") ;
    print_serial("when ready put SW1 to high\n") ;
    while(!(*((volatile uint32_t*)GPIO_IN) & 0x2)){} // wait for SW1 to be high
    print_serial("programming\n") ;
    fraise_sel_write_inference(Writing) ;
    fraise_write_set_reset(1) ; 
    uint8_t i, j ;  
    for(i=0 ; i<8 ;i++){
      for(j=0 ; j<4 ; j++){
        write_line_block(array_1, j, i) ;
      }
    }
    print_serial("please put SW1 to low\n") ;
    while(*((volatile uint32_t*)GPIO_IN) & 0x2){} // wait for SWI to be low
    print_serial("please change the voltages for RESET programming\n") ;
    print_serial("when ready put SW1 to high\n") ;
    while(!(*((volatile uint32_t*)GPIO_IN) & 0x2)){} // wait for SW1 to be high
    print_serial("programming\n") ;
    fraise_write_set_reset(0) ; 
    for(i=0 ; i<8 ;i++){
      for(j=0 ; j<4 ; j++){
        write_line_block(array_1, j, i) ;
      }
    }
    fraise_sel_write_inference(Inference) ;

    print_serial("programming done\n") ;
  } else {
    print_serial("write mode disabled\n") ;
    print_serial("test\n") ; 
  
    print_fraise_content(0x0) ;
    print_fraise_content(0x1) ;
    print_fraise_content(0x2) ;
    print_fraise_content(0x3) ;
  
    print_serial("end\n") ; 
  }
  putchar('\n') ;

  *((volatile uint32_t*)GPIO_OUT) = 0x2 ; // led on 

  uint8_t Observation [4] = {0x06, 0x06, 0x06, 0x06} ;
  fraise_write_obs(Observation) ; 
  fraise_irq_enable() ; 
  bypass_comparator() ; 

  fraise_run() ; 
  asm("wfi") ; 

  uint32_t res_cpy = result ; 
  uint8_t hex_letter ; 
  int i ;
  for(i=0;i<8;i++){
    hex_letter = (res_cpy >> (28-4*i)) & 0xf ; 
    if(hex_letter < 10 ) {
      putchar(hex_letter + '0') ;
    } else {
      putchar(hex_letter - 10 + 'A') ; 
    }
  }
  putchar('\n') ;

  *((volatile uint32_t*)GPIO_OUT) = 0x2 ; // led on 

  return 0;
}

void convert_uint32_to_bits(uint32_t value, char * string) {
  int i ; 
  for(i=0;i<32;i++){
    if(((value >> (31-i)) & 1) == 1) {
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

char convert_uint32_to_char(uint32_t value, int bit_number){
  if(((value >> bit_number) & 1) == 1) {
    return '1' ; 
  } else {
    return '0' ;
  }

}

void print_fraise_content(uint32_t array_line) {
  if(array_line >= 4) {
    asm("nop") ;
  } else {
    uint32_t array[8]; 
    uint32_t col ;
    
    for(col=0;col<4;col++){
      array[2*col    ] = fraise_read(8*col + 2*array_line) ;
      array[2*col + 1] = fraise_read(8*col + 2*array_line + 1) ;
    } 

    putchar('\n') ;
    int array_col ;
    int line ;
    int column ;
    for(line=0;line<8;line++){
      for(array_col=0;array_col<4;array_col++){
        putchar('|') ;
        for(column=0;column<8;column++){
          if(line < 4){
            putchar(convert_uint32_to_char(array[2*array_col], 8*line + 7 - column)) ;
          } else {
            putchar(convert_uint32_to_char(array[2*array_col + 1], 8*(line-4) + 7 - column)) ;
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