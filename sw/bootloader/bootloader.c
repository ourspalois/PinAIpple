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

/*
 * this is a software timer, it has terrible precision dont use it.
*/
uint32_t sleep(uint32_t time_ms){
  uint32_t count_to = (uint32_t)(time_ms * 100 ) ;
  uint32_t i ;
  uint32_t sum = 0 ;
  for(i = 0 ; i < count_to ; i++){
    sum += 1 ;
  }
  return sum ;
}

uint32_t verify(uint32_t result, uint8_t * array, uint8_t * Observations){
  int errors = 0;
  int i ; 
  for(i=0 ; i<4 ; i++){
    uint8_t line_res = (result >> (8*i)) & 0xFF ;

    uint16_t th_res = array[8 * i + Observations[0]] + array[8* (i+4) + Observations[1]]  + array[8 * (i+8) + Observations[2]] + array[8 * (i+12) + Observations[3]] ;
    if(th_res >= 255){
      th_res = 255 ;
    }
    if(line_res != th_res){
      errors++ ;
    }

  }
  return errors ;
}

void print_serial_hex(uint32_t value){
  int i ;
  for(i=0;i<8;i++){
    uint8_t val = (value >> (28 - 4*i)) & 0xF ;
    if(val < 10){
      putchar(val + '0') ;
    }else{
      putchar(val - 10 + 'A') ;
    }
  }
  putchar('\n') ;
}

void print_serial_dec(uint32_t value){
  int i ;
  uint32_t valeur = value ;
  char string [4] ; 
  for(i=0;i<4;i++){
    string[i] = (valeur % 10) + '0' ;
    valeur /= 10 ;
  }
  for(i=3;i>=0;i--){
    putchar(string[i]) ;
  }
}


int main(void){
  *((volatile uint32_t*)GPIO_OUT) = 0x1 ; // led on
  
  uint8_t array[4] = {0x01, 0x00, 0x00, 0x00} ;
  uint8_t array_1[128] ;
  int i, j ;
  for(i=0 ; i<8*16 ; i++){
    array_1[i] = 0x00 ;
  }
  
  print_serial("This is the bootloader.\n") ;
  print_serial("Start measure\n") ;

  if(*((volatile uint32_t*)GPIO_IN) & 0x1){
    print_serial("Programming Enabled\n") ;
    print_serial("SET\n") ;
    sleep(10000) ; 
    fraise_sel_write_inference(Writing) ;
    fraise_write_set_reset(1) ;  
    for(i=0 ; i<8 ;i++){
      for(j=0 ; j<4 ; j++){
        write_line_block(array_1, j, i) ;
      }
    }
    print_serial("RESET\n") ;
    sleep(10000) ;
    fraise_write_set_reset(0) ;
    for(i=0 ; i<8 ;i++){
      for(j=0 ; j<4 ; j++){
        write_line_block(array_1, j, i) ;
      }
    }
    fraise_sel_write_inference(Inference) ;
    print_serial("finish programming\n") ;
    
  }
  *((volatile uint32_t*)GPIO_OUT) = 0x2 ; // led on
  uint32_t vdd ;

  print_serial("READ\n") ;
  sleep(10000) ;
  print_serial("start\n") ;
  for(i=0;i<128;i++){
    array_1[i] = (uint8_t)((fraise_read(i/4) >> (8*(i%4))) && 0xFF) ;
  }
  print_serial("end") ; 

  for(vdd = 1200 ; vdd > 100 ; vdd -= 100){
    print_serial("READ vdd :") ;
    print_serial_dec(vdd) ;
    putchar(':') ;
    putchar('\n') ;
    sleep(1000) ; 
    uint32_t error_number = 0 ; 
    uint8_t Observation [4] ;
    uint8_t obs_0, obs_1, obs_2, obs_3 ;
    obs_2 = 0 ;
    obs_3 = 0 ;

    set_global_interrupt_enable(1);
    fraise_irq_enable() ; 
    bypass_comparator() ;
    uint32_t nbr_of_points = 0 ;
    for(obs_0=0;obs_0<8;obs_0++){
      for(obs_1=0;obs_1<8;obs_1++){
        for(obs_2=0;obs_2<8;obs_2++){
          for(obs_3=0;obs_3<8;obs_3++){
            Observation[0] = obs_0 ;
            Observation[1] = obs_1 ;
            Observation[2] = obs_2 ;
            Observation[3] = obs_3 ;

            fraise_write_obs(Observation) ; 

            fraise_run() ; 
            asm("fence.i") ;
            asm("wfi") ; 

            error_number += verify(result, array_1, Observation) ;
            nbr_of_points += 4 ;
          }
        }
      }
    }
    putchar('\n') ;
    print_serial("errors :") ;
    print_serial_hex(error_number) ;
    putchar(':') ; 
    putchar('\n') ;
    print_serial("points :") ;
    print_serial_hex(nbr_of_points) ;
    putchar(':') ;
    putchar('\n') ;
  }
  print_serial("DONE\n"); 
  *((volatile uint32_t*)GPIO_OUT) = 0x4 ; // led on
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