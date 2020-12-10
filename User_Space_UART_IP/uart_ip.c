// UART IP Example
// UART IP Library (uart_ip.c)
// Krishna Patel

//-----------------------------------------------------------------------------
// Hardware Target
//-----------------------------------------------------------------------------

// Target Platform: DE1-SoC Board

// Hardware configuration:
// UART Port: 
// GPIO_1[0] (pin AK18) UART_CLK_OUT ***NEEDS TO BE CONFIGURED
// GPIO_1[1] (pin Y17)  UART_TX      ***NEEDS TO BE CONFIGURED
// GPIO_1[3] (pin Y18)  UART_RX      ***NEEDS TO BE CONFIGURED
//
// GPIO_1[31-0] is used as a general purpose GPIO port
// HPS interface:
//   Mapped to offset of 0x400 in light-weight MM interface aperature

//-----------------------------------------------------------------------------

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>           // open
#include <sys/mman.h>        // mmap
#include <unistd.h>          // close
#include "address_map.h"     // address map
#include "uart_ip.h"         // gpio
#include "uart_regs.h"       // registers

//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------

uint32_t *uart_base = NULL;

//-----------------------------------------------------------------------------
// Subroutines
//-----------------------------------------------------------------------------

bool uartOpen()
{
    // Open /dev/gpiomem 
    // Use instead of /dev/mem since location does not change and no root access required
    int file = open("/dev/mem", O_RDWR | O_SYNC);
    bool bOK = (file >= 0);
    if (bOK)
    {
        // Create a map from the physical memory location of
        // /dev/mem at an offset to LW avalon interface
        // with an aperature of SPAN_IN_BYTES bytes
        // to any location in the virtual 32-bit memory space of the process
        uart_base = mmap(NULL, UART_SPAN_IN_BYTES, PROT_READ | PROT_WRITE, MAP_SHARED,
                    file, LW_BRIDGE_BASE + UART_BASE_OFFSET);
        bOK = (uart_base != MAP_FAILED);

        // Close /dev/uartmem 
        close(file);
    }
    return bOK;
}

//pin 4 Recovery Clock
bool getUartTestCLKValue()
{
    uint32_t value = *(uart_base+OFS_UART_CONTROL);
    return (value >> 4) & 1;
}

uint32_t getSTATUSValue()
{
    uint32_t value = *(uart_base+OFS_UART_STATUS);
    return value;
}

uint32_t getCONTROLValue()
{
    uint32_t value = *(uart_base+OFS_UART_CONTROL);
    return value;
}
uint8_t getSIZE()
{
     uint32_t value = *(uart_base+OFS_UART_CONTROL);
     return (value & 1);
}
void setSIZE(bool size)
{
    if(size)
        *(uart_base+OFS_UART_CONTROL) |= 1;
    else
      *(uart_base+OFS_UART_CONTROL) &= ~1;
}
void enableTX()
{
    uint32_t mask = 1 << 3;
    *(uart_base+OFS_UART_CONTROL) |= mask;
}

void disableTX()
{
    uint32_t mask = 1 << 3;
    *(uart_base+OFS_UART_CONTROL) &= ~mask;
}

void enable8bitTX()
{
    uint32_t mask = 1;
    *(uart_base+OFS_UART_CONTROL) |= mask;
}
void disable8bitTX()
{
    uint32_t mask = 1;
    *(uart_base+OFS_UART_CONTROL) &= ~mask;
}
void setParity(uint8_t value)
{
   
    if (value == 0)
    {
        *(uart_base+OFS_UART_CONTROL) &= ~6;
    }
    else if (value ==1)
    {
        *(uart_base+OFS_UART_CONTROL) |= 2; 
        *(uart_base+OFS_UART_CONTROL) &= ~(4);
    }
    else if (value ==2)
    {
        *(uart_base+OFS_UART_CONTROL) &= ~(2); 
        *(uart_base+OFS_UART_CONTROL) |= (4);
    }
    else if (value ==3)
    {
        *(uart_base+OFS_UART_CONTROL) |= 6;
    }
}
uint32_t getBRDValue()
{
    uint32_t value = *(uart_base+OFS_UART_BRD);
    return value;
}
void setBRDValue(uint32_t IBRD, uint32_t FBRD)
{
    *(uart_base+OFS_UART_BRD)= (IBRD << 5) | FBRD;
}
void txData( uint8_t value)
{
   *(uart_base+OFS_UART_DATA) =  value;
}
uint8_t rxData()
{
    uint8_t value = *(uart_base+OFS_UART_DATA);
    return value;
}
