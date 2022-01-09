#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

// Crypt your shellcode with this C program before pasting it into the DLL's buf variable
int main (int argc, char **argv) {
    unsigned char buf[] ="PLAIN_SHELLCODE_HERE";
    char xor_key = '7';
    int payload_length = (int) sizeof(buf);

    for (int i=0; i<payload_length; i++) {
        printf("\\x%02X", buf[i]^xor_key);
    }
}
