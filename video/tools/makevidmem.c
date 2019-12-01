#include <stdio.h>
#include <stdlib.h>
//"......." at end is padding
char vidstr[] =
"1A345678901234567890"
"*        1         2"
"* @@@@@@@@@@@@@@@@ *"
"* A              A *"
"* B ############ B *"
"* C X          X C *"
"* D X !!!!!!!! X D *"
"* E X > ~  ~ < X E *"
"* F X :~:**:~: X F *"
"* G X          X G *"
"* H ############ H *"
"* I              I *"
"* !!!!!!!!!!!!!!!! *"
"*                  *"
"* * * * * * * * * */";

int main(int argc, char **argv)
{
    FILE *fp;

    fp = fopen("video.mem","wt");

    for(int i=0;i < (20*15); i++) {
        fprintf(fp,"%02x\n",vidstr[i]);
    }

    fclose(fp);
    return 0;
}
