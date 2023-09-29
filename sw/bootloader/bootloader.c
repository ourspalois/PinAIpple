#include "pinaipple_system.h"
#include "timer.h"
#include "fraise.h"


/*
 * Interupt function for the accelerator
*/
void test_fraise_irq(void) __attribute__((interrupt)) ;
void print_line(uint32_t line_addr) ;
void print_array(void) ; 
uint32_t fraise_read(uint32_t addr) ;
void programming_function(uint8_t values1, uint8_t values2, uint8_t values3, uint8_t values4, uint8_t addr_col, uint8_t addr_row, uint8_t side, uint8_t mode);
uint32_t inference_function(uint8_t observations_col1, uint8_t observations_col2, uint8_t observations_col3, uint8_t observations_col4, uint8_t observations_row1, uint8_t observations_row2, uint8_t observations_row3, uint8_t observations_row4, int inf_choice);

volatile uint32_t result_stoch = 0 ; 
volatile uint32_t result_power_c = 0 ; 
volatile uint32_t result_log = 0 ;
volatile uint32_t result = 0 ; 

volatile int res_valid ; 
//int inf_choice; 0 stoch normal, 1 log, 2, stoch power conscious
void test_fraise_irq(void){
  result = fraise_get_result_stoch() ;
  res_valid = 1 ;
}

void print_serial(char* string) {
  int i ;
  for(i=0;string[i]!='\0';i++){
    putchar(string[i]) ;
  }
}

void programming_function(uint8_t values1, uint8_t values2, uint8_t values3, uint8_t values4, uint8_t addr_col, uint8_t addr_row, uint8_t side, uint8_t mode) {
  fraise_prog((uint32_t) 1 );
  uint32_t values = ((uint32_t)values1<<24) | ((uint32_t)values2<<16) | ((uint32_t)values3<<8) | (uint32_t)values4;
  fraise_write_set_reset(mode);
  // 0 = reset 1 = set
  write_line_block(values, addr_col, addr_row, side);
}


uint32_t inference_function(uint8_t observations_col1, uint8_t observations_col2, uint8_t observations_col3, uint8_t observations_col4, uint8_t observations_row1, uint8_t observations_row2, uint8_t observations_row3, uint8_t observations_row4, int inf_choice){
  fraise_turn_on_off(1);
  fraise_write_obs_col(observations_col1, observations_col2, observations_col3, observations_col4);
  fraise_write_obs_row(observations_row1, observations_row2, observations_row3, observations_row4);
  fraise_sel_write_inference(inf_choice);
  fraise_run();
  if (inf_choice == 0){
    return fraise_get_result_stoch();
  };
  if (inf_choice == 2){
    return fraise_get_result_power_c();
  };
  if (inf_choice == 1){
    return fraise_get_result_log();
  };
}

uint32_t reading_function(uint8_t array_col, uint8_t observations_row, uint8_t side){
  uint32_t addr;
  addr = (uint32_t)((((uint32_t) (array_col & 3)) << 3) | (((uint32_t) (observations_row & 255)) << 5) | ((uint32_t) (side & 1)<<2));
  return fraise_read(addr);
}

