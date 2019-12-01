#include <stdio.h>

int main(int argc, const char** argv) {

    if (argc!=3) return 1;


    unsigned char abyte;
    FILE *inp;
    FILE *outp;

    inp = fopen(argv[1],"rb");  // r for read, b for binary
    outp = fopen (argv[2], "w");

    while (fread(&abyte,1,1,inp) ) {
       fprintf(outp, "%02x\n", abyte);
    }
    fclose(outp);
    fclose(inp);


    return 0;
}
