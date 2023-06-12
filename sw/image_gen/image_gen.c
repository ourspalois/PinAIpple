#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

__asm__(".symver realpath,realpath@GLIBC_2.31");
int main(int argc, char *argv[]) {
  FILE *input, *output;
  unsigned char buffer[4];
  char tmp_string[1024];
  uint32_t tmp = 0 ;
  unsigned int i = 0;

  // open input file
  input = fopen(argv[2], "rb");
  if(input == NULL){
    printf("Input file error!");
    return 2;
  }

  // open output file
  output = fopen(argv[3], "wb");
  if(output == NULL){
    printf("Output file error!");
    return 3;
  }

  // get input file size
  fseek(input, 0L, SEEK_END);
  unsigned int input_size = (unsigned int)ftell(input);
  rewind(input);
  unsigned int input_words = input_size / 4;

  fseek(input, 0L, SEEK_END);

  // go back to beginning
  rewind(input);
 // data
    buffer[0] = 0;
    buffer[1] = 0;
    buffer[2] = 0;
    buffer[3] = 0;
    i = 0;
    #define BASE_ADRESS_ROM 0x00100000
    long int address = 0 + BASE_ADRESS_ROM;

    sprintf(tmp_string, "module rom_1p #(\n"
                        "\tint Depth, \n \tint DATA_WIDTH = 32, \n \tint ADDR_WIDTH = 32 \n "
                        ") (\n"
                        "\tinput logic clk_i, \n\tinput logic req_i, \n\tinput logic [ADDR_WIDTH-1:0] addr_i, \n\toutput logic [DATA_WIDTH-1:0] data_o \n "
                        ");\n"
                        "\talways_ff @(posedge clk_i) begin\n"
                        "\t\tcase (addr_i)\n"
                        ) ; 
    fputs(tmp_string, output);

    while (i < (input_words-1)) {
      if (fread(&buffer, sizeof(unsigned char), 4, input) != 0) {
        tmp  = (uint32_t)(buffer[0] << 0);
        tmp |= (uint32_t)(buffer[1] << 8);
        tmp |= (uint32_t)(buffer[2] << 16);
        tmp |= (uint32_t)(buffer[3] << 24);
        sprintf(tmp_string, "\t\t\t32\'h%08x : data_o = 32\'h%08x ;\n", (unsigned int) address, (unsigned int)tmp);
        fputs(tmp_string, output);
        buffer[0] = 0;
        buffer[1] = 0;
        buffer[2] = 0;
        buffer[3] = 0;
        i++;
      }
      else {
        printf("Unexpected input file end!\n");
        break;
      }
      address += 4;
    }

    if (fread(&buffer, sizeof(unsigned char), 4, input) != 0) {
      tmp  = (uint32_t)(buffer[0] << 0);
      tmp |= (uint32_t)(buffer[1] << 8);
      tmp |= (uint32_t)(buffer[2] << 16);
      tmp |= (uint32_t)(buffer[3] << 24);
      sprintf(tmp_string, "\t\t\t32\'h%08x : data_o = 32\'h%08x ;\n", (unsigned int) address, (unsigned int)tmp);
      fputs(tmp_string, output);
      buffer[0] = 0;
      buffer[1] = 0;
      buffer[2] = 0;
      buffer[3] = 0;
      i++;
    }
    else {
      printf("Unexpected input file end!\n");
    }

    // end
    sprintf(tmp_string, "\t\t\tdefault : data_o = 32\'h00000000 ;\n"
                        "\t\tendcase \n"
                        "\tend\n"
                        "endmodule\n");

    fputs(tmp_string, output);

  fclose(input);
  fclose(output);
}