void print_serial_dec_32(uint32_t value){
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

uint32_t __attribute__((optimize("O0"))) sleep(uint32_t time_ms){
  uint32_t count_to = (uint32_t)(time_ms * 100 ) ;
  uint32_t i ;
  uint32_t sum = 0 ;
  #ifndef SIMULATION_EN
  for(i = 0 ; i < count_to ; i++){
    sum += 1 ;
  }
  #endif
  return sum ;
}

int main(void){
  
  *((volatile uint32_t*)GPIO_OUT) = 0x1 ;
  
  putchar(' ') ; 
  putchar('t') ; 
  putchar('e') ; 
  putchar('s') ; 
  putchar('t') ; 
  putchar('\n') ;

  print_serial("SUPPLY_FORM\n");
  sleep(1000) ; 
  uint32_t line_form ; 
  for(line_form = 0 ; line_form < 64 ; line_form ++){
    programming_function(0,0,0,0, 0, line_form, 0, 1) ;
    programming_function(0,0,0,0, 0, line_form, 1, 1) ;
  } 
  for(line_form = 0 ; line_form < 64 ; line_form ++){
    programming_function(~0, ~0, ~0, ~0, 0, line_form, 0, 1) ;
    programming_function(~0, ~0, ~0, ~0, 0, line_form, 1, 1) ;
  } 
  
  uint8_t pattern[64][8] = {
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,7,255,255,224,0,0,},
    {0,0,7,255,255,224,0,0,},
    {0,0,7,255,255,224,0,0,},
    {0,0,7,255,255,224,0,0,},
    {0,3,255,255,255,255,192,0,},
    {0,3,255,255,255,255,192,0,},
    {0,3,255,255,255,255,192,0,},
    {0,31,199,255,255,227,248,0,},
    {0,31,199,255,255,227,248,0,},
    {0,31,199,255,255,227,248,0,},
    {0,31,199,255,255,227,248,0,},
    {1,255,199,255,255,227,255,128,},
    {1,255,199,255,255,227,255,128,},
    {1,255,199,255,255,227,255,128,},
    {1,255,199,255,255,227,255,128,},
    {1,255,199,255,255,227,255,128,},
    {1,255,199,255,255,227,255,128,},
    {1,255,199,255,255,227,255,128,},
    {15,255,248,127,254,31,255,240,},
    {15,255,248,127,254,31,255,240,},
    {15,255,248,127,254,31,255,240,},
    {14,31,248,0,0,31,248,112,},
    {14,31,248,0,0,31,248,112,},
    {14,31,248,0,0,31,248,112,},
    {14,31,248,0,0,31,248,112,},
    {15,224,0,0,0,0,7,240,},
    {15,224,0,0,0,0,7,240,},
    {15,224,0,0,0,0,7,240,},
    {15,224,0,0,0,0,7,240,},
    {15,224,0,127,254,0,7,240,},
    {15,224,0,127,254,0,7,240,},
    {15,224,0,127,254,0,7,240,},
    {15,252,7,128,1,224,63,240,},
    {15,252,7,128,1,224,63,240,},
    {15,252,7,128,1,224,63,240,},
    {15,252,7,128,1,224,63,240,},
    {15,252,56,0,0,28,63,240,},
    {15,252,56,0,0,28,63,240,},
    {15,252,56,0,0,28,63,240,},
    {15,227,248,0,0,31,199,240,},
    {15,227,248,0,0,31,199,240,},
    {15,227,248,0,0,31,199,240,},
    {15,227,248,0,0,31,199,240,},
    {1,255,192,0,0,3,255,128,},
    {1,255,192,0,0,3,255,128,},
    {1,255,192,0,0,3,255,128,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,},
    {0,0,0,0,0,0,0,0,}
  };
  
  uint32_t line ; 
  print_serial("SUPPLY_SET\n") ; 
  sleep(1000) ; 
  for(line = 0 ; line < 64 ; line ++){
    programming_function(pattern[line][0], pattern[line][1], pattern[line][2], pattern[line][3], 0, line, 0, 1) ;
    programming_function(pattern[line][4], pattern[line][5], pattern[line][6], pattern[line][7], 0, line, 1, 1) ;
  } 
  
  print_serial("SUPPLY_RESET\n") ; 
  sleep(1000) ;
  for(line = 0 ; line < 64 ; line ++){
    programming_function(pattern[line][0], pattern[line][1], pattern[line][2], pattern[line][3], 0, line, 0, 0) ;
    programming_function(pattern[line][4], pattern[line][5], pattern[line][6], pattern[line][7], 0, line, 1, 0) ;
  } 
  
  
  print_serial("SUPPLY_READ\n") ; 
  sleep(1000) ;
  putchar('\n') ;
  print_serial("START_ARRAY\n") ;
  print_array() ; 
  print_serial("END_ARRAY\n") ;
  
  *((volatile uint32_t*)GPIO_OUT) = 0x2 ;
  
  print_serial("END\n") ; 
  
  return 0 ;
}

void print_serial_dec(uint8_t value){
  int i ;
  uint8_t valeur = value ;
  char string [4] ; 
  for(i=0;i<4;i++){
    string[i] = (valeur % 10) + '0' ;
    valeur /= 10 ;
  }
  for(i=3;i>=0;i--){
    putchar(string[i]) ;
  }
}


void print_line(uint32_t line_addr){
  uint32_t values_read[8] ;
  uint8_t increment ; 
  for(increment=0;increment<8;increment++){
    values_read[increment] = reading_function(increment >> 1, (uint8_t) line_addr,(increment + 1)%2) ;
  }

  for(increment=0;increment<8;increment++){
    int sub_incr ; 
    if(increment%2 == 0){
      putchar(' ') ; 
      putchar('|') ; 
    }
    for(sub_incr=3;sub_incr>=0;sub_incr--){
      print_serial_dec(values_read[increment] >> (sub_incr * 8)) ; 
      putchar('|') ; 
    }
  }
  putchar(' ') ; 
  putchar('\n') ;
}

void print_array(){
  int i ; 
  for(i=0;i<256;i++){
    if(i % 64 == 0 && i !=0){
      putchar('\n') ; 
    }
    print_line(i) ;
  }

}