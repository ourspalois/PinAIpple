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
  result = fraise_get_result() ;
  res_valid = 1 ;
}

enum ERROR_CODES_enum {
  ERROR_SIGNATURE = 0, /**< 0: Wrong signature in executable */
  ERROR_SIZE      = 1, /**< 1: Insufficient instruction memory capacity */
  ERROR_CHECKSUM  = 2, /**< 2: Checksum error in executable */
};

const char error_message[4][5] = {
  "EXE",
  "SIZE",
  "CHKS",
  "FLSH"
};

enum NEORV32_EXECUTABLE_enum {
  EXE_OFFSET_SIGNATURE =  0, /**< Offset in bytes from start to signature (32-bit) */
  EXE_OFFSET_SIZE      =  4, /**< Offset in bytes from start to size (32-bit) */
  EXE_OFFSET_CHECKSUM  =  8, /**< Offset in bytes from start to checksum (32-bit) */
  EXE_OFFSET_DATA      = 12, /**< Offset in bytes from start to data (32-bit) */
};

volatile uint32_t exe_available = 0; /**< Executable available flag */
volatile uint32_t exe_fetch    = 0; /**< Executable fetch flag */

int main(void){
  // set status led on
  *((volatile uint32_t*)GPIO_OUT) = 0xaaaaaaaa ;

  puts("\n\n\n PINAIPPLE BOOTLOADER \n\n\n") ;

  puts("\nCMD:> ") ; 
  char cmd = getchar() ;
  putchar(cmd) ;
  puts("cmd well received\n") ;
  

  return 0;
}