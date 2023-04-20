#include "pinaipple_system.h"

int main (void){
  uint16_t observations_1 [2] ;
  observations_1[0] = 0x1234 ;
  observations_1[1] = 0x5678 ; 
  uint16_t observations_2 [2] ;
  observations_2[0] = 0x9abc ;
  observations_2[1] = 0xdef0 ;
  
  puts("Hello world !") ; 
  fraise_turn_on_off(0) ; 
  fraise_write_obs(observations_1, 0) ;
  fraise_write_obs(observations_2, 1) ;
  fraise_run() ; 
  int result = fraise_get_result() ;
  int i ; 
  for(i=0;i<3; i++){
    puts("result"); 
    puthex(i) ; 
    puts(" = ") ;
    puthex((result>>8*i)&0xff) ;
    puts("\n");
  }
  asm("wfi") ; 
  
  return 0 ;
}