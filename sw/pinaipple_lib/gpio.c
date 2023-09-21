// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
#include "dev_access.h"
#include "gpio.h"

void set_outputs(gpio_t gpio, uint32_t outputs){
    DEV_WRITE(gpio, outputs);
}

uint32_t read_gpio(gpio_t gpio){
    return DEV_READ(gpio);
}

void set_output_bit(gpio_t gpio, uint32_t bit_index, uint32_t value){
    uint32_t outputs = read_gpio(gpio);
    outputs &= ~(1 << bit_index); // clear bit 
    outputs |= (value << bit_index); // set bit 
    set_outputs(gpio, outputs);
}

uint32_t get_output_bit(gpio_t gpio, uint32_t bit_index){
    uint32_t outputs = read_gpio(gpio);
    return (outputs >> bit_index) & 1;
}