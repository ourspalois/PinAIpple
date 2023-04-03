#include "pinaipple_system.h"
#include "timer.h"
#include "gpio.h"
#include <stdbool.h>

#define USE_GPIO_SHIFT_REG 0 

void test_uart_irq_handler(void) __attribute__((interrupt));

void test_uart_irq_handler(void) {
  int uart_in_char;

  while ((uart_in_char = uart_in(DEFAULT_UART)) != -1) {
    uart_out(DEFAULT_UART, uart_in_char);
    uart_out(DEFAULT_UART, '\r');
    uart_out(DEFAULT_UART, '\n');
  }
}

int main (void){

    
}