#include <stdio.h>
#include <stdlib.h>

#include "font8x8_basic.h"

unsigned char reverse_byte(char a)
{

  return ((a & 0x1)  << 7) | ((a & 0x2)  << 5) |
         ((a & 0x4)  << 3) | ((a & 0x8)  << 1) |
         ((a & 0x10) >> 1) | ((a & 0x20) >> 3) |
         ((a & 0x40) >> 5) | ((a & 0x80) >> 7);
}

int main(int argc, char **argv) {


   FILE *fp,*fp2;

   //fp = fopen("8x8.data", "wb");  // used to import to graphics package for visual inspection
   fp2 = fopen("8x8rom.mem","wt");

    for(int i=32;i < 127; i++) {
        for (int y=0;y<8;y++) {
//            fprintf(fp,"%c",reverse_byte(bitmap[y]));
            fprintf(fp2,"%02x\n",(unsigned char)font8x8_basic[i][y]);
        }

    }
    fclose(fp2);
   // fclose(fp);
    return 0;
}
