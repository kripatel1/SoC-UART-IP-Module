

#include <stdlib.h>          // EXIT_ codes
#include <stdio.h>           // printf
#include "uart_ip.h"         // GPIO IP library
#include "gpio_ip.h"

int main(int argc, char* argv[])
{
    int pin;
    uint32_t IBRD;
    uint32_t FBRD;
    char* size;
    uartOpen();
    if (argc == 2)
    {
        if (strcmp(argv[1], "size") == 0)
        {
         if(getSIZE())
            printf("uart is 8-bit words\n");
          else
            printf("uart is 7-bit words\n");
        }
            
        else if (strcmp(argv[1], "enable") == 0)
                enableTX();
        else if (strcmp(argv[1], "disable") == 0)
                disableTX();
        else if (strcmp(argv[1], "BRD") == 0)
                printf("%u\n",getBRDValue());                
        else if (strcmp(argv[1], "8bit") == 0)
                enable8bitTX();
        else if (strcmp(argv[1], "7bit") == 0)
                disable8bitTX();
        else if (strcmp(argv[1], "rx") == 0)
           printf("%c RECIEVED\n", rxData());
        else
            printf("argument %s not expected\n", argv[1]);
    }
    else if (argc == 4)
    {
        uartOpen();
        IBRD = atoi(argv[1]);
        FBRD = atoi(argv[2]);

        if (strcmp(argv[1], "set_BRD") == 0)
        {
            setBRDValue(IBRD,FBRD);
        }
       
        else
            printf("argument %s not expected\n", argv[1]);
    }
     else if (argc == 3)
        if (strcmp(argv[1], "tx") == 0)
        {
           printf("%d TRANSMITTED\n", argv[2][0]);
           txData(argv[2][0]);
        }
       
        
    else
        printf("  command not understood\n");
    return EXIT_SUCCESS;
}